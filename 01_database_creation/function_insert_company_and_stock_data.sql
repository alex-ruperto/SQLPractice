-- Function to insert company and its stock data.
CREATE OR REPLACE FUNCTION insert_company_and_stock_data(
    -- Parameters are prefixed with 'p_' to indicate they are parameters.
    p_ticker_symbol VARCHAR(10),
    p_company_name VARCHAR(100),
    p_sector VARCHAR(50) DEFAULT NULL,
    p_founded_year INTEGER DEFAULT NULL,
    p_headquarters VARCHAR(100) DEFAULT NULL,
    p_file_path TEXT -- Path to the CSV file
) RETURNS VOID AS $$ -- Will return nothing, $$ is the delimiter for the function body in PostgreSQL.

-- DECLARE block is used for storing local variables within the function. 
DECLARE
    -- Variables are prefixed with 'v_' to indicate they are local variables.
    v_company_id INTEGER; -- Variable to store the auto-generated ID of the inserted company.
    v_csv_line RECORD; -- Variable to store each line of the CSV data as a record.
    v_date DATE;
    v_open_price NUMERIC(10, 2);
    v_high_price NUMERIC(10, 2);
    v_low_price NUMERIC(10, 2);
    v_close_price NUMERIC(10, 2);
    v_adj_close_price NUMERIC(10, 2);
    v_volume INTEGER;
BEGIN
    -- First, insert the company data.
    -- SERIAL type in the table will automatically generate a unique ID for the company.
    INSERT INTO companies (ticker_symbol, company_name, sector, founded_year, headquarters)
    VALUES (p_ticker_symbol, p_company_name, p_sector, p_founded_year, p_headquarters)
    -- RETURNING clause captures the auto-generated company_id value.
    RETURNING company_id INTO v_company_id;

    -- Create a temporary table to hold the CSV data
    -- This table will automatically be dropped at the end of the session
    CREATE TEMP TABLE temp_stock_data (
        date TEXT,
        open_price TEXT,
        high_price TEXT,
        low_price TEXT,
        close_price TEXT,
        adj_close_price TEXT,
        volume TEXT
    );

    -- Use the COPY command to import data from the CSV file into the temporary table
    -- HEADER option skips the first line which contains headers
    -- The format function safely escapes the file path parameter
    EXECUTE format('COPY temp_stock_data FROM %L CSV HEADER', p_file_path);

    -- Process each row in the temporary table
    FOR v_csv_line IN SELECT * FROM temp_stock_data LOOP
        -- Begin an exception block to handle potential errors in data conversion.
        BEGIN  
            -- Convert each field to the appropriate data type.
            -- The :: operator converts the text value to the specified data type.
            v_date := v_csv_line.date::DATE;
            v_open_price := v_csv_line.open_price::NUMERIC(10, 2);
            v_high_price := v_csv_line.high_price::NUMERIC(10, 2);
            v_low_price := v_csv_line.low_price::NUMERIC(10, 2);
            v_close_price := v_csv_line.close_price::NUMERIC(10, 2);
            v_adj_close_price := v_csv_line.adj_close_price::NUMERIC(10, 2);
            v_volume := v_csv_line.volume::INTEGER;

            -- Insert the parsed values into the stock_data_daily table.
            INSERT INTO stock_data_daily (company_id, date, open_price, high_price, low_price, close_price, adj_close_price, volume)
            VALUES (v_company_id, v_date, v_open_price, v_high_price, v_low_price, v_close_price, v_adj_close_price, v_volume)

            -- Handle the case where we try to insert a duplicate record
            -- The unique_company_date constraint ensures no duplicates for the same company on the same date
            -- DO NOTHING is used to skip the insert if a duplicate is found.
            ON CONFLICT (company_id, date) DO NOTHING;
        
        -- Exception handling - if any errors occur during parsing or insertion,
        -- OTHERS catches all types of errors
        EXCEPTION WHEN OTHERS THEN
            -- Raise a notice that there was an error processing the line
            RAISE NOTICE 'Error processing line: %', v_csv_line;
        END;
    END LOOP;

    -- Drop the temporary table to clean up
    DROP TABLE temp_stock_data;

    -- Final notification that the process completed successfully.
    RAISE NOTICE 'Successfully inserted company % (%) and its stock data.',
        p_company_name, p_ticker_symbol;
END;
-- $$ is the delimiter for the function body.
-- LANGUAGE plpgsql; -- Specifies that this function uses the PL/pgSQL procedural language
$$ LANGUAGE plpgsql;
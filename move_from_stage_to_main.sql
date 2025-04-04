-- Define ticker as a variable
DO $$
Declare
	import_ticker VARCHAR = 'NIO'; -- Change this for import
	existing_count INTEGER;
BEGIN
	-- Check if the ticker already exists
	SELECT COUNT(*) INTO existing_count
	FROM stocks
	WHERE ticker_symbol = import_ticker;

	-- Raise exception if the ticker already exists
	IF existing_count > 0 THEN
		RAISE EXCEPTION 'Ticker % already exists in the database', import_ticker;

	END IF;

RAISE NOTICE 'Importing data for ticker: %', import_ticker;

-- The SELECT statement won't show results inside a DO block
-- Instead, we'll count and report the rows
RAISE NOTICE 'Rows to import: %', (SELECT COUNT(*) FROM staging_import);

-- Insert the data with ticker symbol
-- Make sure to adjust the ticker symbol
INSERT INTO stocks (ticker_symbol, date, open, high, low, close, adj_close, volume)
SELECT import_ticker, date, open, high, low, close, adj_close, volume
FROM staging_import;

-- Report the inserted count
RAISE NOTICE 'Inserted % rows for ticker %', 
	(SELECT COUNT(*) FROM stocks WHERE ticker_symbol = import_ticker),
    import_ticker;

RAISE NOTICE 'Cleaning the staging_import table';
-- Clean the staging table for the next import
TRUNCATE TABLE staging_import;

END $$;
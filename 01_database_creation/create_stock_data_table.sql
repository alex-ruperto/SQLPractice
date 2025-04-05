-- Date,Open,High,Low,Close,Adj Close,Volume
-- Create a table for daily stock data 
CREATE TABLE stock_data_daily (
	stock_data_id SERIAL PRIMARY KEY, 
	company_id INTEGER NOT NULL,
	date DATE NOT NULL,
	-- The following columns provide numeric values of max 10 digits, 2 decimal places to the right, 8 to the left.
	open_price NUMERIC(10,2), 
	high_price NUMERIC(10,2),
	low_price NUMERIC(10,2),
	close_price NUMERIC(10,2),
	adj_close_price NUMERIC(10,2),
	volume INTEGER,

	-- CONSTRAINT 
	CONSTRAINT unique_company_date UNIQUE (company_id, date)
);
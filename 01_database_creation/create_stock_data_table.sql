-- Date,Open,High,Low,Close,Adj Close,Volume
-- Create a table for daily stock data 
CREATE TABLE stock_data_daily (
	stock_data_id SERIAL PRIME KEY,
	stock_data_id SERIAL PRIMARY KEY, 
	company_id INTEGER NOT NULL,
	date DATE NOT NULL,
	open_price NUMERIC(10,2), 
	high_price NUMERIC(10,2),
)
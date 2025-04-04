-- Create a table for companies
CREATE TABLE companies (
	company_id SERIAL PRIMARY KEY, -- auto-incrementing primary ID
	ticker_symbol VARCHAR(10) UNIQUE NOT NULL, -- stock symbol (must be unique)
	company_name VARCHAR(100) NOT NULL, -- full company name
	sector VARCHAR(50), -- industry sector
	founded_year INTEGER, -- when the company was founded
	headquarters VARCHAR(100) -- company headquarters location
)
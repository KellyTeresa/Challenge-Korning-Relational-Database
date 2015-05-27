-- DEFINE YOUR DATABASE SCHEMA HERE

DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS frequency;
DROP TABLE IF EXISTS transactions;

CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE customers (
  account_id CHAR(8) PRIMARY KEY,
  company VARCHAR(100) NOT NULL
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE frequency (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE transactions (
  employee SMALLINT,
  customer CHAR(8),
  product SMALLINT,
  sale_date DATE,
  sale_amount MONEY,
  units_sold INTEGER,
  invoice_id SERIAL PRIMARY KEY,
  frequency SMALLINT
);

INSERT INTO frequency (name) VALUES ('once');
INSERT INTO frequency (name) VALUES ('monthly');
INSERT INTO frequency (name) VALUES ('quarterly');

-- 02_load_external_table.sql
-- Load CSV using an EXTERNAL TABLE (recommended).
-- You need a DIRECTORY object that points to a folder on the DB server.

-- 1) Create a DIRECTORY (DBA action usually). Example:
-- CREATE OR REPLACE DIRECTORY debt_dir AS '/path/on/dbserver/oracle-debtors-portfolio/data';
-- GRANT READ, WRITE ON DIRECTORY debt_dir TO <your_schema>;

-- 2) Point the external table to your CSV file:
-- TODO: set YOUR directory name + CSV filename.

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ext_debtors_csv';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE ext_debtors_csv (
  row_id            VARCHAR2(50),
  client_code       VARCHAR2(30),
  phone_masked      VARCHAR2(30),
  floor             VARCHAR2(50),
  apartment_no      VARCHAR2(50),
  area_m2           VARCHAR2(50),
  purchase_start    VARCHAR2(50),
  purchase_end      VARCHAR2(50),
  total_amount      VARCHAR2(50),
  down_payment      VARCHAR2(50),
  paid_amount       VARCHAR2(50),
  debt_amount_clean VARCHAR2(50),
  return_date       VARCHAR2(50),
  price_per_m2      VARCHAR2(50),
  location          VARCHAR2(200)
)
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY debt_dir   -- TODO: change to your DIRECTORY object name
  ACCESS PARAMETERS (
    RECORDS DELIMITED BY NEWLINE
    SKIP 1
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    MISSING FIELD VALUES ARE NULL
    (
      row_id, client_code, phone_masked, floor, apartment_no, area_m2,
      purchase_start CHAR(50),
      purchase_end   CHAR(50),
      total_amount, down_payment, paid_amount, debt_amount_clean,
      return_date CHAR(50),
      price_per_m2, location
    )
  )
  LOCATION ('debtors_anonymized.csv') -- TODO: CSV name
)
REJECT LIMIT UNLIMITED;

-- Load into staging (stg_debtors_raw uses "full_name" and "phone_raw",
-- but this anonymized CSV already has masked fields, so we load into stg columns we can.)
TRUNCATE TABLE stg_debtors_raw;

INSERT INTO stg_debtors_raw (
  row_id, full_name, phone_raw, floor, apartment_no, area_m2,
  purchase_start, purchase_end, total_amount, down_payment, paid_amount,
  debt_amount, return_date, price_per_m2, location
)
SELECT
  row_id,
  client_code,          -- store masked code in full_name field for demo data
  phone_masked,         -- store masked phone in phone_raw field for demo data
  floor, apartment_no, area_m2,
  purchase_start, purchase_end,
  total_amount, down_payment, paid_amount,
  debt_amount_clean,
  return_date, price_per_m2, location
FROM ext_debtors_csv;

COMMIT;

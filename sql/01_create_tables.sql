-- 01_create_tables.sql
-- Staging table keeps everything as strings (like a raw CSV landing zone).
-- Final tables have proper types and contain masked PII only.

-- Optional: run in your schema (USER)
-- ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE stg_debtors_raw PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE debtors_clean PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE stg_debtors_raw (
  row_id            VARCHAR2(50),
  full_name         VARCHAR2(4000),
  floor             VARCHAR2(50),
  apartment_no      VARCHAR2(50),
  area_m2           VARCHAR2(50),
  purchase_start    VARCHAR2(50),
  purchase_end      VARCHAR2(50),
  phone_raw         VARCHAR2(4000),
  total_amount      VARCHAR2(50),
  down_payment      VARCHAR2(50),
  paid_amount       VARCHAR2(50),
  debt_amount       VARCHAR2(50),
  return_date       VARCHAR2(50),
  price_per_m2      VARCHAR2(50),
  location          VARCHAR2(200)
);

-- Clean, analytics-friendly table with masked PII
CREATE TABLE debtors_clean (
  row_id            NUMBER       NOT NULL,
  client_code       VARCHAR2(30) NOT NULL,
  phone_masked      VARCHAR2(30),
  floor             NUMBER,
  apartment_no      NUMBER,
  area_m2           NUMBER(10,2),
  purchase_start    DATE,
  purchase_end      DATE,
  total_amount      NUMBER(14,2),
  down_payment      NUMBER(14,2),
  paid_amount       NUMBER(14,2),
  debt_amount       NUMBER(14,2),
  return_date       DATE,
  price_per_m2      NUMBER(14,6),
  location          VARCHAR2(200),
  CONSTRAINT pk_debtors_clean PRIMARY KEY (row_id)
);

CREATE INDEX ix_debtors_clean_debt ON debtors_clean (debt_amount);
CREATE INDEX ix_debtors_clean_location ON debtors_clean (location);

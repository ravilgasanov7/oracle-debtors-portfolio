-- 03_transform_and_mask.sql
-- Clean + standardize types and mask PII.
-- Works in two modes:
--   A) Real raw data: stg_debtors_raw.full_name contains real name, stg_debtors_raw.phone_raw contains raw phone
--   B) Demo anonymized CSV: full_name already contains CLIENT_CODE and phone_raw contains PHONE_MASKED

-- Helper inline functions (as expressions):
-- - Extract digits from phone: REGEXP_REPLACE(phone_raw, '[^0-9]', '')
-- - Mask: keep last 3 digits
-- - Deterministic client code: 'CLIENT_' || SUBSTR(STANDARD_HASH(salt||full_name,'SHA256'),1,10)

-- Set a salt that you DON'T publish if you want stronger privacy.
-- For a portfolio repo, it's fine to keep a demo salt for reproducibility.
DEFINE salt = 'demo_salt_2026';

TRUNCATE TABLE debtors_clean;

INSERT INTO debtors_clean (
  row_id, client_code, phone_masked, floor, apartment_no, area_m2,
  purchase_start, purchase_end,
  total_amount, down_payment, paid_amount, debt_amount, return_date,
  price_per_m2, location
)
SELECT
  TO_NUMBER(NULLIF(TRIM(row_id), '')) AS row_id,

  -- If FULL_NAME already looks like CLIENT_xxx, keep it; otherwise hash it.
  CASE
    WHEN full_name LIKE 'CLIENT_%' THEN SUBSTR(full_name, 1, 30)
    ELSE 'CLIENT_' || SUBSTR(STANDARD_HASH('&salt' || TRIM(full_name), 'SHA256'), 1, 10)
  END AS client_code,

  -- If phone_raw already masked (contains '*'), keep it; otherwise mask digits.
  CASE
    WHEN phone_raw LIKE '%*%' THEN SUBSTR(phone_raw, 1, 30)
    ELSE
      CASE
        WHEN REGEXP_REPLACE(phone_raw, '[^0-9]', '') IS NULL THEN NULL
        WHEN LENGTH(REGEXP_REPLACE(phone_raw, '[^0-9]', '')) <= 3 THEN '***'
        ELSE
          RPAD('*', LENGTH(REGEXP_REPLACE(phone_raw, '[^0-9]', '')) - 3, '*')
          || SUBSTR(REGEXP_REPLACE(phone_raw, '[^0-9]', ''), -3)
      END
  END AS phone_masked,

  TO_NUMBER(NULLIF(TRIM(floor), '')) AS floor,
  TO_NUMBER(NULLIF(TRIM(apartment_no), '')) AS apartment_no,
  TO_NUMBER(NULLIF(TRIM(area_m2), '')) AS area_m2,

  -- Dates: accept YYYY-MM-DD; treat 1900-01-01 as NULL (Excel placeholder)
  CASE
    WHEN TRIM(purchase_start) IS NULL THEN NULL
    ELSE TO_DATE(TRIM(purchase_start), 'YYYY-MM-DD')
  END AS purchase_start,

  CASE
    WHEN TRIM(purchase_end) IS NULL THEN NULL
    ELSE TO_DATE(TRIM(purchase_end), 'YYYY-MM-DD')
  END AS purchase_end,

  TO_NUMBER(NULLIF(TRIM(total_amount), '')) AS total_amount,
  TO_NUMBER(NULLIF(TRIM(down_payment), '')) AS down_payment,
  TO_NUMBER(NULLIF(TRIM(paid_amount), '')) AS paid_amount,

  -- Debt: if missing, compute total - (down + paid)
  COALESCE(
    TO_NUMBER(NULLIF(TRIM(debt_amount), '')),
    TO_NUMBER(NULLIF(TRIM(total_amount), '')) - (NVL(TO_NUMBER(NULLIF(TRIM(down_payment), '')),0) + NVL(TO_NUMBER(NULLIF(TRIM(paid_amount), '')),0))
  ) AS debt_amount,

  CASE
    WHEN TRIM(return_date) IS NULL THEN NULL
    WHEN TRIM(return_date) LIKE '1900-01-01%' THEN NULL
    ELSE TO_DATE(SUBSTR(TRIM(return_date), 1, 10), 'YYYY-MM-DD')
  END AS return_date,

  TO_NUMBER(NULLIF(TRIM(price_per_m2), '')) AS price_per_m2,
  TRIM(location) AS location
FROM stg_debtors_raw;

COMMIT;

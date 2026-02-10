# Data dictionary

## stg_debtors_raw (staging)

Raw landing zone. All columns are strings to avoid load failures.

- `ROW_ID` — row number / surrogate id
- `FULL_NAME` — real customer name **(do not publish)** or `CLIENT_CODE` in demo data
- `PHONE_RAW` — raw phone **(do not publish)** or `PHONE_MASKED` in demo data
- `FLOOR`, `APARTMENT_NO`, `AREA_M2`
- `PURCHASE_START`, `PURCHASE_END` — dates as text
- `TOTAL_AMOUNT`, `DOWN_PAYMENT`, `PAID_AMOUNT`, `DEBT_AMOUNT`
- `RETURN_DATE` — Excel placeholder `1900-01-01` is treated as NULL
- `PRICE_PER_M2`
- `LOCATION`

## debtors_clean (final)

Masked + typed table for analytics.

- `CLIENT_CODE` — deterministic masked id (hash)
- `PHONE_MASKED` — masked phone (only last 3 digits visible)
- numeric columns are `NUMBER`, dates are `DATE`

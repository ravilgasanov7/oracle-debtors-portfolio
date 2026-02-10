# Oracle SQL Portfolio Project — Debtors ETL (CSV → Clean → Mask PII)

This portfolio project shows an end‑to‑end **ETL pipeline in Oracle**:

1) Load a CSV into a **staging table** (raw strings)  
2) Clean and standardize types (numbers, dates, phones)  
3) **Mask personal data (PII)** — client names + phone numbers  
4) Build an analytics‑friendly table + example queries

> ✅ The repository contains **ONLY anonymized data** (`data/debtors_anonymized.csv`).  
> ❌ Do **NOT** commit the original CSV/XLSM with real names/phones.

---

## Folder structure

- `data/`
  - `debtors_anonymized.csv` — demo data with masked PII
- `sql/`
  - `01_create_tables.sql` — staging + target tables
  - `02_load_external_table.sql` — optional: load using External Table
  - `03_transform_and_mask.sql` — cleaning + masking logic
  - `04_quality_checks.sql` — data quality checks + examples
- `docs/`
  - `data_dictionary.md`

---

## Option A (recommended for portfolio): External Table

External tables are clean and easy to reproduce.

1) Create tables
```sql
@sql/01_create_tables.sql
```

2) Update the file path inside `sql/02_load_external_table.sql` (see the comment `-- TODO: set your path`), then run:
```sql
@sql/02_load_external_table.sql
```

3) Transform + mask
```sql
@sql/03_transform_and_mask.sql
```

4) Run checks + sample analytics
```sql
@sql/04_quality_checks.sql
```

---

## Option B: SQL*Loader (classic)

If you prefer SQL*Loader, use `sql/debtors_sqlldr.ctl` and `sql/run_sqlldr_example.txt`.
(External tables are usually simpler for recruiters to review, so Option A is enough.)

---

## What gets masked?

- **Name → `CLIENT_CODE`**
  - Deterministic hash-based code (same input name → same output code).
- **Phone → `PHONE_MASKED`**
  - Only last 3 digits visible, the rest replaced with `*`.

---

## Example questions this dataset answers

- Top 20 biggest debtors by amount
- Debt distribution by location / floor
- Apartments with duplicate records
- Customers with missing purchase dates or weird payments

---

## Tech highlights

- Oracle data cleaning with `REGEXP_REPLACE`, `TO_NUMBER`, `TO_DATE`
- Deterministic masking with `STANDARD_HASH`
- Reproducible ETL scripts (create → load → transform → checks)

---

## Notes

- Tested with Oracle 12c+ (because `STANDARD_HASH` is used).
- If your Oracle version is older, replace hashing with `DBMS_CRYPTO.HASH`.
# oracle-debtors-portfolio
Oracle SQL ETL project: loading CSV debtors data, data cleaning, PII masking, and analytical queries using staging and DWH tables.

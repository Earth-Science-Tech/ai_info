# Skill: ETL Debug

## Trigger

When debugging ETL pipeline issues (Peaks Curative or Liberty Pharmacy).

## Debugging Checklist

### 1. Check ETL metadata
```sql
SELECT TOP 10 * FROM etl_metadata ORDER BY date_modified DESC;
```
Look for: last successful run time, error messages, processing flags.

### 2. Check for stuck processing flags
```sql
-- Orders stuck in processing
SELECT * FROM woo_orders WHERE processing_status = 'in_progress';

-- Questionnaires stuck in processing
SELECT * FROM wpforms_entries WHERE processing_status = 'in_progress';
```

Reset if needed: `python scripts/reset_processing_flags.py`

### 3. Verify source data
- **WooCommerce:** Check peakscurative.com admin for recent orders
- **WPForms:** Check WPForms entries in WordPress admin
- **Liberty RX:** Check Liberty database connectivity

### 4. Check order-questionnaire matching
```bash
python scripts/check_questionnaire_matching.py
```
Common issues: mismatched email addresses, missing form submissions.

### 5. Check API connectivity
```bash
# Test eMed API endpoint
curl -X POST https://emed.azurewebsites.net/api/public/moct-visit -H "Content-Type: application/json"
```

### 6. Check permissions
If getting permission errors, verify the `emed_etl` user has grants:
```sql
SELECT dp.name, o.name AS object_name, p.permission_name
FROM sys.database_permissions p
JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
JOIN sys.objects o ON p.major_id = o.object_id
WHERE dp.name = 'emed_etl'
ORDER BY o.name;
```

## Common Issues

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| No new orders appearing | WooCommerce API key expired | Update `.env` WOO_CONSUMER_KEY/SECRET |
| Permission denied on table | Missing GRANT for emed_etl | Create migration script with GRANTs |
| Duplicate visits created | Processing flag not set | Check/reset processing flags |
| SSH connection failed | Cloudways password changed | Update `.env` SSH credentials |
| Questionnaire not matching | Email mismatch | Check `check_questionnaire_matching.py` |

## Applies To

- **emed_etl** — all ETL scripts
- **emed_app** — API endpoint receiving ETL data

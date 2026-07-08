# Validation — SSIS

Validation and reconciliation checks to confirm ETL accuracy are implemented as part of the SSIS workflow.

## Approach
Validation can be handled in SSIS using:
- **Row Count** transformations — compare source vs. destination row counts
- **Execute SQL Task** — run spot-check queries after each load and fail the package on mismatch
- **Data Flow error outputs** — capture and log rejected/mismatched rows

## Suggested Checks
| Check | Method |
|---|---|
| Staging row counts match source | Row Count + Script Task comparison |
| No NULLs in surrogate keys | Execute SQL Task post-load |
| FactSales row count matches staging | Row Count comparison |
| Duplicate fact rows | Execute SQL Task (`HAVING COUNT(*) > 1`) |
| Date range coverage | Execute SQL Task on DimDate |

## Notes
- Add an event handler at package level to send failure alerts
- Log validation results to a control/audit table for traceability

-- Verify Agent job last run status
SELECT 
    j.name,
    h.run_date,
    h.run_time,
    CASE h.run_status WHEN 1 THEN 'Succeeded' WHEN 0 THEN 'Failed' ELSE 'Other' END AS Status,
    h.message
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
WHERE j.name = 'AdventureWorks_ETL_Weekly'
  AND h.step_id = 0  -- 0 = job-level outcome
ORDER BY h.run_date DESC, h.run_time DESC
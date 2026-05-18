USE master
GO

IF DB_ID('AdventureWorks_Staging') > 0
BEGIN
    ALTER DATABASE AdventureWorks_Staging SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE AdventureWorks_Staging
END
GO

CREATE DATABASE AdventureWorks_Staging
GO

USE AdventureWorks_Staging
GO
USE master
GO
 IF DB_id('AdventureWorks_DW') > 0
    BEGIN
        ALTER DATABASE AdventureWorks_DW SET SINGLE_USER WITH ROLLBACK IMMEDIATE
        DROP DATABASE AdventureWorks_DW
    END

 CREATE DATABASE AdventureWorks_DW
 GO

USE AdventureWorks_DW
GO

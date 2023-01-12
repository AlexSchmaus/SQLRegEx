USE master
GO

-- 
-- Alex Schmaus
-- 1/12/2023
--
-- Creates SQL functions from the complied dll's
--

/*
-- Allow the configuration of advanced options
EXEC sp_configure 'show advanced options', 1
RECONFIGURE

-- Enable CLR
EXEC sp_configure 'clr enable', 1
RECONFIGURE

-- turn off CLR strict -> our code is not signed
-- ToDo: figure out code signing
EXEC sp_configure 'clr strict security', 0
RECONFIGURE
GO
*/

-- cleanup past tests
DROP FUNCTION IF EXISTS CLR_isRegexMatch
DROP FUNCTION IF EXISTS CLR_returnRegexMatches
GO
DROP ASSEMBLY IF EXISTS RegexFuncions
DROP ASSEMBLY IF EXISTS RegexFunctions
GO

-- Create the assembly in SQL from the dll we compiled from the C# code
CREATE ASSEMBLY RegexFunctions FROM 'C:\SQL_CLR\SQLRegEx.dll'
GO

-- Create the function
-- SqlString in CLR = nvarchar NOT varchar
CREATE FUNCTION CLR_isRegexMatch(@str nvarchar(2048), @pattern nvarchar(512))
RETURNS bit
-- name is AssemblyName.NamespaceName.FunctionName
EXTERNAL NAME RegexFunctions.UserDefinedFunctions.isRegexMatch
GO

CREATE FUNCTION CLR_returnRegexMatches(@str nvarchar(4000), @pattern nvarchar(512))
RETURNS TABLE ([index] int, [group] nvarchar(4000), [value] nvarchar(4000))
EXTERNAL NAME RegexFunctions.UserDefinedFunctions.returnRegexMatches
GO


-- Test!
SELECT
	dbo.CLR_isRegexMatch('Hello World', 'H'),												-- Should return 1 (true)
	dbo.CLR_isRegexMatch('Hello World', '/d'),												-- Should return 0
	dbo.CLR_isRegexMatch('9/23/1957','((?<m>\d{1,2})\/(?<d>\d{1,2})\/(?<y>\d{4}|\d{2}))'),	-- Should return 1
	dbo.CLR_isRegexMatch('Bob Dole','((?<m>\d{1,2})\/(?<d>\d{1,2})\/(?<y>\d{4}|\d{2}))'),	-- Should return 0
	dbo.CLR_isRegexMatch('11/1/91','((?<m>\d{1,2})\/(?<d>\d{1,2})\/(?<y>\d{4}|\d{2}))')		-- Should return 1

SELECT
	*
FROM dbo.CLR_returnRegexMatches('11/1/91','((?<m>\d{1,2})\/(?<d>\d{1,2})\/(?<y>\d{4}|\d{2}))')
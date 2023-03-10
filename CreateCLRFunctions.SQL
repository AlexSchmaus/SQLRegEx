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
DROP FUNCTION IF EXISTS CLR_isRegexPattern
DROP FUNCTION IF EXISTS CLR_isRegexMatch
DROP FUNCTION IF EXISTS CLR_returnRegexMatches
DROP FUNCTION IF EXISTS CLR_returnRegexCaptures
GO
DROP ASSEMBLY IF EXISTS RegexFuncions
DROP ASSEMBLY IF EXISTS RegexFunctions
GO

-- Create the assembly in SQL from the dll we compiled from the C# code
CREATE ASSEMBLY RegexFunctions FROM 'C:\SQL_CLR\SQLRegEx.dll'
GO

-- Create the functions
-- SqlString in CLR = nvarchar NOT varchar
CREATE FUNCTION CLR_isRegexMatch(@str nvarchar(2048), @pattern nvarchar(512))
RETURNS bit
-- name is AssemblyName.NamespaceName.FunctionName
EXTERNAL NAME RegexFunctions.UserDefinedFunctions.isRegexMatch
GO

CREATE FUNCTION CLR_returnRegexMatches(@str nvarchar(4000), @pattern nvarchar(512))
RETURNS TABLE ([index] int, [value] nvarchar(4000))	-- index is 0 index'd
EXTERNAL NAME RegexFunctions.UserDefinedFunctions.returnRegexMatches
GO

CREATE FUNCTION CLR_returnRegexCaptures(@str nvarchar(4000), @pattern nvarchar(512))
RETURNS TABLE ([match] nvarchar(4000), [matchIndex] int, [group] nvarchar(4000), [value] nvarchar(4000))
EXTERNAL NAME RegexFunctions.UserDefinedFunctions.returnRegexCaptures
GO

CREATE FUNCTION CLR_isRegexPattern(@pattern nvarchar(4000))
RETURNS bit
EXTERNAL NAME RegexFunctions.UserDefinedFunctions.isRegexPattern
GO

-- Test! ---------------------------------------------------------------------------------------------------------------

-- Function 1 - isRegexMatch
SELECT
	dbo.CLR_isRegexMatch('Hello World', 'H'),												-- Should return 1 (true)
	dbo.CLR_isRegexMatch('Hello World', '/d'),												-- Should return 0
	dbo.CLR_isRegexMatch('9/23/1957','((?<m>\d{1,2})\/(?<d>\d{1,2})\/(?<y>\d{4}|\d{2}))'),	-- Should return 1
	dbo.CLR_isRegexMatch('Bob Dole','((?<m>\d{1,2})\/(?<d>\d{1,2})\/(?<y>\d{4}|\d{2}))'),	-- Should return 0
	dbo.CLR_isRegexMatch('11/1/91','((?<m>\d{1,2})\/(?<d>\d{1,2})\/(?<y>\d{4}|\d{2}))')		-- Should return 1


-- Function 2 - returnRegexMatches
-- should return 6 rows, each letter is a match
SELECT 
	*
FROM dbo.CLR_returnRegexMatches('abcdef','(?<grp>\w{1})')	


-- Should return 3 rows, each date is a match
SELECT
	*
FROM dbo.CLR_returnRegexMatches('11/1/92 2/24/02 7/8/99','(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{2})')



-- Function 3 - returnRegexCaptures (capture group values)
SELECT
	*
FROM dbo.CLR_returnRegexCaptures('My cat hans has a fluffy tail', '[\w ]+')

SELECT
	*
FROM dbo.CLR_returnRegexCaptures('My cat hans has a fluffy tail', '([\w ]+)')

SELECT
	*
FROM dbo.CLR_returnRegexCaptures('My cat hans has a fluffy tail', '(([\w ]+))')

-- Should return a row for each word
SELECT
	*
FROM dbo.CLR_returnRegexCaptures('Hello World, Alex','(?<word>\w{2,})')

-- 9 rows, 3 months, 3 days, 3 years
SELECT 
	*
FROM dbo.CLR_returnRegexCaptures('11/1/92 2/24/02 7/8/1999','(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{2,4})')

-- 12 rows - 3 dates, 3 months, 3 days, 3 years
SELECT 
	*
FROM dbo.CLR_returnRegexCaptures('11/1/92 2/24/02 7/8/1999','(?<date>(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{2,4}))')

-- 11/1/92 2/24/02 7/8/99 12/20/2000 5/6/2007 10/30/79


-- Function 4 - isRegexPattern
SELECT
	dbo.CLR_isRegexPattern('Hello World'),	-- should be true (literal match)
	dbo.CLR_isRegexPattern('\'),			-- should be false
	dbo.CLR_isRegexPattern('[zfjkgkdlfb'),	-- should be false
	dbo.CLR_isRegexPattern('(?<zipCode>(?<sectionalCenter>\d{3})(?<facility>\d{2}))-?(?<plusFour>(?<sector>\d{2})(?<segment>\d{2}))?')


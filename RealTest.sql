--
-- Alex Schmaus 1/19/2023
-- "real world" test for the functions in this repo
--

-- the master DB has the CLR functions that allow for RegEx
USE master
GO

-- A Regular Expression for USA Zip Codes
DECLARE @RegEx varchar(1024) = 
	'^(?<zipCode>(?<sectionalCenter>\d{3})(?<facility>\d{2}))-?(?<plusFour>(?<sector>\d{2})(?<segment>\d{2}))?$'

-- table of data to test & parse
DECLARE @Table table (id int IDENTITY(1,1), zipCode varchar(16))
INSERT INTO @Table (ZipCode)
VALUES 
('811 53'),		('2870-610'),		('21480-1198'),	('MD-4438'),		('33-164'),
('684039'),		('5131'),			('507 10'),		('1174'),			('196851'),
('7090'),		('3798'),			('477027'),		('09-101'),			('64200-000'),
('93120-5422'),	('456209'),			('96-127'),		('9715'),			('58100'),
('391 21'),		('569 92'),			('1156'),		('441 92'),			('8201'),
('658640'),		('527-0087'),		('403467'),		('2715-217'),		('16700-000'),
('59055 CEDEX 1'), ('12570-000'),	('5420'),		('93105'),			('3230'),
('02-158'),		('78732-1123'),		('53225-5133'),	('69630-000'),		('68-130'),
('89280-000'),	('2855-162'),		('8501'),		('40130'),			('73167'),
('992-1202'),	('131 22'),			('4625-347'),	('5020'),			('3060-681'),
('3807'),		('1718'),			('75326 CEDEX 07'), ('L7E'),		('162'),
('93115'),		('28-411'),			('L4P'),		('A86'),			('56215-000'),
('70604'),		('630008'),			('97001'),		('891353365'),			('581205232'),
('58-562'),		('98130-000'),		('742-2807'),	('18013 CEDEX'),	('5419'),
('4274'),		('366319'),			(''),			('353701')


IF dbo.CLR_isRegexPattern(@RegEx) = 1 BEGIN
	
	;WITH cZips AS (
		SELECT
			id,
			ZipCode,
			isValidZipCode = dbo.CLR_isRegexMatch(ZipCode, @RegEx)
		FROM @Table
		)
	SELECT
		Z.id,
		Z.ZipCode AS RawData,
		'=' AS [ ],
		R.sectionalCenter,
		R.ZipCode,
		R.plusFour
	FROM cZips Z
		CROSS APPLY (
			SELECT 
				*
			FROM dbo.CLR_returnRegexCaptures(ZipCode, @RegEx)
			PIVOT (min([value]) FOR [group] IN (zipCode,sectionalCenter,plusFour)) AS pvt  
			) R
	WHERE Z.isValidZipCode = 1
	ORDER BY R.ZipCode, R.plusFour
	
	END
ELSE BEGIN
	;THROW 99999, 'Regex pattern is invalid!!', 0
	END



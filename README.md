# SQLRegEx

The goal of this project is to bring RegEx funcationality into Microsoft SQL Server. The limitations of wildcard matching in Transact SQL have always annoyed me, it just not that useful beyond simple tasks. 

This goal is accomplished by using the Common Language Runtime (CLR). Functions are written in C#, compiled, and then added to SQL where they can be used. 

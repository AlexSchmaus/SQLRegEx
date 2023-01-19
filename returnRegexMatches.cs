//
// Alex Schmaus
// 1/12/2023
//
// Retuns matches
//

using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;
using System.Collections;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction(
        Name = "CLR_returnRegexMatches",
        FillRowMethodName = "FillRow",
        TableDefinition = "index int, value nvarchar(4000)"
        )]
    public static IEnumerable returnRegexMatches(SqlString str, SqlString pattern)
    {
        Regex rx = new Regex((string)pattern);

        // .Matches() returns a collection of match objects -> https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.match?view=net-7.0
        MatchCollection Matches = rx.Matches((string)str);

        return Matches;

    }

    public static void FillRow(Object obj, out SqlInt32 index, out SqlString value)
    {
        Match match = (Match)obj;
        index = (SqlInt32)match.Index;
        value = (SqlString)match.Value;
    }

}

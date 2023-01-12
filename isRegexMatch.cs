//
// Alex Schmaus
// 1/12/2023
//
// Checks a string against a Regular Expression, to see if there is a match
//

using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;


// Reference Material:
// SQL data types to CLR types: https://learn.microsoft.com/en-us/sql/relational-databases/clr-integration-database-objects-types-net-framework/mapping-clr-parameter-data?view=sql-server-ver16
// C# Regex: https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regex?view=net-7.0


// note to self - partial classes can be defined across mult. files
public partial class UserDefinedFunctions
{
    // dictate function's behavior in for SQL
    [Microsoft.SqlServer.Server.SqlFunction(Name = "CLR_isRegexMatch")]
    // Function with two params, str, and pattern. 
    public static SqlBoolean isRegexMatch(SqlString str, SqlString pattern)
    {
        // Create regx object, with the provided pattern. convert the SqlString to a string
        Regex rx = new Regex((string)pattern);
        
        // check to see if its a match!
        if (rx.IsMatch((string)str)) {
            return (SqlBoolean)true;
        }
        else {
            return (SqlBoolean)false;
        }
    }
}

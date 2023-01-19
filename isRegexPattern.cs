//
// Alex Schmaus
// 1/12/2023
//
// Checks a string to see if it is a valid regular expression - not if it is a match, but if it can be used 
//

using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;


public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction(Name = "CLR_isRegexPattern")]
    public static SqlBoolean isRegexPattern(SqlString pattern)
    {

        // so, real simple. if we can instantate a Regex object with the pattern, its valid
        try
        {
            Regex rx = new Regex((string)pattern);
        }
        catch
        {
            return false;
        }

        return true;
        
    }
}

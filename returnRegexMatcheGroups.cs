//
// Alex Schmaus
// 1/13/2023
//
// Retuns matches' capturing groups
//

using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.ObjectModel;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction(
        Name = "CLR_returnRegexMatches",
        FillRowMethodName = "FillRowRRC",
        TableDefinition = "match nvarchar(4000), matchIndex int, group nvarchar(4000), value nvarchar(4000)"
        )]
    public static IEnumerable returnRegexCaptures(SqlString str, SqlString pattern)
    {
        Regex rx = new Regex((string)pattern);

        // .Matches() returns a collection of match objects -> https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.match?view=net-7.0
        MatchCollection Matches = rx.Matches((string)str);
        Collection<MatchData> md = new Collection<MatchData>();

        foreach (Match mch in Matches)
        {
            foreach (Group grp in mch.Groups)
            {
                foreach (Capture cap in grp.Captures)
                {
                    md.Add(new MatchData(mch, grp, cap));
                }

            }
        }

        return md;

    }

    public static void FillRowRRC(Object obj, out SqlString match, out SqlInt32 matchIndex, out SqlString group, out SqlString value)
    {
        MatchData md = (MatchData)obj;
        match = (SqlString)md.match;
        matchIndex = (SqlInt32)md.matchIndex;
        group = (SqlString)md.groupName;
        value = (SqlString)md.capturedValue;
    }

    public class MatchData
    {
        public string match;
        public int matchIndex;
        public string groupName;
        public string capturedValue;

        public MatchData(Match match, Group group, Capture capture)
        {
            this.match = match.Value;
            this.matchIndex = match.Index;
            this.groupName = "x";//group.Name;
            this.capturedValue = capture.Value;
        }
    }


}
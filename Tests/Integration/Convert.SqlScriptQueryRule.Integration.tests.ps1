#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    #region Test Setup
    $stigRulesToTest = @(
        @{
            GetScript    = "SELECT name from sysdatabases where name like 'AdventureWorks%';"
            TestScript   = "SELECT name from sysdatabases where name like 'AdventureWorks%';"
            SetScript    = "DROP DATABASE AdventureWorks;"
            CheckContent = "Check SQL Server for the existence of the publicly available `"AdventureWorks`" database by performing the following query:
            SELECT name from sysdatabases where name like 'AdventureWorks%';
            If the `"AdventureWorks`" database is present, this is a finding."
            FixText      = "Remove the publicly available `"AdventureWorks`" database from SQL Server by running the following query:
            DROP DATABASE AdventureWorks"
        }
        @{
            GetScript    = "BEGIN IF OBJECT_ID('TempDB.dbo.#StigEvent') IS NOT NULL BEGIN DROP TABLE #StigEvent END IF OBJECT_ID('TempDB.dbo.#Trace') IS NOT NULL BEGIN DROP TABLE #Trace END IF OBJECT_ID('TempDB.dbo.#TraceEvent') IS NOT NULL BEGIN DROP TABLE #TraceEvent END CREATE TABLE #StigEvent (EventId INT) CREATE TABLE #Trace (TraceId INT) CREATE TABLE #TraceEvent (TraceId INT, EventId INT) INSERT INTO #StigEvent (EventId) VALUES (14),(15),(18),(20),(102),(103),(104),(105),(106),(107),(108),(109),(110),(111),(112),(113),(115),(116),(117),(118),(128),(129),(130),(131),(132),(133),(134),(135),(152),(153),(170),(171),(172),(173),(175),(176),(177),(178) INSERT INTO #Trace (TraceId) SELECT DISTINCT TraceId FROM sys.fn_trace_getinfo(0) DECLARE cursorTrace CURSOR FOR SELECT TraceId FROM #Trace OPEN cursorTrace DECLARE @traceId INT FETCH NEXT FROM cursorTrace INTO @traceId WHILE @@FETCH_STATUS = 0 BEGIN INSERT INTO #TraceEvent (TraceId, EventId) SELECT DISTINCT @traceId, EventId FROM sys.fn_trace_geteventinfo(@traceId) FETCH NEXT FROM cursorTrace INTO @TraceId END CLOSE cursorTrace DEALLOCATE cursorTrace SELECT * FROM #StigEvent SELECT SE.EventId AS NotFound FROM #StigEvent SE LEFT JOIN #TraceEvent TE ON SE.EventId = TE.EventId WHERE TE.EventId IS NULL END"
            TestScript   = "BEGIN IF OBJECT_ID('TempDB.dbo.#StigEvent') IS NOT NULL BEGIN DROP TABLE #StigEvent END IF OBJECT_ID('TempDB.dbo.#Trace') IS NOT NULL BEGIN DROP TABLE #Trace END IF OBJECT_ID('TempDB.dbo.#TraceEvent') IS NOT NULL BEGIN DROP TABLE #TraceEvent END CREATE TABLE #StigEvent (EventId INT) CREATE TABLE #Trace (TraceId INT) CREATE TABLE #TraceEvent (TraceId INT, EventId INT) INSERT INTO #StigEvent (EventId) VALUES (14),(15),(18),(20),(102),(103),(104),(105),(106),(107),(108),(109),(110),(111),(112),(113),(115),(116),(117),(118),(128),(129),(130),(131),(132),(133),(134),(135),(152),(153),(170),(171),(172),(173),(175),(176),(177),(178) INSERT INTO #Trace (TraceId) SELECT DISTINCT TraceId FROM sys.fn_trace_getinfo(0) DECLARE cursorTrace CURSOR FOR SELECT TraceId FROM #Trace OPEN cursorTrace DECLARE @traceId INT FETCH NEXT FROM cursorTrace INTO @traceId WHILE @@FETCH_STATUS = 0 BEGIN INSERT INTO #TraceEvent (TraceId, EventId) SELECT DISTINCT @traceId, EventId FROM sys.fn_trace_geteventinfo(@traceId) FETCH NEXT FROM cursorTrace INTO @TraceId END CLOSE cursorTrace DEALLOCATE cursorTrace SELECT * FROM #StigEvent SELECT SE.EventId AS NotFound FROM #StigEvent SE LEFT JOIN #TraceEvent TE ON SE.EventId = TE.EventId WHERE TE.EventId IS NULL END"
            SetScript    = "BEGIN IF OBJECT_ID('TempDB.dbo.#StigEvent') IS NOT NULL BEGIN DROP TABLE #StigEvent END IF OBJECT_ID('TempDB.dbo.#Trace') IS NOT NULL BEGIN DROP TABLE #Trace END IF OBJECT_ID('TempDB.dbo.#TraceEvent') IS NOT NULL BEGIN DROP TABLE #TraceEvent END CREATE TABLE #StigEvent (EventId INT) INSERT INTO #StigEvent (EventId) VALUES (14),(15),(18),(20),(102),(103),(104),(105),(106),(107),(108),(109),(110),(111),(112),(113),(115),(116),(117),(118),(128),(129),(130),(131),(132),(133),(134),(135),(152),(153),(170),(171),(172),(173),(175),(176),(177),(178) CREATE TABLE #Trace (TraceId INT) INSERT INTO #Trace (TraceId) SELECT DISTINCT TraceId FROM sys.fn_trace_getinfo(0)ORDER BY TraceId DESC CREATE TABLE #TraceEvent (TraceId INT, EventId INT) DECLARE cursorTrace CURSOR FOR SELECT TraceId FROM #Trace OPEN cursorTrace DECLARE @currentTraceId INT FETCH NEXT FROM cursorTrace INTO @currentTraceId WHILE @@FETCH_STATUS = 0 BEGIN INSERT INTO #TraceEvent (TraceId, EventId) SELECT DISTINCT @currentTraceId, EventId FROM sys.fn_trace_geteventinfo(@currentTraceId) FETCH NEXT FROM cursorTrace INTO @currentTraceId END CLOSE cursorTrace DEALLOCATE cursorTrace DECLARE @missingStigEventCount INT SET @missingStigEventCount = (SELECT COUNT(*) FROM #StigEvent SE LEFT JOIN #TraceEvent TE ON SE.EventId = TE.EventId WHERE TE.EventId IS NULL) IF @missingStigEventCount > 0 BEGIN DECLARE @returnCode INT DECLARE @newTraceId INT DECLARE @maxFileSize BIGINT = 5 EXEC @returnCode = sp_trace_create @traceid = @newTraceId OUTPUT, @options = 2, @tracefile = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Log\PowerStig', @maxfilesize = @maxFileSize, @stoptime = NULL, @filecount = 2; IF @returnCode = 0 BEGIN EXEC sp_trace_setstatus @traceid = @newTraceId, @status = 0 DECLARE cursorMissingStigEvent CURSOR FOR SELECT DISTINCT SE.EventId FROM #StigEvent SE LEFT JOIN #TraceEvent TE ON SE.EventId = TE.EventId WHERE TE.EventId IS NULL OPEN cursorMissingStigEvent DECLARE @currentStigEventId INT FETCH NEXT FROM cursorMissingStigEvent INTO @currentStigEventId WHILE @@FETCH_STATUS = 0 BEGIN EXEC sp_trace_setevent @traceid = @newTraceId, @eventid = @currentStigEventId, @columnid = NULL, @on = 1 FETCH NEXT FROM cursorMissingStigEvent INTO @currentStigEventId END CLOSE cursorMissingStigEvent DEALLOCATE cursorMissingStigEvent EXEC sp_trace_setstatus @traceid = @newTraceId, @status = 1 END END END"
            CheckContent = 'Check to see that all required events are being audited.
            From the query prompt:
            SELECT DISTINCT traceid FROM sys.fn_trace_getinfo(0);
            All currently defined traces for the SQL server instance will be listed. If no traces are returned, this is a finding.
            Determine the trace(s) being used for the auditing requirement.
            In the following, replace # with a trace ID being used for the auditing requirements.
            From the query prompt:
            SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#);
            The following required event IDs should be listed:
            14, 15, 18, 20,
            102, 103, 104, 105, 106, 107, 108, 109, 110,
            111, 112, 113, 115, 116, 117, 118,
            128, 129, 130,
            131, 132, 133, 134, 135,
            152, 153,
            170, 171, 172, 173, 175, 176, 177, 178.
            If any of the audit event IDs required above is not listed, this is a finding.
            Notes:
            1. It is acceptable to have the required event IDs spread across multiple traces, provided all of the traces are always active, and the event IDs are grouped in a logical manner.
            2. It is acceptable, from an auditing point of view, to include the same event IDs in multiple traces.  However, the effect of this redundancy on performance, storage, and the consolidation of audit logs into a central repository, should be taken into account.
            3. It is acceptable to trace additional event IDs. This is the minimum list.
            4. Once this check is satisfied, the DBA may find it useful to disable or modify the default trace that is set up by the SQL Server installation process. (Note that the Fix does NOT include code to do this.)
            Use the following query to obtain a list of all event IDs, and their meaning:
            SELECT * FROM sys.trace_events;
            5. Because this check procedure is designed to address multiple requirements/vulnerabilities, it may appear to exceed the needs of some individual requirements.  However, it does represent the aggregate of all such requirements.
            6. Microsoft has flagged the trace techniques and tools used in this Check and Fix as deprecated.  They will be removed at some point after SQL Server 2014.  The replacement feature is Extended Events.  If Extended Events are in use, and cover all the required audit events listed above, this is not a finding.'
            FixText      = 'This will not be used for this type of rule.'     
        }
        @{
            GetScript    = "SELECT who.name AS [Principal Name], who.type_desc AS [Principal Type], who.is_disabled AS [Principal Is Disabled], what.state_desc AS [Permission State], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE what.permission_name = 'Alter any endpoint' AND    who.name NOT LIKE '##MS%##' AND    who.type_desc &lt;&gt; 'SERVER_ROLE' ORDER BY who.name;"
            TestScript   = "SELECT who.name AS [Principal Name], who.type_desc AS [Principal Type], who.is_disabled AS [Principal Is Disabled], what.state_desc AS [Permission State], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE what.permission_name = 'Alter any endpoint' AND    who.name NOT LIKE '##MS%##' AND    who.type_desc &lt;&gt; 'SERVER_ROLE' ORDER BY who.name;"
            SetScript    = "DECLARE @name as varchar(512) DECLARE @permission as varchar(512) DECLARE @sqlstring1 as varchar(max) SET @sqlstring1 = 'use master;' SET @permission = 'Alter any endpoint' DECLARE  c1 cursor  for  SELECT who.name AS [Principal Name], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE who.name NOT LIKE '##MS%##' AND who.type_desc &lt;&gt; 'SERVER_ROLE' AND who.name &lt;&gt; 'sa'  AND what.permission_name = @permission OPEN c1 FETCH next FROM c1 INTO @name,@permission WHILE (@@FETCH_STATUS = 0) BEGIN SET @sqlstring1 = @sqlstring1 + 'REVOKE ' + @permission + ' FROM [' + @name + '];' FETCH next FROM c1 INTO @name,@permission END CLOSE c1 DEALLOCATE c1 EXEC ( @sqlstring1 );"
            CheckContent = "Obtain the list of accounts that have direct access to the server-level permission 'Alter any endpoint' by running the following query:
            SELECT
            who.name AS [Principal Name],
            who.type_desc AS [Principal Type],
            who.is_disabled AS [Principal Is Disabled],
            what.state_desc AS [Permission State],
            what.permission_name AS [Permission Name]
            FROM
            sys.server_permissions what
            INNER JOIN sys.server_principals who
            ON who.principal_id = what.grantee_principal_id
            WHERE
            what.permission_name = 'Alter any endpoint'
            AND    who.name NOT LIKE '##MS%##'
            AND    who.type_desc &lt;&gt; 'SERVER_ROLE'
            ORDER BY
            who.name
            GO
            If any user accounts have direct access to the 'Alter any endpoint' permission, this is a finding.
            Alternatively, to provide a combined list for all requirements of this type:
            SELECT
            what.permission_name AS [Permission Name],
            what.state_desc AS [Permission State],
            who.name AS [Principal Name],
            who.type_desc AS [Principal Type],
            who.is_disabled AS [Principal Is Disabled]
            FROM
            sys.server_permissions what
            INNER JOIN sys.server_principals who
            ON who.principal_id = what.grantee_principal_id
            WHERE
            what.permission_name IN
            'Administer bulk operations',
            'Alter any availability group',
            'Alter any connection',
            'Alter any credential',
            'Alter any database',
            'Alter any endpoint ',
            'Alter any event notification ',
            'Alter any event session ',
            'Alter any linked server',
            'Alter any login',
            'Alter any server audit',
            'Alter any server role',
            'Alter resources',
            'Alter server state ',
            'Alter Settings ',
            'Alter trace',
            'Authenticate server ',
            'Control server',
            'Create any database ',
            'Create availability group',
            'Create DDL event notification',
            'Create endpoint',
            'Create server role',
            'Create trace event notification',
            'External access assembly',
            'Shutdown',
            'Unsafe Assembly',
            'View any database',
            'View any definition',
            'View server state'
            AND    who.name NOT LIKE '##MS%##'
            AND    who.type_desc &lt;&gt; 'SERVER_ROLE'
            ORDER BY
            what.permission_name,
            who.name
            GO"
            FixText      = "Remove the 'Alter any endpoint' permission access from the account that has direct access by running the following script:
            USE master
            REVOKE ALTER ANY ENDPOINT TO &lt;'account name'&gt;
            GO"
        }
    )
    #endregion
    #region Tests
    Describe 'SqlScriptQuery Rule Conversion' {
        foreach ( $stig in $stigRulesToTest )
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $stig.CheckContent -XccdfTitle 'SQL' -FixText $stig.FixText
            $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return a SqlScriptQueryRule Object' {
                $rule.GetType() | Should Be 'SqlScriptQueryRule'
            }

            It "Should return ConfigSection '$($stig.ConfigSection)'" {
                $rule.ConfigSection | Should Be $stig.ConfigSection
            }

            It 'Should return SqlScriptQueryRule GetScript' {
                if ($rule.GetScript -match "<")
                {
                    $rule.GetScript = $rule.GetScript -replace "<", "&lt;" -replace ">", "&gt;"
                }

                $rule.GetScript | Should Be $stig.GetScript
            }

            It 'Should return SqlScriptQueryRule TestScript' {
                if ($rule.TestScript -match "<") 
                {
                    $rule.TestScript = $rule.TestScript -replace "<", "&lt;" -replace ">", "&gt;"
                }

                $rule.TestScript | Should Be $stig.TestScript
            }

            It 'Should return SqlScriptQueryRule SetScript' {
                if ($rule.SetScript -match "<")
                {
                    $rule.SetScript = $rule.SetScript -replace "<", "&lt;" -replace ">", "&gt;"
                }
                
                $rule.SetScript | Should Be $stig.SetScript
            }

            It 'Should Set the status to pass' {
                $rule.ConversionStatus | Should Be 'pass'
            }
        }
    }
    #endregion
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}

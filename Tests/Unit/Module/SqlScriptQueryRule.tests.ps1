#region Header
using module .\..\..\..\Module\SqlScriptQueryRule\SqlScriptQueryRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $sqlScriptQueryRule = @{
            DbExist    = @{
                GetScript    = "SELECT name from sysdatabases where name like 'AdventureWorks%';"
                TestScript   = "SELECT name from sysdatabases where name like 'AdventureWorks%';"
                SetScript    = "DROP DATABASE AdventureWorks"
                CheckContent = "Check SQL Server for the existence of the publicly available `"AdventureWorks`" database by performing the following query:
                SELECT name from sysdatabases where name like 'AdventureWorks%';
                If the `"AdventureWorks`" database is present, this is a finding."
                FixText      = "Remove the publicly available `"AdventureWorks`" database from SQL Server by running the following query:
                DROP DATABASE AdventureWorks"
            }
            Trace      = @{
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
                2. It is acceptable, from an auditing point of view, to include the same event IDs in multiple traces.  However, the effect of this redundancy on performance, storage, and the consolidation `
                of audit logs into a central repository, should be taken into account.
                3. It is acceptable to trace additional event IDs. This is the minimum list.
                4. Once this check is satisfied, the DBA may find it useful to disable or modify the default trace that is set up by the SQL Server installation process. (Note that the Fix does NOT include `
                code to do this.)
                Use the following query to obtain a list of all event IDs, and their meaning:
                SELECT * FROM sys.trace_events;
                5. Because this check procedure is designed to address multiple requirements/vulnerabilities, it may appear to exceed the needs of some individual requirements.  However, it does represent `
                the aggregate of all such requirements.
                6. Microsoft has flagged the trace techniques and tools used in this Check and Fix as deprecated.  They will be removed at some point after SQL Server 2014.  The replacement feature is `
                Extended Events.  If Extended Events are in use, and cover all the required audit events listed above, this is not a finding.'
                FixText      = 'This will not be used for this type of rule.'
                EventId      = '(14),(15),(18),(20),(102),(103),(104),(105),(106),(107),(108),(109),(110),(111),(112),(113),(115),(116),(117),(118),(128),(129),(130),(131),(132),(133),(134),(135),(152),`
                (153),(170),(171),(172),(173),(175),(176),(177),(178)'
            }
            Permission = @{
                GetScript    = "SELECT who.name AS [Principal Name], who.type_desc AS [Principal Type], who.is_disabled AS [Principal Is Disabled], what.state_desc AS [Permission State], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE what.permission_name = 'Alter any endpoint' AND    who.name NOT LIKE '##MS%##' AND    who.type_desc <> 'SERVER_ROLE' ORDER BY who.name;"
                TestScript   = "SELECT who.name AS [Principal Name], who.type_desc AS [Principal Type], who.is_disabled AS [Principal Is Disabled], what.state_desc AS [Permission State], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE what.permission_name = 'Alter any endpoint' AND    who.name NOT LIKE '##MS%##' AND    who.type_desc <> 'SERVER_ROLE' ORDER BY who.name;"
                SetScript    = "DECLARE @name as varchar(512) DECLARE @permission as varchar(512) DECLARE @sqlstring1 as varchar(max) SET @sqlstring1 = 'use master;' SET @permission = 'Alter any endpoint' DECLARE  c1 cursor  for  SELECT who.name AS [Principal Name], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE who.name NOT LIKE '##MS%##' AND who.type_desc <> 'SERVER_ROLE' AND who.name <> 'sa' AND what.permission_name = @permission OPEN c1 FETCH next FROM c1 INTO @name,@permission WHILE (@@FETCH_STATUS = 0) BEGIN SET @sqlstring1 = @sqlstring1 + 'REVOKE ' + @permission + ' FROM [' + @name + '];' FETCH next FROM c1 INTO @name,@permission END CLOSE c1 DEALLOCATE c1 EXEC ( @sqlstring1 );"
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
                AND    who.type_desc <> 'SERVER_ROLE'
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
                AND    who.type_desc <> 'SERVER_ROLE'
                ORDER BY
                what.permission_name,
                who.name
                GO"
                FixText      = "Remove the 'Alter any endpoint' permission access from the account that has direct access by running the following script:
                USE master
                REVOKE ALTER ANY ENDPOINT TO <'account name'>
                GO"
            }
            saAccount    = @{
                GetScript    = "USE [master] SELECT name, is_disabled FROM sys.sql_logins WHERE principal_id = 1 AND name = 'sa' AND is_disabled <> 1;"
                TestScript   = "USE [master] SELECT name, is_disabled FROM sys.sql_logins WHERE principal_id = 1 AND name = 'sa' AND is_disabled <> 1;"
                SetScript    = 'USE [master] DECLARE @saAccountName varchar(50) SET @saAccountName = (SELECT name FROM sys.sql_logins WHERE principal_id = 1) IF @saAccountName = ''sa'' ALTER LOGIN [sa] WITH NAME = [old_sa] SET @saAccountName = ''old_sa'' DECLARE @saDisabled int SET @saDisabled = (SELECT is_disabled FROM sys.sql_logins WHERE principal_id = 1) IF @saDisabled <> 1 ALTER LOGIN [@saAccountName] DISABLE;'
                CheckContent = "Check SQL Server settings to determine if the [sa] (system administrator) account has been disabled by executing the following query:
                USE master; 
                GO 
                SELECT name, is_disabled 
                FROM sys.sql_logins 
                WHERE principal_id = 1; GO 
                Verify that the `"name`" column contains the current name of the [sa] database server account (see note)."
                FixText      = "Modify the SQL Server's [sa] (system administrator) account by running the following script:
                USE master; 
                GO
                ALTER LOGIN [sa] WITH NAME = <new name> GO"
            }
            Audit = @{
                GetScript    = "USE [master] DECLARE @MissingAuditCount INTEGER DECLARE @server_specification_id INTEGER DECLARE @FoundCompliant INTEGER SET @FoundCompliant = 0 /* Create a table for the events that we are looking for */ CREATE TABLE #AuditEvents (AuditEvent varchar(100)) INSERT INTO #AuditEvents (AuditEvent) VALUES (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP),(DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),(DATABASE_OWNERSHIP_CHANGE_GROUP) /* Create a cursor to walk through all audits that are enabled at startup */ DECLARE auditspec_cursor CURSOR FOR SELECT s.server_specification_id FROM sys.server_audits a INNER JOIN sys.server_audit_specifications s ON a.audit_guid = s.audit_guid WHERE a.is_state_enabled = 1; OPEN auditspec_cursor FETCH NEXT FROM auditspec_cursor INTO @server_specification_id WHILE @@FETCH_STATUS = 0 AND @FoundCompliant = 0 /* Does this specification have the needed events in it? */ BEGIN SET @MissingAuditCount = (SELECT Count(a.AuditEvent) AS MissingAuditCount FROM #AuditEvents a JOIN sys.server_audit_specification_details d ON a.AuditEvent = d.audit_action_name WHERE d.audit_action_name NOT IN (SELECT d2.audit_action_name FROM sys.server_audit_specification_details d2 WHERE d2.server_specification_id = @server_specification_id)) IF @MissingAuditCount = 0 SET @FoundCompliant = 1; FETCH NEXT FROM auditspec_cursor INTO @server_specification_id END CLOSE auditspec_cursor; DEALLOCATE auditspec_cursor; DROP TABLE #AuditEvents /* Produce output that works with DSC - records if we do not find the audit events we are looking for */ IF @FoundCompliant > 0 SELECT name FROM sys.sql_logins WHERE principal_id = -1; ELSE SELECT name FROM sys.sql_logins WHERE principal_id = 1"
                TestScript    = "USE [master] DECLARE @MissingAuditCount INTEGER DECLARE @server_specification_id INTEGER DECLARE @FoundCompliant INTEGER SET @FoundCompliant = 0 /* Create a table for the events that we are looking for */ CREATE TABLE #AuditEvents (AuditEvent varchar(100)) INSERT INTO #AuditEvents (AuditEvent) VALUES (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP),(DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),(DATABASE_OWNERSHIP_CHANGE_GROUP) /* Create a cursor to walk through all audits that are enabled at startup */ DECLARE auditspec_cursor CURSOR FOR SELECT s.server_specification_id FROM sys.server_audits a INNER JOIN sys.server_audit_specifications s ON a.audit_guid = s.audit_guid WHERE a.is_state_enabled = 1; OPEN auditspec_cursor FETCH NEXT FROM auditspec_cursor INTO @server_specification_id WHILE @@FETCH_STATUS = 0 AND @FoundCompliant = 0 /* Does this specification have the needed events in it? */ BEGIN SET @MissingAuditCount = (SELECT Count(a.AuditEvent) AS MissingAuditCount FROM #AuditEvents a JOIN sys.server_audit_specification_details d ON a.AuditEvent = d.audit_action_name WHERE d.audit_action_name NOT IN (SELECT d2.audit_action_name FROM sys.server_audit_specification_details d2 WHERE d2.server_specification_id = @server_specification_id)) IF @MissingAuditCount = 0 SET @FoundCompliant = 1; FETCH NEXT FROM auditspec_cursor INTO @server_specification_id END CLOSE auditspec_cursor; DEALLOCATE auditspec_cursor; DROP TABLE #AuditEvents /* Produce output that works with DSC - records if we do not find the audit events we are looking for */ IF @FoundCompliant > 0 SELECT name FROM sys.sql_logins WHERE principal_id = -1; ELSE SELECT name FROM sys.sql_logins WHERE principal_id = 1"
                SetScript    = '/* See STIG supplemental files for the annotated version of this script */ USE [master] IF EXISTS (SELECT 1 FROM sys.server_audit_specifications WHERE name = ''STIG_AUDIT_SERVER_SPECIFICATION'') ALTER SERVER AUDIT SPECIFICATION STIG_AUDIT_SERVER_SPECIFICATION WITH (STATE = OFF); IF EXISTS (SELECT 1 FROM sys.server_audit_specifications WHERE name = ''STIG_AUDIT_SERVER_SPECIFICATION'') DROP SERVER AUDIT SPECIFICATION STIG_AUDIT_SERVER_SPECIFICATION; IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = ''STIG_AUDIT'') ALTER SERVER AUDIT STIG_AUDIT WITH (STATE = OFF); IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = ''STIG_AUDIT'') DROP SERVER AUDIT STIG_AUDIT; CREATE SERVER AUDIT STIG_AUDIT TO FILE (FILEPATH = ''C:\Audits'', MAXSIZE = 200MB, MAX_ROLLOVER_FILES = 50, RESERVE_DISK_SPACE = OFF) WITH (QUEUE_DELAY = 1000, ON_FAILURE = SHUTDOWN) IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = ''STIG_AUDIT'') ALTER SERVER AUDIT STIG_AUDIT WITH (STATE = ON); CREATE SERVER AUDIT SPECIFICATION STIG_AUDIT_SERVER_SPECIFICATION FOR SERVER AUDIT STIG_AUDIT ADD (APPLICATION_ROLE_CHANGE_PASSWORD_GROUP), ADD (AUDIT_CHANGE_GROUP), ADD (BACKUP_RESTORE_GROUP), ADD (DATABASE_CHANGE_GROUP), ADD (DATABASE_OBJECT_CHANGE_GROUP), ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP), ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP), ADD (DATABASE_OPERATION_GROUP), ADD (DATABASE_OWNERSHIP_CHANGE_GROUP), ADD (DATABASE_PERMISSION_CHANGE_GROUP), ADD (DATABASE_PRINCIPAL_CHANGE_GROUP), ADD (DATABASE_PRINCIPAL_IMPERSONATION_GROUP), ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP), ADD (DBCC_GROUP), ADD (FAILED_LOGIN_GROUP), ADD (LOGIN_CHANGE_PASSWORD_GROUP), ADD (LOGOUT_GROUP), ADD (SCHEMA_OBJECT_CHANGE_GROUP), ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP), ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP), ADD (SERVER_OBJECT_CHANGE_GROUP), ADD (SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP), ADD (SERVER_OBJECT_PERMISSION_CHANGE_GROUP), ADD (SERVER_OPERATION_GROUP), ADD (SERVER_PERMISSION_CHANGE_GROUP), ADD (SERVER_PRINCIPAL_CHANGE_GROUP), ADD (SERVER_PRINCIPAL_IMPERSONATION_GROUP), ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP), ADD (SERVER_STATE_CHANGE_GROUP), ADD (SUCCESSFUL_LOGIN_GROUP), ADD (TRACE_CHANGE_GROUP) WITH (STATE = ON); GO '
                CheckContent = "If the following events are not included, this is a finding. 
                DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP DATABASE_OBJECT_PERMISSION_CHANGE_GROUP 
                DATABASE_OWNERSHIP_CHANGE_GROUP"
                FixText      = "Fix Text: Add the following events to the SQL Server Audit that is being used for the STIG compliant audit. 
                DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP DATABASE_OBJECT_PERMISSION_CHANGE_GROUP 
                DATABASE_OWNERSHIP_CHANGE_GROUP
                See the supplemental file `"SQL 2016 Audit.sql`". "
            }
            PlainSQL    = @{
                GetScript    = "SELECT * FROM MSysObjects WHERE 1=1;"
                TestScript   = "SELECT * FROM MSysObjects WHERE 1=1;"
                SetScript    = "DROP DATABASE AdventureWorks"
                CheckContent = "This rule performs a check of records in a database by performing the following query:
                SELECT * FROM MSysObjects WHERE 1=1;
                If records are present, this is a finding."
                FixText      = "Remove the publicly available `"AdventureWorks`" database from SQL Server by running the following query:
                DROP DATABASE AdventureWorks"
            }
        }
        $testStigRuleParam = @{
            CheckContent    = $sqlScriptQueryRule.DbExist.CheckContent
            FixText         = $sqlScriptQueryRule.DbExist.FixText
            ReturnGroupOnly = $true
        }
        $stigRule = Get-TestStigRule @testStigRuleParam
        $rule = [SqlScriptQueryRule]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'Rule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @("GetScript", "TestScript", "SetScript")

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Method Function Tests' {
            foreach ( $rule in $sqlScriptQueryRule.Keys )
            {
                $ruleType = Get-SqlRuleType -CheckContent ($sqlScriptQueryRule.$($rule).CheckContent)
                $checkContent = Format-RuleText -RuleText $sqlScriptQueryRule.$($ruleType).CheckContent
                $fixText = Format-RuleText -RuleText $sqlScriptQueryRule.$($ruleType).FixText

                Context "'$ruleType' Get-SqlRuleType" {
                    It "Should return $($rule)" {
                        $ruleType | Should Be $rule
                    }
                }

                Context "'$ruleType' GetScript" {
                    $getScript = $sqlScriptQueryRule.$($ruleType).GetScript
                    It "Should return a $($ruleType) GetScript" {
                        $result = & Get-$($ruleType)GetScript -CheckContent $checkContent
                        $result | Should be $getScript
                    }
                }

                Context "'$ruleType' TestScript" {
                    $testScript = $sqlScriptQueryRule.$($ruleType).TestScript

                    It "Should return a $($ruleType) TestScript" {
                        $result = & Get-$($ruleType)TestScript -CheckContent $checkContent
                        $result | Should be $testScript
                    }
                }

                Context "'$ruleType' SetScript" {
                    $setScript = $sqlScriptQueryRule.$($ruleType).SetScript

                    It "Should return a $($ruleType) SetScript" {
                        $checkContent = Split-TestStrings -CheckContent $sqlScriptQueryRule.$($ruleType).CheckContent
                        $result = & Get-$($ruleType)SetScript -FixText $fixText -CheckContent $checkContent
                        $result | Should be $setScript
                    }
                }
            }

            Context 'Get-Query' {
                $checkContent = Format-RuleText -RuleText $sqlScriptQueryRule.Trace.CheckContent

                $query = Get-Query -CheckContent $checkContent

                It 'Should return 3 queries' {
                    $query.Count | Should be 3
                }
            }

            Context 'Get-SQLQuery' {
                $checkContent = Format-RuleText -RuleText $sqlScriptQueryRule.Trace.CheckContent

                $query = Get-SQLQuery -CheckContent $checkContent

                It 'Should return 3 queries' {
                    $query.Count | Should be 3
                }
            }

            Context 'SQL Trace Rule functions' {
                $checkContent = Format-RuleText -RuleText $sqlScriptQueryRule.Trace.CheckContent

                $traceSetScript = $sqlScriptQueryRule.Trace.TestScript -split ";"

                $eventId = Get-EventIdData -CheckContent $checkContent
                $traceIdQuery = Get-TraceIdQuery -EventId $eventId

                It 'Should return Trace Id Query' {
                    $traceIdQuery | Should be ($traceSetScript[0])
                }

                $eventId = Get-EventIdData -CheckContent $checkContent
                It 'Should return Event Id Data' {
                    $eventId | Should be $sqlScriptQueryRule.Trace.EventId
                }
            }
        }
        #endregion
        #region Data Tests

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}

#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    <#{TODO}#> <#There are no class tests in here#>
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $sqlScriptQueryRule = @{
            Trace = @{
                GetScript = "BEGIN IF OBJECT_ID('TempDB.dbo.#StigEvent') IS NOT NULL BEGIN DROP TABLE #StigEvent END IF OBJECT_ID('TempDB.dbo.#Trace') IS NOT NULL BEGIN DROP TABLE #Trace END IF OBJECT_ID('TempDB.dbo.#TraceEvent') IS NOT NULL BEGIN DROP TABLE #TraceEvent END CREATE TABLE #StigEvent (EventId INT) CREATE TABLE #Trace (TraceId INT) CREATE TABLE #TraceEvent (TraceId INT, EventId INT) INSERT INTO #StigEvent (EventId) VALUES (14),(15),(18),(20),(102),(103),(104),(105),(106),(107),(108),(109),(110),(111),(112),(113),(115),(116),(117),(118),(128),(129),(130),(131),(132),(133),(134),(135),(152),(153),(170),(171),(172),(173),(175),(176),(177),(178) INSERT INTO #Trace (TraceId) SELECT DISTINCT TraceId FROM sys.fn_trace_getinfo(0) DECLARE cursorTrace CURSOR FOR SELECT TraceId FROM #Trace OPEN cursorTrace DECLARE @traceId INT FETCH NEXT FROM cursorTrace INTO @traceId WHILE @@FETCH_STATUS = 0 BEGIN INSERT INTO #TraceEvent (TraceId, EventId) SELECT DISTINCT @traceId, EventId FROM sys.fn_trace_geteventinfo(@traceId) FETCH NEXT FROM cursorTrace INTO @TraceId END CLOSE cursorTrace DEALLOCATE cursorTrace SELECT * FROM #StigEvent SELECT SE.EventId AS NotFound FROM #StigEvent SE LEFT JOIN #TraceEvent TE ON SE.EventId = TE.EventId WHERE TE.EventId IS NULL END"
                TestScript = "BEGIN IF OBJECT_ID('TempDB.dbo.#StigEvent') IS NOT NULL BEGIN DROP TABLE #StigEvent END IF OBJECT_ID('TempDB.dbo.#Trace') IS NOT NULL BEGIN DROP TABLE #Trace END IF OBJECT_ID('TempDB.dbo.#TraceEvent') IS NOT NULL BEGIN DROP TABLE #TraceEvent END CREATE TABLE #StigEvent (EventId INT) CREATE TABLE #Trace (TraceId INT) CREATE TABLE #TraceEvent (TraceId INT, EventId INT) INSERT INTO #StigEvent (EventId) VALUES (14),(15),(18),(20),(102),(103),(104),(105),(106),(107),(108),(109),(110),(111),(112),(113),(115),(116),(117),(118),(128),(129),(130),(131),(132),(133),(134),(135),(152),(153),(170),(171),(172),(173),(175),(176),(177),(178) INSERT INTO #Trace (TraceId) SELECT DISTINCT TraceId FROM sys.fn_trace_getinfo(0) DECLARE cursorTrace CURSOR FOR SELECT TraceId FROM #Trace OPEN cursorTrace DECLARE @traceId INT FETCH NEXT FROM cursorTrace INTO @traceId WHILE @@FETCH_STATUS = 0 BEGIN INSERT INTO #TraceEvent (TraceId, EventId) SELECT DISTINCT @traceId, EventId FROM sys.fn_trace_geteventinfo(@traceId) FETCH NEXT FROM cursorTrace INTO @TraceId END CLOSE cursorTrace DEALLOCATE cursorTrace SELECT SE.EventId AS NotFound FROM #StigEvent SE LEFT JOIN #TraceEvent TE ON SE.EventId = TE.EventId WHERE TE.EventId IS NULL END"
                SetScript = "BEGIN IF OBJECT_ID('TempDB.dbo.#StigEvent') IS NOT NULL BEGIN DROP TABLE #StigEvent END IF OBJECT_ID('TempDB.dbo.#Trace') IS NOT NULL BEGIN DROP TABLE #Trace END IF OBJECT_ID('TempDB.dbo.#TraceEvent') IS NOT NULL BEGIN DROP TABLE #TraceEvent END CREATE TABLE #StigEvent (EventId INT) INSERT INTO #StigEvent (EventId) VALUES (14),(15),(18),(20),(102),(103),(104),(105),(106),(107),(108),(109),(110),(111),(112),(113),(115),(116),(117),(118),(128),(129),(130),(131),(132),(133),(134),(135),(152),(153),(170),(171),(172),(173),(175),(176),(177),(178) CREATE TABLE #Trace (TraceId INT) INSERT INTO #Trace (TraceId) SELECT DISTINCT TraceId FROM sys.fn_trace_getinfo(0)ORDER BY TraceId DESC CREATE TABLE #TraceEvent (TraceId INT, EventId INT) DECLARE cursorTrace CURSOR FOR SELECT TraceId FROM #Trace OPEN cursorTrace DECLARE @currentTraceId INT FETCH NEXT FROM cursorTrace INTO @currentTraceId WHILE @@FETCH_STATUS = 0 BEGIN INSERT INTO #TraceEvent (TraceId, EventId) SELECT DISTINCT @currentTraceId, EventId FROM sys.fn_trace_geteventinfo(@currentTraceId) FETCH NEXT FROM cursorTrace INTO @currentTraceId END CLOSE cursorTrace DEALLOCATE cursorTrace DECLARE @missingStigEventCount INT SET @missingStigEventCount = (SELECT COUNT(*) FROM #StigEvent SE LEFT JOIN #TraceEvent TE ON SE.EventId = TE.EventId WHERE TE.EventId IS NULL) IF @missingStigEventCount > 0 BEGIN DECLARE @dir nvarchar(4000) DECLARE @tracefile nvarchar(4000) DECLARE @returnCode INT DECLARE @newTraceId INT DECLARE @maxFileSize BIGINT = 5 EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\Setup', N'SQLPath', @dir OUTPUT, 'no_output' SET @tracefile = @dir + N'\Log\PowerStig' EXEC @returnCode = sp_trace_create @traceid = @newTraceId OUTPUT, @options = 2, @tracefile = @tracefile, @maxfilesize = @maxFileSize, @stoptime = NULL, @filecount = 2; IF @returnCode = 0 BEGIN EXEC sp_trace_setstatus @traceid = @newTraceId, @status = 0 DECLARE cursorMissingStigEvent CURSOR FOR SELECT DISTINCT SE.EventId FROM #StigEvent SE LEFT JOIN #TraceEvent TE ON SE.EventId = TE.EventId WHERE TE.EventId IS NULL OPEN cursorMissingStigEvent DECLARE @currentStigEventId INT FETCH NEXT FROM cursorMissingStigEvent INTO @currentStigEventId WHILE @@FETCH_STATUS = 0 BEGIN EXEC sp_trace_setevent @traceid = @newTraceId, @eventid = @currentStigEventId, @columnid = NULL, @on = 1 FETCH NEXT FROM cursorMissingStigEvent INTO @currentStigEventId END CLOSE cursorMissingStigEvent DEALLOCATE cursorMissingStigEvent EXEC sp_trace_setstatus @traceid = @newTraceId, @status = 1 END END END"
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
                FixText = 'This will not be used for this type of rule.'
                EventId = '(14),(15),(18),(20),(102),(103),(104),(105),(106),(107),(108),(109),(110),(111),(112),(113),(115),(116),(117),(118),(128),(129),(130),(131),(132),(133),(134),(135),(152),(153),(170),(171),(172),(173),(175),(176),(177),(178)'
            }
            Permission = @{
                GetScript = "SELECT who.name AS [Principal Name], who.type_desc AS [Principal Type], who.is_disabled AS [Principal Is Disabled], what.state_desc AS [Permission State], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE what.permission_name = 'Alter any endpoint' AND    who.name NOT LIKE '##MS%##' AND    who.type_desc <> 'SERVER_ROLE' ORDER BY who.name;"
                TestScript = "SELECT who.name AS [Principal Name], who.type_desc AS [Principal Type], who.is_disabled AS [Principal Is Disabled], what.state_desc AS [Permission State], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE what.permission_name = 'Alter any endpoint' AND    who.name NOT LIKE '##MS%##' AND    who.type_desc <> 'SERVER_ROLE' ORDER BY who.name;"
                SetScript = "DECLARE @name as varchar(512) DECLARE @permission as varchar(512) DECLARE @sqlstring1 as varchar(max) SET @sqlstring1 = 'use master;' SET @permission = 'Alter any endpoint' DECLARE  c1 cursor  for  SELECT who.name AS [Principal Name], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE who.name NOT LIKE '##MS%##' AND who.type_desc <> 'SERVER_ROLE' AND who.name <> 'sa'  AND what.permission_name = @permission OPEN c1 FETCH next FROM c1 INTO @name,@permission WHILE (@@FETCH_STATUS = 0) BEGIN SET @sqlstring1 = @sqlstring1 + 'REVOKE ' + @permission + ' FROM [' + @name + '];' FETCH next FROM c1 INTO @name,@permission END CLOSE c1 DEALLOCATE c1 EXEC ( @sqlstring1 );"
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
                FixText = "Remove the 'Alter any endpoint' permission access from the account that has direct access by running the following script:
                USE master
                REVOKE ALTER ANY ENDPOINT TO <'account name'>
                GO"
            }
            SysAdminAccount = @{
                GetScript = "USE [master] SELECT name, is_disabled FROM sys.sql_logins WHERE principal_id = 1 AND is_disabled <> 1;"
                TestScript = "USE [master] SELECT name, is_disabled FROM sys.sql_logins WHERE principal_id = 1 AND is_disabled <> 1;"
                SetScript = "USE [master] DECLARE @SysAdminAccountName varchar(50), @cmd NVARCHAR(100), @saDisabled int SET @SysAdminAccountName = (SELECT name FROM sys.sql_logins WHERE principal_id = 1) SELECT @cmd = N'ALTER LOGIN ['+@SysAdminAccountName+'] DISABLE;' SET @saDisabled = (SELECT is_disabled FROM sys.sql_logins WHERE principal_id = 1) IF @saDisabled <> 1 exec sp_executeSQL @cmd;"
                CheckContent = "Check SQL Server settings to determine if the [sa] (system administrator) account has been disabled by executing the following query:
                USE master;
                GO
                SELECT name, is_disabled
                FROM sys.sql_logins
                WHERE principal_id = 1; GO
                Verify that the `"name`" column contains the current name of the [sa] database server account (see note)."
                FixText = "Modify the SQL Server's [sa] (system administrator) account by running the following script:
                USE master;
                GO
                ALTER LOGIN [sa] WITH NAME = <new name> GO"
            }
            Audit = @{
                GetScript = "USE [master] DECLARE @MissingAuditCount INTEGER DECLARE @server_specification_id INTEGER DECLARE @FoundCompliant INTEGER SET @FoundCompliant = 0 /* Create a table for the events that we are looking for */ CREATE TABLE #AuditEvents (AuditEvent varchar(100)) INSERT INTO #AuditEvents (AuditEvent) VALUES ('APPLICATION_ROLE_CHANGE_PASSWORD_GROUP'),('AUDIT_CHANGE_GROUP'),('BACKUP_RESTORE_GROUP'),('DATABASE_CHANGE_GROUP'),('DATABASE_OBJECT_ACCESS_GROUP'),('DATABASE_OBJECT_CHANGE_GROUP'),('DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP'),('DATABASE_OBJECT_PERMISSION_CHANGE_GROUP'),('DATABASE_OWNERSHIP_CHANGE_GROUP'),('DATABASE_OPERATION_GROUP'),('DATABASE_PERMISSION_CHANGE_GROUP'),('DATABASE_PRINCIPAL_CHANGE_GROUP'),('DATABASE_PRINCIPAL_IMPERSONATION_GROUP'),('DATABASE_ROLE_MEMBER_CHANGE_GROUP'),('DBCC_GROUP'),('LOGIN_CHANGE_PASSWORD_GROUP'),('SCHEMA_OBJECT_CHANGE_GROUP'),('SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP'),('SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP'),('SERVER_OBJECT_CHANGE_GROUP'),('SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP'),('SERVER_OBJECT_PERMISSION_CHANGE_GROUP'),('SERVER_OPERATION_GROUP'),('SERVER_PERMISSION_CHANGE_GROUP'),('SERVER_PRINCIPAL_IMPERSONATION_GROUP'),('SERVER_ROLE_MEMBER_CHANGE_GROUP'),('SERVER_STATE_CHANGE_GROUP'),('TRACE_CHANGE_GROUP') /* Create a cursor to walk through all audits that are enabled at startup */ DECLARE auditspec_cursor CURSOR FOR SELECT s.server_specification_id FROM sys.server_audits a INNER JOIN sys.server_audit_specifications s ON a.audit_guid = s.audit_guid WHERE a.is_state_enabled = 1; OPEN auditspec_cursor FETCH NEXT FROM auditspec_cursor INTO @server_specification_id WHILE @@FETCH_STATUS = 0 AND @FoundCompliant = 0 /* Does this specification have the needed events in it? */ BEGIN SET @MissingAuditCount = (SELECT Count(a.AuditEvent) AS MissingAuditCount FROM #AuditEvents a JOIN sys.server_audit_specification_details d ON a.AuditEvent = d.audit_action_name WHERE d.audit_action_name NOT IN (SELECT d2.audit_action_name FROM sys.server_audit_specification_details d2 WHERE d2.server_specification_id = @server_specification_id)) IF @MissingAuditCount = 0 SET @FoundCompliant = 1; FETCH NEXT FROM auditspec_cursor INTO @server_specification_id END CLOSE auditspec_cursor; DEALLOCATE auditspec_cursor; DROP TABLE #AuditEvents /* Produce output that works with DSC - records if we do not find the audit events we are looking for */ IF @FoundCompliant > 0 SELECT name FROM sys.sql_logins WHERE principal_id = -1; ELSE SELECT name FROM sys.sql_logins WHERE principal_id = 1"
                TestScript = "USE [master] DECLARE @MissingAuditCount INTEGER DECLARE @server_specification_id INTEGER DECLARE @FoundCompliant INTEGER SET @FoundCompliant = 0 /* Create a table for the events that we are looking for */ CREATE TABLE #AuditEvents (AuditEvent varchar(100)) INSERT INTO #AuditEvents (AuditEvent) VALUES ('APPLICATION_ROLE_CHANGE_PASSWORD_GROUP'),('AUDIT_CHANGE_GROUP'),('BACKUP_RESTORE_GROUP'),('DATABASE_CHANGE_GROUP'),('DATABASE_OBJECT_ACCESS_GROUP'),('DATABASE_OBJECT_CHANGE_GROUP'),('DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP'),('DATABASE_OBJECT_PERMISSION_CHANGE_GROUP'),('DATABASE_OWNERSHIP_CHANGE_GROUP'),('DATABASE_OPERATION_GROUP'),('DATABASE_PERMISSION_CHANGE_GROUP'),('DATABASE_PRINCIPAL_CHANGE_GROUP'),('DATABASE_PRINCIPAL_IMPERSONATION_GROUP'),('DATABASE_ROLE_MEMBER_CHANGE_GROUP'),('DBCC_GROUP'),('LOGIN_CHANGE_PASSWORD_GROUP'),('SCHEMA_OBJECT_CHANGE_GROUP'),('SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP'),('SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP'),('SERVER_OBJECT_CHANGE_GROUP'),('SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP'),('SERVER_OBJECT_PERMISSION_CHANGE_GROUP'),('SERVER_OPERATION_GROUP'),('SERVER_PERMISSION_CHANGE_GROUP'),('SERVER_PRINCIPAL_IMPERSONATION_GROUP'),('SERVER_ROLE_MEMBER_CHANGE_GROUP'),('SERVER_STATE_CHANGE_GROUP'),('TRACE_CHANGE_GROUP') /* Create a cursor to walk through all audits that are enabled at startup */ DECLARE auditspec_cursor CURSOR FOR SELECT s.server_specification_id FROM sys.server_audits a INNER JOIN sys.server_audit_specifications s ON a.audit_guid = s.audit_guid WHERE a.is_state_enabled = 1; OPEN auditspec_cursor FETCH NEXT FROM auditspec_cursor INTO @server_specification_id WHILE @@FETCH_STATUS = 0 AND @FoundCompliant = 0 /* Does this specification have the needed events in it? */ BEGIN SET @MissingAuditCount = (SELECT Count(a.AuditEvent) AS MissingAuditCount FROM #AuditEvents a JOIN sys.server_audit_specification_details d ON a.AuditEvent = d.audit_action_name WHERE d.audit_action_name NOT IN (SELECT d2.audit_action_name FROM sys.server_audit_specification_details d2 WHERE d2.server_specification_id = @server_specification_id)) IF @MissingAuditCount = 0 SET @FoundCompliant = 1; FETCH NEXT FROM auditspec_cursor INTO @server_specification_id END CLOSE auditspec_cursor; DEALLOCATE auditspec_cursor; DROP TABLE #AuditEvents /* Produce output that works with DSC - records if we do not find the audit events we are looking for */ IF @FoundCompliant > 0 SELECT name FROM sys.sql_logins WHERE principal_id = -1; ELSE SELECT name FROM sys.sql_logins WHERE principal_id = 1"
                SetScript = '/* See STIG supplemental files for the annotated version of this script */ USE [master] IF EXISTS (SELECT 1 FROM sys.server_audit_specifications WHERE name = ''STIG_AUDIT_SERVER_SPECIFICATION'') ALTER SERVER AUDIT SPECIFICATION STIG_AUDIT_SERVER_SPECIFICATION WITH (STATE = OFF); IF EXISTS (SELECT 1 FROM sys.server_audit_specifications WHERE name = ''STIG_AUDIT_SERVER_SPECIFICATION'') DROP SERVER AUDIT SPECIFICATION STIG_AUDIT_SERVER_SPECIFICATION; IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = ''STIG_AUDIT'') ALTER SERVER AUDIT STIG_AUDIT WITH (STATE = OFF); IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = ''STIG_AUDIT'') DROP SERVER AUDIT STIG_AUDIT; CREATE SERVER AUDIT STIG_AUDIT TO FILE (FILEPATH = ''C:\Audits'', MAXSIZE = 200MB, MAX_ROLLOVER_FILES = 50, RESERVE_DISK_SPACE = OFF) WITH (QUEUE_DELAY = 1000, ON_FAILURE = SHUTDOWN) IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = ''STIG_AUDIT'') ALTER SERVER AUDIT STIG_AUDIT WITH (STATE = ON); CREATE SERVER AUDIT SPECIFICATION STIG_AUDIT_SERVER_SPECIFICATION FOR SERVER AUDIT STIG_AUDIT ADD (APPLICATION_ROLE_CHANGE_PASSWORD_GROUP), ADD (AUDIT_CHANGE_GROUP), ADD (BACKUP_RESTORE_GROUP), ADD (DATABASE_CHANGE_GROUP), ADD (DATABASE_OBJECT_CHANGE_GROUP), ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP), ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP), ADD (DATABASE_OPERATION_GROUP), ADD (DATABASE_OBJECT_ACCESS_GROUP), ADD (DATABASE_OWNERSHIP_CHANGE_GROUP), ADD (DATABASE_PERMISSION_CHANGE_GROUP), ADD (DATABASE_PRINCIPAL_CHANGE_GROUP), ADD (DATABASE_PRINCIPAL_IMPERSONATION_GROUP), ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP), ADD (DBCC_GROUP), ADD (FAILED_LOGIN_GROUP), ADD (LOGIN_CHANGE_PASSWORD_GROUP), ADD (LOGOUT_GROUP), ADD (SCHEMA_OBJECT_CHANGE_GROUP), ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP), ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP), ADD (SCHEMA_OBJECT_ACCESS_GROUP), ADD (USER_CHANGE_PASSWORD_GROUP), ADD (SERVER_OBJECT_CHANGE_GROUP), ADD (SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP), ADD (SERVER_OBJECT_PERMISSION_CHANGE_GROUP), ADD (SERVER_OPERATION_GROUP), ADD (SERVER_PERMISSION_CHANGE_GROUP), ADD (SERVER_PRINCIPAL_CHANGE_GROUP), ADD (SERVER_PRINCIPAL_IMPERSONATION_GROUP), ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP), ADD (SERVER_STATE_CHANGE_GROUP), ADD (SUCCESSFUL_LOGIN_GROUP), ADD (TRACE_CHANGE_GROUP) WITH (STATE = ON)'
                CheckContent = "If the following events are not included, this is a finding.
                APPLICATION_ROLE_CHANGE_PASSWORD_GROUP
                AUDIT_CHANGE_GROUP
                BACKUP_RESTORE_GROUP
                DATABASE_CHANGE_GROUP
                DATABASE_OBJECT_ACCESS_GROUP
                DATABASE_OBJECT_CHANGE_GROUP
                DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP
                DATABASE_OBJECT_PERMISSION_CHANGE_GROUP
                DATABASE_OWNERSHIP_CHANGE_GROUP
                DATABASE_OPERATION_GROUP
                DATABASE_PERMISSION_CHANGE_GROUP
                DATABASE_PRINCIPAL_CHANGE_GROUP
                DATABASE_PRINCIPAL_IMPERSONATION_GROUP
                DATABASE_ROLE_MEMBER_CHANGE_GROUP
                DBCC_GROUP
                LOGIN_CHANGE_PASSWORD_GROUP
                SCHEMA_OBJECT_CHANGE_GROUP
                SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP
                SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP
                SERVER_OBJECT_CHANGE_GROUP
                SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP
                SERVER_OBJECT_PERMISSION_CHANGE_GROUP
                SERVER_OPERATION_GROUP
                SERVER_PERMISSION_CHANGE_GROUP
                SERVER_PRINCIPAL_IMPERSONATION_GROUP
                SERVER_ROLE_MEMBER_CHANGE_GROUP
                SERVER_STATE_CHANGE_GROUP
                TRACE_CHANGE_GROUP"
                FixText = "Fix Text: Add the following events to the SQL Server Audit that is being used for the STIG compliant audit.
                APPLICATION_ROLE_CHANGE_PASSWORD_GROUP
                AUDIT_CHANGE_GROUP
                BACKUP_RESTORE_GROUP
                DATABASE_CHANGE_GROUP
                DATABASE_OBJECT_ACCESS_GROUP
                DATABASE_OBJECT_CHANGE_GROUP
                DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP
                DATABASE_OBJECT_PERMISSION_CHANGE_GROUP
                DATABASE_OWNERSHIP_CHANGE_GROUP
                DATABASE_OPERATION_GROUP
                DATABASE_PERMISSION_CHANGE_GROUP
                DATABASE_PRINCIPAL_CHANGE_GROUP
                DATABASE_PRINCIPAL_IMPERSONATION_GROUP
                DATABASE_ROLE_MEMBER_CHANGE_GROUP
                DBCC_GROUP
                LOGIN_CHANGE_PASSWORD_GROUP
                SCHEMA_OBJECT_CHANGE_GROUP
                SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP
                SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP
                SERVER_OBJECT_CHANGE_GROUP
                SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP
                SERVER_OBJECT_PERMISSION_CHANGE_GROUP
                SERVER_OPERATION_GROUP
                SERVER_PERMISSION_CHANGE_GROUP
                SERVER_PRINCIPAL_IMPERSONATION_GROUP
                SERVER_ROLE_MEMBER_CHANGE_GROUP
                SERVER_STATE_CHANGE_GROUP
                TRACE_CHANGE_GROUP
                See the supplemental file `"SQL 2016 Audit.sql`". "
            }
            PlainSQL = @{
                GetScript = "SELECT name from sysdatabases where name like 'AdventureWorks%';"
                TestScript = "SELECT name from sysdatabases where name like 'AdventureWorks%';"
                SetScript = "DROP DATABASE AdventureWorks"
                CheckContent = "Check SQL Server for the existence of the publicly available `"AdventureWorks`" database by performing the following query:
                SELECT name from sysdatabases where name like 'AdventureWorks%';
                If the `"AdventureWorks`" database is present, this is a finding."
                FixText = "Remove the publicly available `"AdventureWorks`" database from SQL Server by running the following query:
                DROP DATABASE AdventureWorks"
            }
            SaAccountRename = @{
                GetScript    = "SELECT name FROM sys.server_principals WHERE TYPE = 'S' and name not like '%##%'"
                SetScript    = "alter login sa with name = [`$(saAccountName)]"
                TestScript   = "SELECT name FROM sys.server_principals WHERE TYPE = 'S' and name = 'sa'"
                CheckContent = "Verify the SQL Server default 'sa' account name has been changed.
                Navigate to SQL Server Management Studio &gt;&gt; Object Explorer &gt;&gt; &lt;'SQL Server name'&gt; &gt;&gt; Security &gt;&gt; Logins.
                If SQL Server default 'sa' account name is in the 'Logins' list, this is a finding."
                FixText      = "Navigate to SQL Server Management Studio &gt;&gt; Object Explorer &gt;&gt; &lt;'SQL Server name'&gt; &gt;&gt; Security &gt;&gt; Logins &gt;&gt; click 'sa' account name.
                Hit &lt;F2&gt; while the name is highlighted in order to edit the name.
                Rename the 'sa' account."
            }
            TraceFileLimit = @{
                GetScript    = "SELECT * FROM ::fn_trace_getinfo(NULL)"
                SetScript    = "DECLARE @new_trace_id INT; DECLARE @maxsize bigint DECLARE @maxRolloverFiles int DECLARE @traceId int DECLARE @traceFilePath nvarchar(500) SET @traceFilePath = N'`$(TraceFilePath)' SET @traceId = (Select Id from sys.traces where path LIKE (@traceFilePath + '%')) SET @maxsize = `$(MaxTraceFileSize) SET @maxRolloverFiles = `$(MaxRollOverFileCount) EXEC sp_trace_setstatus @traceid, @status = 2 EXECUTE master.dbo.sp_trace_create     @new_trace_id OUTPUT,     6,     @traceFilePath,     @maxsize,     NULL,     @maxRolloverFiles "
                TestScript   = "DECLARE @traceFilePath nvarchar(500) DECLARE @desiredFileSize bigint DECLARE @desiredMaxFiles int DECLARE @currentFileSize bigint DECLARE @currentMaxFiles int SET @traceFilePath = N'`$(TraceFilePath)' SET @currentFileSize = (SELECT max_size from sys.traces where path LIKE (@traceFilePath + '%')) SET @currentMaxFiles = (SELECT max_files from sys.traces where path LIKE (@traceFilePath + '%')) IF (@currentFileSize != `$(MaxTraceFileSize)) BEGIN PRINT 'file size not in desired state' SELECT max_size from sys.traces where path LIKE (@traceFilePath + '%') END IF (@currentMaxFiles != `$(MaxRollOverFileCount)) BEGIN PRINT 'max files not in desired state'SELECT max_files from sys.traces where path LIKE (@traceFilePath + '%') END"
                CheckContent = "Check the SQL Server audit setting on the maximum number of files of the trace used for the auditing requirement.
                Select * from sys.traces. Determine the audit being used to fulfill the overall auditing requirement. Examine the max_files and max_size parameters. SQL will overwrite the oldest files when the max_files parameter has been exceeded. Care must be taken to ensure that this does not happen, or data will be lost.
                The amount of space determined for logging by SQL Server is calculated by multiplying the maximum number of files by the maximum file size.
                If auditing will outgrow the space reserved for logging before being overwritten, this is a finding."
                FixText      = "Configure the maximum number of audit log files that are to be generated, staying within the number of logs the system was sized to support.
                Update the max_files parameter of the audits to ensure the correct number of files is defined."
            }
            ShutdownOnError = @{
                GetScript    = "SELECT * FROM ::fn_trace_getinfo(NULL)"
                SetScript    = "DECLARE @new_trace_id INT; DECLARE @traceid INT; SET @traceId  = (SELECT traceId FROM ::fn_trace_getinfo(NULL) WHERE Value = 6) EXECUTE master.dbo.sp_trace_create     @results = @new_trace_id OUTPUT,     @options = 6,     @traceFilePath = N'`$(TraceFilePath)'"
                TestScript   = "DECLARE @traceId int SET @traceId = (SELECT traceId FROM ::fn_trace_getinfo(NULL) WHERE Value = 6) IF (@traceId IS NULL) SELECT traceId FROM ::fn_trace_getinfo(NULL) ELSE Print NULL"
                CheckContent = "From the query prompt:
                SELECT DISTINCT traceid FROM sys.fn_trace_getinfo(0);
                All currently defined traces for the SQL Server instance will be listed. If no traces are returned, this is a finding.
                Determine the trace being used for the auditing requirement. Replace # in the following code with a traceid being used for the auditing requirements.
                From the query prompt, determine whether the trace options include the value 4, which means SHUTDOWN_ON_ERROR:
                SELECT CAST(value AS INT)
                FROM sys.fn_trace_getinfo(#)
                where property = 1;
                If the query does not return a value, this is a finding.
                If a value is returned but is not 4 or 6, this is a finding.
                (6 represents the combination of values 2 and 4.  2 means TRACE_FILE_ROLLOVER.)
                NOTE:  Microsoft has flagged the trace techniques and tools used in this STIG as deprecated. They will be removed at some point after SQL Server 2014. The replacement feature is Extended Events. If Extended Events are in use and configured to satisfy this requirement, this is not a finding.  The following code can be used to check Extended Events settings.
                /**********************************
                Check to verify shutdown on failure is set.
                The following settings are what should be returned:
                name = &lt;name of audit&gt;
                on_failure = 1
                on_failure_desc = SHUTDOWN SERVER INSTANCE
                **********************************/
                SELECT name, on_failure, on_failure_desc
                FROM sys.server_audits "
                FixText      = "If a trace does not exist, create a trace specification that complies with requirements.
                If a trace exists, but is not set to SHUTDOWN_ON_ERROR, modify the SQL Server audit setting to immediately shutdown the database in the event of an audit failure by setting property 1 to a value of 4 or 6 for the audit.
                (See the SQL Server Help page for sys.sp_trace_create for implementation details.)"
            }
            ViewAnyDatabase = @{
                GetScript    = "SELECT who.name AS [Principal Name], who.type_desc AS [Principal Type], who.is_disabled AS [Principal Is Disabled], what.state_desc AS [Permission State], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE what.permission_name = 'View any database' AND who.type_desc = 'SERVER_ROLE' ORDER BY who.name"
                SetScript    = "REVOKE External access assembly TO '`$(ViewAnyDbUser)'"
                TestScript   = "SELECT who.name AS [Principal Name], who.type_desc AS [Principal Type], who.is_disabled AS [Principal Is Disabled], what.state_desc AS [Permission State], what.permission_name AS [Permission Name] FROM sys.server_permissions what INNER JOIN sys.server_principals who ON who.principal_id = what.grantee_principal_id WHERE what.permission_name = 'View any database' AND who.type_desc = 'SERVER_ROLE' AND who.name != '`$(ViewAnyDbUser)' ORDER BY who.name"
                CheckContent = "Obtain the list of roles that are authorized for the SQL Server 'View any database' permission and what 'Grant', 'Grant With', and/or 'Deny' privilege is authorized. Obtain the list of roles with that permission by running the following query:
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
                       what.permission_name = 'View any database'
                AND    who.type_desc = 'SERVER_ROLE'
                ORDER BY
                       who.name
                ;
                GO
                If any role has 'Grant', 'With Grant' or 'Deny' privileges on this permission and users with that role are not authorized to have the permission, this is a finding.
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
                    (
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
                    )
                AND who.type_desc = 'SERVER_ROLE'
                ORDER BY
                    what.permission_name,
                    who.name
                ;
                GO
                "
                FixText      = "Remove the `"View any database`" permission access from the role that is not authorized by executing the following query:
                REVOKE View any database TO &lt;'role name'&gt;"
            }
            ChangeDatabaseOwner= @{
                GetScript    = "select suser_sname(owner_sid) AS 'Owner' from sys.databases where name = `$(Database)"
                SetScript    = "ALTER AUTHORIZATION ON DATABASE::`$(Database) to `$(DatabaseOwner)"
                TestScript   = "SELECT suser_sname(owner_sid) AS 'Owner' FROM sys.databases WHERE name = N'`$(Database)' and suser_sname(owner_sid) != N'`$(DatabaseOwner)';"
                Variable     = "DatabaseOwner={0}"
                CheckContent = "Review system documentation to identify SQL Server accounts authorized to own database objects.
                If the SQL Server database ownership list does not exist or needs to be updated, this is a finding.
                Run the following SQL query to determine SQL Server ownership of all database objects:
                SELECT name AS 'Database name'
                     , SUSER_SNAME(owner_sid) AS 'Database Owner'
                     , state_desc AS 'Database state'
                  FROM sys.databases"
                FixText      = "Add and/or update system documentation to include any accounts authorized for object ownership and remove any account not authorized.
                Reassign database ownership to authorized database owner account:
                Navigate to SQL Server Management Studio &gt;&gt; Object Explorer &gt;&gt; &lt;'SQL Server name'&gt; &gt;&gt; Databases &gt;&gt; right click &lt;'database name'&gt; &gt;&gt; Properties &gt;&gt; Files.
                Select new database `"Owner`":
                Navigate to click on […] &gt;&gt; Select new Database Owner &gt;&gt; Browse… &gt;&gt; click on box to indicate account &gt;&gt; &lt;'OK'&gt; &gt;&gt; &lt;'OK'&gt; &gt;&gt; &lt;'OK'&gt;"
            }
            AuditShutDownOnError = @{
                GetScript    = 'SELECT on_failure_desc FROM sys.server_audits'
                SetScript    = '/* See STIG supplemental files for the annotated version of this script */ USE [master] IF EXISTS (SELECT 1 FROM sys.server_audit_specifications WHERE name = ''STIG_AUDIT_SERVER_SPECIFICATION'') ALTER SERVER AUDIT SPECIFICATION STIG_AUDIT_SERVER_SPECIFICATION WITH (STATE = OFF); IF EXISTS (SELECT 1 FROM sys.server_audit_specifications WHERE name = ''STIG_AUDIT_SERVER_SPECIFICATION'') DROP SERVER AUDIT SPECIFICATION STIG_AUDIT_SERVER_SPECIFICATION; IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = ''STIG_AUDIT'') ALTER SERVER AUDIT STIG_AUDIT WITH (STATE = OFF); IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = ''STIG_AUDIT'') DROP SERVER AUDIT STIG_AUDIT; CREATE SERVER AUDIT STIG_AUDIT TO FILE (FILEPATH = ''C:\Audits'', MAXSIZE = 200MB, MAX_ROLLOVER_FILES = 50, RESERVE_DISK_SPACE = OFF) WITH (QUEUE_DELAY = 1000, ON_FAILURE = SHUTDOWN) IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = ''STIG_AUDIT'') ALTER SERVER AUDIT STIG_AUDIT WITH (STATE = ON); CREATE SERVER AUDIT SPECIFICATION STIG_AUDIT_SERVER_SPECIFICATION FOR SERVER AUDIT STIG_AUDIT ADD (APPLICATION_ROLE_CHANGE_PASSWORD_GROUP), ADD (AUDIT_CHANGE_GROUP), ADD (BACKUP_RESTORE_GROUP), ADD (DATABASE_CHANGE_GROUP), ADD (DATABASE_OBJECT_CHANGE_GROUP), ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP), ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP), ADD (DATABASE_OPERATION_GROUP), ADD (DATABASE_OBJECT_ACCESS_GROUP), ADD (DATABASE_OWNERSHIP_CHANGE_GROUP), ADD (DATABASE_PERMISSION_CHANGE_GROUP), ADD (DATABASE_PRINCIPAL_CHANGE_GROUP), ADD (DATABASE_PRINCIPAL_IMPERSONATION_GROUP), ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP), ADD (DBCC_GROUP), ADD (FAILED_LOGIN_GROUP), ADD (LOGIN_CHANGE_PASSWORD_GROUP), ADD (LOGOUT_GROUP), ADD (SCHEMA_OBJECT_CHANGE_GROUP), ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP), ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP), ADD (SCHEMA_OBJECT_ACCESS_GROUP), ADD (USER_CHANGE_PASSWORD_GROUP), ADD (SERVER_OBJECT_CHANGE_GROUP), ADD (SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP), ADD (SERVER_OBJECT_PERMISSION_CHANGE_GROUP), ADD (SERVER_OPERATION_GROUP), ADD (SERVER_PERMISSION_CHANGE_GROUP), ADD (SERVER_PRINCIPAL_CHANGE_GROUP), ADD (SERVER_PRINCIPAL_IMPERSONATION_GROUP), ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP), ADD (SERVER_STATE_CHANGE_GROUP), ADD (SUCCESSFUL_LOGIN_GROUP), ADD (TRACE_CHANGE_GROUP) WITH (STATE = ON)'
                TestScript   = 'DECLARE @AuditShutdown nvarchar(30) SET @AuditShutdown = (SELECT on_failure FROM sys.server_audits) IF @AuditShutdown = 0 OR @AuditShutdown IS NULL BEGIN RAISERROR (''Audit is not configured for shutdown on failure.'',16,1) END ELSE BEGIN PRINT ''Audit is configured for shutdown on failure.'' END'
                CheckContent = 'If the system documentation indicates that availability takes precedence over audit trail completeness, this is not applicable (NA). 

                If SQL Server Audit is in use, review the defined server audits by running the statement: 
                
                SELECT * FROM sys.server_audits; 
                
                By observing the [name] and [is_state_enabled] columns, identify the row or rows in use. 
                
                If the [on_failure_desc] is "SHUTDOWN SERVER INSTANCE" on this/these row(s), this is not a finding. Otherwise, this is a finding.
                
                Fix Text: If SQL Server Audit is in use, configure SQL Server Audit to shut SQL Server down upon audit failure, to include running out of space for audit logs. 
                
                Run this T-SQL script for each identified audit: 
                
                ALTER SERVER AUDIT [AuditNameHere] WITH (STATE = OFF); 
                GO 
                ALTER SERVER AUDIT [AuditNameHere] WITH (ON_FAILURE = SHUTDOWN); 
                GO 
                ALTER SERVER AUDIT [AuditNameHere] WITH (STATE = ON); 
                GO'
                FixText    = 'If SQL Server Audit is in use, configure SQL Server Audit to shut SQL Server down upon audit failure, to include running out of space for audit logs. 

                Run this T-SQL script for each identified audit: 
                
                ALTER SERVER AUDIT [AuditNameHere] WITH (STATE = OFF); 
                GO 
                ALTER SERVER AUDIT [AuditNameHere] WITH (ON_FAILURE = SHUTDOWN); 
                GO 
                ALTER SERVER AUDIT [AuditNameHere] WITH (STATE = ON); 
                GO  '
            }
        }
        #endregion
        #region Method Tests
        # TO DO - move to CommonTests
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

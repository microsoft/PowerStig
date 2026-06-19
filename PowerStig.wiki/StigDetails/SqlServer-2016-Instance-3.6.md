# [MS SQL Server 2016 Instance STIG, Version 3.6](https://github.com/Microsoft/PowerStig/wiki/SqlServer-2016-Instance-3.6)

**Title:** MS SQL Server 2016 Instance Security Technical Implementation Guide  
**Version:** 3  
**Release:** Release: 6 Benchmark Date: 05 Jan 2026 3.5.2 1.10.0  
**FileName:** U_MS_SQL_Server_2016_Instance_STIG_V3R6_Manual-xccdf.xml  
**Created:** 2/18/2026  
**Description:** This Security Technical Implementation Guide is published as a tool to improve the security of Department of Defense (DOD) information systems. The requirements are derived from the National Institute of Standards and Technology (NIST) 800-53 and related documents. Comments or proposed revisions to this document should be sent via email to the following address: disa.stig_spt@mail.mil.  
**Total Stig Rule Coverage:** **52** of **106** rules are automated; **49%**

* **High (CAT I):** **24** of **32** rules are automated
* **Medium (CAT II):** **28** of **72** rules are automated
* **Low (CAT III):** **0** of **2** rules are automated

## Automated Rules

| StigRuleId | Severity | RuleType | DscResource | DuplicateOf |
| :---- | :---- | :---- | :---- | :---- |
| V-213967.a | High | RegistryRule | Registry |  |
| V-213967.b | High | RegistryRule | Registry |  |
| V-213967.c | High | RegistryRule | Registry |  |
| V-213967.d | High | RegistryRule | Registry |  |
| V-213967.e | High | RegistryRule | Registry |  |
| V-213967.f | High | RegistryRule | Registry |  |
| V-213967.g | High | RegistryRule | Registry |  |
| V-213967.h | High | RegistryRule | Registry |  |
| V-213967.i | High | RegistryRule | Registry |  |
| V-213967.j | High | RegistryRule | Registry |  |
| V-213967.k | High | RegistryRule | Registry |  |
| V-213967.l | High | RegistryRule | Registry |  |
| V-213967.m | High | RegistryRule | Registry |  |
| V-213967.n | High | RegistryRule | Registry |  |
| V-213967.o | High | RegistryRule | Registry |  |
| V-213967.p | High | RegistryRule | Registry |  |
| V-213967.q | High | RegistryRule | Registry |  |
| V-213967.r | High | RegistryRule | Registry |  |
| V-213967.s | High | RegistryRule | Registry |  |
| V-213967.t | High | RegistryRule | Registry |  |
| V-213968 | High | SecurityOptionRule | SecurityOption |  |
| V-213969 | High | SecurityOptionRule | None | V-213968 |
| V-213954.a | Medium | SqlDatabaseRule | SqlDatabase |  |
| V-213954.b | Medium | SqlDatabaseRule | SqlDatabase |  |
| V-213954.c | Medium | SqlDatabaseRule | SqlDatabase |  |
| V-213954.d | Medium | SqlDatabaseRule | SqlDatabase |  |
| V-213964 | High | SqlLoginRule | SqlLogin |  |
| V-213961 | Medium | SqlProtocolRule | SqlProtocol |  |
| V-213939 | Medium | SqlScriptQueryRule | SqlScriptQuery |  |
| V-213940 | Medium | SqlScriptQueryRule | SqlScriptQuery |  |
| V-213942 | Medium | SqlScriptQueryRule | SqlScriptQuery |  |
| V-213943 | Medium | SqlScriptQueryRule | SqlScriptQuery |  |
| V-213989 | Medium | SqlScriptQueryRule | SqlScriptQuery |  |
| V-214000 | Medium | SqlScriptQueryRule | SqlScriptQuery |  |
| V-214002 | Medium | SqlScriptQueryRule | None | V-214000 |
| V-214004 | Medium | SqlScriptQueryRule | SqlScriptQuery |  |
| V-214008 | Medium | SqlScriptQueryRule | None | V-214000 |
| V-214014 | Medium | SqlScriptQueryRule | SqlScriptQuery |  |
| V-214028 | High | SqlScriptQueryRule | SqlScriptQuery |  |
| V-214029 | Medium | SqlScriptQueryRule | SqlScriptQuery |  |
| V-213957 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-213958 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-213975 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-214034 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-214035 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-214036 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-214037 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-214038 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-214039 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-214040 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-214041 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |
| V-214043 | Medium | SqlServerConfigurationRule | SqlServerConfiguration |  |

## Document / Manual Rules (Not Automated)

| StigRuleId | Severity | RuleType |
| :---- | :---- | :---- |
| V-213929 | Medium | DocumentRule |
| V-213930 | High | DocumentRule |
| V-213931 | Medium | DocumentRule |
| V-213932 | High | DocumentRule |
| V-213933 | Medium | DocumentRule |
| V-213936 | Medium | DocumentRule |
| V-213937 | Medium | DocumentRule |
| V-213941 | Medium | DocumentRule |
| V-213948 | Medium | DocumentRule |
| V-213950 | Medium | DocumentRule |
| V-213951 | Medium | DocumentRule |
| V-213952 | High | DocumentRule |
| V-213955 | Medium | DocumentRule |
| V-213956 | Medium | DocumentRule |
| V-213959 | Medium | DocumentRule |
| V-213960 | Medium | DocumentRule |
| V-213965 | Medium | DocumentRule |
| V-213970 | Medium | DocumentRule |
| V-213972 | High | DocumentRule |
| V-213976 | Medium | DocumentRule |
| V-213977 | Medium | DocumentRule |
| V-213978 | Medium | DocumentRule |
| V-213979 | Medium | DocumentRule |
| V-213980 | Medium | DocumentRule |
| V-213983 | Medium | DocumentRule |
| V-213986 | Medium | DocumentRule |
| V-213987 | Medium | DocumentRule |
| V-213988 | Medium | DocumentRule |
| V-213991 | Medium | DocumentRule |
| V-213992 | Medium | DocumentRule |
| V-213993 | Medium | DocumentRule |
| V-214025 | Medium | DocumentRule |
| V-214026 | Medium | DocumentRule |
| V-214027 | Medium | DocumentRule |
| V-214030 | Medium | DocumentRule |
| V-214031 | Medium | DocumentRule |
| V-214032 | Medium | DocumentRule |
| V-214033 | Medium | DocumentRule |
| V-214042 | Low | DocumentRule |
| V-214044 | Low | DocumentRule |
| V-214045 | High | DocumentRule |
| V-265870 | High | DocumentRule |
| V-213934 | Medium | ManualRule |
| V-213935 | Medium | ManualRule |
| V-213944 | Medium | ManualRule |
| V-213953 | Medium | ManualRule |
| V-213966 | High | ManualRule |
| V-213973 | Medium | ManualRule |
| V-213974 | Medium | ManualRule |
| V-213984 | Medium | ManualRule |
| V-213985 | Medium | ManualRule |
| V-213994 | Medium | ManualRule |
| V-214021 | Medium | ManualRule |
| V-214046 | High | ManualRule |

# [Microsoft Windows 2012 Server Domain Name System STIG, Version 2.5](https://github.com/Microsoft/PowerStig/wiki/WindowsDnsServer-2012R2-2.5)

**Title:** Microsoft Windows 2012 Server Domain Name System Security Technical Implementation Guide  
**Version:** 2  
**Release:** Release: 5 Benchmark Date: 31 May 2022 3.3.0.27375 1.10.0  
**FileName:** U_MS_Windows_2012_Server_DNS_STIG_V2R5_Manual-xccdf.xml  
**Created:** 6/6/2022  
**Description:** This Security Technical Implementation Guide is published as a tool to improve the security of Department of Defense (DoD) information systems. The requirements are derived from the National Institute of Standards and Technology (NIST) 800-53 and related documents. Comments or proposed revisions to this document should be sent via email to the following address: disa.stig_spt@mail.mil.  
**Total Stig Rule Coverage:** **13** of **84** rules are automated; **15%**

* **High (CAT I):** **0** of **3** rules are automated
* **Medium (CAT II):** **13** of **81** rules are automated
* **Low (CAT III):** **0** of **0** rules are automated

## Automated Rules

| StigRuleId | Severity | RuleType | DscResource | DuplicateOf |
| :---- | :---- | :---- | :---- | :---- |
| V-215591 | Medium | DnsServerRootHintRule | Script |  |
| V-215573 | Medium | DnsServerSettingRule | xDnsServerSetting |  |
| V-215574 | Medium | DnsServerSettingRule | None | V-215573 |
| V-215648 | Medium | DnsServerSettingRule | xDnsServerSetting |  |
| V-215650 | Medium | DnsServerSettingRule | None | V-215648 |
| V-215604 | Medium | PermissionRule | NTFSAccessEntry |  |
| V-215605 | Medium | PermissionRule | None | V-215604 |
| V-215606 | Medium | PermissionRule | None | V-215604 |
| V-215652.a | Medium | PermissionRule | NTFSAccessEntry |  |
| V-215632.a | Medium | UserRightRule | UserRightsAssignment |  |
| V-215632.b | Medium | UserRightRule | UserRightsAssignment |  |
| V-215632.c | Medium | UserRightRule | UserRightsAssignment |  |
| V-215652.b | Medium | UserRightRule | UserRightsAssignment |  |

## Document / Manual Rules (Not Automated)

| StigRuleId | Severity | RuleType |
| :---- | :---- | :---- |
| V-215593 | Medium | DocumentRule |
| V-215594 | Medium | DocumentRule |
| V-215608 | Medium | DocumentRule |
| V-215631 | Medium | DocumentRule |
| V-215639 | Medium | DocumentRule |
| V-215642 | Medium | DocumentRule |
| V-215644 | Medium | DocumentRule |
| V-215645 | Medium | DocumentRule |
| V-215649 | Medium | DocumentRule |
| V-215575 | Medium | ManualRule |
| V-215576 | Medium | ManualRule |
| V-215577 | Medium | ManualRule |
| V-215578 | Medium | ManualRule |
| V-215579 | Medium | ManualRule |
| V-215580 | High | ManualRule |
| V-215581 | Medium | ManualRule |
| V-215582 | Medium | ManualRule |
| V-215583 | High | ManualRule |
| V-215584 | Medium | ManualRule |
| V-215585 | Medium | ManualRule |
| V-215586 | Medium | ManualRule |
| V-215587 | Medium | ManualRule |
| V-215588 | Medium | ManualRule |
| V-215589 | Medium | ManualRule |
| V-215590 | Medium | ManualRule |
| V-215592 | Medium | ManualRule |
| V-215595 | Medium | ManualRule |
| V-215596 | Medium | ManualRule |
| V-215598 | Medium | ManualRule |
| V-215599 | Medium | ManualRule |
| V-215600 | Medium | ManualRule |
| V-215601 | Medium | ManualRule |
| V-215602 | Medium | ManualRule |
| V-215603 | Medium | ManualRule |
| V-215607 | Medium | ManualRule |
| V-215609 | Medium | ManualRule |
| V-215610 | Medium | ManualRule |
| V-215611 | Medium | ManualRule |
| V-215612 | Medium | ManualRule |
| V-215613 | Medium | ManualRule |
| V-215614 | Medium | ManualRule |
| V-215615 | Medium | ManualRule |
| V-215616 | Medium | ManualRule |
| V-215617 | Medium | ManualRule |
| V-215618 | Medium | ManualRule |
| V-215619 | Medium | ManualRule |
| V-215620 | Medium | ManualRule |
| V-215621 | Medium | ManualRule |
| V-215622 | Medium | ManualRule |
| V-215623 | Medium | ManualRule |
| V-215624 | Medium | ManualRule |
| V-215625 | Medium | ManualRule |
| V-215626 | Medium | ManualRule |
| V-215627 | High | ManualRule |
| V-215628 | Medium | ManualRule |
| V-215629 | Medium | ManualRule |
| V-215630 | Medium | ManualRule |
| V-215633 | Medium | ManualRule |
| V-215634 | Medium | ManualRule |
| V-215635 | Medium | ManualRule |
| V-215636 | Medium | ManualRule |
| V-215637 | Medium | ManualRule |
| V-215638 | Medium | ManualRule |
| V-215640 | Medium | ManualRule |
| V-215641 | Medium | ManualRule |
| V-215643 | Medium | ManualRule |
| V-215647 | Medium | ManualRule |
| V-215651 | Medium | ManualRule |
| V-215660 | Medium | ManualRule |
| V-215661 | Medium | ManualRule |
| V-228571 | Medium | ManualRule |

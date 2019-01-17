# XCCDF formatting guide

## Samples

### Registry values

The most common format across the STIG library is

Value:{space}{Hex value(Optional)}{space}({number}){space}(value description(Optional))

Here are a few examples

Value: 4
Value: 0x00000004 (4)
Value: 537395200
Value: 0x20080000 (537395200)
Value: 1 (Enabled with UEFI lock)
Value: 0x00000001 (1) (Enabled with UEFI lock)

Any xccdf check-content elements that do not align to this format will be updated to reduce the complexity of the rule parser.
It is much faster to fix and handful of rules in the than it is to update the parser.
This will also allow us to trim much of the test code and replace it with proper error handling to throw an exception when a rule is not parsed properly.

Here are a few examples of free text that should be updated to align with the rest of the xccdf formatting.

Value: 0x00000000 (0) - Off
Should be
Value: 0x00000000 (0) (Off)

Value: 0 - No peering (HTTP Only)
Should Be
Value: 0 (No peering HTTP Only)

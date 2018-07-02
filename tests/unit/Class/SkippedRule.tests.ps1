using module .\..\..\..\Public\Class\SkippedRule.psm1

[string[]] $SkippedRuleArray =
@(
"V-1114",
"V-1115",
"V-3472.a",
"V-4108",
"V-4113",
"V-8322.b",
"V-26482",
"V-26579",
"V-26580",
"V-26581"
)

Describe "SkippedRule Class" {

    Context "Constructor" {

        It "Should create an SkippedRule class instance using SkippedRule data" {
            foreach ($rule in $SkippedRuleArray) 
            {
                $SkippedRule = [SkippedRule]::new($rule)
                $SkippedRule.StigRuleId | Should Be $rule
            }
        }
    }

    Context "Static Methods" {
        It "ConvertFrom: Should be able to convert an array of StigRuleId strings to a SkippedRule array" {
            $SkippedRules = [SkippedRule]::ConvertFrom($SkippedRuleArray)

            foreach ($rule in $SkippedRuleArray)
            {
                $skippedRule = $SkippedRules.Where( {$_.StigRuleId -eq $rule})
                $skippedRule.StigRuleId | Should Be $rule
            }
        }
    }
}

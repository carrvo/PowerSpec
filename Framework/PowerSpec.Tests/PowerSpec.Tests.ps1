Import-Module "$PSScriptRoot\..\PowerSpec","$PSScriptRoot\..\..\ContrivedExample\ApplicationSpecification","$PSScriptRoot\..\..\ContrivedExample\ThirdPartyPowerShell"
$specResult = Test-Specification -API (Get-Module ApplicationSpecification) -Instance (Get-MyList)

Describe "PowerSpec" {
	Context "Test Results" {
		It "identifies the API" {
			$specResult.ModuleId.Name | Should Be ApplicationSpecification
		}
		
		It "identifies the instance Type" {
			$specResult.TypeId.Name | Should Be MyList
		}
		
		It "should pass specification (all tests)" {
			$specResult.TestResultIds.Passed | Should Be $true
		}
	}
}

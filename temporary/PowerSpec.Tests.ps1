Describe "PowerSpec" {
	Import-Module .\framework,.\impl,.\spec
	$specResult = Test-Specification -API (Get-Module spec) -Instance (Get-MyList)
	
	Context "Test Results" {
		It "identifies the API" {
			$specResult.ModuleId.Name | Should Be spec
		}
		
		It "identifies the instance Type" {
			$specResult.TypeId.Name | Should Be MyList
		}
		
		It "should pass specification (all tests)" {
			$specResult.TestResultIds.Passed | Should Be $true
		}
	}
}

using module ..\Example.Specification\bin\Debug\netstandard2.0\Example.Specification.psd1
using assembly ..\Example.ThirdParty.TrueStack\bin\Debug\netstandard2.0\Example.ThirdParty.TrueStack.dll
using assembly ..\Example.ThirdParty.ListStack\bin\Debug\netstandard2.0\Example.ThirdParty.ListStack.dll
using assembly ..\Example.ThirdParty.FakeStack\bin\Debug\netstandard2.0\Example.ThirdParty.FakeStack.dll
using module ..\..\Framework\PowerSpec\PowerSpec.psm1
using module ..\Example.Application\bin\Debug\netstandard2.0\Example.Application.dll

$specResult =  @(
	(New-Object -TypeName Example.ThirdParty.TrueStack[string]),
	(New-Object -TypeName Example.ThirdParty.ListStack[string]),
	(New-Object -TypeName Example.ThirdParty.FakeStack[string])
) | Test-Specification -API (Get-Module Example.Specification)

Describe "Third Party Acceptance" {
	It "TrueStack is accepted" {
		$specResult |
			Where-Object {$_.ModuleId.Name -EQ 'Example.Specification'} |
			Where-Object {$_.TypeId.Name -EQ 'TrueStack`1'} |
			Select-Object -ExpandProperty TestResultIds |
			Select-Object -ExpandProperty Passed |
			Should Be $true
	}
	It "ListStack is accepted" {
		$specResult |
			Where-Object {$_.ModuleId.Name -EQ 'Example.Specification'} |
			Where-Object {$_.TypeId.Name -EQ 'ListStack`1'} |
			Select-Object -ExpandProperty TestResultIds |
			Select-Object -ExpandProperty Passed |
			Should Be $true
	}
	It "FakeStack is NOT accepted" {
		$testResults = $specResult |
			Where-Object {$_.ModuleId.Name -EQ 'Example.Specification'} |
			Where-Object {$_.TypeId.Name -EQ 'FakeStack`1'} |
			Select-Object -ExpandProperty TestResultIds |
			Select-Object -ExpandProperty Passed
		($false -in $testResults) | Should Be $true
	}
}

Describe "The Application" {
	$dataStructure = New-Object -TypeName Example.ThirdParty.TrueStack[int]
	Context "when the same base" {
		It "shall be the same" {
			$digits = 2, 4, 3
			$digits |
				ConvertTo-Base -SourceBase 10 -DestinationBase 10 -DataStructure $dataStructure |
				Should Be $digits
		}
	}
	Context "when different bases" {
		It "shall convert" {
			3, 6, 5, 7 |
				ConvertTo-Base -SourceBase 8 -DestinationBase 10 -DataStructure $dataStructure |
				Should Be @(1, 9, 6, 7)
		}
	}
}

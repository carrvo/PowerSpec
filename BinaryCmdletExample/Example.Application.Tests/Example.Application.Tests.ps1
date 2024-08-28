using module ..\Example.Specification\bin\Debug\netstandard2.0\Example.Specification.psd1
using assembly ..\Example.ThirdParty.TrueStack\bin\Debug\netstandard2.0\Example.ThirdParty.TrueStack.dll
using assembly ..\Example.ThirdParty.ListStack\bin\Debug\netstandard2.0\Example.ThirdParty.ListStack.dll
using assembly ..\Example.ThirdParty.FakeStack\bin\Debug\netstandard2.0\Example.ThirdParty.FakeStack.dll
using module ..\..\Framework\PowerSpec\PowerSpec.psm1
using assembly ..\..\..\..\..\.nuget\packages\newtonsoft.json\13.0.3\lib\netstandard2.0\Newtonsoft.Json.dll
using module ..\Example.Application\bin\Debug\netstandard2.0\Example.Application.dll

$specResult =  @(
	(New-Object -TypeName Example.ThirdParty.TrueStack[string]),
	(New-Object -TypeName Example.ThirdParty.ListStack[string]),
	(New-Object -TypeName Example.ThirdParty.FakeStack[string])
) | Test-Specification -API (Get-Module Example.Specification)
Export-SpecificationResult -SpecificationResults $specResult -Path "..\Example.Application\bin\Debug\netstandard2.0\Example.Specification.json"

Describe "The Application - Third Party Acceptance" {
	Context "TrueStack is accepted" {
		$dataStructure = New-Object -TypeName Example.ThirdParty.TrueStack[int]
		It "when the same base it shall be the same" {
				$digits = 2, 4, 3
				$digits |
					ConvertTo-Base -SourceBase 10 -DestinationBase 10 -DataStructure $dataStructure |
					Should Be $digits
		}
		It "when different bases it shall convert" {
				3, 6, 5, 7 |
					ConvertTo-Base -SourceBase 8 -DestinationBase 10 -DataStructure $dataStructure |
					Should Be @(1, 9, 6, 7)
		}
	}
	Context "ListStack is accepted" {
		[Example.Specification.IStack[int]]$dataStructure = New-Object -TypeName Example.ThirdParty.ListStack[int]
		It "when the same base it shall be the same" {
				$digits = 2, 4, 3
				$digits |
					ConvertTo-Base -SourceBase 10 -DestinationBase 10 -DataStructure $dataStructure |
					Should Be $digits
		}
		It "when different bases it shall convert" {
				3, 6, 5, 7 |
					ConvertTo-Base -SourceBase 8 -DestinationBase 10 -DataStructure $dataStructure |
					Should Be @(1, 9, 6, 7)
		}
	}
	Context "FakeStack is NOT accepted" {
		$dataStructure = New-Object -TypeName Example.ThirdParty.FakeStack[int]
		It "when the same base it shall throw" {
				$digits = 2, 4, 3
				{ $digits |
					ConvertTo-Base -SourceBase 10 -DestinationBase 10 -DataStructure $dataStructure } |
					Should Throw
		}
		It "when different bases it shall throw" {
				{ 3, 6, 5, 7 |
					ConvertTo-Base -SourceBase 8 -DestinationBase 10 -DataStructure $dataStructure } |
					Should Throw
		}
	}
}

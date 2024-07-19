using namespace System.Management.Automation

class SpecificationResult {
	[PSCustomObject] $ModuleId
	[PSCustomObject] $TypeId
	[PSCustomObject[]] $TestResultIds
}

function Test-Specification {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory)]
		[PSModuleInfo] $API,
		
		[Parameter(Mandatory, ValueFromPipeline)]
		[object] $Instance
	)
	Process {
		$testType = $Instance.GetType()
		$base = $API.ModuleBase
		$specMap = $API.FileList | Get-Item | Where Name -EQ Specification.psd1 | Import-PowerShellDataFile
		$specTests = $specMap.Keys |
			Where-Object {
				$specType = [Type]$_
				$Instance -IS $specType
			} |
			ForEach-Object { $specMap.$_ } |
			ForEach-Object { @{ Path = "$base\$_"; Parameters = @{ Instance = $Instance } } }
		$results = Invoke-Pester -Script $specTests -PassThru
		$specResult = [SpecificationResult]@{
			ModuleId = $API | Select-Object -Property CompanyName,ModuleBase,Name,Version,Guid
			TypeId = $testType | Select-Object -Property @{Name='Assembly';Expression={$_.Assembly.FullName}},Namespace,Name,AssemblyQualifiedName,GUID
			TestResultIds = $results.TestResult | Select-Object -Property Describe,Context,Name,ParameterizedSuiteName,Parameters,Result,Passed,FailureMessage
		}
		Write-Output $specResult
	}
}

function Export-SpecificationResult {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory)]
		[SpecificationResult[]] $SpecificationResults,
		
		[Parameter(Mandatory)]
		[ValidatePattern('.json$')]
		[System.IO.FileInfo] $Path
	)
	Process {
		ConvertTo-Json -InputObject $SpecificationResults -Depth 4 | Out-File -LiteralPath $Path.FullName
	}
}

function Import-SpecificationResult {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory)]
		[System.IO.FileInfo] $Path
	)
	Process {
		Get-Content -LiteralPath $Path | ConvertFrom-Json | Write-Output | ForEach-Object {[SpecificationResult]$_}
	}
}

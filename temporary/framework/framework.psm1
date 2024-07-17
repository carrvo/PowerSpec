using namespace System.Management.Automation

function Invoke-Specification {
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
	}
}

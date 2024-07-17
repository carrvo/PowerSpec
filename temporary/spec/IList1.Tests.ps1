Param(
	[System.Collections.IList] $Instance
)

Describe "IList" {
	It "should add" {
		{ $Instance.Add(1) } | Should Not Throw
	}
}

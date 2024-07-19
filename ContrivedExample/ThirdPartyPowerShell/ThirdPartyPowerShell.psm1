using namespace System.Collections

class MyList : IList {
	[int] get_Count() { return 1 }
	[bool] get_IsFixedSize() { return $true }
	[bool] get_IsReadOnly() { return $true }
	[bool] get_IsSynchronized() { return $true }
	[object] get_SyncRoot() { return $null }
	[object] get_Item([int] $index) { return $null }
	[void] set_Item([int] $index, [object] $value) { }
	[int] Add ([object] $value) { return 1 }
	[void] Clear () { }
	[bool] Contains ([object] $value) { return $true }
	[void] CopyTo ([Array] $array, [int] $index) { }
	[IEnumerator] GetEnumerator () { return $null }
	[int] IndexOf ([object] $value) { return 1 }
	[void] Insert ([int] $index, [object] $value) { }
	[void] Remove ([object] $value) { }
	[void] RemoveAt ([int] $index) { }
}

function Get-MyList {
	[CmdletBinding()]
	Param()
	New-Object MyList
}

Export-ModuleMember -Function Get-MyList

#Requires -Module Example.Specification
Param(
	[Example.Specification.IStack[string]] $Instance
)

Describe "The IStack" {
	Context "while empty" {
		It "shall report empty" {
			$Instance.Count | Should Be 0
		}
	}

	It "shall accept items" {
		$Instance.Push('item1')
		$Instance.Peek() | Should Be 'item1'
	}

	Context "when peeking at the most recent item" {
		It "shall retain all items" {
			$before = $Instance.Count
			$Instance.Peek() | Should Be 'item1'
			$Instance.Count | Should Be $before
		}
	}

	It "shall hold multiple items" {
		$Instance.Peek() | Should Be 'item1'
		$Instance.Push('item2')
		$Instance.Peek() | Should Be 'item2'
	}

	Context "while holds items" {
		It "shall report how many" {
			$Instance.Count | Should Be 2
		}
	}

	Context "when removing items" {
		It "shall remove the most recently added item" {
			$Instance.Pop() | Should Be 'item2'
			$Instance.Count | Should Be 1
			$Instance.Peek() | Should Be 'item1'
		}

		It "shall not remove past empty" {
			$Instance.Pop() | Out-Null
			$Instance.Count | Should Be 0
			{ $Instance.Pop() } | Should Throw
		}
	}
}

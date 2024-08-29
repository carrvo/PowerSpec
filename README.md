# PowerSpec

## About
Tired of the overhead that comes from writing a requirements documentation / specification only to reproduce each item in code as a test?
Enter PowerSpec, a methodology for writing human-friendly requirements into a "document" that then serves as runnable tests (aka, "testable requirements")--in .NET and PowerShell!
1. Start by creating a structured document writen and read in a natural language (such as English), then run the document to see that the requirements are not yet implemented.
1. Update the document with technical and coding information about how the requirements will be verified and what the API will look like, then run the document to see that the requirements fail.
1. Have your developers create coding projects to implement the technical functionality, then run the document to see the implementation status.

PowerSpec is intended to be used for integration and public API purposes. It may also be beneficial to be used with internal APIs in complex systems.

WARNING: PowerSpec is ***NOT*** a replacement for manual Quality Assurance (QA) testing, smoke testing, visual testing, documentation testing, exploratory testing, among other practices.
It is merely meant to serve as testable requirements that enhance API development and integration practices.

## Quick Start
Note that while the example shown below is for an application in binary cmdlet form,
it applies to other applications as well (console applications, REST APIs, et cetera) but with the API looking different.

PowerSpec utilizes [Pester v3](https://github.com/pester/Pester/wiki/Should-v3) for its structured document.
Furthermore, examples are written in accordance with [EARS Principles](https://alistairmavin.com/ears/) with a small structural difference.
EARS is **not** mandatory, and any two- to three-level orgainizational hierarcy will suffice.

### 1. Product Owners, Customers, Standards Organizations
Start by creating a Pester test file `<Specification Name>.Tests.ps1` and populate it with the following structure:
```powershell
Describe "The <system name>" {
	It "shall <ubiquitous response>" {
	}
	Context "while <precondition(s)>" {
		It "shall <state driven response>" {
		}
	}
	Context "when <trigger>" {
		It "shall <event driven response>" {
		}
	}
	Context "where <feature is included>" {
		It "shall <optional feature response>" {
		}
	}
	Context "if <trigger>" {
		It "shall <unwanted behaviour response>" {
		}
	}
}
```

This file can then be run either by
- Right-click "Run with PowerShell" (on Windows)
- `.\<Specification Name>.Tests.ps1` from a PowerShell command-line
- `powershell.exe -File .\<Specification Name>.Tests.ps1` from other command-lines

### 2. Solution Architects, Standards Organizations
Update `<Specification Name>.Tests.ps1` with technical information about testing and the API.

First, if you are writing requirements for a data structure, then you need to declare it at the top of the file.
This allows third-parties (including yourself) to implement different solutions to your specification.
*For those looking for requirements against a single-solution specification then the following is not necessary;
in fact, PowerSpec is not necessary and you can freely follow or not the methodology laid out.*
```powershell
#Requires -Module <Specification Module>
Param(
	[<Specification Interface>] $Instance
)
```

You will also need to create the project and interface for your data structure in your .NET language of chioce.
```cs
public interface IStack<T>
{
    void Push(T item);

    T Pop();

    T Peek();

    Int32 Count { get; }
}
```

This interface translates to
```powershell
#Requires -Module Example.Specification
Param(
	[Example.Specification.IStack[string]] $Instance
)
```

Next, add scripting code within `It` blocks to define the API signatures and how it will be used.
Make should to query for system responses and feed them into `Should` statements to ensure that the requirement is being met.
For [Pester v3](https://github.com/pester/Pester/wiki/Should-v3) order is preserved, but be careful about variable scope
(*for [Pester v5](https://pester.dev/docs/quick-start) there was a breaking change so that order is intentionally no longer preserved, among other differences*).
You can use the syntax `$script:myVariable` for scope sharing.
```powershell
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
```

Then, let PowerSpec know how to map the interface to your tests with a `Specification.psd1` file.
```powershell
@{
	"Example.Specification.IStack[string]" = @(,
		"IStack.Tests.ps1"
	)
}
```

The syntax for this file comes from [PowerShell data files](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_data_files?view=powershell-5.1)
and is expected have the following structure.
```powershell
@{
	"Namespace.Type1" = @(, "Module relative path to Specification Name.Tests.ps1")
	"Namespace.Type2" = @(
		"Module relative path to Spec1.Tests.ps1",
		"Module relative path to Spec2.Tests.ps1"
	)
}
```

Finally, create a module manifest file from the command-line so that all the needed files can be distributed together.
```powershell
PS> New-ModuleManifest -Author '<your name>' -Company 'your organization' -RequiredAssemblies 'Module relative path to your assembly.dll' -FileList '<Specification Name>.Tests.ps1', '<Additional Specification Name>.Tests.ps1', 'Specification.psd1' #other parameters at your discretion
```

A [Full Example](./BinaryCmdletExample/Example.Specification/) has been included for you to explore.

The specification can now be run through PowerSpec! (This can be seen [here](./BinaryCmdletExample/Example.Application.Tests/Example.Application.Tests.ps1).)
```powershell
PS> Import-Module <Specification Module path>
PS> Import-Module PowerSpec
PS> $specResult = New-Object -TypeName <ThirdParty> | Test-Specification -API (Get-Module <Specification Module>)
```

And later exported for your application to verify third-party implementations.
```powershell
PS> Export-SpecificationResult -SpecificationResults $specResult -Path "Application Specification config path.json"
```

*Note: Architects should be prepared to negotiate the signatures with developers.*

### 3. Developers
Create coding projects to implement!
If you are a third-party looking to implement a interface, then you can proceed as you normally do ([Examples](./BinaryCmdletExample/ThirdParty/)).
If you are looking to implement a binary cmdlet, then there is also an [example](./BinaryCmdletExample/Example.Application/) for you!
You can also read on for a few helpful hints.

#### Low Quality
*TODO: basic implementation of binary cmdlets from a signature.*

#### Mid Quality
*TODO: fleshed out implementation of binary cmdlets.*

You should also be writing additional testing outside the specification for design decisions, PSR, robustness, additional features, and unit testing.

#### High Quality
You should be aware of what additional software and industry practices apply to your product that elevate it to a high quality product.

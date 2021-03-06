#
# Unit tests for the Code keyword
#

[CmdletBinding()]
param (

)

# Setup error handling
$ErrorActionPreference = 'Stop';
Set-StrictMode -Version latest;

# Setup tests paths
$rootPath = (Resolve-Path $PSScriptRoot\..\..).Path;
$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$temp = "$here\..\..\build";

Import-Module (Join-Path -Path $rootPath -ChildPath "out/modules/PSDocs") -Force;

$outputPath = "$temp\PSDocs.Tests\Code";
Remove-Item -Path $outputPath -Force -Recurse -Confirm:$False -ErrorAction SilentlyContinue;
$Null = New-Item -Path $outputPath -ItemType Directory -Force;

$dummyObject = New-Object -TypeName PSObject;

$Global:TestVars = @{ };

Describe 'PSDocs -- Code keyword' {
    Context 'Code markdown' {

        # Define a test document with a table
        document 'CodeMarkdown' {
            Code {
                # This is a comment
                This is code

                # Another comment
                And code
            }
        }

        $result = CodeMarkdown -InputObject $dummyObject -PassThru;

        It 'Should match expected format' {
            $result | Should -Match "`# This is a comment(\r|\n|\r\n)This is code(\r|\n|\r\n){2,}`# Another comment(\r|\n|\r\n)And code";
        }
    }

    Context 'Code markdown with named format' {

        # Define a test document with a table
        document 'CodeMarkdownNamedFormat' {
            Code powershell {
                Get-Content
            }
        }

        $result = CodeMarkdownNamedFormat -InputObject $dummyObject -PassThru;

        It 'Should match expected format' {
            $result | Should -Match '```powershell\r\nGet-Content\r\n```';
        }
    }

    Context 'Code markdown with evaluation' {

        # Define a test document with a table
        document 'CodeMarkdownEval' {
            $a = 1; $a += 1; $a | Code powershell;
        }

        $outputDoc = "$outputPath\CodeMarkdownEval.md";
        CodeMarkdownEval -InputObject $dummyObject -OutputPath $outputPath;

        It 'Should have generated output' {
            Test-Path -Path $outputDoc | Should -Be $True;
        }

        It 'Should match expected format' {
            $outputDoc | Should -FileContentMatchMultiline '```powershell\r\n2\r\n```';
        }
    }
}

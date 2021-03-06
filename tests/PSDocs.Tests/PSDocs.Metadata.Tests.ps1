#
# Unit tests for the Metadata keyword
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

$outputPath = "$temp\PSDocs.Tests\Metadata";
Remove-Item -Path $outputPath -Force -Recurse -Confirm:$False -ErrorAction SilentlyContinue;
$Null = New-Item -Path $outputPath -ItemType Directory -Force;

$dummyObject = New-Object -TypeName PSObject;

$Global:TestVars = @{ };

Describe 'PSDocs -- Metadata keyword' {
    Context 'Metadata single entry' {
        # Define a test document with metadata content
        document 'MetadataSingleEntry' {
            Metadata ([ordered]@{
                title = 'Test'
            })
        }

        $outputDoc = "$outputPath\MetadataSingleEntry.md";
        MetadataSingleEntry -InputObject $dummyObject -OutputPath $outputPath;

        It 'Should have generated output' {
            Test-Path -Path $outputDoc | Should be $True;
        }

        It 'Should match expected format' {
            Get-Content -Path $outputDoc -Raw | Should match '---\r\ntitle: Test\r\n---';
        }
    }

    Context 'Metadata multiple entries' {
        # Define a test document with metadata content
        document 'MetadataMultipleEntry' {
            Metadata ([ordered]@{
                value1 = 'ABC'
                value2 = 'EFG'
            })
        }

        $outputDoc = "$outputPath\MetadataMultipleEntry.md";
        MetadataMultipleEntry -InputObject $dummyObject -OutputPath $outputPath;

        It 'Should have generated output' {
            Test-Path -Path $outputDoc | Should be $True;
        }

        It 'Should match expected format' {
            Get-Content -Path $outputDoc -Raw | Should match '---\r\nvalue1: ABC\r\nvalue2: EFG\r\n---';
        }
    }

    Context 'Metadata multiple blocks' {
        # Define a test document with metadata content
        document 'MetadataMultipleBlock' {
            Metadata ([ordered]@{
                value1 = 'ABC'
            })

            Section 'Test' {
                'A test section spliting metadata blocks.'
            }

            Metadata @{
                value2 = 'EFG'
            }
        }

        $outputDoc = "$outputPath\MetadataMultipleBlock.md";
        MetadataMultipleBlock -InputObject $dummyObject -OutputPath $outputPath;

        It 'Should have generated output' {
            Test-Path -Path $outputDoc | Should be $True;
        }

        It 'Should match expected format' {
            Get-Content -Path $outputDoc -Raw | Should match '---\r\nvalue1: ABC\r\nvalue2: EFG\r\n---';
        }
    }

    Context 'Document without Metadata block' {
        # Define a test document without metadata content
        document 'NoMetdata' {
            Section 'Test' {
                'A test section.'
            }
        }

        $outputDoc = "$outputPath\NoMetdata.md";
        NoMetdata -InputObject $dummyObject -OutputPath $outputPath;

        It 'Should have generated output' {
            Test-Path -Path $outputDoc | Should be $True;
        }

        It 'Should match expected format' {
            Get-Content -Path $outputDoc -Raw | Should not match '---\r\n';
        }
    }

    Context 'Document null Metadata block' {
        # Define a test document with null metadata content
        document 'NullMetdata' {
            Metadata $Null
            Section 'Test' {
                'A test section.'
            }
        }

        $outputDoc = "$outputPath\NullMetdata.md";
        NullMetdata -InputObject $dummyObject -OutputPath $outputPath;

        It 'Should have generated output' {
            Test-Path -Path $outputDoc | Should be $True;
        }

        It 'Should match expected format' {
            Get-Content -Path $outputDoc -Raw | Should not match '---\r\n';
        }
    }

    Context 'Get Metadata header' {
        $result = Get-PSDocumentHeader -Path $outputPath;

        It 'Should have data' {
            $result | Should not be $Null;
        }

    }
}

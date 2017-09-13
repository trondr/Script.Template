Set-StrictMode -Version Latest

# User specified functions for use in the main script can be defined in this file.

function SomeExampleUserFunctionThrowsError
{
    throw [System.IO.FileNotFoundException] "File not found exception example."
}

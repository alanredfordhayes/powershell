Import-Module .\VirtualMachine.ps1 -Force

Clear-Host

$vm = [VirtualMachine]::new()

$vm.Server(
    (Read-Host -Prompt 'Server'),
    (Get-Credential)
)

$vm.NewVMinteractive()
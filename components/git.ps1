if (((Get-Command git -ErrorAction SilentlyContinue) -ne $null) -and ((Get-Module -ListAvailable Posh-Git -ErrorAction SilentlyContinue) -ne $null)) {
  Import-Module Posh-Git
  # Disabled file statuses. It slows shell completely
  $GitPromptSettings.EnableFileStatus = $false
  Start-SshAgent -Quiet
}

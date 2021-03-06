# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}


### Update Help for Modules
Write-Host "Updating Help..." -ForegroundColor "Yellow"
Update-Help -Force


### Package Providers
Write-Host "Installing Package Providers..." -ForegroundColor "Yellow"
Get-PackageProvider NuGet -Force | Out-Null
# Chocolatey Provider is not ready yet. Use normal Chocolatey
#Get-PackageProvider Chocolatey -Force
#Set-PackageSource -Name chocolatey -Trusted


### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
Install-Module Posh-Git -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force


### Chocolatey
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"
if ((which cinst) -eq $null) {
    iex (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
    Refresh-Environment
    choco feature enable -n=allowGlobalConfirmation
}

# system and cli
choco install curl                --limit-output
choco install nuget.commandline   --limit-output
choco install webpi               --limit-output
choco install git.install         --limit-output -params '"/GitAndUnixToolsOnPath /NoShellIntegration"'
choco install nvm.portable        --limit-output

# browsers
choco install GoogleChrome        --limit-output; <# pin; evergreen #> choco pin add --name GoogleChrome        --limit-output

# dev tools and frameworks
choco install vim                 --limit-output
choco install winmerge            --limit-output
choco install vscode              --limit-output
choco install awscli              --limit-output

Refresh-Environment

nvm on
$nodeLtsVersion = choco search nodejs-lts --limit-output | ConvertFrom-String -TemplateContent "{Name:package-name}\|{Version:1.11.1}" | Select -ExpandProperty "Version"
nvm install $nodeLtsVersion
nvm use $nodeLtsVersion
Remove-Variable nodeLtsVersion

gem pristine --all --env-shebang

### Windows Features
Write-Host "Installing Windows Features..." -ForegroundColor "Yellow"
# ASP.NET Base Configuration
Enable-WindowsOptionalFeature -Online -All -FeatureName `
    "NetFx3", `
    "NetFx4-AdvSrvs", `
    "NetFx4Extended-ASPNET45", `
    -NoRestart | Out-Null

# Web Platform Installer for remaining Windows features
webpicmd /Install /AcceptEula /Products:"UrlRewrite2"
#webpicmd /Install /AcceptEula /Products:"NETFramework452"
webpicmd /Install /AcceptEula /Products:"Python279"

### Node Packages
Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
if (which npm) {
    npm update npm
    npm install -g gulp
    npm install -g mocha
    npm install -g node-inspector
    npm install -g yo
    npm install -g serverless
    npm install -g typescript
    npm install -g tslint
}

Write-Host "Installing vim plugins..." -ForegroundColor "Yellow"
if ((which curl) -and (which vim) -and (which bash) -and (which git)) {
    cp home/.vimrc ~/
    cp home/.gvimrc ~/

    mkdir -p ~/.vim/autoload
    mkdir -p ~/.vim/bundle
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    # Nerdtree
    git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
    git clone https://github.com/Xuyuanp/nerdtree-git-plugin.git ~/.vim/bundle/nerdtree-git-plugin
    git clone https://github.com/chase/vim-ansible-yaml.git ~/.vim/bundle/vim-ansible-yaml
    git clone https://github.com/altercation/vim-colors-solarized.git ~/.vim/bundle/vim-colors-solarized
    git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go
    git clone https://github.com/othree/yajs.vim ~/.vim/bundle/yajs
}


### Visual Studio Plugins
if (which Install-VSExtension) {
    ### Visual Studio 2015
    # VsVim
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329/file/6390/57/VsVim.vsix
    # Productivity Power Tools 2015
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/34ebc6a2-2777-421d-8914-e29c1dfa7f5d/file/169971/1/ProPowerTools.vsix

    ### Visual Studio 2013
    # VsVim
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329/file/6390/57/VsVim.vsix
    # Productivity Power Tools 2013
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/dbcb8670-889e-4a54-a226-a48a15e4cace/file/117115/4/ProPowerTools.vsix
    # Web Essentials 2013
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/56633663-6799-41d7-9df7-0f2a504ca361/file/105627/47/WebEssentials2013.vsix
}

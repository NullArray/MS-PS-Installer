# MS-PS-Installer
Automated PowerShell installer for `*Nix` with multi Distro support.

As part of a different project i am currently working on. I wrote this Bash script to automate the installation of PowerShell on Linux. It started off as an installer for Debian and Ubuntu primarily but i've expanded functionality to include support for Fedora, RHEL, CentOS, and OpenSUSE.

The aim of the script is to automate as much of the installation operations as possible. If you want to easily install and run MS PowerShell on your local Linux machine or perhaps in VM, now you can.

## Usage

To use the tool all you need to do is the following.
```
git clone https://github.com/NullArray/MS-PS-Installer.git
cd MS-PS-Installer
chmod +x ms-ps.sh

# And you can run it from your terminal with the following command
sudo ./ps-ms.sh
```

## Additional Information

This script comes with two methods of deploying PowerShell-Core on Linux. The first approach makes use of 'AppImages' which bundles all the dependencies into a single package that works independently of the user's Distro.
 
It is built as a single portable binary and as such can be run without installing, or altering any system libraries or preferences.
	
If you'd prefer to run PowerShell-Core natively, and install the related components to your distribution directly, the second approach is reccomended. Opting for this approach will show a list of supported distros. Once you've made your selection, the installer will employ your package manager and related utilities to install PowerShell
to your system proper.

### Note

This is an early release and as such the tool might be subject to change in the future. Should you happen to encounter a bug please feel free to [Open up a Pull Request](https://github.com/NullArray/MS-PS-Installer/pulls) or [Submit a Ticket](https://github.com/NullArray/MS-PS-Installer/issues).

Thanks.


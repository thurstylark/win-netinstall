#WinPE
##Website
https://technet.microsoft.com/en-us/library/cc766093(v=ws.10).aspx


##Details

Windows Preinstallation Environment (WinPE) is a tool provided by Microsoft that is designed to run on removable media, and it provides a Windows-based framework for various sysadmin tasks, most commonly capturing and applying images.

The way Microsoft has chosen to implement this environment is to create a bootloader that understands WIM image archives enough to mount and boot to them. This means the entirety of the WinPE installation is housed within a WIM image, and will be booted as read-only. Modifications to the WinPE disk must be made by a tool that can manipulate WIM archives such as Microsoft's DISM, or the wimlib suite of tools for Linux (http://wimlib.net/).

This is important, because this drastically limits the availible methods for booting WinPE. One needs to mount and boot to physical media in FAT32 format with a valid and correct MBR, boot to optical media created with Microsoft-specific tools, or find another way to point to the necessary boot files.

This environment is necessary in order to capture a WIM image using imagex.exe, apply (deploy) a WIM image using imagex.exe, or (in the case of this configuration) run Windows Setup to automatically install a custom image.

##Components

- WinPE_amd64 base image
	- Created with Windows Assesment and Deployment Kit (ADK)
- imagex.exe
	- Included with the ADK, and can be found at `C:\Windows\System32\imagex.exe`
	- This must be manually added to your WinPE media in `C:\Windows\System32\`
- startnet.cmd
	- Found in your WinPE media at `C:\Windows\System32\startnet.cmd`
	- This batch file is the first thing to run when WinPE starts
	- This contains commands to mount a SMB share, CD to the appropriate directory, and run setup.exe with the answer file
- Autounattend.xml
	- Created with Windows System Image Manager (SIM)
	- Contains instructions pertaining to the installation and Out Of Box Experience (OOBE)
- setup.exe
	- AKA Windows Setup
	- Facilitates the install of Windows
	- Copied from Windows 10 install media
- timeout.exe
	- Optional addition to the WinPE setup
	- Added specifically to show a countdown and give the user a chance to abort the install process before it begins
	- Can be found at `C:\Windows\System32\timeout.exe`
	- Must be manually added to your WinPE media at `C:\Windows\System32\timeout.exe`
	- Part of any Windows installation


#WinPE Base Image
##Prerequisites

- Windows 10 
- Windows ADK
	- Download: https://msdn.microsoft.com/en-us/windows/hardware/dn913721.aspx#adkwin10
	- During the install process, be sure to select the following features:
		- Deployment Tools
		- Windows Preinstallation Environment
		- Imaging and Configuration Designer
- USB Thumb Drive no greater than 32GB



##Creating WinPE Media

Follow the instructions found here:
https://technet.microsoft.com/en-us/library/hh825109.aspx

For the purpose of this specific configuration, installing WinPE to a USB flash drive is not necessary. All the files we will need are found in the "media" directory within the directory you created in the above instructions. 

>***IMPORTANT NOTE:***
>Setup.exe CANNOT modify a GPT disk when booted in BIOS mode!! For this reason, we MUST be able to boot WinPE in UEFI mode in order to install Windows 10 properly!

The BARE MINIMUM files needed for this configuration:
- \Boot and all contents
	- This contains files necessary for Windows to boot properly
- \EFI and all contents
	- This contains files necessary for booting in UEFI mode
- \en-us and all contents
	- This folder contains localization information that may or may not be necessary. Included for thoroughness
- \sources and all contents
	- This folder contains the boot drive archive "boot.wim" and other files necessary for proper operation
OPTIONAL files:
- \bootmgr
	- File that enables booting in BIOS mode
	- *NOT RECCOMMENDED FOR PRODUCTION USE* Omit this file unless testing/troubleshooting

##Customizing WinPE

- In a Windows environment, follow these instructions:
	- https://technet.microsoft.com/en-us/library/hh824972.aspx
- In a Linux environment, refer to the man pages for each tool in the wimlib library:
	- http://wimlib.net/


##Customizations done for this specific configuration
- Modified startnet.cmd (see below)
- Addition of imagex.exe and timeout.exe


#Imagex.exe
##Reference
https://technet.microsoft.com/en-us/library/cc748966(v=ws.10).aspx

##Description

Imagex.exe is a command line tool provided with the ADK and is used for working with WIM images. This tool is necessary for capturing the base image on your target computer. While not entirely necessary for the purpose of an unattended install, it was included in this configuration to provide an easy solution for capturing images.

##Accessing

Accessing imagex in this specific configuration can be done by following these steps:

1. Boot to the WinPE netboot
2. Press Ctrl-C before the timer runs out 
3. At the prompt, run `imagex` and include the necessary options

>Note:
>This assumes that you have already set up your netboot environment as detailed in `netboot/README` and your WinPE environment as detailed in this document.

##Usage

Using imagex is beyond the scope of this document. Please see imaging/README for usage instructions.


#Startnet.cmd
##Reference
https://technet.microsoft.com/en-us/library/hh825191.aspx

##Description
Startnet.cmd is a batch file that is run when WinPE boots.

##Special Considerations
When creating startnet.cmd, it should include a line to run wpeinit. This is because wpeinit initializes hardware devices (eg. NIC, Display), and reads the Autounattend.xml file for configuration information.

In this specific configuration, wpeinit is called in the first line in order to initialize network devices in preparation to mount a SMB share.

##Contents
You can find the contents of this script at `imaging/startnet.cmd`.


#Answer File: Autounattend.xml
##Reference
https://technet.microsoft.com/en-us/library/cc749113(v=ws.10).aspx

##Description

An Answer File is an XML file that contains settings and values that Windows uses to automatically configure itself at several points in the installation process. Each of these points is called a Configuration Pass. The configuration passes of interest to us in this scope are "windowsPE" and "oobeSystem".


##Usage

Windows looks for an Answer File at different locations depending on the Configuration Pass. The locations and applicible passes can be found in the table on this page: https://technet.microsoft.com/en-us/library/cc749415(v=ws.10).aspx

For this configuration, the Answer File is placed in the following locations:

1. The root of the WinPE media
	-`C:\Autounattend.xml`
	-This is to assure that WinPE is configured correctly when wpeinit is run
2. In the same directory as setup.exe
	-This is referred to explicitly when startnet.cmd runs setup.exe 
	-Implementing it this way ensures flexibility when tweaking settings specific to setup.exe
3. In the Sysprep folder in the imaged drive
	-`C:\Windows\System32\Sysprep`
	-Allows configuration of the "oobeSystem" configuration pass, and keeping the Answer File in a place that the end user is less likely to find

##Creation:

Creation of an Answer File is beyond the scope of this document. Please see imaging/README for information about creating an Answer File.


#Setup.exe

Setup.exe does the actual work of installing our image. It is copied from the Windows 10 install media.

Please see `imaging/README` for details.


#Timeout.exe
##Description

Timeout.exe is a Windows command line program that displays a countdown for a determined ammount of time.

Timeout.exe is used in this configuration to give the user a chance to abort the install process in order to use other features of WinPE


##Usage

Please refer to `timeout.exe`'s help text. Access this by opening a cmd window, and running `timeout /?`.


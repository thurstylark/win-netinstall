Imaging Windows 10
====================

###Capturing and Deploying Windows Images for the Linux Admin

Unfortunately, Windows doesn't give you tools to access low-level block devices or a flexible way to copy configuration from machine to machine. On top of all that, there's n+1 layers of proprietary databases, tools, formats, and what-have-you over something that a *nix OS makes super simple. 

Never fear, because it absolutely IS possible to capture and deploy an image to that 1% of your environment that *has* to be Windows, *without* needing a Windows Server environment. 

Of course, since Microsoft is in the picture, remaining completely FOSS goes straight out the Windows, but you can still get by with software that is free-as-in-beer.

Also, since most of this solution is licensed up the wazoo, I am unable to distribute any tools that were used in this solution. 

###Components involved in this solution
 - Windows 10
	- Sysprep
- Windows Assesment and Deployment Kit (ADK)
	- WinPE
	- imagex
	- Windows IMaging format (WIM)
	- Windows System Image Manager (SIM) 
	- Answer Files
- Windows 10 Install Media
	- setup.exe


Image Capture Environment
-----------------

###Reference
https://technet.microsoft.com/en-us/library/cc766376(v=ws.10).aspx

###Setting up

It's reccommended to set up 2 Windows machines: your template machine, and a tech machine. Your template machine is where you set up Windows the way you want and capture the image from, and your tech machine holds your tools like ADK, your WinPE media, and where you can work with Microsoft-supported tools.
 
###Template Machine
 
Start with a factory fresh install of Windows 10, go through the setup, and start installing and configuring to your heart's content. When you are content with it, it's time to do Sysprep.

Sysprep is a tool included in the base install of Windows that removes any hardware-specific information, and also returns Windows to its "Out Of Box Experience" (OOBE).

To run Sysprep, open a run prompt (WinKey-R), and type `sysprep` and click OK. This will bring up an Explorer window. Open sysprep. For System Cleanup Action, select "Enter Out of Box Experience". Select Generalize, and for Shutdown Options select Shut Down.
 
Now your template machine is "Syspreped" and ready for the image to be captured. DO NOT boot the computer up to Windows again until you have a WinPE disk ready. If you boot the computer up again, Windows will specialize the system, run Windows Welcome, and you will need to sysprep again. 

###Tech Machine
 
On your tech machine, install Windows ADK and create a WinPE disk. Please refer to the instructions in [`winpe/README.md`](../blob/master/winpe/README.md)

Capture the Image
-------------------
###Reference
https://technet.microsoft.com/en-us/library/cc748966(v=ws.10).aspx

###Capture using imagex

Once booted to your WinPE media (that has imagex installed), get an idea of where your volumes are. Run `diskpart` in the cmd window. At the DISKPART prompt, run `list volume`. This will show the volumes availible to you. When you're done with diskpart, exit. 

Now it's time to capture your image:

`imagex /capture C:\ C:\image.wim "ImageName"`

Refer to https://technet.microsoft.com/en-us/library/cc749447(v=ws.10).aspx for other imagex options.

>Note: 
>It is completely acceptable to use the source drive as the destination of the WIM image. imagex is smart enough to skip the resulting file when archiving. Sometimes it can be the best solution for capturing an image depending on the resulting size.


Create Install Environment
----------------------------

###SMB share
WinPE (like all Windows versions) speaks SMB/Samba natively, and does not have support for other network filesharing systems. You will need a Samba share for your WinPE to mount. This Samba share is used to serve the image and install media. The share definition as it exists for this solution is as follows:

```
[images]
   comment = Public Stuff
   path = /home/samba
   public = yes
   read only = yes
   write list = @wheel
```

The easiest way to utilize this share is to mount the share as a drive letter in `startnet.cmd` using `net use`.

```
net use Y: \\192.168.59.1\images
```

Syntax for `net use` can be found here: https://technet.microsoft.com/en-us/library/bb490717.aspx

###Copy Install Media
The tools necessary to do this install in an automated way can be found on any Windows 10 install media. You can create this media on a thumb drive using built in tools.

All the files necessary are in the `sources/` directory. Replace `sources/install.wim` with the image captured with `imagex` as described above. 

For this solution, I put the sources dir at the root of the SMB share. This way, we can run `setup.exe` from `startnet.cmd`, and make the whole process completely automated:

```
cd /D y:\sources
setup.exe /unattend:"y:\Autounattend.xml"
```

###Create Answer File

An answer file is an XML file that is made with Windows System Image Magager (SIM). This XML file handles several automated tasks at several stages of the boot, setup, and install process. SIM should have been installed with the ADK. If it has not, run the ADK installer again, being sure to select SIM during the process.

The `Autounattend.xml` used in this solution is included in this folder as reference. **DO NOT use this file as-is**. Certain information has been redacted, and I cannot give any guarantee that your system will not be harmed if you do so. If you would like to use the `Autounattend.xml` in this repo as a template, I suggest you open it with SIM to modify it to your liking.

Certain configuration options correspond only with certain configuration passes. I suggest you look in the help documents that were included with SIM for explanations of the individual configuration options. Alternatively, a tutorial for creating a simple Answer File can be found here: https://technet.microsoft.com/en-us/library/cc749317(v=ws.10).aspx

You may have noticed that I explicitly referenced `Autounattend.xml` in the call to `setup.exe` in the example above. Ideally, `setup.exe` would automatically pull its configuration options from `Autounattend.xml` if it exists in the right directory with the right name. However, I decided to forego the time I would have spent testing this feature, and just made the reference explicitly.

A list of all the configuration passes, and where Windows will expect an Answer File can be found here: https://technet.microsoft.com/en-us/library/cc749415(v=ws.10).aspx

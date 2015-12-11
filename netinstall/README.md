Net Booting
===============
###Goal

Boot a UEFI client to a Windows PE image hosted on a Linux server.

###Implementation

This soution is comprised of the following componets:

- iPXE EFI Image with embedded script
	- Custom-built image in order to include a chainloading script
- iPXE Boot Script
	- Instructs iPXE to chainload wimboot, and includes pointers to `BCD`, `BCD.sdi`, and `Boot.wim`
- Wimboot
	- EFI image capable of booting a WIM image over HTTP
	- A product of the iPXE team
- DHCPD
	- Configuration that serves different pxe boot files to UEFI machines, than it serves BIOS machines.

iPXE
-----------------
###Website: 
http://www.ipxe.org/

###Summary

iPXE is meant to be a replacement PXE firmware to be burned onto your NIC hardware, but it can also be used as a PXE loader in a similar fashion to `pxelinux.0`. This solution paired with wimboot allows us to boot WinPE over the network without needing a Windows Server environment and all the costs associated with such an environment.


###Details

iPXE was chosen for this solution because of its ability to chainload wimboot in UEFI mode. This is necessary because WinPE CANNOT modify a GPT disk while in BIOS mode. Windows 10 *MUST* be installed in UEFI mode, and thus must use a GPT disk.

The way iPXE is implemented in this configuration is by leveraging the capability of Embedded Scripts. During the compilation process, one can specify the "EMBED" paramater that points to an ipxe script. See ipxe.org for details on the ipxe scripting language.

The embeded script in question simply tells iPXE to chainload `http://192.168.59.1:8080/boot.ipxe`, which is simply another ipxe script.

This 2nd ipxe script then chainloads wimboot and points wimboot (see below) to the files needed to boot to the WIM image. This script can be found at `root/srv/http/boot.ipxe`.

>Note:
>Changing the default behavior of iPXE is as simple as editing the 2nd script AS LONG as it can be found at `http://192.168.59.1:8080/boot.ipxe`. If this location changes, a new EFI image will need to be built.

###Building the EFI Image

1. Follow the instructions at http://ipxe.org/download to clone the iPXE git.
2. `cd ipxe/src`
3. create your ipxe script you wish to embed
	- You can find the script that was used for this configuration at `netinstall/embedscript.ipxe`
4. `make bin-x86_64-efi/ipxe.efi EMBED=myscript.ipxe`
	- replace `myscript.ipxe` with the location of the script you wish to embed.

The resulting file (`ipxe.efi`) should be moved into the TFTP root directory. Find the efi image used in this configuration at `netinstall/ipxe.efi`

Wimboot
-------------
###Documentation
Please refer to the following page for wimboot documentation:
http://ipxe.org/appnote/wimboot_architecture


DHCP
-------------
###Reference
http://ipxe.org/howto/chainloading
(see section titled "UEFI")
https://wiki.archlinux.org/index.php/Diskless_system#DHCP

###Description

This entire solution needs to live on the same server as an existing PXE setup, but one that is geared towards BIOS machines. This means that the dhcp server needs to be able to discriminate between BIOS and UEFI machines. 

Enter: DHCP Option Code 93. This option is called the *"Client System Archetecture Type"*, with which the DHCP client can ask for a specific type of bootable binary. In this setup, the UEFI client asks for an x86_64-efi binary which is type 0x7. So, in `/etc/dhcpd.conf`, we define an option called `architecture` which is equal to the value of code 93, and define it as an unsigned integer 16 (`netinstall/dhcpd.conf` line 9). Later on lines 21-25, we test this option with an if. As a result, we send EFI clients `ipxe.efi`, and BIOS clients `pxelinux.0`.







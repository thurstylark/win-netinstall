#Deploying Windows in a Linux Environment
##Goal
Unattended deployment of a customized Windows 10 image using an existing Linux server environment.

Budget: $0

##Summary
A component of our product includes a Windows 10 machine which runs a touch interface in Chrome. We chose this route knowing that the end user would need to use the machine for more than just a control interface, and that Windows would be the most familiar environment. Windows 10 was chosen because of its good touch integration, paired with it's relative familiarity to Windows 7, which continues to be a standard in enterprise environments.

Deployment of these machines was an issue because they represent a relatively small part of the system as a whole, and as such, each computer was manually configured by a member of the team. This introduced a considerable time sink, and a large margin for human error.

##Environment
For this team, the environment is completely Linux, top to bottom. Every single other component of the product is based on Linux. Deployment solutions were already in place for all other components except this one.

The environment presented a problem as Microsoft has wrapped the deployment and management of Windows in many layers of their own environment. This proved a unique challenge as the budget was literally nonexistent, but an investment of time proved to be enough.

#Components
This is a solution that requires many moving parts to set up, but once configured, the deployment is virtually entirely unattended. You can find documentation of this system in the following folders.

##Imaging
Find info pertaining to the process of capturing and deploying a Windows (WIM) image.

##Netinstall
This folder contains instructions and configuration info pertaining to booting Windows Preinstallation Environment (PE) over the network using a Linux server. The README also points out some caveats involved with doing so on a client in UEFI mode.

##Winpe
This folder contains instructions for creating a Windows live boot medium and tooling it to your needs. It also contains some additional information pertinent to this specific solution.

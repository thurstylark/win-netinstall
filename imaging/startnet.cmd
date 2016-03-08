@echo off
wpeinit
echo Starting Install
timeout 10 /nobreak
net use y: \\192.168.59.1\images guest /user:guest
cd /D y:\sources
setup.exe /unattend:"y:\Autounattend.xml"

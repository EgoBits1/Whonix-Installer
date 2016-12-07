!define APPNAME "Whonix for Windows"
!define COMPANYNAME "Whonix"
!define DESCRIPTION "The easy way to use Whonix on Windows"
# These three must be integers
!define VERSIONMAJOR 13
!define VERSIONMINOR 0
!define VERSIONBUILD 0
# These will be displayed by the "Click here for support information" link in "Add/Remove Programs"
# It is possible to use "mailto:" links in here to open the email client
!define HELPURL "https://forums.whonix.org" # "Support Information" link
!define UPDATEURL "https:/whonix.org/download" # "Product Updates" link
!define ABOUTURL "https://whonix.org" # "Publisher" link
# This is the size (in kB) of all the files copied into "Program Files"
!define INSTALLSIZE 3894304
 
RequestExecutionLevel admin ;Require admin rights on NT6+ (When UAC is turned on)
 
InstallDir "$PROGRAMFILES\${COMPANYNAME}\${APPNAME}"
 
# rtf or txt file - remember if it is txt, it must be in the DOS text format (\r\n)
LicenseData "license.rtf"
# This will be in the installer/uninstaller's title bar
Name "${COMPANYNAME}"
Icon "logo.ico"
BrandingText "Whonix 13"
outFile "Whonix-Installer.exe"

!include LogicLib.nsh
!include x64.nsh
 
# Just three pages - license agreement, install location, and installation
page license
page directory
Page instfiles
 
!macro VerifyUserIsAdmin
UserInfo::GetAccountType
pop $0
${If} $0 != "admin" ;Require admin rights on NT4+
        messageBox mb_iconstop "Administrator rights required!"
        setErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
        quit
${EndIf}
!macroend
 
function .onInit
	setShellVarContext all
	!insertmacro VerifyUserIsAdmin
functionEnd
 
section "install"
	# Files for the install directory - to build the installer, these should be in the same directory as the install script (this file)
	setOutPath $INSTDIR
	# Files added here should be removed by the uninstaller (see section "uninstall")
	File "Whonix.exe"
	File "7za.exe"
	File "virtualbox_x64.msi"
	File "virtualbox_x86.msi"
	File "common.cab"
	File "VBoxManage.exe"
	File "gateway.7z"
	File "workstation.7z"
	File "MahApps.Metro.dll"
	File "System.Windows.Interactivity.dll"
	# Add any other files for the install directory (license files, app data, etc) here
 
	# Uninstaller - See function un.onInit and section "uninstall" for configuration
	writeUninstaller "$INSTDIR\uninstall.exe"
 
	# Start Menu
	createDirectory "$SMPROGRAMS\${COMPANYNAME}"
	createShortCut "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}.lnk" "$INSTDIR\Whonix.exe"
	createShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\Whonix.exe"
 
	# Registry information for add/remove programs
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayName" "${COMPANYNAME} - ${APPNAME} - ${DESCRIPTION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayIcon" "$\"$INSTDIR\logo.ico$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "Publisher" "$\"${COMPANYNAME}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "HelpLink" "$\"${HELPURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "URLUpdateInfo" "$\"${UPDATEURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "URLInfoAbout" "$\"${ABOUTURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayVersion" "$\"${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}$\""
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMinor" ${VERSIONMINOR}
	# There is no option for modifying or repairing the install
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoRepair" 1
	# Set the INSTALLSIZE constant (!defined at the top of this script) so Add/Remove Programs can accurately report the size
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "EstimatedSize" ${INSTALLSIZE}
sectionEnd

Section "Clean VirtualBox"
${If} ${RunningX64}
	nsExec::Exec '"msiexec" /x "$INSTDIR\virtualbox_x64.msi" /quiet'
	${Else}
	nsExec::Exec '"msiexec" /x "$INSTDIR\virtualbox_x86.msi" /quiet'
	${EndIf}
SectionEnd

Section "VirtualBox"
${If} ${RunningX64}
	nsExec::Exec '"msiexec" /i "$INSTDIR\virtualbox_x64.msi" INSTALLDIR="$INSTDIR" /quiet'
${Else}
	nsExec::Exec '"msiexec" /i "$INSTDIR\virtualbox_x86.msi" INSTALLDIR="$INSTDIR" /quiet'
${EndIf}
SectionEnd

Section "Extract"
	nsExec::Exec '"$INSTDIR\7za.exe" x gateway.7z'
	nsExec::Exec '"$INSTDIR\7za.exe" x workstation.7z'
SectionEnd


Section "Import Gateway"
	nsExec::Exec '"$INSTDIR\VBoxManage" import whonix_gateway.ova --vsys 0 --eula accept'
SectionEnd

Section "Import Workstation"
	nsExec::Exec '"$INSTDIR\VBoxManage" import whonix_workstation.ova --vsys 0 --eula accept'
SectionEnd

Section "Remove temporary files"
	delete $INSTDIR\gateway.7z
	delete $INSTDIR\workstation.7z
	delete $INSTDIR\whonix_gateway.ova
	delete $INSTDIR\whonix_workstation.ova
	delete $INSTDIR\7za.exe
SectionEnd

# Uninstaller
 
function un.onInit
	SetShellVarContext all
 
	#Verify the uninstaller - last chance to back out
	MessageBox MB_OKCANCEL "Permanantly remove ${APPNAME}?" IDOK next
		Abort
	next:
	!insertmacro VerifyUserIsAdmin
functionEnd
 
section "uninstall"
 
	# Remove Start Menu launcher
	delete "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}.lnk"
	# Try to remove the Start Menu folder - this will only happen if it is empty
	rmDir "$SMPROGRAMS\${COMPANYNAME}"
	
	#Remove Desktop shorcut
	delete "$DESKTOP\${APPNAME}.lnk"
	
	#Remove virtual drives
	nsExec::Exec '"$INSTDIR\VBoxManage" unregistervm Whonix-Gateway --delete'
	nsExec::Exec '"$INSTDIR\VBoxManage" unregistervm Whonix-Workstation --delete'
	
	#Remove VirtualBox
	${If} ${RunningX64}
	nsExec::Exec '"msiexec" /x "$INSTDIR\virtualbox_x64.msi" /quiet'
	${Else}
	nsExec::Exec '"msiexec" /x "$INSTDIR\virtualbox_x86.msi" /quiet'
	${EndIf}
 
	# Remove files
	delete $INSTDIR\Whonix.exe
	delete $INSTDIR\MahApps.Metro.dll
	delete $INSTDIR\System.Windows.Interactivity.dll
	delete $INSTDIR\common.cab
	delete $INSTDIR\virtualbox_x86.msi
	delete $INSTDIR\virtualbox_x64.msi

	# Always delete uninstaller as the last action
	delete $INSTDIR\uninstall.exe
 
	# Try to remove the install directory - this will only happen if it is empty
	rmDir $INSTDIR
 
	# Remove uninstaller information from the registry
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}"
sectionEnd
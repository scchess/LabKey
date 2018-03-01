NSIS-OS 1.1

Copyright (C) 2001 Robert Rainwater <rrainwater@yahoo.com>

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute
it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented;
   you must not claim that you wrote the original software.
   If you use this software in a product, an acknowledgment in the
   product documentation would be appreciated but is not required.
2. Altered versions must be plainly marked as such,
   and must not be misrepresented as being the original software.
3. This notice may not be removed or altered from any distribution.

OS Version Usage Information
----------------------------
Step 1:
	Call osversion

Step 2:
	The major version is returned to $0 and the minor version
        is returned to $1.  See below for details on version numbers.


OS Platform Usage Information
-----------------------------
Step 1:
	Call osplatform

Step 2:
	The platform is returned into $0.  Possible values
        are: "win31", "win9x", "winnt", and "unknown".


Interpreting The Version Numbers
--------------------------------
Major Version:
  Windows 95 		4
  Windows 98 		4
  Windows Me 		4
  Windows NT 3.51 	3
  Windows NT 4.0 	4
  Windows 2000 		5
  Windows XP 		5
  Windows Server 2003 	5 (including R2 update)
  Windows Vista 	6
  Windows Server 2008   6 (including R2 update)
  Windows 7             6

Minor Version
  Windows 95 		0
  Windows 98 		10
  Windows Me 		90
  Windows NT 3.51 	51
  Windows NT 4.0 	0
  Windows 2000 		0
  Windows XP 32-bit	1
  Windows XP 64-bit 	2
  Windows Server 2003 	2 (including R2 update)
  Windows Server 2008   0
  Windows Server 2k8 R2 1
  Windows Vista 	0
  Windows 7             1

(note: Windows XP x64 and Windows Server 2003 will both return version 5.2)

Example
-------

# Get the OS version
nsisos::osversion
StrCpy $R0 $0
StrCpy $R1 $1

# Check our version
StrCmp $R0 "5" WindowsXPPlatform
StrCmp $R0 "6" WindowsVistaPlatform

WindowXPPlatform:
MessageBox MB_OK|MB_ICONSTOP "Installation failed: Windows XP or earlier not supported."
Abort

WindowVistaPlatform:

Also, see example.nsi
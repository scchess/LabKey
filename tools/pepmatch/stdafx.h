// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#ifdef _MSC_VER
#pragma once

#ifndef _WIN32_WINNT		// Allow use of features specific to Windows XP or later.                   
#define _WIN32_WINNT 0x0501	// Change this to the appropriate value to target other versions of Windows.
#endif						
#ifndef strcasecmp
#define strcasecmp _stricmp
#endif
#endif

#define XML_STATIC // to statically link the expat libraries

#include <stdio.h>
#include <math.h>
#include <vector>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

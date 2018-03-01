// ltqpush.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#define _countof(a) (sizeof(a) / sizeof(a[0]))

const char logName[] = "ms2.log";
const char rawFilter[] = "*.raw";
const char datFilter[] = "*.dat";
const char xmlFilter[] = "*.mzXML";
const char allFilter[] = "*.*";
const char rawDir[] = "raw";
const char datDir[] = "dat";
const char xmlDir[] = "xml";

/////////////////////////////////////////////////////////////////////////////
// Global variables

// Command line options

const char* emailAddr = NULL;
const char* machineType = NULL;
const char* pruneName = NULL;
int pruneLevel = -1;
bool alphabetize = false;
bool xmlout = false;
bool datout = false;

bool convertLocal = false;


typedef void (*AddParamsFunc)(FILE*, const char*);

struct DefSpec
{
	const char* defDir;
	const char* defFile;
	AddParamsFunc defAddParams;
};

void AddCometParams(FILE* out, const char* line)
{
	if (strstr(line, "Database") != NULL ||
			strstr(line, "database") != NULL)
	{
		if (emailAddr != NULL)
			fprintf(out, "EmailAddress = %s@fhcrc.org\r\n", emailAddr);
		if (machineType != NULL)
			fprintf(out, "MassSpecType = %s\r\n", machineType);
	}
}

void AddTandemParams(FILE* out, const char* line)
{
	if (strstr(line, "pipeline, database") != NULL)
	{
		if (emailAddr != NULL)
			fprintf(out, "<note type=\"input\" label=\"pipeline, email address\">%s@fhcrc.org</note>\r\n", emailAddr);
	}
}

DefSpec defSpecs[] =
{
	{"cmt", "comet.def", AddCometParams},
	{"xtan", "tandem.xml", AddTandemParams},
};

const char* skipNames[] = { "std", "blk", "water", "end" };

/////////////////////////////////////////////////////////////////////////////
// Utility functions

void continue_exit(int code)
{
	char inputBuff[2048];
	printf("\nPress ENTER to continue...");
	fgets(inputBuff, _countof(inputBuff), stdin);	
	exit(code);
}

char* pathcat(const char* dir, const char* filter)
{
	int lenDir = strlen(dir);
	char* ret = (char*) malloc(lenDir + strlen(filter) + 2);
	strcpy(ret, dir);
	if (dir[lenDir - 1] != '\\')
		strcat(ret, "\\");
	strcat(ret, filter);
	return ret;
}

bool exist(const char* path)
{
	_finddata_t fd;
	long l = _findfirst(path, &fd);
	if (l == -1)
	{
		return false;
	}
	_findclose(l);

	return true;
}

bool exist_safe(const char* path)
{
	char* pchSlash = strchr(path, '\\');
	char* pchLast = strrchr(path, '\\');

	while (pchSlash != NULL)
	{
		pchSlash = strchr(pchSlash + 1, '\\');
		if (pchSlash == NULL)
			break;
		*pchSlash = '\0';
		char* filterPath =  pathcat(path, allFilter);
		*pchSlash = '\\';

		_finddata_t fd;
		long l = _findfirst(filterPath, &fd);
		free(filterPath);

		if (l == -1)
			return false;
		
		bool found = false;
		do
		{

			if (pchSlash != pchLast && (fd.attrib & _A_SUBDIR) == 0)
				continue;

			if (strncmp(fd.name, pchSlash + 1, strlen(fd.name)) == 0)
			{
				char* pchAfter = (pchSlash + strlen(fd.name) + 1);
				if (*pchAfter == '\\' || *pchAfter == '\0')
				{
					found = true;
					break;
				}
			}
		}
		while (_findnext(l, &fd) == 0);

		_findclose(l);

		if (!found)
		{
			return false;
		}
	}

	return true;
}

bool exist(const char* dir, const char* filter)
{
	char* filterPath = pathcat(dir, filter);
	bool ret = exist(filterPath);
	free(filterPath);
	return ret;
}

bool ensure_dir(const char* dir)
{
	if (dir == NULL || exist(dir))
		return true;

	char* pch = strrchr(dir, '\\');

	// If not in current directory, or at drive root.
	if (pch != NULL && (pch == dir || *(pch - 1) != ':'))
	{
		// Make sure parent exits.
		char* parent = strdup(dir);
		parent[pch - dir] = '\0';

		bool success = ensure_dir(parent);

		free(parent);

		if (!success)
			return false;
	}

	// Create the directory.
	return (_mkdir(dir) == 0 || errno != ENOENT);
}

//
//	Checks for important files
//

bool hasRaw(const char* dir)
{	return exist(dir, rawFilter); }
bool hasDat(const char* dir)
{	return exist(dir, datFilter); }
bool hasXml(const char* dir)
{	return exist(dir, xmlFilter); }
bool hasLog(const char* dir)
{	return exist(dir, logName); }

DefSpec* getDefSpec(const char* dir)
{
	for (int i = 0; i < _countof(defSpecs); i++)
	{
		if (exist(dir, defSpecs[i].defFile))
			return (defSpecs + i);
	}

	return NULL;
}

bool hasDefFile(const char* dir)
{	return (getDefSpec(dir) != NULL); }

bool isSkipName(const char* name)
{
	for (int i = 0; i < _countof(skipNames); i++)
	{
		const char* skip = skipNames[i];
		int len = strlen(skip);
		if (_strnicmp(skip, name, len) == 0)
			return true;
	}

	return false;
}

bool isTest(const char* dir)
{
	int len = strlen(dir);
	return (stricmp(dir + len - 4, "_test") == 0);
}

bool checkedCopy(const char* src, const char* dest)
{
	bool success = false;

	char* destFile = NULL;
	char* destSafe = NULL;
	
	while (!success)
	{
		// Try twice silently.
		for (int i = 0; i < 2 && !success; i++)
		{
			struct _stati64 statSrc, statDest;
			if (_stati64(dest, &statDest) == 0 && statDest.st_mode & _S_IFDIR)
			{
				if (destFile == NULL)
				{
					const char* pch = strrchr(src, '\\');
					if (pch == NULL)
						pch = src;
					else
						pch++;
					dest = destFile = pathcat(dest, pch);
				}
			}
			if (_stati64(src, &statSrc) != 0)
			{
				printf("No stat on %s\n", src);
				continue;
			}

			if (destSafe == NULL)
			{
				destSafe = (char*) malloc(strlen(dest) + 5 + 1);
				strcpy(destSafe, dest);
				strcat(destSafe, ".copy");
			}

			int statSpawn = 0;
			if (statSrc.st_mode & _S_IFDIR)
			{
				statSpawn = _spawnlp(_P_WAIT, "cmd", "/c",
					"xcopy", "/s", "/e", "/i", "/q", "/y",
					src, destSafe, ">nul", "2>nul", NULL);
			}
			else
			{
				statSpawn = _spawnlp(_P_WAIT, "cmd", "/c",
					"copy", src, destSafe, ">nul", "2>nul", NULL);
			}

			if (statSpawn != 0)
			{
				printf("Copy failure.\n");
				continue;
			}
			if (_stati64(destSafe, &statDest) != 0)
			{
				printf("No stat on %s\n", destSafe);
				continue;
			}
			if ((statSrc.st_mode & _S_IFDIR) == 0 &&
					statSrc.st_size != statDest.st_size)
			{
				printf("Size %s (%d) != %s (%d)\n", src, (int) statSrc.st_size,
					destSafe, statDest.st_size);

				// If the file is bad, try to remove it.
				_spawnlp(_P_WAIT, "cmd", "/c",
							"del", destSafe, ">nul", "2>nul", NULL);
				continue;
			}
			
			if (rename(destSafe, dest) != 0)
			{
				printf("Rename from %s to %s failed.\n", destSafe, dest);
				// Try to remove file.
				_spawnlp(_P_WAIT, "cmd", "/c",
							"del", "/s", "/f", destSafe, ">nul", "2>nul", NULL);
				continue;
			}

			success = true;
		}

		// Ask the user to continue trying.
		if (!success)
		{
			char inputBuff[2048];

			printf("\nFailure copying %s to %s.\n", src, dest);
			printf("Try again (y or n)? ");

			fgets(inputBuff, _countof(inputBuff), stdin);

			if (*inputBuff != 'y' && *inputBuff != 'Y')
				break;
		}
	}

	if (destFile != NULL)
		free(destFile);
	if (destSafe != NULL)
		free(destSafe);

	return success;
}

/////////////////////////////////////////////////////////////////////////////
// Gather a list of directories to be converted before doing the
// conversion.  Conversion can take a long time, and this allows
// the list to be built quickly between MS runs.

class DefNode
{
public:
	DefNode(const char* destProcDir, const char* defDir, DefSpec* defSpecStruct,
		DefNode* nextNode)
	{
		destProc = strdup(destProcDir);
		defdir = strdup(defDir);
		defSpec = defSpecStruct;
		next = nextNode;
	}

	~DefNode()
	{
		free((void*)destProc);
		free((void*)defdir);
	}

	int pushDefFile();

	const char* getProcDir()
	{	return destProc; }
	const char* getDefDir()
	{	return defdir; }
	DefSpec* getDefSpec()
	{	return defSpec; }
	DefNode* getNext()
	{   return next; }

private:
	const char* destProc;
	const char* defdir;
	DefSpec* defSpec;
	DefNode* next;
};

class ConvertNode
{
public:
	ConvertNode(const char* srcDir, const char* destDir,
		ConvertNode* nextNode);
	~ConvertNode();

	int process();

	bool hasWork()
	{
		return (defs != NULL || fCopy || fConvert);
	}

	void printWork();

	bool hasIntermediateFiles(const char* path)
	{
		return (xmlout ? hasXml(path) : hasDat(path));
	}

	// Member variable getters.
	//
	const char* getSrc()
	{	return src; }
	const char* getDest()
	{	return dest; }
	DefNode* getDefList()
	{	return defs; }
	ConvertNode* getNext()
	{	return next; }
	void setNext(ConvertNode* node)
	{	next = node; }

private:
	int convert(FILE* log);
	int pushDefs(FILE* log);

	int findDefs();
	int addDef(const char* destProc, const char* defDir, DefSpec* defSpec);
	void freeDefs();

private:
	char* src;
	char* dest;
	char* destRaw;
	char* destInterm;
	bool fExistDest;
	bool fCollision;
	bool fCopy;
	bool fConvert;
	DefNode* defs;
	ConvertNode* next;
};

/////////////////////////////////////////////////////////////////////////////
//	Push analysis definition file to server

int DefNode::pushDefFile()
{
	if (!ensure_dir(destProc))
		return 1;

	bool tempfile = false;
	char* defFile = pathcat(defdir, defSpec->defFile);
	if (!exist(defFile))
		return 1;

	if (emailAddr != NULL || machineType != NULL)
	{
		char* defTemplate = defFile;
		defFile = _tempnam(defdir, "~def");

		// Open the template for reading.
		FILE* tmp = fopen(defTemplate, "rb");
		if (tmp == NULL)
		{
			free(defTemplate);
			free(defFile);
			return 1;
		}

		// Open the output file.
		FILE* out = fopen(defFile, "wb");
		if (out == NULL)
		{
			fclose(tmp);
			free(defTemplate);
			free(defFile);
			return 1;
		}

		tempfile = true;

		// Write output, adding email address.
		char buffer[4096];
		while (fgets(buffer, _countof(buffer), tmp))
		{
			if (fputs(buffer, out) == EOF)
				break;

			defSpec->defAddParams(out, buffer);
		}

		int success = feof(tmp);

		fclose(out);
		fclose(tmp);
		free(defTemplate);

		if (!success)
		{
			_spawnlp(_P_WAIT, "cmd", "/c", "del", defFile, ">nul", "2>nul", NULL);
			free(defFile);
			return 1;
		}
	}

	char* destFile = pathcat(destProc, defSpec->defFile);
	int status = 0;
	if (!checkedCopy(defFile, destFile))
		status = 1;
	if (tempfile)
		_spawnlp(_P_WAIT, "cmd", "/c", "del", defFile, ">nul", "2>nul", NULL);

	
	free(destFile);
	free(defFile);

	return status;
}

/////////////////////////////////////////////////////////////////////////////
//	ConvertNode

ConvertNode::ConvertNode(const char* srcPath, const char* destPath,
						 ConvertNode* nextNode)
{
#ifdef _DEBUG
//	printf("ConvertNode(srcPath=%s, destPath=%s)\n", srcPath, destPath);
#endif

	next = nextNode;
	defs = NULL;
	src = strdup(srcPath);

	dest = strdup(destPath);
	destRaw = strdup(dest);
	destInterm = strdup(dest);

#ifdef _DEBUG
//	printf("	destRaw=%s\n", destRaw);
//	printf("	destInterm=%s\n", destInterm);
#endif

	fCollision = false;
	fExistDest = exist(dest);

	if (fExistDest && !exist_safe(dest))
	{
		fCollision = true;
	}
	else
	{
		findDefs();

		fCopy = !hasRaw(destRaw);
		fConvert = (convertLocal && (defs != NULL) && !hasIntermediateFiles(destInterm));

		if (!fExistDest)
		{
			if (!fCopy || (!fConvert && convertLocal && defs != NULL))
				fCollision = true;
		}
	}

	if (fCollision)
	{
		printf("ERROR: Name collision.\n"
			"Source %s\n"
			"Destination %s\n"
			"The destination directory appears to exist, but is not listed in its parent.\n"
			"This is due to an OS bug.\n"
			"Please try another name.\n\n", src, dest);

		fCopy = false;
		fConvert = false;

		freeDefs();
	}
}

ConvertNode::~ConvertNode()
{
	free((void*)src);
	free((void*)dest);
	free((void*)destRaw);
	free((void*)destInterm);

	freeDefs();
}

void ConvertNode::printWork()
{
	printf("Queue for processing %s\n", src);
	printf("    -Destination %s\n", dest);

	if (fCopy)
		printf("    -Copy .raw files to raw directory\n");

	if (fConvert)
	{
		if (xmlout)
			printf("    -Convert to .mzXML in xml directory\n");
		else
			printf("    -Convert to .dat in dat directory\n");
	}

	for (DefNode* d = defs; d != NULL; d = d->getNext())
	{
		printf("    -Copy %s for search\n        from %s\n        to %s\n",
			d->getDefSpec()->defFile, d->getDefDir(), d->getProcDir());
	}
}

int ConvertNode::findDefs()
{
	// Check for a def in the directory with the .RAW files.
	if (hasDefFile(src))
	{
		printf("WARNING: Analysis definition file found in %s.\n", src);
		printf("	Place all analysis definition files in subdirectories below the .raw files.\n");
	}

	// Recurse into subdirectories.
	_finddata_t fd;

	char* filterPath = pathcat(src, allFilter);
	long l = _findfirst(filterPath, &fd);
	free(filterPath);

	if (l == -1)
	{
		printf("ERROR: Could not find directory %s.\n", src);
		return 1;
	}

	int lenSrc = strlen(src) + 1;
	char* srcSub = (char*) malloc(lenSrc + sizeof(fd.name));
	strcpy(srcSub, src);
	strcat(srcSub, "\\");

	int lenDest = strlen(dest) + 1;
	char* destProcSub = (char*) malloc(lenDest + 50 + sizeof(fd.name));
	strcpy(destProcSub, dest);
	strcat(destProcSub, "\\");

	do
	{
		if ((fd.attrib & _A_SUBDIR) == 0)
			continue;
		else if (strcmp(fd.name, ".") == 0 ||
				strcmp(fd.name, "..") == 0)
			continue;

		strcpy(srcSub + lenSrc, fd.name);

		DefSpec* defSpec = getDefSpec(srcSub);
		if (defSpec == NULL)
			continue;

		strcpy(destProcSub + lenDest, defSpec->defDir);
		strcat(destProcSub, "\\");
		strcat(destProcSub, fd.name);

		addDef(destProcSub, srcSub, defSpec);
	}
	while (_findnext(l, &fd) == 0);

	return 0;
}

int ConvertNode::addDef(const char* destProcDir, const char* defDir, DefSpec* defSpec)
{
	// Add a new node, if the destination does not exist.
	if (!hasDefFile(destProcDir))
		defs = new DefNode(destProcDir, defDir, defSpec, defs);
	else if (!fExistDest)
		fCollision = true;

	return 0;
}

void ConvertNode::freeDefs()
{
	while (defs != NULL)
	{
		DefNode* defFree = defs;
		defs = defs->getNext();
		delete defFree;
	}
}

/////////////////////////////////////////////////////////////////////////////
//	Do the work of conversion from .dat to .raw

int ConvertNode::process()
{
	// Open log file.
	char* logPath = pathcat(src, logName);
	FILE* log = fopen(logPath, "w");
	free(logPath);

	// Write time and date of conversion.
    char timeBuf[128];
	char dateBuf[128];
    _strtime(timeBuf);
    _strdate(dateBuf);
	printf("%s %s\n", timeBuf, dateBuf);
	fprintf(log, "%s %s\n", timeBuf, dateBuf);

	// Write conversion start header.
	printf("Processing %s to %s...\n", src, dest);
	fprintf(log, "Processing %s to %s...\n", src, dest);

	long status = convert(log);
	if (status == 0)
		status = pushDefs(log);

	if (status == 0)
	{
		printf("Success\n");
		fprintf(log, "Success\n");
	}
	else
	{
		printf("Errors\n");
		fprintf(log, "Errors\n");
	}

    _strtime(timeBuf);
    _strdate(dateBuf);
	printf("%s %s\n\n", timeBuf, dateBuf);
	fprintf(log, "%s %s\n\n", timeBuf, dateBuf);

	fclose(log);

	return status;
}

int ConvertNode::convert(FILE* log)
{
	if (!fCopy && !fConvert)
		return 0;

	// Make sure the destination diretory exists.
	bool success = ensure_dir(dest);
	if (fCopy)
		success = success && ensure_dir(destRaw);
	if (fConvert)
		success = success && ensure_dir(destInterm);

	if (!success)
	{
		printf("ERROR: Failed creating destination %s\n", dest);
		fprintf(log, "ERROR: Failed creating destination %s\n", dest);

		fflush(log);
		return 1;
	}

	int status = 0;

	_finddata_t fd;

	// Convert all the .raw files.
	char* filterPath = pathcat(src, rawFilter);
	long l = _findfirst(filterPath, &fd);
	free(filterPath);

	assert(l != 0); // No raw files found.

	int lenSrc = strlen(src) + 1;
	char* srcPath = (char*) malloc(lenSrc + sizeof(fd.name));
	strcpy(srcPath, src);
	strcat(srcPath, "\\");

	const char* convertExe = (xmlout ? "ReAdW.exe" : "XConvert.exe");

	do
	{
		long statSpawn = 0;

		strcpy(srcPath + lenSrc, fd.name);

		if (isSkipName(fd.name))
		{
			if (fCopy)
			{
				// Copy raw file
				printf("Copying %s... ", fd.name);
				fprintf(log, "Copying %s... ", fd.name);

				char* destRawBack = (char*) malloc(strlen(destRaw) + 1 + strlen(fd.name) + 5);
				strcpy(destRawBack, destRaw);
				strcat(destRawBack, "\\");
				strcat(destRawBack, fd.name);
				strcat(destRawBack, ".bak");

				if (!checkedCopy(srcPath, destRawBack))
					statSpawn++;

				free(destRawBack);

				if (statSpawn == 0)
				{
					printf("success\n");
					fprintf(log, "success\n");
				}
				else
				{
					status += statSpawn;
					printf("ERROR\n");
					fprintf(log, "ERROR\n");
				}

			}
			continue;
		}

		printf("Processing %s... ", fd.name);
		fprintf(log, "Processing %s... ", fd.name);

		fflush(log);

		// Need to use "cmd /c" to run XConvert, or it runs and detaches
		// immediately, and then runs as a background process.

		if (fConvert)
		{
			if (fd.attrib & _A_SUBDIR)
			{
				// CONSIDER: exit?
				printf("ERROR: mzXML conversion not supported for %s\n", src);
				fprintf(log, "ERROR: mzXML conversion not supported for %s\n", src);
			}
			else
			{
				printf("convert... ");
				fprintf(log, "convert... ");

				if (xmlout)
				{
					statSpawn += _spawnlp(_P_WAIT,
						"cmd",
						"/c",
						"ReAdW.exe",
						srcPath,
						"p",
						NULL);
				}
				else
				{
					statSpawn += _spawnlp(_P_WAIT,
						"cmd",
						"/c",
						"XConvert.exe",
						"/SL",
						"/DI",
						srcPath,
						"/O",
						src,
						NULL);
				}

				if (!exist(src, (xmlout ? xmlFilter : datFilter)))
				{
					statSpawn++;
				}
			}
		}

		// Convert locally and then copy, because converting to dest
		// was seeing occasional write failures when dest was network
		// drive.

		if (statSpawn == 0)
		{
			printf("copy... ");
			fprintf(log, "copy... ");

			if (fCopy)
			{
				// Copy raw file
				if (!checkedCopy(srcPath, destRaw))
					statSpawn++;
			}

			if (fConvert && statSpawn == 0)
			{
				if (xmlout)
					strcpy(srcPath + (strlen(srcPath) - 3), xmlFilter + 2);
				else
					strcpy(srcPath + (strlen(srcPath) - 3), datFilter + 2);

				// Copy dat/xml file
				if (!checkedCopy(srcPath, destInterm))
					statSpawn++;
			}
		}
		else if (statSpawn == -1)
		{
			status++;
			if (errno == ENOENT)
			{
				printf("\nERROR: %s not found.\nCheck your path.\n", convertExe);
				continue_exit(2);
			}
			else
			{
				// CONSIDER: exit?
				printf("ERROR: Unable to run %s.\n", convertExe);
				fprintf(log, "ERROR: Unable to run %s.\n", convertExe);
			}
		}

		if (statSpawn == 0)
		{
			printf("success\n");
			fprintf(log, "success\n");
		}
		else
		{
			status += statSpawn;
			printf("ERROR\n");
			fprintf(log, "ERROR\n");
		}

		if (fConvert)
		{
			// Remove any leftover .dat files.
			if (xmlout)
				strcpy(srcPath + lenSrc, xmlFilter);
			else
				strcpy(srcPath + lenSrc, datFilter);
			_spawnlp(_P_WAIT, "cmd", "/c",
				"del", "/f", srcPath, ">nul", "2>nul", NULL);
		}

		fflush(log);
	}
	while (_findnext(l, &fd) == 0);

	_findclose(l);
	free(srcPath);

	return status;
}

int ConvertNode::pushDefs(FILE* log)
{
	int status = 0;

	for (DefNode* node = defs; node != NULL; node = node->getNext())
	{
		const char* defdir = node->getDefDir();
		const char* deffile = node->getDefSpec()->defFile;
		if (node->pushDefFile() == 0)
		{
			printf("Copied %s from %s\n", deffile, defdir);
			fprintf(log, "Copied %s from %s\n", deffile, defdir);
		}
		else
		{
			status++;

			printf("ERROR: Unable to copy %s from %s\n\n", deffile, defdir);
			fprintf(log, "ERROR: Unable to copy %s from %s\n", deffile, defdir);
		}
	}

	return status;
}

/////////////////////////////////////////////////////////////////////////////
//	Collect the list of directories to be converted.

ConvertNode* mirror(const char* src, const char* dest, int level,
					ConvertNode* convertList)
{
	// If this directory has .raw files, then it is a leaf directory.
	if (hasRaw(src))
	{
		char* pch = strchr(src, ' ');

		if (pch != NULL)
		{
			printf("WARNING: Skipping path with spaces %s.\n", src);
		}
		else
		{
			ConvertNode* node = new ConvertNode(src, dest, convertList);
			if (node->hasWork())
			{
				node->printWork();
				return node;
			}
		}

		// printf("Skipping %s\n", src);
		return convertList;
	}

	// Recurse into subdirectories.
	_finddata_t fd;

	char* filterPath = pathcat(src, allFilter);
	long l = _findfirst(filterPath, &fd);
	free(filterPath);

	if (l == -1)
	{
		printf("ERROR: Could not find source directory %s.\n", src);
		continue_exit(2);
	}

	int lenSrc = strlen(src) + 1;
	int lenDest = strlen(dest) + 1;
	char* srcSub = (char*) malloc(lenSrc + sizeof(fd.name));
	strcpy(srcSub, src);
	strcat(srcSub, "\\");
	char* destSub = NULL;
	if (pruneLevel == level && pruneName != NULL)
	{
		lenDest += strlen(pruneName) + 1;
		destSub = (char*) malloc(lenDest + sizeof(fd.name));
		strcpy(destSub, dest);
		strcat(destSub, "\\");
		strcat(destSub, pruneName);
		strcat(destSub, "\\");
	}
	else
	{
		destSub = (char*) malloc(lenDest + sizeof(fd.name));
		strcpy(destSub, dest);
		strcat(destSub, "\\");
	}

	do
	{
		if ((fd.attrib & _A_SUBDIR) == 0)
			continue;
		else if (strcmp(fd.name, ".") == 0 ||
				strcmp(fd.name, "..") == 0)
			continue;

		strcpy(srcSub + lenSrc, fd.name);

		int lenDestAppend = lenDest;
		if (alphabetize && level == 0)
		{
			destSub[lenDestAppend++] = fd.name[0];
			destSub[lenDestAppend++] = '\\';
		}
		strcpy(destSub + lenDestAppend, fd.name);

		convertList = mirror(srcSub, destSub, level + 1, convertList);			
	}
	while (_findnext(l, &fd) == 0);

	_findclose(l);
	free(srcSub);
	free(destSub);

	return convertList;
}

void main(int argc, char* argv[])
{
	char* src = NULL;
	char* dest = NULL;

	bool usage = false;

	for (int i = 1; i < argc; i++)
	{
		char* pch = argv[i];
		if (*pch == '/' || *pch == '-')
		{
			pch++;
			if ((*pch == 'E' || *pch == 'e') && *(pch + 1) == '\0')
			{
				i++;
				if (i < argc)
					emailAddr = argv[i];
				else 
					usage = true;
				continue;
			}
			else if ((*pch == 'M' || *pch == 'm') && *(pch + 1) == '\0')
			{
				i++;
				if (i < argc)
					machineType = argv[i];
				else 
					usage = true;
				continue;
			}
			else if ((*pch == 'L' || *pch == 'l') && *(pch + 1) == '\0')
			{
				i++;
				if (i < argc)
					pruneLevel = atoi(argv[i]);
				else 
					usage = true;
				continue;
			}
			else if ((*pch == 'P' || *pch == 'p') && *(pch + 1) == '\0')
			{
				i++;
				if (i < argc)
					pruneName = argv[i];
				else 
					usage = true;
				continue;
			}
			else if ((*pch == 'A' || *pch == 'a') && *(pch + 1) == '\0')
			{
				alphabetize = true;
				continue;
			}			
			else if ((*pch == 'X' || *pch == 'x') && *(pch + 1) == '\0')
			{
				xmlout = true;
				convertLocal = true;
				if (datout)
					usage = true;
				continue;
			}
			else if ((*pch == 'D' || *pch == 'd') && *(pch + 1) == '\0')
			{
				datout = true;
				convertLocal = true;
				if (xmlout)
					usage = true;
				continue;
			}
		}

		if (src == NULL)
			src = argv[i];
		else if (dest == NULL)
			dest = argv[i];
		else
			usage = true;
	}
	
	if (pruneLevel != -1 && pruneName == NULL)
		usage = true;
	else if (pruneLevel == -1 && pruneName != NULL)
		usage = true;

	if (usage || src == NULL || dest == NULL)
	{
		printf("USAGE: %s [/a] [/e <email address>] [/m <machine type>]\n", argv[0]);
		printf("\t\t[/x | /d] [/l <prune-level> /p <prune-name>]\n");
		printf("\t\t<source dir> <dest dir>\n");
		printf("\tMirrors the directory structure in <source dir>\n");
		printf("\tto <dest dir>, and converts any .raw files found\n");
		printf("\tin <src dir> to .dat files in <dest dir>.\n");
		printf("\n");
		printf("\tOptions:\n");
		printf("\t/a - Prepends an alpha directory to dest path.\n");
		printf("\t/e - Adds an email address to analysis definition files.\n");
		printf("\t/m - Adds a machine type to analysis definition files.\n");
		printf("\t/x - Conversion to .mzXML done locally.\n");
		printf("\t/d - Conversion to .dat done locally.\n");
		printf("\t/l - Directory level at which to insert a named directory.\n");
		printf("\t/p - Named directory to insert.\n");
		continue_exit(1);
	}

	// Remove trailing backslashes, if present.
	int last = strlen(src) - 1;
	if (src[last] == '\\')
		src[last] = '\0';
	last = strlen(dest) - 1;
	if (dest[last] == '\\')
		dest[last] = '\0';


	if (!exist(src))
	{
		printf("ERROR: Source directory %s not found.\n", src);
		continue_exit(1);
	}
	if (!exist(dest))
	{
		printf("ERROR: Destination directory %s not found.\n", dest);
		continue_exit(1);
	}

	int status = 0;

	char inputBuff[2048];

	ConvertNode* convertList = mirror(src, dest, 0, NULL);
	if (convertList == NULL)
	{
		printf("Destination is up to date.\n");
	}
	else
	{
		printf("\nBegin processing (y or n)? ");

		fgets(inputBuff, _countof(inputBuff), stdin);

		if (*inputBuff != 'y' && *inputBuff != 'Y')
			exit(0);

		// Reverse the list, so processing happens in directory list order.
		ConvertNode* newList = NULL;
		while (convertList != NULL)
		{
			ConvertNode* node = convertList->getNext();
			convertList->setNext(newList);
			newList = convertList;
			convertList = node;
		}
		convertList = newList;

		// Convert everything.
		while (convertList != NULL)
		{
			ConvertNode* node = convertList;
			convertList = convertList->getNext();

			status += node->process();

			delete node;
		}
	}

	continue_exit(status);
}

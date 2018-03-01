#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <algorithm>
#include <vector>
#include <math.h>
#include <assert.h>
#define null 0

#include "FloatImage.h"
#include "VectorUtil.h"


void usage()
	{
	printf("bin2tsv peaks.bin -o peaks.tsv\n");
	exit(1);
	}



extern "C" int __cdecl main(int argc, char *argv[])
	{
	char *fileIn = null;
	char *fileOut = null;
	FILE *in = stdin;
	FILE *out = stdout;

	for (int i=1 ; i<argc ; i++)
		{
		char *option = argv[i];
		if (option[0] != '-')
			{
			if (null == fileIn)
				fileIn = argv[i];
			continue;
			}
		switch (option[1])
			{
		case 'o': 
			if (++i < argc)
				{
				if (null == fileOut)
					fileOut = argv[i];
				}
			break;
		case '?':
		case '-':
			usage();
			break;
			}
		}
	if (null == fileIn)
	   _setmode( _fileno(stdin), _O_BINARY );
	else
		{
		in = fopen(fileIn, "rb");
		if (null == in)
			{
			fprintf(stderr, "could not open file %s\n", fileIn);
			exit(1);
			}
		}

	FloatImage *img = FloatImage::create();
	img->loadBinary(in);
	if (stdin != in)
		fclose(in);

	if (null != fileOut)
		{
		out = fopen(fileOut, "w");
		if (null == out)
			{
			fprintf(stderr, "could not open file %s\n", fileOut);
			exit(1);
			}
		}

	char *captions[3] = {"scan","mz","score"};
	img->saveText(out, true, null);
	if (null != out && stdin != out)
		fclose(out);

	delete img;

	return 0;
}
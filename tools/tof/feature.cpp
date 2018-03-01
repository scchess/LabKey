#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <float.h>
#include <algorithm>
#include <vector>
#include <math.h>
#include <memory>
#include <assert.h>
#define null 0

int verbose = false;

#include "common.h"


extern "C" int __cdecl main(int argc, char *argv[])
	{
	double n = -1.0;
	double p = 1.0;

	char *fileIn = null;
	char *fileOut = null;
	FILE *in = stdin;
	FILE *out = stdout;
	float yblur=0.0f, xblur=0.0f;

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
		case 'x': 
			if (++i < argc)
				{
				sscanf(argv[i],"%f",&xblur);
				}
			break;
		case 'y': 
			if (++i < argc)
				{
				sscanf(argv[i],"%f",&yblur);
				}
			break;
		case 'v':
			verbose = true;
			break;
		case '?':
		case '-':
			usage();
			break;
			}
		}

	if (null == fileIn)
		usage();
	if (null == fileOut)
		usage();

	in = fopen(fileIn, "rb");
	if (null == in)
		{
		fprintf(stderr, "could not open file %s\n", fileIn);
		exit(1);
		}

	std::vector<DataPoint> *v = load(in, 0.0);
	if (stdin != in)
		fclose(in);

	out = fopen(fileOut, "wb");
	if (null == out)
		{
		fprintf(stderr, "could not open file %s\n", fileOut);
		exit(1);
		}

	int minScan = (*v)[0].scan;
	int maxScan = (*v)[v->size()-1].scan;
	if (verbose)
		printf("minScan %d maxScan %d\n", minScan, maxScan);

	sortbymass(v);

	float minMass = (*v)[0].mz;
	float maxMass = (*v)[v->size()-1].mz;
	if (verbose)
		printf("minMass %f maxMass %f\n", minMass, maxMass);

	std::vector<DataPoint> &points = *v;
	DataPoint point;

	for (int i = 0 ; i < points.size() ; ) // for each scan
		{
		DataPoint *first = &points[i];
		int select = 0;
		for ( ; i < points.size() && first->scan == points[i].scan ; i++)
			select |= (points[i].i > 100);
		DataPoint *last = &points[i];

		if (!select)
			continue;
		fwrite(&point, sizeof(DataPoint), last-first, out);
		}

	if (null != out && stdin != out)
		fclose(out);
	return 0;
	}
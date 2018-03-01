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

#include "fftw3.h"

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

	std::vector<DataPoint> *v = load(in, 10.0F);
	if (stdin != in)
		fclose(in);

	out = fopen(fileOut, "wb");
	if (null == out)
		{
		fprintf(stderr, "could not open file %s\n", fileOut);
		exit(1);
		}

	sortbyscan(v);

	int minScan = (*v)[0].scan;
	int maxScan = (*v)[v->size()-1].scan;
	if (verbose)
		printf("minScan %d maxScan %d\n", minScan, maxScan);

	sortbymass(v);

	float minMass = (*v)[0].mz;
	float maxMass = (*v)[v->size()-1].mz;
	if (verbose)
		printf("minMass %f maxMass %f\n", minMass, maxMass);

	int size = (maxScan+1);
	int filterlen = 2*(size/2+1);
	double sigma = xblur * filterlen/2;

	Filter *fgauss = _gaussian(sigma, filterlen/2);
	Filter *fcomplex = new Filter(filterlen, 0);
	for (int x=0 ; x<filterlen/2 ; x++)
		(*fcomplex)[2*x] = (*fcomplex)[2*x+1] = (*fgauss)[x];

	/*
	FloatVector row(size+1);
	FloatVector freq(2*(size/2+1));
	fftwf_plan decompose   = fftwf_plan_dft_r2c_1d(size, &row[0], (fftwf_complex *)&freq[0], 0);
	fftwf_plan reconstruct = fftwf_plan_dft_c2r_1d(size, (fftwf_complex *)&freq[0], &row[0], 0);

	std::vector<DataPoint> &points = *v;
	DataPoint point;

	for (int i = 0 ; i < points.size() ; ) // for each row
		{
		memset(&row[0], 0, row.size() * sizeof(float));
		point.mz = points[i].mz;
		if (verbose)
			printf("mz = %f\n", point.mz);

		for ( ; i < points.size() && point.mz == points[i].mz ; i++)
			row[points[i].scan] = points[i].i;
		fftwf_execute(decompose);

		// don't I have a helper for this?
		for (unsigned x=0 ; x<freq.size() ; x++)
			{
			float f = freq[x] * (*fcomplex)[x];
			if (isdenormal(f)) f = 0.0f;
			freq[x] = f;
			}
		
		fftwf_execute(reconstruct);
		for (point.scan = 1 ; point.scan <= size ; point.scan++)
			{
			point.i = row[point.scan]/size;
			if (point.i < 1.0f) 
				continue;
			fwrite(&point, sizeof(DataPoint), 1, out);
			}
		}
	*/

	FloatVector row(size+2);
	FloatVector freq(2*(size/2+1));
	fftwf_plan decompose   = fftwf_plan_dft_r2c_1d(size, &row[0], (fftwf_complex *)&freq[0], 0);
	fftwf_plan reconstruct = fftwf_plan_dft_c2r_1d(size, (fftwf_complex *)&freq[0], &row[0], 0);

	std::vector<DataPoint> &points = *v;
	DataPoint point;

	for (int i = 0 ; i < points.size() ; ) // for each row
		{
		memset(&row[0], 0, row.size() * sizeof(float));
		point.mz = points[i].mz;
		if (verbose)
			printf("mz = %f\n", point.mz);

		for ( ; i < points.size() && point.mz == points[i].mz ; i++)
			row[points[i].scan] = points[i].i;

		for (unsigned x=1 ; x<=size ; x++)
			row[x] = (row[x-1]+row[x]+row[x]+row[x+1])/4.0;

		for (point.scan = 1 ; point.scan <= row.size() ; point.scan++)
			{
			point.i = row[point.scan];
			if (point.i < 1.0f) 
				continue;
			fwrite(&point, sizeof(DataPoint), 1, out);
			}
		}

	if (null != out && stdin != out)
		fclose(out);
	return 0;
	}

#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <stdlib.h>
#include <math.h>
#include <algorithm>
#include <vector>

#include "BmpFile.h"
#include "FloatImage.h"
#define null 0


void usage()
	{
	printf("bin2bmp ms1.bin -o ms1.bmp\n");
	printf("\t-t <threshold>\n");
	printf("\t-l\tplot log values\n");
	printf("-r -g -b\tred green blue\n");
	exit(1);
	}


class BMPIter: public ImageIter
	{
	public: FloatImage *_bmp;
	public: int _width;
	public: int _height;
	public: double _min;
	public: double _max;
	public: double _scale;
	public: double _offset;
	public: bool _bNegativeValues;
	public: bool _bLog;

	public: BMPIter(int width, int height, FloatImage *bmp, double min, double max, bool bNegativeValues, bool bLog)
		{
		_width = width; _height = height; _bmp = bmp;
		_min = min; _max = max; _bNegativeValues = bNegativeValues, _bLog = bLog;
		if (bNegativeValues)
			{
			_offset = 0.5;
			_scale = 0.5 / max;
			}
		else
			{
			_offset = 0;
			_scale = 1.0 / (max - min);
			}
		}

	public: virtual void next(int x, int y, float &f) 
		{
		int sign = 1;
		if (f == 0)
			_bmp->set(x,y,(float)_offset);
		else
			{
			sign = f<0 ? -1 : 1;
            f = fabs(f);
			if (_bLog) f = log(f+1);
			double s = _offset + sign * (f-_min) * _scale;
			_bmp->set(x,y,(float)s);
			}
		}
	};



//extern "C" int __cdecl wmain(int argc, wchar_t *argv[])
extern "C" int __cdecl main(int argc, char *argv[])
	{
	float yscale = 1.0;
	float threshold = -1;
	
	char *fileIn = null;
	char *fileOut = null;
	FILE *in = stdin;
	FILE *out = stdout;
	bool bLog = false;
	RGBQUAD white  = {255, 255, 255, 0}; // B G R
	RGBQUAD black  = {0, 0, 0, 0};
	RGBQUAD red    = {255, 0, 0, 0};
	RGBQUAD green  = {0, 255, 0, 0};
	RGBQUAD blue   = {0, 0, 255, 0};
	RGBQUAD loColor = white;
	RGBQUAD hiColor = black;

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
			case 't':
				if (++i < argc)
					{
					sscanf(argv[i],"%f",&threshold);
					}
				break;
			case 'l':
				bLog = true;
				break;
			case 'r':
				hiColor = red;
				break;
			case 'g':
				hiColor = green;
				break;
			case 'b':
				hiColor = blue;
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
			fprintf(stderr, "could not open file: %s\n", fileIn);
			exit(1);
			}
		}

	if (null == fileOut)
		_setmode( _fileno(stdout), _O_BINARY );
	else
		{
		out = fopen(fileOut, "wb");
		if (null == out)
			{
			fprintf(stderr, "could not open file: %s\n", fileOut);
			exit(1);
			}
		}

	FloatImage *img = FloatImage::create();
	img->loadBinary(in);

	std::pair<float,float> range = img->minmax();
	bool fNegativeValues = range.first < 0;

	printf("input values: [%f,%f]\n", range.first, range.second);
	if (fNegativeValues)
		printf("dynamic range: %4.2lf\n", log(range.second+1)+log(-range.first+1));
	else
		printf("dynamic range: %4.2lf\n", log(range.second+1)-log(range.first+1));

	double min = range.first;
	double max = range.second;
	if (fNegativeValues)
		{
		min = 0; //std::min(range.first,-1 * range.second);
		max = std::max(-1*range.first, range.second);
		}
	else 
		{
		min = (-1==threshold) ? range.first : threshold;
		max = range.second;
		}

	std::vector<int> *histogram = img->histogram();
	double sum=0;
	for (int i=0 ; i<(int)histogram->size() ; i++)
		{
		double range = pow(10.0,i/10.0);
		sum += range * (*histogram)[i];
		}

	// dynamically set high cut-off
	double cutoffsum = sum * 0.01;
	double s = 0.0;
	for (int i=histogram->size() ; i-->0 ; )
		{
		s += pow(10.0,i/10.0) * (*histogram)[i];
		if (s > cutoffsum)
			{
			max = pow(10.0,i/10.0);
			break;
			}
		}

	//dynamically set low cut-off
	s = 0.0;
	if (!fNegativeValues && -1 == threshold)
	for (int i=0 ; i<(int)histogram->size() ; i++)
		{
		s += pow(10.0,i/10.0) * (*histogram)[i];
		if (s > cutoffsum)
			{
			min = pow(10.0,((double)i+1)/10.0);
			break;
			}
		}
	printf("compressed dynamic range: %4.2lf\n", log(max)- log(std::max(1.0, min)));

	int width = (img->getWidth()|0x001f)+1;
	int height = img->getHeight();
	if (bLog)
		{
		min = log(min+1);
		max = log(max+1);
		}

	FloatImage *bitmap = FloatImage::create();
	bitmap->setWidth(img->getWidth());
	bitmap->setHeight(img->getHeight());
	BMPIter iter(width, height, bitmap, min, max, fNegativeValues, bLog);
	img->Iterate(&iter);

	delete img;

	BMPFile *bmpFile = new BMPFile();
	bmpFile->SaveBMP(out, bitmap, loColor, hiColor);

	free(bitmap);
	if (null != in && stdin != in)
		fclose(in);
	if (null != out && stdout != out)
		fclose(out);

	return 0;
	}

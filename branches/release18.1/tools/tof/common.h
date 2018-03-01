class DoubleVector : public std::vector<double> 
	{
	typedef std::vector<double> superClass;
	public: DoubleVector(size_t len) : 
			superClass(len) //, 0.0, DoubleAllocator())
		{
		}
	};

class FloatVector : public std::vector<float> 
	{
	typedef std::vector<float> superClass;
	public: FloatVector(size_t len) : 
			superClass(len) // , 0.0f, FloatAllocator())
		{
		}
	};



void usage()
	{
	printf("bin2bmp ms1.bin -o ms1_blur.bin\n");
	printf("\t-x width\n");
	printf("\t-y height\n");
	exit(1);
	}


float median(float *array, int length)
	{
	float window[5];
	memcpy(window, array, 5 * sizeof(float));
	std::sort(window, window+5);
	return window[2];
	}


size_t fsize(FILE *f)
	{
	size_t start = ftell(f);
	fseek(f,0,SEEK_END);
	size_t pos = ftell(f);
	fseek(f,start,SEEK_SET);
	return pos;
	}


struct Filter
	{
	public: Filter(int length, int offset) : 
			_v(length), _offset(offset)
		{
		}
	public: float& operator [](int x)
		{
		return _v[x];
		}
	private: size_t _offset;		// v.size()/2 (v.size() is odd)
	private: FloatVector _v;
	public: FloatVector &v() { return _v; }
	public: size_t length() { return _v.size(); }
	public: size_t offset() { return _offset; };
	};


struct DataPoint
	{
	int scan;
	float mz;
	float i;
	};


struct CompareMass
	{
	int operator()(DataPoint &a, DataPoint &b)
		{
		if (a.mz == b.mz)
			return a.scan < b.scan;
		return a.mz < b.mz;
		}
	};

struct CompareScan
	{
	int operator()(DataPoint &a, DataPoint &b)
		{
		if (a.scan == b.scan)
			return a.mz < b.mz;
		return a.scan < b.scan;
		}
	};


std::vector<DataPoint> *load(FILE *fpIn, float minIntensity)
	{
	size_t size = fsize(fpIn);
	size_t len = size/sizeof(DataPoint);
	std::vector<DataPoint> *v = new std::vector<DataPoint>(len);

	DataPoint *p = &(*v)[0];
	if (0.0F == minIntensity)
		{
		fread(p, sizeof(DataPoint), len, fpIn);
		}
	else
		{
		while (fread(p, sizeof(DataPoint), 1, fpIn))
			{
			if (p->i >= minIntensity)
				p++;
			}
		len = p - &(*v)[0];
		v->resize(len);
		}

	if (verbose)
		printf("read %d points\n", len);
	return v;
	}


inline void sortbymass(std::vector<DataPoint> *v)
	{
	struct CompareMass Pr;
	std::sort(&(*v)[0], &(*v)[v->size()], Pr);
	if (verbose)
		printf("sorted %d points\n", v->size());
	}


inline void sortbyscan(std::vector<DataPoint> *v)
	{
	struct CompareScan Pr;
	std::sort(&(*v)[0], &(*v)[v->size()], Pr);
	if (verbose)
		printf("sorted %d points\n", v->size());
	}


inline int isdenormal(double d)
	{
	//return _fpclass(d) == _FPCLASS_PD;
	return 0 == (*(__int64 *)&d & 0x7ff0000000000000);
	}

static Filter *_gaussian(float sigma, int length)
	{
	Filter *filter = new Filter(length, 0);

	FloatVector &v = filter->v();
	for (int n = 0; n < length ; n++)
		{
		double d = exp(-0.5 * (n * n) / sigma);
		// if (_fpclass(f) == _FPCLASS_PD) break;
		if (isdenormal(d))
			break;
		v[n] = (float)d;
		}
	return filter;
	}



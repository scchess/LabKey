// InspectResultsParser.h
//     Handles parsing of msInspect results, and adding pepXML information
//     as extra columns.

class PepResultsParser;

class InspectResultsParser
{
public:
	InspectResultsParser()
	{
	}

	void setPeptides(PepResultsParser* parser)
	{
		peptides = parser;
	}

	void setInputFile(const char* fileName)
	{
		inputFile = fileName;
	}

	void setOutputFile(const char* fileName)
	{
		outputFile = fileName;
	}

	bool parse();

protected:
	class Feature
	{
	public:
		Feature()
		{
			clear();
		}

		Feature(const Feature& rhs)
		{
			*this = rhs;
		}

		void clear()
		{
			scan = 0;
			rt = 0.0;
			mz = 0.0;
			accurate = false;
			mass = 0.0;
			intensity = 0.0;
			charge = 0;
			charge_states = 0;
			kl = 0.0;
			background = 0.0;
			median = 0.0;
			peaks = 0;
			first_scan = 0;
			last_scan = 0;
			scan_count = 0;
			total_int = 0.0;
		}

		Feature& operator=(const Feature& rhs)
		{
			scan = rhs.scan;
			rt = rhs.rt;
			mz = rhs.mz;
			accurate = rhs.accurate;
			mass = rhs.mass;
			intensity = rhs.intensity;
			charge = rhs.charge;
			charge_states = rhs.charge_states;
			kl = rhs.kl;
			background = rhs.background;
			median = rhs.median;
			peaks = rhs.peaks;
			first_scan = rhs.first_scan;
			last_scan = rhs.last_scan;
			scan_count = rhs.scan_count;
			total_int = rhs.total_int;

			return *this;
		}

        int scan;
        double rt;
        double mz;
        bool accurate;
        double mass;
        double intensity;
        int charge;
        int charge_states;
        double kl;
        double background;
        double median;
        int peaks;
        int first_scan;
        int last_scan;
		int scan_count;
		double total_int;
        double sum_squares_dist;
	};

protected:
	PepResultsParser* peptides;

	string inputFile;
	string outputFile;
};

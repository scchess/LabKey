// PeakabooResultsParser.h
//     Handles parsing of peakaboo results, and adding pepXML information
//     as an extra tag.

#include "saxhandler.h"

class PepResultsParser::SpectrumQuery;

class PeakabooResultsParser : public SAXHandler
{
public:
	class PeakFamily
	{
	public:
		PeakFamily()
		{
			clear();
		}

		PeakFamily(const PeakFamily& rhs)
		{
			*this = rhs;
		}

		void clear()
		{
			line = 0;
			scanNumber = 0;
			charge = 0;
			retentionTime = 0.0;
			mzMonoisotopic = 0.0;
		}

		PeakFamily& operator=(const PeakFamily& rhs)
		{
			line = rhs.line;
			scanNumber = rhs.scanNumber;
			charge = rhs.charge;
			retentionTime = rhs.retentionTime;
			mzMonoisotopic = rhs.mzMonoisotopic;

			return *this;
		}

		void setSpectrumQueryBest(PepResultsParser::SpectrumQuery* spectrumQuery)
		{
			spectrumQueryBest = spectrumQuery;
		}

		int line;
		int scanNumber;
		int charge;
		double retentionTime;
		double mzMonoisotopic;
		PepResultsParser::SpectrumQuery* spectrumQueryBest;
	};

public:
	PeakabooResultsParser()
	{
		state = NULL;
	}

	void setPeptides(PepResultsParser* parser)
	{
		peptides = parser;
	}

	void setOutputFile(const char* fileName)
	{
		outputFile = fileName;
	}

	bool parse();

protected:
	static bool lessThanSpectrumQueryBest(const PeakFamily& l, const PeakFamily& r);
	static bool lessThanPeakFamilyLine(const PeakFamily& l, const PeakFamily& r);

protected:
	virtual void startElement(const XML_Char *el, const XML_Char **attr);
	virtual void endElement(const XML_Char *el);

	void startScan(const XML_Char **attr);
	void startPeakFamily(const XML_Char **attr);

protected:
    vector<PeakFamily> vPeakFamilies;

	PeakFamily peakFamilyCur;

	PepResultsParser* peptides;

	string outputFile;

	const char* state;
};

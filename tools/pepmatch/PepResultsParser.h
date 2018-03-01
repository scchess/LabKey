// PepResultsParser.h
//     Handles parsing of pepXML output file for correlation with msInspect features.

#include "saxhandler.h"

class PepResultsParser : public SAXHandler
{
public:
	class SpectrumQuery
	{
	public:
		SpectrumQuery()
		{
			clear();
		}

		SpectrumQuery(const SpectrumQuery& rhs)
		{
			*this = rhs;
		}

		void clear()
		{
			start_scan = 0;
			end_scan = 0;
			assumedCharge = 0;
			precursorNeutralMass = 0.0;
			prophetProbability = 0.0;
		}

		SpectrumQuery& operator=(const SpectrumQuery& rhs)
		{
			start_scan = rhs.start_scan;
			end_scan = rhs.end_scan;
			assumedCharge = rhs.assumedCharge;
			precursorNeutralMass = rhs.precursorNeutralMass;
			prophetProbability = rhs.prophetProbability;

			return *this;
		}

		double getMZ()
		{
			const double dProtonMass = 1.007276;

			return (precursorNeutralMass / assumedCharge) + dProtonMass;
		}

		int start_scan;
		int end_scan;
		int assumedCharge;
		double precursorNeutralMass;
		double prophetProbability;
	};

public:
	PepResultsParser()
	{
		mzWindow = 1.0;
		minProb = 0.0;
		matchCharge = false;

		state = NULL;
	}

	SpectrumQuery* getBestMatchSpectrum(int start_scan, int end_scan, int charge, double mz);

	void setMZWindow(double window)
	{
		mzWindow = window;
	}

	void setMinProb(double min)
	{
		minProb = min;
	}

	void setMatchCharge(bool match)
	{
		matchCharge = match;
	}

	bool parse();

protected:
	static bool lessThanSpectrumQuery(const SpectrumQuery& l, const SpectrumQuery& r)
	{
		return (l.start_scan < r.start_scan);
	}

protected:
	vector<SpectrumQuery>::iterator binSearch(vector<SpectrumQuery>::iterator l,
		vector<SpectrumQuery>::iterator r, int start_scan)
	{
		// Look for the first scan that is greater than the start_scan.

		// Empty
		if (l == r)
			return r;

		// Only one left
		if (l + 1 == r)
			return l;

		vector<SpectrumQuery>::iterator m = l + ((r - l) / 2);

		// If less than, then what we are looking for has to be on the right side.
		if (m->start_scan < start_scan)
			return binSearch(m + 1, r, start_scan);

		// If greater than, this could be it, or it could be to the left, so
		// look left, and then walk forward if necessary.
		if (m->start_scan > start_scan)
			m = binSearch(l, m, start_scan);

		// Walk forward to the first value greater than the given start scan.
		while (m < r && m->start_scan <= start_scan)
			m++;

		return m;
	}

	virtual void startElement(const XML_Char *el, const XML_Char **attr);
	virtual void endElement(const XML_Char *el);

	void startSpectrumQuery(const XML_Char **attr);
	void endSpectrumQuery();
	void startProphet(const XML_Char **attr);

protected:
	double mzWindow;
	double minProb;
	bool matchCharge;

    vector<SpectrumQuery> vSpectrumQueries;

	SpectrumQuery spectrumCur;

	const char* state;
};

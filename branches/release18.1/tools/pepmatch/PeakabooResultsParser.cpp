// PeakabooResultsParser.cxx
//     Handles parsing of peakable results, and adding pepXML information
//     as an extra tag.

#include "stdafx.h"

#include "PepResultsParser.h"
#include "PeakabooResultsParser.h"

static const char EL_SCAN[] = "scan";
static const char EL_PEAK_FAMILIES[] = "peakFamilies";
static const char EL_PEAK_FAMILY[] = "peakFamily";

bool PeakabooResultsParser::lessThanSpectrumQueryBest(const PeakFamily& l, const PeakFamily& r)
{
	if (l.spectrumQueryBest == NULL)
		return false;
	else if (r.spectrumQueryBest == NULL)
		return true;
	else if (l.spectrumQueryBest->start_scan != r.spectrumQueryBest->start_scan)
		return l.spectrumQueryBest->start_scan < r.spectrumQueryBest->start_scan;
	else if (l.spectrumQueryBest->assumedCharge != r.spectrumQueryBest->assumedCharge)
		return l.spectrumQueryBest->assumedCharge < r.spectrumQueryBest->assumedCharge;
	else
		return l.spectrumQueryBest->precursorNeutralMass < l.spectrumQueryBest->precursorNeutralMass;
}

bool PeakabooResultsParser::lessThanPeakFamilyLine(const PeakFamily& l, const PeakFamily& r)
{
	return (l.line < r.line);
}

bool PeakabooResultsParser::parse()
{
	bool ret = SAXHandler::parse();

	int lineIn = 0;

	FILE* pfIn = fopen(m_strFileName.data(), "r");
	if (pfIn == NULL)
	{
		cerr << "Failed to open input file '" << m_strFileName << "'.\n";
		return false;
	}
	
	ostream* pOut = &cout;

	ofstream ofOut;
	if (outputFile != "")
	{
		ofOut.open(outputFile.data(),
			ios_base::out | ios_base::trunc | ios_base::binary);
		if (!ofOut.is_open())
		{
			cerr << "Failed to open " << outputFile << " for write.\n";
			return false;
		}

		pOut = &ofOut;
	}

	ostream& rOut = *pOut;

	char buffer[8192];
	char bufferVal[1024];

	vector<PeakFamily>::iterator it = vPeakFamilies.begin();
	vector<PeakFamily>::iterator end = vPeakFamilies.end();

	while (it != end)
	{
		it->setSpectrumQueryBest(peptides->getBestMatchSpectrum(it->scanNumber,
			it->scanNumber + 7, it->charge, it->mzMonoisotopic));

		it++;
	}

	// Get rid of duplicates
	it = vPeakFamilies.begin();
	vector<PeakFamily>::iterator itBest = it;
	
	sort(it, end, lessThanSpectrumQueryBest);

	while (it != end)
	{
		if (it != itBest)
		{
			if (it->spectrumQueryBest == itBest->spectrumQueryBest)
				it->setSpectrumQueryBest(NULL);
			else
				itBest = it;
		}

		it++;
	}

	// Rewrite the peaks.xml
	it = vPeakFamilies.begin();

	sort(it, end, lessThanPeakFamilyLine);

	while (fgets(buffer, sizeof(buffer), pfIn) != NULL)
	{
		lineIn++;

		if (it != end && it->line + 1 == lineIn)
		{
			PepResultsParser::SpectrumQuery* spectrum = it->spectrumQueryBest;
			if (spectrum != NULL)
			{
				char* pch = buffer;
				while (isspace(*pch))
					rOut << *pch++;
				sprintf(bufferVal, "%.04f", spectrum->prophetProbability);
				rOut << "<ms2Match scan=\"" << spectrum->start_scan << "\" probability=\"" << bufferVal << "\"/>\n";
			}
			it++;
		}

		rOut << buffer;
	}

	bool success = true;

	if (ferror(pfIn))
	{
		cerr << "ERROR: Failed reading msInspect feature file '" << m_strFileName << "'.\n";
		success = false;
	}

	fclose(pfIn);

	if (ofOut.is_open())
		ofOut.close();

	return success;

	return ret;
}

void PeakabooResultsParser::startElement(const XML_Char *el, const XML_Char **attr)
{
	if (state == NULL)
	{
		if (isElement(EL_SCAN, el))
			startScan(attr);
	}
	else if (state == EL_SCAN)
	{
		if (isElement(EL_PEAK_FAMILIES, el))
			state = EL_PEAK_FAMILIES;
	}
	else if (state == EL_PEAK_FAMILIES)
	{
		if (isElement(EL_PEAK_FAMILY, el))
			startPeakFamily(attr);
	}
}

void PeakabooResultsParser::endElement(const XML_Char *el)
{
	if (state == EL_PEAK_FAMILY)
	{
		if (isElement(EL_PEAK_FAMILY, el))
			state = EL_PEAK_FAMILIES;
	}
	else if (state == EL_PEAK_FAMILIES)
	{
		if (isElement(EL_PEAK_FAMILIES, el))
			state = EL_SCAN;
	}
	else if (state == EL_SCAN)
	{
		if (isElement(EL_SCAN, el))
			state = NULL;
	}
}

void PeakabooResultsParser::startScan(const XML_Char **attr)
{
	state = EL_SCAN;

	// Reset all values
	peakFamilyCur.clear();

	// Look for values on this tag.  Other values on child tags.
	for (int i = 0; attr[i]; i += 2)
	{
		const char* name = attr[i];
		const char* value = attr[i + 1];

		if (isAttr("scanNumber", name))
		{
			peakFamilyCur.scanNumber = atoi(value);
		}
		else if (isAttr("retentionTime", name))
		{
			peakFamilyCur.retentionTime = atof(value);
		}
	}
}

void PeakabooResultsParser::startPeakFamily(const XML_Char **attr)
{
	state = EL_PEAK_FAMILY;

	// Look for values on this tag.  Other values on child tags.
	for (int i = 0; attr[i]; i += 2)
	{
		const char* name = attr[i];
		const char* value = attr[i + 1];

		if (isAttr("charge", name))
		{
			peakFamilyCur.charge = atoi(value);
		}
		else if (isAttr("mzMonoisotopic", name))
		{
			peakFamilyCur.mzMonoisotopic = atof(value);
		}
	}

	peakFamilyCur.line = XML_GetCurrentLineNumber(m_parser);

	vPeakFamilies.push_back(peakFamilyCur);
}

// PepResultsParser.cxx
//     Handles parsing of pepXML output file for correlation with msInspect features.

#include "stdafx.h"

#include "PepResultsParser.h"

static const char EL_SPECTRUM_QUERY[] = "spectrum_query";
static const char EL_SEARCH_RESULT[] = "search_result";
static const char EL_SEARCH_HIT[] = "search_hit";
static const char EL_ANALYSIS_RESULT[] = "analysis_result";
static const char EL_PEPTIDEPROPHET_RESULT[] = "peptideprophet_result";

PepResultsParser::SpectrumQuery* PepResultsParser::getBestMatchSpectrum(int start_scan, int end_scan, int charge, double mz)
{
	vector<SpectrumQuery>::iterator end = vSpectrumQueries.end();
	vector<SpectrumQuery>::iterator it = binSearch(vSpectrumQueries.begin(), end, start_scan);

	vector<SpectrumQuery>::iterator best = end;
	vector<SpectrumQuery>::iterator bestCharge = end;
	double mzDeltaBest = 10000.0;

	while (it < end && it->start_scan < end_scan)
	{
		if (minProb > 0.0 || it->prophetProbability >= minProb)
		{
			double mzDelta = fabs(mz - it->getMZ());
			if (mzDelta <= mzWindow && mzDelta <= mzDeltaBest)
			{
				if (mzDelta < mzDeltaBest)
					best = it;
				else if (it->prophetProbability > best->prophetProbability)
					best = it;

				if (best->assumedCharge == charge)
					bestCharge = best;

				mzDeltaBest = mzDelta;
			}
		}

		it++;
	}

	if (best == end)
		return NULL;

	if (best->assumedCharge != charge)
	{
		if (matchCharge)
		{
			// Warn if this promotes a worse match to be used
			if (bestCharge != end)
			{
				cerr << "WARNING: forcing charge match over best match.\n"
					 << "         Feature starting at " << start_scan << " has charge " << charge << "\n"
					 << "         Discarding peptide match at " << bestCharge->start_scan
							<< " has charge " << best->assumedCharge << ", probability " << best->prophetProbability << "\n"
					<< "         Using peptide match at " << bestCharge->start_scan
							<< " has charge " << bestCharge->assumedCharge << ", probability " << bestCharge->prophetProbability << "\n";
			}
			best = bestCharge;
		}
		else
		{
			cerr << "WARNING: mismatched charge.\n"
				 << "         Feature starting at " << start_scan << " has charge " << charge << "\n"
				 << "         Peptide match at " << best->start_scan << " has charge " << best->assumedCharge << "\n";
		}
	}

	return &(*best);
}

bool PepResultsParser::parse()
{
	bool ret = SAXHandler::parse();

	sort(vSpectrumQueries.begin(), vSpectrumQueries.end(), lessThanSpectrumQuery);

	return ret;
}

void PepResultsParser::startElement(const XML_Char *el, const XML_Char **attr)
{
	if (state == NULL)
	{
		if (isElement(EL_SPECTRUM_QUERY, el))
			startSpectrumQuery(attr);
	}
	else if (state == EL_SPECTRUM_QUERY)
	{
		if (isElement(EL_SEARCH_RESULT, el))
			state = EL_SEARCH_RESULT;
	}
	else if (state == EL_SEARCH_RESULT)
	{
		if (isElement(EL_SEARCH_HIT, el))
			state = EL_SEARCH_HIT;
	}
	else if (state == EL_SEARCH_HIT)
	{
		if (isElement(EL_ANALYSIS_RESULT, el))
			state = EL_ANALYSIS_RESULT;
	}
	else if (state == EL_ANALYSIS_RESULT)
	{
		if (isElement(EL_PEPTIDEPROPHET_RESULT, el))
			startProphet(attr);
	}
}

void PepResultsParser::endElement(const XML_Char *el)
{
	if (state == EL_SPECTRUM_QUERY)
	{
		if (isElement(EL_SPECTRUM_QUERY, el))
			endSpectrumQuery();
	}
	else if (state == EL_SEARCH_RESULT)
	{
		if (isElement(EL_SEARCH_RESULT, el))
			state = EL_SPECTRUM_QUERY;
	}
	else if (state == EL_SEARCH_HIT)
	{
		if (isElement(EL_SEARCH_HIT, el))
			state = EL_SEARCH_RESULT;
	}
	else if (state == EL_ANALYSIS_RESULT)
	{
		if (isElement(EL_ANALYSIS_RESULT, el))
			state = EL_SEARCH_HIT;
	}
	else if (state == EL_PEPTIDEPROPHET_RESULT)
	{
		if (isElement(EL_PEPTIDEPROPHET_RESULT, el))
			state = EL_ANALYSIS_RESULT;
	}
}

void PepResultsParser::endSpectrumQuery()
{
	vSpectrumQueries.push_back(spectrumCur);
	state = NULL;
}

void PepResultsParser::startSpectrumQuery(const XML_Char **attr)
{
	state = EL_SPECTRUM_QUERY;

	// Reset all values
	spectrumCur.clear();

	// Look for values on this tag.  Other values on child tags.
	for (int i = 0; attr[i]; i += 2)
	{
		const char* name = attr[i];
		const char* value = attr[i + 1];

		if (isAttr("start_scan", name))
		{
			spectrumCur.start_scan = atoi(value);
		}
		else if (isAttr("end_scan", name))
		{
			spectrumCur.end_scan = atoi(value);
		}
		else if (isAttr("assumed_charge", name))
		{
			spectrumCur.assumedCharge = atoi(value);
		}
		else if (isAttr("precursor_neutral_mass", name))
		{
			spectrumCur.precursorNeutralMass = atof(value);
		}
	}
}

void PepResultsParser::startProphet(const XML_Char **attr)
{
	state = EL_PEPTIDEPROPHET_RESULT;

	// Look for values on this tag.  Other values on child tags.
	for (int i = 0; attr[i]; i += 2)
	{
		const char* name = attr[i];
		const char* value = attr[i + 1];

		if (isAttr("probability", name))
		{
			spectrumCur.prophetProbability = atof(value);
		}
	}
}

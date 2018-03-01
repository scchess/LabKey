// InspectResultsParser.cxx
//     Handles parsing of msInspect results, and adding pepXML information
//     as extra columns.

#include "stdafx.h"

#include "PepResultsParser.h"
#include "InspectResultsParser.h"

static char* prepareAppend(char* buffer)
{
	size_t len = strlen(buffer);
	if (buffer[len - 1] == '\n')
		buffer[--len] = '\0';
	if (buffer[len - 1] == '\r')
		buffer[--len] = '\0';
	buffer[len++] = '\t';
	buffer[len++] = '\0';
	return buffer;
}

bool InspectResultsParser::parse()
{
	int lineIn = 0;

	FILE* pfIn = fopen(inputFile.data(), "r");
	if (pfIn == NULL)
	{
		cerr << "Failed to open input file '" << inputFile << "'.\n";
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

	Feature feature;

	char buffer[8192];
	char bufferVal[1024];

	while (fgets(buffer, sizeof(buffer), pfIn) != NULL)
	{
		lineIn++;

		if (buffer[0] != '#')
			break;

		rOut << buffer;
	}

    bool hasSumSquares = strstr(buffer, "\tsumSquaresDist") > 0;

	rOut << prepareAppend(buffer) << "MS2scan\tMS2charge\tprobability\n";

	while (fgets(buffer, sizeof(buffer), pfIn) != NULL)
	{
		lineIn++;

		feature.clear();

        int n;
        if (hasSumSquares)
        {
            n = sscanf(buffer, "%d\t%lf\t%lf\t%s\t%lf\t%lf\t%d\t%d\t%lf\t%lf\t%lf\t%d\t%d\t%d\t%d\t%lf\t%lf\t%s",
						&feature.scan,
						&feature.rt,
						&feature.mz,
						bufferVal,
						&feature.mass,
						&feature.intensity,
						&feature.charge,
						&feature.charge_states,
						&feature.kl,
						&feature.background,
						&feature.median,
						&feature.peaks,
						&feature.first_scan,
						&feature.last_scan,
						&feature.scan_count,
						&feature.total_int,
                        &feature.sum_squares_dist);
        }
        else
        {
            n = sscanf(buffer, "%d\t%lf\t%lf\t%s\t%lf\t%lf\t%d\t%d\t%lf\t%lf\t%lf\t%d\t%d\t%d\t%d\t%lf\t%s",
						&feature.scan,
						&feature.rt,
						&feature.mz,
						bufferVal,
						&feature.mass,
						&feature.intensity,
						&feature.charge,
						&feature.charge_states,
						&feature.kl,
						&feature.background,
						&feature.median,
						&feature.peaks,
						&feature.first_scan,
						&feature.last_scan,
						&feature.scan_count,
						&feature.total_int);
        }
		if (strcasecmp("true", bufferVal) == 0)
			feature.accurate = true;

		PepResultsParser::SpectrumQuery* spectrum = peptides->getBestMatchSpectrum(feature.first_scan,
			feature.last_scan + 7, feature.charge, feature.mz);

		rOut << prepareAppend(buffer);
		if (spectrum == NULL)
			rOut << "\t\t";
		else
		{
			sprintf(bufferVal, "%.04f", spectrum->prophetProbability);
			rOut << spectrum->start_scan << "\t" << spectrum->assumedCharge << "\t" << bufferVal;
		}
		rOut << "\n";
	}

	bool success = true;

	if (ferror(pfIn))
	{
		cerr << "ERROR: Failed reading msInspect feature file '" << inputFile << "'.\n";
		success = false;
	}

	fclose(pfIn);

	if (ofOut.is_open())
		ofOut.close();

	return success;
}

// pepmatch.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include "PepResultsParser.h"
#include "InspectResultsParser.h"
#include "PeakabooResultsParser.h"

void usage(char* argv[])
{
	cerr << "Usage: " << argv[0] << " <pepXML file> <feature file> [options]\n";
	cerr << "       -o<output file> - writes to the specified output file.\n";
	cerr << "       -w<window>      - filters on the specified mz-delta window. (default 1.0)\n";
	cerr << "       -p<min>         - minimum PeptideProphet probability to match.\n"
		<<  "                           (default 0.0 - everything)\n";
	cerr << "       -c              - discard matches where pepXML assumed charge\n";
	cerr << "                         does not match MS1 data\n";
	exit(EXIT_FAILURE);
}

int main(int argc, char* argv[])
{
	if (argc < 3)
		usage(argv);


	double mzWindow = 1.0;
	double minProb = 0.0;	// Include everything, even -1, -2, -3...
	bool matchCharge = false;
	string pepxml = argv[1];
	string features = argv[2];
	string output;

	for (int i = 3; i < argc; i++)
	{
		char* arg = argv[i];
		if (arg[0] != '-')
			usage(argv);
		else if (arg[1] == 'o')
			output = arg + 2;
		else if (arg[1] == 'w')
			mzWindow = atof(arg + 2);
		else if (arg[1] == 'p')
			minProb = atof(arg + 2);
		else if (arg[1] == 'c')
			matchCharge = true;
		else
			usage(argv);
	}

	PepResultsParser pepResults;
	pepResults.setFileName(pepxml.data());
	pepResults.setMZWindow(mzWindow);
	pepResults.setMinProb(minProb);
	pepResults.setMatchCharge(matchCharge);
	if (!pepResults.parse())
		exit(EXIT_FAILURE);

	if (strcmp(features.data() + features.length() - 4, ".tsv") == 0)
	{
		InspectResultsParser inspectResults;
		inspectResults.setInputFile(features.data());
		inspectResults.setOutputFile(output.data());
		inspectResults.setPeptides(&pepResults);
		if (!inspectResults.parse())
			exit(EXIT_FAILURE);
	}
	else if (strcmp(features.data() + features.length() - 4, ".xml") == 0)
	{
		PeakabooResultsParser peakResults;
		peakResults.setFileName(features.data());
		peakResults.setOutputFile(output.data());
		peakResults.setPeptides(&pepResults);
		if (!peakResults.parse())
			exit(EXIT_FAILURE);
	}

	return 0;
}


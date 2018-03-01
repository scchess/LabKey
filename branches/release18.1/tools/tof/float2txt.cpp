#include <stdio.h>
#include <stdlib.h>


#ifndef FLT_MAX
#define FLT_MAX         3.402823466e+38F
#endif

#define null 0


struct DataPoint
   {
   int scan;
   float mz;
   float i;
   };


void convert(FILE *fpIn, FILE *fpOut, int minScan, int maxScan, double minMZ, double maxMZ)
   {
   DataPoint data;

   while (fread(&data,sizeof(data),1,fpIn))
      {
      if (data.scan >= minScan && data.scan <= maxScan && (double)data.mz >= minMZ && (double)data.mz <= maxMZ)
	      fprintf(fpOut, "%d\t%.4f\t%.1f\n", data.scan, data.mz, data.i);
      }
   }



int main(int argc, char *argv[])
   {
   int minScan = 0;
   int maxScan = 0x7ffffff;
   double minMZ = 0.00;
   double maxMZ = FLT_MAX;

   FILE *fpIn = null;
   FILE *fpOut = stdout;

   for (int i=1 ; i<argc ; i++)
      {
      char *arg = argv[i];
      if (arg[0] != '-')
         {
         if (fpIn == null)
         	{
            fpIn = fopen(arg, "rb");
         	}
         else
            fpOut = fopen(arg, "w");
         }
      else
         {
         if (arg[1] == 'm')
            {
            float f = atof(argv[i+1]);
            i++;
            minMZ = (double)f - 0.00001;
            maxMZ = (double)f + 0.00001;
            }
         else if (arg[1] == 's')
            {
            int s = atoi(argv[i+1]);
            i++;
            minScan = s;
            maxScan = s;
            }
         }
      }

   convert(fpIn, fpOut, minScan, maxScan, minMZ, maxMZ);
   return 0;
   }

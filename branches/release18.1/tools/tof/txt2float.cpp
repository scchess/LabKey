#include <stdio.h>
#include <stdlib.h>


void convert(FILE *fpIn, FILE *fpOut, double minMZ, double maxMZ, double minIntensity)
   {
   char buf[1024];

   struct _foo
      {
      int scan;
      float mz;
      float i;
      } data;
   
   while (fgets(buf,1024,fpIn))
      {
      switch (buf[0])
         {
         case 'S':
            sscanf(buf, "Scan %ld", &data.scan);
            break;
            
         case '0':
         case '1':
         case '2':
         case '3':
         case '4':
         case '5':
         case '6':
         case '7':
         case '8':
         case '9':
            sscanf(buf, "%f\t%f", &data.mz, &data.i);
            if (data.mz < minMZ || data.mz > maxMZ)
               continue;
			if (data.i < minIntensity)
				continue;
            fwrite(&data, sizeof(data), 1, fpOut);
            break;
            
         case 'R':
         case '\n':
         case '\r':
         default:
            break;
         }
      }
   }


int main(int argc, char *argv[])
   {
   FILE *fpIn = fopen(argv[1],"r");
   FILE *fpOut = fopen(argv[2],"ab");

   double min = 450.0;
   double max = 2000.0;

   if (argc > 3)
	   min = atof(argv[3]);
   if (argc > 4)
	   max = atof(argv[4]);

   convert(fpIn, fpOut, min, max, 3.0);
   return 0;
   }
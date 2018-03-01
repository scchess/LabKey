#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char *argv[])
	{
	char chars[] = "abcdefghijkmnopqrstuvwyzABCDEFGHJKLMNPQRSTUVWXYZ123456789";
	srand( (unsigned)time(NULL) );

	int len = 0;
	if (argc > 1)
		len = atoi(argv[1]);
	if (len < 1)
		len = 8;
	
	int i;
	for (i=0 ; i<len ; i++)
		{
		int r = rand() % (sizeof(chars)-1);
		char c = chars[r];
		putc(c,stdout);
		}
	putc('\n',stdout);
	}


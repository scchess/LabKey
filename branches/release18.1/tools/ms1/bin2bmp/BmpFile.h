#define WIDTHBYTES(bits)    (((bits) + 31) / 32 * 4)
#define BMP_HEADERSIZE (3 * 2 + 4 * 12)
#define BMP_BYTESPERLINE (width, bits) ((((width) * (bits) + 31) / 32) * 4)
#define BMP_PIXELSIZE(width, height, bits) (((((width) * (bits) + 31) / 32) * 4) * height)

typedef long LONG;
typedef unsigned short WORD;
typedef unsigned long DWORD;
typedef unsigned int UINT;
typedef unsigned char BYTE;

typedef struct tagRGBQUAD {
        BYTE    rgbBlue;
        BYTE    rgbGreen;
        BYTE    rgbRed;
        BYTE    rgbReserved;
} RGBQUAD;

class FloatImage;

#include <pshpack2.h>
typedef struct tagBITMAPFILEHEADER {
        WORD    bfType;
        DWORD   bfSize;
        WORD    bfReserved1;
        WORD    bfReserved2;
        DWORD   bfOffBits;
} BITMAPFILEHEADER;
#include <poppack.h>

typedef struct tagBITMAPINFOHEADER{
        DWORD      biSize;
        LONG       biWidth;
        LONG       biHeight;
        WORD       biPlanes;
        WORD       biBitCount;
        DWORD      biCompression;
        DWORD      biSizeImage;
        LONG       biXPelsPerMeter;
        LONG       biYPelsPerMeter;
        DWORD      biClrUsed;
        DWORD      biClrImportant;
} BITMAPINFOHEADER;

class BMPFile
{
public:
	// parameters
	char *m_errorText;
	DWORD m_bytesRead;

public:

	// operations

	BMPFile();

	BYTE * LoadBMP(char *fileName, UINT *width, UINT *height);

	void SaveBMP(char *fileName,		// output path
			BYTE * buf,				// RGB buffer
			UINT width,				// size
			UINT height);

	void SaveBMP(char *fileName, 			// output path
			BYTE * colormappedbuffer,	// one BYTE per pixel colomapped image
			UINT width,
			UINT height,
 			int bitsperpixel,			// 1, 4, 8
			int colors,				// number of colors (number of RGBQUADs)
			RGBQUAD *colormap);			// array of RGBQUADs 

	void SaveBMP(FILE *fp,
			BYTE * colormappedbuffer,	// one BYTE per pixel colomapped image
			UINT width,
			UINT height,
 			int bitsperpixel,			// 1, 4, 8
			int colors,				// number of colors (number of RGBQUADs)
			RGBQUAD *colormap);			// array of RGBQUADs 

	void BMPFile::SaveBMP(
			FILE *fp,
			BYTE * colormappedbuffer,	// one BYTE per pixel colomapped image
			UINT width,
			UINT height,
			RGBQUAD color);

	void BMPFile::SaveBMPbw(
			FILE *fp,
			BYTE * colormappedbuffer,	// one BYTE per pixel colomapped image
			UINT width,
			UINT height)
		{
		RGBQUAD color;
		color.rgbReserved = 0;
		color.rgbBlue = color.rgbRed = color.rgbGreen = 255;
		SaveBMP(fp, colormappedbuffer, width, height, color);
		}


	void BMPFile::SaveBMP(
			FILE *fp,
			FloatImage *img,
			RGBQUAD loColor,
			RGBQUAD hiColor);
	};
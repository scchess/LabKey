//	bmpops.cpp : implementation of the BMPFile class
//	
//	This handles the reading and writing of BMP files.
//
//
#include <stdio.h>
#include <algorithm>
#include <vector>
#include "FloatImage.h"
#include "BmpFile.h"


BMPFile::BMPFile()
{
	m_errorText="OK";
}


////////////////////////////////////////////////////////////////////////////
//	write a 24-bit BMP file
//
//	image MUST be a packed buffer (not DWORD-aligned)
//	image MUST be vertically flipped !
//	image MUST be BGR, not RGB !
//

void BMPFile::SaveBMP(char *fileName,		// output path
							BYTE * buf,		// BGR buffer
							UINT width,		// pixels
							UINT height)
{
	short res1=0;
    short res2=0;
    long pixoff=54;
    long compression=0;
    long cmpsize=0;
    long colors=0;
    long impcol=0;
	char m1='B';
	char m2='M';

	m_errorText="OK";

	DWORD widthDW = WIDTHBYTES(width * 24);

	long bmfsize=sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) +
  							widthDW * height;	
	long byteswritten=0;

	BITMAPINFOHEADER header;
  	header.biSize=40; 						// header size
	header.biWidth=width;
	header.biHeight=height;
	header.biPlanes=1;
	header.biBitCount=24;					// RGB encoded, 24 bit
	header.biCompression=0;					// no compression
	header.biSizeImage=0;
	header.biXPelsPerMeter=0;
	header.biYPelsPerMeter=0;
	header.biClrUsed=0;
	header.biClrImportant=0;

	FILE *fp;	
	fp=fopen(fileName,"wb");
	if (fp==NULL) {
		m_errorText="Can't open file for writing";
		return;
	}

	// should probably check for write errors here...
	
	fwrite((BYTE  *)&(m1),1,1,fp); byteswritten+=1;
	fwrite((BYTE  *)&(m2),1,1,fp); byteswritten+=1;
	fwrite((long  *)&(bmfsize),4,1,fp);	byteswritten+=4;
	fwrite((int  *)&(res1),2,1,fp); byteswritten+=2;
	fwrite((int  *)&(res2),2,1,fp); byteswritten+=2;
	fwrite((long  *)&(pixoff),4,1,fp); byteswritten+=4;

	fwrite((BITMAPINFOHEADER *)&header,sizeof(BITMAPINFOHEADER),1,fp);
	byteswritten+=sizeof(BITMAPINFOHEADER);
	
	long row=0;
	long rowidx;
	long row_size;
	row_size=header.biWidth*3;
    long rc;
	for (row=0;row<header.biHeight;row++) {
		rowidx=(long unsigned)row*row_size;						      

		// write a row
		rc=fwrite((void  *)(buf+rowidx),row_size,1,fp);
		if (rc!=1) {
			m_errorText="fwrite error\nGiving up";
			break;
		}
		byteswritten+=row_size;	

		// pad to DWORD
		for (DWORD count=row_size;count<widthDW;count++) {
			char dummy=0;
			fwrite(&dummy,1,1,fp);
			byteswritten++;							  
		}

	}
           
	fclose(fp);
}



void BMPFile::SaveBMP(
		FILE *fp,
		BYTE * colormappedbuffer,	// one BYTE per pixel colomapped image
		UINT width,
		UINT height,
		int bitsperpixel,			// 1, 4, 8
		int colors,				// number of colors (number of RGBQUADs)
		RGBQUAD *colormap)			// array of RGBQUADs 
{
	int datasize, cmapsize, byteswritten, row, col;

	m_errorText="OK";

	if (bitsperpixel == 24) {
		// the routines could be combined, but i don't feel like it
		m_errorText="We don't do 24-bit files in here, sorry";
		return;
	} else
		cmapsize = colors * 4;

	datasize = BMP_PIXELSIZE(width, height, bitsperpixel);

	long filesize = BMP_HEADERSIZE + cmapsize + datasize;
	int res1, res2;
	res1 = res2 = 0;

	long pixeloffset = BMP_HEADERSIZE + cmapsize;

	int bmisize = 40;
	long cols = width;
	long rows = height;
	WORD planes = 1;
	long compression =0;
	long cmpsize = datasize;
	long xscale = 0;
	long yscale = 0;
	long impcolors = colors;

	char bm[2];
	bm[0]='B';
	bm[1]='M';

	// header stuff
	BITMAPFILEHEADER bmfh;
	bmfh.bfType=*(WORD *)&bm; 
    bmfh.bfSize= filesize; 
    bmfh.bfReserved1=0; 
    bmfh.bfReserved2=0; 
    bmfh.bfOffBits=pixeloffset; 

	fwrite(&bmfh, sizeof (BITMAPFILEHEADER), 1, fp);


	BITMAPINFOHEADER bmih;
	bmih.biSize = bmisize; 
	bmih.biWidth = cols; 
	bmih.biHeight = rows; 
	bmih.biPlanes = planes; 
	bmih.biBitCount = bitsperpixel;
	bmih.biCompression = compression; 
	bmih.biSizeImage = cmpsize; 
	bmih.biXPelsPerMeter = xscale; 
	bmih.biYPelsPerMeter = yscale; 
	bmih.biClrUsed = colors;
	bmih.biClrImportant = impcolors;
	
	fwrite(&bmih, sizeof (BITMAPINFOHEADER), 1, fp);

	if (cmapsize) {
		int i;
		for (i = 0; i< colors; i++) {
			putc(colormap[i].rgbRed, fp);
			putc(colormap[i].rgbGreen, fp);
			putc(colormap[i].rgbBlue, fp);
			putc(0, fp);	// dummy
		}
	}

	byteswritten = BMP_HEADERSIZE + cmapsize;

	if (bitsperpixel == 8 && planes == 1 && width%32 == 0)
	{
		fwrite(colormappedbuffer, 1, datasize, fp);
	}
	else
	{
		for (row = 0; row< (int)height; row++) {
			int pixbuf = 0;
			int nbits = 0;

			for (col =0 ; col < (int)width; col++) {
				int offset = row * width + col;	// offset into our color-mapped RGB buffer
				BYTE pval = *(colormappedbuffer + offset);

				pixbuf = (pixbuf << bitsperpixel) | pval;

				nbits += bitsperpixel;

				if (nbits > 8) {
					m_errorText="Error : nBits > 8????";
					fclose(fp);
					return;
				}

				if (nbits == 8) {
					putc(pixbuf, fp);
					pixbuf=0;
					nbits=0;
					byteswritten++;
				}
			} // cols

			if (nbits > 0) {
				putc(pixbuf, fp);		// write partially filled byte
				byteswritten++;
			}

			// DWORD align
			while ((byteswritten -pixeloffset) & 3) {
				putc(0, fp);
				byteswritten++;
			}
		}	//rows
	}

	if (byteswritten!=filesize) {
		m_errorText="byteswritten != filesize";
	}

	fclose(fp);
}


// monochrome
void BMPFile::SaveBMP(
		FILE *fp,
		BYTE * colormappedbuffer,	// one BYTE per pixel colomapped image
		UINT width,
		UINT height,
		RGBQUAD color)
{
	RGBQUAD colormap[256];
	for (int i=0;i<256;i++)
	{
		colormap[i].rgbBlue = ((int)color.rgbBlue*i/255)*i;
		colormap[i].rgbRed = ((int)color.rgbRed*i/255)*i;
		colormap[i].rgbGreen = ((int)color.rgbGreen*i/255)*i;
		colormap[i].rgbReserved = 0;
	}
	SaveBMP(fp, colormappedbuffer, width, height, 8, 256, colormap);
}


// monochrome
void BMPFile::SaveBMP(
		FILE *fp,
		FloatImage *image,
		RGBQUAD loColor,
		RGBQUAD hiColor)
{
	RGBQUAD colormap[256];
	for (int i=0;i<256;i++)
	{
		colormap[i].rgbBlue  = loColor.rgbBlue  + ((int)hiColor.rgbBlue  - (int)loColor.rgbBlue ) * i / 255;
		colormap[i].rgbRed   = loColor.rgbRed   + ((int)hiColor.rgbRed   - (int)loColor.rgbRed  ) * i / 255;
		colormap[i].rgbGreen = loColor.rgbGreen + ((int)hiColor.rgbGreen - (int)loColor.rgbGreen) * i / 255;
		colormap[i].rgbReserved = 0;
	}

	int width = image->getWidth();
	int height = image->getHeight();
	unsigned char *buf = new unsigned char[width * height];
	for (int y=0 ; y<height ; y++)
		for (int x=0 ; x<width ; x++)
			{
			float f = image->get(x,y);
			buf[y*width + x] = std::min(255,std::max(0,(int)(f*255.0)));
			}
	SaveBMP(fp, buf, width, height, 8, 256, colormap);
	delete[] buf;
}

/**************************************************************************************
**
**  Copyright (c) 1999-2011 VisualSonics Inc. All Rights Reserved.
**
**  VsiBModeRAW.c
**
**	Description:
**		Example code demonstrating the extraction and processing of B-Mode RAW data
**
**	Revision: 1.0 Original
**	Revision: 1.1 Enabled 8 bit raw data sets
**
***************************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <math.h>
#include "..\include\VsiHelper.h"
#include "..\include\VsiXmlHelper.h"
#include "..\include\VsiImageHelper.h"
#include "..\include\VsiBFrameHelper.h"

int main(int argc, char* argv[])
{
	FILE *pFile = NULL;
	VSI_RF_FILE_HEADER rfHeader = {0};
	VSI_RF_FRAME_HEADER rfFrameHeader = {0};

	unsigned int dwCount;

	char pszFileName[1024];
	unsigned char *pbtFrameData = NULL;
	unsigned char *pbtProcessData = NULL;
	unsigned char *pbtProcessTranspose = NULL;
	unsigned char *pbtProcessResample = NULL;

	int iSamples;
	int iLines;
	int iFrameSize;
	int iProcessSize;
	int i8BitRawData;
	double dbYOffset;
	double dbVOffset;
	double dbDynRange;
	double dbDelay;
	double dbWidth;
	double dbDepth;
	double dbHeight;

	int iXResOut;
	int iYResOut;

	// Check for number of arguments
	if(argc != 4)
	{
		printf("\n\nVsiBModeRAW Copyright (c) 1999-2011 VisualSonics Inc.\n");
		printf("VsiBModeRAW.exe <Data.raw.bmode> <Data.raw.xml> <OutputPrefix>\n");

		return 0;
	}

	// Read xml parameters
	{
		char *pszDataFormat;
		int iDataFormatResult;
		double dbScale;
		char *pszXmlFileData = ReadXmlFile(argv[2]);

		// Read and check data format
		pszDataFormat = ReadXmlString(pszXmlFileData, "Data-Format");
		iDataFormatResult = strncmp(pszDataFormat, "RAW", 2);
		if(iDataFormatResult != 0)
		{
			printf("Only 'RAW' data is supported in this example.\n");
			exit(1);
		}

		// Read required data types for processing
		iSamples = ReadXmlInt(pszXmlFileData, "B-Mode/Samples");
		iLines = ReadXmlInt(pszXmlFileData, "B-Mode/Lines");


		dbYOffset = ReadXmlDouble(pszXmlFileData, "B-Mode/Y-Offset");
		dbVOffset = ReadXmlDouble(pszXmlFileData, "B-Mode/V-Offset");
		dbDynRange = ReadXmlDouble(pszXmlFileData, "B-Mode/Display-Range");

		dbDelay = ReadXmlDouble(pszXmlFileData, "B-Mode/Depth-Offset");
		dbDepth = ReadXmlDouble(pszXmlFileData, "B-Mode/Depth");
		dbWidth = ReadXmlDouble(pszXmlFileData, "B-Mode/Width");

		// Height is depth minus delay
		dbHeight = dbDepth - dbDelay;

		// Calculate output resolution to generate image of correct dimensions
		iYResOut = iSamples;

		dbScale = dbWidth / dbHeight;
		iXResOut = (int)(dbScale * iSamples + 0.5);

		// Calculate size of frame
		iFrameSize = (iSamples * iLines * sizeof(float)) + (iLines * sizeof(unsigned int));
		iProcessSize = iSamples * iLines;

		// Allocate memory for frames
		pbtFrameData = (unsigned char *)malloc(iFrameSize);
		pbtProcessData = (unsigned char *)malloc(iProcessSize);
		pbtProcessTranspose = (unsigned char *)malloc(iProcessSize);
		pbtProcessResample = (unsigned char *)malloc(iYResOut * iXResOut);

		i8BitRawData = 0; // default is floating point data format

		free(pszXmlFileData);
	}

	// Open RF file
	pFile = OpenRfFile(argv[1]);

	// Read RF file header
	rfHeader = ReadRfFileHeader(pFile);

	// Determine if this an 8bit format
	i8BitRawData = (rfHeader.dwInfo & VSI_RF_FILE_HEADER_INFO_DATA_RAW8) == VSI_RF_FILE_HEADER_INFO_DATA_RAW8;
	if (i8BitRawData)
	{
		// This format is an 8bit raw format
		iFrameSize = iSamples * iLines * sizeof(unsigned char);
	}

	printf("\n\n\nReading file %s\n", argv[1]);
	printf("	Version %d\n", rfHeader.dwVersion);
	printf("	Number of frames %d\n", rfHeader.dwNumFrames);
	printf("	Bit depth %d\n\n", i8BitRawData ? 8 : 32);
	
	for(dwCount=0; dwCount<rfHeader.dwNumFrames; ++dwCount)
	{
		// Read frame header
		rfFrameHeader = ReadRfFrameHeader(pFile);

		printf("Frame %d: Number %d, Time = %f, Size %d\n",
			dwCount,
			rfFrameHeader.dwFrameNumber,
			rfFrameHeader.dbTimeStamp,
			rfFrameHeader.dwPacketSize);

		if((int)rfFrameHeader.dwPacketSize != iFrameSize)
		{
			printf("Packet size (%d) does not match calculated frame size (%d)",
				rfFrameHeader.dwPacketSize, iFrameSize);
			exit(1);
		}

		// Read data block
		ReadRfFrameData(pFile, pbtFrameData, rfFrameHeader.dwPacketSize);

		
		// Process frame
		if (i8BitRawData)
		{
			memcpy(pbtProcessData, pbtFrameData, iSamples * iLines * sizeof(unsigned char));
		}
		else
		{
			ProcessBModeFrameRaw(
				pbtFrameData,
				pbtProcessData,
				iSamples,
				iLines,
				dbYOffset,
				dbVOffset,
				dbDynRange);
		}

		// Transpose data set
		Rotate90Deg8(pbtProcessData, iSamples, iLines, pbtProcessTranspose);

		// Resample data set
		Resample8(pbtProcessTranspose, iLines, iSamples, pbtProcessResample, iXResOut, iYResOut);

		// Save image frame
		sprintf(pszFileName, "%s_%d.bmp", argv[3], dwCount + 1);
		SaveBmp(pszFileName, pbtProcessResample, iXResOut, iYResOut, 8, g_pBModePalette);
	}

	// Close the RF file
	CloseRfFile(pFile);

	// Free processing memory
	if(NULL != pbtFrameData)
		free(pbtFrameData);

	if(NULL != pbtProcessData)
		free(pbtProcessData);

	if(NULL != pbtProcessTranspose)
		free(pbtProcessTranspose);

	if(NULL != pbtProcessResample)
		free(pbtProcessResample);

	return 0;
}


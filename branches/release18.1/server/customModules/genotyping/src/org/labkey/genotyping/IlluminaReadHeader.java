/*
 * Copyright (c) 2014-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.genotyping;

/**
* User: jeckels
* Date: 5/29/14
*/
public class IlluminaReadHeader
{
    private String _instrument;
    private int _runId;
    private String _flowCellId;
    private int _flowCellLane;
    private int _tileNumber;
    private int _xCoord;
    private int _yCoord;
    private int _pairNumber;
    private boolean _failedFilter;
    private int _controlBits;
    private int _sampleNum;
    private String _sampleName;

    private static final int NO_SAMPLE_NUMBER_FOUND = -1;

    public IlluminaReadHeader(String header, String filename) throws IllegalArgumentException
    {
        String[] h;
        int minLength;

        //alternate format: HWI-ST881:298:C15RNACXX:6:2209:15829:47176/1
        if (header.endsWith("/1") || header.endsWith("/2"))
        {
            header = header.replaceAll("/1$", ":1");
            header = header.replaceAll("/2$", ":2");
            minLength = 8;
        }
        else
        {
            minLength = 11;
        }

        h = header.split(":| ");
        if (h.length < minLength)
        {
            throw new IllegalArgumentException("Improperly formatted header: " + header);
        }

        try
        {
            _instrument = h[0];
            _runId = Integer.parseInt(h[1]);
            _flowCellId = h[2];
            _flowCellLane = Integer.parseInt(h[3]);
            _tileNumber = Integer.parseInt(h[4]);
            _xCoord = Integer.parseInt(h[5]);
            _yCoord = Integer.parseInt(h[6]);
            _pairNumber = Integer.parseInt(h[7]);

            if (h.length > 8)
            {
                setFailedFilter(h[8]);
                _controlBits = Integer.parseInt(h[9]);
            }

            _sampleNum = NO_SAMPLE_NUMBER_FOUND;
            _sampleName = null;
            if (h.length > 10)
            {
                //Note: if this read was not demultiplexed by illumina, the index sequence may appear in this position
                try
                {
                    _sampleNum = Integer.parseInt(h[10]);
                }
                catch (NumberFormatException e)
                {
                    // may mean new header format, so attempt to process differently
                    _sampleName = filename.split("_")[0];
                    if(_sampleName.endsWith(".gz"))  // whoops, may be new filename format, so try one more filename format
                    {
                        String[] sampleNameParts = filename.split("-");
                        if(sampleNameParts.length == 3)
                            _sampleName = sampleNameParts[2].split("\\.")[0];
                        else
                            throw new IllegalArgumentException("Filename '" + filename + "' is in an unknown name format.");
                    }
                }
            }
        }
        catch (NumberFormatException e)
        {
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    public String getInstrument()
    {
        return _instrument;
    }

    public void setInstrument(String instrument)
    {
        _instrument = instrument;
    }

    public int getRunId()
    {
        return _runId;
    }

    public void setRunId(int runId)
    {
        _runId = runId;
    }

    public String getFlowCellId()
    {
        return _flowCellId;
    }

    public void setFlowCellId(String flowCellId)
    {
        _flowCellId = flowCellId;
    }

    public int getFlowCellLane()
    {
        return _flowCellLane;
    }

    public void setFlowCellLane(int flowCellLane)
    {
        _flowCellLane = flowCellLane;
    }

    public int getTileNumber()
    {
        return _tileNumber;
    }

    public void setTileNumber(int tileNumber)
    {
        _tileNumber = tileNumber;
    }

    public int getxCoord()
    {
        return _xCoord;
    }

    public void setxCoord(int xCoord)
    {
        _xCoord = xCoord;
    }

    public int getyCoord()
    {
        return _yCoord;
    }

    public void setyCoord(int yCoord)
    {
        _yCoord = yCoord;
    }

    public int getPairNumber()
    {
        return _pairNumber;
    }

    public void setPairNumber(int pairNumber)
    {
        _pairNumber = pairNumber;
    }

    public boolean isFailedFilter()
    {
        return _failedFilter;
    }

    public void setFailedFilter(boolean failedFilter)
    {
        _failedFilter = failedFilter;
    }

    public void setFailedFilter(String failedFilter)
    {
        _failedFilter = "Y".equals(failedFilter) ? true : false;
    }

    public int getControlBits()
    {
        return _controlBits;
    }

    public void setControlBits(int controlBits)
    {
        _controlBits = controlBits;
    }

    /**
     * @return Sample index, as assigned by illumina.  NO_SAMPLE_NUMBER_FOUND indicates this is part of non-assigned reads.
     */
    public int getSampleNum()
    {
        return _sampleNum;
    }

    public void setSampleNum(int sampleNum)
    {
        this._sampleNum = sampleNum;
    }

    public String getSampleName()
    {
        return _sampleName;
    }

    public void setSampleName(String sampleName)
    {
        _sampleName = sampleName;
    }
}


// tool to split individual channels into separate folders for further analysis with BIP
// DeboraOlivier https://github.com/DeboraOlivier/
// modified from Philippe Andrey pandrey@inrae.fr

//## This program is free software: you can redistribute it and/or modify
//## it under the terms of the GNU General Public License as published by
//## the Free Software Foundation, either version 3 of the License, or
//## (at your option) any later version.
//##
//## This program is distributed in the hope that it will be useful,
//## but WITHOUT ANY WARRANTY; without even the implied warranty of
//## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//## GNU General Public License for more details.
//##
//## You should have received a copy of the GNU General Public License
//## along with this program.  If not, see <http://www.gnu.org/licenses/>.



setBatchMode(true);
topDir = "E:/_PAPERS_in_PREP/_3Dpaper/data/SP8/DistanceAnalysis__DAPI_Lap2b_Lap2a_TRF1/CROPS/2_ana_LAP/"
inputDir = topDir+"_originals/";
dir1 = topDir+"dapi/";
dir2 = topDir+"lap2b/";
dir3 = topDir+"lap2a/";
dir4 = topDir+"TRF1/";
files = getFileList(inputDir);
for (i = 0; i < files.length; i++)
{
	if ( endsWith(files[i],".tif") )
	{
    		print("processing "+files[i]);
		open(inputDir+files[i]);
		title = getTitle();
		title1 = "C1-" + title; // DAPI
		title2 = "C2-" + title; //Lap2b
		title3 = "C3-" + title; //Lap2a
		title4 = "C4-" + title; //TRF1
		run("Split Channels");
	
		// saves channels 1 and 2 under the same
		// original filename in the two subdirs
		selectWindow(title1);
		saveAs("tiff",dir1+title);
		selectWindow(title2);
		saveAs("tiff",dir2+title);
		selectWindow(title3);
		saveAs("tiff",dir3+title);
		selectWindow(title4);
		saveAs("tiff",dir4+title);
		run("Close All");
	}
}
print("done");
setBatchMode(false);


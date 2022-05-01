
// tool to crop around single nuclei, to get individual anaphase/telophase cells
// DeboraOlivier https://github.com/DeboraOlivier/

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



//initialise
roiManager("Reset");
run("Clear Results");

//select location where images are stored & where processed images should go
input = getDirectory("location where images are stored");
output = getDirectory("Location for results");
list = getFileList(input);
Dialog.create("Number of Pixels to Expand Bounding Box by ");
Dialog.addNumber("Number of Pixels:", 20);
Dialog.show();
L=Dialog.getNumber();

setBatchMode(true);
//sets to false if want to see intermediate images

//loop to sequentially open images (=FUNCTION 1)
for (im=0; im<list.length; im++){{
full = input + list[im];
run("Bio-Formats Importer", "open=full autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
name=File.nameWithoutExtension; //name of the last file opened!! has to be after running bioformats
//Get the name without the extension
//fn=getTitle();
//ShortFileName=substring(fn, 0, lastIndexOf(fn,"."));
out = output + name;

//make rois of nuclei using channel Lamin MAx Proj/channel1-DAPI
run("Duplicate...", "title=original duplicate");
run("Duplicate...", "duplicate channels=1");
rename("C1");
run("Z Project...", "projection=[Max Intensity]");
run("Gaussian Blur...", "sigma=4");
setAutoThreshold("Default dark");
//run("Threshold...");
setAutoThreshold("Default dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Fill Holes");
run("Dilate");
run("Dilate");
run("Analyze Particles...", "size=1000-Infinity pixel show=Outlines display exclude clear add");

n=roiManager("Count");
//for each roi
for (roi=0;roi<n;roi++){
	selectWindow("original");
	roiManager("Select",roi);
	roiManager("Rename","Cell Contour "+roi+1);
	Roi.getBounds(x, y, w, h);
	
	makeRectangle(x-L, y-L, w+2*L, h+2*L);
	roiManager("add");
	//roiManager("Rename","Cell-Bounding-Box "+roi+1);
	run("Duplicate...", "duplicate channels=1-4");
	Stack.setChannel(1);
	run("Grays");
	setMinAndMax(0, 30000);
	Stack.setDisplayMode("color");
	Stack.setChannel(2);
	run("Magenta");
	setMinAndMax(0, 25000);
	Stack.setChannel(3);
	run("Cyan");
	setMinAndMax(0, 18000);
	Stack.setChannel(4);
	run("Yellow");
	setMinAndMax(0, 20000);
	Stack.setDisplayMode("composite");
	run("Hide Overlay");
	rename(name+"_cell" + roi+1); //doesnt work yet
	print(name+"_cell" + roi+1 + " done");
	outcell = out + "_cell" + roi+1;
	saveAs("tiff", outcell); //saves new image crop	
	}
//cleanup after saving - save all ROI sets	
 outROI = out + "_crops";
 roiManager("deselect");
 roiManager("Save", outROI +".zip");
 roiManager("Reset");
}
run("Close All");
}
cleanUp();

// Closes the "Results" and "Log" windows and all image windows
function cleanUp() {
    requires("1.30e");
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );
    {
//    if (isOpen("Log")) {
//         selectWindow("Log");
//         run("Close" );
    }
    while (nImages()>0) {
          selectImage(nImages());  
          run("Close");
    }
}
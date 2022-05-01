//initialise
roiManager("Reset");
run("Clear Results");

//select location where images are stored & where processed images should go
input = getDirectory("location where images are stored");
output = getDirectory("Location for results");
list = getFileList(input);
Dialog.create("Number of Pixels to Expand Bounding Box by ");
Dialog.addNumber("Number of Pixels:", 50);
Dialog.show();
L=Dialog.getNumber();

setBatchMode(true);
//sets to false if want to see intermediate images

//loop to sequentially open images (=FUNCTION 1)
for (im=0; im<list.length; im++){{
full = input + list[im];
run("Bio-Formats Importer", "open=full autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");

//Get the name without the extension
fn=getTitle();
ShortFileName=substring(fn, 0, lastIndexOf(fn,"."));
out = output + ShortFileName;

//make rois of nuclei using channel Lamin MAx Proj/channel-DAPI
run("Duplicate...", "title=original duplicate");
run("Duplicate...", "duplicate channels=3");
rename("C2");
run("Z Project...", "projection=[Max Intensity]");
run("Gaussian Blur...", "sigma=5");
setAutoThreshold("Default dark");
//run("Threshold...");
setAutoThreshold("Default dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Fill Holes");
run("Dilate");
run("Dilate");
//run("Adjustable Watershed", "tolerance=0.5");
//run("Watershed") in case of touching cells;
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
	Stack.setChannel(2);
	run("Green");
	setMinAndMax(0, 13000);
	Stack.setChannel(3);
	run("Magenta");
	setMinAndMax(0, 35000);
	Stack.setChannel(4);
	run("Yellow");
	setMinAndMax(0, 17000);
	Stack.setChannel(1);
	run("Grays");
	setMinAndMax(0, 30000);
	Stack.setDisplayMode("composite");
	run("Hide Overlay");
	rename(ShortFileName+"_cell" + roi+1); //doesnt work yet
	print(ShortFileName+"_cell" + roi+1 + " done");
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

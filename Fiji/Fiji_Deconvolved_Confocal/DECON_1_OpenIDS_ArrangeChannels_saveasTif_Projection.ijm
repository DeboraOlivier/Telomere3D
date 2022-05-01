
// tool to save IDS file output from Huygens into TIF, adjust LUTs and a projection
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


run("Close All");
number=0;
suffix= ".ics";

//open directory of images
Dialog.create("Batch Processing - IDS_Projection");
	Proj=newArray("Max Intensity","Average Intensity", "Min Intensity", "Sum Slices", "Standard Deviation", "Median" );
	Dialog.addChoice("Type of projection", Proj,"Max Intensity");
	//Dialog.addCheckbox("Use Bio-Formats Importer ", true);
	Dialog.addString("Image Format:",suffix);
	Dialog.addCheckbox("Convert to RGB on save", false);

Dialog.show();
	suffix= Dialog.getString();
	ProjectionType = Dialog.getChoice();
	//Bio=Dialog.getCheckbox(); 
	Convert = Dialog.getCheckbox(); 

		
//select location where images are stored
input = getDirectory("location where images are stored");
output = getDirectory("Location for results");
setBatchMode(true);

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
						//if finds files with correct suffix, will run function processFile
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
path=input+file;
print("Processing: " +path);
run("Bio-Formats Importer", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
name=File.nameWithoutExtension; //name of the last file opened!! has to be after running bioformats
run("Duplicate...", "title=temp duplicate");

/// uncomment if need to rearrange channels ///
//run("Arrange Channels...", "new=4123"); 

///// set VISUALIZTION levels ////
Stack.setChannel(1);
run("Grays");
setMinAndMax(0, 10000);
Stack.setChannel(2);
run("Magenta");
setMinAndMax(0, 25000);
Stack.setChannel(3);
run("Cyan");
setMinAndMax(0, 20000);
Stack.setChannel(4);
run("Yellow");
setMinAndMax(0, 30000);
Stack.setDisplayMode("composite");

//// 16 bit conversion OPTIONNAL ////
//run("16-bit");


// save the original file in TIF //
out = output + name;
saveAs("tiff", out); 

//// Z projection ////
getDimensions(width, height, channels, slices, frames);
type="projection=["+ProjectionType+"] all";
run("Z Project...",type);
if (Convert==true){
	run("Make Composite");
	run("Stack to RGB");
					}
rename(name + "_"+ ProjectionType);
print(name + "_"+ ProjectionType + " done");
outProj = output + name +"_"+ ProjectionType;
saveAs("tiff", outProj);
run("Close All");
number=number+1;
}



print("All done - " + number + " images processed");



// tool to arrange channels and set LUT and levels
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


Dialog.create("Batch Processing - channel reorganization");
	Dialog.addCheckbox("Use Bio-Formats Importer ", true);
Dialog.show();
		Bio=Dialog.getCheckbox();
		
input = getDirectory("location where images are stored");



//select location where images are stored
output = getDirectory("Location for results");

list = getFileList(input);

setBatchMode(true);

//loop to sequentially open images
for (im=0; im<list.length; im++){{
full = input + list[im];

if (Bio==true){
run("Bio-Formats Importer", "open=full autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
} else {
open(full);
}

filename=getTitle();
//Get the name without the extension
ShortFileName=substring(filename, 0, lastIndexOf(filename,"."));
run("Duplicate...", "title=temp duplicate");
run("Arrange Channels...", "new=4123");
Stack.setChannel(1);
run("Grays");
setMinAndMax(0, 10000);
Stack.setDisplayMode("color");
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

/// uncomment (remove //) if you want to rename file ///
//rename(ShortFileName +"_chLAC-TRF1-Dapi-SUN");
//print(ShortFileName + " done");
//out = output + ShortFileName +"_chLAC-TRF1-Dapi-SUN";
out = output + ShortFileName;
saveAs("tiff", out);
run("Close All");
number=number+1;
}

setBatchMode(true);


print("All done - " + number + " images processed");

}

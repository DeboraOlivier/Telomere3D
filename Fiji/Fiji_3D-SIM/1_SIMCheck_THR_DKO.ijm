// macro to perform thresholding of reconstructed SIM iamages - DeboraOlivier
// https://github.com/DeboraOlivier?tab=repositories

Dialog.create("Batch Processing - SIM Thresholding");
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
run("Threshold and 16-bit Conversion", "auto-scale");
}
rename(ShortFileName+"_THR ");
print(ShortFileName+"_THR " + "done");
out = output + ShortFileName + "_THR ";
saveAs("tiff", out);
run("Close All");
number=number+1;


setBatchMode(false);


print("All done - " + number + " images processed");

}
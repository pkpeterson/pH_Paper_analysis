# pH_Paper_analysis

A set of matlab scripts and functions to analyse used pH indicator paper and report a pH. This code was developed in collaboration with Rebecca Craig and Andrew Ault.

This script is designed to work with pictures of both the used indicator paper and the pH scale. An example image is provided in this repository. The script first allows the user to select an image (filename). The user is then prompted to outline the pH scale, and then the region of the indicator paper to be analysed. The script will then generate a calibration curve and report the pH of the region. The script has two outputs, which appear in the directory where the script is run.

 1) pH_calibration(name of image).pdf, Image that shows the calculated calibration curve
 2) pH_Result_(name of image).png, An image of the cropped sample and the pH scale with the calculated pH displayed above the sample. 
 

Dependencies: Matlab Image Processing Toolbox, export_fig (https://github.com/altmany/export_fig), peakfinder (included here, also available at https://www.mathworks.com/matlabcentral/fileexchange/25500-peakfinder-x0--sel--thresh--extrema--includeendpoints--interpolate-)



This code is all provided as-is and no blame or responsibility for anything will be taken. If this code is used for the purposes of scientific publication, this code should be cited.

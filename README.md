# Depth from Focus using Windowed Linear Least-Squares Regressions
MATLAB Implementation of Depth from Focus algorithm and Python notebook for ceramics depth estimation.

## First part: Windowed linear-least square Regressions

The full algorithm can be runned in the `main.m` Matlab file.
At the end, you can generate a depth map as an image, and a .stl 3D model.

For inputs, please place your images in a folder in order from closest to furthest.
You can use raw images in .jpg format. In this case, please number your images as *img_00n* with *n* being the image number.
If you align your images (for example with Enfuse software like us), please have them in .tif format under the name *aligned_000n*.

Parameters:
- *distance* is the distance between two images
- *size_filter* is the size of the gaussian filter applied on the focus measure map
- *radius_z* is the size of the window along *z*
- *mls_filter_size* is the size of the MLS filter applied at the end for post-processing

The folder *example_engraving* can be used as a test in */data*.

## Second part: Non-invasive on-site method for thickness measurement of transparent ceramic glazes based on Depth from Focus

For ceramics glazed depth measurement, Depth from focus can be runned in the `main_ceramics.m` Matlab file in order to generate a pkl file that can be studied in the `ceramics_depth_measurement.ipynb` Jupiter notebook file.

To use it, first run the Matlab file.
As in the previous part, please put your images from the closest to the furthest, and rename them like explain before. 

Parameters:
- *ROI* is the region of interest you want to focus on.
- *distance* is the distance between two images
 
 After it, run it in order to generate a pkl file you can study in the jupyter file. 
 Follow the indications until the end in order to measure the depth of above and under the glaze.
 Don't forget to multiply your depth estimation by the refractive index supposed of your glaze (in our cases, between 1.5 and 2.0).
 
 The folder *example_ceramics_bdx6502* can be used as a test in */data*. You can compare the results you obtain with our results. 

Contact informations 
-------
- Corentin Cou <corentin.cou@institutoptique.fr> (for 1st and 2nd part)
- Gael Guennebaud <gael.guennebaud@inria.fr> (only for 2nd part)


License
-------
 
[CeCILL-B](LICENSE.txt)

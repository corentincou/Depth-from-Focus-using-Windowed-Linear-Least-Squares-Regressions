# -*- coding: utf-8 -*-
"""
Created on Wed May 17 10:29:47 2023

@author: coren
"""

import numpy as np
import trimesh
import time
import cv2


import os.path
from os import path


#########################################
# Input parameters (see README)
filepath = 'D://data//example_ceramics_bdx6502//'
filename = 'object.stl'
x_size = 1775# size in x of the mesh, from Matlab 
y_size = 2683# size in y of the mesh, from Matlab

restack_name = 'restack.tif' # Name of the all-in-focus image

#########################################


def affiImg(img):
    img2 = np.zeros((np.shape(img)[0], np.shape(img)[1], np.shape(img)[2]))
    img2[:,:,0] = img[:,:,2]
    img2[:,:,1] = img[:,:,1]
    img2[:,:,2] = img[:,:,0]
    return img2


def stl_to_obj(filepath, filename, x_size, y_size, restack_name):
    # Load the stl file
    start = time.time()
    mesh = trimesh.load_mesh(file_obj = filepath+filename, file_type ='stl')
    end = time.time()
    print('Executing time : '+str(end-start)+'s')
    print("Import done")
        
    # Load the image for the texture
    img = affiImg(cv2.imread(filepath+restack_name))
    img = img[18:-19, 18:-19,:]
    img = cv2.resize(img, (y_size, x_size))
    h, w, c = img.shape
    
    # Create it as a color
    colors = img.reshape((h*w, 3), order='F')
        
    # Export it on the vertex after taking the good order of vertex
    order = np.argsort(mesh.vertices[:,0] + x_size*mesh.vertices[:,1])
    mesh.visual.vertex_colors[order, :3] = colors
    print("Adding colors is done")

    # Export it as an obj file wilth color stocked in vertex coordinates
    result = trimesh.exchange.obj.export_obj(mesh, include_normals=True,
                                             include_color=True, 
                                             include_texture=False, return_texture=False,
                                             write_texture=False, resolver=None,
                                             digits=8)
    
    output_file = open(filepath +'object.obj', "w", encoding='utf-8')
    output_file.write(result)
    output_file.close()
    print('Export of the obj file done')
    print('Filepath:', filepath+'object.obj')
            
    
#########################################
# Input parameters (see README)

if __name__ == "__main__":
    stl_to_obj(filepath, 
               filename, 
               x_size, 
               y_size, 
               restack_name)
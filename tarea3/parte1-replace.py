#! /usr/bin/python
# -*- coding: utf-8 -*-

import sys
from collections import defaultdict
import math
import os
import shutil

def replaceLowFreq(corpus_file, corpus_file2):
    file = open('gene.out.train', 'w')
    lines = corpus_file2.readlines()
    for line in lines:
        file.write("%s" % line)
    corpus_file.seek(0);        
    l = corpus_file.readline()
    while l: #leemos linea por linea el archivo de conteo
        
        line = l.strip() #Limpiamos espacios tanto por delante como por atras
        arrayLine = line.split() #Hacemos split de la linea y almacenamos las palabras de la linea en un array
        line = l.strip() #Limpiamos espacios tanto por delante como por atras
        arrayLine = line.split() #Hacemos split de la linea y almacenamos las palabras de la linea en un array
        if arrayLine[1] == 'WORDTAG': #solo se toma en cuenta las lineas clasificadas como WORDTAG            
            count = int(arrayLine[0]) #count 
            if count < 5: #si la frecuencia es menor a 5 buscamos la linea en el archivo de entrenamiento y la reemplazamos por _RARE_
                findLine = arrayLine[3] + " " + arrayLine[2]
                findLine = findLine.strip()
                file = open('gene.out.train', 'r+')
                lines = file.readlines()
                for line in lines:
                    line = line.strip()
                    if line == findLine:
                        file.write("_RARE_ " + arrayLine[2])
            else:
                file.write(line)
        l = corpus_file.readline() #Leemos la siguiente linea
    
    #for p in keys: print p
    #for p in values: print p
    #for p in wTag: print p

if __name__ == "__main__":

    if len(sys.argv)!=3: # Expect exactly one argument: the training data file
        sys.exit(2)

    try:
        input1 = file(sys.argv[1],"r")
        input2 = file(sys.argv[2],"r")
    except IOError:
        sys.stderr.write("ERROR: Cannot read inputfile %s.\n" % arg)
        sys.exit(1)
    
    replaceLowFreq(input1, input2)
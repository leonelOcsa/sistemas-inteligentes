#! /usr/bin/python
 
#__author__="Leonel Ocsa S�nchez <leonel.ocsa.sanchez@ucsp.edu.pe>"
#__date__ ="$Dec, 2016"

import sys
from collections import defaultdict
import math

def parte2(corpus_file1, corpus_file2):
    #a continuacion creamos una colección de 2-GRAMAS y 3-GRAMAS con sus respectivas combinaciones y contadores 
    l = corpus_file1.readline()
    gram2 = {}
    gram3 = {}
    while l: #leemos linea por linea el archivo de conteo
        line = l.strip()
        arrayLine = line.split() #Hacemos split de la linea y almacenamos las palabras de la linea en un array
        #2 casos cuando es 2-GRAM y 3-GRAM
        gramType = arrayLine[1]
        if gramType == '2-GRAM':
            count = arrayLine[0]
            first = arrayLine[2] #primera etiqueta
            second = arrayLine[3] #segunda etiqueta
            #count2gram = {second : count}
            if not first in gram2: #comprobamos si la primera etiqueta existe
                gram2[first] = {}
            gram2[first][second] = count        
        else: 
            if gramType == '3-GRAM':
                count = arrayLine[0]
                first = arrayLine[2] #primera etiqueta
                second = arrayLine[3] #segunda etiqueta
                third = arrayLine[4] #tercera etiqueta
                if not first in gram3: #comprobamos si la primera etiqueta existe
                    gram3[first] = {}
                if not second in gram3[first]: #comprobamos si la segunda etiqueta existe
                    gram3[first][second] = {}
                gram3[first][second][third] = count
        l = corpus_file1.readline()

    #luego de haber creado nuestro diccionario de secuencias leemos el archivo de entrada etiquetado y procedemos 
    #python parte2.py gene.out.counts gene_dev.p1.out
if __name__ == "__main__":

    if len(sys.argv)!=3: # Expect exactly one argument: the training data file
        sys.exit(2)

    try:
        input1 = file(sys.argv[1],"r")
        input2 = file(sys.argv[2],"r")
    except IOError:
        sys.stderr.write("ERROR: Cannot read inputfile %s.\n" % arg)
        sys.exit(1)
    
    parte2(input1, input2)

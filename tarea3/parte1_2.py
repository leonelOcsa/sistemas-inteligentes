#! /usr/bin/python
 
#__author__="Leonel Ocsa S�nchez <leonel.ocsa.sanchez@ucsp.edu.pe>"
#__date__ ="$Dec, 2016"

import sys
from collections import defaultdict
import math

#luego de haber hecho el nuevo conteo sobre el archivo train modificado
#python count_freqs.py gene.out.train > gene.out.counts

def parte1_2(corpus_file, corpus_file2):
    l = corpus_file.readline()
    keys = [] #creamos una lista vacia para las claves tag
    values = [] #creamos una lista vacia para los values

    wKeys = [] #clave de palabras
    wCount = [] #conteo de palabras obtenidas del archivo counts
    wTag = [] #tag correspondiente a la palabra
    wEmission = [] #probabilidad de emision de cada palabra
    while l: #leemos linea por linea el archivo de conteo
        line = l.strip() #Limpiamos espacios tanto por delante como por atras
        arrayLine = line.split() #Hacemos split de la linea y almacenamos las palabras de la linea en un array
        if arrayLine[1] == 'WORDTAG': #solo se toma en cuenta las lineas clasificadas como WORDTAG            
            count = arrayLine[0] #count
            tag = arrayLine[2] #y
            word = arrayLine[3] #x
            wIndex = len(wKeys) 
            if not tag in keys: #llenamos nuestro keys, s�lo deber� aceptar un �nico valor, en este caso por ejemplo O o I-GENE 
                index = len(keys) #el length actual de nuestra lista de keys indicara la siguiente posicion donde insertar un key encontrado
                keys.insert(index, tag) #insertamos la clave encontrada en keys
                values.insert(index, 0) #inicializamos su valor respectivo en 0
            wKeys.insert(wIndex, word) #insertamos la palabra en una lista de claves 
            wCount.insert(wIndex, int(count))
            wTag.insert(wIndex, tag) 
            #una vez creada nuestra clave empezamos el conteo
            valIndex = keys.index(tag)
            values[valIndex] = values[valIndex] + int(count)
        l = corpus_file.readline() #Leemos la siguiente linea
    
    #for p in keys: print p
    #for p in values: print p
    #for p in wTag: print p

    #acontinuacion creamos el diccionario de palabras con sus respectivo conteo de apariciones por TAG
    dictionary = {}

    for x in range(len(wKeys)):
        if not wKeys[x] in dictionary: #si la clave no existe en el diccionario
            dictionary[wKeys[x]] = {wTag[x]:int(wCount[x])}
        else: #si la clave ya existe
            dictionary[wKeys[x]][wTag[x]] = int(wCount[x])

    for x in range(len(wKeys)):
        tag = wTag[x]
        valIndex = keys.index(tag)
        val = values[valIndex]
        wEmission.insert(x, float(float(wCount[x]) / float(val)))
        #print str(wCount[x]) + " " + wKeys[x] + " " + wTag[x] + " " + str(wEmission[x])
    
    #ahora copiamos el archivo modificando las palabras de menor frecuencia
    file = open('gene_dev.p1.out', 'w')
    l = corpus_file2.readline()
    while l: #leemos linea por linea el archivo de conteo
        line = l.strip() #limpiamos espacios tanto por delante como por atras
        if line == "":
            file.write("%s\n" % line)
        else:
            arrayline = line.split() #hacemos split de la linea y almacenamos las palabras de la linea en un array
            word = arrayline[0]
            tags = {}
            if word in dictionary:
                tags = dictionary[word] #obtengo el valor de la palabra que en este caso es un diccionario que almacena el count para cada etiqueta relacionada a la palabra (clave)
            else:
                tags = dictionary['_RARE_']
            tagsLen = len(tags) #saco el length para saber cuantas etiquetas tiene esta palabra
            max = 0.0
            winnerTag = 0
            for i in range(tagsLen):
                tag = tags.keys()[i] #tag actual a evaluar, de este modo accedo al tag correspondiente en la posicion i
                #print tag
                valIndex = keys.index(tag)
                val = values[valIndex] #respectivo contador total del tag
                #print val
                emissionPr = float(float(tags[tag])/float(val)) #probabilidad de emision
                #print emissionPr
                if emissionPr > max:
                    winnerTag = i
                    max = emissionPr
            newline = word + " " + tags.keys()[winnerTag]               
            file.write("%s\n" % newline)
        l = corpus_file2.readline()
    file.close()

if __name__ == "__main__":

    if len(sys.argv)!=3: # Expect exactly one argument: the training data file
        sys.exit(2)

    try:
        input1 = file(sys.argv[1],"r")
        input2 = file(sys.argv[2],"r")
    except IOError:
        sys.stderr.write("ERROR: Cannot read inputfile %s.\n" % arg)
        sys.exit(1)
    
    parte1_2(input1, input2)
    #despues de llamar a la funcion se ontiene el mismo resultado que el pdf
    #para llamar esta funcion desde consola python parte1_2.py gene.out.counts gene.dev
   

#! /usr/bin/python
 
#__author__="Leonel Ocsa Sánchez <leonel.ocsa.sanchez@ucsp.edu.pe>"
#__date__ ="$Dec, 2016"

import sys
from collections import defaultdict
import math

def parte2(corpus_file1, corpus_file2):
    #a continuacion creamos una colección de 2-GRAMAS y 3-GRAMAS con sus respectivas combinaciones y contadores 
    l = corpus_file1.readline()
    gram2 = {}
    gram3 = {}
    e = {} #probabilidad de emision
    tags = {} #contiene el total de etiquetas con su respectiva cantidad
    dictionary = {} #contiene el tag con su respectiva emision total
    while l: #leemos linea por linea el archivo de conteo
        line = l.strip()
        arrayLine = line.split() #Hacemos split de la linea y almacenamos las palabras de la linea en un array
        #2 casos cuando es 2-GRAM y 3-GRAM
        gramType = arrayLine[1]
        #92 WORDTAG O reading
        if gramType == 'WORDTAG':
            count = int(arrayLine[0])
            tag = arrayLine[2]
            word = arrayLine[3]
            key = word + "|" + tag
            e[key] = count

            if not word in dictionary:
                dictionary[word] = 0     

        else:  
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
                else:
                    if gramType == '1-GRAM':
                        count = int(arrayLine[0])
                        tag = arrayLine[2]
                        tags[tag] = count
        l = corpus_file1.readline()
    
    #ahora se halla el valor de real de la probabilidad de emision de cada palabra
    eLen = len(e)
    for i in range(eLen):
        tag = e.keys()[i] #aqui obtengo el tag
        xy = tag.split('|') #separo obteniendo un array con la palabra x y su respectivo tag y
        y = xy[1] #extraigo el tag 
        e[tag] = float(float(e[tag])/float(tags[y])) #y lo divido entre el conteo total de su respectivo tag 
    
    gram3Len = len(gram3)

    q = {} #creo mi coleccion de probabilidades para q(y_i|y_i-2, y_i-1)
    #cada palabra esta presentada en una linea y cada linea contiene lo siguiente
    wKeys = [] #clave de palabras
    wCount = [] #conteo de palabras obtenidas del archivo counts
    wTag = [] #tag correspondiente a la palabra
    
    #recorremos cada uno de los trigramas para calcular los parametros

    for i in range(gram3Len): #y_i-2 -> x
        y_iminus2 = gram3.keys()[i]
        gram3len2 = len(gram3[y_iminus2])
        for j in range(gram3len2): #y_i-1 -> y
            y_iminus1 = (gram3[y_iminus2]).keys()[j]
            gram3len3 = len(gram3[y_iminus2][y_iminus1])
            for k in range(gram3len3): #y_i -> z
                y_i = (gram3[y_iminus2][y_iminus1]).keys()[k]
                #print y_iminus2 + " " + y_iminus1 + " " + y_i
                #print gram3[y_iminus2][y_iminus1][y_i] 
                #print y_iminus2 + " " + y_iminus1 
                #print gram2[y_iminus2][y_iminus1]
                xyz = gram3[y_iminus2][y_iminus1][y_i] #Count(y_i-2, y_i-1, y_i)
                xy = gram2[y_iminus2][y_iminus1] #Count(y_i-2, y_i-1)
                #entonces q(y_i|y_i-2, y_i-1) = xyz/xy lo cual es equivalente a q(z|x,y)
                key = y_i + "|" + y_iminus2 + "," + y_iminus1   
                #ahora hacemos el calculo de las q(y_i | y_i-2, y_i-1) = count(y_i-2, y_i-1, y_i)/count(y_i-2, y_i-1)
                q[key] = float(float(xyz)/float(xy))
    
    #print e

    allTags = [] #aqui almacenare todas las etiquetas posibles para el problema, en este caso solo tenemos O y I-GENE
    for i in range(len(tags)):
        tag = tags.keys()[i]
        allTags.insert(i, tag);    
    
    file = open('gene_dev.p2.out', 'w')                
    l = corpus_file2.readline()
    i = 0
    S = [] #esta lista ira almacenando una sentencia a la vez a medida que vaya leyendo el archivo se actualizara con la siguiente nueva sentencia y aplicar Viterbi
    pi = {'-1,*,*' : 1}
    piMax = {'-1,*,*' : "w"} #para almacenar la etiqueta equivalente al maximo backpointer
    bp = {} #backpointers
    while l: #leemos linea por linea el archivo de conteo
        line = l.strip()
        if line != "":
            S.insert(i, line)
            i = i+1
        else: #si encuentra salto de linea en archivo signfica STOP y cuando eso ocurre aplicamos Viterbi
            S_minus2 = S_minus1 = ['*']
            for k in range(len(S)):
                tags_kminus1 = []
                kminus1 = k-1
                if(kminus1 == -1): #si no corresponde al rango de la lista
                    tags_kminus1 = S_minus1 #['*']
                else:
                    tags_kminus1 = allTags #['O', 'I-GENE']
                for u in range(len(tags_kminus1)): #para k-1
                    tags_k = allTags
                    for v in range(len(tags_k)): #para k 
                        if(k == 0 or k == 1):
                            tags_kminus2 = S_minus2
                        else:
                            tags_kminus2 = allTags
                        wMax = 0.0
                        wMaxTag = "X"
                        key = str(k) + ',' + tags_kminus1[u] + ',' + tags_k[v] #clave para pi actual
                        #print key

                        for w in range(len(tags_kminus2)): #para k-2
                            previousKey = str(k-1) + ',' + tags_kminus2[w] + ',' + tags_kminus1[u] #clave para pi anterior
                            #print "w " + previousKey
                            qKey = tags_k[v] + "|" + tags_kminus2[w] + "," + tags_kminus1[u] 
                            #if not qKey in q:
                            #     qKey = "_RARE_" + "|" + tags_kminus2[w] + "," + tags_kminus1[u]
                            eKey = S[k] + "|" + tags_k[v]
                            if not S[k] in dictionary:
                                eKey = "_RARE_|" + tags_k[v]                                    
                            tag = 0
                            if not eKey in e:
                                tag = 1     
                            #OK
                            #print "e "+ eKey
                            if tag == 0: 
                                if wMax < pi[previousKey]*q[qKey]*e[eKey]:
                                    wMax = pi[previousKey]*q[qKey]*e[eKey]
                                    wMaxTag = tags_kminus2[w]
                            
                            #if not key in pi: #si no existe en pi
                            #    wMax = tags_kminus2[w]
                            #    piMax[key] = wMax
                            #    pi[key] = pi[previousKey]*q[qKey]*e[eKey]
                            #else: #si ya existe en pi comparamos con el valor actual y vemos si el nuevo valor es mayor
                            #    if pi[key] < pi[previousKey]*q[qKey]*e[eKey]:
                            #        wMax = tags_kminus2[w]      
                            #        pi[key] = pi[previousKey]*q[qKey]*e[eKey]
                            #        piMax[key] = wMax
                            #bp[key] = piMax[key] #y finalmente seteo el valor final del backpointer   
                        pi[key] = wMax
                        bp[key] = wMaxTag                   
            N = len(S)
            yTags = ['X']*N #secuencia de tags relacionado a la sentencia
            yTagsMax = [0.0]*N

            for u in range(len(allTags)):
                for v in range(len(allTags)):
                    key = str(N-1) + "," + allTags[u] + "," + allTags[v]
                    qkey = "STOP|" + allTags[u] + "," + allTags[v]
                    if yTagsMax[N-1] < pi[key]*q[qkey]:
                        yTagsMax[N-1] = pi[key]*q[qkey]
                        yTags[N-1] = allTags[v] 
                        yTags[N-2] = allTags[u]
            
            for k in range(N-3,-1,-1): #ahora completamos las etiquetas restantes
                bpKey = str(k+2) + "," + yTags[k+1] + "," + yTags[k+2]
                yTags[k] = bp[bpKey]                                  
            
            #procedemos a escribir el archivo de salida
            for a in range(N):
                newline = S[a] + " " + yTags[a]               
                file.write("%s\n" % newline)
            space = ""                                  
            file.write("%s\n" % space)                              
                  
            S = [] #volvemos a setear la sentencia como vacio para la siguiente sentencia que será leida
            i = 0 #inicializamos la posicion de la lista
            pi = {'-1,*,*' : 1}
            piMax = {'-1,*,*' : "w"}
        l = corpus_file2.readline()
    
    #print pi
    file.close()
    
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

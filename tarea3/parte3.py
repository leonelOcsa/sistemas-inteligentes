#! /usr/bin/python
 
#__author__="Leonel Ocsa Sánchez <leonel.ocsa.sanchez@ucsp.edu.pe>"
#__date__ ="$Dec, 2016"

import sys
from collections import defaultdict
import math

def parte3(corpus_file1, corpus_file2):
    print "hello world"
    
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
    
    parte3(input1, input2)

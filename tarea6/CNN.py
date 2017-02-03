import matplotlib.pyplot as plt
import tensorflow as tf
import numpy as np
from sklearn.metrics import confusion_matrix
import time
from datetime import timedelta
import math
import os

import cifar10 #para la importacion de datos desde cifar10

from ConvolutionalNeuranlNetwork import ConvolutionalNeuranlNetwork



#Cargamos la data usando las funcion de cifar10
cifar10.maybe_download_and_extract()
#cargamos los siguientes parametros desde la data: tamaño de las imagenes, numero de canales, y numero total de clases
from cifar10 import img_size, num_channels, num_classes

#creamos nuestro objeto CNN
CNN = ConvolutionalNeuranlNetwork()

#luego cargamos los datos de entrenamiento y sacamos algunos parametros de interes de cada imagen
imagesTrain, clsTrain, labelsTrain = cifar10.load_training_data()
#y establecemos un objeto para los datos de entrenamiento que contiene las imagenes de entrenamiento y las imagenes
CNN.dataTrain = type('obj', (object,), {'imagesTrain' : imagesTrain, 'labelsTrain' : labelsTrain})

#acto seguido cargamos los datos de peueba y sacamos sus parametros respectivos
imagesTest, clsTest, labelsTest = cifar10.load_test_data()
#y creamos un objeto que contenga los datos importantes
CNN.dataTest = type('obj', (object,), {'imagesTest' : imagesTest, 'labelsTest' : labelsTest})
CNN.clsTest = clsTest #seteamos el valor de las clases de prueba

#extramos los nombres de las clases
class_names = cifar10.load_class_names()

#Recargamos la precision y pesos de entrenamientos previos 
CNN.initRestorePath()

#from tensorflow.examples.tutorials.mnist import input_data
#data = input_data.read_data_sets('data/MNIST/', one_hot=True)

#la data es cargada como one-hot encode lo que significa que para cada label tenemos un vector de 10 elementos
#donde el valor mayor indica la clase del label, si queremos saber el numero exacto de la clase sacamos el maximo valor 
#y obtenemos un vector con cada una de las clases respectivas de las imagenes de entrada
#data.test.cls = np.argmax(data.test.labels, axis=1)

#ahora especificamos las dimensiones de los datos
#en este caso tenemos imagenes de entrada de tamano 28x28 por lo tanto especificamos:
#imgSize = 28
CNN.imgSize = img_size
#nuestras imagenes son almacenadas en un solo vector por lo tanto definimos un flat
CNN.imgSizeFlat = CNN.imgSize*CNN.imgSize
#ahora definimos la forma de la imagen mediante una tupla que usaremos mas adelante
CNN.imgShape = (CNN.imgSize, CNN.imgSize)
#es importante definir el numero de canales (colores) de nuestras imagenes
#numChannels = 1 #en este caso escala de grises
CNN.numChannels = num_channels #en este caso escala de grises
#y finalmente el numero de clases de nuestras imagenes
#numClasses = 10
CNN.numClasses = num_classes

#definimos nuestra funcion de ploteo que nos permite ver un numero limite de 9 imagenes
def plotImages(images, cls_true, cls_pred=None):
    assert len(images) == len(cls_true) == 9

    smooth=True
    
    fig, axes = plt.subplots(3, 3)

    if cls_pred is None:
        hspace = 0.3
    else:
        hspace = 0.6

    fig.subplots_adjust(hspace=0.3, wspace=0.3)

    #for i, ax in enumerate(axes.flat):
        # Plot image.
    #    ax.imshow(images[i].reshape(imgShape), cmap='binary')

        # Show true and predicted classes.
    #    if cls_pred is None:
    #        xlabel = "True: {0}".format(cls_true[i])
    #    else:
    #        xlabel = "True: {0}, Pred: {1}".format(cls_true[i], cls_pred[i])

    for i, ax in enumerate(axes.flat):
        if smooth:
            interpolation = 'spline16'
        else:
            interpolation = 'nearest'

        ax.imshow(images[i, :, :, :],
                  interpolation=interpolation)
            
        cls_true_name = class_names[cls_true[i]]

        if cls_pred is None:
            xlabel = "True: {0}".format(cls_true_name)
        else:
            cls_pred_name = class_names[cls_pred[i]]

            xlabel = "True: {0}\nPred: {1}".format(cls_true_name, cls_pred_name)

        ax.set_xlabel(xlabel)
        
        ax.set_xticks([])
        ax.set_yticks([])
    
    plt.show() # luego de todos los calculos esta funcion se encarga de plotear las imagenes

#asi como accedemos a la informacion de los labels de cada imagen, podemos acceder a su imagen respectiva
#images = data.test.images[0:9] #notese que solo se accede a las 9 primeras imagenes
images = CNN.dataTest.imagesTest[0:9] #notese que solo se accede a las 9 primeras imagenes

#accedemos a sus clases verdaderas para cada una de las imagenes
#trueClasses = data.test.cls[0:9] #de igual modo solo accedemos a las 9 primeras imagenes
trueClasses = clsTest[0:9] #de igual modo solo accedemos a las 9 primeras imagenes

#y procedemos a plotear las imagenes con sus respectivos labels
#plot_images(images, trueClasses)

CNN.initLayersAndDo() #realizamos toda la configuracion y carga de los datos del CNN

CNN.printTestAccuracy() #imprimimos la precision de los datos de prueba antes de empezar para saber la precision de previas iteraciones

CNN.optimize(numOfIterations=40000) #especificamos el numero de iteraciones, la precision se cargara de los archivos guardados en disco, de iteraciones previas

CNN.printTestAccuracy() #imprimimos la precision final despues de toda la optimizacion

#anadimos todas las dependencias necesarias
import matplotlib.pyplot as plt
import tensorflow as tf
import numpy as np
from sklearn.metrics import confusion_matrix
import time
from datetime import timedelta
import math
import os

class ConvolutionalNeuranlNetwork:
    def __init__(self):
        self.dataTrain = None #datos de entrenamiento cargados desde la data
    
        self.dataSelf = None #datos de prueba cargdos desde la data

        self.clsTest = None #clases oxtraidas de las imagenes de prueba

        self.imgSize = None #tamano de las imagenes

        self.imgSizeFlat = None #flat de la imagen para representarlo como vector

        self.imgShape = None #forma de la imagen

        self.numChannels = None #numero de canales que ira incrementando

        self.numClasses = None #numero de clases del data set

        self.x_imgs = None #placeholder para las imagenes

        self.trueLabels = None #etiquetas de las imagenes
        
        self.predictionClasses = None #clases que seran predecidas

        self.trainBatchSize = 64 #tamano del batch de entrenamiento

        self.batchSize = 256 #tamano de batch usado para la prediccion de las clases

        self.totalIterations = 0 #este es el contador para el numero total de iteraciones realizados durante el CNN

        self.optimizer = None #optimizador que sera inicializado usando la funcion de Adam

        self.accuracy = None #precision del entrenamiento

        self.savePath = None  #directorio donde guardaremos los resultados de entrenamiento

        self.saver = None #definimos una variable para guardar nuestros datos de entrenamiento asi iremos acumulando todas las iteraciones que deseemos

        self.session = tf.Session()


    #ahora empezamos a disenar el tensor flow graph 
    #empezamos primero definiendo nuestros placeholders

    #necesitamos nuestras variables que seran optimizadas que son los pesos y los bias,
    #por lo tanto definimos 2 variables
    def Weights(self, shape): #le pasamos como parametro la forma (shape) de nuestras imagenes, y crea pesos aleatorios
        return tf.Variable(tf.truncated_normal(shape, stddev=0.05)) #y por defecto una desviacion standard del modelo gaussiano truncado con valor de 0.05

    #ahora definimos nuestros biases
    def Biases(self, length): #retorna biases aleatorios
        return tf.Variable(tf.constant(0.05, shape=[length])) #aqui le pasamos un shape unidimensional

    #la CNN usa convoluciones, por lo tanto procedemos a definir cada una de nuestras capas convolucionales mediante una funcion
    #Parametros:
    #input: entrada de la anterior capa, este parametro es un tensor de 4 dimensiones, donde el primer valor es el numero de la 
    #       imagen, el segundo es el eje Y de la imagen, el tercero el eje X de la imagen y el cuarto el numero de canales de la imagen    
    #numOfInputChannels: numero de canales de la entrada en la anterior capa
    #filterSize: indica el tamano del filtro que sera de tamano filterSize*filterSize
    #numOfFilters: indica el numero de filtros a ser usados en la capa de convolucion
    #useMaxPooling: que por defecto tiene el valor de true, permite hacer un max pooling de 2x2
    def ConvolutionalLayer(self, input, numOfInputChannels, filterSize, numOfFilters, useMaxPooling = True):
        #separamos espacio para los pesos para ello necesitaremos definir un tensor de 4 dimensiones que contiene la forma
        shape = [filterSize, filterSize, numOfInputChannels, numOfFilters] #notese que los 2 primeros valores son iguales filterSize porque tenemos imagenes de igual w y h
        #ahora con nuestra funcion encargada de crear pesos aleatorios inicializamos los pesos
        weights = self.Weights(shape=shape)
        #y creamos biases aleatorios para cada uno de los filtros
        biases = self.Biases(length=numOfFilters)
        #ahora llamamos a la funcion de convolucion de tensorflow
        #le pasamos el input, los pesos que separamos, luego tenemos los strides que indican como se moveran los valores
        #en este caso tenemos todos 1s, eso indica que la image se movera en 1, al igual que los ejes X e Y, y de igual modo el canal del input
        #padding=SAME indica que obtendremos un output del mismo tamano que el input
        layer = tf.nn.conv2d(input=input, filter= weights, strides=[1, 1, 1, 1], padding='SAME')
        #ahora a cada uno de los layer se le suma el bias, es decir a cada uno de los filtros se le suma el bias

        #considerando que tenemos el cuarto parametro de la funcion como un flag de activacion para usar max pooling
        #se declara la siguiente condicion
        if (useMaxPooling): 
            #notese como definimos strides de 1 2 2 1, indicando que recorreremos en X e Y de 2 en 2 para obtener
            #de cada 2x2 el maximo valor 
            layer = tf.nn.max_pool(value=layer, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME') 
            #ahora a continuacion como se sabe durante la capa convolucional al hacer la multiplicacion de los pixeles 
            #de la imagen y los filtros podemos obtener valores negativos, los cuales mediante la funcion 
            #Rectified Linear Unit son corregidos y seteados en 0
            layer = tf.nn.relu(layer) #la posicion de hacer esta operacion optimiza el codigo, ya que normalmente esto se hace despues de la multiplicacion del filtro
    
        return layer, weights

    #el layer que retornamos es de 4 dimensiones y como solo queremos trabajar con 2 dimensiones lo convertimos a 2D tensor
    def convertLayer(self, layer):
        layerShape = layer.get_shape()
        numFeatures = layerShape[1:4].num_elements()
        layerFlat = tf.reshape(layer, [-1, numFeatures])
        return layerFlat, numFeatures

    #ahora definimos la construccion de nuestra FCL, donde el input es el output de la capa anterior,
    #el numOfInputs es el numero de outputs de la capa anterior y tambien definimos el numero de outputs que tendra la capa
    def FullyConnectedLayer(self, input, numOfInputs, numOfOutputs, useRelu=True):
        #creamos los pesos y bias aleatorios 
        weights = self.Weights(shape=[numOfInputs, numOfOutputs])
        biases = self.Biases(length=numOfOutputs)
        #aqui se hace el calculo de una mutiplicacion de las matrices de input y pesos a lo cual le sumamos los biases
        layer = tf.matmul(input, weights) + biases
        #y finalmente usamos Rectified Linear Unit para corregir los valores negativos
        if(useRelu): #solo si es true que es por defecto
            layer = tf.nn.relu(layer)
    
        return layer #retornamos nuestra layer

    def initRestorePath(self):
        saveDir = 'checkpoints/'
        if not os.path.exists(saveDir):
            os.makedirs(save_dir)
        self.savePath = os.path.join(saveDir, 'best_validation')
    
    #para tomar trozos de las imagenes de forma aleatoria definimos la siguiente funcion
    def randomBatch(self):
        # Number of images in the training-set.
        num_images = len(self.dataTrain.imagesTrain)

        # Create a random index.
        idx = np.random.choice(num_images, size=self.trainBatchSize, replace=False)

        # Use the random index to select random images and labels.
        x_batch = self.dataTrain.imagesTrain[idx, :, :, :]
        y_batch = self.dataTrain.labelsTrain[idx, :]

        return x_batch, y_batch

    #funcion de optizacion
    def optimize(self, numOfIterations):
        start_time = time.time() #se establace un tiempo de inicio

        for i in range(self.totalIterations, self.totalIterations + numOfIterations):

            x_batch, y_true_batch = self.randomBatch()

            feed_dict_train = {self.x_imgs: x_batch, self.trueLabels: y_true_batch}

            #corremos el optimizador un numero determinado de iteraciones durante el entrenamiento y mientras esto ocurre 
            #almacenamos dichos valores dentro de la sesion de Tensor Flow
            self.session.run(self.optimizer, feed_dict=feed_dict_train)

            #Cada 100 iteraciones imprimimos el progreso
            if i % 100 == 0:
                #Calculamos la precision de los datos de entrenamiento
                acc = self.session.run(self.accuracy, feed_dict=feed_dict_train)
                
                msg = "Iteración: {0:>6}, Precisión de Entrenamiento: {1:>6.1%}"

                #Procedemos a guardar los datos de precision de entrenamiento que se encuentran dentro de la sesion 
                self.saver.save(sess=self.session, save_path=self.savePath)

                print(msg.format(i + 1, acc))
        
        self.totalIterations += numOfIterations

        #Y guardamos el tiempo en que finalizo todo el proceso de optimización
        end_time = time.time()
        
        #Calculamos la diferencia entre el tiempo inicial y final
        time_dif = end_time - start_time
        
        print("Tiempo total: " + str(timedelta(seconds=int(round(time_dif)))))

    def predictCls(self, images, labels, cls_true):
        numImages = len(images) #Numero de imagenes
        #array que contiene las clases que seran predecidas
        cls_pred = np.zeros(shape=numImages, dtype=np.int)

        #a continuacion se hace el calculo de las clases a ser predecidas
        
        i = 0
        while i < numImages:
            j = min(i + self.batchSize, numImages)

            feed_dict = {self.x_imgs: images[i:j, :],
                         self.trueLabels: labels[i:j, :]}

            #Usando Tensor Flow calculamos la clase predecida de la imagen
            cls_pred[i:j] = self.session.run(self.predictionClasses, feed_dict=feed_dict)

            i = j

        #aqui se almacena las imagenes si estan correctamente clasificadas
        correct = (cls_true == cls_pred)

        return correct, cls_pred

    def printTestAccuracy(self, show_example_errors=False, show_confusion_matrix=False):
        #Para todas las imagenes se calculan las clases predecidas con su respectivos cls_true para determinar si corresponde a la clase o no
        correct, cls_pred = self.predictCls (images=self.dataTest.imagesTest, labels=self.dataTest.labelsTest, cls_true=self.clsTest)
        
        acc = correct.mean() #calculamos la media de precision
        num_correct = correct.sum() #y tambien sumamos todos sus valores solo de las clasificaciones correctas
        num_images = len(correct) #numero de imagenes que seran clasificadas

        msg = "Precisión de los datos de prueba: {0:.1%} ({1} / {2})"
        print(msg.format(acc, num_correct, num_images))

        #Si deseamos mostrar los datos de prueba ploteamos 
        if show_example_errors:
            print("Example errors:")
            plot_example_errors(cls_pred=cls_pred, correct=correct)

        #De igual modo para la matriz de confusion
        if show_confusion_matrix:
            print("Confusion Matrix:")
            plot_confusion_matrix(cls_pred=cls_pred)

    def initLayersAndDo(self):
        #definimos los parametros iniciales de nuestras red neuronal convolucional
        #debemos tomar en cuenta el numero de capas convolucionales
        #convolucio 1:
        filterSize1 = 5 #Los filtros seran de FilterSize * filterSize
        numFilter1 = 16 #definimos el numero de filtros en la primera capa convolucional
        #convolucion 2: de igual modo para la convolcion numero 2
        filterSize2 = 5
        numFilter2 = 36 
        #Fully connected Layer
        fullyConLayerSize = 128

        #ahora definimos nuestras variables placeholder, primero definimos el placeholder para las imagenes
        #aqui definimos una forma con numero de rows None que indica que tenemos un numero arbitrario de filas,
        #mientras que indicamos el size Flat de la imagen como numero de columnas 
        #x_imgs = tf.placeholder(tf.float32, shape=[None, imgSizeFlat], name='x_imgs') #el name es opcional
        self.x_imgs = tf.placeholder(tf.float32, shape=[None, self.imgSize, self.imgSize, self.numChannels], name='x_imgs')
        #hacemos un reshape de 4D a 2D ya que el alto, ancho y tamano de imagen son lo mismo, podemos reducir a 2D
        x_image = tf.reshape(self.x_imgs, [-1, self.imgSize, self.imgSize, self.numChannels])
        #luego de esto definimos nuestros place holders para los labels reales de cada imagen
        self.trueLabels = tf.placeholder(tf.float32, shape=[None, self.numClasses], name='true_Labels')
        #y finalmentee si queremos el valor exacto almacenado en un entero y no en array hacemos lo siguiente
        trueClasses = tf.argmax(self.trueLabels, dimension=1)

        #empezamos con el entrenamiento, y para ello empezamos creando nuestra primera capa convolucional
        #en el numero de numOfInputChannels recordar que se esta trabajando con 1 solo canal de escala de grises
        #si fuera RGB se modifica a 3, y usamos los parametros definidos para la capa convolucional 1
        layerConvolution1, weightsConvolution1 = self.ConvolutionalLayer(input=x_image, numOfInputChannels=self.numChannels, filterSize=filterSize1, numOfFilters=numFilter1, useMaxPooling=True)
        #los pesos son valores correspondientes a la convolucion que luego podemos plotear, en el caso de LayerConvolutional 1
        #tenemos que es un tensor de 4 dimensiones

        #print(layerConvolution1)

        #convolucion 2 que recibe como entrada el output de la primera capa convolucional
        layerConvolution2, weightsConvolution2 = self.ConvolutionalLayer(input=layerConvolution1, numOfInputChannels=numFilter1, filterSize=filterSize2, numOfFilters=numFilter2, useMaxPooling=True) 
 
        #ahora usamos nuestro conversor de 4D a 2D para convertir la salida de la convolucion 2
        layerFlat, numFeatures = self.convertLayer(layerConvolution2)

        #aqui obtenemos el numero de caracteristicas de cada vector que en total es filterSize*filterSize*numChannels
        #una vez convertida la data procedemos a convertirla en una fully connected layer
        #le pasamos el numero de caracteristicas y el tamano del fully connected layer, internamente ya se hace el
        #rectified Linear Unit
        fullyConLayer1 = self.FullyConnectedLayer(input=layerFlat, numOfInputs=numFeatures, numOfOutputs=fullyConLayerSize) 

        #en este caso anadimos otra fully connected layer que recibira como entrada la primera fully connected layer
        #en input recibe el fullyConLayerSize y como output tenemos la cantidad de clases de los datos, y en este caso no usamos RELU
        fullyConLayer2 = self.FullyConnectedLayer(input=layerFlat, numOfInputs=numFeatures, numOfOutputs=self.numClasses, useRelu=False)

        #luego aplicamos softmax para normalizar el output de la fully connected layer 2
        prediction = tf.nn.softmax(fullyConLayer2)

        #y para obtener el valor especifico de la clase obtenemos el indice del valor maximo de la prediccion
        self.predictionClasses = tf.argmax(prediction, dimension=1)

        #como el modelo iniciar con pesos y biases aleatorios, debemos calcular cuan preciso es el calculo, para ello
        #usamos crossEntropy, al obtener al entropia cruzada podemos comparar los datos de prueba con los datos de entrenamiento
        #y de esto determinar el comportamiento de la red
        crossEntropy = tf.nn.softmax_cross_entropy_with_logits(logits=fullyConLayer2, labels=self.trueLabels) #y se la pasamos los vectores que representan el label de cada imagen
        #y de ello obtenemos el costo
        cost = tf.reduce_mean(crossEntropy)

        #el costo debe ser minimizado por lo tanto debemos optimizar usando la descendiente de la gradiente
        self.optimizer = tf.train.AdamOptimizer(learning_rate=1e-4).minimize(cost)

        #para conocer el performance de la red durante la clasificacion hacemos una comparacion de precision entre los datos reales y los datos predecidos
        correctPrediction = tf.equal(self.predictionClasses, trueClasses)
        #y luego calculamos la precision
        self.accuracy = tf.reduce_mean(tf.cast(correctPrediction, tf.float32))

        #termina la creacion del grafo
        #ahora se define una funcion que nos ayudara con las iteraciones para ello se usa el batch previamente definido
        #debido a que la cantidad de imagenes es 50000 no es posible procesar todas de una, sino que es necesario
        #subdividirlo en trozos, para ello funciona el batch
        
        #tambien es importante definir nuestra sesion de tensorflow que sera usada mas adelante
        #session = tf.Session()
        self.session.run(tf.global_variables_initializer())
        #para guadar
        self.saver = tf.train.Saver()
        #restaurar
        self.saver.restore(sess=self.session, save_path=self.savePath)

        #self.printTestAccuracy()

        #self.optimize(10000) #especificamos el numero de iteraciones, la precision se cargara de los archivos guardados en disco, de iteraciones previas

        #self.printTestAccuracy()

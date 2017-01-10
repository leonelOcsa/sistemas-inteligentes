function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

%tenemos 5000 entradas que pasaran a traves de 400 capas
%esto estara representado por una matriz
%creamos el input 
inputNR = ones(m,1); 
matx = [inputNR X]; %concatenamos la entrada con X  
Zx = matx*Theta1'; %multiplicamos matx con Theta1 transpuesta para que coincidan dimensiones
sigmoidX = sigmoid(Zx); %aplicamos la funcion sigmoidal
%aplicamos lo mismo para theta2 pero usando el resultado sigmoidal
maty = [inputNR sigmoidX]; 
Zy = maty*Theta2';
%calculamos el H de theta de la funcion de la red neuronal
ht=sigmoid(Zy);
%ahora calculamos la sumatoria de la funcion de costo de la red neuronal
%sin regularizacion
sum = 0;
for k=1:m
    %aplicando la formula
    %-((y_k)^(i))*log((h_theta(x^(i))_k)) - (1 - (y_k)^(i))*log(1 - (h_theta(x^(i))_k))
    sum = sum + (-y(k,:) * log(ht(k,:))' - (1-y(k,:))*log(1-ht(k,:))');
end
%segun la formula hallamos el valor de J_theta
J = (1/m)*sum;

%para la parte 2 del ejercioio procedemos a regularizar los valores de
%J_theta
[f1, c1] = size(Theta1);
[f1, c2] = size(Theta2);
%J = J + (lambda/(2*m))*(sum(sum(Theta1(:,2:c1).^2)) + sum(sum(Theta2(:,2:c2).^2)));

%ahora se calcula las gradientes de la red neuronal
G_1 = 0;
G_2 = 0;
%donde se hace el calculo del feedforward propagation
for i=1:m
    %ahora recorremos fila por fila a X y concatenamos un input de valor 1
    row=[1 X(i,:)];
    Zx = row*Theta1';
    sigmoidX = [1 sigmoid(Zx)]; %concatenamos a la funcion sigmoidal
    sigmoidZ=sigmoid(sigmoidX*Theta2'); %se calcula el array sigmoidal de sigmoidX * transpuesta de Theta2
    label1=sigmoidZ-y(i,:);
    %aplicamos la funcion gradiente sigmoidal usada para redes neuronales
    label2=Theta2'*label1(:).*[1 sigmoidGradient(Zx)]';
    label2=label2(2:end);
    G_1 = G_1 + label2 * row;
    G_2 = G_2 + label1' * sigmoidX;
end

%ahora actualizamos los valores de Theta1_grad y Theta2_grad

[f1, c1] = size(Theta1);
[f2, c2] = size(Theta2);
[tf1, tc1] = size(Theta1_grad);
[tf2, tc2] = size(Theta2_grad);
[gf1, gc1] = size(G_1);
[gf2, gc2] = size(G_2);

Theta1_grad(:,1) = G_1(:,1)/m; %modificamos la primera columna
%y ahora se modifica el resto de columnas
Theta1_grad(:,2:gc1) = G_1(:,2:gc1)/m + lambda/m*Theta1(:,2:c1).*Theta1(:,2:c1)
%y se hace lo mismo para Theta2_grad
Theta2_grad(:,1) = G_2(:,1)/m;
Theta2_grad(:,2:gc2) = G_2(:,2:gc2)/m + lambda/m*Theta2(:,2:c2).*Theta2(:,2:c2)

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end

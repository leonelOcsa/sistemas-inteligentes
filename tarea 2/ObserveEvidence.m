% ObserveEvidence Modify a vector of factors given some evidence.
%   F = ObserveEvidence(F, E) sets all entries in the vector of factors, F,
%   that are not consistent with the evidence, E, to zero. F is a vector of
%   factors, each a data structure with the following fields:
%     .var    Vector of variables in the factor, e.g. [1 2 3]
%     .card   Vector of cardinalities corresponding to .var, e.g. [2 2 2]
%     .val    Value table of size prod(.card)
%   E is an N-by-2 matrix, where each row consists of a variable/value pair.
%     Variables are in the first column and values are in the second column.

function F = ObserveEvidence(F, E) % el segundo parametro recibe un array de variables valor

% Iterate through all evidence

for i = 1:size(E, 1), %recorremos las variables con sus respectivos valores a ser observados 
    v = E(i, 1); % variable
    x = E(i, 2); % value

    % Check validity of evidence
    if (x == 0),
        warning(['Evidence not set for variable ', int2str(v)]);
        continue;
    end;

    for j = 1:length(F), %recorremos cada uno de los factores
		  % Does factor contain variable?
        indx = find(F(j).var == v) %retorna el indice de la columna var si existe la variable si no lo encuentra retorna []

        if (~isempty(indx)),

		  	   % Check validity of evidence
            if (x > F(j).card(indx) || x < 0 ),
                error(['Invalid evidence, X_', int2str(v), ' = ', int2str(x)]);
            end;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % YOUR CODE HERE
            % Adjust the factor F(j) to account for observed evidence
            % Hint: You might find it helpful to use IndexToAssignment
            %       and SetValueOfAssignment
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            totalValues = length(F(j).val);
            
            assignmentJ = IndexToAssignment(1:length(F(j).val), F(j).card); %listo los assignments para poder detectar las filas que seran observadas
            
            for k=1:totalValues
                varColumn = assignmentJ(k,indx); %extraigo los valores de la columna var a observar
                if varColumn ~= x % de ser diferente al valor que se busca seteamos 0
                    F(j).val(k) = 0;
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				% Check validity of evidence / resulting factor
            if (all(F(j).val == 0)),
                warning(['Factor ', int2str(j), ' makes variable assignment impossible']);
            end;

        end;
    end;
end;

end

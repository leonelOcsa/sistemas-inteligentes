function [c] = naiveBayesOp()
     filename = fopen('car.data');
     C = textscan(filename,'%s %s %s %s %s %s %s', 'Delimiter',',');
     fclose(filename);
     
     a = size(C{:,1}, 1)
     b = size(C,2)
     
     attributes = {}; 
     
     for i=1:b
        attributes{i} = {};
     end
     
     
     for i=1:a
        for j=1:b-1
            %atributo en la posicion j
            flag = 0;
            colValue = 0;
            attrLen = size(attributes{:,j},2);
            for k=1:attrLen
                if ismember(attributes{j}{1,k}, C{1, j}{i})
                    flag = 1;
                    colValue = k;
                end
            end
            if flag == 0
                %len = length(attributes{j});
                if(attrLen > 0)
                    colValue = attrLen+1;
                    attributes{j}{1, attrLen+1} = C{1, j}{i}; 
                else
                    colValue = 1;
                    attributes{j}{1,1} = C{1, j}{i}; 
                end
                      
            end
            
            %comprobamos en que clase estamos
            classFlag = 0;
            rowClass = 0;
            attrLenClass = size(attributes{:,b},2);
            for k=1:attrLenClass
                if ismember(attributes{b}{1,k}, C{1, b}{i})
                    classFlag = 1;
                    rowClass = k+1;
                end
            end
            
            if classFlag == 0
                %classLen = length(attributes{b});
                rowClass = attrLenClass+2;
                attributes{b}{1, attrLenClass+1} = C{1, b}{i};   
            end
            attributes{j}{colValue, 2} = 1;
        end
     end
     %c{1}{4,4} = 44
     c = attributes
end


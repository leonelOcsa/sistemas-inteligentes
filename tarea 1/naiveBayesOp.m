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
            arr = ismember(attributes{j}, C{1, j}{i});
            flag = 0;
            colValue = 0;
            for k=1:length(arr)
                if arr(k) == 1
                    flag = 1;
                    colValue = k;
                end
            end
            if flag == 0
                len = length(attributes{j});
                colValue = len+1;
                attributes{j}{len+1} = C{1, j}{i};   
            end
            
            arrClass = ismember(attributes{b}, C{1, b}{i});
            flagClass = 0;
            indexRowClass = 0; %indica donde a que clase sera insertado el valor
            for k=1:length(arrClass)
                if arrClass(k) == 1
                    flagClass = 1;
                    indexRowClass = k+1;
                end
            end
            if flagClass == 0
                len = length(attributes{b});
                indexRowClass = len+1;
                attributes{b}{len+1} = C{1, b}{i};   
            end
            attributes{j}{indexRowClass, colValue} = 1;
        end
     end
     %c{1}{4,4} = 44
     c = attributes
end


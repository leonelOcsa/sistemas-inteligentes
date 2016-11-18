function [ results ] = naiveBayes()
    buying = {'vhigh', 'high', 'med', 'low'; 1, 1, 1, 1; 1, 1, 1, 1; 1, 1, 1, 1; 1, 1, 1, 1}
    maint = {'vhigh', 'high', 'med', 'low'; 1, 1, 1, 1; 1, 1, 1, 1; 1, 1, 1, 1; 1, 1, 1, 1}
    doors = {'2', '3', '4', '5more'; 1, 1, 1, 1; 1, 1, 1, 1; 1, 1, 1, 1; 1, 1, 1, 1}
    persons = {'2', '4', 'more'; 1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1}
    lug_boot = {'small', 'med', 'big'; 1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1}
    safety = {'low', 'med', 'high'; 1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1}
    
    filename = fopen('car.data');
    C = textscan(filename,'%s %s %s %s %s %s %s', 'Delimiter',',')
    fclose(filename);
    
    unacc = 0;
    acc = 0;
    good = 0;
    vgood = 0;
    
    a = size(C{:,1}, 1);
    b = size(C,2);
    
    for i = 1:a
        if strcmp(C{b}{i}, 'unacc')
            unacc = unacc + 1;
            %buying
            if strcmp(C{1}{i}, 'vhigh')
                buying{2,1} = buying{2,1} + 1;
            elseif strcmp(C{1}{i}, 'high')
                buying{2,2} = buying{2,2} + 1;
            elseif strcmp(C{1}{i}, 'med')
                buying{2,3} = buying{2,2} + 1;
            elseif strcmp(C{1}{i}, 'low')
                buying{2,4} = buying{2,2} + 1;    
            end
            %maint
            if strcmp(C{2}{i}, 'vhigh')
                maint{2,1} = maint{2,1} + 1;
            elseif strcmp(C{2}{i}, 'high')
                maint{2,2} = maint{2,2} + 1;
            elseif strcmp(C{2}{i}, 'med')
                maint{2,3} = maint{2,3} + 1;
            elseif strcmp(C{2}{i}, 'low')
                maint{2,4} = maint{2,4} + 1;
            end
            %doors
            if strcmp(C{3}{i}, '2')
                doors{2,1} = doors{2,1} + 1;
            elseif strcmp(C{3}{i}, '3')
                doors{2,2} = doors{2,2} + 1;
            elseif strcmp(C{3}{i}, '4')
                doors{2,3} = doors{2,3} + 1;
            elseif strcmp(C{3}{i}, '5more')
                doors{2,4} = doors{2,4} + 1;
            end
            %persons
            if strcmp(C{4}{i}, '2')
                persons{2,1} = persons{2,1} + 1;
            elseif strcmp(C{4}{i}, '4')
                persons{2,2} = persons{2,2} + 1;
            elseif strcmp(C{4}{i}, 'more')
                persons{2,3} = persons{2,3} + 1;
            end
            %lug_boot
            if strcmp(C{5}{i}, 'small')
                lug_boot{2,1} = lug_boot{2,1} + 1;
            elseif strcmp(C{5}{i}, 'med')
                lug_boot{2,2} = lug_boot{2,2} + 1;
            elseif strcmp(C{5}{i}, 'big')
                lug_boot{2,3} = lug_boot{2,3} + 1;
            end
            %safety
            if strcmp(C{6}{i}, 'low')
                safety{2,1} = safety{2,1} + 1;
            elseif strcmp(C{6}{i}, 'med')
                safety{2,2} = safety{2,2} + 1;
            elseif strcmp(C{6}{i}, 'high')
                safety{2,3} = safety{2,3} + 1;
            end
        elseif strcmp(C{7}{i}, 'acc')
            acc = acc + 1;
            %buying
            if strcmp(C{1}{i}, 'vhigh')
                buying{3,1} = buying{3,1} + 1;
            elseif strcmp(C{1}{i}, 'high')
                buying{3,2} = buying{3,2} + 1;
            elseif strcmp(C{1}{i}, 'med')
                buying{3,3} = buying{3,2} + 1;
            elseif strcmp(C{1}{i}, 'low')
                buying{3,4} = buying{3,2} + 1;    
            end
            %maint
            if strcmp(C{2}{i}, 'vhigh')
                maint{3,1} = maint{3,1} + 1;
            elseif strcmp(C{2}{i}, 'high')
                maint{3,2} = maint{3,2} + 1;
            elseif strcmp(C{2}{i}, 'med')
                maint{3,3} = maint{3,3} + 1;
            elseif strcmp(C{2}{i}, 'low')
                maint{3,4} = maint{3,4} + 1;
            end
            %doors
            if strcmp(C{3}{i}, '2')
                doors{3,1} = doors{3,1} + 1;
            elseif strcmp(C{3}{i}, '3')
                doors{3,2} = doors{3,2} + 1;
            elseif strcmp(C{3}{i}, '4')
                doors{3,3} = doors{3,3} + 1;
            elseif strcmp(C{3}{i}, '5more')
                doors{3,4} = doors{3,4} + 1;
            end
            %persons
            if strcmp(C{4}{i}, '2')
                persons{3,1} = persons{3,1} + 1;
            elseif strcmp(C{4}{i}, '4')
                persons{3,2} = persons{3,2} + 1;
            elseif strcmp(C{4}{i}, 'more')
                persons{3,3} = persons{3,3} + 1;
            end
            %lug_boot
            if strcmp(C{5}{i}, 'small')
                lug_boot{3,1} = lug_boot{3,1} + 1;
            elseif strcmp(C{5}{i}, 'med')
                lug_boot{3,2} = lug_boot{3,2} + 1;
            elseif strcmp(C{5}{i}, 'big')
                lug_boot{3,3} = lug_boot{3,3} + 1;
            end
            %safety
            if strcmp(C{6}{i}, 'low')
                safety{3,1} = safety{3,1} + 1;
            elseif strcmp(C{6}{i}, 'med')
                safety{3,2} = safety{3,2} + 1;
            elseif strcmp(C{6}{i}, 'high')
                safety{3,3} = safety{3,3} + 1;
            end
        elseif strcmp(C{7}{i}, 'good')
            good = good + 1;
            %buying
            if strcmp(C{1}{i}, 'vhigh')
                buying{4,1} = buying{4,1} + 1;
            elseif strcmp(C{1}{i}, 'high')
                buying{4,2} = buying{4,2} + 1;
            elseif strcmp(C{1}{i}, 'med')
                buying{4,3} = buying{4,3} + 1;
            elseif strcmp(C{1}{i}, 'low')
                buying{4,4} = buying{4,4} + 1;    
            end
            %maint
            if strcmp(C{2}{i}, 'vhigh')
                maint{4,1} = maint{4,1} + 1;
            elseif strcmp(C{2}{i}, 'high')
                maint{4,2} = maint{4,2} + 1;
            elseif strcmp(C{2}{i}, 'med')
                maint{4,3} = maint{4,3} + 1;
            elseif strcmp(C{2}{i}, 'low')
                maint{4,4} = maint{4,4} + 1;
            end
            %doors
            if strcmp(C{3}{i}, '2')
                doors{4,1} = doors{4,1} + 1;
            elseif strcmp(C{3}{i}, '3')
                doors{4,2} = doors{4,2} + 1;
            elseif strcmp(C{3}{i}, '4')
                doors{4,3} = doors{4,3} + 1;
            elseif strcmp(C{3}{i}, '5more')
                doors{4,4} = doors{4,4} + 1;
            end
            %persons
            if strcmp(C{4}{i}, '2')
                persons{4,1} = persons{4,1} + 1;
            elseif strcmp(C{4}{i}, '4')
                persons{4,2} = persons{4,2} + 1;
            elseif strcmp(C{4}{i}, 'more')
                persons{4,3} = persons{4,3} + 1;
            end
            %lug_boot
            if strcmp(C{5}{i}, 'small')
                lug_boot{4,1} = lug_boot{4,1} + 1;
            elseif strcmp(C{5}{i}, 'med')
                lug_boot{4,2} = lug_boot{4,2} + 1;
            elseif strcmp(C{5}{i}, 'big')
                lug_boot{4,3} = lug_boot{4,3} + 1;
            end
            %safety
            if strcmp(C{6}{i}, 'low')
                safety{4,1} = safety{4,1} + 1;
            elseif strcmp(C{6}{i}, 'med')
                safety{4,2} = safety{4,2} + 1;
            elseif strcmp(C{6}{i}, 'high')
                safety{4,3} = safety{4,3} + 1;
            end
        elseif strcmp(C{7}{i}, 'vgood')
            vgood = vgood + 1;
            %buying
            if strcmp(C{1}{i}, 'vhigh')
                buying{5,1} = buying{5,1} + 1;
            elseif strcmp(C{1}{i}, 'high')
                buying{5,2} = buying{5,2} + 1;
            elseif strcmp(C{1}{i}, 'med')
                buying{5,3} = buying{5,3} + 1;
            elseif strcmp(C{1}{i}, 'low')
                buying{5,4} = buying{5,4} + 1;    
            end
            %maint
            if strcmp(C{2}{i}, 'vhigh')
                maint{5,1} = maint{5,1} + 1;
            elseif strcmp(C{2}{i}, 'high')
                maint{5,2} = maint{5,2} + 1;
            elseif strcmp(C{2}{i}, 'med')
                maint{5,3} = maint{5,3} + 1;
            elseif strcmp(C{2}{i}, 'low')
                maint{5,4} = maint{5,4} + 1;
            end
            %doors
            if strcmp(C{3}{i}, '2')
                doors{5,1} = doors{5,1} + 1;
            elseif strcmp(C{3}{i}, '3')
                doors{5,2} = doors{5,2} + 1;
            elseif strcmp(C{3}{i}, '4')
                doors{5,3} = doors{5,3} + 1;
            elseif strcmp(C{3}{i}, '5more')
                doors{5,4} = doors{5,4} + 1;
            end
            %persons
            if strcmp(C{4}{i}, '2')
                persons{5,1} = persons{5,1} + 1;
            elseif strcmp(C{4}{i}, '4')
                persons{5,2} = persons{5,2} + 1;
            elseif strcmp(C{4}{i}, 'more')
                persons{5,3} = persons{5,3} + 1;
            end
            %lug_boot
            if strcmp(C{5}{i}, 'small')
                lug_boot{5,1} = lug_boot{5,1} + 1;
            elseif strcmp(C{5}{i}, 'med')
                lug_boot{5,2} = lug_boot{5,2} + 1;
            elseif strcmp(C{5}{i}, 'big')
                lug_boot{5,3} = lug_boot{5,3} + 1;
            end
            %safety
            if strcmp(C{6}{i}, 'low')
                safety{5,1} = safety{5,1} + 1;
            elseif strcmp(C{6}{i}, 'med')
                safety{5,2} = safety{5,2} + 1;
            elseif strcmp(C{6}{i}, 'high')
                safety{5,3} = safety{5,3} + 1;
            end
        end
    end
    %buying
    for i = 2:5
        t = 0;
        for j = 1:4
            t = t + buying{i,j};
        end
        for j = 1:4
            buying{i,j} = buying{i,j}/t; 
        end
    end
    %maint
    for i = 2:5
        t = 0;
        for j = 1:4
            t = t + maint{i,j};
        end
        for j = 1:4
            maint{i,j} = maint{i,j}/t; 
        end
    end
    %doors
    for i = 2:5
        t = 0;
        for j = 1:4
            t = t + doors{i,j};
        end
        for j = 1:4
            doors{i,j} = doors{i,j}/t; 
        end
    end
    %persons
    for i = 2:5
        t = 0;
        for j = 1:3
            t = t + persons{i,j};
        end
        for j = 1:3
            persons{i,j} = persons{i,j}/t; 
        end
    end
    %lug_boot
    for i = 2:5
        t = 0;
        for j = 1:3
            t = t + lug_boot{i,j};
        end
        for j = 1:3
            lug_boot{i,j} = lug_boot{i,j}/t; 
        end
    end
    %safety
    for i = 2:5
        t = 0;
        for j = 1:3
            t = t + safety{i,j};
        end
        for j = 1:3
            safety{i,j} = safety{i,j}/t; 
        end
    end
    %a continuacion se muestran las tablas de probabilidades de cada
    %atributo para cada clase, cada fila es una clase y va en el siguiente
    %orden unacc, acc, good y vgood
    buying
    maint
    doors
    persons
    lug_boot
    safety
    
    allAttr = {buying, maint, doors, persons, lug_boot, safety};
    
    test = ['low', 'low', '4', '2', 'big', 'high'];
    
    total = unacc + acc + good + vgood;
    unacc = unacc/total;
    acc = acc/total;
    good = good/total;
    vgood = vgood/total;
    
    filename = fopen('car-prueba.data');
    A = textscan(filename,'%s %s %s %s %s %s %s', 'Delimiter',',');
    fclose(filename);
    %A = string(A);
    %celldisp(A);
    
    classes = {'unacc', 'acc', 'good', 'vgood'};
    
    a = size(A{:,1}, 1);
    b = size(A,2);
    
    for i=1:a
        unacc_f = unacc;
        acc_f = acc;
        good_f = good;
        vgood_f = vgood;
        for j=1:b-1
            v = A{j}{i};
            allAttr{j};
            [x,y] = find(strcmp(allAttr{j},A{j}{i}));
            allAttr{j}{2,y};
            unacc_f = unacc_f *allAttr{j}{2,y}; 
            acc_f = acc_f *allAttr{j}{3,y};
            good_f = good_f *allAttr{j}{4,y};
            vgood_f = vgood_f *allAttr{j}{5,y};
        end
        
        mn = [unacc_f acc_f good_f vgood_f];
        [index] = find(mn == max(mn));
        A{b}{i} = classes{1,index};
    end
    %result{1,7} para ver los resultados
    results = A;
    
    display('TABLA DE RESULTADOS');
    
    for i=1:a
        s = '';
        s = strcat(s, num2str(i));
        s = strcat(' | ', s );
        s = strcat(s, ' |' );
        for j=1:b
            rl = 10;
            wl = length(results{1, j}{i});
            diff = rl - wl;
            s = strcat(s, results{1, j}{i});
            for k=1:diff
                s = strcat(s, '_');
            end
            s = strcat(s, ' | ');
        end
        s1 = sprintf(s);
        %s2 = sprintf('\n');
        disp(s1);
        %display(s2);
    end
end


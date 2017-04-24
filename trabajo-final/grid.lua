N = 20 --numero de filas que tendra el grid del mundo, en realidad solo 13
M = 220 --numero de columnas del escenario total, en realidad solo 200
grid = {}
for i=1, N do 
    grid[i] = {} --creamos las N filas
    for j=1, M do 
        grid[i][j] = tostring((i-1)*16) .. "_" .. tostring((j-1)*16) .. ".txt"
    end
end
--grid2 para clasificar los bloques como:
--aire = -1
--bloque = -2
--coin = -3
--question = -4
--agujero = -5
--monstruo = -6
grid2 = {}
for i=1, N do 
    grid2[i] = {} --creamos las N filas
    for j=1, M do 
        grid2[i][j] = -1
    end
end

--funcion para conocer si hay agujero cerca
function isPitClose(y, x, range)
    isPit = false
    i = y
    j = x - range
    iLimit = i + 10
    jLimit = j + range*2
    --print(i .. " - " .. iLimit)
    --print(j .. " - " .. jLimit)
    if(i < 1) then 
        i = 1
        iLimit = i + 10
    end    
    if(j < 1) then 
        j = 1
        jLimit = j + range
    end
    if(iLimit > 20) then
        iLimit = 20
    end
    
    for a = i, iLimit do 
        for b = j, jLimit do 
            if(grid2[a][b] == -5) then
                isPit = true
            end    
        end
    end 
    return isPit
end

--funcion para saber si un archivo existe o no
function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

--funcion para convertir los datos del archivo en una tabla (matriz)
--a base de espacios y saltos de linea
function fileToTable(fname)
    local Q = {}
    local file = io.open(fname, "r")
    for line in file:lines () do 
        words = {}
        for word in line:gmatch("%S+") do table.insert(words, tonumber(word)) end  
        table.insert(Q, words)
    end 
    file:close()
    return Q
end

--funcion para guardar una tabla en un archivo
function tableToFile(Q, fname)
    --os.remove(fname)
    file = io.open(fname, "w+")
    for i = 1, table.getn(Q) do
        line = ""
        for j = 1, table.getn(Q[i]) do 
            line = line .. tostring(Q[i][j]) .. " "
        end
        line = line .. "\n"
        file:write(line)
    end
    file:close()
end
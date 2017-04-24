
require("grid") --de aqui cargo mi grid

player1 = 1
--lista de botones
right = false
left = false
A = true --este boton corresponde al salto
B = false

--LISTA DE ACCIONES
actions = {
    false, --go right 
    false, --go left
    false, --jump
    false, --right and jump
    false, --left and jump
    false --quiet
} 

memory.writebyte(0x075A,100) --modificamos el numero de vidas de mario
--memory.writebyte(0x0772, 3)


buttons = {}
buttons["right"] = right
buttons["left"] = left
buttons["A"] = A

function pressButtons()
    buttons["right"] = right
    buttons["left"] = left
    buttons["A"] = A 
    joypad.set(player1, buttons)
end

--segun la opcion elegida cambiamos los valores de los botones
function updateButtons(action)
    if(action == 1) then --si es moverse a la derecha
        right = true
        left = false
        A = false
    else 
        if (action == 2) then --si es moverse a la izquierda
            right = false
            left = true
            A = false
        else
            if (action == 3) then --si es solo saltar
                right = false
                left = false
                A = true
            else
                if (action == 4) then --si es ir a la derecha y saltar 
                    right = true 
                    left = false
                    A = true
                else
                    if (action == 5) then --si es ir a la izquierda y saltar
                        right = false
                        left = true
                        A = true
                    else
                        if (action == 6) then --si la accion es quedarse quieto
                            right = false
                            left = false
                            A = false
                        end
                    end
                end 
            end
        end    
    end
end

--funcion que segun las coordenadas de mario retorna la posicion respectiva de la grilla del mundo
function getGridIndices(marioX, marioY)
    x = marioX / 16
    x = math.floor(x) + 1

    y = marioY / 16
    y = math.floor(y) + 1

    return {y, x}
end

--Retorna los indices del maximo valor de un vector
function max_indices(v)
  max = math.max(unpack(v))
  indices = {}
  j = 1
  for i = 1, table.getn(v) do
    if max == v[i] then
      table.insert(indices, j, i)
      j = j + 1
    end 
  end
  return indices
end

--funciones adicionales

function draw_text ()
  marioX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86) --posicion en X
  marioY = memory.readbyte(0x03B8)+16 --posicion en Y 
  emu.message("X = " .. marioX ..", Y = " .. marioY)
end

function set_state ()
  level1_start = savestate.object(1)
  savestate.save(level1_start)

end

function init ()
  set_state()
end

--print(file_exists("w11/192_1584.txt"))

--Q = fileToTable("w11/" .. "192_0.txt")
--print(Q)


--file:write("Hello Wosdrld 2")
--file:close()

count = 0
previousAction = 6 --iniciamos con mario en estado quieto
previousMarioX = 0
previousMarioY = 0
previousQfile = "test.txt"
player_dies = 11 --mario muere =(
player_state = 0
float = 0
previousFloat = -1
player_vertical_position = 1

--especiales
olderQfile = "test.txt"
olderPreviousAction = 0
olderAction = 0
olderMarioX = 40
wasPitClose = false
flagRun = false

Qstack = {}
QpreviousActions = {}
Qactions = {}
marioIsfalling = false

vertical_position = 1

range = 1

pitClose = false

--epsilon = 1
learningRate =  1.0 --0.9 --0.7  
gamma = 0.1 --1.0 --0.2 

k = 0

if(file_exists("w11/grid_iterations.txt") == true) then

else
    file = io.open("w11/grid_iterations.txt", "w") --empezamos a escribir
    N = 20 --numero de filas que tendra el grid del mundo, en realidad solo 13
    M = 220 --numero de columnas del escenario total, en realidad solo 200
    for i=1, N do 
        s = ""
        for j=1, M do 
            s = s .. 1 .. " " --inicializamos todos los contadores en 1 para cada grid
        end
        file:write(s .. "\n")
    end
    file:close()
end

flag = true

counter_ = 0;

init()
while true do
    epsilon = math.random(1, 100)
    --print(epsilon)

    vertical_position = memory.readbyte(0x00B5);

    marioX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86) --posicion en X
    marioY = memory.readbyte(0x03B8)+16 --posicion en Y 
    player_state = memory.readbyte(0x000E) 
    float = memory.readbyte(0x001D) --indica el estado de mario 0 si esta sobre una superficie o 1 si esta volando
    player_vertical_position = memory.readbyte(0x00B5)
    gridIndex = getGridIndices(marioX, marioY) --obtenemos los indices de la grilla segun la posicion de mario
    Qfile = grid[gridIndex[1]][gridIndex[2]] --obtenemos el nombre de su archivo respectivo
    --print(Qfile)
    if(file_exists("w11/" .. Qfile) == true) then --coprobamos si el archivo existe
        --Aqui hacemos los calculos
    else --si no existe lo creamos
        file = io.open("w11/" .. Qfile, "w")
        --[[
        file:write("0 0 10 10 0 -10 \n")
        file:write("0 0 0 0 0 0 \n")
        file:write("0 0 10 10 0 -10 \n")
        file:write("0 0 10 10 0 -10 \n")
        file:write("0 0 10 10 0 -10 \n")
        file:write("0 0 0 0 0 -10 \n")
        --]]
        file:write("0 0 0 0 0 0 \n")
        file:write("0 0 0 0 0 0 \n")
        file:write("0 0 0 0 0 0 \n")
        file:write("0 0 0 0 0 0 \n")
        file:write("0 0 0 0 0 0 \n")
        file:write("0 0 0 0 0 0 \n")
        
        file:close()
    end
    
    --print(player_state)
    Q = fileToTable("w11/" .. Qfile)
    
    --gridIterations = fileToTable("w11/grid_iterations.txt") --obtenemos la tabla de iteraciones de cada celda
    --gridIterations[gridIndex[1]][gridIndex[2]] = gridIterations[gridIndex[1]][gridIndex[2]] + 1
    --tableToFile(gridIterations, "w11/grid_iterations.txt")
    
    --print(1/gridIterations[gridIndex[1]][gridIndex[2]])

    --print("w11/" .. Qfile)
    --print(float)

    if(player_state == 8) then flag = true end
    flag2 = true
    
    --print(" epsilon " .. epsilon)
    
    if(epsilon > 95) then --realiza una exploracion aleatoria
        action = math.random(1, table.getn(actions)) --mario toma una accion de forma aleatoria
        --si mario estuvo saltando mientras estaba en el aire y
        --en la siguiente accion (accion actual) sigue manteniendo la misma accion de salto o similar 

        if(float == 0) then 
            --if(previousAction == 4 and action == 4) then 
                --action = 6
            --end
            --while(previousAction == action) do 
                --action = math.random(1, table.getn(actions))
            --end
            --[[
            if(previousAction == 4 and action == 4) then 
                action =  1 --cambiamos la accion por una arbitraria a la derecha
            else 
                if(previousAction == 3 and action == 4) then
                    action = 1
                else
                    if(previousAction == 4 and action == 3) then
                        action = 1
                    else
                        if(previousAction == 3 and action == 3) then
                            action = 1
                        else
                            if(previousAction == 5 and action == 4) then
                                action = 1 
                            end
                        end
                    end
                end
            end
            --]]
        end
        

        reward = 0 --inicializamos un reward local que recibira por la accion realizada
        
        --si hay un agujero cerca
        if(marioY < 206) then 
            pitClose = isPitClose(gridIndex[1],gridIndex[2], range)
            if(pitClose == true) then
                --print("agujero cerca " .. marioX .. " " .. marioY)
                if(action ~= 4) then 
                    action = 4
                end
            end
        end

        if(float == 1) then --mientras mario esta en el aire
            if(action == 3) then --si la accion es jump  
                reward = 100
            else 
                if(action == 4) then --si la accion es jump a la derecha 
                    reward = 300
                else 
                    if(action == 6) then --si la accion es quieto
                        reward = -50
                    end 
                end
            end
        end

        if(flagRun == true) then 
            action = 1
            flagRun = false
        end

        --print(float .. " " .. action)
        --ejecutamos la accion actual
        updateButtons(action)
        pressButtons()
        
        if(player_state == player_dies) then --si mario muere asesinado
            --print("mario muere")
            reward = -100
            flag = false
            marioIsfalling = false
            wasPitClose = false
        end
        if(marioY > 192 and player_state ~= player_dies) then --si mario muere por caida 
            reward = -100
            flag = false
        end

        if(player_state == 0) then --si mario entra en la pantalla de carga
            flag = false
            marioIsfalling = false
            wasPitClose = false
        end

        if(player_state == 7) then --si mario esta entradndo al area
            flag = false
            marioIsfalling = false
            wasPitClose = false
        end

        --Q[previousAction][action] = -1 + reward + Q[previousAction][action] + learningRate * math.max(unpack(Q[action]))
        Q[previousAction][action] = Q[previousAction][action] + learningRate *(reward + gamma * math.max(unpack(Q[action])) - Q[previousAction][action]) 
        tableToFile(Q, "w11/" .. Qfile)
        if(marioX%16 == 0) then --comprobamos si mario entra a una celda de la grilla
            if(previousMarioX < marioX) then --comprobamos si fue hacia delante
                reward = reward + 500 --le damos un reward positivo
                pQ = fileToTable("w11/" .. previousQfile)
                --pQ[previousAction][action] = reward + pQ[previousAction][action] + learningRate * math.max(unpack(pQ[action]))
                pQ[previousAction][action] = pQ[previousAction][action] + learningRate *(reward + gamma * math.max(unpack(pQ[action])) - pQ[previousAction][action])
                tableToFile(pQ, "w11/" .. previousQfile)
            end
        else 
            if(previousMarioX%16 == 0) then --comprobamos si mario estuvo en el limite de una celda
                if(marioX < previousMarioX) then --si mario retrocede
                    reward = reward - 100 --le damos un reward negativo
                    pQ = fileToTable("w11/" .. previousQfile)
                    --pQ[previousAction][action] = reward + pQ[previousAction][action] + learningRate * math.max(unpack(pQ[action]))
                    pQ[previousAction][action] = pQ[previousAction][action] + learningRate *(reward + gamma * math.max(unpack(pQ[action])) - pQ[previousAction][action])
                    tableToFile(pQ, "w11/" .. previousQfile)
                end
            end
        end
    else
        --print(Q [previousAction])
        indices = max_indices(Q[previousAction])
        opt_index = math.random(1, table.getn(indices))
        action = indices[opt_index]
        
        --si hay un agujero cerca
        if(marioY < 206) then 
            pitClose = isPitClose(gridIndex[1],gridIndex[2], range)
            if(pitClose == true) then
                --print("agujero cerca")
                if(action ~= 4) then 
                    action = 4
                end
            end
        end

        if(flagRun == true) then
            --print("sdsdsdsd") 
            action = 1
            flagRun = false
        end

        --print(float .. " " .. action)
        updateButtons(action)
        pressButtons()
        
        if(flag2 == true) then
            reward = 0
            if(player_state == player_dies) then --si mario muere asesinado
                --print("muero")
                reward = -100
                Q[previousAction][action] = Q[previousAction][action] + learningRate *(reward + gamma * math.max(unpack(Q[action])) - Q[previousAction][action])
                tableToFile(Q, "w11/" .. Qfile)
                if(marioX%16 == 0) then --comprobamos si mario entra a una celda de la grilla
                    if(previousMarioX < marioX) then --comprobamos si fue hacia delante
                        reward = reward + 500 --le damos un reward positivo
                        pQ = fileToTable("w11/" .. previousQfile)
                        pQ[previousAction][action] = pQ[previousAction][action] + learningRate *(reward + gamma * math.max(unpack(pQ[action])) - pQ[previousAction][action])
                        tableToFile(pQ, "w11/" .. previousQfile)
                    end
                else 
                    if(previousMarioX%16 == 0) then --comprobamos si mario estuvo en el limite de una celda
                        if(marioX < previousMarioX) then --si mario retrocede
                            reward = reward - 100 --le damos un reward negativo
                            pQ = fileToTable("w11/" .. previousQfile)
                            pQ[previousAction][action] = pQ[previousAction][action] + learningRate *(reward + gamma * math.max(unpack(pQ[action])) - pQ[previousAction][action])
                            tableToFile(pQ, "w11/" .. previousQfile)
                        end
                    end
                end
            end
        end
    end
    if(flag2 == true) then
        if(previousFloat == 0 and float == 0) then 
            --print(action)
        end
        
        --ahora pregunto y almaceno el ultimo estado donde mario estuvo en tierra 
        --si anteriormente mario estuvo en tierra y ahora esta en el aire
        if(previousFloat == 0 and float == 1 and marioIsfalling == false) then
            --print(" ss " .. gridIndex[1] .. " " .. gridIndex[2])
            wasPitClose = isPitClose(gridIndex[1],gridIndex[2], range) 
            --print("marioIsfalling")
            olderMarioX = marioX 
            table.insert(Qstack, previousQfile) --insertamos en la pila de Qs
            table.insert(QpreviousActions, previousAction) --insertamos en la pila de acciones previas
            table.insert(Qactions, action) --insertamos en la pila de acciones
            --olderQfile = previousQfile
            --olderPreviousAction = previousAction
            --olderAction = action
            --print(olderQfile .. " " .. olderPreviousAction .. " " .. olderAction .. " " .. epsilon)
        end

        --ahora ocurre lo siguiente que mario este en el aire por lo tanto guardamos sus acciones y estados Q
        if(previousFloat == 1 and float == 1 and marioIsfalling == false) then 
            table.insert(Qstack, previousQfile) --insertamos en la pila de Qs
            table.insert(QpreviousActions, previousAction) --insertamos en la pila de acciones previas
            table.insert(Qactions, action) --insertamos en la pila de acciones
        end
        --que pasa si mario salta y resbala para caer
        if(previousFloat == 1 and float == 2 and marioIsfalling == false) then 
            table.insert(Qstack, previousQfile) --insertamos en la pila de Qs
            table.insert(QpreviousActions, previousAction) --insertamos en la pila de acciones previas
            table.insert(Qactions, action) --insertamos en la pila de acciones
        end
        --si mario salta con exito y cae en tierra
        if(previousFloat == 1 and float == 0 and player_state ~= player_dies) then 
            reward = 500
            for k in pairs (Qstack) do
                if(math.abs(olderMarioX - marioX) > 32) then 
                    if(QpreviousActions[k] == 4 and Qactions[k] == 4) then
                        tmpQ = fileToTable("w11/" .. Qstack[k])
                        tmpQ[QpreviousActions[k]][Qactions[k]] = tmpQ[QpreviousActions[k]][Qactions[k]] + learningRate *(reward + gamma * math.max(unpack(tmpQ[Qactions[k]])) - tmpQ[QpreviousActions[k]][Qactions[k]])
                        tableToFile(tmpQ, "w11/" .. Qstack[k])
                    end
                end
                Qstack[k] = nil
                QpreviousActions[k] = nil
                Qactions[k] = nil 
            end
            Qstack = {}
            QpreviousActions = {}
            Qactions = {}
            --para que no se repita la secuencia de botones porque al paretar B seguido el salto pierde efecto
            flagRun = true
        end 
    end
    --print("action " .. action)
    --if(marioY > 192) then
    --    grid2[gridIndex[1]][gridIndex[2]] = -5 --actualizamos ese bloque como agujero
    --end 
    --print(float)
    if(float == 0) then 
        --print(float .. " x " .. marioX)
    end


    if(flag2 == true) then
        if(player_state == player_dies) then
            reward = -100
            --print("entre " .. table.getn(QpreviousActions))
            for k in pairs (Qstack) do
                --print("entre 2 " .. k)
                --print(previousFloat)
                --ss = ss .. " " .. Qstack[k] .. " " .. QpreviousActions[k]
                qflag = false
                if(QpreviousActions[k] == 3 and Qactions[k] == 6) then 
                    qflag = true
                end
                if(QpreviousActions[k] == 3 and Qactions[k] == 2) then 
                    qflag = true
                end
                if(QpreviousActions[k] == 4 and Qactions[k] == 6) then 
                    qflag = true
                end
                if(QpreviousActions[k] == 4 and Qactions[k] == 5) then 
                    qflag = true
                end 
                if(QpreviousActions[k] == 4 and Qactions[k] == 2) then 
                    qflag = true
                end
                if(QpreviousActions[k] == 4 and Qactions[k] == 1) then 
                    qflag = true
                end
                if(QpreviousActions[k] == 5 and Qactions[k] == 6) then 
                    qflag = true
                end 
                if(QpreviousActions[k] == 5 and Qactions[k] == 5) then 
                    qflag = true
                end
                if(QpreviousActions[k] == 5 and Qactions[k] == 4) then 
                    qflag = true
                end
                if(QpreviousActions[k] == 5 and Qactions[k] == 3) then 
                    qflag = true
                end 
                if(QpreviousActions[k] == 5 and Qactions[k] == 2) then 
                    qflag = true
                end    
                if(QpreviousActions[k] == 5 and Qactions[k] == 1) then 
                    qflag = true
                end  
                if(qflag == true) then 
                    tmpQ = fileToTable("w11/" .. Qstack[k])
                    tmpQ[QpreviousActions[k]][Qactions[k]] = tmpQ[QpreviousActions[k]][Qactions[k]] + learningRate *(reward + gamma * math.max(unpack(tmpQ[Qactions[k]])) - tmpQ[QpreviousActions[k]][Qactions[k]])
                    tableToFile(tmpQ, "w11/" .. Qstack[k])
                end
                Qstack[k] = nil
                QpreviousActions[k] = nil
                Qactions[k] = nil
            end
            Qstack = {}
            QpreviousActions = {}
            Qactions = {}
        end 
        if(marioY >= 192 and marioY <= 195 and float == 1 and player_state ~= player_dies and vertical_position == 1) then --si mario esta en el aire y empieza a caer en un agujero 
            marioIsfalling = true
            --print("me caigo")
            reward = -100
            ss = ""
            if(wasPitClose == true) then
                --print("antes de saltar habia un agujero, salte desde " .. olderMarioX)
                for k in pairs (Qstack) do
                    ss = ss .. " " .. QpreviousActions[k]
                    qflag = false
                    if(QpreviousActions[k] == 3 and Qactions[k] == 6) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 3 and Qactions[k] == 2) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 4 and Qactions[k] == 6) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 4 and Qactions[k] == 5) then 
                        qflag = true
                    end 
                    if(QpreviousActions[k] == 4 and Qactions[k] == 2) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 4 and Qactions[k] == 1) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 5 and Qactions[k] == 6) then 
                        qflag = true
                    end 
                    if(QpreviousActions[k] == 5 and Qactions[k] == 5) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 5 and Qactions[k] == 4) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 5 and Qactions[k] == 3) then 
                        qflag = true
                    end 
                    if(QpreviousActions[k] == 5 and Qactions[k] == 2) then 
                        qflag = true
                    end    
                    if(QpreviousActions[k] == 5 and Qactions[k] == 1) then 
                        qflag = true
                    end  
                    if(qflag == true) then 
                        tmpQ = fileToTable("w11/" .. Qstack[k])
                        tmpQ[QpreviousActions[k]][Qactions[k]] = tmpQ[QpreviousActions[k]][Qactions[k]] + learningRate *(reward + gamma * math.max(unpack(tmpQ[Qactions[k]])) - tmpQ[QpreviousActions[k]][Qactions[k]])
                        tableToFile(tmpQ, "w11/" .. Qstack[k])
                    end
                    Qstack[k] = nil
                    QpreviousActions[k] = nil
                    Qactions[k] = nil 
                end
            else
                --if (table.getn(Qstack) > 0) then
                    --tmpQ = fileToTable("w11/" .. Qstack[1])
                    --tmpQ[QpreviousActions[1]][Qactions[1]] = tmpQ[QpreviousActions[1]][Qactions[1]] + learningRate *(reward + gamma * math.max(unpack(tmpQ[Qactions[1]])) - tmpQ[QpreviousActions[1]][Qactions[1]])
                    --tableToFile(tmpQ, "w11/" .. Qstack[1])
                --end
                --print("antes de saltar no habia un agujero pero me cai")
            end
            --print(ss .. "\n")
            Qstack = {}
            QpreviousActions = {}
            Qactions = {}
            --olderQ = fileToTable("w11/" .. olderQfile)
            --olderQ[olderPreviousAction][olderAction] = olderQ[olderPreviousAction][olderAction] + learningRate *(reward + gamma * math.max(unpack(olderQ[olderAction])) - olderQ[olderPreviousAction][olderAction])
            --tableToFile(olderQ, "w11/" .. olderQfile)
            grid2[gridIndex[1]][gridIndex[2]] = -5 --clasificamos celdas como agujero
        end
        if(marioY >= 192 and marioY <= 195 and float == 2 and player_state ~= player_dies and vertical_position == 1) then --si mario esta resbalando por un bloque y luego cae
            marioIsfalling = true
            --print("me caigo 2")
            --print(table.getn(Qstack))
            reward = -100
            ss = ""
            if(wasPitClose == true) then
                for k in pairs (Qstack) do
                    ss = ss .. " " .. QpreviousActions[k]
                    qflag = false
                    if(QpreviousActions[k] == 3 and Qactions[k] == 6) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 3 and Qactions[k] == 2) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 4 and Qactions[k] == 6) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 4 and Qactions[k] == 5) then 
                        qflag = true
                    end 
                    if(QpreviousActions[k] == 4 and Qactions[k] == 2) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 4 and Qactions[k] == 1) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 5 and Qactions[k] == 6) then 
                        qflag = true
                    end 
                    if(QpreviousActions[k] == 5 and Qactions[k] == 5) then 
                        qflag = true
                    end 
                    if(QpreviousActions[k] == 5 and Qactions[k] == 4) then 
                        qflag = true
                    end
                    if(QpreviousActions[k] == 5 and Qactions[k] == 3) then 
                        qflag = true
                    end 
                    if(QpreviousActions[k] == 5 and Qactions[k] == 2) then 
                        qflag = true
                    end    
                    if(QpreviousActions[k] == 5 and Qactions[k] == 1) then 
                        qflag = true
                    end  
                    if(qflag == true) then
                        tmpQ = fileToTable("w11/" .. Qstack[k])
                        tmpQ[QpreviousActions[k]][Qactions[k]] = tmpQ[QpreviousActions[k]][Qactions[k]] + learningRate *(reward + gamma * math.max(unpack(tmpQ[Qactions[k]])) - tmpQ[QpreviousActions[k]][Qactions[k]])
                        tableToFile(tmpQ, "w11/" .. Qstack[k])
                    end
                    Qstack[k] = nil
                    QpreviousActions[k] = nil
                    Qactions[k] = nil 
                end
            end
            Qstack = {}
            QpreviousActions = {}
            Qactions = {}       
            --print(ss .. "\n")
            --olderQ = fileToTable("w11/" .. olderQfile)
            --olderQ[olderPreviousAction][olderAction] = olderQ[olderPreviousAction][olderAction] + learningRate *(reward + gamma * math.max(unpack(olderQ[olderAction])) - olderQ[olderPreviousAction][olderAction])
            --tableToFile(olderQ, "w11/" .. olderQfile)
            grid2[gridIndex[1]][gridIndex[2]] = -5
        end
    end

    --print(action)
    --updateButtons(action)
    --pressButtons()

    --print(grid[13][100])

    --print(k)

    if(flag == true) then
        previousAction = action --actualizamos la accion previa para el siguiente episodio
    else 
        previousAction = 6
    end
    previousMarioX = marioX
    previousMarioY = marioY
    previousFloat = float
    previousQfile = Qfile
    count = count + 1
    k = k + 1
    draw_text()
    emu.frameadvance()
end
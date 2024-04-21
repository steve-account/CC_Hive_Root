trtl = 'false'
pckt_cmp = 'false'
cmd_cmp = 'false'
pc_cmp = 'false'
my_name = "'" .. os.getComputerLabel() .. "'"
my_id = os.getComputerID()
function getDeviceType()
    if turtle then
        trtl = 'true'
        saveState("trtl",trtl)
        saveState("pckt_cmp",pckt_cmp)
        saveState("cmd_cmp",cmd_cmp)
        saveState("pc_cmp",pc_cmp)
        saveState("my_name",my_name)
        saveState("my_id",my_id)
        calibrate_turtle()
    elseif pocket then
        pckt_cmp = 'true'
    elseif commands then
        cmd_cmp = 'true'
    else
        pc_cmp = 'true'
        saveState("trtl",trtl)
        saveState("pckt_cmp",pckt_cmp)
        saveState("cmd_cmp",cmd_cmp)
        saveState("pc_cmp",pc_cmp)
        saveState("my_name",my_name)
        saveState("my_id",my_id)
        calibrate_pc()
    end
end
function saveState(stateKey, newValue)
    local filename = "/state.lua"
    local lines = {}
    local found = false
    local serializedValue
    if type(newValue) == "table" then
        serializedValue = textutils.serialize(newValue)
    else
        serializedValue = newValue
    end
    local file = fs.open(filename, "r")
    if file then
        while true do
            local line = file.readLine()
            if line == nil then break end
            if line:find("^" .. stateKey .. " =") then
                line = stateKey .. " = " .. serializedValue
                found = true
            end
            table.insert(lines, line)
        end
        file.close()
    end
    if not found then
        table.insert(lines, stateKey .. " = " .. serializedValue)
    end
    file = fs.open(filename, "w")
    for _, line in ipairs(lines) do
        file.writeLine(line)
    end
    file.close()
end
function calibrate_turtle()
    local sx, sy, sz = gps.locate()
    if not turtle.forward() then return false end
    local nx, ny, nz = gps.locate()
    if nx == sx + 1 then
        orientation = 'east'
    elseif nx == sx - 1 then
        orientation = 'west'
    elseif nz == sz + 1 then
        orientation = 'south'
    elseif nz == sz - 1 then
        orientation = 'north'
    else
        return false
    end
    orientation = "'" .. orientation .. "'"

    turtle.back()
    location = string.format("{x = %s, y = %s, z = %s}", nx, ny ,nz)
    saveState("orientation",orientation)
    saveState("location",location)
    return true
end
function calibrate_pc()
    local nx, ny, nz = gps.locate()
    location = string.format("{x = %s, y = %s, z = %s}", nx, ny ,nz)
    saveState("location",location)
end
function gps_on_check()
    local sx, sy, sz = gps.locate()
    if not sx or not sy or not sz then
        print("no gps found retaining location info")
        return false
    else
        getDeviceType()
    end
end
gps_on_check()



for index, value in ipairs(who_am_i) do
    if type(value) == "table" then
        for subkey, subvalue in pairs(value) do
            saveState(tostring(subkey),"'" .. subvalue .. "'")
        end
    else
        saveState(tostring(index),value)
    end
end


who_am_i = {
    cmp_type = {
        trtl = false,
        pckt_cmp = false,
        cmd_cmp = false,
        pc_cmp = false
    },
    
    my_id = id,
    --my_name = "'" .. os.getComputerLabel() .. "'"
    
    
    }

    if turtle then
        who_am_i.cmp_type.trtl = true
    elseif pocket then
        who_am_i.cmp_type.pckt_cmp = true
    elseif commands then
        who_am_i.cmp_type.cmd_cmp = true
    else
        who_am_i.cmp_type.pc_cmp = true
    end
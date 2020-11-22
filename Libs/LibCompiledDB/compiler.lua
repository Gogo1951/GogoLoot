LibCompiledDB.compiler = {}

local stream = LibCompiledDB.stream:GetStream("raw")
local serial = LibCompiledDB.serial

serial.enableObjectLimit = false

LibCompiledDB.compiler.readers = {
    ["u8"] = stream.ReadByte,
    ["u16"] = stream.ReadShort,
    ["s16"] = function(stream)
        return stream:ReadShort() - 32767
    end,
    ["u24"] = stream.ReadInt24,
    ["u32"] = stream.ReadInt,
    ["u12pair"] = function(stream)
        local ret = {stream:ReadInt12Pair()}
        -- bit of a hack
        if ret[1] == 0 and ret[2] == 0 then
            return nil
        end
        return ret
    end,
    ["u24pair"] = function(stream)
        local ret = {stream:ReadInt24(), stream:ReadInt24()}
        -- bit of a hack
        if ret[1] == 0 and ret[2] == 0 then
            return nil
        end

        return ret
    end,
    ["s24pair"] = function(stream)
        local ret = {stream:ReadInt24()-8388608, stream:ReadInt24()-8388608}
        -- bit of a hack
        if ret[1] == 0 and ret[2] == 0 then
            return nil
        end

        return ret
    end,
    ["u8string"] = function(stream)
        local ret = stream:ReadTinyString()
        if ret == "nil" then-- I hate this but we need to support both nil strings and empty strings
            return nil
        else
            return ret
        end
    end,
    ["u16string"] = function(stream)
        local ret = stream:ReadShortString()
        if ret == "nil" then-- I hate this but we need to support both nil strings and empty strings
            return nil
        else
            return ret
        end
    end,
    ["u8u16array"] = function(stream)
        local count = stream:ReadByte()

        if count == 0 then return nil end

        local list = {}

        for i = 1, count do
            tinsert(list, stream:ReadShort())
        end
        return list
    end,
    ["u16u16array"] = function(stream)
        local list = {}
        local count = stream:ReadShort()
        for i = 1, count do
            tinsert(list, stream:ReadShort())
        end
        return list
    end,
    ["u8u24array"] = function(stream)
        local count = stream:ReadByte()

        if count == 0 then return nil end

        local list = {}
        for i = 1, count do
            tinsert(list, stream:ReadInt24())
        end
        return list
    end,
    ["u8u16stringarray"] = function(stream)
        local list = {}
        local count = stream:ReadByte()
        for i = 1, count do
            tinsert(list, stream:ReadShortString())
        end
        return list
    end,
    ["faction"] = function(stream)
        local val = stream:ReadByte()
        if val == 3 then
            return nil
        elseif val == 2 then
            return "AH"
        elseif val == 1 then
            return "H"
        else
            return "A"
        end
    end,
    ["spawnlist"] = function(stream)
        local count = stream:ReadByte()
        local spawnlist = {}
        for i = 1, count do
            local zone = stream:ReadShort()
            local spawnCount = stream:ReadShort()
            local list = {}
            for e = 1, spawnCount do
                local x, y = stream:ReadInt12Pair()
                if x == 0 and y == 0 then
                    tinsert(list, {-1, -1})
                else
                    tinsert(list, {x / 40.90, y / 40.90}) 
                end
            end
            spawnlist[zone] = list
        end
        return spawnlist
    end,
    ["trigger"] = function(stream)
        if stream:ReadShort() == 0 then
            return nil
        else
            stream._pointer = stream._pointer - 2
        end
        local ret = {}
        tinsert(ret, stream:ReadTinyStringNil())
        tinsert(ret, LibCompiledDB.compiler.readers["spawnlist"](stream))
        return ret
    end,
    ["questgivers"] = function(stream)
        --local count = stream:ReadByte()
        --if count == 0 then return nil end
        local ret = {}
        ret[1] = LibCompiledDB.compiler.readers["u8u24array"](stream)
        ret[2] = LibCompiledDB.compiler.readers["u8u24array"](stream)
        ret[3] = LibCompiledDB.compiler.readers["u8u24array"](stream)

        --for i = 1, count do
        --    tinsert(ret, LibCompiledDB.compiler.readers["u8u16array"](stream))
        --end

        return ret
    end,
    ["objective"] = function(stream)
        local count = stream:ReadByte()
        if count == 0 then
            return nil
        end

        local ret = {}

        for i = 1, count do
            tinsert(ret, {stream:ReadInt24(), stream:ReadTinyStringNil()})
        end
        return ret
    end,
    ["objectives"] = function(stream)
        local ret = {}

        ret[1] = LibCompiledDB.compiler.readers["objective"](stream)
        ret[2] = LibCompiledDB.compiler.readers["objective"](stream)
        ret[3] = LibCompiledDB.compiler.readers["objective"](stream)
        ret[4] = LibCompiledDB.compiler.readers["u24pair"](stream)

        return ret
    end,
    ["waypointlist"] = function(stream)
        local count = stream:ReadByte()
        local waypointlist = {}
        for i = 1, count do
            local lists = {}
            local zone = stream:ReadShort()
            local listCount = stream:ReadByte()
            for e = 1, listCount do
                local spawnCount = stream:ReadShort()
                local list = {}
                for e = 1, spawnCount do
                    local x, y = stream:ReadInt12Pair()
                    if x == 0 and y == 0 then
                        tinsert(list, {-1, -1})
                    else
                        tinsert(list, {x / 40.90, y / 40.90}) 
                    end
                end
                tinsert(lists, list)
            end
            waypointlist[zone] = lists
        end
        return waypointlist
    end,
}

LibCompiledDB.compiler.writers = {
    ["u8"] = function(stream, value)
        stream:WriteByte(value or 0)
    end,
    ["u16"] = function(stream, value)
        stream:WriteShort(value or 0)
    end,
    ["s16"] = function(stream, value)
        stream:WriteShort(32767 + (value or 0))
    end,
    ["u24"] = function(stream, value)
        stream:WriteInt24(value or 0)
    end,
    ["u32"] = function(stream, value)
        stream:WriteInt(value or 0)
    end,
    ["u12pair"] = function(stream, value)
        if value then
            stream:WriteInt12Pair(value[1] or 0, value[2] or 0)
        else
            stream:WriteInt24(0)
        end
    end,
    ["u24pair"] = function(stream, value)
        if value then
            stream:WriteInt24(value[1] or 0)
            stream:WriteInt24(value[2] or 0)
        else
            stream:WriteInt24(0)
            stream:WriteInt24(0)
        end
    end,
    ["s24pair"] = function(stream, value)
        if value then
            stream:WriteInt24((value[1] or 0) + 8388608)
            stream:WriteInt24((value[2] or 0) + 8388608)
        else
            stream:WriteInt24(8388608)
            stream:WriteInt24(8388608)
        end
    end,
    ["u8string"] = function(stream, value)

        stream:WriteTinyString(value or "nil") -- I hate this but we need to support both nil strings and empty strings

        --if value then
        --    stream:WriteTinyString(value)
        --else
        --    stream:WriteByte(0)
        --end 
    end,
    ["u16string"] = function(stream, value)
        --if value then
        --    stream:WriteShortString(value)
        --else
        --    stream:WriteShort(0)
        --end
        stream:WriteShortString(value or "nil")
    end,
    ["u8u16array"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _,v in pairs(value) do
                stream:WriteShort(v)
            end
        else
            stream:WriteByte(0)
        end
    end,
    ["u16u16array"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteShort(count)
            for _,v in pairs(value) do
                stream:WriteShort(v)
            end
        else
            stream:WriteShort(0)
        end
    end,
    ["u8u24array"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _,v in pairs(value) do
                stream:WriteInt24(v)
            end
        else
            stream:WriteByte(0)
        end
    end,
    ["u8u16stringarray"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _,v in pairs(value) do
                stream:WriteShortString(v or "nil")
            end
        else
            --print("Missing u8u16stringarray for " .. LibCompiledDB.compiler.currentEntry)
            stream:WriteByte(0)
        end
    end,
    ["faction"] = function(stream, value)
        if value == nil then
            stream:WriteByte(3)
        elseif "A" == value then
            stream:WriteByte(0)
        elseif "H" == value then
            stream:WriteByte(1)
        else
            stream:WriteByte(2)
        end
    end,
    ["spawnlist"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for zone, spawnlist in pairs(value) do
                count = 0 for _ in pairs(spawnlist) do count = count + 1 end
                stream:WriteShort(zone)
                stream:WriteShort(count)
                for _, spawn in pairs(spawnlist) do
                    if spawn[1] == -1 and spawn[2] == -1 then -- instance spawn
                        stream:WriteInt24(0) -- 0 instead
                    else
                        stream:WriteInt12Pair(math.floor(spawn[1] * 40.90), math.floor(spawn[2] * 40.90))
                    end
                end
            end
        else
            --print("Missing spawnlist for " .. LibCompiledDB.compiler.currentEntry)
            stream:WriteByte(0)
        end
    end,
    ["trigger"] = function(stream, value)
        if value then
            stream:WriteTinyString(value[1])
            LibCompiledDB.compiler.writers["spawnlist"](stream, value[2])
        else
            stream:WriteByte(0)
            stream:WriteByte(0)
        end
    end,
    ["questgivers"] = function(stream, value)
        if value then
            LibCompiledDB.compiler.writers["u8u24array"](stream, value[1])
            LibCompiledDB.compiler.writers["u8u24array"](stream, value[2])
            LibCompiledDB.compiler.writers["u8u24array"](stream, value[3])
        else
            print("Missing questgivers for " .. LibCompiledDB.compiler.currentEntry)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteByte(0)
        end
    end,
    ["objective"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _, pair in pairs(value) do
                stream:WriteInt24(pair[1])
                stream:WriteTinyString(pair[2] or "")
            end
        else
            stream:WriteByte(0)
        end
    end,
    ["objectives"] = function(stream, value)
        if value then
            LibCompiledDB.compiler.writers["objective"](stream, value[1])
            LibCompiledDB.compiler.writers["objective"](stream, value[2])
            LibCompiledDB.compiler.writers["objective"](stream, value[3])
            LibCompiledDB.compiler.writers["u24pair"](stream, value[4])
        else
            --print("Missing objective table for " .. LibCompiledDB.compiler.currentEntry)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteInt24(0)
            stream:WriteInt24(0)
        end
    end,
    ["waypointlist"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for zone, spawnlists in pairs(value) do
                stream:WriteShort(zone)
                count = 0 for _ in pairs(spawnlists) do count = count + 1 end
                stream:WriteByte(count)
                for _, spawnlist in pairs(spawnlists) do
                    count = 0 for _ in pairs(spawnlist) do count = count + 1 end
                    stream:WriteShort(count)
                    for _, spawn in pairs(spawnlist) do
                        if spawn[1] == -1 and spawn[2] == -1 then -- instance spawn
                            stream:WriteInt24(0) -- 0 instead
                        else
                            stream:WriteInt12Pair(math.floor(spawn[1] * 40.90), math.floor(spawn[2] * 40.90))
                        end
                    end
                end
            end
        else
            --print("Missing spawnlist for " .. LibCompiledDB.compiler.currentEntry)
            stream:WriteByte(0)
        end
    end
}

LibCompiledDB.compiler.skippers = {
    ["u8"] = function(stream) stream._pointer = stream._pointer + 1 end,
    ["u16"] = function(stream) stream._pointer = stream._pointer + 2 end,
    ["s16"] = function(stream) stream._pointer = stream._pointer + 2 end,
    ["u24"] = function(stream) stream._pointer = stream._pointer + 3 end,
    ["u32"] = function(stream) stream._pointer = stream._pointer + 4 end,
    ["u12pair"] = function(stream) stream._pointer = stream._pointer + 3 end,
    ["u24pair"] = function(stream) stream._pointer = stream._pointer + 6 end,
    ["s24pair"] = function(stream) stream._pointer = stream._pointer + 6 end,
    ["u8string"] = function(stream) stream._pointer = stream:ReadByte() + stream._pointer end,
    ["u16string"] = function(stream) stream._pointer = stream:ReadShort() + stream._pointer end,
    ["u8u16array"] = function(stream) stream._pointer = stream:ReadByte() * 2 + stream._pointer end,
    ["u16u16array"] = function(stream) stream._pointer = stream:ReadShort() * 2 + stream._pointer end,
    ["u8u24array"] = function(stream) stream._pointer = stream:ReadByte() * 3 + stream._pointer end,
    ["waypointlist"]  = function(stream)
        local count = stream:ReadByte()
        for i = 1, count do
            stream._pointer = stream._pointer + 2
            local listCount = stream:ReadByte()
            for e = 1, listCount do
                stream._pointer = stream:ReadShort() * 3 + stream._pointer
            end
        end
    end,
    ["u8u16stringarray"] = function(stream) 
        local count = stream:ReadByte()
        for i=1,count do
            stream._pointer = stream:ReadShort() + stream._pointer
        end
    end,
    ["faction"] = function(stream) stream._pointer = stream._pointer + 1 end,
    ["spawnlist"] = function(stream)
        local count = stream:ReadByte()
        for i = 1, count do
            stream._pointer = stream._pointer + 2
            stream._pointer = stream:ReadShort() * 3 + stream._pointer
        end
    end,
    ["trigger"] = function(stream) 
        stream._pointer = stream:ReadByte() + stream._pointer
        LibCompiledDB.compiler.skippers["spawnlist"](stream)
    end,
    ["questgivers"] = function(stream)
        --local count = stream:ReadByte()
        --for i = 1, count do
        --    LibCompiledDB.compiler.skippers["u8u16array"](stream)
        --end
        LibCompiledDB.compiler.skippers["u8u24array"](stream)
        LibCompiledDB.compiler.skippers["u8u24array"](stream)
        LibCompiledDB.compiler.skippers["u8u24array"](stream)
    end,
    ["objective"] = function(stream)
        local count = stream:ReadByte()
        for i=1,count do
            stream._pointer = stream._pointer + 3
            stream._pointer = stream:ReadByte() + stream._pointer
        end
    end,
    ["objectives"] = function(stream)
        LibCompiledDB.compiler.skippers["objective"](stream)
        LibCompiledDB.compiler.skippers["objective"](stream)
        LibCompiledDB.compiler.skippers["objective"](stream)
        LibCompiledDB.compiler.skippers["u24pair"](stream)
    end
}

LibCompiledDB.compiler.dynamics = {
    ["u8string"] = true,
    ["u16string"] = true,
    ["u8u16array"] = true,
    ["u16u16array"] = true,
    ["u8u24array"] = true,
    ["u8u16stringarray"] = true,
    ["spawnlist"] = true,
    ["trigger"] = true, 
    ["objective"] = true,
    ["objectives"] = true,
    ["questgivers"] = true,
    ["waypointlist"] = true,
}

LibCompiledDB.compiler.statics = {
    ["u8"] = 1,
    ["u16"] = 2,
    ["s16"] = 2,
    ["u24"] = 3,
    ["u32"] = 4,
    ["faction"] = 1,
    ["u12pair"] = 3,
    ["u24pair"] = 6,
    ["s24pair"] = 6,
}

function LibCompiledDB.compiler:CompileData(data, types,order, keys, func)
    LibCompiledDB.compiler:CompileTableTicking(data, types, order, keys, func)
end

local function equals(a, b)
    if a == nil and b == nil then return true end
    if a == nil or b == nil then return false end
    local ta = type(a)
    local tb = type(b)
    if ta ~= tb then return false end

    if ta == "number" then
        return math.abs(a-b) < 0.2
    elseif ta == "table" then
        for k,v in pairs(a) do
            if not equals(b[k], v) then
                return false
            end
        end
        for k,v in pairs(b) do
            if not equals(b[k], v) then
                return false
            end
        end
        return true
    else
        return a == b
    end

end

function LibCompiledDB.compiler:EncodePointerMap(stream, pointerMap)
    stream:reset()
    stream:WriteShort(0) -- placeholder
    local count = 0
    for id, ptrs in pairs(pointerMap) do
        stream:WriteInt24(id)
        stream:WriteInt24(ptrs)
        count = count + 1
    end
    stream._pointer = 1
    stream:WriteShort(count)
    return stream:Save()
end

function LibCompiledDB.compiler:DecodePointerMap(stream)
    local count = stream:ReadShort()
    local ret = {}
    for i = 1, count do 
        ret[stream:ReadInt24()] = stream:ReadInt24()
    end
    return ret
end

function LibCompiledDB.compiler:CompileTable(tbl, types, order, lookup)
    local pointerMap = {}
    local stream = stream:GetStream("raw")
    for id, entry in pairs(tbl) do
        pointerMap[id] = stream._pointer
        for _, key in pairs(order) do
            LibCompiledDB.compiler.writers[types[key]](stream, entry[lookup[key]])
        end
    end
    return stream:Save(), LibCompiledDB.compiler:EncodePointerMap(stream, pointerMap)
end

function LibCompiledDB.compiler:CompileTableTicking(tbl, types, order, lookup, after)
    local count = 0
    local indexLookup = {};
    for id in pairs(tbl) do
        count = count + 1
        indexLookup[count] = id
    end
    count = count + 1
    LibCompiledDB.compiler.index = 0

    LibCompiledDB.compiler.pointerMap = {}
    LibCompiledDB.compiler.stream = stream:GetStream("raw")

    LibCompiledDB.compiler.ticker = C_Timer.NewTicker(0.01, function()
        for i=0, 48 do
            LibCompiledDB.compiler.index = LibCompiledDB.compiler.index + 1
            if LibCompiledDB.compiler.index == count then
                LibCompiledDB.compiler.ticker:Cancel()
                --print("Finalizing: " .. LibCompiledDB.compiler.index)
                after(LibCompiledDB.compiler.stream:Save(), LibCompiledDB.compiler:EncodePointerMap(LibCompiledDB.compiler.stream, LibCompiledDB.compiler.pointerMap))
                break
            end
            local id = indexLookup[LibCompiledDB.compiler.index]
            LibCompiledDB.compiler.currentEntry = id
            local entry = tbl[id]
            --local pointerStart = LibCompiledDB.compiler.stream._pointer
            LibCompiledDB.compiler.pointerMap[id] = LibCompiledDB.compiler.stream._pointer--pointerStart
            for _, key in pairs(order) do
                LibCompiledDB.compiler.writers[types[key]](LibCompiledDB.compiler.stream, entry[lookup[key]])
            end
            tbl[id] = nil -- quicker gabage collection later
        end
    end)
end

function LibCompiledDB.compiler:BuildSkipMap(types, order) -- skip map is used for random access, to read specific fields in an entry without reading the whole entry
    local skipmap = {}
    local indexToKey = {}
    local keyToIndex = {}
    local ptr = 0
    local haveDynamic = false
    local endIndex = nil
    local lastIndex = nil
    for index, key in pairs(order) do
        local typ = types[key]
        indexToKey[index] = key
        keyToIndex[key] = index
        if not haveDynamic then
            skipmap[key] = ptr
        end
        if LibCompiledDB.compiler.dynamics[typ] then
            if not haveDynamic then
                lastIndex = index
            end
            haveDynamic = true
        else
            --print("static: " .. typ)
            ptr = ptr + LibCompiledDB.compiler.statics[typ]
        end
    end
    skipmap = {skipmap, lastIndex, ptr, types, order, indexToKey, keyToIndex}
    return skipmap
end

function LibCompiledDB.compiler:GetDBHandle(data, pointers, skipmap, keyToRootIndex)
    local handle = {}
    local skipmap, lastIndex, lastPtr, types, order, indexToKey, keyToIndex = unpack(skipmap)

    local stream = stream:GetStream("raw")
    stream:Load(pointers)
    pointers = LibCompiledDB.compiler:DecodePointerMap(stream)

    stream:Load(data)

    handle.Query = function(id, key)
        local typ = types[key]
        local ptr = pointers[id]
        if ptr == nil then
            --print("Entry not found! " .. id)
            return nil
        end
        if skipmap[key] ~= nil then -- can skip directly
            stream._pointer = skipmap[key] + ptr
        else -- need to skip over some variably sized data
            stream._pointer = lastPtr + ptr
            local targetIndex = keyToIndex[key]
            if targetIndex == nil then
                print("ERROR: Unhandled db key: " .. key)
            end
            for i = lastIndex, targetIndex-1 do
                LibCompiledDB.compiler.readers[types[indexToKey[i]]](stream)
            end
        end
        return LibCompiledDB.compiler.readers[typ](stream)
    end
    
    handle.pointers = pointers

    return handle
end

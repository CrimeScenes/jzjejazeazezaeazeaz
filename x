local threads = {}

local gc = getgc(true)
local detection_funcs = {}

local has_function_more_than_once = function(func, t)
    local count = 0
    for i = 1, #t do
        if t[i] == func then
            count = count + 1
            if count > 1 then
                return true
            end
        end
    end
    return false
end

for i = 1, #gc do
    local collection = gc[i]

    if type(collection) == "function" and islclosure(collection) then
        local constants = debug.getconstants(collection)

        for _, constant in constants do
            if tostring(constant):lower():find("not enough memory") and debug.getinfo(collection).short_src:lower():find("corepackages") then
                for index, upvalue in debug.getupvalues(collection) do
                    if type(upvalue) == "function" and islclosure(upvalue) then
                        table.insert(detection_funcs, upvalue)
                    end
                end
            end
        end
    end
end

local detection_func

for i = 1, #detection_funcs do
    local func = detection_funcs[i]
    
    if has_function_more_than_once(func, detection_funcs) then
        detection_func = func
        break  -- Stop at the first detection function found with more than one instance
    end
end

-- Only hook the function if detection_func is valid (not nil)
if detection_func then
    hookfunction(detection_func, function(detection)
        print(string.format("tried detecting %s", tostring(detection)))
    end)
else
    print("No valid detection function found to hook.")
end





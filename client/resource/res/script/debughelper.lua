--add globa debug method. by liugeng

 overwriteprint=1    --如果要将print输出到文件log里就不注释'overwriteprint'

if overwriteprint then
local debugFile = 'LuaDebugLog.txt'

local old = io.open(debugFile, 'r')
if old then
    old:close()
    os.remove(debugFile)
end

local skipStr = {}
skipStr['enter getinstance'] = 1

-- UTF-8 BOM标记，用于标识文件为UTF-8编码
local UTF8_BOM = string.char(0xEF, 0xBB, 0xBF)
local isFirstWrite = true

--将log输出到client/resource/bin/debug/LuaDebugLog.txt
local oldprint = _G.print
_G.print = function(...)
    if skipStr[...] then return end
    local fp = io.open(debugFile, 'ab')  -- 使用二进制追加模式打开
    if fp then
        -- 首次写入时添加UTF-8 BOM
        if isFirstWrite then
            fp:write(UTF8_BOM)
            isFirstWrite = false
        end
        fp:write(string.format(...))
        fp:write('\n')
        fp:close()
    else
        oldprint(...)
    end
end

local t = os.date('*t', os.time())
print(t.year..'-'..t.month..'-'..t.day..' '..t.hour..':'..t.min)

end


--使用debugrequire替换require引用lua文件，可以用LuaEditor在文件里打断点
--对于实现界面的lua文件，可以在打开界面的按钮事件函数里使用debugrequire，这时修改
--lua文件后只需要保存再重新打开该界面就可以看到改变后的效果，不需要重启程序
local debugfiles = {}
local oldrequire = _G.require
_G.debugrequire = function(str)

    local element = {}
    for v in string.gmatch(str, '[^.]+') do
        table.insert(element, v)
    end
    
    local cmd = '../../res/script'
    for _,v in pairs(element) do
        cmd = cmd..'/'..v
    end
    
    local ret = nil
    
    function __G__TRACKBACK__(msg)
        print("----------------------------------------")
        print("LUA ERROR:" .. tostring(msg) .. "\n")
        print(debug.traceback())
        print("----------------------------------------")
        package.loaded[str] = nil
        ret = oldrequire(str)
    end
    local dofile = function()
        package.loaded[str] = true
        ret = _G.dofile(cmd..'.lua')
    end
    
    xpcall(dofile, __G__TRACKBACK__)
    
    print('[debugrequire]'..cmd..'.lua')

    debugfiles[str] = ret
    return ret
end

_G.require = function(str)
    if debugfiles[str] then
        return debugfiles[str]
    end
    return oldrequire(str)
end


--调用函数时使用debugcall调用，可以输出错误日志
--不是对所有错误都有效，但能输出nil value之类的错误
_G.debugcall = function(func)
    function __G__TRACKBACK__(msg)
        print("----------------------------------------")
        print("LUA ERROR:" .. tostring(msg) .. "\n")
        print(debug.traceback())
        print("----------------------------------------")
    end

    xpcall(func, __G__TRACKBACK__)
end

function dump(t)
    if t == nil then return end
    if type(t) == 'table' then
        print('-----[dump]-----')
        for k,v in pairs(t) do
            print(k,':',v)
        end
        print('----------------')
    elseif type(t) == 'userdata' then
        dump(getmetatable(t))
    end
end

-- value  : 要打印的table或者其他类型
-- desciption :　相关描述
function dumpT(value, desciption, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local traceback = StringBuilder.Split(debug.traceback("", 2), "\n")
    print("dump from: " .. MHSD_UTILS.trim(traceback[3]))

    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end



-------------------------------------------------------------------------------------
local _debugTime = {}
function printtime(msg, line)
    _debugTime[msg] = _debugTime[msg] or 0
    local t = _debugTime[msg]

    if t == 0 then
        t = getusectime()
        print(string.format("[%s] begin", msg))
    else
        local t1 = getusectime()
        if t1 > t then
            print(string.format("[%s] %d: %d", msg, line, t1-t))
        end
    end

    _debugTime[msg] = getusectime()
end

function endprinttime(msg)
    msg = msg or ""
    local t = _debugTime[msg]
    local t1 = getusectime()
    print(string.format("[%s] end: %d", msg, t1-t))
    _debugTime[msg] = 0
end
--printtime(msg, debug.getinfo(1).currentline)
-------------------------------------------------------------------------------------
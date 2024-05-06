-- lua扩展

-- table扩展

-- 返回table大小
table.size = function(t)
	local count = 0
	for _ in pairs(t or {}) do
		count = count + 1
	end
	return count
end

-- 判断table是否为空
table.empty = function(t)
    if not (t) then return true end
    return not next(t)
end

-- 返回table索引列表
table.indices = function(t)
    local result = {}
    for k, v in pairs(t) do
        table.insert(result, k)
    end
    return result
end

-- 返回table值列表
table.values = function(t)
    local result = {}
    for k, v in pairs(t) do
        table.insert(result, v)
    end
    return result
end

-- 浅拷贝
table.clone = function(t, nometa)
    local result = {}
    if not nometa then
        setmetatable(result, getmetatable(t))
    end
    for k, v in pairs (t) do
        result[k] = v
    end
    return result
end

-- 深拷贝
table.copy = function(t, nometa)   
    local result = {}

    if not nometa then
        setmetatable(result, getmetatable(t))
    end

    for k, v in pairs(t) do
        if type(v) == "table" then
            result[k] = table.copy(v)
        else
            result[k] = v
        end
    end
    return result
end

-- 功能：复制表
table.lowcopy = function (t)
    local tbl = {}
    for i, v in pairs(t) do
        tbl[i] = v
    end
    return tbl
end

-- 功能：深度复制表
-------------------------------------------------------------
-- lua元素复制接口,提供浅复制(lowcopy)和深复制两个接口(deepcopy)
-- 深复制解决以下3个问题:
-- 1. table存在循环引用
-- 2. metatable(metatable都不参与复制)
-- 3. keys也是table
--------------------------------------------------------------
table.deepcopy = function (o, seen)
    local typ = type(o)
    if typ ~= "table" then 
        return o
    end
    seen = seen or {}
    if seen[o] then
        return seen[o] 
    end
    local newtable = {}
    seen[o] = newtable
    for k,v in pairs(o) do
        newtable[table.deepcopy(k, seen)] = table.deepcopy(v, seen)
    end
    return newtable
end

-- 将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值
table.merge = function(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end
-- 将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，不覆盖其值
table.mergenocover = function(dest, src)
    for k, v in pairs(src) do
        if not dest[k] then
            dest[k] = v
        end
    end
end

-- 在目标表格的指定位置插入来源表格，如果没有指定位置则连接两个表格
-- table.insertto(dest, src, 5)
function table.insertto(dest, src, begin)
    if not begin or begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

table.append = function(t1, t2)
    for k, v in pairs(t2 or {}) do
        table.insert(t1, v)
    end
end

table.fromstring = function(str)
    if str == nil then
        return nil
    end
    local f = load('return ' .. str)
    if f == nil then
        logger.warn("table.fromstring() - f=nil, str=%s", str)
        return nil
    end
    return f()
end


-- 将table中的key tostring
table.keyToString = function (t)
    if type(t) ~= "table" then return t end
    local tmp = {}
    for k, v in pairs(t) do
        tmp[tostring(k)] = table.keyToString(v)
    end
    return tmp
end

table.valueToKey = function (t)
    if "table" ~= type(t) then return t end

    local tmp = {}
    for k, v in pairs(t) do
        if "table" == type(v) then break end
        
        tmp[v] = k
    end

    return tmp
end

-- local LuaText = require("LuaText")
-- function table.tostring(t)
--     return LuaText:serialize(t)
-- end

-- function table.serialize(t)
--     return LuaText:dbserialize(t)
-- end

-- function table.strtotable(t)
--     return LuaText:deserialize(t)
-- end

-- 将table中的key tonumber
function table.keyToNumber(t)
    if type(t) ~= "table" then return t end
    local tmp = {}
    for k, v in pairs(t) do
        tmp[tonumber(k) or k] = table.keyToNumber(v)
    end
    return tmp
end

table.removeItem = function(t, item, removeAll)
    for i = #t, 1, -1 do
        if t[i] == item then
            table.remove(t, i)
            if not removeAll then break end
        end
    end
end

table.foreach = function(table, func) 
    for key, value in pairs(table) do
        func(key, value)
    end
end
-- 功能：k，v翻转
table.invert = function (t)
    local inverts = {}
    table.foreach(t, function(k, v)
        inverts[v] = k
    end)
    return inverts
end

--[[--
在目标表格的指定位置插入来源表格，如果没有指定位置则连接两个表格
~~~ lua
local dest = {1, 2, 3}
local src  = {4, 5, 6}
table.insertto(dest, src)
-- dest = {1, 2, 3, 4, 5, 6}
dest = {1, 2, 3}
table.insertto(dest, src, 5)
-- dest = {1, 2, 3, nil, 4, 5, 6}
~~~
]]

-- end --

table.insertto = function (dest, src, begin)
    if not begin or begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

-- 抽取src表中的key，转化为字符串操作, 存入dest 注意可能转换失败
function table.ktos(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[tostring(k)] = table.ktos({}, v)
        else
            dest[tostring(k)] = v
        end
    end
    return dest
end

-- 抽取src表中的key,转化为数字操作,存入dest 注意可能转换失败
function table.kton(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[tonumber(k) or k] = table.kton({}, v)    
        else
            dest[tonumber(k) or k] = v
        end
    end
    return dest
end

--[[--
返回指定表格中的所有键
~~~ lua
local hashtable = {a = 1, b = 2, c = 3}
local keys = table.keys(hashtable)
-- keys = {"a", "b", "c"}
~~~
]]

-- end --

function table.keys(hashtable)
    local keys = {}
    for k, _ in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end
--[[--
返回指定表格中的所有值
~~~ lua
local hashtable = {a = 1, b = 2, c = 3}
local values = table.values(hashtable)
-- values = {1, 2, 3}
~~~
]]
function table.values(hashtable)
    local values = {}
    for _, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end


function table.ivalues(hashtable)
    local keys = table.keys(hashtable)
    table.sort(keys)
    local values = {}
    for _, key in ipairs(keys) do
        values[#values + 1] = hashtable[key]
    end
    return values
end

function table.walk(t, fn)
    for k,v in pairs(t) do
        fn(k, v)
    end
end

function table.sum_value(des, src)
    if not des or not src then
        return
    end
    for key, value in pairs(src) do
        des[key] = (des[key] or 0) + value
    end
end

--{a = 1, b = 2, c = 3} 不重复
function table.getRandKey(tab,count)
    local array={}
    for key, value in pairs(tab) do
        table.insert(array,key)
    end
    local result = {}
    if count>=#array  then
        return array
    end
    while #result < count  do
        -- 从原始数组中随机选择一个元素
        local index = math.random(#array)
        local element = array[index]
        -- 如果选择的元素不在结果数组中，则添加到结果数组中
        if not result[element] then
            table.insert(result, element)
        
            -- 从原始数组中移除已选择的元素，避免重复选择
            table.remove(array, index)
        end
    end
    return result
end

-- 保留n位小数
function floorLimitBit(num, n)
    if type(num) ~= "number" then
        return num
    end
    n = n or 4
    return tonumber(string.format("%." .. n .. "f", num))
end

--递归查表
function recursionSearch(table, searchKey, searchValue)
    for key, value in pairs(table) do
        if key == searchKey and value == searchValue then
            return table
        end

        if 'table' == type(value) then
            recursionSearch(value, searchKey, searchValue)
        end
    end
end

-- string扩展
-- 没有分隔符时有问题，用 string.msplit
string.split = function(s, delim)
    assert(s, "no find s")
    local split = {}
    local pattern = "[^" .. delim .. "]+"
    string.gsub(s, pattern, function(v) table.insert(split, v) end)
    return split
end

string.msplit = function(s, delim)
    local split = {}
    for w in string.gmatch(s, "([^".. delim .. ",]+)") do
        table.insert(split, w)
    end
    return split
end

string.numsplit = function(s, delim)
    local split = {}
    local pattern = "[^" .. delim .. "]+"
    string.gsub(s, pattern, function(v) table.insert(split, tonumber(v)) end)
    return split
end

string.ltrim = function(s, c)
    local pattern = "^" .. (c or "%s") .. "+"
    return (string.gsub(s, pattern, ""))
end

string.rtrim = function(s, c)
    local pattern = (c or "%s") .. "+" .. "$"
    return (string.gsub(s, pattern, ""))
end

string.trim = function(s, c)
    return string.rtrim(string.ltrim(s, c), c)
end

string.starts = function(s, c)
    return string.sub(s, 1, string.len(c))==c
end

string.ends = function(s, c)
    return c=="" or string.sub(s, -string.len(c))==c
end

math.round = function(n, p)
    local e = 10 ^ (p or 0)
    return math.floor(n * e + 0.5) / e
end

--mrandom() = (0,1)
local mrandom = math.random
math.randomf = function(lower, greater)
    return lower + mrandom() * (greater - lower)
end

math.randomx = function(min, max, cnt)
    local ret = {}
    if max - min + 1 < cnt then
        for i=min, max do
            table.insert(ret, i)
        end
        return ret
    end
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local tmp = {}
    while cnt > 0 do
        local x = mrandom(min, max)
        if not tmp[x] then
            table.insert(ret, x)
            tmp[x] = 1
            cnt = cnt - 1
        end
    end
    return ret
end

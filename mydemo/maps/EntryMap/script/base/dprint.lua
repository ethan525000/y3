function table2str(...)--
	local arg = {...}
	local tem = "";
	local loopdc = {}
	for i,v in ipairs(arg) do
		if type(v) == 'table' then
			local bok = false
			tem = tem.."{"
			if loopdc[v] then return "loop" end
			loopdc[v ] = 1 
			for i,value in pairs(v) do
				bok = true
				local pr_i = i
				if type(i) == "string" then
					pr_i = "\'"..i.."\'"
				end
		     	if type(value) == 'table' then
					if loopdc[value] then return "loop" end
					loopdc[value ] = 1 
		     		tem =tem..tostring(pr_i).."="..table2str(value);
		     	else
		     		tem =tem..tostring(pr_i).."="..tostring(value)--..",\t";
		     	end
				 tem =tem..","
			end
			tem = tem.."} "
		else
		   if v == nil then
		   		tem = tem.."nil"--.."\t"
		   end
	       tem = tem..tostring(v)--.."\t";
	    end
	 end
	return tem
end

function table_dump(tb, dump_metatable, max_level)
    if not print_debug then
        return
    end
    if tb == nil or tb == "" then
        return
    end
    local lookup_table = {}
    local level = 0
    local rep = string.rep
    local dump_metatable = dump_metatable
    local max_level = max_level or 5

    local function _dump(tb, level)
        local str = "\n" .. rep("\t", level) .. "{\n"
        for k, v in pairs(tb) do
            local k_is_str = type(k) == "string" and 1 or 0
            local v_is_str = type(v) == "string" and 1 or 0
            str =
                str ..
                rep("\t", level + 1) ..
                    "[" .. rep('"', k_is_str) .. (tostring(k) or type(k)) .. rep('"', k_is_str) .. "]" .. " = "
            if type(v) == "table" then
                if not lookup_table[v] and ((not max_level) or level < max_level) then
                    lookup_table[v] = true
                    str = str .. _dump(v, level + 1) .. "\n"
                else
                    str = str .. (tostring(v) or type(v)) .. ",\n"
                end
            else
                str = str .. rep('"', v_is_str) .. (tostring(v) or type(v)) .. rep('"', v_is_str) .. ",\n"
            end
        end
        if dump_metatable then
            local mt = getmetatable(tb)
            if mt ~= nil and type(mt) == "table" then
                str = str .. rep("\t", level + 1) .. '["__metatable"]' .. " = "
                if not lookup_table[mt] and ((not max_level) or level < max_level) then
                    lookup_table[mt] = true
                    str = str .. _dump(mt, level + 1, dump_metatable) .. "\n"
                else
                    str = str .. (tostring(mt) or type(mt)) .. ",\n"
                end
            end
        end
        str = str .. rep("\t", level) .. "},"
        return str
    end

    return _dump(tb, level)
end

local function logmsg(level, format, ...)
    local other = table.pack(...)
    local msg
    local tmp_msg_tab = {}

    if other.n > 0  then
        msg = string.format(format, ...)
        table.insert(tmp_msg_tab, msg)
        if string.find(msg, format, 1, true) then   -- format 中没有格式化串
            local str = {}
            for i = 1, other.n do
                str[#str+1] = tostring(other[i])
            end
            table.insert(tmp_msg_tab, table.concat(str, " "))
        end
    else
        table.insert(tmp_msg_tab, format)
    end

    msg = table.concat(tmp_msg_tab)
    log[level](msg)
end
-- y3 默认定义日记
local logLevel = {
    trace = 1,
    debug = 2,
    info  = 3,
    warn  = 4,
    error = 5,
    fatal = 6,
}

logger = {}
logger._level = logLevel[log.level]
for level, logvalue in pairs (logLevel) do
    logger[level] = function (format, ...)
        if logger._level <= logvalue then
            logmsg(level, format, ...)
        end
    end
end


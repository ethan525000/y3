

local path = require "ui.path"

New 'ECAFunction' '获取随机路径'
    -- 声明第一个参数的ECA类型
    : with_param('路径', 'road_id')
    -- 声明返回值的ECA类型
    : with_return('路径', 'Road')
    : with_return('超点', 'Point')
    ---@param road_id integer
    ---@return Road road 
    ---@return Point point 
    : call(function (road_id)
        local sroad,spoint = path.reverse_path(road_id)
        return sroad,spoint
    end)


New 'ECAFunction' '获取路径方向'
-- 声明第一个参数的ECA类型
-- 声明返回值的ECA类型
: with_return('方向', 'integer')
---@return integer fx 
: call(function ()
    return path.faxian
end)
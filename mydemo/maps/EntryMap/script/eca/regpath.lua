

local path = require "ui.path"

New 'ECAFunction' '获取随机路径'
    -- 声明第一个参数的ECA类型
    : with_param('路径', 'road_id')
    -- 声明返回值的ECA类型
    : with_return('路径', 'Road')
    : with_return('起点', 'Point')
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

New 'ECAFunction' '获取临时路径'
    -- 声明第一个参数的ECA类型
    : with_param('路径', 'py_road')
    : with_param('当前位置', 'py_point')
    : with_param('方向', 'faxian')
    -- 声明返回值的ECA类型
    : with_return('路径', 'Road')
    : with_return('起点', 'Point')
    ---@param py_road py.Road
    ---@param py_point Point.HandleType
    ---@param fanxian integer 
    ---@return Road road 
    ---@return Point point 
    : call(function (py_road, py_point, fanxian)
        local sroad,spoint = path.tmp_path(py_road, py_point, fanxian)
        return sroad,spoint
    end)


New 'ECAFunction' '挑战者停下时继续'
    -- 声明第一个参数的ECA类型
    : with_param('事件中的单位', 'py_unit')
    : with_param('路径', 'py_road')
    : with_param('新手保护', 'isNewBir')
    -- 声明返回值的ECA类型
    ---@param py_road py.Road
    ---@param py_unit py.Unit
    ---@param isNewBir boolean 

    : call(function (py_unit, py_road, isNewBir)
        if "number" == type(py_unit) then
            logger.info("挑战者停下时继续 py_unit ", py_unit)
        end
         return path.send_path_command(py_unit, py_road, isNewBir)
    end)
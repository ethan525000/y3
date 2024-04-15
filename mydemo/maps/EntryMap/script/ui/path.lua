local mathRandom   = math.random

local newpath = {}
newpath.faxian = nil
---comment 返回预定路径两个方向生成的新路径定义和起点
---@param res_id integer
---@return Road road 
---@return Point point 
function newpath.reverse_path(res_id)
    log.info("oldpathid ", res_id)
    local phandle = y3.road.get_road_by_res_id(res_id)
    local poincn = phandle:get_point_count()

    local stpos = mathRandom(1, poincn)
    local stfx  = mathRandom(1, 2)
    newpath.faxian = stfx

    local startpoint = y3.point.get_point_in_path(phandle,stpos)
    local roadpath = y3.road.create_path(startpoint)

    if 1 == stfx then   -- 正向
        local ix = 1
        for x = stpos+1, poincn do
            ix = ix + 1
            roadpath:add_point(ix,  y3.point.get_point_in_path(phandle, x))
        end
        if stpos > 1 then
            for x = 1, stpos-1, 1 do
                ix = ix + 1
                roadpath:add_point(ix,  y3.point.get_point_in_path(phandle, x))
            end
        end
        y3.road.add_tag(roadpath, "正向路径")
        -- log.info("正向路径 起点 ", stpos, startpoint:get_x() ,startpoint:get_y(), startpoint:get_z())
    else
        local ix = 1
        if stpos > 1 then
            for x = stpos-1, 1, -1 do
                ix = ix + 1
                roadpath:add_point(ix,  y3.point.get_point_in_path(phandle, x))
            end
        end
        for x = poincn, stpos+1, -1  do
            ix = ix + 1
            roadpath:add_point(ix,  y3.point.get_point_in_path(phandle, x))
        end
        y3.road.add_tag(roadpath, "反向路径")
        -- log.info("反向路径 起点 ", stpos, startpoint:get_x() ,startpoint:get_y(), startpoint:get_z())
    end

    return roadpath,startpoint
end

return newpath
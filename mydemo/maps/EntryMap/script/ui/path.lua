local mathRandom   = math.random
local mathAbs      = math.abs

local newpath = {}
newpath.faxian = nil
---comment 返回预定路径两个方向生成的新路径定义和起点
---@param res_id integer
---@return Road road 
---@return Point point 
function newpath.reverse_path(res_id)
    log.info("路径原始 oldpathid ", res_id)
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
        local last_point = y3.point.get_point_in_path(roadpath, roadpath:get_point_count())
        logger.info("正向路径 起点索引:%s  新路径起点:%s,%s,%s 路径点数量:%s 终点:%s,%s", stpos, startpoint:get_x(), startpoint:get_y(), startpoint:get_z(), 
        roadpath:get_point_count(), last_point:get_x(), last_point:get_y() )
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

        local last_point = y3.point.get_point_in_path(roadpath, roadpath:get_point_count())
        logger.info("反向路径 起点索引:%s  新路径起点:%s,%s,%s 路径点数量:%s 终点:%s,%s", stpos, startpoint:get_x(), startpoint:get_y(), startpoint:get_z(), 
        roadpath:get_point_count(), last_point:get_x(), last_point:get_y() )
    end

    return roadpath,startpoint
end

---comment 原路径巡逻被打断后，生成新路径，返回新路径和起点
---@param py_road py.Road            原来巡逻路径
---@param py_point Point.HandleType  单位当前位置
---@param fanxian integer
---@return Road road 
---@return Point point 
function newpath.tmp_path(py_road, py_point, fanxian)
    -- log.info("road_id, pos, fanxian ", py_road, pos, fanxian)
    local phandle = y3.road.get_by_handle(py_road)
    local poincn = phandle:get_point_count()

    local phadlepos = y3.point.get_by_handle(py_point)
    logger.info("++++++++++ 生成临时路径 当前位置:%s,%s 获得原路径数量:%s", phadlepos:get_x(), phadlepos:get_y(), poincn)
    -- 从原始路径中获取一个最近的目标点，以这个点生成到达终点的临时路径
    local chose_point
    local chose_x = 0
    local chose_dis
    for x = 1, poincn do
        local tmp_point = y3.point.get_point_in_path(phandle, x)
        logger.info("x:%s 查询结点 tmp_point %s,%s",x, tmp_point:get_x(), tmp_point:get_y())
        if tmp_point then
            if 0 == chose_x then
                chose_point = tmp_point
                chose_x = x
                chose_dis = phadlepos:get_distance_with(chose_point)
            -- elseif mathAbs(phadlepos:get_x() - tmp_point:get_x()) <= 10  then
            --     logger.info("tmp_point x<10 %s,%s", mathAbs(phadlepos:get_y() - tmp_point:get_y()), mathAbs(phadlepos:get_y() - chose_point:get_y()))
            --     if mathAbs(phadlepos:get_y() - tmp_point:get_y()) < mathAbs(phadlepos:get_y() - chose_point:get_y()) then
            --         chose_point = tmp_point
            --         chose_x = x
            --     end
            -- elseif mathAbs(phadlepos:get_y() - tmp_point:get_y()) <= 10  then
            --     logger.info("tmp_point y<10 %s,%s", mathAbs(phadlepos:get_x() - tmp_point:get_x()), mathAbs(phadlepos:get_x() - chose_point:get_x()))
            --     if mathAbs(phadlepos:get_x() - tmp_point:get_x()) < mathAbs(phadlepos:get_x() - chose_point:get_x()) then
            --         chose_point = tmp_point
            --         chose_x = x
            --     end

            elseif mathAbs(phadlepos:get_x() - tmp_point:get_x()) <= 10 or mathAbs(phadlepos:get_y() - tmp_point:get_y()) <= 10  then
                local dis = phadlepos:get_distance_with(tmp_point)
                if dis < chose_dis then
                    logger.info("tmp_point y<10 chose_dis:%s, dis:%s x:%s", chose_dis, dis, x)
                    chose_dis = dis
                    chose_point = tmp_point
                    chose_x = x
                end

            end
        end

    end
    logger.info("新生成临时路径 找到点 chose_point:%s,%s chose_x:%s", chose_point:get_x(), chose_point:get_y(), chose_x)

    local return_road = y3.road.create_path(phadlepos)
    local ix = 2
    for x = chose_x+1, poincn do -- 从第2个开始，防止退回
        return_road:add_point(ix, y3.point.get_point_in_path(phandle, x))
        ix = ix + 1
    end
    -- 补齐一个环
    -- if chose_x > 1 then
    --     for x=1, chose_x-1 do
    --         return_road:add_point(ix, y3.point.get_point_in_path(phandle, x))
    --         ix = ix + 1
    --     end
    -- end

    local lastpoint = y3.point.get_point_in_path(return_road, ix-1)
    logger.info(" ++++++++++ 返回 新生成临时路径 起点:%s,%s 终点:%s,%s 数量:%s",  phadlepos:get_x(), phadlepos:get_y(), lastpoint:get_x(), lastpoint:get_y(), ix-1)
    for x=1, return_road:get_point_count() do
        local curpoint = y3.point.get_point_in_path(return_road, x)
        logger.info(" ++++++++++ 返回 新生成临时路径 %s %s", curpoint:get_x(), curpoint:get_y())
    end
    return return_road, phadlepos
end

-- 发布按路径移动命令
function newpath.send_path_command(py_unit, py_road, isNewBir)
    logger.info("发布按路径移动命令")
    local unit = y3.unit.get_by_handle(py_unit)
    if isNewBir or unit:is_moving() or unit:is_in_battle() then
        return
    end
    --沿路径移动
    local road = y3.road.get_by_handle(py_road)
    unit:move_along_road(road, y3.const.PatrolType.LOOP, true,true,false)
    y3.game:event_notify_with_args('自定义积分增加', {'123'})
end

return newpath
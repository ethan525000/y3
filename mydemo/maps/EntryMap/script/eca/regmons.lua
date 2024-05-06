local jianzao_danyuan   = GlobalData.emumData.jianzao_danyuan
local builds            = GlobalData.builds
local battle_wave       = require 'eca.buildmons'

-- 获得离路径最近的点(路径中的点要分布均匀，尽可能的多数据)
local function get_nearest_road_point(py_road, point)
    local phandle = y3.road.get_by_handle(py_road)
    local poincn = phandle:get_point_count()
    local chose = 0
    local chose_dis

    for x = 1, poincn do
        local tmp_point = y3.point.get_point_in_path(phandle, x)
        local dis = point:get_distance_with(tmp_point)
        if chose == 0 or chose_dis > dis then
            chose_dis = dis
            chose = x
        end
    end

    return y3.point.get_point_in_path(phandle, chose)
end
-- 获得附近随机点，要在路径控制范围内
local function get_zone_point(point)
    local chose = math.random(100, 299)
    local x, y
    if chose/100 == 1  then
        x = point:get_x()+ (chose//10)%10
        y = point:get_y()+ chose%10
    else
        x = point:get_x()- (chose//10)%10
        y = point:get_y()- chose%10
    end

    return y3.point.create(x, y, point:get_z())
end

New 'ECAFunction' '添加刷怪建筑'
    -- 声明第一个参数的ECA类型
    : with_param('事件玩家', 'py_player')
    : with_param('建造完成的单位', 'py_unit')
    : with_param('建造单位所在点', 'py_point')
    : with_param('游戏路径', 'py_road')
    -- 声明返回值的ECA类型
    -- : with_return('路径', 'Road')
    -- : with_return('起点', 'Point')
    ---@param py_player py.Role 玩家
    ---@param py_unit py.Unit # 建造完成的单位
    ---@param py_point Point.HandleType 
    ---@param py_road py.Road
    ---@return integer ret 1 succ 2

    : call(function (py_player, py_unit, py_point, py_road)

        local unit = y3.unit.get_by_handle(py_unit)
        local point = y3.point.get_by_handle(py_point)

        local player = y3.player.get_by_handle(py_player)

        logger.info("添加刷怪建筑 player id:%s unit_key:%s unit id:%s %s {x:%s y:%s}",
            player:get_id(), unit:get_key(), unit:get_id(), jianzao_danyuan[unit:get_id()], point:get_x(), point:get_y())
        local cur_player_id = player:get_id()
        GlobalData.runData.playerData[cur_player_id] = GlobalData.runData.playerData[cur_player_id] or {}
        local playerdata =  GlobalData.runData.playerData[cur_player_id]
        playerdata[cur_player_id] = {}
        local unit_id = unit:get_id()   -- 单位实例唯一id
        playerdata[cur_player_id][unit_id] = {}     -- 记录生成建筑列表
        playerdata[cur_player_id][unit_id].unit_key = unit:get_key() -- 单位类型key
        playerdata[cur_player_id].pos = point

        local road_point = get_nearest_road_point(py_road, point)
        local mons_point = get_zone_point(road_point)

        -- 生成怪物
        -- local monster = y3.unit.create_unit(y3.player(31), 134243613, mons_point, 0) -- 31 中立敌对 32 中立友善
        -- 命令怪物攻击移动到目标位置
        -- monster:attack_move(mons_point)
        -- monster:hold(mons_point)
        -- logger.info("召唤怪物 ", monster:get_id())

        local oneBuild = {spawn_point = mons_point, unit=unit}
        oneBuild.battle_wave = battle_wave.new(oneBuild.spawn_point)
        oneBuild.battle_wave:next_wave()
        table.insert(GlobalData.builds, oneBuild)

    end)
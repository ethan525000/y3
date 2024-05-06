-- 游戏启动后会自动运行此文件
y3.config.log.toGame = false

-- y3.game:event('游戏-初始化', function (trg, data)
--     print('Hello, Y3!')
-- end)

-- y3.timer.loop(5, function (timer, count)
--     -- print('每5秒显示一次文本，这是第' .. tostring(count) .. '次')
-- end)

-- y3.game:event('键盘-按下', y3.const.KeyboardKey['SPACE'], function ()
--     print('你按下了空格键！')
-- end)

GlobalData = {}
GlobalData.initTime = y3.game.get_game_init_time_stamp()
GlobalData.emumData = {}
GlobalData.runData = {}
GlobalData.builds = {}
GlobalData.scope = 0
GlobalData.playscore = {}
GlobalData.runData.playerData = {}  -- [player_id][unitid]建筑列表
GlobalData.emumData.jianzao_danyuan = {
    [134265545] = "孙尚香",
    [134258818] = "郭嘉",
}

GlobalData.generate_monsters_config = {
    -- 怪物类型                  刷怪数
    { monster_type = 134243613, count = 2 }, --牛头战士
    { monster_type = 134227878, count = 2 }, --羊头怪小兵
    { monster_type = 134243613, count = 2 }, --牛头战士
    { monster_type = 134227878, count = 2 }, --羊头怪小兵
    { monster_type = 134243613, count = 2 }, --牛头战士
    { monster_type = 134227878, count = 2 }, --羊头怪小兵
}

function addPersonScore(player, score)
    local playerid = player:get_id()
    GlobalData.playscore[playerid]=(GlobalData.playscore[playerid] or 0) + score
    GlobalData.scope = GlobalData.scope + score
    logger.info("addPersonScore ", score, GlobalData.scope)
    -- y3.game:event_notify_with_args('boss积分增加',  {}, GlobalData.scope)
    -- print('发了 boss积分增加 事件', ...)

    return GlobalData.scope
end

require "base.luaext"
require "base.misc"
require "base.dprint"
require "eca.regpath"
require "eca.regmons"
require "eca.regevent"


-- local battle_wave = require 'eca.buildmons'

local builds = GlobalData.builds


y3.game:event('游戏-初始化', function (trg, data)
    -- print('Hello, Y3!')

end)

y3.game:event('技能-建造完成', function (trg, data)
    print('技能-建造完成!!!', data.ability:get_name(), data.unit:get_name())-- 孙尚香 单位 挑战者
    print('技能-建造完成 222 !!!', data.unit:get_owner():get_name(), data.ability:get_owner():get_name())  -- ethan 挑战者
end)

-- 注册发生事件时回调
-- y3.game:event_on('自定义积分增加', {'123'}, function (trigger, ...)
--     print('触发了自定义积分增加事件', ...)
-- end)


-- y3.game:event_on('boss积分增加',  function (trigger, ...)
--     print('触发了boss积分增加事件', ...)
-- end)

-- 发送自定义事件给ECA
-- GameAPI.send_custom_event

-- y3.timer.loop(1, function (timer, count)
    -- print('每5秒显示一次文本，这是第' .. tostring(count) .. '次')
    -- print('秒定时器', GlobalData.initTime, y3.game.current_game_run_time())
-- end)

y3.ltimer.wait(1, function ()

    y3.ltimer.loop(5, function(timer)
        for ix, oneBuild in ipairs(builds) do
            if oneBuild.battle_wave then
                oneBuild.battle_wave:next_wave()

                if oneBuild.battle_wave:get_alive_count() == 0 and not oneBuild.battle_wave:has_next() then
                    oneBuild.battle_wave:stop()
                    table.remove(builds, ix)
                    logger.info(" 建筑%s 刷怪结束 !!!", oneBuild.unit:get_id())
                end
            end

            -- timer:remove()
            -- logger.info(" 刷怪结束 !!!")
        end
       
    end)

end)
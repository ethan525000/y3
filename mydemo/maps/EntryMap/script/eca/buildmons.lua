local deepcopy     = table.deepcopy

local M = {}


-- 怪物出生坐标
-- local spawn_point = y3.point.create(0, -2000, 0)
-- 怪物进攻目标
-- local attack_point = y3.point.create(0, -2000, 0)

-- 刷下一波怪
function M:next_wave()
    if not self:has_next() then
        return 
    end

    if self.stopped then
        return 
    end

    self.wave_index = self.wave_index + 1

    -- 怪物类型
    local monster_type = self.monsters_config[self.wave_index].monster_type

    -- 这一波要刷的怪物数量
    local count = self.monsters_config[self.wave_index].count

    -- 每间隔一秒刷一个怪物
    y3.timer.count_loop(1, count, function()
        if self.stopped then
            return
        end

        -- 生成怪物
        local monster = y3.unit.create_unit(y3.player(31), monster_type, self.spawn_point, 0)

        -- 命令怪物攻击移动到目标位置
        monster:attack_move(self.spawn_point)

        self.alive_count = self.alive_count + 1

        monster:event('单位-死亡', function(_, data)
            self.alive_count = self.alive_count - 1
        end)
    end)

end

---@return boolean 有无下波怪
function M:has_next()
    return self.wave_index < self.total_batch_count
end

function M:get_alive_count()
    return self.alive_count
end

function M:stop()
    self.stopped = true
end


function M:set_spawn_point(spawn_point)
    self.spawn_point = spawn_point
end

function M:init()
    self.stopped = false
    -- 初始为第0波怪物
    self.wave_index = 0
    -- 总共几波
    self.total_batch_count = #self.monsters_config
    -- 场上存活的怪物
    self.alive_count = 0
end

function M:set_mons_cfg(cfg)
    if not type(cfg) == "table" then
       return 
    end
    self.monsters_config = deepcopy(cfg)
end

M.new = function(spawn_point, mons_cfg)
    local t = {}
    t.spawn_point = spawn_point
    
    setmetatable(t, {__index = M})
    t:set_mons_cfg(mons_cfg or GlobalData.generate_monsters_config)
    t:init()
    return t
end

return M

-- 注册事件类的ECA回调函数

New 'ECAFunction' '增加BOSS积分'
    -- 声明第一个参数的ECA类型
    : with_param('事件玩家', 'py_player')
    : with_param('增加积分', 'addscore')
    -- 声明返回值的ECA类型
    : with_return('总积分', 'integer')
    ---@param py_player py.Role 玩家
    ---@param addscore  number
    ---@return integer scope 

    : call(function (py_player, addscore)

        -- print("call 增加BOSS积分 ", addscore
        local player = y3.player.get_by_handle(py_player)
        return addPersonScore(player, addscore)
    end)




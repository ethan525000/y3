misc = {}

function misc.now() --客户端本地时间,和服务器时间不一定相同,所以要注意使用(如服务器时间或本地时间跑不准,跨区等)
    return os.time();
end
function misc.Int(value)
    return math.floor(value)
end
function misc.Ceil(value) --向上取值,和Int是相反的
    return math.ceil(value)
end
function misc.int(value)
    return math.floor(tonumber(value))
end

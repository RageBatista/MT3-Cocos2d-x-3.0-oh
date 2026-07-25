

HttpManager ={}
HttpManager.__index = HttpManager

local _instance

function HttpManager.getInstance()
    if not _instance then
        _instance = HttpManager:new()
    end
    return _instance
end

function HttpManager.destroyInstance()
    if _instance then
        _instance = nil
    end
end

function HttpManager:new()
    local self = {}
    setmetatable(self, HttpManager)
    self.callback={}
    return self
end

function HttpManager:SendData(url,postdata,dataid,callback)
    self.callback[dataid]=callback
    local req=CRequestPost:Create()
    req.url=url
    req.dataid=dataid;
    req.postdata=postdata
    LuaProtocolManager.getInstance():send(req)
end

function HttpManager:RecvData(retvalue,dataid)
    if self.callback[dataid] then
        self.callback[dataid](retvalue)
        self.callback[dataid]=nil
    end
end

return HttpManager

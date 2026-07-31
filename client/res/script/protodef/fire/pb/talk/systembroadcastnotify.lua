require "utils.tableutil"
SSystemBroadcastNotify = {}
SSystemBroadcastNotify.__index = SSystemBroadcastNotify
--gs:SSystemBroadcastNotify
SSystemBroadcastNotify.PROTOCOL_TYPE = 792503

-- 优先级常量
SSystemBroadcastNotify.PRIORITY_LOW = 0      -- 低优先级
SSystemBroadcastNotify.PRIORITY_NORMAL = 1    -- 普通优先级
SSystemBroadcastNotify.PRIORITY_HIGH = 2      -- 高优先级

-- 消息类型常量
SSystemBroadcastNotify.MSG_TYPE_SYSTEM = 0    -- 系统消息
SSystemBroadcastNotify.MSG_TYPE_ACTIVITY = 1  -- 活动通知
SSystemBroadcastNotify.MSG_TYPE_NOTICE = 2    -- 公告

function SSystemBroadcastNotify.Create()
    return SSystemBroadcastNotify:new()
end

function SSystemBroadcastNotify:new()
    local self = {}
    setmetatable(self, SSystemBroadcastNotify)
    self.type = self.PROTOCOL_TYPE
    self.messageId = 0          -- 消息ID
    self.msgId = 0             -- 消息模板ID
    self.parameters = {}        -- 消息参数列表
    self.timestamp = 0         -- 时间戳
    self.priority = 1          -- 优先级
    self.msgType = 0           -- 消息类型
    return self
end

function SSystemBroadcastNotify:unmarshal(_os_)
    self.messageId = _os_:unmarshal_uint64()
    self.msgId = _os_:unmarshal_int32()
    
    -- 读取参数列表
    local paramCount = _os_:unmarshal_uint32()
    self.parameters = {}
    for i = 1, paramCount do
        table.insert(self.parameters, _os_:unmarshal_wstring())
    end
    
    self.timestamp = _os_:unmarshal_uint64()
    self.priority = _os_:unmarshal_int32()
    self.msgType = _os_:unmarshal_int32()
    return self
end

-- 获取格式化后的消息内容
function SSystemBroadcastNotify:getFormattedMessage()
    local msg = GetStringFromId(self.msgId)
    if not msg or msg == "" then
        return ""
    end
    
    -- 替换参数占位符 {1}, {2}, {3}...
    if self.parameters then
        for i, param in ipairs(self.parameters) do
            local placeholder = "{" .. i .. "}"
            msg = string.gsub(msg, placeholder, param)
        end
    end
    
    return msg
end

-- 判断是否高优先级
function SSystemBroadcastNotify:isHighPriority()
    return self.priority == self.PRIORITY_HIGH
end

-- 判断是否是公告类型
function SSystemBroadcastNotify:isNotice()
    return self.msgType == self.MSG_TYPE_NOTICE
end

-- 判断是否是活动类型
function SSystemBroadcastNotify:isActivity()
    return self.msgType == self.MSG_TYPE_ACTIVITY
end

return SSystemBroadcastNotify

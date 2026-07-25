require "utils.tableutil"
SHornNotify = {}
SHornNotify.__index = SHornNotify
--gs:SUseHornNotify
SHornNotify.PROTOCOL_TYPE = 792502

-- 广播类型常量
SHornNotify.BROADCAST_TYPE_LOCAL = 1       -- 本服广播
SHornNotify.BROADCAST_TYPE_CROSS_ZONE = 2   -- 全服广播

function SHornNotify.Create()
    return SHornNotify:new()
end

function SHornNotify:new()
    local self = {}
    setmetatable(self, SHornNotify)
    self.type = self.PROTOCOL_TYPE
    self.messageId = 0        -- 消息ID
    self.senderId = 0         -- 发送者ID
    self.senderName = ""      -- 发送者名称
    self.senderTitle = 0      -- 发送者称号
    self.vipLevel = 0        -- VIP等级
    self.content = ""         -- 广播内容
    self.timestamp = 0       -- 时间戳
    self.zoneId = 0          -- 大区ID
    self.broadcastType = 1   -- 广播类型
    self.color = 0           -- 消息颜色
    return self
end

function SHornNotify:unmarshal(_os_)
    self.messageId = _os_:unmarshal_uint64()
    self.senderId = _os_:unmarshal_uint64()
    self.senderName = _os_:unmarshal_wstring(self.senderName)
    self.senderTitle = _os_:unmarshal_int32()
    self.vipLevel = _os_:unmarshal_int32()
    self.content = _os_:unmarshal_wstring(self.content)
    self.timestamp = _os_:unmarshal_uint64()
    self.zoneId = _os_:unmarshal_int32()
    self.broadcastType = _os_:unmarshal_int32()
    self.color = _os_:unmarshal_int32()
    return self
end

-- 获取发送者显示名称（带VIP标识）
function SHornNotify:getDisplayName()
    local name = self.senderName
    if self.vipLevel > 0 then
        name = "[VIP" .. self.vipLevel .. "]" .. name
    end
    return name
end

-- 获取消息颜色
function SHornNotify:getColor()
    return self.color or 0
end

-- 判断是否全服广播
function SHornNotify:isCrossZone()
    return self.broadcastType == self.BROADCAST_TYPE_CROSS_ZONE
end

return SHornNotify

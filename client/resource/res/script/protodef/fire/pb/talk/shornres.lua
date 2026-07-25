require "utils.tableutil"
SHornRes = {}
SHornRes.__index = SHornRes
--gs:SUseHornRes
SHornRes.PROTOCOL_TYPE = 792501

-- 结果码常量
SHornRes.RESULT_SUCCESS = 0
SHornRes.RESULT_RATE_LIMIT = 1           -- 发送过于频繁
SHornRes.RESULT_SENSITIVE_WORD = 2       -- 包含敏感词
SHornRes.RESULT_NO_PERMISSION = 3        -- 无权限
SHornRes.RESULT_ITEM_NOT_ENOUGH = 4      -- 道具不足
SHornRes.RESULT_CONTENT_INVALID = 5      -- 内容非法
SHornRes.RESULT_SYSTEM_ERROR = 6         -- 系统错误
SHornRes.RESULT_BLACKLISTED = 7          -- 账号在黑名单中
SHornRes.RESULT_FUNCTION_DISABLED = 8    -- 功能已关闭

function SHornRes.Create()
    return SHornRes:new()
end

function SHornRes:new()
    local self = {}
    setmetatable(self, SHornRes)
    self.type = self.PROTOCOL_TYPE
    self.result = 0            -- 结果码
    self.errorMessage = ""    -- 错误信息
    return self
end

function SHornRes:unmarshal(_os_)
    self.result = _os_:unmarshal_int32()
    self.errorMessage = _os_:unmarshal_wstring(self.errorMessage)
    return self
end

-- 判断是否成功
function SHornRes:isSuccess()
    return self.result == self.RESULT_SUCCESS
end

-- 获取错误描述
function SHornRes:getErrorDesc()
    if self.result == self.RESULT_SUCCESS then
        return ""
    end
    
    if self.errorMessage and self.errorMessage ~= "" then
        return self.errorMessage
    end
    
    -- 根据错误码返回默认描述
    local descMap = {
        [self.RESULT_RATE_LIMIT] = "发送过于频繁，请稍后再试",
        [self.RESULT_SENSITIVE_WORD] = "包含敏感词，无法发送",
        [self.RESULT_NO_PERMISSION] = "没有权限发送广播",
        [self.RESULT_ITEM_NOT_ENOUGH] = "喇叭道具不足",
        [self.RESULT_CONTENT_INVALID] = "内容非法",
        [self.RESULT_SYSTEM_ERROR] = "系统错误",
        [self.RESULT_BLACKLISTED] = "账号在黑名单中",
        [self.RESULT_FUNCTION_DISABLED] = "该功能已关闭",
    }
    
    return descMap[self.result] or "未知错误"
end

return SHornRes

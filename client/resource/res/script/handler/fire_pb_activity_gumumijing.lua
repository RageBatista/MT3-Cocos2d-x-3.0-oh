local p = require "protodef.fire.pb.activity.exchangecode.sexchangecode"
function p:process()
    local code = self.flag
    local ErrorString =
    {
        [1] = MHSD_UTILS.get_msgtipstring(160327),
        [3] = MHSD_UTILS.get_msgtipstring(160324),
        [4] = MHSD_UTILS.get_msgtipstring(160328),
        [5] = MHSD_UTILS.get_msgtipstring(160323),
        [6] = MHSD_UTILS.get_msgtipstring(160330),
        [7] = MHSD_UTILS.get_msgtipstring(160329),
        [16] = MHSD_UTILS.get_msgtipstring(160407)
    }
    local text = ErrorString[code]
    if text then
        GetCTipsManager():AddMessageTip(text)
    else --如果没有错误号 弹默认提示
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(160326))
    end

end
local sqqexchangecodestatus = require "protodef.fire.pb.activity.exchangecode.sqqexchangecodestatus"
function sqqexchangecodestatus:process()
    LoginRewardManager:SetQQopen(self.status)
end



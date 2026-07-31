ShouJiAnQuanMgr =
{
    tel                 = 0,    -- 关联手机号码
    createdate          = 0,    -- 角色创建时间点
    isfistloginofday    = 0,    -- 是否今天第一次登陆
    isgetbindtelaward   = 0,    -- 是否已经领取奖励 0-未领且不可领 1-已领 2-未领且可领
    isbindtelagain      = 0,    -- 是否需要验证手机

    finishtimepoint     = 0,    -- 验证码倒计时完成时间点

    telrecord           = 0,    -- 获取验证码时，临时记录的手机号
    telforconfirm       = 0,    -- 确认关联时，临时记录的手机号码
}

function ShouJiAnQuanMgr.isBindTel()
    return  ShouJiAnQuanMgr.tel > 0
end

function ShouJiAnQuanMgr.notBind7Days()
    local elapseSecond = (gGetServerTime() - ShouJiAnQuanMgr.createdate) / 1000
    if elapseSecond > 7 * 24 * 3600 and ShouJiAnQuanMgr.tel == 0 then
        return true
    end
    return false
end

function ShouJiAnQuanMgr.notBind4DaysAndFirstLoginToday()
    local elapseSecond = (gGetServerTime() - ShouJiAnQuanMgr.createdate) / 1000
    if elapseSecond > 4 * 24 * 3600 and elapseSecond < 5 * 24 * 3600 and ShouJiAnQuanMgr.tel == 0 and ShouJiAnQuanMgr.isfistloginofday == 1 then
        return true
    end
    return false
end

function ShouJiAnQuanMgr.refreshAwardOpen()
    if not ShouJiAnQuanMgr.isGetAward() then
        require("logic.qiandaosongli.loginrewardmanager").getInstance():SetPhoneBindOpen(1)
    else
        require("logic.qiandaosongli.loginrewardmanager").getInstance():SetPhoneBindOpen(0)
    end
end

function ShouJiAnQuanMgr.refreshAwardRedPoint()
    if ShouJiAnQuanMgr.canGetAward() and not ShouJiAnQuanMgr.isGetAward() then
        require("logic.qiandaosongli.loginrewardmanager").getInstance():SetPhoneBindRedPoint(1)
    else
        require("logic.qiandaosongli.loginrewardmanager").getInstance():SetPhoneBindRedPoint(0)
    end
end

-- 满足领奖条件
function ShouJiAnQuanMgr.canGetAward()
    return ShouJiAnQuanMgr.isBindTel() or ShouJiAnQuanMgr.isgetbindtelaward == 2
end

-- 已经领奖
function ShouJiAnQuanMgr.isGetAward()
    return ShouJiAnQuanMgr.isgetbindtelaward == 1
end

-- 是否需要验证手机
function ShouJiAnQuanMgr.needBindTelAgain()
    return ShouJiAnQuanMgr.isbindtelagain == 1
end

-- 是否可以获取验证码
function ShouJiAnQuanMgr.canRequestCode()
    local serverTime = gGetServerTime()
    if ShouJiAnQuanMgr.telrecord == 0 or serverTime > ShouJiAnQuanMgr.finishtimepoint then
        return true
    end
    return false
end

-- 清空数据
function ShouJiAnQuanMgr.clear()
    ShouJiAnQuanMgr.tel                 = 0
    ShouJiAnQuanMgr.createdate          = 0
    ShouJiAnQuanMgr.isfistloginofday    = 0
    ShouJiAnQuanMgr.isgetbindtelaward   = 0
    ShouJiAnQuanMgr.isbindtelagain      = 0
    ShouJiAnQuanMgr.finishtimepoint     = 0
    ShouJiAnQuanMgr.telrecord           = 0
    ShouJiAnQuanMgr.telforconfirm       = 0
end

return ShouJiAnQuanMgr
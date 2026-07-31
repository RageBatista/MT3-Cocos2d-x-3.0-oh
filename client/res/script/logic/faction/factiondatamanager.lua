FactionDataManager =
{
    campid = 0,
    factionid = 0,
    factionname = "",
    factionlevel = 0,
    membersnum = 0,
    factionmaster = 0,
    factionaim = "",
    index = 0,
    factioncreator = "",
    oldfactionname = "",
    factioncreatorid = 0,
    money = 0,
    bonus = 0,                      -- 公会分红
    house = {0,0,0,0},
    autostate = 0,
    requestlevel = 0,
    costeverymoney = 0,
    costmax = {0,0,0,0},
    claninstservice = {},

    -- 弹劾数据
    m_bClickToShowImpeachUI = false,    -- 是否点击打开弹劾界面
    m_impeach =
    {
        state   = 0,    -- 弹劾状态 0-没有人弹劾会长 1-有人弹劾会长
        maxnum  = 0,    -- 弹劾成功需要的人数
        name    = "",   -- 发起弹劾人的名称
        time    = 0,    -- 发起弹劾时间
        curnum  = 0,    -- 当前响应人数
    },

    -- 公会列表
    m_FamilyList =
    {
        m_Curpage = 0,              -- 当前默认页
        m_FactionList = { }         -- 公会列表
    },
    
    m_ApplyerList = { },            -- 自己公会的申请者列表
    members = { },                  -- 成员列表(协议“SRefreshMemberList”的返回)

    m_LastSearchResult = { },       -- 上一次搜索公会的结果，缓存了一下，用于以后界面缓存每次搜索的时候会先清理
    m_SearchIsNull = false,         -- 上一次搜索公会结果是否为空
    m_IsOpenFamilyUI = 0,           -- 是否点击创建公会
    m_HasbeenApplyList = { },       -- 已经申请的公会列表
    m_FamilyEventList = { },        -- 公会事件信息列表
    m_FamilyYaoFangInfor = { },     -- 药房信息
    m_FamilyYaoFangList = { },      -- 药房列表
    m_FamilyChanYaoMode = 0,        -- 选择几倍产药
    m_CurDayHasBuyNumber = 0,       -- 当天已经购买数量
    m_RuneQuestList = { },          -- 符文请求列表
    m_HasBeenRuneQuestList = { },   -- 已经申请符文的列表
    m_DaFuTimes = 0,                -- 打符次数
    m_FuwenTongjiList = { },        -- 符文统计信息列表
    m_XiaoHaoHuoLi = 0,             -- 消耗活力

    -- key : 职业code ; value : 制符道具code
    m_FuwenMap =
    {
        [11] = 331201,----大唐
        [12] = 331204,----方寸
        [13] = 331206,----狮驼
        [14] = 331205,----地府
        [15] = 331202,----龙宫
        [16] = 331203,----普陀
        [17] = 331209,----魔王
        [18] = 331208,----月宫
        [19] = 331207----化生
    },
    m_FactionTips = nil,            -- 红点信息
    m_ApplyTimeCollection = { }     -- 邀请加入公会倒计时
}

-- 当前是否有工会判断，进入不同UI
-- 有公会进入工会信息
-- 没有工会进入加入公会UI
function FactionDataManager.OpenFamilyUI()
    if FactionDataManager:IsHasFaction() then
        local p = require "protodef.fire.pb.clan.copenclan":new()
        require "manager.luaprotocolmanager".getInstance():send(p)
        FactionDataManager.m_IsOpenFamilyUI = 1
    else
        require "logic.family.familyjiarudialog".getInstanceAndShow()
    end
end

-- 会长弹劾相关的请求
function FactionDataManager.RequestImpeach(cmdtype)
    local p = require "protodef.fire.pb.clan.crequestimpeachmentview".Create()
    p.cmdtype = cmdtype
    require "manager.luaprotocolmanager".getInstance():send(p)
end

-- 计时器，目前只用于邀请加入的倒计时
function FactionDataManager.OnTick(delta)
    local toRemove = { }
    local len = #FactionDataManager.m_ApplyTimeCollection
    for i = 1, len do
        local temp = FactionDataManager.m_ApplyTimeCollection[i]
        if temp then
            if temp.value then
                temp.value = temp.value - delta
                if temp.value <= 0 then
                    table.insert(toRemove, i)
                end
            end
        end
    end
    for k, v in pairs(toRemove) do
        table.remove(FactionDataManager.m_ApplyTimeCollection, v)
    end
end

-- 添加邀请加入公会倒计时
function FactionDataManager.AddApplyTimeCollection(id)
    local entry = FactionDataManager.GetApplyTimeCollectionEntry(id)
    if not entry then
        local temp = { }
        temp.key = id
        temp.value = 10000
        table.insert(FactionDataManager.m_ApplyTimeCollection, temp)
    end
end

-- 添加邀请加入公会倒计时
function FactionDataManager.GetApplyTimeCollectionEntry(id)
    for _, v in pairs(FactionDataManager.m_ApplyTimeCollection) do
        if v.key == id then
            return v
        end
    end
    return nil
end

-- 刷新红点提示
function FactionDataManager.RefreshRedPointTips()
    if not FactionDataManager.m_FactionTips then
        return
    end
    -- 主界面
    local mainDlg = MainControl.getInstanceNotCreate()
    local ret = FactionDataManager.m_FactionTips[1]
    if mainDlg then
        if mainDlg.m_pFactionMark then
            mainDlg.m_mTipNum[9] = ret
            mainDlg:setSimplify(13, ret)
        end
        if ret == 0 then
            if FactionDataManager.bonus > 0 then
                mainDlg.m_mTipNum[9] = 1
                mainDlg:refreshTipInfo()
                mainDlg:setSimplify(13, 1)
            end
        end
    end
    -- 成员界面
    local chengyuanDlg = Familychengyuandialog.getInstanceNotCreate()
    if chengyuanDlg then
        if chengyuanDlg.m_TipImage2 then
            chengyuanDlg.m_TipImage2:setVisible(ret == 1)
        end
    end

    local FamilyLabelDlg = Familylabelframe.getInstanceNotCreate()
    if FamilyLabelDlg then
        if FamilyLabelDlg.ChengyuanImageTips then
            FamilyLabelDlg.ChengyuanImageTips:setVisible(ret == 1)
        end
        if FamilyLabelDlg.FuliImageTips then
            FamilyLabelDlg.FuliImageTips:setVisible(FactionDataManager.bonus > 0)
        end
    end

    local ZhanDouAnNiuDlg = ZhanDouAnNiu.getInstanceNotCreate()
    if ZhanDouAnNiuDlg then
        if ZhanDouAnNiuDlg.m_pBangPaiMark then
              ZhanDouAnNiuDlg.m_pBangPaiMark:setVisible(ret == 1)
        end
    end
    
end

-- 符文统计排序
function FactionDataManager.FuWenTongJiSort()
    local function SortFuWen(a1, a2)
        if a1.givenum ~= a2.givenum then
            return a1.givenum > a2.givenum
        end
        if a1.acceptnum ~= a2.acceptnum then
            return a1.acceptnum > a2.acceptnum
        end
        -- return a1.requesttime>a2.requesttime
        return a1.roleid > a2.roleid
    end
    table.sort(FactionDataManager.m_FuwenTongjiList, SortFuWen)
end

-- 获得符文统计相关的信息
function FactionDataManager.GetFuWenTongJiInfor(roleid)
    for k, v in pairs(FactionDataManager.m_FuwenTongjiList) do
        if v then
            if v.roleid == roleid then
                return v
            end
        end
    end
    return nil
end

-- 此符文id 是否要显示
function FactionDataManager.IsPassFuwenShow(id)
    local data = gGetDataManager():GetMainCharacterData()
    local infor = FactionDataManager.getMember(data.roleid)
    if infor and infor.school then
        local ret = FactionDataManager.m_FuwenMap[infor.school]
        if ret then
            if id == ret then
                return true
            end
        end
    end
    return false
end

-- 获得药房entry
function FactionDataManager.getYaoFangEntry(id)
    for k, v in pairs(FactionDataManager.m_FamilyYaoFangList) do
        if v then
            if v.itemid == id then
                return v
            end
        end
    end


end

-- 清理公会事件
function FactionDataManager.ClearEventList()
    FactionDataManager.m_FamilyEventList = { }
end

--[[ ================公会成员列表排序相关================= ]]

-- 1 升序 -1 降序
-- 排序按照ID
function FactionDataManager.SortByID(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByIDUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByIDDown)
    end
end
function FactionDataManager.SortByIDUp(a, b)
    return a.roleid < b.roleid
end
function FactionDataManager.SortByIDDown(a, b)
    return a.roleid > b.roleid
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照Level
function FactionDataManager.SortByLevel(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLevelUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLevelDown)
    end
end
function FactionDataManager.SortByLevelUp(a, b)
    if a.rolelevel ~= b.rolelevel then
        return a.rolelevel < b.rolelevel
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLevelDown(a, b)
    if a.rolelevel ~= b.rolelevel then
        return a.rolelevel > b.rolelevel
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照职业
function FactionDataManager.SortByZhiYe(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortBySchoolUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortBySchoolDown)
    end
end
function FactionDataManager.SortBySchoolUp(a, b)
    if a.school ~= b.school then
        return a.school < b.school
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortBySchoolDown(a, b)
    if a.school ~= b.school then
        return a.school > b.school
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照职务
function FactionDataManager.SortByZhiWu(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByZhiWuUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByZhiWuDown)
    end
end
function FactionDataManager.SortByZhiWuUp(a, b)
    if a.position ~= b.position then
        return a.position > b.position
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByZhiWuDown(a, b)
    if a.position ~= b.position then
        return a.position < b.position
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照上周贡献
function FactionDataManager.SortByShangZhouGongXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByShangZhouGongXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByShangZhouGongXianDown)
    end
end
function FactionDataManager.SortByShangZhouGongXianUp(a, b)
    if a.preweekcontribution ~= b.preweekcontribution then
        return a.preweekcontribution < b.preweekcontribution
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByShangZhouGongXianDown(a, b)
    if a.preweekcontribution ~= b.preweekcontribution then
        return a.preweekcontribution > b.preweekcontribution
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照本周贡献
function FactionDataManager.SortByBenZhouGongXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenZhouGongXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenZhouGongXianDown)
    end
end
function FactionDataManager.SortByBenZhouGongXianUp(a, b)
    if a.weekcontribution ~= b.weekcontribution then
        return a.weekcontribution < b.weekcontribution
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByBenZhouGongXianDown(a, b)
    if a.weekcontribution ~= b.weekcontribution then
        return a.weekcontribution > b.weekcontribution
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照历史贡献
function FactionDataManager.SortByXianYouGongXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByXianYouGongXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByXianYouGongXianDown)
    end
end
function FactionDataManager.SortByXianYouGongXianUp(a, b)
    if a.rolecontribution ~= b.rolecontribution then
        return a.historycontribution < b.historycontribution
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByXianYouGongXianDown(a, b)
    if a.rolecontribution ~= b.rolecontribution then
        return a.historycontribution > b.historycontribution
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照历史贡献
function FactionDataManager.SortByLiShiGongXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiGongXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiGongXianDown)
    end
end
function FactionDataManager.SortByLiShiGongXianUp(a, b)
    if a.historycontribution ~= b.historycontribution then
        return a.historycontribution < b.historycontribution
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLiShiGongXianDown(a, b)
    if a.historycontribution ~= b.historycontribution then
        return a.historycontribution > b.historycontribution
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照周援助
function FactionDataManager.SortByBenZhouYuanZhu(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenZhouYuanZhuUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenZhouYuanZhuDown)
    end
end
function FactionDataManager.SortByBenZhouYuanZhuUp(a, b)
    if a.weekaid ~= b.weekaid then
        return a.weekaid < b.weekaid
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByBenZhouYuanZhuDown(a, b)
    if a.weekaid ~= b.weekaid then
        return a.weekaid > b.weekaid
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照历史援助
function FactionDataManager.SortByLiShiYuanZhu(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiYuanZhuUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiYuanZhuDown)
    end
end
function FactionDataManager.SortByLiShiYuanZhuUp(a, b)
    if a.historyaid ~= b.historyaid then
        return a.historyaid < b.historyaid
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLiShiYuanZhuDown(a, b)
    if a.historyaid ~= b.historyaid then
        return a.historyaid > b.historyaid
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按按参加公会副本次数排序
function FactionDataManager.SortByBenLunJingSai(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenLunJingSaiUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenLunJingSaiDown)
    end
end
function FactionDataManager.SortByBenLunJingSaiUp(a, b)
    if a.claninstnum ~= b.claninstnum then
        return a.claninstnum < b.claninstnum
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByBenLunJingSaiDown(a, b)
    if a.claninstnum ~= b.claninstnum then
        return a.claninstnum > b.claninstnum
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按参加公会战次数
function FactionDataManager.SortByLiShiJingSai(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiJingSaiUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiJingSaiDown)
    end
end
function FactionDataManager.SortByLiShiJingSaiUp(a, b)
    if a.clanfightnum ~= b.clanfightnum then
        return a.clanfightnum < b.clanfightnum
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLiShiJingSaiDown(a, b)
    if a.clanfightnum ~= b.clanfightnum then
        return a.clanfightnum > b.clanfightnum
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照入会时间
function FactionDataManager.SortByRuHui(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByRuHuiUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByRuHuiDown)
    end
end
function FactionDataManager.SortByRuHuiUp(a, b)
    if a.jointime ~= b.jointime then
        return a.jointime < b.jointime
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByRuHuiDown(a, b)
    if a.jointime ~= b.jointime then
        return a.jointime > b.jointime
    else
        return a.roleid < b.roleid
    end
end


 

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照综合战力
function FactionDataManager.SortByFightValue(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByFightValueUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByFightValueDown)
    end
end
function FactionDataManager.SortByFightValueUp(a, b)
    if a.fightvalue ~= b.fightvalue then
        return a.fightvalue < b.fightvalue
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByFightValueDown(a, b)
    if a.fightvalue ~= b.fightvalue then
        return a.fightvalue > b.fightvalue
    else
        return a.roleid < b.roleid
    end
end


---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照离线时间
function FactionDataManager.SortByLiXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiXianDown)
    end
end
function FactionDataManager.SortByLiXianUp(a, b)
    if a.lastonlinetime ~= b.lastonlinetime and a.lastonlinetime~=0 and b.lastonlinetime~=0 then
        return a.lastonlinetime < b.lastonlinetime
    elseif a.lastonlinetime + b.lastonlinetime ~=0 and a.lastonlinetime*b.lastonlinetime == 0 then
        if a.lastonlinetime == 0 then
         return false
        else
         return true
        end
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLiXianDown(a, b)
    if a.lastonlinetime ~= b.lastonlinetime and a.lastonlinetime~=0 and b.lastonlinetime~=0 then
        return a.lastonlinetime > b.lastonlinetime
    elseif a.lastonlinetime + b.lastonlinetime ~=0 and a.lastonlinetime*b.lastonlinetime == 0 then
        if a.lastonlinetime == 0 then
         return true
        else
         return false
        end
    else
        return a.roleid < b.roleid
    end
end


--[[ ================公会申请列表排序相关================= ]]

-- 1 升序 -1 降序
-- 排序按照ID
function FactionDataManager.ShenqingSortByID(Type)
    if Type == 1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByIDUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByIDDown)
    end
end
function FactionDataManager.ShenqingSortByIDUp(a, b)
    return a.roleid < b.roleid
end
function FactionDataManager.ShenqingSortByIDDown(a, b)
    return a.roleid > b.roleid
end

---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照Level
function FactionDataManager.ShenqingSortByLevel(Type)
    if Type == 1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByLevelUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByLevelDown)
    end
end
function FactionDataManager.ShenqingSortByLevelUp(a, b)
    if a.rolelevel ~= b.rolelevel then
        return a.rolelevel < b.rolelevel
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.ShenqingSortByLevelDown(a, b)
    if a.rolelevel ~= b.rolelevel then
        return a.rolelevel > b.rolelevel
    else
        return a.roleid < b.roleid
    end
end



---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照综合战力
function FactionDataManager.ShenqingSortByFightvalue(Type)
    if Type == 1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByFightvalueUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByFightvalueDown)
    end
end
function FactionDataManager.ShenqingSortByFightvalueUp(a, b)
    if a.rolelevel ~= b.fightvalue then
        return a.fightvalue < b.fightvalue
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.ShenqingSortByFightvalueDown(a, b)
    if a.rolelevel ~= b.fightvalue then
        return a.fightvalue > b.fightvalue
    else
        return a.roleid < b.roleid
    end
end


---------------------------------------------

-- 1 升序 -1 降序
-- 排序按照职业
function FactionDataManager.ShenqingSortByZhiYe(Type)
    if Type == 1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortBySchoolUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortBySchoolDown)
    end
end
function FactionDataManager.ShenqingSortBySchoolUp(a, b)
    if a.roleschool ~= b.roleschool then
        return a.roleschool < b.roleschool
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.ShenqingSortBySchoolDown(a, b)
    if a.roleschool ~= b.roleschool then
        return a.roleschool > b.roleschool
    else
        return a.roleid < b.roleid
    end
end

--[[ ================公会相关================= ]]

-- 获得当前在线成员
function FactionDataManager.GetOnLineCollection()
    local ret = { }
    for _, v in pairs(FactionDataManager.members) do
        -- 0 表示在线
        if v.lastonlinetime == 0 then
            table.insert(ret, v)
        end
    end
    return ret
end

-- 移除已经申请的entry
function FactionDataManager.removeHasbeenApplyListEntry(id)
    local idx = 1
    for k, v in pairs(FactionDataManager.m_HasbeenApplyList) do
        if v then
            if v.clankey == id then
                table.remove(FactionDataManager.m_HasbeenApplyList, idx)
                break
            end
        end
        idx = idx + 1
    end
end

-- 获得已经申请的entry
function FactionDataManager.getHasbeenApplyListEntry(id)
    for k, v in pairs(FactionDataManager.m_HasbeenApplyList) do
        if v then
            if v.clankey == id then
                return v
            end
        end
    end
    return nil
end

-- 添加已经申请的entry
function FactionDataManager.addHasbeenApplyListEntry(entry)
    if not entry then
        return
    end
    local IsExist = FactionDataManager.getHasbeenApplyListEntry(entry.clankey)
    if IsExist then
        return
    end
    table.insert(FactionDataManager.m_HasbeenApplyList, entry)
end

--[[
		<variable name="roleid" type="long"/>                           角色id
		<variable name="shapeid" type="int"/>                           头像id
		<variable name="rolename" type="string"/>                       成员名字
		<variable name="rolelevel" type="int"/>                         角色等级
		<variable name="rolecontribution" type="int"/>                  公会贡献度
		<variable name="weekcontribution" type="int"/>                  本周公会贡献度
		<variable name="historycontribution" type="int"/>               历史公会贡献度
		<variable name="rolefreezedcontribution" type="int"/>           冻结的公会贡献度
		<variable name="lastonlinetime" type="long"/>                   为0表示在线，否则表示上次离线时间,单位毫秒
		<variable name="position" type="int"/>                          见FactionPositionType
		<variable name="salutation"  type="string"/>                    公会中的称谓
		<variable name="availableExchangeContribution"  type="int"/>    当前可兑换公会贡献度（一周累计，下周清除）
		<variable name="school" type="int"/>                            职业
		<variable name="jointime" type="long"/>                         加入公会时间
		<variable name="competition" type="int"/>                       本轮竞赛
		<variable name="historycompetition" type="int"/>                历史竞赛
		<variable name="weekaid" type="int"/>                           本周援助
		<variable name="historyaid" type="int"/>                        历史援助
]]--

-- 根据公会id获得相应公会信息
function FactionDataManager.GetFaction(id)
    for _, k in pairs(FactionDataManager.m_FamilyList.m_FactionList) do
        if k.clanid == id then
            return k
        end
    end
    return nil
end

-- 获得当前我冻结的公会贡献度
function FactionDataManager.GetMyDongJieMoney()
    local data = gGetDataManager():GetMainCharacterData()
    local infor = FactionDataManager.getMember(data.roleid)
    if infor then
        return infor.rolefreezedcontribution
    end
    return 0
end

-- 公会中是否存在副会长
function FactionDataManager.IsExistFuHuiZhang()
    for _, v in pairs(FactionDataManager.members) do
        if v.position == 2 then
            return true
        end
    end
    return false
end

-- 获得我在公会中职务的静态详细信息
function FactionDataManager.GetMyZhiWuInfor()
    local zhiwu = FactionDataManager.GetMyZhiWu()
    local conf = BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(zhiwu)
    return conf
end

-- 获得我的公会中职务
function FactionDataManager.GetMyZhiWu()
    -- 获得我的数据
    local data = gGetDataManager():GetMainCharacterData()
    for _, v in pairs(FactionDataManager.members) do
        if v.roleid == data.roleid then
            return v.position
        end
    end
    return -1
end

-- 获得会长信息
function FactionDataManager.GetFamilyHost()
    for _, v in pairs(FactionDataManager.members) do
        if v.position == 1 then
            return v
        end
    end
    return nil
end

-- 追加公会列表
function FactionDataManager.AppendFamilyList(InforList)
    for _, v in pairs(InforList) do
        table.insert(FactionDataManager.m_FamilyList.m_FactionList, v)
    end

end

-- 获得当前公会人数
function FactionDataManager.GetPersonNumber()
    if FactionDataManager.members then
        return #(FactionDataManager.members)
    end
    return 0
end

---- 获得我的公会可以招募的学徒上限
--function FactionDataManager.GetMaxXueTuNumber()
--    local level = FactionDataManager.house[4]
--    local temp = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getRecorder(level)
--    return temp.apprenticemax
--end

-- 获得我的公会可以招募的人数上限
function FactionDataManager.GetMaxPersonNumber()
    local level = FactionDataManager.house[4]
    local temp = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getRecorder(level)
    return temp.peoplemax
end

-- 获得当前公会内在线成员人数
function FactionDataManager.GetOnlinePerson()
    local ret = 0
    for _, v in pairs(FactionDataManager.members) do
        -- 0 表示在线
        if v.lastonlinetime == 0 then
            ret = ret + 1
        end
    end
    return ret
end

---- 获得公会内学徒在线数量
--function FactionDataManager.GetOnlineXueTu()
--    local ret = 0
--    for _, v in pairs(FactionDataManager.members) do
--        -- 0 表示在线
--        if v.lastonlinetime == 0 and v.position == 20 then
--            ret = ret + 1
--        end
--    end
--    return ret
--end

---- 获得现有学徒数量
--function FactionDataManager.GetXueTuNumber()
--    local ret = 0
--    for _, v in pairs(FactionDataManager.members) do
--        if v.position == 20 then
--            ret = ret + 1
--        end
--    end
--    return ret
--end

-- 修改名字
function FactionDataManager.ChangedFactionName(Name)
    FactionDataManager.factionname = Name
end

-- 刷新申请者列表
function FactionDataManager.RefreshApplyerList(args)
    FactionDataManager.m_ApplyerList = { }
    for k, v in pairs(args) do
        FactionDataManager.m_ApplyerList[k] = v
    end
end

-- 添加申请者
function FactionDataManager:AddApplyer(Infor)
    for k, v in pairs(FactionDataManager.m_ApplyerList) do
        if v.roleid == Infor.roleid then
            return
        end
    end
    table.insert(FactionDataManager.m_ApplyerList, Infor)
end

-- 移除申请者
function FactionDataManager.RemoveApplyer(ID)
    for k, v in pairs(FactionDataManager.m_ApplyerList) do
        if v.roleid == ID then
            table.remove(FactionDataManager.m_ApplyerList, k)
            break
        end
    end
end

-- 获得申请者
function FactionDataManager:GetApplyer(args)
end

-- 当前角色是否有公会
function FactionDataManager:IsHasFaction()
    if self.factionid == nil or self.factionid <= 0 then
        return false
    end
    return true
end

-- 清除所有相关的公会信息
function FactionDataManager:Clear()
    FactionDataManager.campid = 0
    FactionDataManager.factionid = 0
    FactionDataManager.factionname = ""
    FactionDataManager.factionlevel = 0
    FactionDataManager.membersnum = 0
    FactionDataManager.factionmaster = 0
    FactionDataManager.factionaim = ""
    FactionDataManager.buildlevel = 0
    FactionDataManager.index = 0
    FactionDataManager.factioncreator = ""
    FactionDataManager.members = { }
    print("===================Clear Faction Data================")
end

-- 获得成员
function FactionDataManager.getMember(memberid)
    if not FactionDataManager.members then
        return false
    end
    for i = 1, #FactionDataManager.members do
        if FactionDataManager.members[i].roleid == memberid then
            return FactionDataManager.members[i]
        end
    end
    return nil
end

-- 移除成员
function FactionDataManager.removeMember(memberid)
    if not FactionDataManager.members then
        return false
    end
    for k, v in pairs(FactionDataManager.members) do
        if FactionDataManager.members[k].roleid == memberid then
            table.remove(FactionDataManager.members, k)
            return true
        end
    end
end
-- 添加成员
function FactionDataManager.addMember(memberinfo)
    if not FactionDataManager.members then
        FactionDataManager.members = { }
    end
    for i = 1, #FactionDataManager.members do
        if FactionDataManager.members[i].roleid == memberinfo.roleid then
            FactionDataManager.members[i] = memberinfo.roleid
            return
        end
    end
    table.insert(FactionDataManager.members, memberinfo)
end

-- 获得当前公会成员名字
function FactionDataManager.GetCurFactionName()
    if not FactionDataManager or not FactionDataManager.members then
        return false, ""
    end

    local curRoleID = -1
    if gGetDataManager() and gGetDataManager():GetMainCharacterID() then
        curRoleID = gGetDataManager():GetMainCharacterID()
    end

    if curRoleID < 0 then
        return false, ""
    end

    for i = 1, #FactionDataManager.members do
        if FactionDataManager.members[i].roleid == curRoleID then
            local result = FactionDataManager.members[i].factionname
            if result then
                return true, result
            else
                print("____not found factionname")
                return false, ""
            end
        end
    end

    return false, ""
end

-- 是否在符文请求信息列表内
function FactionDataManager.IsInHasBeenRuneQuestList(id)
    for k, v in pairs(FactionDataManager.m_HasBeenRuneQuestList) do
        if v then
            if v.itemid == id then
                return true
            end
        end
    end
    return false
end

-- 处理断线重连
function FactionDataManager.onInternetReconnected()
--  FactionDataManager:Clear()
--  local p = require "protodef.fire.pb.clan.copenclan":new()
--  require "manager.luaprotocolmanager".getInstance():send(p)
end

-- 获取工会副本选择信息
function FactionDataManager.getFubenSelectedInfo()
    for k,v in pairs(FactionDataManager.claninstservice)  do
        if v == 1 then
            return k
        end
    end
end

function FactionDataManager.setFubenInfo(idx)
    for k,v in pairs(FactionDataManager.claninstservice)  do
        if k == idx then
            FactionDataManager.claninstservice[k] = 1
        else
            FactionDataManager.claninstservice[k] = 0
        end
    end
end

return FactionDataManager




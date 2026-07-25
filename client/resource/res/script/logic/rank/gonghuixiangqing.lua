require "logic.dialog"

Gonghuixiangqing = { }
setmetatable(Gonghuixiangqing, Dialog)
Gonghuixiangqing.__index = Gonghuixiangqing

local _instance
function Gonghuixiangqing.getInstance()
    if not _instance then
        _instance = Gonghuixiangqing:new()
        _instance:OnCreate()
    end
    return _instance
end

function Gonghuixiangqing.getInstanceAndShow(parent)
    if not _instance then
        _instance = Gonghuixiangqing:new()
        _instance:OnCreate(parent)
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Gonghuixiangqing.getInstanceNotCreate()
    return _instance
end

function Gonghuixiangqing.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Gonghuixiangqing.ToggleOpenClose()
    if not _instance then
        _instance = Gonghuixiangqing:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Gonghuixiangqing.GetLayoutFileName()
    return "gonghuixiangqing.layout"
end

function Gonghuixiangqing:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Gonghuixiangqing)
    return self
end

function Gonghuixiangqing:OnCreate(parent)
    Dialog.OnCreate(self, parent, 1)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- 关闭按钮
    self.closeBtn = CEGUI.toPushButton(winMgr:getWindow(tostring(1) .. "gonghuixiangqing/jiemian/guanbi"))
    -- 宗旨文本
    self.m_ZongZhiText = winMgr:getWindow(tostring(1) .. "gonghuixiangqing/jiemian/xuanyan/wenben")
    -- 曾用名文本
    self.m_CengYongMingText = winMgr:getWindow(tostring(1) .. "gonghuixiangqing/jiemian/cengyongming/gonghuiming")
    -- 申请加入公会按钮
    self.m_BtnApplyJoinToFamily = CEGUI.toPushButton(winMgr:getWindow(tostring(1) .. "gonghuixiangqing/jiemian/gonghuishenqing"))
    -- 联系会长按钮
    self.m_ContectHost = CEGUI.toPushButton(winMgr:getWindow(tostring(1) .. "gonghuixiangqing/jiemian/lianxihuizhang"))

    self.closeBtn:subscribeEvent("Clicked", Gonghuixiangqing.OnClickedCloseBtn, self)
    self.m_BtnApplyJoinToFamily:subscribeEvent("Clicked", Gonghuixiangqing.OnClickedBtnApplyJoinToFamily, self)
    self.m_ContectHost:subscribeEvent("Clicked", Gonghuixiangqing.OnClickedContectHostBtn, self)
    self.m_ID = 0
    -- 公会ID
    self.m_FactionMansterID = 0
    -- 会长ID
end
-- 关闭按钮回调
function Gonghuixiangqing:OnClickedCloseBtn(args)
    self:DestroyDialog()
end
-- 点击申请公会
function Gonghuixiangqing:OnClickedBtnApplyJoinToFamily(args)
    local send = require "protodef.fire.pb.clan.capplyclan":new()
    send.clanid = self.m_ID
    LuaProtocolManager.getInstance():send(send)
    self:DestroyDialog()
end
-- 点击联系会长
function Gonghuixiangqing:OnClickedContectHostBtn(args)
    if gGetFriendsManager() then
        gGetFriendsManager():RequestSetChatRoleID(self.m_FactionMansterID)
    end
    self:DestroyDialog()
    RankingList.DestroyDialog()
end

-- 刷新数据
function Gonghuixiangqing:RefreshData(data)
    if not data then
        return
    end
    if not data.factionid then
        return
    end
    if not data.cengyongming then
        return
    end
    if not data.zongzhi then
        return
    end
    if not self.m_FactionMansterID then
        return
    end
    if not self.m_CengYongMingText then
        return
    end
    if not self.m_ZongZhiText then
        return
    end
    self.m_ID = data.factionid
    self.m_FactionMansterID = data.factionmasterid
    self.m_CengYongMingText:setText(data.cengyongming)
    self.m_ZongZhiText:setText(data.zongzhi)

    -- 当自己是这个公会会长时屏蔽按钮
    if gGetDataManager() and gGetDataManager():GetMainCharacterID() == self.m_FactionMansterID then
        self.m_ContectHost:setEnabled(false)
    else
        self.m_ContectHost:setEnabled(true)
    end
end
return Gonghuixiangqing

require "logic.dialog"
require "logic.family.familygaiming1dialog"
Familygaimingdialog = { }
setmetatable(Familygaimingdialog, Dialog)
Familygaimingdialog.__index = Familygaimingdialog

local _instance
function Familygaimingdialog.getInstance()
    if not _instance then
        _instance = Familygaimingdialog:new()
        _instance:OnCreate()

    end
    return _instance
end

function Familygaimingdialog.getInstanceAndShow()
    if not _instance then
        _instance = Familygaimingdialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familygaimingdialog.getInstanceNotCreate()
    return _instance
end

function Familygaimingdialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familygaimingdialog.ToggleOpenClose()
    if not _instance then
        _instance = Familygaimingdialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familygaimingdialog.GetLayoutFileName()
    return "familygaimingdialog.layout"
end

function Familygaimingdialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familygaimingdialog)
    return self
end

function Familygaimingdialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_ChuangShiRen = winMgr:getWindow("familygaimingdialog/text1")
    self.m_ChuangShiRenID = winMgr:getWindow("familygaimingdialog/text2")
    self.m_LastName = winMgr:getWindow("familygaimingdialog/text3")
    self.m_GaimingBtn = CEGUI.toPushButton(winMgr:getWindow("familygaimingdialog/gaiming"))
    self.m_GonghuiTitle = winMgr:getWindow("familygaimingdialog/name")

    self.m_GaimingBtn:subscribeEvent("Clicked", Familygaimingdialog.GaimingBtnClicked, self)
    self:RefreshInfor()
end
-- 设置原始名字
function Familygaimingdialog:RefreshInfor()
    local datamanager = require "logic.faction.factiondatamanager"
    self.m_GonghuiTitle:setText(datamanager.factionname)
    self.m_ChuangShiRen:setText(datamanager.factioncreator)
    self.m_LastName:setText(tostring(datamanager.oldfactionname))
    self.m_ChuangShiRenID:setText(tostring(datamanager.factioncreatorid))
end
-- 点击改名
function Familygaimingdialog:GaimingBtnClicked(args)
    local datamanager = require "logic.faction.factiondatamanager"
    local infor = datamanager.GetMyZhiWuInfor()
    -- 没有改名权限
    if infor.changefactionname == 0 and infor.id~=-1 then
        local tips = MHSD_UTILS.get_msgtipstring(150127)
        GetCTipsManager():AddMessageTip(tips)
        self.DestroyDialog()
        return
    end
    Familygaiming1dialog.getInstanceAndShow()
    self.DestroyDialog()
end


return Familygaimingdialog

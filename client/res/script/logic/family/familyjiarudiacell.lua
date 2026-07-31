-- 公会列表项

require "logic.dialog"

Familyjiarudiacell = { }
setmetatable(Familyjiarudiacell, Dialog)
Familyjiarudiacell.__index = Familyjiarudiacell

local _instance

function Familyjiarudiacell.getInstance()
    if not _instance then
        _instance = Familyjiarudiacell:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyjiarudiacell.getInstanceAndShow()
    if not _instance then
        _instance = Familyjiarudiacell:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyjiarudiacell.getInstanceNotCreate()
    return _instance
end

function Familyjiarudiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyjiarudiacell)
    return self
end

function Familyjiarudiacell.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Familyjiarudiacell.ToggleOpenClose()
    if not _instance then
        _instance = Familyjiarudiacell:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyjiarudiacell.GetLayoutFileName()
    return "familyjiarudiacell.layout"
end

function Familyjiarudiacell:OnCreate(pParentDlg, id)
    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()

    local prefixstr = tostring(id)

    -- 底板
    self.btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyjiarudiacell/diban"))
    self.btn:EnableClickAni(false)
    -- 编号
    self.m_Index = winMgr:getWindow(prefixstr .. "familyjiarudiacell/number")
    -- 公会名字
    self.m_Name = winMgr:getWindow(prefixstr .. "familyjiarudiacell/familyname")
    -- 公会等级
    self.m_Level = winMgr:getWindow(prefixstr .. "familyjiarudiacell/level")
    -- 人数
    self.m_PersonNumber = winMgr:getWindow(prefixstr .. "familyjiarudiacell/renshu")
    -- 会长名字
    self.m_MasterName = winMgr:getWindow(prefixstr .. "familyjiarudiacell/name")
    -- 对勾按钮
    self.m_SelectBtn = winMgr:getWindow(prefixstr .. "familyjiarudiacell/diban/gouxuan")
end

-- 创建新的公会列表项
function Familyjiarudiacell.CreateNewDlg(pParentDlg, id)
    LogInfo("enter familyjiarudiacell.CreateNewDlg")

    local newDlg = Familyjiarudiacell:new()
    newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

-- 设置信息
function Familyjiarudiacell:SetInfor(infor)
    if infor then
        -- 设置公会ID
        self.m_ID = infor.clanid
        self.m_IndexNumber = infor.index
        -- 设置编号
        self.m_Index:setText(tostring(infor.index))
        -- 设置公会名字
        self.m_Name:setText(infor.clanname)
        -- 设置公会等级
        self.m_Level:setText(tostring(infor.clanlevel))
        -- 设置人数
        local temp = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getRecorder(infor.hotellevel)
        if temp then
            local text = string.format("%d/%d", infor.membernum, temp.peoplemax)

            self.m_PersonNumber:setText(text)
        end

        -- 设置会长名字
        self.m_MasterName:setText(infor.clanmastername)
        self.m_SelectBtn:setVisible(false)
        self:RefreshApplyState()
    end
end

-- 刷新申请状态
function Familyjiarudiacell:RefreshApplyState()
    local datamanager = require "logic.faction.factiondatamanager"
    local temp = datamanager.getHasbeenApplyListEntry(self.m_ID)
    if temp == nil then
        self.m_SelectBtn:setVisible(false)
    elseif temp.applystate == 0 then
        self.m_SelectBtn:setVisible(false)
    else
        self.m_SelectBtn:setVisible(true)
    end
end

return Familyjiarudiacell

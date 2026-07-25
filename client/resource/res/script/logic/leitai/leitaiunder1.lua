require "logic.dialog"
debugrequire "logic.leitai.leitaidengji"

LeiTaiUnder1 = { }
setmetatable(LeiTaiUnder1, Dialog)
LeiTaiUnder1.__index = LeiTaiUnder1

local _instance
function LeiTaiUnder1.getInstance()
    if not _instance then
        _instance = LeiTaiUnder1:new()
        _instance:OnCreate()
    end
    return _instance
end

function LeiTaiUnder1.getInstanceAndShow(parent)
    if not _instance then
        _instance = LeiTaiUnder1:new()
        _instance:OnCreate(parent)
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function LeiTaiUnder1.getInstanceNotCreate()
    return _instance
end

function LeiTaiUnder1.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            if _instance.m_Entrys then
                _instance.m_Entrys:destroyCells()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function LeiTaiUnder1.ToggleOpenClose()
    if not _instance then
        _instance = LeiTaiUnder1:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function LeiTaiUnder1.GetLayoutFileName()
    return "leitaishaixuan_mtg.layout"
end

function LeiTaiUnder1:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, LeiTaiUnder1)
    return self
end

function LeiTaiUnder1:OnCreate(parent)
    Dialog.OnCreate(self, parent, 2)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_Under = winMgr:getWindow(tostring(2) .. "leitaishaixuan_mtg")
    self.m_Width = 195 * 2 + 30
    self.Height = 64 * 4
    self.m_Collecttion = { }
    self.m_Under:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.m_Width + 10), CEGUI.UDim(0, self.Height + 10)))
    self:Refresh()
end
-- 刷新职业筛选
function LeiTaiUnder1:Refresh()
    self.m_Collecttion = { }
    local cleitailevel = BeanConfigManager.getInstance():GetTableByName("npc.cleitailevel") 
    -- has vector
    local len = cleitailevel:getSize()
    -- 清空容器
    if self.m_Entrys then

    else
        self.m_Entrys = TableView.create(self.m_Under)
        self.m_Entrys:setViewSize(self.m_Width, self.Height - 30)
        self.m_Entrys:setDataSourceFunc(self, LeiTaiUnder1.tableViewGetCellAtIndex)
        self.m_Entrys:setPosition(15, 15)
    end
    self.m_Entrys:setColumCount(2)
    self.m_Entrys:setCellInterval(10, 5)
    self.m_Entrys:setCellCountAndSize(len, 195, 64)
    self.m_Entrys:reloadData()
end

function LeiTaiUnder1:tableViewGetCellAtIndex(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = LeiTaiDengji.CreateNewDlg(tableView.container, idx)
        cell.m_Btn:subscribeEvent("MouseButtonUp", LeiTaiUnder1.OnClickedButton, self)
    end
    -- has vector
    local infor = BeanConfigManager.getInstance():GetTableByName("npc.cleitailevel"):getRecorder(idx)
    cell:SetInfor(infor)
    cell.m_Btn:setID(infor.id)
    
    table.insert(self.m_Collecttion, cell.m_Btn)
    return cell
end

function LeiTaiUnder1:OnClickedButton(args)
    self:ResetButton()
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    local state = CEGUI.toWindowEventArgs(args).window:getID2()

    local datamanager = require "logic.leitai.leitaidatamanager"
    local send = require "protodef.fire.pb.battle.cplaypkfightview":new()
    send.modeltype = datamanager.ModularType
    if state == 0 then
        datamanager.m_LevelArea = id
        send.levelindex = id
    else
        datamanager.m_LevelArea = 0
        send.levelindex = 0
    end
    send.school = datamanager.m_FilterMode

    require "manager.luaprotocolmanager":send(send)

end
function LeiTaiUnder1:ResetButton()
    for k, v in pairs(self.m_Collecttion) do
        v:SetPushState(false)
    end
end
function LeiTaiUnder1:RefreshSelect()
   local datamanager = require "logic.leitai.leitaidatamanager"
    for k, v in pairs(self.m_Collecttion) do
        if v:getID() == datamanager.m_LevelArea then
           v:setID2(1)
           v:SetPushState(true)
        else
           v:setID2(0)
           v:SetPushState(false)
        end
    end
end
return LeiTaiUnder1

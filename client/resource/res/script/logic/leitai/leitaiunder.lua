require "logic.dialog"
debugrequire "logic.leitai.leitaishaixuan"

LeiTaiUnder = { }
setmetatable(LeiTaiUnder, Dialog)
LeiTaiUnder.__index = LeiTaiUnder

local _instance
function LeiTaiUnder.getInstance()
    if not _instance then
        _instance = LeiTaiUnder:new()
        _instance:OnCreate()
    end
    return _instance
end

function LeiTaiUnder.getInstanceAndShow(parent)
    if not _instance then
        _instance = LeiTaiUnder:new()
        _instance:OnCreate(parent)
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function LeiTaiUnder.getInstanceNotCreate()
    return _instance
end

function LeiTaiUnder.DestroyDialog()
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

function LeiTaiUnder.ToggleOpenClose()
    if not _instance then
        _instance = LeiTaiUnder:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function LeiTaiUnder.GetLayoutFileName()
    return "leitaishaixuan_mtg.layout"
end

function LeiTaiUnder:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, LeiTaiUnder)
    return self
end

function LeiTaiUnder:OnCreate(parent)
    Dialog.OnCreate(self, parent, 1)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_Under = winMgr:getWindow(tostring(1) .. "leitaishaixuan_mtg")
    self.m_Width = 85 * 3
    self.m_Height = 115 * 3
    self.m_Collecttion = { }
    self.m_Under:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.m_Width + 10), CEGUI.UDim(0, self.m_Height + 10)))
    self:Refresh()
end
-- 刷新职业筛选
function LeiTaiUnder:Refresh()
    self.m_Collecttion = { }
    local len = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getSize()
    -- 清空容器
    if self.m_Entrys then

    else
        self.m_Entrys = TableView.create(self.m_Under)
        self.m_Entrys:setViewSize(self.m_Width, self.m_Height)
        self.m_Entrys:setDataSourceFunc(self, LeiTaiUnder.tableViewGetCellAtIndex)
        self.m_Entrys:setPosition(5, 5)
    end
    self.m_Entrys:setColumCount(3)
    self.m_Entrys:setCellCountAndSize(len, 85, 115)
    self.m_Entrys:reloadData()
end

function LeiTaiUnder:tableViewGetCellAtIndex(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = LeiTaiShaiXuan.CreateNewDlg(tableView.container, idx)
        cell.m_Btn:subscribeEvent("Clicked", LeiTaiUnder.OnClickedButton, self)
    end
    local infor = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(idx + 10)
    cell:SetInfor(infor)
    cell.m_Btn:setID(infor.id)
    
    table.insert(self.m_Collecttion, cell.m_Btn)
    return cell
end
function LeiTaiUnder:ResetButton()
    for k, v in pairs(self.m_Collecttion) do
        local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(v:getID())
        if schoolConfig then
            v:setProperty("NormalImage", schoolConfig.normalbtnimage) --schoolConfig.pushbtnimage
            v:setProperty("PushedImage", schoolConfig.normalbtnimage)
        end
    end
end
function LeiTaiUnder:OnClickedButton(args)

    local id = CEGUI.toWindowEventArgs(args).window:getID()
    local state = CEGUI.toWindowEventArgs(args).window:getID2()
    local datamanager = require "logic.leitai.leitaidatamanager"
    local send = require "protodef.fire.pb.battle.cplaypkfightview":new()
    send.modeltype = datamanager.ModularType
    if state == 0 then
        datamanager.m_FilterMode = id
         send.school = id
    else
        datamanager.m_FilterMode = -1
        send.school = -1
    end
    send.levelindex = datamanager.m_LevelArea
    require "manager.luaprotocolmanager":send(send)
    self:ResetButton()
end
function LeiTaiUnder:RefreshSelect()
   local datamanager = require "logic.leitai.leitaidatamanager"
    for k, v in pairs(self.m_Collecttion) do
        local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(v:getID())
        if v:getID() == datamanager.m_FilterMode then
            v:setID2(1)
            if schoolConfig then
                v:setProperty("NormalImage", schoolConfig.pushbtnimage) --schoolConfig.pushbtnimage
                v:setProperty("PushedImage", schoolConfig.pushbtnimage)
            end
           --v:SetPushState(true)
        else
            v:setID2(0)
            v:setProperty("NormalImage", schoolConfig.normalbtnimage) --schoolConfig.pushbtnimage
            v:setProperty("PushedImage", schoolConfig.normalbtnimage)
        end
    end
end
return LeiTaiUnder

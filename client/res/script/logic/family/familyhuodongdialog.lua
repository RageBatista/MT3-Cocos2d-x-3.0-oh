require "logic.dialog"
debugrequire "logic.family.familyhuodongdiacell"
require "logic.family.familyfuben"

Familyhuodongdialog = { }
setmetatable(Familyhuodongdialog, Dialog)
Familyhuodongdialog.__index = Familyhuodongdialog

local _instance
function Familyhuodongdialog.getInstance()
    if not _instance then
        _instance = Familyhuodongdialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyhuodongdialog.getInstanceAndShow()
    if not _instance then
        _instance = Familyhuodongdialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyhuodongdialog.getInstanceNotCreate()
    return _instance
end
function Familyhuodongdialog.DestroyDialog(IsDestroyPage)
    -- 关闭本dialog
    if IsDestroyPage == nil then
        IsDestroyPage = true
    end
    if IsDestroyPage then
        if Familylabelframe.getInstanceNotCreate() then
            Familylabelframe.getInstanceNotCreate().DestroyDialog()
        end
    end
    if _instance then
        if not _instance.m_bCloseIsHide then
            -- 关闭tableview
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

function Familyhuodongdialog.ToggleOpenClose()
    if not _instance then
        _instance = Familyhuodongdialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyhuodongdialog.GetLayoutFileName()
    return "familyhuodongdialog.layout"
end

function Familyhuodongdialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyhuodongdialog)
    return self
end

function Familyhuodongdialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    SetPositionOfWindowWithLabel(self:GetWindow())

    self.m_HuoDongGroup = winMgr:getWindow("familyhuodongdialog/diban/list")
    self:RefreshHuoDongList()
end
-- 刷新活动列表
function Familyhuodongdialog:RefreshHuoDongList()
    if not self.m_HuoDongGroup then
        return
    end
    self.ids = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhuodong"):getAllID()
    local len = #self.ids
    if not self.m_Entrys then
        local s = self.m_HuoDongGroup:getPixelSize()
        self.m_Entrys = TableView.create(self.m_HuoDongGroup,TableView.HORIZONTAL)
        self.m_Entrys:setViewSize(s.width - 20, s.height)
        self.m_Entrys:setPosition(10, 5)
        self.m_Entrys:setDataSourceFunc(self, Familyhuodongdialog.tableViewGetCellAtIndex)
    end

    self.m_Entrys:setCellCountAndSize(len)
    self.m_Entrys:reloadData()
end
function Familyhuodongdialog:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end
    idx = idx + 1
    if not cell then
        cell = Familyhuodongdiacell.CreateNewDlg(tableView.container)
        cell.m_Btn:subscribeEvent("Clicked", Familyhuodongdialog.HandleClickedBtn, self)
		cell.m_Btn1:subscribeEvent("Clicked", Familyhuodongdialog.HandleClickedBtn, self)
		cell.m_Btn2:subscribeEvent("Clicked", Familyhuodongdialog.HandleClickedBtn, self)
        cell.m_mange:subscribeEvent("Clicked", Familyhuodongdialog.HandleMangeClickedBtn, self)
    end
    if cell and self.ids then
        local infor = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhuodong"):getRecorder(self.ids[idx])
        if infor then
            cell:SetInfor(infor)
        end
    end
    return cell
end
function Familyhuodongdialog:HandleClickedBtn(args)
    if GetBattleManager():IsInBattle() then
        GetCTipsManager():AddMessageTipById(145104)
        return
    end
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    if id == 1 then-- 公会任务
        TaskHelper.gotoNpc(161301)
    elseif id == 2 then-- 公会副本
        TaskHelper.gotoNpc(161303)
	elseif id == 3 then---帮派强盗----废弃不用
        TaskHelper.gotoNpc(161303)
	elseif id == 4 then---帮派强盗----帮派活动
        TaskHelper.gotoNpc(161303)
	elseif id == 5 then---帮派强盗----帮派活动
        TaskHelper.gotoNpc(161303)
		
    end
    self:DestroyDialog()
end

function Familyhuodongdialog:HandleMangeClickedBtn(args)
    familyfuben.getInstanceAndShow()
end

return Familyhuodongdialog

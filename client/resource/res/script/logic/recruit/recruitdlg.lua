require "logic.dialog"

RecruitDlg = {}
setmetatable(RecruitDlg, Dialog)
RecruitDlg.__index = RecruitDlg

local _instance
function RecruitDlg.getInstance()
	if not _instance then
		_instance = RecruitDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function RecruitDlg.getInstanceAndShow()
	if not _instance then
		_instance = RecruitDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RecruitDlg.getInstanceNotCreate()
	return _instance
end

function RecruitDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            if _instance.m_dlg then
                _instance.m_dlg:OnClose(false, false)
                _instance.m_dlg = nil
            end

			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RecruitDlg.ToggleOpenClose()
	if not _instance then
		_instance = RecruitDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RecruitDlg.GetLayoutFileName()
	return "recruitdialog.layout"
end

function RecruitDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RecruitDlg)
	return self
end

function RecruitDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    SetPositionOfWindowWithLabel(self:GetWindow())
    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", FriendMailLabel.DestroyDialog, nil)
    self.m_cellbg = winMgr:getWindow("recruitdialog/liebiao/diban/list")
    self.m_MainBg = winMgr:getWindow("recruitdialog/chatframe/xinxi")
    self.m_smallcells = {}
    self.m_index = 1
    self.m_y = 0
    self.m_dlg = nil
    self:InitCell()
end

function RecruitDlg:InitCell()
    for i = 1, 3 do
	    local curCell = require "logic.recruit.recruitcell".CreateNewDlg(self.m_cellbg, i)
	    local x = CEGUI.UDim(0, 5)
	    local y = CEGUI.UDim(0, 5 + (i - 1) * curCell.m_height)
	    local pos = CEGUI.UVector2(x,y)
        self.m_y = (i) * curCell.m_height
	    curCell:GetWindow():setPosition(pos)
        if i == 1 then
            curCell.m_cell:setSelected(true)
        end
    end

end
function RecruitDlg:Update()
    if self.m_index == 1 then
        self.m_dlg:Update()
    end
end
function RecruitDlg:Show(index)
    if self.m_dlg then
        self.m_dlg:OnClose(false, false)
        self.m_dlg = nil
    end
    self.m_index = index
    if index == 1 then
        if IsPointCardServer() then
            self.m_dlg = require "logic.recruit.recruitcell1diankadlg".CreateNewDlg(self.m_MainBg)
        else
            self.m_dlg = require "logic.recruit.recruitcell1dlg".CreateNewDlg(self.m_MainBg)
        end
        
	    local x = CEGUI.UDim(0, 10)
	    local y = CEGUI.UDim(0, 10)
	    local pos = CEGUI.UVector2(x,y)
	    self.m_dlg:GetWindow():setPosition(pos)
        for _,v in pairs(self.m_smallcells) do
            v:OnClose(false, false)
        end
        self.m_smallcells = {}
    elseif index == 2 then
        self.m_dlg = require "logic.recruit.recruitjiangli".CreateNewDlg(self.m_MainBg)
	    local x = CEGUI.UDim(0, 1)
	    local y = CEGUI.UDim(0, 1)
	    local pos = CEGUI.UVector2(x,y)
	    self.m_dlg:GetWindow():setPosition(pos)
        for _,v in pairs(self.m_smallcells) do
            v:OnClose(false, false)
        end
        self.m_smallcells = {}
    elseif index == 3 then
        self.m_dlg = require "logic.recruit.recruitmine".CreateNewDlg(self.m_MainBg)
	    local x = CEGUI.UDim(0, 1)
	    local y = CEGUI.UDim(0, 1)
	    local pos = CEGUI.UVector2(x,y)
        self.m_dlg:GetWindow():setPosition(pos)
        for _,v in pairs(self.m_smallcells) do
            v:OnClose(false, false)
        end
        self.m_smallcells = {}
        self.m_dlg:getRecruitList()
    end
end
function RecruitDlg:createCell()
    local hasData = false
    local list = std.vector_int_()
    list = GetServerInfo():getRecruitList()
    local vSize = list:size()

    for i = 0, vSize - 1 do
        hasData = true
	    local curCell = require "logic.recruit.recruitsmallcell".CreateNewDlg(self.m_cellbg, i)
	    local x = CEGUI.UDim(0, 22)
	    local y = CEGUI.UDim(0, 5 + (i) * curCell.m_height + self.m_y)
	    local pos = CEGUI.UVector2(x,y)
	    curCell:GetWindow():setPosition(pos)
        curCell:setData(list[i])
        if i == 0 then
            curCell.m_cell:setSelected(true)
        end
        table.insert(self.m_smallcells,curCell)
    end
    if hasData then
        self.m_dlg:getRecruitSuccess()
    else
        self.m_dlg:getRecruitSuccessVoid()
    end
end
function RecruitDlg:getRecruitListSuccess()
    if _instance then
        if _instance.m_index == 3 then
            _instance.m_dlg:getRecruitSuccess()
            _instance:createCell()
        end
    end
end
function RecruitDlg:getRecruitListFail()
    if _instance then
        if _instance.m_index == 3 then
            _instance.m_dlg:getRecruitFail()
        end
    end
end
function RecruitDlg:getRecruitSuccess()
    if _instance then
        if _instance.m_index == 2 then
            _instance.m_dlg:getRecruitSuccess()
        end
        
    end
end
function RecruitDlg:getRecruitFail()
    if _instance then
        if _instance.m_index == 2 then
            _instance.m_dlg:getRecruitFail()
        end
    end
end
function RecruitDlg:getRecruitOneSuccess()
    if _instance then
        if _instance.m_index == 3 then
            _instance.m_dlg:getOneRoleSuccess()
        end
        
    end
end
function RecruitDlg:getOneRoleFail()
    if _instance then
        if _instance.m_index == 3 then
            _instance.m_dlg:getRecruitFail()
        end
    end
end
function RecruitDlg:refreshDataForMine()
    if _instance then
        if _instance.m_index == 3 then
            _instance.m_dlg:getData()
        end
    end
end
function RecruitDlg:refreshDataForJiangli()
    if _instance then
        if _instance.m_index == 2 then
            _instance.m_dlg:getData()
        end
    end
end
return RecruitDlg
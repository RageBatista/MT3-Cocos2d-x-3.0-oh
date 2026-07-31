require "logic.dialog"
require "logic.team.huobanzhuzhanschoolcell"

huobanzhuzhanSchoolBg = {}
setmetatable(huobanzhuzhanSchoolBg, Dialog)
huobanzhuzhanSchoolBg.__index = huobanzhuzhanSchoolBg

local _instance
function huobanzhuzhanSchoolBg.getInstance(parent)
	if not _instance then
		_instance = huobanzhuzhanSchoolBg:new()
		_instance:OnCreate(parent)
	end
	return _instance
end

function huobanzhuzhanSchoolBg.getInstanceAndShow(parent)
	if not _instance then
		_instance = huobanzhuzhanSchoolBg:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function huobanzhuzhanSchoolBg.getInstanceNotCreate()
	return _instance
end

function huobanzhuzhanSchoolBg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			for index in pairs( _instance.m_cells ) do
				local cell = _instance.m_cells[index]
				if cell then
					cell:OnClose(false, false)
					cell = nil
				end
			end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function huobanzhuzhanSchoolBg.ToggleOpenClose()
	if not _instance then
		_instance = huobanzhuzhanSchoolBg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function huobanzhuzhanSchoolBg.GetLayoutFileName()
	return "leitaishaixuan_mtg.layout"
end

function huobanzhuzhanSchoolBg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, huobanzhuzhanSchoolBg)
	return self
end

function huobanzhuzhanSchoolBg:OnCreate(parent)
    local strHuoban = "huoban"
	Dialog.OnCreate(self, parent, strHuoban)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_framewindow = winMgr:getWindow(strHuoban.."leitaishaixuan_mtg")
    self.m_framewindow:setAlwaysOnTop(true)
    self.m_cells ={}
    self:initCell()
end

function huobanzhuzhanSchoolBg:initCell()
    --行索引
    local indexx = 0
    --列索引
    local indexy = 0
    --cell大小
    local cellwidth = 0
    local cellheight = 0
    --cell间距
    local widthDis = 10
    local heightDis = 10
    
    --职业头像一行几个
    local constWidth = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(246).value)

    local schoolid = 0

    local dlg = require "logic.team.huobanzhuzhandialog".getInstanceNotCreate()
    if dlg then
        schoolid = dlg.mState_filter
    end
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getAllID()
    for k,v in pairs(tableAllId) do
        local cell = huobanzhuzhanSchoolCell.CreateNewDlg(self:GetWindow())
        cell:init(v)
        cellwidth = cell:GetWindow():getWidth().offset + widthDis
        cellheight = cell:GetWindow():getHeight().offset + heightDis
        cell:GetWindow():setXPosition(CEGUI.UDim(0, widthDis + indexx * cellwidth ))
	    cell:GetWindow():setYPosition(CEGUI.UDim(0, heightDis + indexy * cellheight ))
        if v == schoolid then
            cell.m_Btn:SetPushState(true)
            cell.m_BtnStatus = true
        end
        table.insert(self.m_cells, cell)
        indexx = indexx + 1
        if indexx >=constWidth then
            indexx = 0
            indexy = indexy + 1
        end
    end
    self.m_pMainFrame:setSize(CEGUI.UVector2(CEGUI.UDim(0, constWidth * cellwidth + widthDis), CEGUI.UDim(0, indexy * cellheight + heightDis)))
end

return huobanzhuzhanSchoolBg

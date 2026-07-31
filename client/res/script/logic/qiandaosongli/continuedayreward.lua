require "logic.qiandaosongli.loginrewardmanager"

ContinueDayReward = {}
ContinueDayReward.__index = ContinueDayReward

local _instance

function ContinueDayReward.create()
    if not _instance then
		_instance = ContinueDayReward:new()
		_instance:OnCreate()
	end
	return _instance
end

function ContinueDayReward.getInstance()
    local Jianglinew = require("logic.qiandaosongli.jianglinewdlg")
    local jlDlg = Jianglinew.getInstanceAndShow()
     if not jlDlg then
        return nil
    end 
    local dlg = jlDlg:showSysId(Jianglinew.systemId.sevenSign)
	return dlg
end

function ContinueDayReward.getInstanceAndShow()
	return ContinueDayReward.getInstance()
end

function ContinueDayReward.getInstanceNotCreate()
	return _instance
end

function ContinueDayReward:remove()
    self:clearData()
    _instance = nil
end

function ContinueDayReward:clearData()
    
    if not self.m_listCell then
        return
    end

    for i,v in pairs(self.m_listCell) do
		v:OnClose()
	end

end

function ContinueDayReward.DestroyDialog()
     require("logic.qiandaosongli.jianglinewdlg").DestroyDialog()
end

function ContinueDayReward:new()
	local self = {}
	setmetatable(self, ContinueDayReward)
	return self
end

function ContinueDayReward:OnCreate(parent)
    self.parent = parent
	local winMgr = CEGUI.WindowManager:getSingleton()
	local layoutName = "qiriqiandao.layout"
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)
	self.m_bg = CEGUI.toFrameWindow(winMgr:getWindow("qiriqiandao"))
	self.m_scrollCellScro = CEGUI.toScrollablePane(winMgr:getWindow("qiriqiandao/di1/liebiao"))
	self.m_continueDays = LoginRewardManager.getInstance():GetLoginDays()
	self.m_gotList = {}
	self.m_gotList = LoginRewardManager.getInstance():GetMapAwards()
	self.elapse = 0
	self.m_nIntroAID = 11187
	self.m_listCell = {}
	self:InitCell()

end

function ContinueDayReward:update(delta)
	self.elapse = self.elapse+delta
	if self.elapse > 3000 then
		self.m_nIntroAID = self.m_nIntroAID + 1
		if self.m_nIntroAID > 11189 then
			self.m_nIntroAID = 11187
		end
		self.elapse = 0
	end
end

function ContinueDayReward:InitCell()
	for i = 1 , 7 do
        local cellclass =  require "logic.qiandaosongli.continuedaycell"
		local cell = cellclass.CreateNewDlg(self.m_scrollCellScro)
		local x = CEGUI.UDim(0, 5)
		local y = CEGUI.UDim(0, cell:GetWindow():getPixelSize().height*(i-1) + (i - 1)*4)
		local pos = CEGUI.UVector2(x,y)
		cell:GetWindow():setPosition(pos)
		cell:SetID(i)
		if self.m_gotList[i] then
			cell:SetFlag( self.m_gotList[i] )
		end
		
		cell:RefreshShow()
		table.insert(self.m_listCell, cell )
	end	
	
end

function ContinueDayReward:UpdateCellData()
	self.m_gotList = LoginRewardManager.getInstance():GetMapAwards()
    self.m_continueDays = LoginRewardManager.getInstance():GetLoginDays()
	for i , v in pairs( self.m_listCell ) do
		
		if self.m_gotList[i] then
			v:SetFlag( self.m_gotList[i] )
		end
		v:RefreshShow()
	end
end

return ContinueDayReward

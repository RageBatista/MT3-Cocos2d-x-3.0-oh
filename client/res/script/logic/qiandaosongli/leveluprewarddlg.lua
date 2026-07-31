LevelUpRewardDlg = {}
LevelUpRewardDlg.__index = LevelUpRewardDlg

local _instance


function LevelUpRewardDlg.create()
    if not _instance then
		_instance = LevelUpRewardDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function LevelUpRewardDlg.getInstance()
    local Jianglinew = require("logic.qiandaosongli.jianglinewdlg")
    local jlDlg = Jianglinew.getInstanceAndShow()
    if not jlDlg then
        return nil
    end 
    local dlg = jlDlg:showSysId(Jianglinew.systemId.levelupReward)
	return dlg
end

function LevelUpRewardDlg.getInstanceAndShow()
	return LevelUpRewardDlg.getInstance()
end

function LevelUpRewardDlg.getInstanceNotCreate()
	return _instance
end

function LevelUpRewardDlg:DestroyListCell()
	for index in pairs( _instance.m_listCell ) do
		local cell = _instance.m_listCell[index]
		if cell then
			cell:OnClose()
		end
	end
end


function LevelUpRewardDlg:remove()
    self:clearData()
    _instance = nil
end

function LevelUpRewardDlg:clearData()
    if not self.m_listCell then
        return
    end

     for index in pairs( self.m_listCell ) do
	        local cell = self.m_listCell[index]
	        if cell then
		        cell:OnClose()
	        end
    end
end

function LevelUpRewardDlg.DestroyDialog()
    require("logic.qiandaosongli.jianglinewdlg").DestroyDialog()   
end

function LevelUpRewardDlg:new()
	local self = {}
	setmetatable(self, LevelUpRewardDlg)
	return self
end

function LevelUpRewardDlg:SetRewardID( rewardID )
	self.m_nRewardID = rewardID
	self:InitCell()
	self:RefreshCellState()
end

function LevelUpRewardDlg:RefreshRewardID()
	self:InitCell()
	self:RefreshCellState()
end

function LevelUpRewardDlg:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()

	local layoutName = "shengjidalibao.layout"
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)

	self.m_bg = CEGUI.toFrameWindow(winMgr:getWindow("shengjidalibao"))
	self.m_scrollpanePaneA = CEGUI.toScrollablePane(winMgr:getWindow("shengjidalibao/liebiao"))
    self.m_scrollpanePaneA:EnableVertScrollBar(true)
	
	self.m_nRewardID = LoginRewardManager.getInstance().levelupItemID
	
	self.m_listCell = {}
	self.m_arrBelongIndexID = {}
	self:InitCell()
	self:RefreshCellState()
end


function LevelUpRewardDlg:RefreshCellState()
	local data = gGetDataManager():GetMainCharacterData()
	local level = data:GetValue(fire.pb.attr.AttrType.LEVEL)

	for i , v in pairs( self.m_listCell ) do
		local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_nRewardID)
		if i == 1 and itembean and level >= itembean.needLevel then
			flag = true
		else
			flag = false
		end
		v:SetFlag(flag)	
	end

end

function LevelUpRewardDlg:InitCell()
    self.m_listCell = {}
    self.m_arrBelongIndexID = {}
    self.m_scrollpanePaneA:cleanupNonAutoChildren()
    local data = gGetDataManager():GetMainCharacterData()
    local level = data:GetValue(fire.pb.attr.AttrType.LEVEL)

    local indexIDs = BeanConfigManager.getInstance():GetTableByName("item.cpresentconfig"):getAllID()

    local playerSchoolID = gGetDataManager():GetMainCharacterCreateShape()

    --Íæ¼ÒÖ°Òµ
    local playerCareer = gGetDataManager():GetMainCharacterSchoolID()
    
    self.m_arrBelongIndexID = {}
    self:CheckAndInsertIndex(playerSchoolID, self.m_nRewardID ,indexIDs, self.m_arrBelongIndexID, playerCareer)
    
    self.m_listCell = {}
    local posY = 0  
    
    local posX = 0
    local spaceY = 5
    local beginidx = math.floor(level/10) + 1
    local prefixNum = 20
    for i , v in pairs(self.m_arrBelongIndexID) do	
        local cellclass =  require "logic.qiandaosongli.leveluprewardcell"
        local cpresentCfg = BeanConfigManager.getInstance():GetTableByName("item.cpresentconfig"):getRecorder(self.m_arrBelongIndexID[i])
        
        local cell = cellclass.CreateNewDlg(self.m_scrollpanePaneA, self.m_arrBelongIndexID[i], self.m_arrBelongIndexID[i], prefixNum)
        prefixNum = prefixNum+1

        local nsize = cpresentCfg.itemids:size()

        local x = CEGUI.UDim(0, 0)  
        local y = CEGUI.UDim(0, posY)  

        local pos = CEGUI.UVector2(x, y)

        posY = posY + cell:GetWindow():getPixelSize().height + spaceY 

        cell:GetWindow():setPosition(pos)

        table.insert(  self.m_listCell, cell )
    end
end

function LevelUpRewardDlg:CheckAndInsertIndex(  paschoolID, paitemID ,pavecIdx, arrbelongIndexID ,playerCareer )
    local num = require "utils.tableutil".tablelength(pavecIdx)
	local bFinde = false
	for mapID = 1, num do
		local id = pavecIdx[mapID]

		local cpresentCfg = BeanConfigManager.getInstance():GetTableByName("item.cpresentconfig"):getRecorder(pavecIdx[mapID])
		local nitemID = cpresentCfg.itemid
		local nSchoolID = cpresentCfg.dutyallow
        local nCareerID = cpresentCfg.careerallow

		if nitemID == paitemID and  paschoolID  == nSchoolID and playerCareer == nCareerID then
			table.insert( arrbelongIndexID, pavecIdx[mapID])
			bFinde = true
			local lastitemID =  cpresentCfg.itemids[cpresentCfg.itemids:size() - 1]
			if self:CheckAndInsertIndex(  paschoolID, lastitemID ,pavecIdx, arrbelongIndexID,nCareerID) then
				break
			end
            break
		end
		
	end
	return bFinde
end

return LevelUpRewardDlg

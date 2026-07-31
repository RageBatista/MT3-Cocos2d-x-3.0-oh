require "logic.dialog"

BattleTips = {}
setmetatable(BattleTips, Dialog)
BattleTips.__index = BattleTips

local _instance
function BattleTips.getInstance()
	if not _instance then
		_instance = BattleTips:new()
		_instance:OnCreate()
	end
	return _instance
end

function BattleTips.getInstanceAndShow()
	if not _instance then
		_instance = BattleTips:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function BattleTips.getInstanceNotCreate()
	return _instance
end

function BattleTips.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			for _,v in pairs(_instance.m_CellList) do
				v:OnClose(false, false)
			end
			_instance:Clear()
			
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function BattleTips.ToggleOpenClose()
	if not _instance then
		_instance = BattleTips:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function BattleTips.GetLayoutFileName()
	return "battletips.layout"
end

function BattleTips:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, BattleTips)
	return self
end

function BattleTips:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pName = winMgr:getWindow("battletips/text")
	self.m_pName2 = winMgr:getWindow("battletips/text1")
	self.m_pIcon = winMgr:getWindow("battletips/tubiao")
	self.m_pName:setText("")
	self.m_pName2:setText("")
	self.m_pName:setVisible(false)
	self.m_pName2:setVisible(false)
	self.m_pList = CEGUI.toScrollablePane(winMgr:getWindow("battletips/list"))
	self.m_pHP = winMgr:getWindow("battletips/hp")
	self.m_pMP = winMgr:getWindow("battletips/mp")
	self.m_pSP = winMgr:getWindow("battletips/sp")
	self.m_pEP = winMgr:getWindow("battletips/sp1")
	self.orderBtn = CEGUI.toPushButton(winMgr:getWindow("battletips/btn"))
    self.orderBtn:subscribeEvent("Clicked", BattleTips.HandleOrderClicked,self)
	
	self.m_HPY = self.m_pHP:getYPosition():asAbsolute(0)
	self.m_SPY = self.m_pSP:getYPosition():asAbsolute(0)
	self.m_EPY = self.m_pEP:getYPosition():asAbsolute(0)
	self.m_ListY = self.m_pList:getYPosition():asAbsolute(0)
	
	self.m_CellList = {}
	self.m_CellCount = 0
	
	self.m_CellTemplate = require "logic.battle.battletipscell"
	local Cell0 = self.m_CellTemplate.CreateNewDlg(nil)
	self.m_CellH = Cell0:GetWindow():getHeight():asAbsolute(0)
	Cell0:OnClose()
	--self.m_pList:cleanupNonAutoChildren()
    self.m_battlerID = 0
end
function BattleTips:SetBattleID(BattleID, PlayerOrPetOrNPC)
	self:Clear()
    self.m_battlerID = BattleID
	if BattleID == 0 then
		return true
	end
	self:ShowName(BattleID)
	self.m_pHP:setVisible(false)
	self.m_pMP:setVisible(false)
	self.m_pSP:setVisible(false)
	self.m_pEP:setVisible(false)
	local ListY = self:ShowHPMPSP(BattleID, PlayerOrPetOrNPC)
	self.m_pList:setYPosition(CEGUI.UDim(0, ListY))
	self:GetWindow():setHeight(CEGUI.UDim(0, 1000))
	local BuffListHeight = self:ShowBuff(BattleID)
	local BGH = ListY
	BGH = BGH + BuffListHeight + 40
	if BuffListHeight == 0 then
		if PlayerOrPetOrNPC == 2 then
			BGH = BGH + 30
		end
	end
	self:GetWindow():setHeight(CEGUI.UDim(0, BGH))

	local SWH = CEGUI.System:getSingleton():getGUISheet():getPixelSize()
	local SW = SWH.width
	local SH = SWH.height
	
	local BGW = self:GetWindow():getWidth():asAbsolute(0)
	
	local WX = (SW - BGW) / 2
	local WY = (SH - BGH) / 2
	
	self:GetWindow():setXPosition(CEGUI.UDim(0, WX))
	self:GetWindow():setYPosition(CEGUI.UDim(0, WY))
	
    local isWatcher = false
    if GetBattleManager() and GetBattleManager():IsOnBattleWatch() then
        isWatcher = true
    end
    if GetTeamManager():IsOnTeam()==true and GetTeamManager():IsMyselfOrder() and GetTeamManager():GetMemberNum() > 1 and isWatcher == false and GetBattleManager() and GetBattleManager():isOnBattleReplay()==false then
	    self.orderBtn:setVisible(true)
    else
        self.orderBtn:setVisible(false)
    end
end
function BattleTips:ShowName(BattleID)
	local Battler = GetBattleManager():FindBattlerByID(BattleID)
    local school = Battler:GetBattlerData().school
    local schoolrecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school)

	self.m_pName:setText(Battler:GetName())
	self.m_pName2:setText(Battler:GetName())
    if schoolrecord then
        self.m_pIcon:setProperty("Image", schoolrecord.schooliconpath)
        self.m_pIcon:setVisible(true)
	    self.m_pName:setVisible(false)
	    self.m_pName2:setVisible(true)
    else
	    self.m_pName:setVisible(true)
	    self.m_pName2:setVisible(false)
        self.m_pIcon:setVisible(false)
    end
end
function BattleTips:ShowHPMPSP(BattleID, PlayerOrPetOrNPC)
	local Battler = GetBattleManager():FindBattlerByID(BattleID)
	local hp = 0
	local mp = 0
	local sp = 0
	local hpmax = 0
	local mpmax = 0
	local spmax = 0
	self.m_pHP:setVisible(true)
	self.m_pMP:setVisible(true)
	if PlayerOrPetOrNPC == 0 then
		local data = gGetDataManager():GetMainCharacterData()
		hp = data:GetValue(80)
		mp = data:GetValue(100)
		sp = data:GetValue(120)
		hpmax = data:GetValue(70)
		mpmax = data:GetValue(90)
		spmax = data:GetValue(110)
		self.m_pSP:setVisible(true)		
		self.m_pSP:setText(MHSD_UTILS.get_resstring(11192) .. ":" .. sp .. "/" .. spmax)
		self.m_pHP:setText(MHSD_UTILS.get_resstring(11190) .. ":" .. hp .. "/" .. hpmax)
		self.m_pMP:setText(MHSD_UTILS.get_resstring(11191) .. ":" .. mp .. "/" .. mpmax)
						
		if Battler:GetBattlerData().school == 24 then
			if Battler:IsFriendSide() == true or GetBattleManager():IsInPVPBattle() == false then
				local text = MHSD_UTILS.get_resstring(1134)
				text = string.gsub(text, "%$parameter1%$", tostring(Battler:GetEPValue()))
				self.m_pEP:setText(text)
				self.m_pEP:setVisible(true)
				return self.m_ListY
			end
		end
		return self.m_EPY
	elseif PlayerOrPetOrNPC == 1 then
		local data = MainPetDataManager.getInstance():GetBattlePet()
		hp = data:getAttribute(80)
		mp = data:getAttribute(100)
		hpmax = data:getAttribute(60)
		mpmax = data:getAttribute(90)
		self.m_pHP:setText(MHSD_UTILS.get_resstring(11190) .. ":" .. hp .. "/" .. hpmax)
		self.m_pMP:setText(MHSD_UTILS.get_resstring(11191) .. ":" .. mp .. "/" .. mpmax)
		return self.m_SPY
	elseif PlayerOrPetOrNPC == 2 then
		self.m_pHP:setVisible(false)
		self.m_pMP:setVisible(false)
		return self.m_HPY
	end
end
function BattleTips:ShowBuff(BattleID)
	local Battler = GetBattleManager():FindBattlerByID(BattleID)
	local BuffCount = Battler:GetBattleBuffCount()
	local BuffCountNew = 0
	local BuffInfoList = {}
	for i = 1, BuffCount do
		local BuffInfo = sBattleBuff()
		Battler:GetBattleBuffInfoByIndex(i - 1, BuffInfo)		
		local BuffLastRound = BuffInfo.leftround
		local buffconfig = GameTable.buff.GetCBuffConfigTableInstance():getRecorder(BuffInfo.buffid)
		local BuffInBattle = buffconfig.inbattle
		if BuffLastRound > 0 and BuffInBattle > 0 then
			BuffCountNew = BuffCountNew + 1
			local BuffInfoNew = {}
			BuffInfoNew.ID = BuffInfo.buffid
			BuffInfoNew.LastRound = BuffLastRound
			BuffInfoList[BuffCountNew] = BuffInfoNew
		end
	end
	
	--BuffCountNew = BuffCountNew + 1
	--local BuffInfo = {}
	--BuffInfo.ID = 508001
	--BuffInfo.LastRound = 1
	--BuffInfoList[BuffCountNew] = BuffInfo
	
	local ListH = 0.0
	if BuffCountNew <= 3 then
		ListH = self.m_CellH * BuffCountNew
	elseif BuffCountNew > 3 then
		ListH = self.m_CellH * 3.5
	end	
	self.m_pList:setHeight(CEGUI.UDim(0, ListH))
	for i = 1, BuffCountNew do		
		self:AddBuffCell(BuffInfoList[i].ID, BuffInfoList[i].LastRound, i)
	end
	return ListH
end
function BattleTips:AddBuffCell(BuffID, BuffLastRound, Index)
	local Cell = require "logic.battle.battletipscell"
	local curCell = Cell.CreateNewDlg(self.m_pList)
	self.m_CellList[Index] = curCell
	self.m_CellCount = Index
	--local x = CEGUI.UDim(0, 0)
	--local h = curCell:getHeight():asAbsolute(0)
	--local y = CEGUI.UDim(0, h * (Index - 1))
	--local pos = CEGUI.UVector2(x,y)
	--curCell.pWnd:setPosition(pos)
	--curCell.pWnd:setVisible(true)
	curCell:SetBuffID(BuffID, BuffLastRound)
	local pos = CEGUI.UDim(0, self.m_CellH * (Index - 1))
	curCell:GetWindow():setYPosition(pos)
end
function BattleTips:Clear()
	for _,v in pairs(self.m_CellList) do
		v:OnClose(false, false)
	end
	self.m_pList:cleanupNonAutoChildren()
	self.m_CellList = {}
	self.m_CellCount = 0
end
function BattleTips:HandleOrderClicked(args)
	local Battler = GetBattleManager():FindBattlerByID(self.m_battlerID)
    if Battler then
        local dlg = OrderSetDlg.getInstanceAndShow()
        dlg:setBattleID(self.m_battlerID)
        if Battler:IsFriendSide() then
            dlg:setShowSide(1)
        else
            dlg:setShowSide(2)
        end            
        BattleTips.CSetVisible(false)
    end
end
function BattleTips.CSetBattleID(BattleID, PlayerOrPetOrNPC)
	if BattleID == 0 then
		BattleTips.CSetVisible(false)
	else
		BattleTips.CSetVisible(true)
	end
	BattleTips.getInstance():SetBattleID(BattleID, PlayerOrPetOrNPC)
end

function BattleTips.CSetVisible(Visible)
	BattleTips.getInstance():SetVisible(Visible)
end

return BattleTips

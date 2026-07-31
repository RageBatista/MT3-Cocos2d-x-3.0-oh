require "logic.dialog"
require "logic.mapchose.mapchosecell"
require "logic.mapchose.autofightskillcell"
require "logic.mapchose.hookmanger"
require "logic.guajicfg"
require "logic.mapchose.mapchosecellbg"
MapChoseDlg = {}
setmetatable(MapChoseDlg, Dialog)
MapChoseDlg.__index = MapChoseDlg

local _instance
function MapChoseDlg.getInstance()
	if not _instance then
		_instance = MapChoseDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function MapChoseDlg.getInstanceAndShow()
	if not _instance then
		_instance = MapChoseDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function MapChoseDlg.getInstanceNotCreate()
	return _instance
end

function MapChoseDlg.DestroyDialog()	
	if TipsGuajiImg.getInstanceNotCreate() then
		TipsGuajiImg.DestroyDialog()
	end
	
	if AutoFightSkillCell.getInstanceNotCreate() then
		AutoFightSkillCell.DestroyDialog()
	end
	
	if _instance then
		if not _instance.m_bCloseIsHide then
            for index in pairs( _instance.m_mapCell ) do
		        local cell = _instance.m_mapCell[index]
		        if cell then
			        cell:OnClose()
		        end
	        end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end


function MapChoseDlg.ToggleOpenClose()
	if not _instance then
		_instance = MapChoseDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function MapChoseDlg.GetLayoutFileName()
	return "mapchosedialog_mtg.layout"
end

function MapChoseDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MapChoseDlg)
	self:init()
	return self
end

function MapChoseDlg:init()
	self.m_bForAutoBattle = false
end

function MapChoseDlg:SetBottomBtnVisible(bVisible)	
	
	self.m_bBottomVisible = bVisible
	
	self.m_btnYuandi:setVisible(bVisible)
    self.m_btnIntro:setVisible(bVisible)

	if bVisible then
		self:RefreshBtn()
	end
end

function MapChoseDlg:initSonMapID(mapID)
	self.m_mapIDList = {}
	local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapID)
	local vecSubMaps =  MapChoseDlg.GetSubMapIDByString(mapRecord.sonmapid);
	
	local size = #vecSubMaps
	for index  = 1, size do
		local nMapID = tonumber( vecSubMaps[index] )
		table.insert(self.m_mapIDList, nMapID)
	end
	
	--clear cell	
	for index in pairs( self.m_mapCell ) do
		local cell  =  self.m_mapCell[index]
		if cell then
			cell:OnClose()
		end
	end
	self.m_mapCell = {} --清空
	
	self:InitMapCell()
	
	self:RefreshSkillBox()
	self:RefreshBtn()
	self:RefreshCellColor()
	
		
end

function MapChoseDlg.SetMapID( mapID )
	local dlg = MapChoseDlg.getInstanceNotCreate()
	if mapID ~= nil then
		--这里需要将地图加载成从属地图
		if tonumber(mapID) > 0 then					
			dlg:initSonMapID(mapID)			
		end
		dlg:SetBottomBtnVisible(false)
		local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapID)
			
		dlg.m_imgBg:setText( mapconfig.sonmapname ) --地图名称
	else
		dlg:SetBottomBtnVisible(true)
		dlg.m_imgBg:setText( MHSD_UTILS.get_resstring(11155)) --显示挂机 11128 
		
		--设置选择位置
		local width = 240
		local cnt = #(dlg.m_mapCell)

        local index = (dlg.m_iHighLightID - 2)
        if index < 0 then
            index = 0
        end

		local scale = index / cnt
		dlg.m_scrollCellList:setHorizontalScrollPosition(scale)		
	end
end

function MapChoseDlg.GetSubMapIDByString(strSubMaps)
	local sub_str_tab = {};
	local str = strSubMaps;
	while (true) do 
		local pos = string.find(str, ",");
		if not pos then
			sub_str_tab[#sub_str_tab + 1] = str;
			break;
		end
		local sub_str = string.sub(str, 1, pos - 1);
		sub_str_tab[#sub_str_tab + 1] = sub_str;
		str = string.sub(str, pos + 1, #str);
	end
	return sub_str_tab;
end
function MapChoseDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_imgBg = winMgr:getWindow("mapchosedialog_mtg")
    	
	self.m_btnYuandi = CEGUI.toPushButton(winMgr:getWindow("mapchosedialog_mtg/now"))
	
	self.m_scrollCellList = CEGUI.toScrollablePane(winMgr:getWindow("mapchosedialog_mtg/list"))
	self.m_btnIntro = CEGUI.toPushButton(winMgr:getWindow("mapchosedialog_mtg/btntishi1"))

    self.m_switchAuto = CEGUI.toSwitch(winMgr:getWindow("mapchosedialog_mtg/text3/switch"))
	self.m_btnFight = CEGUI.toPushButton(winMgr:getWindow("mapchosedialog_mtg/text3/btnrenwu"))
	self.m_imgSkillFight = CEGUI.toSkillBox(winMgr:getWindow("mapchosedialog_mtg/text3/btnrenwu/skillbox1"))
	self.m_btnDef = CEGUI.toPushButton(winMgr:getWindow("mapchosedialog_mtg/text3/btnrenwu1"))
	self.m_imgSkillDef = winMgr:getWindow("mapchosedialog_mtg/text3/btnrenwu/gongji1s1")
    
	self.m_btnFight:EnableClickAni(false)
	self.m_btnDef:EnableClickAni(false)

	self.m_skillRole = tolua.cast(winMgr:getWindow("mapchosedialog_mtg/text3/btnrenwu/skillbox1"),"CEGUI::SkillBox")
	self.m_skillPet = tolua.cast(winMgr:getWindow("mapchosedialog_mtg/text3/btnrenwu/skillbox11"),"CEGUI::SkillBox")
	
	self.m_imgRole =  winMgr:getWindow("mapchosedialog_mtg/text3/btnrenwu/gongji1s")
	self.m_imgPet =  winMgr:getWindow("mapchosedialog_mtg/text3/btnrenwu/gongji1s1")
	
	self.m_btnYuandi:subscribeEvent("Clicked", MapChoseDlg.HandleBtnYuandiClick, self)
	
	self.m_btnIntro:subscribeEvent("Clicked", MapChoseDlg.HandleBtnIntroClick, self)
	
	self.m_btnFight:subscribeEvent("Clicked", MapChoseDlg.HandleBtnGuaJiClick, self)
	self.m_btnDef:subscribeEvent("Clicked", MapChoseDlg.HandleBtnDefClick, self)
	self.m_switchAuto:subscribeEvent("StatusChanged", MapChoseDlg.HandleSwitchAutoClick, self)
	self.m_scrollCellList:EnableHorzScrollBar(true)

	self.m_mapCell = {}
	self.m_mapIDList = {}
	self.m_iHighLightID = 0
	
	self.m_OperateTypePlayer = GetBattleManager():GetAutoCommandOperateType(0)
	self.m_OperateIDPlayer = GetBattleManager():GetAutoCommandOperateID(0)
	self.m_OperateTypePet = GetBattleManager():GetAutoCommandOperateType(1)
	self.m_OperateIDPet = GetBattleManager():GetAutoCommandOperateID(1)	
	
	self.m_nCanDoublePtr = 0
	self.m_nGotDoublePtr = 0
	self.m_nOfflineExp  = 0
	
	self.m_tipIntro = nil
	
	self.m_bBottomVisible = true
	
	self:InitMapID()
	self:InitMapCell()	
	
	self:SetSrvData()
	
	self:CaclHighLightPos()		
	
	self:RefreshSkillBox()
	self:RefreshBtn()
	self:RefreshCellColor()
	
	
	
	
end

function MapChoseDlg:CaclHighLightPos()
	local data = gGetDataManager():GetMainCharacterData()
	local level = data:GetValue(1230);
	for index , nCell in pairs( self.m_mapCell ) do
		local cell = nCell
		local nMapID = nCell:GetMapID()
		local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(nMapID)
		local minLevel = mapconfig.LevelLimitMin
		local maxlevel = mapconfig.LevelLimitMax
		if  level < maxlevel and level > minLevel or level == maxlevel or level == minLevel then
			self.m_iHighLightID = index
		end
	end
end

function MapChoseDlg:SetSrvData(  )

	local list = HookManager.getInstance():GetHookData()
	if list == nil or #list == 0 then
		return
	end
	self.m_nCanDoublePtr = list[1]
	self.m_nGotDoublePtr = list[2]
	self.m_nOfflineExp  = list[3]
end

function MapChoseDlg:RefreshCellColor()
		
	local data = gGetDataManager():GetMainCharacterData()
	local level = data:GetValue(1230);
	
	for index , nCell in pairs( self.m_mapCell ) do
		local cell = nCell
		local nMapID = nCell:GetMapID()
		local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(nMapID)
		local minLevel = mapconfig.LevelLimitMin
		local maxlevel = mapconfig.LevelLimitMax
		if  level < maxlevel and level > minLevel or level == maxlevel or level == minLevel then
			cell:SetSelectedBySelf(true)
		else
			cell:SetSelectedBySelf(false)
		end		
	end
	
end

function MapChoseDlg:RefreshSkillBox()
	self.m_OperateTypePlayer = GetBattleManager():GetAutoCommandOperateType(0)
	self.m_OperateIDPlayer = GetBattleManager():GetAutoCommandOperateID(0)
	self.m_OperateTypePet = GetBattleManager():GetAutoCommandOperateType(1)
	self.m_OperateIDPet = GetBattleManager():GetAutoCommandOperateID(1)
	
	self:InitSkill(self.m_OperateTypePlayer, self.m_OperateIDPlayer, self.m_imgRole, self.m_skillRole)
	self:InitSkill(self.m_OperateTypePet, self.m_OperateIDPet, self.m_imgPet, self.m_skillPet)
end

function MapChoseDlg:SetRoleSkill( OperateType,OperateID )
	self.m_OperateTypePlayer = OperateType
	self.m_OperateIDPlayer = OperateID
	self:InitSkill(self.m_OperateTypePlayer, self.m_OperateIDPlayer, self.m_imgRole, self.m_skillRole)
	self:RefreshBtn()
end

function MapChoseDlg:SetPetSkill( OperateType,OperateID )
	self.m_OperateTypePet = OperateType
	self.m_OperateIDPet = OperateID
	self:InitSkill(self.m_OperateTypePet, self.m_OperateIDPet, self.m_imgPet, self.m_skillPet)
	self:RefreshBtn()
end

function MapChoseDlg:InitSkill(OperateType,OperateID,img,BtnSkill)
	
	if OperateType == 2 then--技能
		img:setVisible(false)		
		BtnSkill:setVisible(true)
		SkillBoxControl.SetSkillInfo(BtnSkill,OperateID,0)
	else
		BtnSkill:setVisible(false)
		img:setVisible(true)
		local NormalImage = ""
		if OperateType == 1 then--普通攻击
			NormalImage = "set:fightui image:attack"
		else--防御
			NormalImage = "set:fightui image:defense"
		end
		img:setProperty("Image",NormalImage)
	end
end


function MapChoseDlg:InitMapID()
	self.m_mapIDList = {}
    self.m_mapIDList = HookManager.getInstance():GetMapChooseTotalMapID()
end

function MapChoseDlg:InitMapCell()
	self.m_mapCell = {}
	local width = 262
	local height = 340
	
	local xO = 0
	local yO = 1
	
	for i in pairs( self.m_mapIDList ) do
		local mapID = self.m_mapIDList[i]
        local cellbg = MapChouseCellBg.CreateNewDlg( self.m_scrollCellList )
		local cell = MapChooseCell.CreateNewDlg( self.m_scrollCellList )
        cellbg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0, (i-1)*width + xO ), CEGUI.UDim(0,  yO  )))
        cellbg:SetMapID(mapID)
		cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0, (i-1)*width + xO ), CEGUI.UDim(0,  yO  )))
		cell:SetMapID(mapID)
		cell:GetWindow():setID( i )					
		table.insert(self.m_mapCell, cell)		
		cell:Refresh()
	end
	
end


function MapChoseDlg:RefreshBtn()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local switch = CEGUI.toSwitch(winMgr:getWindow("mapchosedialog_mtg/text3/switch"))
	if GetBattleManager():IsAutoOperate()  then
		switch:setLookStatus(0)
	else
		switch:setLookStatus(1)
	end
	
	local PetData = MainPetDataManager.getInstance():GetBattlePet()
	if PetData == nil then
		self.m_btnDef:setEnabled(false)
		self.m_btnDef:setVisible(false)
		self.m_imgPet:setVisible(false)
		self.m_skillPet:setVisible(false)
	else
		self.m_btnDef:setEnabled(true)
		self.m_btnDef:setVisible(true)
	end
	--按钮名称
	if self.m_OperateTypePlayer == 1 then
		self.m_btnFight:setText(MHSD_UTILS.get_resstring(11128))
	elseif self.m_OperateTypePlayer == 4 then
		self.m_btnFight:setText(MHSD_UTILS.get_resstring(11130))		
	elseif self.m_OperateTypePlayer == 2 then		
		local nconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(self.m_OperateIDPlayer)
		self.m_btnFight:setText(nconfig.name)
	else
		self.m_btnFight:setText("")
	end
	
	if self.m_OperateTypePet == 1 and PetData then
		self.m_btnDef:setText(MHSD_UTILS.get_resstring(11128))
	elseif self.m_OperateTypePet == 4 and PetData then
		self.m_btnDef:setText(MHSD_UTILS.get_resstring(11130))		
	elseif self.m_OperateTypePet == 2 and PetData then		
		local nconfig = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(self.m_OperateIDPet)
		local strSkillName =  tostring(nconfig.skillname)
		self.m_btnDef:setText(nconfig.skillname)
	else
		self.m_btnDef:setText("")
	end
end


function MapChoseDlg:HandleCellClicked( args )
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	local cell = 	self.m_mapCell[id]
	local mapID = cell:GetMapID()
end

function MapChoseDlg:HandleBtnYuandiClick(args)
	print(" MapChoseDlg:HandleBtnYuandiClick(args) ")
	if GetBattleManager():IsInBattle() then	
		GetChatManager():AddTipsMsg(150157)
		return true
	end
	local nMapID = gGetScene():GetMapID()
	local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(nMapID)
	
	local bSameMap = false
	for index  , id in pairs(self.m_mapIDList) do
		if nMapID == id  then
			bSameMap = true
			break
		end
	end
	
	if not bSameMap then
		GetChatManager():AddTipsMsg(150160)
		return true
	end
	
	if GetMainCharacter() then
		GetMainCharacter():SetRandomPacing()
	end
	MapChoseDlg.DestroyDialog()
end

function MapChoseDlg:HandleBtnIntroClick(args)
	print("MapChoseDlg:HandleInfoClick()")
	local title = MHSD_UTILS.get_resstring(11132)
	local strAllString = MHSD_UTILS.get_resstring(11133)

	local tips1 = require "logic.workshop.tips1"
	tips1.getInstanceAndShow(strAllString, title)
end

function MapChoseDlg:HandleBtnFightClick(args)
	print("MapChoseDlg:HandleBtnFightClick(args)")
	if GetBattleManager():IsInBattle() then		--new add
		GetChatManager():AddTipsMsg(150157)
		return true
	end	
	if AutoFightSkillCell.getInstanceNotCreate() then
		AutoFightSkillCell.DestroyDialog()
		return true
	end
	
	local dlg = AutoFightSkillCell.getInstanceAndShow()

	local pos = self.m_btnFight:GetScreenPos()
	
	dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,pos.x + 40), CEGUI.UDim(0, pos.y - 280)))
	dlg:GetWindow():setAlwaysOnTop(true)
	dlg:SetRoleOrPetID(0)
	dlg:RefreshAll()
	
end
function MapChoseDlg:HandleBtnDefClick(args)
	print("MapChoseDlg:HandleBtnDefClick(args)")
	--[[if GetBattleManager():IsInBattle() then		--new add
		GetChatManager():AddTipsMsg(150157)
		return true
	end	--]]
	if AutoFightSkillCell.getInstanceNotCreate() then
		AutoFightSkillCell.DestroyDialog()
		return true
	end
	
	local dlg = AutoFightSkillCell.getInstanceAndShow()

	local pos = self.m_imgBg:GetScreenPos()
	dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,pos.x + 500), CEGUI.UDim(0, pos.y + 80)))
	dlg:GetWindow():setAlwaysOnTop(true)
	dlg:SetRoleOrPetID(1)
	dlg:RefreshAll()
end

function MapChoseDlg:HandleBtnGuaJiClick(args)
    local dlg = GuaJiAIDlg.getInstanceAndShow()
end

function MapChoseDlg:HandleSwitchAutoClick(args)
	print("MapChoseDlg.HandleSwitchAutoClick(args)")
	if GetBattleManager():IsInBattle() then		--new add
		local winMgr = CEGUI.WindowManager:getSingleton()
		local switch = CEGUI.toSwitch(winMgr:getWindow("mapchosedialog_mtg/text3/switch"))
		if GetBattleManager():IsAutoOperate()  then
			switch:setLookStatus(0)
		else
			switch:setLookStatus(1)
		end
		GetChatManager():AddTipsMsg(150157)
		return true
	end
	local winMgr = CEGUI.WindowManager:getSingleton()
	local switch = CEGUI.toSwitch(winMgr:getWindow("mapchosedialog_mtg/text3/switch"))
	local status = switch:getStatus()
	if status == 0 then
        GetBattleManager():BeginAutoOperate()
	else
		GetBattleManager():EndAutoOperate()		
    end
	
end

function MapChoseDlg:HandleInfoClick()

	
end


return MapChoseDlg

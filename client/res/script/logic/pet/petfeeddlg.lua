------------------------------------------------------------------
-- ��������
------------------------------------------------------------------
require "logic.dialog"
require "logic.pet.petchoosezizhi"
require "logic.pet.petchoosezizhinew"
local RANDOM_ACT = {
	eActionRun,
	eActionAttack,
	eActionMagic1
} 

PetFeedDlg = {
	selectedPetKey = 0,
	actType = eActionStand,
	elapse = 0,
	defaultActRepeatTimes = 3,
	defaultActCurTimes = 0,
	selectedItemID = 0
}
setmetatable(PetFeedDlg, Dialog)
PetFeedDlg.__index = PetFeedDlg

local _instance
function PetFeedDlg.getInstance()
	if not _instance then
		_instance = PetFeedDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetFeedDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetFeedDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetFeedDlg.getInstanceNotCreate()
	return _instance
end

function PetFeedDlg.DestroyDialog()
	if _instance then 
		if _instance.sprite then
			_instance.sprite:delete()
			_instance.sprite = nil
			_instance.profileIcon:getGeometryBuffer():setRenderEffect(nil)
		end
		
		gGetDataManager().m_EventPetDataChange:RemoveScriptFunctor(_instance.eventPetDataChange)
		gGetDataManager().m_EventPetNumChange:RemoveScriptFunctor(_instance.eventPetNumChange)
		gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)
		Dialog.OnClose(_instance)
		if not _instance.m_bCloseIsHide then
			_instance = nil
		end
	end
end

function PetFeedDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetFeedDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetFeedDlg.GetLayoutFileName()
	return "petpropertypeiyang_mtg.layout"
end

function PetFeedDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetFeedDlg)
	return self
end

function PetFeedDlg:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.itemIcon = CEGUI.toItemCell(winMgr:getWindow("petpropertypeiyang_mtg/itemdes/itemcell2"))
	self.itemName = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/name")
	
	--���ʵ�������
	self.zizhiItemDesBg = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/zizhiitemdes")
	self.zizhides_leftCount = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/zizhiitemdes/leftusecount")
	
	--������������
	self.lifeItemDesBg = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/lifeitemdes")
	self.lifedes_life = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/lifeitemdes/lifeval")
	self.lifedes_lifeUp = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/lifeitemdes/lifeupval")
    self.lifedes_allwaysLive = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/lifeitemdes/lifeval1")
	
	--�����������
	self.expItemDesBg = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/expitemdes")
	self.expdes_bar = CEGUI.toProgressBar(winMgr:getWindow("petpropertypeiyang_mtg/itemdes/expbar"))
	self.expdes_level = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/expitemdes/levelval")
	self.expdes_levelup = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/expitemdes/expupval")
	
	

	
	--�ɳ���������
	self.growItemDesBg = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/growitemdes")
	self.growdes_ = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/growitemdes/grow")
	self.growdes_grow = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/growitemdes/growval")
	self.growdes_growUp = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/growitemdes/growupval")
	self.growdes_leftCount = winMgr:getWindow("petpropertypeiyang_mtg/itemdes/growitemdes/leftusecount")
	
	self.useBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertypeiyang_mtg/itemdes/useBtn"))
	self.useOnceBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertypeiyang_mtg/itemdes/btnyici"))
	self.useTenBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertypeiyang_mtg/itemdes/btnshiyong1"))
	self.itemScroll = CEGUI.toScrollablePane(winMgr:getWindow("petpropertypeiyang_mtg/textbg/list"))
	self.itemTable = CEGUI.toItemTable(winMgr:getWindow("petpropertypeiyang_mtg/textbg/list/table"))
	self.fanhuiBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertypeiyang_mtg/fanhui"))
	
	self.nameText = winMgr:getWindow("petpropertypeiyang_mtg/icon/type")
	self.profileIcon = winMgr:getWindow("petpropertypeiyang_mtg/icon")
	--self.levelText = winMgr:getWindow("petpropertypeiyang_mtg/level")
	--self.fightSign = winMgr:getWindow("petpropertypeiyang_mtg/icon/zhan")
	self.kindImg = winMgr:getWindow("petpropertypeiyang_mtg/icon/kindImg")
	self.scoreText = winMgr:getWindow("petpropertypeiyang_mtg/scoreText")
	self.petScroll = CEGUI.toScrollablePane(winMgr:getWindow("petpropertypeiyang_mtg/pets/petScroll"))
	--self.petTable = CEGUI.toItemTable(winMgr:getWindow("petpropertypeiyang_mtg/pets/petScroll/petTable"))
    self.fightLevelText = winMgr:getWindow("petpropertypeiyang_mtg/canzhan1")
	
	
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", PetLabel.hide, nil)

	self.petScroll:EnableAllChildDrag(self.petScroll)
	--self.petTable:subscribeEvent("TableClick", PetFeedDlg.handlePetSelected, self)
	
	self.itemScroll:EnableAllChildDrag(self.itemScroll)
	self.itemTable:subscribeEvent("TableClick", PetFeedDlg.handleItemSelected, self)
	
	self.useBtn:subscribeEvent("Clicked", PetFeedDlg.handleUseClicked, self)
	self.useOnceBtn:subscribeEvent("Clicked", PetFeedDlg.handleUseOnceClicked, self)
	self.useTenBtn:subscribeEvent("Clicked", PetFeedDlg.handleUseTenClicked, self)
	self.fanhuiBtn:subscribeEvent("Clicked", PetFeedDlg.handlefanhuiClicked, self)---返回宠物界面
	
	--[[local num = self.petTable:GetCellCount()
	for i=0,num-1 do
		local cell = self.petTable:GetCell(i)
		cell:SetBackGroundImage("chongwuui", "chongwu_di")
		cell:subscribeEvent("LockCellClick", PetFeedDlg.handleLockedPetIconClicked, self)
	end--]]

    self.m_petList = {}
    self.petlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("petpropertypeiyang_mtg/pets/petScroll"));
    self.petlistWnd:EnableHorzScrollBar(false)
	
	self.itemIcon:subscribeEvent("TableClick", PetFeedDlg.HandleShowToolTipsWithItemID, self)

	
	self:refreshItemTable()
	
	self.eventPetDataChange = gGetDataManager().m_EventPetDataChange:InsertScriptFunctor(PetFeedDlg.onEventPetDataChange)
	self.eventPetNumChange = gGetDataManager().m_EventPetNumChange:InsertScriptFunctor(PetFeedDlg.onEventPetNumChange)
	self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(PetFeedDlg.OnEventItemNumChange)
end

function PetFeedDlg:releasePetIcon()   
    local sz = #self.m_petList
    for index  = 1, sz do
        local lyout = self.m_petList[1]
        lyout.addclick = nil
        lyout.LevelText = nil
        self.petCell = nil
        self.chuzhan = nil
        self.NameText = nil
        self.petlistWnd:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_petList,1)
	end
    if self.addPetButton then
        local lyout = self.addPetButton
        lyout.addclick = nil
        lyout.NameText = nil
        lyout.LevelText = nil
        lyout.petCell = nil
        lyout.chuzhan = nil
        lyout.dengji = nil
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        self.addPetButton = nil
    end
end

function PetFeedDlg:HandleShowToolTipsWithItemID(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e2 = CEGUI.toMouseEventArgs(args)
	local touchPos = e2.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--local nType = Commontipdlg.eType.eComeFrom
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function PetFeedDlg:getSelectedPetData()
	return MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
end

function PetFeedDlg:refreshAll(petData)
	self:refreshSelectedPet(petData)
	self:refreshPetTable()
	self:refreshItemTable()
	self:refreshItemDescription()
end

function PetFeedDlg:refreshPetTable()
    
    self:releasePetIcon()
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;
    self.m_petList = {}
    local index = 0
    local fightid = gGetDataManager():GetBattlePetID()
    for i = 1, MainPetDataManager.getInstance():GetPetNum() do
		local petData = MainPetDataManager.getInstance():getPet(i)
        local sID = "PetFeedDlg" .. tostring(index)
        local lyout = winMgr:loadWindowLayout("petcell1.layout",sID);
        self.petlistWnd:addChildWindow(lyout)
	     local xindex = (index)%5
        local yindex = math.floor((index)/5)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (lyout:getWidth().offset)), CEGUI.UDim(0.0, sy + yindex * (lyout:getHeight().offset))))
        --lyout:setID(index)

        lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
        lyout.addclick:setID(index)
	    lyout.addclick:subscribeEvent("MouseButtonUp", PetFeedDlg.handlePetSelected, self)

        if petData.key == self.selectedPetKey then
            lyout.addclick:setSelected(true)
        end
                    
        lyout.NameText = winMgr:getWindow(sID.."petcell/name")
        lyout.NameText:setText(petData.name)
        
        lyout.LevelText = winMgr:getWindow(sID.."petcell/number")
        lyout.LevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))        

        lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."petcell/touxiang"))   
        SetPetItemCellInfo2(lyout.petCell, petData) 

        lyout.chuzhan = winMgr:getWindow(sID.."petcell/zhan")
        lyout.chuzhan:setVisible(false) 
        lyout.addtext = winMgr:getWindow(sID.."petcell/name1")
        lyout.addtext:setVisible(false)

        if fightid == petData.key then
            lyout.chuzhan:setVisible(true) 
        end
        table.insert(self.m_petList, lyout)
        index = index + 1
    end 
    self:refreshAddPetBtn(index)
end
function PetFeedDlg:refreshAddPetBtn(index) 
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;      
    if not MainPetDataManager.getInstance():IsMyPetFull() then
        if self.addPetButton == nil then  
            local sID = "PetFeedDlgNewAdd"
            local lyout = winMgr:loadWindowLayout("petcell1.layout",sID);
            self.petlistWnd:addChildWindow(lyout)
            lyout:setID(index)
            lyout.key = -1

            lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
            lyout.addclick:setID(index)
	        lyout.addclick:subscribeEvent("MouseButtonUp", PetPropertyDlgNew.handleLockedPetIconClicked, self)
                    
            lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."petcell/touxiang"))  
		    lyout.petCell:Clear()
            lyout.petCell:setID(index)
	        lyout.petCell:subscribeEvent("MouseButtonUp", PetPropertyDlgNew.handleLockedPetIconClicked, self)

            local abtn = winMgr:getWindow(sID.."petcell/touxiang/jiahao")
            abtn:setVisible(true)

            lyout.NameText = winMgr:getWindow(sID.."petcell/name")   
            lyout.NameText:setVisible(false)      
            lyout.LevelText = winMgr:getWindow(sID.."petcell/number")  
            lyout.LevelText:setVisible(false)      
            lyout.chuzhan = winMgr:getWindow(sID.."petcell/zhan")
            lyout.chuzhan:setVisible(false) 
            lyout.dengji = winMgr:getWindow(sID.."petcell/dengji")
            lyout.dengji:setVisible(false)        
            lyout.addtext = winMgr:getWindow(sID.."petcell/name1")
            lyout.addtext:setVisible(true)        

            self.addPetButton = lyout 
        end
    else
        if self.addPetButton ~= nil then
            local lyout = self.addPetButton
            lyout.addclick = nil
            lyout.NameText = nil
            lyout.LevelText = nil
            lyout.petCell = nil
            lyout.chuzhan = nil
            lyout.dengji = nil
	        CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
            self.addPetButton = nil
        end
    end
    if self.addPetButton then
	    local xindex = (index)%5
        local yindex = math.floor((index)/5)
	    self.addPetButton:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (self.addPetButton:getWidth().offset)), CEGUI.UDim(0.0, sy + yindex * (self.addPetButton:getHeight().offset))))
     end
end
function PetFeedDlg:refreshPetTableData()    
	local winMgr = CEGUI.WindowManager:getSingleton()
    local fightid = gGetDataManager():GetBattlePetID()
    local sz = MainPetDataManager.getInstance():GetPetNum()
    local sx = 2.0;
    local sy = 2.0;      
    local index = 0
    for i = 1, sz do
		local petData = MainPetDataManager.getInstance():getPet(i)
        if petData then
            local lyout = self.m_petList[i]  
            if lyout == nil then
                local sID = "PetFeedDlg" .. tostring(index)
                lyout = winMgr:loadWindowLayout("petcell1.layout",sID);
                self.petlistWnd:addChildWindow(lyout)
                lyout.key = petData.key            
                lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
                lyout.addclick:setID(index)
	            lyout.addclick:subscribeEvent("MouseButtonUp", PetPropertyDlgNew.handlePetIconSelected, self)
                if petData.key == self.selectedPetKey then
                    lyout.addclick:setSelected(true)
                end                    
                lyout.NameText = winMgr:getWindow(sID.."petcell/name")        
                lyout.LevelText = winMgr:getWindow(sID.."petcell/number")
                lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."petcell/touxiang")) 
                lyout.chuzhan = winMgr:getWindow(sID.."petcell/zhan")
                lyout.addtext = winMgr:getWindow(sID.."petcell/name1")
                lyout.addtext:setVisible(false)
                table.insert(self.m_petList, lyout)
            end
	        local xindex = (index)%5
        local yindex = math.floor((index)/5)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (lyout:getWidth().offset)), CEGUI.UDim(0.0, sy + yindex * (lyout:getHeight().offset))))
       
            lyout.NameText:setText(petData.name)  
            lyout.LevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))        
            SetPetItemCellInfo2(lyout.petCell, petData) 
            lyout.chuzhan:setVisible(false) 
            if fightid == petData.key then
                lyout.chuzhan:setVisible(true) 
            end
            lyout:setVisible(true)
        else
            lyout:setVisible(false)            
        end
        index=index+1
    end 
    for i = #self.m_petList, index+1, -1 do
        local lyout = self.m_petList[i]
        lyout.addclick = nil
        lyout.NameText = nil
        lyout.LevelText = nil
        lyout.petCell = nil
        lyout.chuzhan = nil
        lyout.dengji = nil
        self.petlistWnd:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_petList,i)
    end
    self:refreshAddPetBtn(index)
end

function PetFeedDlg:refreshSelectedPet(petData)
	if petData then
		self.selectedPetKey = petData.key
		--[[if gGetDataManager():GetBattlePetID() == petData.key then
			self.fightSign:setVisible(true)
		else
			self.fightSign:setVisible(false)
		end--]]
	else
		--self.fightSign:setVisible(false)
		self.selectedPetKey = 0
	end
		
	self:refreshProfileView(petData)
	self:refreshItemDescription()
	PetLabel.getInstance():setSelectedPetKey(self.selectedPetKey)
end

function PetFeedDlg:refreshItemTable()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	if not self.feedItemList then
		self.feedItemList = {}
		local ids = BeanConfigManager.getInstance():GetTableByName("pet.cpetfeeditemlist"):getAllID()
		for i = 1, #ids do
			local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetfeeditemlist"):getRecorder(ids[i])
			self.feedItemList[i-1] = conf.itemid
		end
		
		local cellCount = self.itemTable:GetCellCount()
		local itemCount = TableUtil.tablelength(self.feedItemList)
		for i = 0, cellCount-1 do
			local cell = self.itemTable:GetCell(i)
			if i < itemCount then
				cell:SetHaveSelectedState(true)
				local itemid = self.feedItemList[i]
				local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid)
                if item then
				    local img = gGetIconManager():GetImageByID(item.icon)
				    cell:SetImageAutoScale(true)
				    cell:SetImage(img)
                    SetItemCellBoundColorByQulityItem(cell, item.nquality)
				    --cell:setUserData(item)
				    cell:setID(itemid)
				    cell:SetTextUnit(roleItemManager:GetItemNumByBaseID(itemid))
                end
				
				if i==0 then
					self.selectedItemID = itemid
					 cell:SetSelected(true)
				end
				
			else
				cell:setVisible(false)
			end
		end
	else
		local cellCount = self.itemTable:GetCellCount()
		local itemCount = TableUtil.tablelength(self.feedItemList)
		for i=0, cellCount-1 do
			local cell = self.itemTable:GetCell(i)
			if i < itemCount then
				 cell:SetSelected(self.feedItemList[i] == self.selectedItemID)
				cell:SetTextUnit(roleItemManager:GetItemNumByBaseID(self.feedItemList[i]))
			end
		end
	end
end

function PetFeedDlg:refreshProfileView(petData)
    local petAttr
    if petData then
        --self.nameText:setProperty("TextColours", GetPetNameColour(petData.baseid))
		self.nameText:setProperty("TextColours", "FF50321A")
        petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petAttr then
            local imgpath = GetPetKindImageRes(petAttr.kind, petAttr.unusualid)
            self.kindImg:setVisible(true)
		    self.kindImg:setProperty("Image", imgpath)
			if petAttr.iszhenshou ==1 then
				self.kindImg:setProperty("Image", "set:cc25410 image:zhenshou")
					imgpath="set:cc25410 image:zhenshou"
			end
            UseImageSourceSize(self.kindImg, imgpath)
        end
    else
		self.kindImg:setVisible(false)
    end
	self.nameText:setText(petData and petData.name or "")
	self.scoreText:setText(petData and petData.score or "0")
	--self.levelText:setText(petData and 'Lv.'..petData:getAttribute(fire.pb.attr.AttrType.LEVEL) or "")
    self.fightLevelText:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.PET_FIGHT_LEVEL) or "")

	self:refreshPetSprite(petData and petData.shape or nil)
    if self.sprite and petAttr then        
        if petData and petData.petdye1 ~= 0 then
            self.sprite:SetDyePartIndex(0,petData.petdye1)
        else
            self.sprite:SetDyePartIndex(0,petAttr.area1colour)
        end
        if petData and petData.petdye2 ~= 0 then
            self.sprite:SetDyePartIndex(1,petData.petdye2)
        else
            self.sprite:SetDyePartIndex(1,petAttr.area2colour)
        end
    end
end

function PetFeedDlg:refreshPetSprite(shapeID)
	if not shapeID then
		return
	end
	
	if not self.sprite then
		local pos = self.profileIcon:GetScreenPosOfCenter()
		local loc = Nuclear.NuclearPoint(pos.x, pos.y+50)
		self.sprite = UISprite:new(shapeID)
		if self.sprite then
			self.sprite:SetUILocation(loc)
			self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
			self.profileIcon:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, PetFeedDlg.performPostRenderFunctions))
		end
	else
		self.sprite:SetModel(shapeID)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end
	
	self.elapse = 0
	self.defaultActCurTimes = 0
end

function PetFeedDlg:handlefanhuiClicked(args)---返回
	PetLabel.Show(1)
end

function PetFeedDlg:selectFeedItem(itembaseid)
    local cellCount = self.itemTable:GetCellCount()
	for i=0, cellCount-1 do
		local cell = self.itemTable:GetCell(i)
		if cell:getID() == itembaseid then
			self.selectedItemID = itembaseid
			cell:SetSelected(true)
            self:refreshItemDescription()
            break
		end
    end
end

function PetFeedDlg.performPostRenderFunctions(id)
	if _instance and _instance:IsVisible() and _instance:GetWindow():getEffectiveAlpha() > 0.95 and _instance.selectedPetKey ~= 0 and _instance.sprite then
		_instance.sprite:RenderUISprite()
	end
end

function PetFeedDlg:update(dt)
	if not self.sprite then
		return
	end
	
	self.elapse = self.elapse+dt
	if self.elapse >= self.sprite:GetCurActDuration() then
		self.elapse = 0
		if self.actType == eActionStand then
			self.defaultActCurTimes = self.defaultActCurTimes+1
			if self.defaultActCurTimes == self.defaultActRepeatTimes then
				self.defaultActCurTimes = 0
				local idx = math.random(1, #RANDOM_ACT)
				self.actType = RANDOM_ACT[idx]
				self.sprite:PlayAction(self.actType)
			end
		else
			self.actType = eActionStand
			self.sprite:PlayAction(self.actType)
		end
	end
end

--[[function PetFeedDlg:refreshItemTable()
	local itemCount = 7
	local count = self.itemTable:GetCellCount()
	if itemCount > count then
		local rowCount = math.floor(itemCount/5) + (itemCount%5>0 and 1 or 0)
		self.itemTable:SetRowCount(rowCount)
		local h = self.itemTable:GetCellHeight()
		local spaceY = self.itemTable:GetSpaceY()
		self.itemTable:setHeight(CEGUI.UDim(0, (h+spaceY)*rowCount))
		self.itemScroll:EnableAllChildDrag(self.itemScroll)
		
		count = rowCount*5
	end
	
	for i=0,count-1 do
		local cell = self.itemTable:GetCell(i)
		if i < itemCount then
			
		else
			cell:setVisible(false)
		end
	end
end--]]

function PetFeedDlg:refreshItemDescription()
	if self.selectedItemID == 0 then
		return
	end
	
	local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
	
	local itemconf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.selectedItemID)
	if not itemconf then
		return
	end
	
	local img = gGetIconManager():GetImageByID(itemconf.icon)
	self.itemIcon:SetImage(img)
	self.itemIcon:setID(itemconf.id)
    SetItemCellBoundColorByQulityItem(self.itemIcon, itemconf.nquality)
	self.itemName:setText(itemconf.name)
	
	local t = itemconf.itemtypeid
	print('itemtype ' .. t .. ' ' .. itemconf.id)
	local wnd = nil
	if t == ITEM_TYPE.PET_APT then			--��������ҩ��
		wnd = self.zizhiItemDesBg
		local common = GameTable.common.GetCCommonTableInstance():getRecorder(120) --��������������
		self.zizhides_leftCount:setText(petData and tonumber(common.value)-petData.aptaddcount or "0")
		
	elseif t == ITEM_TYPE.PET_CHENGZHANG then		--���ﾭ��ҩ��
		wnd = self.growItemDesBg
		if petData then
			self.growdes_grow:setText(math.floor(petData.growrate*1000) / 1000)
			
			local growratemax = 2000
			--local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
           -- if petConf then
			--    for i=0, petConf.growrate:size()-1 do
			--	    if growratemax < petConf.growrate[i] then
			--		    growratemax = petConf.growrate[i]
			--	    end
			--    end
           -- end
			
			local common = GameTable.common.GetCCommonTableInstance():getRecorder(121) --�ɳ�����������
			self.growdes_leftCount:setText(tonumber(common.value)-petData.growrateaddcount)
			--if tonumber(common.value) == petData.growrateaddcount then
			--	self.growdes_growUp:setText("0")
			--else
			    --��С0.001����������
			    if math.floor(petData.growrate*1000) >= math.floor(growratemax) then
				    self.growdes_growUp:setText("0.5")
			    else
				    growratemax = growratemax/1000
				    local low = math.max(math.floor(((growratemax-petData.growrate)*0.05+0.0005)*1000)/1000, 0.001)
				    local up = math.max(math.floor(((growratemax-petData.growrate)*0.1+0.0005)*1000)/1000, 0.001)
				    if low == up then
					    self.growdes_growUp:setText("0.5")
				    else
					    self.growdes_growUp:setText("0.5")
				    end
			    end
			--end
		else
			self.growdes_grow:setText("0")
			self.growdes_growUp:setText("0")
			self.growdes_leftCount:setText("0")
		end
			
	elseif t == ITEM_TYPE.PET_GROWRATE then		--�ɳ�����ҩ��
		wnd = self.growItemDesBg
		if petData then
			self.growdes_grow:setText(math.floor(petData.growrate*1000) / 1000)
			
			local growratemax = 2000
			--local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
           -- if petConf then
			--    for i=0, petConf.growrate:size()-1 do
			--	    if growratemax < petConf.growrate[i] then
			--		    growratemax = petConf.growrate[i]
			--	    end
			--    end
           -- end
			
			local common = GameTable.common.GetCCommonTableInstance():getRecorder(121) --成长提升丹次数
			self.growdes_leftCount:setText(tonumber(common.value)-petData.growrateaddcount)
			if tonumber(common.value) == petData.growrateaddcount then
				self.growdes_growUp:setText("0")
			else
			    --最小0.001，四舍五入
			    if math.floor(petData.growrate*1000) >= math.floor(growratemax) then
				    self.growdes_growUp:setText("0")
			    else
				    growratemax = growratemax/1000
				    local low = math.max(math.floor(((growratemax-petData.growrate)*0.05+0.0005)*1000)/1000, 0.001)
				    local up = math.max(math.floor(((growratemax-petData.growrate)*0.1+0.0005)*1000)/1000, 0.001)
				    if low == up then
					    self.growdes_growUp:setText(low)
				    else
					    self.growdes_growUp:setText(low .. "-" .. up)
				    end
			    end
			end
		else
			self.growdes_grow:setText("0")
			self.growdes_growUp:setText("0")
			self.growdes_leftCount:setText("0")
		end
		
	elseif t == ITEM_TYPE.PET_EXP then		--���ﾭ��ҩ��
		wnd = self.expItemDesBg
		if petData then
			self.expdes_level:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
			self.expdes_bar:setText(petData.curexp .. "/" .. petData.nextexp)
			self.expdes_bar:setProgress(petData.curexp / petData.nextexp)
		else
			self.expdes_level:setText("0")
			self.expdes_bar:setText("0")
			self.expdes_bar:setProgress(0)
		end
		
		local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetfeeditemattr"):getRecorder(itemconf.id)
		self.expdes_levelup:setText(conf.addpetexp)
		
	elseif t == ITEM_TYPE.PET_FOOD then		--����ʳ��
		wnd = self.lifeItemDesBg
        if petData then
            if petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE) < 0 then
                self.lifedes_life:setText(MHSD_UTILS.get_resstring(11548)) --����
            else
	            self.lifedes_life:setText(petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE))
            end
        else
            self.lifedes_life:setText(0)
        end
		--self.lifedes_life:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE) or "0")
		
		local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetfeeditemattr"):getRecorder(itemconf.id)
        self.lifedes_lifeUp:setText(conf.addpetlife)
	elseif t == ITEM_TYPE.PET_LIFE then		--�������
		wnd = self.lifeItemDesBg
        if petData then
            if petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE) < 0 then
                self.lifedes_life:setText(MHSD_UTILS.get_resstring(11548)) --����
            else
	            self.lifedes_life:setText(petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE))
            end
        else
            self.lifedes_life:setText(0)
        end
		--self.lifedes_life:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE) or "0")
		
		--[[local conf = GameTable.pet.GetCFoodItemAttrTableInstance():getRecorder(itemconf.id)
		local str = string.gsub(conf.addpetlife, "quality", MHSD_UTILS.get_resstring(11131))
		self.lifedes_lifeUp:setText(str)--]]
		
		local conf = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugformula"):getRecorder(itemconf.id)
		self.lifedes_lifeUp:setText(conf and conf.strformula or "0")
	end
	self.zizhiItemDesBg:setVisible( self.zizhiItemDesBg == wnd )
	self.expItemDesBg:setVisible( self.expItemDesBg == wnd )
	self.lifeItemDesBg:setVisible( self.lifeItemDesBg == wnd )
	self.growItemDesBg:setVisible( self.growItemDesBg == wnd )
	
	self.useOnceBtn:setVisible( self.expItemDesBg == wnd )
	self.useTenBtn:setVisible( self.expItemDesBg == wnd )
	self.useBtn:setVisible( self.expItemDesBg ~= wnd )
    self.lifedes_life:setVisible(true)
    self.lifedes_allwaysLive:setVisible(false)
    if petData then
        local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petConf.life == -1 then
            self.lifedes_allwaysLive:setVisible(true)
            self.lifedes_life:setVisible(false)
        end
    end
end

function PetFeedDlg:recvZiZhiCultivateSuccess(petkey, aptid, aptvalue)
	
end

function PetFeedDlg:handleItemSelected(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	print('item selected=>%d', id)
	self.selectedItemID = id
 
	self:refreshItemDescription()
 
end

function PetFeedDlg:handlePetSelected(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)
	local idx = cell:getID()
	if idx < MainPetDataManager.getInstance():GetPetNum() then
		local petData = MainPetDataManager.getInstance():getPet(idx+1)
		if self.selectedPetKey ~= petData.key then
			self:refreshSelectedPet(petData)
		end
	end
end

function PetFeedDlg:handleLockedPetIconClicked(args)
	local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
	cell:setMouseOnThisCell(false)
	
	require("logic.shop.npcpetshop").getInstanceAndShow()
end

function PetFeedDlg:handleUseClicked(args)
	if self.selectedPetKey == 0 then
		return
	end
    local itemconf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.selectedItemID)
    if not itemconf then
		return
	end
	
    if GetBattleManager():IsInBattle() then
        local t = itemconf.itemtypeid
        if t == ITEM_TYPE.PET_APT or			--��������ҩ��
            t == ITEM_TYPE.PET_GROWRATE then		--�ɳ�����ҩ��
	        if self.selectedPetKey == gGetDataManager():GetBattlePetID() then
		        GetCTipsManager():AddMessageTipById(131451) --ս���в��ܽ��д˲���
		        return
	        end
        end
    end
    local petData = self:getSelectedPetData()
    if petData then
        local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petConf.life == -1 and (itemconf.itemtypeid == ITEM_TYPE.PET_FOOD or itemconf.itemtypeid == ITEM_TYPE.PET_LIFE) then
            GetCTipsManager():AddMessageTipById(162131)
            return
        end
    end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local num = roleItemManager:GetItemNumByBaseID(self.selectedItemID)
	if num == 0 then
        ShopManager:tryQuickBuy(self.selectedItemID)
		return
	end
	
	local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
	
	if itemconf.itemtypeid == ITEM_TYPE.PET_APT then	--��������ҩ��
		local common = GameTable.common.GetCCommonTableInstance():getRecorder(120) --��������������
		
		--if tonumber(common.value) <= petData.aptaddcount then
		--	local str = MHSD_UTILS.get_msgtipstring(150071) --xxx�����Ѿ�����ʳ�����ʵ���
		--	str = string.gsub(str, "%$parameter1%$", petData.name)
		--	GetCTipsManager():AddMessageTip(str)
		--	return
	--	end
		
		local dlg = PetChooseZiZhi.getInstanceAndShow()
		dlg:setData(petData, itemconf)
		return
	end
	if itemconf.itemtypeid == ITEM_TYPE.PET_ZIZHI then	--��������ҩ��
		local common = GameTable.common.GetCCommonTableInstance():getRecorder(120) --��������������
		
		--if tonumber(common.value) <= petData.aptaddcount then
		--	local str = MHSD_UTILS.get_msgtipstring(150071) --xxx�����Ѿ�����ʳ�����ʵ���
		--	str = string.gsub(str, "%$parameter1%$", petData.name)
		--	GetCTipsManager():AddMessageTip(str)
		--	return
	--	end
		
		local dlg = PetChooseZiZhiNew.getInstanceAndShow()
		dlg:setData(petData, itemconf)
		return
	end
	
	if itemconf.itemtypeid == ITEM_TYPE.PET_GROWRATE then
		local common = GameTable.common.GetCCommonTableInstance():getRecorder(121) --成长提升丹次数
		if tonumber(common.value) <= petData.growrateaddcount then
			local str = MHSD_UTILS.get_msgtipstring(150072) --xxx宠物已经不能食用xxx了
			str = string.gsub(str, "%$parameter1%$", petData.name)
			str = string.gsub(str, "%$parameter2%$", itemconf.name)
			GetCTipsManager():AddMessageTip(str)
			return
		end
		
		local growratemax = 0
		local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petConf then
		    for i=0, petConf.growrate:size()-1 do
			    if growratemax < petConf.growrate[i] then
				    growratemax = petConf.growrate[i]
			    end
		    end
        end
		
		if math.floor(petData.growrate*1000) >= growratemax then
			local str = MHSD_UTILS.get_msgtipstring(150073) --xxx宠物成长已满，无法使用xx
			str = string.gsub(str, "%$parameter1%$", petData.name)
			str = string.gsub(str, "%$parameter2%$", itemconf.name)
			GetCTipsManager():AddMessageTip(str) 
			return
		end
	end
	
	local item = roleItemManager:GetItemByBaseID(self.selectedItemID)
	if item then
		roleItemManager:UseItem(item, fire.pb.item.IDType.PET, self.selectedPetKey)
	end
end

--ʹ�þ������
function PetFeedDlg:handleUseOnceClicked(args)
	if self.selectedPetKey == 0 then
		return
	end

    --[[if GetBattleManager():IsInBattle() then
		GetCTipsManager():AddMessageTipById(131451) --ս���в��ܽ��д˲�����
        return
    end--]]
    if GetBattleManager():IsInBattle() then    
	    if self.selectedPetKey == gGetDataManager():GetBattlePetID() then
		    GetCTipsManager():AddMessageTipById(131451) --ս���в��ܽ��д˲���
		    return
	    end
    end
    local petData = self:getSelectedPetData()
    local itemconf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.selectedItemID)
    if not itemconf then
		return
	end
    if petData then
        local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petConf.life == -1 and itemconf.itemtypeid == ITEM_TYPE.PET_FOOD then
            GetCTipsManager():AddMessageTipById(162131)
            return
        end
    end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local num = roleItemManager:GetItemNumByBaseID(self.selectedItemID)
	if num == 0 then
        ShopManager:tryQuickBuy(self.selectedItemID)
		return
	end
	
	local level = petData:getAttribute(fire.pb.attr.AttrType.LEVEL)
	local roleLevel = gGetDataManager():GetMainCharacterLevel()
	if level >= roleLevel + 10 then
		local str = MHSD_UTILS.get_msgtipstring(150070) --xxx����ȼ����ߣ������ٴ�ʹ��xxxx����
		str = string.gsub(str, "%$parameter1%$", petData.name)
		str = string.gsub(str, "%$parameter2%$", self.itemName:getText())
		GetCTipsManager():AddMessageTip(str) 
		return
	end
	
	--[[local item = roleItemManager:GetItemByBaseID(self.selectedItemID)
	if item then
		roleItemManager:UseItem(item, fire.pb.item.IDType.PET, self.selectedPetKey)
	end--]]
	
	local p = require("protodef.fire.pb.pet.cpetexpcultivate"):new()
	p.petkey = self.selectedPetKey
	p.itemid = self.selectedItemID
	p.itemnum = 1
	LuaProtocolManager:send(p)
end

function PetFeedDlg:handleUseTenClicked(args)
	if self.selectedPetKey == 0 then
		return
	end

    --[[if GetBattleManager():IsInBattle() then
		GetCTipsManager():AddMessageTipById(131451) --ս���в��ܽ��д˲�����
        return
    end--]]
    if GetBattleManager():IsInBattle() then    
	    if self.selectedPetKey == gGetDataManager():GetBattlePetID() then
		    GetCTipsManager():AddMessageTipById(131451) --ս���в��ܽ��д˲���
		    return
	    end
    end

    local itemconf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.selectedItemID)
    if not itemconf then
		return
	end
    local petData = self:getSelectedPetData()
    if petData then
        local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petConf.life == -1 and itemconf.itemtypeid == ITEM_TYPE.PET_FOOD then
            GetCTipsManager():AddMessageTipById(162131)
            return
        end
    end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local num = roleItemManager:GetItemNumByBaseID(self.selectedItemID)
	if num == 0 then
        ShopManager:tryQuickBuy(self.selectedItemID, 10)
		return
	end
	local level = petData:getAttribute(fire.pb.attr.AttrType.LEVEL)
	local roleLevel = gGetDataManager():GetMainCharacterLevel()
	if level >= roleLevel + 10 then
		local str = MHSD_UTILS.get_msgtipstring(150070) --xxx����ȼ����ߣ������ٴ�ʹ��xxxx����
		str = string.gsub(str, "%$parameter1%$", petData.name)
		str = string.gsub(str, "%$parameter2%$", self.itemName:getText())
		GetCTipsManager():AddMessageTip(str) 
		return
	end
	
	local p = require("protodef.fire.pb.pet.cpetexpcultivate"):new()
	p.petkey = self.selectedPetKey
	p.itemid = self.selectedItemID
	p.itemnum = math.min(10, num)
	LuaProtocolManager:send(p)
end

function PetFeedDlg.onEventPetDataChange(key)
	if not _instance or not _instance:IsVisible() then
		return
	end
	
	_instance:refreshPetTableData()
	if _instance.selectedPetKey == key then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.selectedPetKey)
		_instance:refreshSelectedPet(petData)
	end
end

function PetFeedDlg.onEventPetNumChange()
	if not _instance or not _instance:IsVisible() then
		return
	end
	_instance:refreshPetTableData()
end

function PetFeedDlg.OnEventItemNumChange(bagid, itemkey, itembaseid)
	if not _instance or not _instance:IsVisible() or bagid ~= fire.pb.item.BagTypes.BAG then
		return
	end
	
	_instance:refreshItemTable()
end

return PetFeedDlg

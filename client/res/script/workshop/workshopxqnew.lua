require "logic.dialog"
require "logic.workshop.workshophelper"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "logic.workshop.workshopmanager"
require "utils.commonutil"
require "logic.workshop.workshopitemcell2"
--local nOpenLevel1 = 30
--local nOpenLevel2 = 60
	
WorkshopXqNew = {}
local GemTypeID = 0x5
local FUNCTION_INDEX = 1
local BAG_INDEX = 2
local STONE_INDEX = 3
setmetatable(WorkshopXqNew, Dialog)
WorkshopXqNew.__index = WorkshopXqNew
local _instance


function WorkshopXqNew.OnDzResult()
	if not _instance then
		return
	end
	
end

--卸下返回
function WorkshopXqNew:RefreshItemTips(item)
	if not _instance then
		return
	end
	LogInfo("WorkshopXqNew:RefreshItemTips ")
	
	_instance:RefreshEquipListState()
	_instance:RefreshMiddle(true)
	--_instance:RefreshRightGem(true)
	local bUseLocal = true  
	_instance:RefreshRichBox(bUseLocal)
	
end

	
function WorkshopXqNew.OnXqResult(protocol)
	if not _instance then
		return
	end
	
	if protocol.ret~=1 then
		return
	end
	
	_instance:RefreshEquipListState()
    local bSelNext = true
	_instance:RefreshMiddle(true,bSelNext)
	--_instance:RefreshRightGem(true)
	local bUseLocal = true  
	_instance:RefreshRichBox(bUseLocal)
	
end

function WorkshopXqNew.OnTHResult(protocol)
	if not _instance then
		return
	end
	
	
	_instance:RefreshEquipListState()
	--_instance:RefreshEquipCellSel()
	_instance:RefreshMiddle(true)
	--_instance:RefreshRightGem(true)
	_instance:RefreshRichBox(false)
end

--//取下成功
function WorkshopXqNew.OnQXResult(protocol)
	if not _instance then
		return
	end
	
	--_instance:RefreshUI()
	--_instance:RefreshEquipList()
	_instance:RefreshEquipListState()
	--_instance:RefreshEquipCellSel()
	_instance:RefreshMiddle(true)
	--_instance:RefreshRightGem(true)
	_instance:RefreshRichBox(false)
end

function WorkshopXqNew.getInstance()
	if _instance == nil then
		_instance = WorkshopXqNew:new()
		_instance:OnCreate()
	end
	return _instance
end


function WorkshopXqNew:IsGemMatchItem(gemid, itemid,nCurSelGemType)
    return require("logic.workshop.workshopmanager").getInstance():IsGemMatchItem(gemid, itemid,nCurSelGemType)
end

--eequiptype 部件类型
function WorkshopXqNew.getInstanceOrNot()
	return _instance
end

function WorkshopXqNew:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel(self:GetWindow())

	--//=======================
	self:InitMiddle()
	self:InitRight()

    if gGetRoleItemManager() then
        self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(WorkshopXqNew.OnItemNumChange)
    end
end

function WorkshopXqNew.OnItemNumChange(eBagType, nItemKey, nItemId)
    
    if _instance == nil then
		return
	end
	

	if eBagType ~= fire.pb.item.BagTypes.BAG then
		return
	end

    local wsManager = Workshopmanager.getInstance()
	local nItemType = wsManager:GetItemTypeWithId(nItemId)
	if nItemType~=eItemType_GEM then
		return
	end

    _instance:RefreshRightGem(true, false)

end

function WorkshopXqNew:RefreshUI(nBagId,nItemKey)
	self:RefreshEquipList(nBagId,nItemKey)
	self:RefreshEquipListState()
	self:RefreshEquipCellSel()
	self:RefreshMiddle()
	self:RefreshRightGem(nil, true)
	self:RefreshRichBox(false)
end

function WorkshopXqNew:InitMiddle()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("workshopxqnew/left/list"))
	self.ScrollEquip:subscribeEvent("NextPage", WorkshopXqNew.OnNextPage, self)
		
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("workshopxqnew/left/info/item"))
    self.imageHaveEquip = winMgr:getWindow("workshopxqnew/left/info/item/biaoqian")  
    self.imageHaveEquip:setVisible(false)
	self.LabTargetName = winMgr:getWindow("workshopxqnew/left/info/xuantieqiang") 
	self.LabTargetTypeName = winMgr:getWindow("workshopxqnew/left/info/sixty") 
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("workshopxqnew/left/info/box"))
	self.richBoxEquip:setReadOnly(true)

    self.labEquipXqGemMaxLevel = winMgr:getWindow("workshopxqnew/left/info/wenben")
	
	self.vButtonBox = {}
	for nIndexBox=1,3 do 
		self.vButtonBox[nIndexBox] = {}
		
		local btnBox = CEGUI.toGroupButton(winMgr:getWindow("workshopxqnew/left/info/xuankuang"..nIndexBox))
		btnBox:subscribeEvent("MouseClick", self.HandleBtnClickedGemBox, self)
		btnBox.nId = nIndexBox
		local itemCell = CEGUI.toItemCell(winMgr:getWindow("workshopxqnew/left/info/xuankuang"..nIndexBox.."/baoshi"))
		local labelGemName = winMgr:getWindow("workshopxqnew/left/info/xuankuang"..nIndexBox.."/sheli")
		local labelGemEffect = winMgr:getWindow("workshopxqnew/left/info/xuankuang"..nIndexBox.."/baoshixiaoguo")
		local imageJiaohao = winMgr:getWindow("workshopxqnew/left/info/xuankuang"..nIndexBox.."/baoshi/jiahao")
        local btnDownGem = CEGUI.toPushButton(winMgr:getWindow("workshopxqnew/left/info/xuankuang"..nIndexBox.."/baoshi/down"))
        btnDownGem:subscribeEvent("Clicked", self.HandleBtnClickedGetDown, self)
        btnDownGem:setID(nIndexBox) --12

		self.vButtonBox[nIndexBox].btnBg = btnBox
		self.vButtonBox[nIndexBox].itemCell = itemCell
		self.vButtonBox[nIndexBox].labelGemName = labelGemName
		self.vButtonBox[nIndexBox].labelGemEffect = labelGemEffect
		self.vButtonBox[nIndexBox].imageJiaohao = imageJiaohao
        self.vButtonBox[nIndexBox].btnDownGem = btnDownGem


		local nLockIndex = nIndexBox+3
		local btnBgLock = CEGUI.toPushButton(winMgr:getWindow("workshopxqnew/left/info/xuankuang"..nLockIndex))
		local labLevelOpen = winMgr:getWindow("workshopxqnew/left/info/xuankuang"..nLockIndex.."/jiesuo")
		self.vButtonBox[nIndexBox].btnBgLock = btnBgLock
		self.vButtonBox[nIndexBox].labLevelOpen = labLevelOpen
		WorkshopHelper.SetChildNoCutTouch(btnBox)
	end
end

function WorkshopXqNew:InitRight()
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.PaneShow = winMgr:getWindow("workshopxqnew/right2") --
	self.PaneShow:setVisible(false)
	self.ScrollGemType = winMgr:getWindow("workshopxqnew/right2/list5")
	--//===================================
	self.PaneGem = winMgr:getWindow("workshopxqnew/right3")
	self.PaneGem:setVisible(true)
	self.scrollGemList = CEGUI.toScrollablePane(winMgr:getWindow("workshopxqnew/right3/list5"))
	self.labEquipPosName = winMgr:getWindow("workshopxqnew/right2/wuqibuwei") 
	--self.labEquipXqGemMaxLevel = winMgr:getWindow("workshopxqnew/right2/benzhuangbei") 
	--//===================================
	
	self:RefreshGemListVisible()

end 


--//点击卸下按钮
function WorkshopXqNew:HandleBtnClickedGetDown(args)

	local wnd = CEGUI.toWindowEventArgs(args).window
    local nBoxIndex = wnd:getID()
    

	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(11017) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	local eBagType = self:GetCurItemBagType()
	local equipbag = 1
	if eBagType == fire.pb.item.BagTypes.EQUIP then
		equipbag = 1
	else
		equipbag = 0
	end
	local equipItemkey = self:GetCurServerKey()
	if equipItemkey == -1 then
		return
	end
	--local equipbag = 1
	local gemindex = nBoxIndex-1 --lua index
	if gemindex==-1 then
		return
	end
	
	local nGemId = self:GetGemIdInEquip(nBoxIndex)
	if nGemId==-1 then
		local strNoXqGemzi = MHSD_UTILS.get_resstring(2749) --未镶嵌宝石
		GetCTipsManager():AddMessageTip(strNoXqGemzi)
		return
	end
		
	require "protodef.fire.pb.item.cdelgem"
	local p = CDelGem.Create()
	p.keyinpack = equipItemkey
	p.isequip = equipbag
	p.gempos = gemindex
    LuaProtocolManager.getInstance():send(p)
end

--//点击镶嵌按钮
function WorkshopXqNew:HandlBtnClickedXiangqian()
	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(11017) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	
	local eBagType = self:GetCurItemBagType()
	local equipbag = 1
	if eBagType == fire.pb.item.BagTypes.EQUIP then
		equipbag = 1
	else
		equipbag = 0
	end
	local equipItemkey = self:GetCurServerKey()
	if equipItemkey == -1 then
		return
	end
	local bCanXqCur,strNoXqGemzi = self:IsCanXqCur()
	if bCanXqCur==false then
		GetCTipsManager():AddMessageTip(strNoXqGemzi)
		return
	end
	--local equipbag = 1
	local gemItemkey = self.nCellGemSelId --宝石的key
	if gemItemkey==-1 then
		return
	end
	
	require "protodef.fire.pb.item.cattachgem"
	local p = CAttachGem.Create()
	p.keyinpack = equipItemkey
	p.packid = equipbag
	p.gemkey = gemItemkey
    LuaProtocolManager.getInstance():send(p)

	-- 设一个标记：客户端请求镶嵌宝石
	GameCenterUtil.requestAttachGem = true;
	local roleItemManager = require("logic.item.roleitemmanager").getInstance();
	local pItem = roleItemManager:FindItemByBagAndThisID(equipItemkey, eBagType);
	if pItem then
		GameCenterUtil.Lv7GemCount = pItem:GetGemCountByLevel(7);
	end
end

function WorkshopXqNew:IsCanXqCur()
	local gemItemkey = self.nCellGemSelId --宝石的key
	if gemItemkey==-1 then
		local strNoXqGemzi = MHSD_UTILS.get_resstring(11010) --请选择一个宝石
		return false,strNoXqGemzi
	end
	return true
end

--//点击替换按钮
function WorkshopXqNew:HandlBtnClickedTihuan()
	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(11017) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	
	local bCanXqCur,strNoXqGemzi = self:IsCanXqCur()
	if bCanXqCur==false then
		GetCTipsManager():AddMessageTip(strNoXqGemzi)
		return
	end

	local equipItemkey =0
	local equipbag = 0
	local gemIndex = 0
	local gemItemkey = 0
	--//=====================================
	local eBagType = self:GetCurItemBagType()
	local equipbag = 1
	if eBagType == fire.pb.item.BagTypes.EQUIP then
		equipbag = 1
	else
		equipbag = 0
	end
	local equipItemkey = self:GetCurServerKey()
	if equipItemkey == -1 then
		return
	end
	--//=====================================
	local gemIndex = self.nGemBoxIndex-1 --lua index
	if gemIndex==-1 then
		return
	end
	local gemItemkey = self.nCellGemSelId --宝石的key
	if gemItemkey==-1 then
		return
	end
	
	--//=====================================
	LogInfo("equipItemkey="..equipItemkey)
	LogInfo("equipbag="..equipbag)
	LogInfo("gemIndex="..gemIndex)
	LogInfo("gemItemkey="..gemItemkey)
	
	--self.equipitemkey = 0
	--self.equipbag = 0
	--self.gemindex = 0
	--self.gemitemkey = 0
	
	local p = require "protodef.fire.pb.item.creplacegemfromequip":new()
	p.equipitemkey = equipItemkey
	p.equipbag = equipbag
	p.gemindex = gemIndex
	p.gemitemkey = gemItemkey
	require "manager.luaprotocolmanager":send(p)

	-- 设一个标记：客户端请求替换宝石
	GameCenterUtil.requestAttachGem = true;
	local roleItemManager = require("logic.item.roleitemmanager").getInstance();
	local pItem = roleItemManager:FindItemByBagAndThisID(equipItemkey, eBagType);
	if pItem then
		GameCenterUtil.Lv7GemCount = pItem:GetGemCountByLevel(7);
	end
	
end


--//刷新装备列表状态
function WorkshopXqNew:RefreshEquipListState()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		self:RefreshEquipCellGemState(equipCell)
	end
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshRedPointInRightLabel()
end


--//取在宝石蓝的宝石id
function WorkshopXqNew:GetGemIdInGemBoxWithIndex(vcGemList,nIndex) --same in manager
     return require("logic.workshop.workshopmanager").getInstance():GetGemIdInGemBoxWithIndex(vcGemList,nIndex)
end



--function WorkshopXqNew
--是否有空的宝石栏
function WorkshopXqNew:IsHaveGemBoxFree(equipData) --same in manager
     return require("logic.workshop.workshopmanager").getInstance():IsHaveGemBoxFree(equipData)
end


--是否有空宝石栏并且有宝石镶嵌
function WorkshopXqNew:IsHaveFreeGemBoxAndGem(equipData) --same in manager
    return require("logic.workshop.workshopmanager").getInstance():IsHaveFreeGemBoxAndGem(equipData)
end


--//刷新装备列表状态
function WorkshopXqNew:RefreshEquipCellGemState(equipCell)
	equipCell.imageStone1:setProperty("Image","" )
	equipCell.imageStone2:setProperty("Image","" )
	
	local nServerKey = equipCell.nServerKey
	local eBagType = equipCell.eBagType
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return
	end
	local equipObj = equipData:GetObject()
	local vGemList = equipObj:GetGemlist()
	for nIndexGem = 1, vGemList:size() do
		local nGemId = vGemList[nIndexGem - 1]
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nGemId)
		local strIconPath = gGetIconManager():GetImagePathByID(itemAttrCfg.icon):c_str()
		if itemAttrCfg then
			if nIndexGem==1 then
				equipCell.imageStone1:setProperty("Image",strIconPath )
			elseif nIndexGem==2 then
				equipCell.imageStone2:setProperty("Image",strIconPath)
			end
		end
	end
	--//
	equipCell.labBottom1:setVisible(false)
	if vGemList:size()==0 then
		equipCell.labBottom1:setVisible(true)
		local bHaveGem = self:IsHaveFreeGemBoxAndGem(equipData) --self:IsHaveCanXqGem(equipData)
		if bHaveGem then --11011
			local strHaveGemToXqzi = MHSD_UTILS.get_resstring(11011)
            equipCell.labBottom1:setProperty("TextColours","FFFFFFFF")

            local strGreenColor = "FF06cc11"
            strHaveGemToXqzi = "[colour=".."\'"..strGreenColor.."\'".."]"..strHaveGemToXqzi

			equipCell.labBottom1:setText(strHaveGemToXqzi) --FF06cc11
            if eBagType==fire.pb.item.BagTypes.EQUIP then
                equipCell.imageRed:setVisible(true)
            end
			
			
		else --2749
            equipCell.labBottom1:setProperty("TextColours","FF333333")
			local strNoHaveGemToXqzi = MHSD_UTILS.get_resstring(2749)
			equipCell.labBottom1:setText(strNoHaveGemToXqzi)
			equipCell.imageRed:setVisible(false)
		end
	else
		local bHaveFreeGemBox = self:IsHaveFreeGemBoxAndGem(equipData)
		if bHaveFreeGemBox then
             if eBagType==fire.pb.item.BagTypes.EQUIP then
                equipCell.imageRed:setVisible(true)
            end
		else
			equipCell.imageRed:setVisible(false)
		end
	end

	
	
    local nBoxIndex = 1
	local bUnlock = self:IsUnlockGemBox(equipData,nBoxIndex)
	
	if bUnlock == false then
          local strCannotxq = MHSD_UTILS.get_resstring(11028)
          equipCell.labBottom1:setProperty("TextColours","FFFFFFFF")

          local strColornoxq = "FF777777"
          strCannotxq = "[colour=".."\'"..strColornoxq.."\'".."]"..strCannotxq

          equipCell.labBottom1:setText(strCannotxq)
    end		
	
	
end


function WorkshopXqNew:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXqPage = wsManager.nXqPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:GetXqEquipWithPage(vEquipKeyOrderIndex,wsManager.nXqPage)
	local nNewNum = #vEquipKeyOrderIndex
	if nNewNum==0 then
		return
	end
	for nIndex=1,nNewNum do 
		local nEquipOrderIndex = vEquipKeyOrderIndex[nIndex]
		local equipCellData = wsManager:GetEquipCellDataWithIndex(nEquipOrderIndex)
		if equipCellData~= nil then
			self:CreateEquipCell(equipCellData)
		end
	end
	self:RefreshEquipListState()
end

function WorkshopXqNew:CreateEquipCell(equipCellData)
	local nEquipKey = equipCellData.nEquipKey
	local eBagType = equipCellData.eBagType
	local nIndexEquip = #self.vItemCellEquip +1
	--local nEquipKey = vEquipKeyOrder[nIndexEquip].nEquipKey
	--local eBagType = vEquipKeyOrder[nIndexEquip].eBagType
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local prefix = "WorkshopXqNew_equip"..nIndexEquip
			
			local cellEquipItem = Workshopitemcell.new(self.ScrollEquip, nIndexEquip - 1,prefix)
			cellEquipItem:RefreshVisibleWithType(2) --//1=dz 2xq 3hc 4xl
			self.vItemCellEquip[nIndexEquip] = cellEquipItem
			local itemAttrCfg = equipData:GetBaseObject()
			cellEquipItem.labItemName:setText(equipData:GetName())
			cellEquipItem.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))

            SetItemCellBoundColorByQulityItemWithId(cellEquipItem.itemCell,itemAttrCfg.id)

            local nItemId = itemAttrCfg.id
            SetItemCellBoundColorByQulityItem(cellEquipItem.itemCell, itemAttrCfg.nquality)

            refreshItemCellBind(cellEquipItem.itemCell,eBagType,nEquipKey)

			cellEquipItem.nClientKey = nIndexEquip
			cellEquipItem.eBagType = eBagType
			cellEquipItem.nServerKey = nEquipKey
			if eBagType==fire.pb.item.BagTypes.EQUIP then
				cellEquipItem.imageHaveEquiped:setVisible(true)
			end
			cellEquipItem.btnBg:subscribeEvent("MouseClick", WorkshopXqNew.HandleClickedCellEquip,self)
		end
end

--//刷新装备列表
function WorkshopXqNew:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXqPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}

	--//=============================
	--local vEquipKeyOrder = {}
	--WorkshopHelper.GetEquipArray(vEquipKeyOrder)
	local vEquipKeyOrderIndex = {}
    wsManager:GetXqEquipWithPage(vEquipKeyOrderIndex,wsManager.nXqPage)
	
	--//=============================
	for nIndex=1,#vEquipKeyOrderIndex do 
		local nEquipOrderIndex = vEquipKeyOrderIndex[nIndex]
		local equipCellData = wsManager:GetEquipCellDataWithIndex(nEquipOrderIndex)
		if equipCellData~= nil then
			self:CreateEquipCell(equipCellData)
		end
		
		if self.nItemCellSelId ==0 then 
			self.nItemCellSelId = nEquipOrderIndex
		end	
	end

    local bHaveSelIdInPage = self:isSelIdInPage(self.nItemCellSelId,vEquipKeyOrderIndex)
    if bHaveSelIdInPage == false then
        if #vEquipKeyOrderIndex > 0 then
            local nEquipOrderIndex = vEquipKeyOrderIndex[1]
            self.nItemCellSelId = nEquipOrderIndex
        end
    end

end

function WorkshopXqNew:isSelIdInPage(nSelId,vEquipKeyOrderIndex)
     local bHaveSelIdInPage = false
    for nIndex=1,#vEquipKeyOrderIndex do 
		local nEquipOrderIndex = vEquipKeyOrderIndex[nIndex]
        if nSelId == nEquipOrderIndex then
            bHaveSelIdInPage = true
        end
	end
    return bHaveSelIdInPage
end


--//点击装备
function WorkshopXqNew:HandleClickedCellEquip(e) 
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.vItemCellEquip do
		local cellEquip = self.vItemCellEquip[i]
		if cellEquip.btnBg == mouseArgs.window then
			self.nItemCellSelId =  cellEquip.nClientKey
			break
		end
	end
	
	self:RefreshEquipCellSel() 
	self:RefreshMiddle()
	self.bGemListPaneShow = false  
	self:RefreshRightGem(nil, true)
	self:RefreshRichBox(false)
	return true
end

--//刷新装备选中状态
function WorkshopXqNew:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
		end	
	end
end

--取当前装备key
function WorkshopXqNew:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return -1
	end
	return cellEquipItem.nServerKey
end

--取当前装备cell
function WorkshopXqNew:GetCellWithIndex(nIndex)
	local nCellNum = #self.vItemCellEquip
	if nIndex > nCellNum then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

--取当前装备存放位置类型
function WorkshopXqNew:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

--取当前装备数据结构
function WorkshopXqNew:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function WorkshopXqNew:ResetMiddle()
	self.ItemCellTarget:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithId(self.ItemCellTarget,0)

	self.LabTargetName:setText("")
	self.LabTargetTypeName:setText("")
	local nIndex=1
	local bUnlock = false
	self:SetGemBoxLockState(nIndex,bUnlock)
	self:SetGemBoxLockState(nIndex+1,bUnlock)
	self.richBoxEquip:Clear()
	
	
end

function WorkshopXqNew:RefreshMiddle(bKeepSelBox,bSelNext)
    if bKeepSelBox==nil then
        bKeepSelBox=false
    end
    if bSelNext==nil then
        bSelNext = false
    end
	local equipData = self:GetCurEquipData()
	if not equipData then
		self:ResetMiddle()
		return 
	end
	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	self.ItemCellTarget:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(self.ItemCellTarget,itemAttrCfg.id)

    local nBagId = equipData:GetObject().loc.tableType
    local nItemKey = equipData:GetThisID()

    SetItemCellBoundColorByQulityItem(self.ItemCellTarget,itemAttrCfg.nquality)
    refreshItemCellBind(self.ItemCellTarget,nBagId,nItemKey)

    local pObj = equipData:GetObject()
    if pObj then
         if pObj.loc.tableType == fire.pb.item.BagTypes.EQUIP then
           self.imageHaveEquip:setVisible(true) 
        else
           self.imageHaveEquip:setVisible(false) 
        end
    end

   

	local nEquipType = itemAttrCfg.itemtypeid
	local strTypeName = ""
	local itemTypeCfg = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nEquipType)
	if itemTypeCfg then
		strTypeName = itemTypeCfg.name
	end
	local strLevelzi = MHSD_UTILS.get_resstring(351)
	strTypeName = itemAttrCfg.level..strLevelzi.." "..strTypeName
	self.LabTargetName:setText(itemAttrCfg.name)
	self.LabTargetTypeName:setText(strTypeName)
	--local nEquipLevel = itemAttrCfg.level
	--//==================================
    if not bKeepSelBox then
        self.nGemBoxIndex = 1
    end
    if bSelNext then
        local bNextCanSel = self:isNextCanSel()
        if bNextCanSel then
            self.nGemBoxIndex = 2
        end
    end
	
	self:RefreshGemBoxLockState()
	self:RefreshGemBoxContent()
	self:RefreshGemBoxSel() 
	self:RefreshTihuanBtnState()
	
	self:RefreshOpenLevelTitle()
end

function WorkshopXqNew:isNextCanSel()
    local equipData = self:GetCurEquipData()
	if not equipData then
		return false
	end
    local nNextSelBoxId = 2
	local bUnlock = self:IsUnlockGemBox(equipData,nNextSelBoxId)
    if bUnlock == false then
        return false
    end

    local nGemId = self:GetGemIdInEquip(nNextSelBoxId)
	if nGemId ~= -1 then
        return false
    end
    return true
end

function WorkshopXqNew:RefreshOpenLevelTitle()
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	--11027
	--11028 buneng
	local strOpenLevelzi = MHSD_UTILS.get_resstring(11027)
	local strOpenLevelNotzi = MHSD_UTILS.get_resstring(11028)
	
	for nIndex=1,#self.vButtonBox do 
		local bUnlock = self:IsUnlockGemBox(equipData,nIndex)
		local nOpenLevel = self:GetOpenLevelInGemBoxIndex(equipData,nIndex)
		if nOpenLevel~=-1 then
			if bUnlock==false then
				local strBuild = StringBuilder:new()
				strBuild:Set("parameter1", tostring(nOpenLevel))
				local strOpenTitle = strBuild:GetString(strOpenLevelzi)
				strBuild:delete()
				self.vButtonBox[nIndex].labLevelOpen:setText(strOpenTitle)
			end
		else
			self.vButtonBox[nIndex].labLevelOpen:setText(strOpenLevelNotzi)
		end
	end
	--labLevelOpen
	--self.vButtonBox[nIndexBox]
end


--//取宝石类型数组
function WorkshopXqNew:GetGemTypeIdArray(vGemTypeId)
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipAttrCfg then
		return false
	end
	local nNum = equipAttrCfg.vgemtype:size()
	for i = 1, nNum do
		vGemTypeId[#vGemTypeId + 1] = equipAttrCfg.vgemtype[i-1]
	end
end


function WorkshopXqNew:createOneGemToTree(treeView,parentItem,nGemKey)
    local sizeScroll = self.ScrollGemType:getPixelSize()

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local gemData = roleItemManager:FindItemByBagAndThisID(nGemKey, fire.pb.item.BagTypes.BAG)
	if not gemData then
        return
    end
    local itemAttrCfg = gemData:GetBaseObject()

    local childItem = treeView:addChildItem("TaharezLook/common_zbdj", parentItem, sizeScroll.width, 90)
	--childItem:setText(itemAttrCfg.name)
    childItem:setID(nGemKey)

	local cellGem = Workshopitemcell2.new(childItem,0) 
	cellGem.labItemName:setText(itemAttrCfg.name)
	cellGem.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(cellGem.itemCell,itemAttrCfg.id)

	local nNum = gemData:GetNum()
	cellGem.itemCell:SetTextUnit(tostring(nNum))
	local gemconfig = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(itemAttrCfg.id)
    if gemconfig then
	    local strEffect = gemconfig.effectdes 
	    cellGem.labBottom1:setText(strEffect)
    end
	
    childItem.cellGem = cellGem
    self.vCellGem[#self.vCellGem + 1] = cellGem
end

function WorkshopXqNew:createBuyGemCell(treeView,parentItem,nGemTypeId)
    local sizeScroll = self.ScrollGemType:getPixelSize()

    local gemTypeAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cgemtype"):getRecorder(nGemTypeId)
    if gemTypeAttrCfg == nil then
          return
    end

    local childItem = treeView:addChildItem("TaharezLook/common_zbdj", parentItem, sizeScroll.width, 90)
    if not childItem then
        return
    end
   
    local nItemId =  gemTypeAttrCfg.nitemid
    local strDes = gemTypeAttrCfg.stradddes
    local strTypeName = gemTypeAttrCfg.strname

    local cellGem = Workshopitemcell2.new(childItem,0) 
    cellGem.imageAdd:setVisible(true)
	cellGem.labItemName:setText(strTypeName)
	--cellGem.labBottom1:setText(strDes)
	
    cellGem.imageAdd:setID(nItemId)
    childItem.cellGem = cellGem
    self.vCellGem[#self.vCellGem + 1] = cellGem

end

function WorkshopXqNew:createOneGemType(treeView,nGemTypeId)
    local sizeScroll = self.ScrollGemType:getPixelSize()
    local gemTypeAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cgemtype"):getRecorder(nGemTypeId)
    if gemTypeAttrCfg == nil then
          return
    end
    local nIconId = gemTypeAttrCfg.nicon
    local strTypeName = gemTypeAttrCfg.strname
            
    local parentItem = treeView:addParentItem("TaharezLook/common_zbdj", sizeScroll.width, 80)
    if not parentItem then
        return 
    end
    --parentItem.item:setText(strTypeName)
    parentItem.item:setID(nGemTypeId)

    local layoutName = "xiangqianliebiao.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
    local prefix = "WorkshopXqNew_type"..nGemTypeId
	local typeCell = winMgr:loadWindowLayout(layoutName,prefix)
    typeCell.iamgeGem = winMgr:getWindow(prefix.."xiangqianliebiao/tu1")  
    typeCell.labelName = winMgr:getWindow(prefix.."xiangqianliebiao/wenben")  
    typeCell.imageArrow = winMgr:getWindow(prefix.."xiangqianliebiao/tu")   

    typeCell.labelEffectDes =  winMgr:getWindow(prefix.."xiangqianliebiao/wenben2") 
    local strDes = gemTypeAttrCfg.stradddes
    typeCell.labelEffectDes:setText(strDes)

    local strIconPath = gGetIconManager():GetImagePathByID(nIconId):c_str()
	typeCell.iamgeGem:setProperty("Image",strIconPath )
    typeCell.labelName:setText(strTypeName)
    typeCell.imageArrow:setProperty("Image","set:common image:dowm" )
    parentItem.item:addChildWindow(typeCell)
    local x = CEGUI.UDim(0,0)
    local y = CEGUI.UDim(0, 15)
	local pos = CEGUI.UVector2(x,y)
    typeCell:setPosition(pos)


    parentItem.typeCell = typeCell
    self.vGemTypeCell[#self.vGemTypeCell + 1] = typeCell
    ----------------------------------
    self:createBuyGemCell(treeView,parentItem,nGemTypeId)
    
	local equipData = self:GetCurEquipData()
	if not equipData then
		return
	end
	local vGemIdKey = {}
	self:GetCanXqGemIdArray(equipData,vGemIdKey,nGemTypeId)

    for nIndexCell=1,#vGemIdKey do 
		local nGemKey = vGemIdKey[nIndexCell]
        self:createOneGemToTree(treeView,parentItem,nGemKey)		
    end
       
end


function WorkshopXqNew:RefreshGemTypeList(bKeepOldTypeOpen, needAni)

    if not bKeepOldTypeOpen then
        self.nGemTypeId  = 0
    end
    self:ClearAllGemTypeCell()
    self:ClearAllCellGem()
    self.treeView = nil
    self.ScrollGemType:cleanupNonAutoChildren()
    local sizeScroll = self.ScrollGemType:getPixelSize()
    
    local treeView = TreeView.create(self.ScrollGemType, sizeScroll.width, sizeScroll.height)
    self.treeView = treeView
    treeView:setPosition(0, 0)
    treeView:setParentItemClickCallFunc(WorkshopXqNew.clickTreeParentItem, self)
    treeView:setChildItemClickCallFunc(WorkshopXqNew.clickTreeChildItem, self)
	local vGemTypeId = {}
	self:GetGemTypeIdArray(vGemTypeId)
	for nIndexGemType=1,#vGemTypeId do
		local nGemTypeId = vGemTypeId[nIndexGemType]
        self:createOneGemType(treeView,nGemTypeId)
	end
    --local offset = #vGemTypeId*80
    local offset = -10
    treeView:setScrollPos(offset)
    treeView:fresh()
    local aniMan = CEGUI.AnimationManager:getSingleton()
    if aniMan then
        if self.m_aniopen then
            aniMan:destroyAnimationInstance(self.m_aniopen)
        end
    end
    if needAni == true then
        self.animationOpen = aniMan:getAnimation("baoshiyidong")
        self.m_aniopen = aniMan:instantiateAnimation(self.animationOpen)
        self.m_aniopen:setTargetWindow(self.treeView.scroll)
        self.treeView.scroll:subscribeEvent("AnimationEnded", self.HandleAnimationOver, self)
        self.m_aniopen:unpause()
    end
    if bKeepOldTypeOpen then
        self:setOpenParentItem(treeView,self.nGemTypeId)
    end
end

function WorkshopXqNew:HandleAnimationOver(args)
    self.m_aniopen:stop()
end

function WorkshopXqNew:refreshOpenParentItem(treeView,nGemTypeId)
    for k,v in pairs(treeView.parentItems) do
        if v.item:getID() == nGemTypeId then
            if treeView.openedParentItem then
                v.typeCell.imageArrow:setProperty("Image","set:common image:up")
            else
                v.typeCell.imageArrow:setProperty("Image","set:common image:dowm")
            end
        else
           v.typeCell.imageArrow:setProperty("Image","set:common image:dowm")
        end
    end
end


function WorkshopXqNew:setOpenParentItem(treeView,nGemTypeId)
    for k,v in pairs(treeView.parentItems) do
        if v.item:getID() == nGemTypeId then
            treeView:setOpenParentItem(v.item)
            self:refreshOpenParentItem(treeView,nGemTypeId)
            if treeView.openedParentItem then

            end
            --treeView.openedParentItem:setSelected(true)
            break
        end
    end

end

function WorkshopXqNew:clickTreeParentItem(wnd)
    if not wnd then
        return
    end
    self.nGemTypeId = wnd:getID()
    self:refreshOpenParentItem(self.treeView,self.nGemTypeId)

end

function WorkshopXqNew:clickTreeChildItem(wnd)
     if not wnd then
        return
    end
    local nAddId = wnd.cellGem.imageAdd:getID()
    if nAddId > 0 then
        local nItemId = nAddId
        local Openui = require("logic.openui")
        Openui.OpenUI(Openui.eUIId.shanghui_01,nItemId)
        return
    end

    self.nCellGemSelId = wnd:getID()
    if self.bTihuan then
        self:HandlBtnClickedTihuan()
    else
        self:HandlBtnClickedXiangqian()
    end
end



--刷新装备属性信息
function WorkshopXqNew:RefreshRichBox(bUseLocal)
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
    local bNoNaijiu = true
    local bFujiaOneLine = true
	local bHaveData,strParseText = WorkshopHelper.GetMapPropertyWithEquipData(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine)
	if bHaveData then
		self.richBoxEquip:Clear()
		self.richBoxEquip:show()
		self.richBoxEquip:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip:Refresh()
	end
end

--刷新宝石栏锁住状态
function WorkshopXqNew:RefreshGemBoxLockState()
    local equipData = self:GetCurEquipData()
	if not equipData then
		return false
	end
	for nIndex=1,#self.vButtonBox do 
		--local box = self.vButtonBox[nIndex]
		local bUnlock = self:IsUnlockGemBox(equipData,nIndex)
		self:SetGemBoxLockState(nIndex,bUnlock)
	end
end
 
--刷新宝石栏内容
function WorkshopXqNew:RefreshGemBoxContent()
	
	for nIndex=1,#self.vButtonBox do 
		--local box = self.vButtonBox[nIndex]
		local nGemId = self:GetGemIdInEquip(nIndex)
		if nGemId ~= -1 then
			self:RefreshGemBoxWithGemId(nIndex,nGemId)
		else
			self:SetCanXqState(nIndex)
		end
	end
end



function WorkshopXqNew:GetOpenLevelInGemBoxIndex_pointCard(equipData,nIndexBox)
    local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipAttrCfg then
		return -1
	end 
    local nPointCardXqKey = itemAttrCfg.level
    local pointCardXQTable = BeanConfigManager.getInstance():GetTableByName("item.cpointcardequipgem"):getRecorder(nPointCardXqKey)
    if not pointCardXQTable then
		  return -1
	end 

	local nGemBoxLevelNum = pointCardXQTable.vgemboxlevel:size()
	local nOpenLevel =-1
	for nIndex=1,nGemBoxLevelNum do 
		if nIndex==nIndexBox then
			nOpenLevel = pointCardXQTable.vgemboxlevel[nIndex-1]
		end
	end
	return nOpenLevel
end

function WorkshopXqNew:GetOpenLevelInGemBoxIndex(equipData,nIndexBox)
    
    if IsPointCardServer() then
        return self:GetOpenLevelInGemBoxIndex_pointCard(equipData,nIndexBox)
    end

	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipAttrCfg then
		return -1
	end 
	local nGemBoxLevelNum = equipAttrCfg.vgemboxlevel:size()
	local nOpenLevel =-1
	for nIndex=1,nGemBoxLevelNum do 
		if nIndex==nIndexBox then
			nOpenLevel = equipAttrCfg.vgemboxlevel[nIndex-1]
		end
	end
	return nOpenLevel
	
end

--是否解锁宝石栏
function WorkshopXqNew:IsUnlockGemBox(equipData,nIndexBox) --same in manager
     return require("logic.workshop.workshopmanager").getInstance():IsUnlockGemBox(equipData,nIndexBox)
end

--点击宝石栏
function WorkshopXqNew:HandleBtnClickedGemBox(e)
	--nId
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local nBoxIndex = mouseArgs.window.nId --自定义属性nId
    self:RefreshRightGem(nil, true)
	self.nGemBoxIndex = nBoxIndex --1，2
	self:RefreshGemBoxSel() 
	self.bGemListPaneShow = false
	--self:RefreshRightGem(true)
	self:RefreshTihuanBtnState()
end

--刷新替换按钮状态
function WorkshopXqNew:RefreshTihuanBtnState()
    local equipData = self:GetCurEquipData()
	if not equipData then
		return false
	end

	local bUnlock = self:IsUnlockGemBox(equipData,self.nGemBoxIndex)
	local bTihuan = false
	if bUnlock then
		local nGemId = self:GetGemIdInEquip(self.nGemBoxIndex)
		if nGemId~=-1 then
			bTihuan = true
		end
	end
    self.bTihuan = bTihuan
end

--刷新宝石栏选中状态
function WorkshopXqNew:RefreshGemBoxSel()
	local equipData = self:GetCurEquipData()
	if not equipData then
		return false
	end

	for nIndex=1,#self.vButtonBox do 
		local btnBox = self.vButtonBox[nIndex]
		local bUnlock = self:IsUnlockGemBox(equipData,nIndex)
		self:SetGemBoxLockState(nIndex,bUnlock)
		if self.nGemBoxIndex == nIndex then
			btnBox.btnBg:setSelected(true)
		else
			btnBox.btnBg:setSelected(false)
		end
	end
end

--设置可镶嵌状态
function WorkshopXqNew:SetCanXqState(nIndexBox)
	self.vButtonBox[nIndexBox].itemCell:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithId(self.vButtonBox[nIndexBox].itemCell,0)

	local strCanXqzi = MHSD_UTILS.get_resstring(2754) --可镶嵌
	self.vButtonBox[nIndexBox].labelGemName:setText(strCanXqzi)
	self.vButtonBox[nIndexBox].labelGemEffect:setText("")
	self.vButtonBox[nIndexBox].imageJiaohao:setVisible(true)
    self.vButtonBox[nIndexBox].btnDownGem:setVisible(false)
	
end
 
--取装备身上宝石id
function WorkshopXqNew:GetGemIdInEquip(nIndex)--1,2
	local equipData = self:GetCurEquipData()
	if not equipData then
		return false
	end
	local equipObj = equipData:GetObject()
	local vGemIdInEquip = equipObj:GetGemlist()
	local ncIndex = nIndex -1
	if ncIndex >= vGemIdInEquip:size() then --0,1,2
		return -1
	end
	local nGemId = vGemIdInEquip[ncIndex]
	return nGemId
end

--刷新宝石栏内容显示
function WorkshopXqNew:RefreshGemBoxWithGemId(nIndexBox,nGemId)
	--self.vButtonBox[nIndexBox].btnBg 
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nGemId)
	if not itemAttrCfg then
		return
	end
	local gemEffectCfg = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nGemId)
	if not gemEffectCfg then
		return
	end
	local strEffect = gemEffectCfg.effectdes --gemconfig.inlayeffect
	self.vButtonBox[nIndexBox].itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(self.vButtonBox[nIndexBox].itemCell,itemAttrCfg.id)

	self.vButtonBox[nIndexBox].labelGemName:setText(itemAttrCfg.name)
	self.vButtonBox[nIndexBox].labelGemEffect:setText(strEffect)
	self.vButtonBox[nIndexBox].imageJiaohao:setVisible(false)
    self.vButtonBox[nIndexBox].btnDownGem:setVisible(true)

end

--设置宝石栏锁住状态
function WorkshopXqNew:SetGemBoxLockState(nIndexBox,bUnLock)
	if bUnLock then
		self.vButtonBox[nIndexBox].btnBgLock:setVisible(false)
		self.vButtonBox[nIndexBox].btnBg:setVisible(true)
	else 
		self.vButtonBox[nIndexBox].btnBgLock:setVisible(true)
		self.vButtonBox[nIndexBox].btnBg:setVisible(false)
	end
	
end

function WorkshopXqNew:IsHaveCanXqGem(equipData)
    return require("logic.workshop.workshopmanager").getInstance():IsHaveCanXqGem(equipData)
end

--取可镶嵌所有宝石
function WorkshopXqNew:GetCanXqGemIdArray(equipData,vGemIdKey,nSelGemType)

    local nOrderKeyWeight = {}
	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local vGemKey = {}
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	vGemKey = roleItemManager:GetItemKeyListByType(vGemKey,eItemType_GEM, fire.pb.item.BagTypes.BAG)
	for i = 0, vGemKey:size() - 1 do
		local baggem = roleItemManager:FindItemByBagAndThisID(vGemKey[i], fire.pb.item.BagTypes.BAG)
		if baggem then
			local nGemId = baggem:GetObjectID()
			
			local bMatch = self:IsGemMatchItem(nGemId,nEquipId,nSelGemType)
			if bMatch==true then
				vGemIdKey[#vGemIdKey +1 ] =  vGemKey[i]
                local nItemKeyInBag = vGemKey[i]
                nOrderKeyWeight[nItemKeyInBag] = baggem:GetBaseObject().level
			end
		end
	end
    -------------------------------
    table.sort(vGemIdKey, function (v1, v2)

		local nOrderWeight1 = nOrderKeyWeight[v1]
		local nOrderWeight2 = nOrderKeyWeight[v2]
		return nOrderWeight1 < nOrderWeight2
	end)
end

--//刷新右侧宝石相关
function WorkshopXqNew:RefreshRightGem(bKeepOldTypeOpen, needAni)
    --bKeepOldTypeOpen = false
    if not bKeepOldTypeOpen then
        self.nCellGemSelId = -1 --宝石key 归位
    end

    self:RefreshGemListVisible()
	self:RefreshGemTypeList(bKeepOldTypeOpen, needAni)

    self:RefreshEquipPosLabel()
end

--宝石列表显示隐藏
function WorkshopXqNew:RefreshGemListVisible()
    self.PaneGem:setVisible(false)
	self.PaneShow:setVisible(true)
end

function WorkshopXqNew:GetCurEquipId()
	local equipData = self:GetCurEquipData()
	if not equipData then
		return -1
	end
	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	return nEquipId
end

--刷新装备部位提示
function WorkshopXqNew:RefreshEquipPosLabel()
	local nEquipId = self:GetCurEquipId()
	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipAttrCfg then
		return 
	end --vgemtype
	local eequiptype = equipAttrCfg.eequiptype --装备部件类型 
	local equipPosNameCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipposname"):getRecorder(eequiptype)
	if not equipPosNameCfg or equipPosNameCfg.id == -1 then
		return 
	end


	local strPosName = equipPosNameCfg.strname
	local nLevelLimit =  Workshopmanager.getInstance():getCanXqGemLevelMax(nEquipId) --equipAttrCfg.gemsLevel --装备可镶嵌宝石等级上限
	local strEquipPoszi = MHSD_UTILS.get_resstring(11008) --武器部位可镶嵌:
	local strEquipLevelzi = MHSD_UTILS.get_resstring(11009)
	local strBuild = StringBuilder:new()
	strBuild:Set("parameter1", strPosName)
	self.labEquipPosName:setText(strBuild:GetString(strEquipPoszi))
	strBuild:delete()
	local strBuild2 = StringBuilder:new()
	strBuild2:Set("parameter1", nLevelLimit)
	self.labEquipXqGemMaxLevel:setText(strBuild2:GetString(strEquipLevelzi))
	strBuild2:delete()

    if nLevelLimit==0 then
        strEquipLevelzi = MHSD_UTILS.get_resstring(11398)
        self.labEquipXqGemMaxLevel:setText(strEquipLevelzi)
    end
end

function WorkshopXqNew:GetLayoutFileName()
	return "workshopxqnew.layout"
end
function WorkshopXqNew.DestroyDialog()
	if not _instance then
		return
	end
	if _instance.m_LinkLabel then
        if _instance.m_aniopen then
            local aniMan = CEGUI.AnimationManager:getSingleton()
            aniMan:destroyAnimationInstance(_instance.m_aniopen)
        end
        _instance.m_LinkLabel:OnClose()
	else
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function WorkshopXqNew:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		v:DestroyDialog()
        self.vItemCellEquip[k] = nil
	end
    self.vItemCellEquip = {}
end


function WorkshopXqNew:ClearAllCellGem()
	for k, v in pairs(self.vCellGem) do
		v:DestroyDialog()
        self.vCellGem[k] = nil
	end
    self.vCellGem = {}
end

function WorkshopXqNew:ClearAllGemTypeCell()

	for k, v in pairs(self.vGemTypeCell) do
	    if v then
            local parentLayout = v:getParent()
            if parentLayout then
                parentLayout:removeChildWindow(v)
                CEGUI.WindowManager:getSingleton():destroyWindow(v)
            end
        end
        self.vGemTypeCell[k] = nil
	end
    self.vGemTypeCell = {}
    
end


function WorkshopXqNew:OnClose()
    if gGetRoleItemManager() then
        gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
    end

	self:ClearCellAll()
	self:ClearAllCellGem()
	
	Dialog.OnClose(self)
	self:ClearData()
	_instance = nil
end

function WorkshopXqNew:ClearData()
	self.m_LinkLabel = nil
	self.vItemCellEquip = {}
	self.nCellGemSelId = -1
	self.nItemCellSelId = 0
	self.vButtonBox = {}
	self.vCellGem = {}
	self.nGemBoxIndex = 0
	self.nGemTypeId = 0
	self.bGemListPaneShow = false
    self.bTihuan = false
    self.vGemTypeCell = {}
    self.treeView = nil
end


function WorkshopXqNew:new()
	LogInsane("new WorkshopXqNew Instance")
	local self = {}
	self = Dialog:new()
	setmetatable(self, WorkshopXqNew)
	self:ClearData()
	return self
end

return WorkshopXqNew

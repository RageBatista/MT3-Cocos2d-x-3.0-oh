require "logic.dialog"
require "utils.commonutil"

Taskcommititemdialog = {}
setmetatable(Taskcommititemdialog, Dialog)
Taskcommititemdialog.__index = Taskcommititemdialog
local _instance


Taskcommititemdialog.eCommitType = 
{
	eScenario =1,
	eRepeat =2,
	eFuben =3,
}

function Taskcommititemdialog:OnCreate()
	Dialog.OnCreate(self)
	--SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.scrollPane = CEGUI.toScrollablePane(winMgr:getWindow("renwuwupinshangjiao_mtg/textbg/list"))
	self.btnUse = winMgr:getWindow("renwuwupinshangjiao_mtg/btnshangjiao")
	self.btnUse:subscribeEvent("MouseClick", self.HandleClickedUse, self)
	
	local  mainFrame = self:GetMainFrame()
	local size = CEGUI.System:getSingleton():getGUISheet():getPixelSize()
	local offsetx = size.width*0.45
	local offsety = size.height*0.2
	
    local bgSize = mainFrame:getPixelSize()
    local nPosX = size.width - 50 - bgSize.width
    
	local p = CEGUI.UVector2(CEGUI.UDim(0, nPosX), CEGUI.UDim(0, offsety))
	local s = mainFrame:getPixelSize()
	local scale = mainFrame:getScale()
	
	mainFrame:setPosition(p)
	
	local closeBtn=CEGUI.toPushButton(mainFrame:getCloseButton())
	closeBtn:subscribeEvent("MouseClick",Taskcommititemdialog.HandleClickedClose,self)
	
end

function Taskcommititemdialog:setDelegateTarget(target,targetCallback)
    self.delegateTarget = target
    self.targetCallback= targetCallback
end

function Taskcommititemdialog:clickUse_scenario()
	local nNpcKey = self.nNpcKey 
		local nTaskTypeId = self.nTaskTypeId
		local nOptionId = 0
		
		--LogInfo("Taskhelperscenario.HandleClickedUse=nTaskTypeId="..nTaskTypeId)
		--LogInfo("Taskhelperscenario.HandleClickedUse=nNpcKey="..nNpcKey)
		--LogInfo("Taskhelperscenario.HandleClickedUse=nOptionId="..nOptionId)
		GetTaskManager():CommitScenarioQuest(nTaskTypeId,nNpcKey,nOptionId)
		--GetTaskManager():CommitScenarioQuest(nTaskTypeId,self.nNpcKey,nOptionId)
		self:DestroyDialog()
end



function Taskcommititemdialog:isOverBlue()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local nItemKey = self.nCurItemKey
    local roleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.BAG)
    if not roleItem then
        return false
    end

    local itemTable = roleItem:GetBaseObject()
    local nItemType = itemTable.itemtypeid
	local nFirstType = require("utils.mhsdutils").GetItemFirstType(nItemType)
	if nFirstType ~= eItemType_EQUIP then
        return false
    end

    if itemTable.nquality >= 4 then --3=blue 
        return true
    end
    return false
end



function Taskcommititemdialog:showConfirmCommitItemOverBlue()
    local strMsg = require "utils.mhsdutils".get_msgtipstring(166056)
	local msgManager = gGetMessageManager()
    
	gGetMessageManager():AddConfirmBox(eConfirmNormal,
	strMsg,
	Taskcommititemdialog.clickConfirmBoxOk_commititem,
	Taskcommititemdialog,
	Taskcommititemdialog.clickConfirmBoxCancel_commititem,
	Taskcommititemdialog)
end

function Taskcommititemdialog.clickConfirmBoxOk_commititem()
    if _instance then
        _instance:sendCommitItem()
    end
    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Taskcommititemdialog.clickConfirmBoxCancel_commititem()

    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Taskcommititemdialog:clickUse_repeat()
    local bOverBlue = self:isOverBlue()
    if bOverBlue then
        self:showConfirmCommitItemOverBlue()
        return 
    end
    self:sendCommitItem()
end

function Taskcommititemdialog:sendCommitItem()
	    local Taskhelpertable = require "logic.task.taskhelpertable"
		local nNpcKey = self.nNpcKey 
		local nTaskTypeId =  self.nTaskTypeId
		local submitUnit  = require "protodef.rpcgen.fire.pb.npc.submitunit":new()
		local nItemKey = self.nCurItemKey
		submitUnit.key = nItemKey
		local nNum =  Taskhelpertable.GetSchoolNeedNum(nTaskTypeId)
		if nNum <1 then
			nNum = 1
		end
		submitUnit.num = nNum
		local p = require "protodef.fire.pb.npc.csubmit2npc":new()
		p.questid = nTaskTypeId
		p.npckey = nNpcKey
		p.submittype = 1 --1=item 2=pet
		p.things[1] = submitUnit
		require "manager.luaprotocolmanager":send(p)
		LogInfo("Taskcommititemdialog:HandleClickedUse(e)=nTaskTypeId"..nTaskTypeId)
		LogInfo("Taskcommititemdialog:HandleClickedUse(e)=nNum"..nNum)
		LogInfo("Taskcommititemdialog:HandleClickedUse(e)=nNpcKey"..nNpcKey)

        self:DestroyDialog()
end

function Taskcommititemdialog:clickUse_fuben()
	LogInfo("Taskcommititemdialog:clickUse_fuben(e)=nTaskTypeId")

	--local Taskhelpertable = require "logic.task.taskhelpertable"
		local nNpcKey = self.nNpcKey 
		local nTaskTypeId =  self.nTaskTypeId
		local submitUnit  = require "protodef.rpcgen.fire.pb.npc.submitunit":new()
		local nItemKey = self.nCurItemKey
		submitUnit.key = nItemKey
		local nNum =  self.nCommitNum 
		if nNum <1 then
			nNum = 1
		end
		submitUnit.num = nNum
		local p = require "protodef.fire.pb.npc.csubmit2npc":new()
		p.questid = nTaskTypeId
		p.npckey = nNpcKey
		p.submittype = 22 --1=item 2=pet 22=gonghui fuben
		p.things[1] = submitUnit
		require "manager.luaprotocolmanager":send(p)
		
		LogInfo("Taskcommititemdialog:HandleClickedUse(e)=nTaskTypeId"..nTaskTypeId)
		LogInfo("Taskcommititemdialog:HandleClickedUse(e)=nNum"..nNum)
		LogInfo("Taskcommititemdialog:HandleClickedUse(e)=nNpcKey"..nNpcKey)

		self:DestroyDialog()
end

function Taskcommititemdialog:HandleClickedUse(e)
	if self.nCommitType==1 then --1-main task
		--LogInfo("Taskhelperscenario.HandleClickedUse=nNpcKey="..self.nNpcKey)
		self:clickUse_scenario()
	elseif self.nCommitType==Taskcommititemdialog.eCommitType.eRepeat then
		self:clickUse_repeat()
	elseif self.nCommitType==Taskcommititemdialog.eCommitType.eFuben then
		self:clickUse_fuben()
    else
	end
    if self.delegateTarget and self.targetCallback then
        self.targetCallback(self.delegateTarget,self)
       
    end
    
    require("logic.tips.commontipdlg").DestroyDialog()
end

function Taskcommititemdialog:HandleClickedClose(e)
	self:DestroyDialog()
    require("logic.tips.commontipdlg").DestroyDialog()
    require("logic.tips.equipinfotips").DestroyDialog()
end
	
function Taskcommititemdialog:SetCommitItemId_scenario(nItemId,nNpcKey,nCommitType,nTaskTypeId)
	self.nTaskTypeId = nTaskTypeId
	self.nCommitType = nCommitType
	self.nNpcKey = nNpcKey
	
	local vItemId = {}
	vItemId[#vItemId +1] = nItemId
	self:SetCommitItemId_allTypeItem(vItemId,nNpcKey,nCommitType)
end

function Taskcommititemdialog:GetBagIdWithItemId(nItemId)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return -1
	end
	local nItemTypeId = itemAttrCfg.itemtypeid
	
	local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemTypeId)
	local nBagType = -1
	if nFirstType==eItemType_TASKITEM then
		nBagType = fire.pb.item.BagTypes.QUEST
	else
		nBagType = fire.pb.item.BagTypes.BAG
	end
	return nBagType
end

function Taskcommititemdialog:GetRoleItem(nItemId)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local bBindPrior = false
	local nBagId = self:GetBagIdWithItemId(nItemId)
	local pItem = roleItemManager:GetItemByBaseID(nItemId,bBindPrior,nBagId)
	return pItem
	
end

--//main task use
function Taskcommititemdialog:SetCommitItemId_allTypeItem(vItemId,nNpcKey,nCommitType,nTaskTypeId) ----//1 mainmiss 2=school
	
	self.scrollPane:cleanupNonAutoChildren()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local nOriginX = 20
	local nOriginY = 10
	local nItemCellW = 94
	local nItemCellH = 94
	local nSpaceX = 10
	local nSpaceY = 20
	local nRowCount = 5
	
    local pObj = nil
	local nItemIdTip = 0
	for nIndex=1,#vItemId do
		
		local nItemId = vItemId[nIndex]
		local pRoleItem = self:GetRoleItem(nItemId) --require("logic.item.roleitemmanager").getInstance():FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.BAG)
		if  pRoleItem then
			local strName = "cellname"..tostring(nIndex)
			local itemCell =  CEGUI.toItemCell(winMgr:createWindow("TaharezLook/ItemCell",strName))
			local nPosX,nPosY = TaskHelper.GetPos(nIndex-1,nRowCount,nOriginX,nOriginY,nItemCellW,nItemCellH,nSpaceX,nSpaceY)
			itemCell:setSize(CEGUI.UVector2(CEGUI.UDim(0,nItemCellW), CEGUI.UDim(0,nItemCellH)))
			itemCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0,nPosX),CEGUI.UDim(0,nPosY)))
            local nQuality = pRoleItem:GetBaseObject().nquality
            SetItemCellBoundColorByQulityItem(itemCell, nQuality, pRoleItem:GetItemTypeID())
            local nBagId = pRoleItem:GetObject().loc.tableType
            refreshItemCellBind(itemCell,nBagId,pRoleItem:GetObject().data.key)
            local level = Commontiphelper.getItemLevelValue(pRoleItem:GetObjectID(), pRoleItem:GetObject())
            itemCell:SetTextUnit(level > 0 and "" .. level or "")
			self.scrollPane:addChildWindow(itemCell)
			--local nItemId = pRoleItem:GetObjectID()
			itemCell:setID(nItemId)
			local nNum = pRoleItem:GetNum()
            if nNum > 1 then
			    itemCell:SetTextUnit(tostring(nNum))
            end
		
			itemCell:subscribeEvent("MouseClick", Taskcommititemdialog.HandleCellClicked, self)
			local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
			if itemAttrCfg then
				itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
			end
			local nItemKey = pRoleItem:GetThisID()
			itemCell.nItemKey = nItemKey
			self.vItemCell[nIndex] = itemCell
			if self.nCurItemKey==-1 then
				self.nCurItemKey = nItemKey
			end
				
			if nIndex==1 then
				nItemIdTip = nItemId
                pObj = pRoleItem:GetObject()
			end
		end
	end
		
	local nPosXTip,nPosYTip = self:GetRightPos()
	self:ShowTip(nItemIdTip,nPosXTip,nPosYTip,pObj)
	
	self:RefreshItemCellSel()
	
end

function Taskcommititemdialog:GetRightPos()
	local  mainFrame = self:GetMainFrame()
	local  nodePos = mainFrame:getPosition()
	local btnWidth = mainFrame:getPixelSize().width
	local btnHeight = mainFrame:getPixelSize().height
	local nNodePosX = nodePos.x.offset + btnWidth
	local nNodePosY = nodePos.y.offset + 60
	return nNodePosX,nNodePosY
end

--repeat task fuben task item in bag
function Taskcommititemdialog:SetCommitItemId(vItemKey,nNpcKey,nCommitType,nTaskTypeId,nCommitNum) ----//1 mainmiss 2=school
	
	self.nTaskTypeId = nTaskTypeId
	self.nCommitType = nCommitType--//1 mainmiss 2=school 3=fuben
	self.nNpcKey = nNpcKey
	self.vItemKey = vItemKey
    self.nCommitNum = nCommitNum
	
	self.scrollPane:cleanupNonAutoChildren()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local nOriginX = 18
	local nOriginY = 8
	local nItemCellW = 84
	local nItemCellH = 84
	local nSpaceX = 10
	local nSpaceY = 18
	local nRowCount = 4
	
	local nItemIdTip = 0

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	table.sort(vItemKey, function(v1, v2)
		local item1 = roleItemManager:FindItemByBagAndThisID(v1, fire.pb.item.BagTypes.BAG)
		local item2 = roleItemManager:FindItemByBagAndThisID(v2, fire.pb.item.BagTypes.BAG)

		local q1 = require "logic.tips.commontiphelper".getItemQuality(item1)
		local q2 = require "logic.tips.commontiphelper".getItemQuality(item2)

		if q1 < q2 then
			return true
		end
	end)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	
	for nIndex=1,#vItemKey do
		local nItemKey = vItemKey[nIndex]
		local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.BAG)
		local strName = "cellname"..tostring(nIndex)
		local itemCell =  CEGUI.toItemCell(winMgr:createWindow("TaharezLook/ItemCell",strName))
		
		local nPosX,nPosY = TaskHelper.GetPos(nIndex-1,nRowCount,nOriginX,nOriginY,nItemCellW,nItemCellH,nSpaceX,nSpaceY)
		
		itemCell:setSize(CEGUI.UVector2(CEGUI.UDim(0,nItemCellW), CEGUI.UDim(0,nItemCellH)))
		itemCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0,nPosX),CEGUI.UDim(0,nPosY)))
        local nQuality = pRoleItem:GetBaseObject().nquality
        SetItemCellBoundColorByQulityItem(itemCell, nQuality, pRoleItem:GetItemTypeID())
        local level = Commontiphelper.getItemLevelValue(pRoleItem:GetObjectID(), pRoleItem:GetObject())
        itemCell:SetTextUnit(level > 0 and "" .. level or "")
        refreshItemCellBind(itemCell,pRoleItem:GetObject().loc.tableType,pRoleItem:GetObject().data.key)
		self.scrollPane:addChildWindow(itemCell)
		
		local nItemId = pRoleItem:GetObjectID()
		itemCell:setID(nItemId)
		local nNum = pRoleItem:GetNum()
        if nNum > 1 then
		    itemCell:SetTextUnit(tostring(nNum))
        end
		itemCell:subscribeEvent("MouseClick", Taskcommititemdialog.HandleCellClicked, self)
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
		if itemAttrCfg then
			itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
		end
		itemCell.nItemKey = nItemKey
		self.vItemCell[nIndex] = itemCell
		if self.nCurItemKey==-1 then
			self.nCurItemKey = nItemKey
		end
		
		if nIndex==1 then
			nItemIdTip = nItemId
		end
	end
	
	local nBagId = self:GetBagIdWithItemId(nItemIdTip)
	local nItemKey = self.nCurItemKey
	local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	if not pRoleItem then
		return 
	end
	
	local pObj = pRoleItem:GetObject()
	
	local nPosXTip,nPosYTip = self:GetRightPos()
	self:ShowTip(nItemIdTip,nPosXTip,nPosYTip,pObj)
	self:RefreshItemCellSel()
end

function Taskcommititemdialog:HandleCellClicked(e)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
    self.nCurItemKey = clickWin.nItemKey
	local nItemId = e.window:getID()
	--local touchPos = e.position
	local nBagId = self:GetBagIdWithItemId(nItemId)
	local nItemKey = self.nCurItemKey
	local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	if not pRoleItem then
		return 
	end
	
	local pObj = pRoleItem:GetObject()
	local nPosXTip,nPosYTip = self:GetRightPos()
	self:ShowTip(nItemId,nPosXTip,nPosYTip,pObj)
	self:RefreshItemCellSel()
end


function Taskcommititemdialog:showEquipTip(nItemId,nPosX,nPosY,pObj)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local nBagId = self:GetBagIdWithItemId(nItemId)
	    local nItemKey = self.nCurItemKey
	    local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	    if not pRoleItem then
		    return 
	    end
        local pItem = pRoleItem
        local bShowBtn = false
        local winMgr = CEGUI.WindowManager:getSingleton()
		local m_pLeft = CEGUI.toPushButton(winMgr:getWindow("ItemTips/delete"))
		local m_pRight = CEGUI.toPushButton(winMgr:getWindow("ItemTips/use"))
        local m_pMiddle = CEGUI.toPushButton(winMgr:getWindow("ItemTips/back/btnhuodetujing"))
	    m_pLeft:setVisible(false)
	    m_pRight:setVisible(false)
        m_pMiddle:setVisible(false)
        --=============
        local strCompareDlgName = "CEquipTipCompareDlg".."ItemTips/back";
        local m_pCompareDlg = winMgr:getWindow(strCompareDlgName)
        if m_pCompareDlg then
             m_pCompareDlg:setVisible(false)
        end
        --==============
     self:refreshEquipTipPos()
end

function Taskcommititemdialog:refreshEquipTipPos()
    local winMgr = CEGUI.WindowManager:getSingleton()
    local strCompareDlgName = "ItemTips/back";
    local m_pCompareDlg = winMgr:getWindow(strCompareDlgName)

     local commontipdlg  = m_pCompareDlg 
	local mainFrame = self:GetMainFrame()
	local tipWidth = commontipdlg:getPixelSize().width
	local tipPosOld  = mainFrame:getPosition()
	local tipPos = CEGUI.UVector2(CEGUI.UDim(tipPosOld.x.scale, tipPosOld.x.offset-tipWidth), CEGUI.UDim(tipPosOld.y.scale, tipPosOld.y.offset))
	commontipdlg:setPosition(tipPos)
end



function Taskcommititemdialog:ShowTip(nItemId,nPosX,nPosY,pObj)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end

    local nItemType = itemAttrCfg.itemtypeid
    local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType)

	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eNormal
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY,pObj)
	
	self:ResetTipPos()
end

function Taskcommititemdialog:ResetTipPos()
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local mainFrame = self:GetMainFrame()
	--local  nodePos = mainFrame:getPosition()
	local tipWidth = commontipdlg:GetMainFrame():getPixelSize().width
	local tipPosOld  = mainFrame:getPosition()
	local tipPos = CEGUI.UVector2(CEGUI.UDim(tipPosOld.x.scale, tipPosOld.x.offset-tipWidth), CEGUI.UDim(tipPosOld.y.scale, tipPosOld.y.offset))
	commontipdlg:GetMainFrame():setPosition(tipPos)
    commontipdlg:DisableBtn()
end

function Taskcommititemdialog:RefreshItemCellSel()
	for k,itemCell in pairs(self.vItemCell) do 
		local nItemKey = itemCell.nItemKey
		if self.nCurItemKey == nItemKey then
			itemCell:SetSelected(true)
		else
			itemCell:SetSelected(false)
		end
	end
end

--//==============================
function Taskcommititemdialog:GetLayoutFileName()
	return "renwuwupinshangjiao.layout"
end

function Taskcommititemdialog.getInstance()
	if _instance == nil then
		_instance = Taskcommititemdialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Taskcommititemdialog.getInstanceNotCreate()
	return _instance
end

function Taskcommititemdialog.getInstanceOrNot()
	return _instance
end


function Taskcommititemdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Taskcommititemdialog)
	self:ClearData()
	return self
end

function Taskcommititemdialog:DestroyDialog()
	self:OnClose()
end

function Taskcommititemdialog:ClearData()
	self.nNpcKey = -1
	self.vItemCell = {}
	self.nCurItemKey = -1

    self.delegateTarget = nil
    self.targetCallback= nil

end

function Taskcommititemdialog:ClearDataInClose()
	self.nNpcKey = -1
	self.vItemCell = nil
	self.nCurItemKey = -1
end

function Taskcommititemdialog:OnClose()
	Dialog.OnClose(self)
	self:ClearDataInClose()
	_instance = nil
end

return Taskcommititemdialog


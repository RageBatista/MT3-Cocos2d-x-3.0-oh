require "logic.dialog"
require "logic.workshop.workshophelper"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "logic.workshop.workshopdznewcell"
require "logic.workshop.workshopdzpreview"
require "logic.workshop.workshopitemcell3"
require "logic.workshop.workshopmanager"


WorkshopDzNew = {}
setmetatable(WorkshopDzNew, Dialog)
WorkshopDzNew.__index = WorkshopDzNew
local _instance


function WorkshopDzNew:RefreshItemTips(item)
end
--//������
function WorkshopDzNew.OnDzResult(protocol)
	--int maketype; // typeΪ1�����Ǵ������ɵ���Ʒ��Ϊ2����ҩ���ɵ�ҩƷ��Ϊ3��������⿳ɹ���ʳƷ
	--int itemkey;
	if not _instance then
		return
	end
	local xlDlg = require "logic.workshop.workshopxlnew"
	xlDlg.OnDzResult()
	local xqDlg = require "logic.workshop.workshopxqnew"
	xqDlg.OnDzResult()
	local xilDlg = require "logic.workshop.workshopxilian"
	xilDlg.OnDzResult()
	local aqDlg = require "logic.workshop.workshopaq"
	aqDlg.OnDzResult()
	local nItemKey = protocol.itemkey

    _instance:RefreshEquipScrollData()
	_instance:RefreshEquipScrollState()
	_instance:RefreshItemCellSel()
	_instance:RefreshRight()

	_instance:checkForShowZhenPin(nItemKey)

	-- ����װ������ GameCenter �ɾ͵÷�
	if protocol.maketype == 1 then
		if GameCenter:GetInstance() then
                  local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
                  if manager then
                      if manager.m_isPointCardServer then
                           GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId_DK.DK_MakeEquipment, 20);
                      else
                            GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId.MakeEquipment, 20);
                      end
                  end
		end
	end
	
end

function WorkshopDzNew:checkForShowZhenPin(nItemKey)
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
				
	local eBagType = fire.pb.item.BagTypes.BAG
	local roleItem = roleItemManager:FindItemByBagAndThisID(nItemKey,eBagType)
	if not roleItem then
		return
	end
	
		local itemAttrCfg = roleItem:GetBaseObject()
		local nItemId = itemAttrCfg.id
		
		local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nItemId)
		if equipAttrCfg then
			local equipObj = roleItem:GetObject()

			local nCurScore = 0 
            if equipObj then
               nCurScore = equipObj.equipscore 
            end
			
			if nCurScore > equipAttrCfg.treasureScore then
				local strZhenPin = require("utils.mhsdutils").get_msgtipstring(160112)
				GetCTipsManager():AddMessageTip(strZhenPin)
			end
		end
		
end

function WorkshopDzNew.OnMakeEquip(nType) --1=normal 2=qiangha
	if not _instance then
		return
	end
	_instance:OnMakeEquip(nType)
end


function WorkshopDzNew.RefreshLevelArea(nLevelArea)
	if not _instance then
		return
	end
	_instance:RefreshLevelArea(nLevelArea)
end

function WorkshopDzNew.closeForBeside()
	if not _instance then
		return
	end
	_instance:closeForBeside()
end

function WorkshopDzNew:closeForBeside()
	self.bLevelTipOpen = false
	self:RefreshLevelBtn()
end

function WorkshopDzNew:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	self:InitEquipItem(winMgr)
	self:InitMaterial(winMgr)
	self.nCurLevelArea = self:GetRoleLvelArea()
	
	--[[
	self:RefreshEquipScroll()
	self:RefreshLevelBtn(false)
	self:RefreshItemCellSel()
	self:RefreshRight()
	--]]
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(WorkshopDzNew.OnMoneyChange)
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(WorkshopDzNew.OnItemNumChange)

    self.handle_AddBagItem = gGetRoleItemManager().m_EventAddPackItem:InsertScriptFunctor(WorkshopDzNew.eventAddBagItem)

end


function WorkshopDzNew.eventAddBagItem(nItemKey)
    if not _instance then
        return
       
    end
    _instance:RefreshEquipScrollData()
    _instance:RefreshEquipScrollState()
	_instance:RefreshRight()
end


function WorkshopDzNew.OnItemNumChange()
	if not _instance then
		return
	end
	_instance:RefreshRight()
end

function WorkshopDzNew.OnMoneyChange()
	if not _instance then
		return
	end
	--_instance:RefreshRight()
	_instance:RefreshMoney()
    _instance:RefreshEquipScrollData()
    _instance:RefreshEquipScrollState()
end

-- 1 10 20 30 
function WorkshopDzNew:getAreaWithItemId(nItemId)
    local nArea = -1
    if not nItemId then
        return nArea
    end
    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemTable then
		return nArea
	end
    local nLevel = itemTable.level
    return nLevel
end

function WorkshopDzNew:getSelEquipId(nItemIdCailiao,nLevelArea)
    
    if not nItemIdCailiao then
        return -1
    end

    local equipConfig = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemIdCailiao)
	if not equipConfig then
		return -1
	end

    if equipConfig.itemtypeid ~= 422 and  equipConfig.itemtypeid~=2470 then --first need item --422=tuzhi 2470=yuanshi
        return -1
    end

    local equipMakeTabAllId = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getAllID()
	for i = 1, #equipMakeTabAllId do
		local nEquipId = equipMakeTabAllId[i]
		local equipMakeInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getRecorder(nEquipId)
        if equipMakeInfoCfg.nlevel==nLevelArea then
	        if equipMakeInfoCfg and equipMakeInfoCfg.id ~= -1 then
		         if equipMakeInfoCfg.tuzhiid == nItemIdCailiao or equipMakeInfoCfg.qianghuaid==nItemIdCailiao then
                    return nEquipId
                end
	        end
        end
	end
    return -1
end

function WorkshopDzNew:RefreshUI(nItemIdCailiao,nItemKey)
    local wsManager = Workshopmanager.getInstance()
    local nEquipIdInDzSel = wsManager.nEquipIdInDzSel
    if nEquipIdInDzSel ~= -1 then
         local nArea = self:getAreaWithItemId(nEquipIdInDzSel)
         if nArea >0  then
            self.nCurLevelArea = nArea
        end
    end
    
    local nArea = self:getAreaWithItemId(nItemIdCailiao)
    if tonumber(nArea) >0  then
        self.nCurLevelArea = nArea
        local wsManager = Workshopmanager.getInstance()
        wsManager.nEquipIdInDzSel = -1
    end
	self:RefreshEquipScroll()
	self:RefreshLevelBtn()


    self:SetSelIdAtTop()
    if wsManager.nEquipIdInDzSel ~= -1 then
        self.nItemCellSelId = nEquipIdInDzSel
        self:refreshSelCellToShow()
    end
    local nSelEquipId = self:getSelEquipId(nItemIdCailiao,self.nCurLevelArea)
    if nSelEquipId~= -1 then
        self.nItemCellSelId = nSelEquipId
        self:refreshCellToTopShow(self.nItemCellSelId)
    end
	self:RefreshItemCellSel()
	self:RefreshRight()
    self:refreshMakeTarget()

   
end

function WorkshopDzNew:getEquipDataIndexWithId(nItemCellSelId)
    
    for  nIndex=1, #self.vEquipData do 
	 	local oneEquipData = self.vEquipData[nIndex]
		if oneEquipData.nEquipId == nItemCellSelId then
            return nIndex
        end
	end
end

function WorkshopDzNew:refreshCellToTopShow(nItemCellSelId)
    local nSelIndex = self:getEquipDataIndexWithId(nItemCellSelId)
    if not nSelIndex then
        return
    end
    local nOffset = (nSelIndex-1) * self.nodeCellSize.height
    self.tableView:setContentOffset(nOffset)
end

function WorkshopDzNew:refreshSelCellToShow()
    local wsManager = Workshopmanager.getInstance()
    local fOffsetPercent = wsManager.nOffsetDz

    local bar = self.tableView.scroll:getVertScrollbar()
    local docH = bar:getDocumentSize()
    local nOffsetDz = fOffsetPercent * docH
    self.tableView:setContentOffset(nOffsetDz)
end



function WorkshopDzNew:refreshCell(nIndex,cellEquipItem)

     local oneEquipData = self.vEquipData[nIndex]
     local nEquipId = oneEquipData.nEquipId
     local bCanMake = oneEquipData.bCanMake 
	 if bCanMake then 
		cellEquipItem.imageCanMake:setVisible(true)
	else
		cellEquipItem.imageCanMake:setVisible(false)
	end
    ---
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nEquipId)
    if itemAttrCfg then
		    local nEquipType = itemAttrCfg.itemtypeid
		    local strTypeName = ""
		    local itemTypeCfg = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nEquipType)
		    if itemTypeCfg then
			    strTypeName = itemTypeCfg.name
		    end
			local iconManager = gGetIconManager()
			cellEquipItem.labItemName:setText(itemAttrCfg.name)
			cellEquipItem.itemCell:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon))
			cellEquipItem.itemCell:setID(nEquipId)
			local strLevelzi = MHSD_UTILS.get_resstring(351)
			local strShowTitle = itemAttrCfg.level..strLevelzi
			cellEquipItem.labBottom1:setText(strShowTitle)
			cellEquipItem.labBottom2:setText(strTypeName)
     end

    if cellEquipItem.itemCell:getID() ~= self.nItemCellSelId then
		 cellEquipItem.btnBg:setSelected(false)
    else
        cellEquipItem.btnBg:setSelected(true)
    end
    local wsManager = Workshopmanager.getInstance()
    local bCanEauip = wsManager:isCanEquip(nEquipId)
    cellEquipItem.iamgeCanEquip:setVisible(bCanEauip)

end

function WorkshopDzNew:tableViewGetCellAtIndex(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:CreateCellWithId(tableView.container,nIndex )
    end
   
    self:refreshCell(nIndex,cell)
    return cell
end

function WorkshopDzNew:InitEquipItem(winMgr)
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("workshopdznew/liebiao/list"))

    local sizeBgA = self.ScrollEquip:getPixelSize()
    self.tableView = TableView.create(self.ScrollEquip, TableView.VERTICAL)
    self.tableView:setViewSize(sizeBgA.width, sizeBgA.height)
    self.tableView:setPosition(0, 0)
    self.tableView:setDataSourceFunc(self, WorkshopDzNew.tableViewGetCellAtIndex)

    local layoutNamegetSize = "workshopitemcell.layout"
    local strPrefix = "getsize"
	local nodeCell = winMgr:loadWindowLayout(layoutNamegetSize,strPrefix)
    self.nodeCellSize = nodeCell:getPixelSize()
    winMgr:destroyWindow(nodeCell)

	
	self.BtnSelLevel = CEGUI.toPushButton(winMgr:getWindow("workshopdznew/liebiao/level"))
	self.BtnSelLevel:subscribeEvent("Clicked", WorkshopDzNew.HandleSelLevelBtnClicked, self) --MouseClick MouseButtonUp

    self.labelLevelArea = winMgr:getWindow("workshopdznew/liebiao/level/lvwenben")
    self.labelLevelArea:setMousePassThroughEnabled(true)

	self.ImageDown = winMgr:getWindow("workshopdznew/liebiao/xuanze")
	self.ImageUp = winMgr:getWindow("workshopdznew/liebiao/xuanze2")
end

	

function WorkshopDzNew:getComeFromItemId(nIndex)
    if nIndex~=2 and nIndex~=3 then
        return -1
    end
    local nSelEquipId = self.nItemCellSelId
	local equipMakeInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getRecorder(nSelEquipId)
	if equipMakeInfoCfg == nil then
		return -1
	end
    local nComeItemId = -1
    if nIndex==2 then
        local vcItemId = equipMakeInfoCfg.vcailiaotie
        if vcItemId:size()>0 then
            nComeItemId = vcItemId[0]
        end
	elseif nIndexMaterial==3 then
        local vcItemId = equipMakeInfoCfg.vcailiaozhizaofu
        if vcItemId:size()>0 then
            nComeItemId = vcItemId[0]
        end
    end
	return nComeItemId

end


function WorkshopDzNew:HandleClickItemCell(args)
	
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position

    local nIndex = e.window.nIndex
    local nComeFromItemId = self:getComeFromItemId(nIndex)
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eComeFrom
	--nType = Commontipdlg.eType.eNormal 

	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    commontipdlg.nComeFromItemId = nComeFromItemId
end


function WorkshopDzNew:InitMaterial(winMgr)
	self.vLabItemLevel = {}
	for nIndex=1,3 do 
		self.vLabItemLevel[nIndex] = winMgr:getWindow("workshopdznew/right/bot/leveltext"..nIndex)
	end
	--local wsManager = Workshopmanager.getInstance()
	
	self.vItemCell = {}
	self.vItemLabel = {}
	for nIndexMaterial = 1, 4 do
		self.vItemCell[nIndexMaterial] = CEGUI.toItemCell(winMgr:getWindow("workshopdznew/right/bot/item"..nIndexMaterial))
		self.vItemLabel[nIndexMaterial] = winMgr:getWindow("workshopdznew/right/bot/name"..nIndexMaterial)
		self.vItemCell[nIndexMaterial]:subscribeEvent("TableClick", WorkshopDzNew.HandleClickItemCell, self)
        self.vItemCell[nIndexMaterial].nIndex = nIndexMaterial
	end
	self.BtnSelQhItem = CEGUI.toCheckbox(winMgr:getWindow("workshopdznew/right/textcase2/checkbox"))
	self.BtnSelQhItem:subscribeEvent("CheckStateChanged", WorkshopDzNew.HandlSelQhItemBtnClicked, self)
	self.BtnSelQhItem:setVisible(false)
	--self.ImageSelQhItem =  winMgr:getWindow("workshopdznew/right/gouxuankuang/gou")
	--self.ImageSelQhItem:setVisible(false)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("workshopdznew/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("workshopdznew/right/part2/item2/kedazao") 
	self.LabTargetName = winMgr:getWindow("workshopdznew/right/part2/name2") 
	self.LabTargetNamec = winMgr:getWindow("workshopdznew/right/xiaohao11") 
	self.LabTargetNamecc = winMgr:getWindow("workshopdznew/right/bot/leveltext21") 
	self.BtnLook = CEGUI.toPushButton(winMgr:getWindow("workshopdznew/right/yulan"))
	self.BtnLook:subscribeEvent("Clicked", WorkshopDzNew.HandlLookBtnClicked, self)
	self.needMoneyLabel = winMgr:getWindow("workshopdznew/right/bg1/one")
	self.ownMoneyLabel = winMgr:getWindow("workshopdznew/right/bg11/2")
	self.ImageNeedMoneyIcon = winMgr:getWindow("workshopdznew/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("workshopdznew/right/yinbi2")
	self.MakeBtn = CEGUI.toPushButton(winMgr:getWindow("workshopdznew/right/all"))
	self.MakeBtn:subscribeEvent("Clicked", WorkshopDzNew.HandlMakeBtnClicked, self)
	
	self.qiehuan1 = winMgr:getWindow("workshopdznew/qiehuan1")
	self.qiehuan1:subscribeEvent("MouseClick", WorkshopDzNew.HandleClickQieHuan1, self)
	
    self.smokeBg = winMgr:getWindow("workshopdznew/Back/flagbg/smoke")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi1", true, s.width*0.5, s.height)

	
	--workshopdznew/right/image
	--workshopdznew/right/shiyong
	self.imageTanhao = winMgr:getWindow("workshopdznew/right/tanhao")
	self.imageTanhao:subscribeEvent("MouseClick", WorkshopDzNew.HandleClickShowInfo, self)
	self.labelInfo = winMgr:getWindow("workshopdznew/right/shiyong")
	self.labelInfo:subscribeEvent("MouseClick", WorkshopDzNew.HandleClickShowInfo, self)
	
	--WorkshopHelper.SetChildNoCutTouch(self.ItemCellTarget)
	self.ItemCellTarget:setMousePassThroughEnabled(true)  --SetBackGroundEnable(false)
		
	self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("workshopdznew/right/jiahao"))
	self.BtnExchange:subscribeEvent("Clicked", WorkshopDzNew.HandleExchangeBtnClicked, self)

    self.labelMakeTargetType = winMgr:getWindow("workshopdznew/right/part2/line1/jilv/biaoti") 
    self.scrollTarget = CEGUI.toScrollablePane(winMgr:getWindow("workshopdznew/right/part2/line1/jilv/"))

    --self.scrollTarget:EnableDrag(false)
    --self.scrollTarget:SetDragMoveEnable(false)  --no register
    --self.scrollTarget:EnableVertScrollBar(false)
    --self.scrollTarget:EnableHorzScrollBar(false)
    --self.scrollTarget:setShowVertScrollbar(false)

    local scrollBat = self.scrollTarget:getVertScrollbar()
    scrollBat:EnbalePanGuesture(false)
    
    
    --EnbaleSlide(true);
    self.scrollTarget:setMousePassThroughEnabled(true) 
	
end

function WorkshopDzNew:clearAllMakeTargetCell()
    for k,v in pairs( self.vMakeTarget) do 
        v:DestroyDialog()
    end
    self.vMakeTarget = {}

end

function WorkshopDzNew:HandleClickQieHuan1(args)-----宠物装备打造
   require("logic.shengsizhan.jingmaihecheng_hs1").getInstanceAndShow()
    WorkshopDzNew.DestroyDialog()
end

function WorkshopDzNew:DestroyDialog()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

function WorkshopDzNew:refreshMakeTarget()
    self:clearAllMakeTargetCell()


    local nSelEquipId = self.nItemCellSelId
	if nSelEquipId == 0 then
		return 
	end
	local equipMakeInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getRecorder(nSelEquipId)
	if not equipMakeInfoCfg then
		return 
	end
    local equipConfig = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nSelEquipId)
	if not equipConfig then
		return
	end

   
    local vTargetItemId = {}
    local vTargetItemPercent = {}
    
    self:getTarget(vTargetItemId,vTargetItemPercent,equipMakeInfoCfg)

    for nIndex=1,#vTargetItemId do 
        local nTargetId = vTargetItemId[nIndex]
        local nTargetPer = 0
        if nIndex <=  #vTargetItemPercent then
            nTargetPer = vTargetItemPercent[nIndex]
        end
        local fPer = nTargetPer/100
        

        fPer = string.format("%.02f",fPer)
        local strPer = fPer.."%"

		local prefix = "Workshopdztargetcell"..nIndex
		local cellTarget = require("logic.workshop.workshopdztargetcell").new(self.scrollTarget, nIndex-1,prefix)

        
        cellTarget.labelPercent:setText(strPer)

        local strQualityImageName = self:getQualityIamgeName(nTargetId)

       cellTarget.imageQuality:setProperty("Image",strQualityImageName )


        self.vMakeTarget[#self.vMakeTarget + 1] = cellTarget
    end

    local nMakeType = self:getMakeType()
    local strDzTitlezi = ""
    if nMakeType == 0 then 
		strDzTitlezi = MHSD_UTILS.get_resstring(11004) 
	else
		strDzTitlezi = MHSD_UTILS.get_resstring(11005) 
	end
    self.labelMakeTargetType:setText(strDzTitlezi)

end

function  WorkshopDzNew:getQualityIamgeName(nItemId)

   local strResult = "set:jiangli image:lv"
   local equipConfig = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not equipConfig then
		return strResult
	end
   
    local nQuality = equipConfig.nquality
    if nQuality == 2 then
        strResult = "set:jiangli image:lv"
    elseif nQuality == 3 then
         strResult = "set:jiangli image:lan"
    elseif nQuality == 4 then
         strResult = "set:jiangli image:zi"
    end
    return strResult

end

function WorkshopDzNew:getMakeType()
 
    local bVisible = self.BtnSelQhItem:isSelected()
	local nMakeType = 0
	if bVisible==true then
		nMakeType = 1 --qh
	else
		nMakeType = 1
	end
    return nMakeType

end

function WorkshopDzNew:getTarget(vTargetItemId,vTargetItemPercent,equipMakeInfoCfg)
    local nMakeType = self:getMakeType()
    if nMakeType == 0 then
        for nIndex=0,equipMakeInfoCfg.vptdazhaoid:size()-1 do 
            local nTargetId = equipMakeInfoCfg.vptdazhaoid[nIndex]
            vTargetItemId[#vTargetItemId + 1] = nTargetId
        end
        for nIndex=0,equipMakeInfoCfg.vptdazhaorate:size()-1 do 
            local nTargetId = equipMakeInfoCfg.vptdazhaorate[nIndex]
            vTargetItemPercent[#vTargetItemPercent +1] = nTargetId
        end
    else
        for nIndex=0,equipMakeInfoCfg.vqhdazhaoid:size()-1 do 
            local nTargetId = equipMakeInfoCfg.vqhdazhaoid[nIndex]
            vTargetItemId[#vTargetItemId +1] = nTargetId
        end
        for nIndex=0,equipMakeInfoCfg.vqhdazhaorate:size()-1 do 
            local nTargetId = equipMakeInfoCfg.vqhdazhaorate[nIndex]
            vTargetItemPercent[#vTargetItemPercent +1] = nTargetId
        end
    end
end

function WorkshopDzNew:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)
	return true
end


function WorkshopDzNew:HandleClickShowInfo(e)
	local tips1 = require "logic.workshop.tips1"
    --tips1.getInstanceAndShow(self.m_pMainFrame)
	local strTitle = "" 
	local strContent = MHSD_UTILS.get_resstring(11025) 
	tips1.getInstanceAndShow(strContent, strTitle)
	
end

function WorkshopDzNew:RefreshLevelArea(nLevelArea)
    
    local wsManager = Workshopmanager.getInstance()
    wsManager.nEquipIdInDzSel = -1

	self.nCurLevelArea = nLevelArea
	self.bLevelTipOpen = false
	self:RefreshLevelBtn() --up=true
	self.nItemCellSelId = 0
    
	self:RefreshEquipScroll()
    self:SetSelIdAtTop()
	--self:RefreshEquipScrollState()
	self:RefreshItemCellSel()
	self:RefreshRight()
    self:refreshMakeTarget()
end


function WorkshopDzNew:HandlSelQhItemBtnClicked(e)
    local wsManager = Workshopmanager.getInstance()
	local bSel = self.BtnSelQhItem:isSelected()
	if bSel then 
        wsManager.nSelQh = 1
	else
        wsManager.nSelQh = 1
	end
	self:RefreshDzBtn()
    self:refreshMakeTarget()

    self:RefreshEquipScrollData()
    self:RefreshEquipScrollState()

end

function WorkshopDzNew:RefreshDzBtn()
	local bVisible = self.BtnSelQhItem:isSelected()
	local strDzTitlezi = ""
	if bVisible then 
		strDzTitlezi = MHSD_UTILS.get_resstring(11005) 
	else
		strDzTitlezi = MHSD_UTILS.get_resstring(11004) 
	end
	self.MakeBtn:setText(strDzTitlezi)
end

function WorkshopDzNew:RefreshLevelBtn()
	local bUp = self.bLevelTipOpen
	if bUp == true then
		self.ImageDown:setVisible(false)
		self.ImageUp:setVisible(true)
	else
		self.ImageDown:setVisible(true)
		self.ImageUp:setVisible(false)
	end
	local strLevel = MHSD_UTILS.get_resstring(351)
	local strShowTitle = self.nCurLevelArea.." "..strLevel..""
	--self.BtnSelLevel:setText(strShowTitle)
    self.labelLevelArea:setText(strShowTitle)
end

function WorkshopDzNew:GetRoleLvelArea()
	local nLevelSpace = 10
	local nUserLevel = gGetDataManager():GetMainCharacterLevel()
	local  fLevel  =  nUserLevel /nLevelSpace
	local nLevelArea = math.floor(fLevel)
	if nLevelArea == 0 then
		nLevelArea =1
	end
	local nLevel =  nLevelArea * nLevelSpace
	return nLevel
end

function WorkshopDzNew:RefreshScrollLayout()
	self:RefreshEquipScrollData()
	self:sortEquipScroll()
	--self:RefreshEquipScrollPos()
	self:RefreshEquipScrollState()
end

function WorkshopDzNew:RefreshEquipScrollData()
	for  nIndex=1, #self.vEquipData do 
	 	local oneEquipData = self.vEquipData[nIndex]
		local nEquipId = oneEquipData.nEquipId
		local bCanMake = self:IsCanMake(nEquipId)
		oneEquipData.bCanMake = bCanMake
		if bCanMake then
			oneEquipData.nOrderWeight = 100 + 100-nIndex
		else
			oneEquipData.nOrderWeight = 100-nIndex
		end
	end
end

function WorkshopDzNew:sortEquipScroll()
	table.sort(self.vEquipData, function (v1, v2)
		local nOrderHeight1 = v1.nOrderWeight
		local nOrderHeight2 = v2.nOrderWeight
		return nOrderHeight1 > nOrderHeight2
	end)
end

function WorkshopDzNew:getEquipDataWithId(nEquipId)
    for nIndex=1,table.getn(self.vEquipData) do
        local oneEquipData = self.vEquipData[nIndex]
        if nEquipId == oneEquipData.nEquipId then
            return oneEquipData
        end
    end
    return nil
end

function WorkshopDzNew:RefreshEquipScrollState()

    local vVisibleCells = self.tableView.visibleCells
    if not vVisibleCells then 
        return
    end
	for k,cellEquip in pairs(vVisibleCells) do 
		local nEquipId = cellEquip.itemCell:getID()
        local oneEquipData = self:getEquipDataWithId(nEquipId)--self.vEquipData[nIndex]
        
		local bCanMake = false --oneEquipData.bCanMake --self:IsCanMake(nEquipId)
        if oneEquipData then
            bCanMake = oneEquipData.bCanMake
        end
		if bCanMake then 
			cellEquip.imageCanMake:setVisible(true)
		else
			cellEquip.imageCanMake:setVisible(false)
		end
    end

    
end

function WorkshopDzNew:CreateCellWithId(parent,nIndex)
    local oneEquipData = self.vEquipData[nIndex]
    if not oneEquipData  then
        return nil
    end
    local nEquipId = oneEquipData.nEquipId
		local prefix = "WorkshopDzNewe_equip"
		local cellEquipItem = Workshopitemcell3.new(parent,prefix)
		cellEquipItem.nEquipId = nEquipId
		cellEquipItem:RefreshVisibleWithType(1) --//1=dz 2xq 3hc 4xl
		cellEquipItem.btnBg:subscribeEvent("MouseClick", WorkshopDzNew.HandleEquipItemClicked,self)
        return cellEquipItem
end

function WorkshopDzNew:RefreshEquipScroll()
	
    local wsManager = Workshopmanager.getInstance()
	local nLevelArea = self.nCurLevelArea
	local vEquipId = {}	
    wsManager:getEquipIdWithLevel(nLevelArea,vEquipId) 
    self.vEquipData = {}

    for nIndex=1,table.getn(vEquipId) do 
        self.vEquipData[nIndex] = {}
        self.vEquipData[nIndex].nEquipId = vEquipId[nIndex]
    end

    self:RefreshEquipScrollData()
    self:sortEquipScroll()
    --self:SetSelIdAtTop()

    self.tableView:destroyCells()
    local wsManager = Workshopmanager.getInstance()

    local nRankNumA = table.getn(self.vEquipData)
    self.tableView:setCellCountAndSize(nRankNumA, self.nodeCellSize.width, self.nodeCellSize.height)
    self.tableView:reloadData()


    --self.tableView:setContentOffset(100)

end

function WorkshopDzNew:SetSelIdAtTop()
    local oneEquipData = self.vEquipData[1]
    if oneEquipData then
        self.nItemCellSelId = oneEquipData.nEquipId
    end
end

function WorkshopDzNew:RefreshItemCellSel()

    local vVisibleCells = self.tableView.visibleCells
    if not vVisibleCells then 
        return
    end
	for k,equipCell in pairs(vVisibleCells) do 
		if equipCell.itemCell:getID() ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
             local wsManager = Workshopmanager.getInstance()
             wsManager.nEquipIdInDzSel = self.nItemCellSelId
		end	
	end
end

function WorkshopDzNew:HandleEquipItemClicked(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)

    local vVisibleCells = self.tableView.visibleCells
    if not vVisibleCells then 
        return
    end
	for k,equipCell in pairs(vVisibleCells) do 
        if equipCell.btnBg == mouseArgs.window then
			if equipCell.itemCell:getID() == 0 then
				return false
			end
			self.nItemCellSelId =  equipCell.itemCell:getID()
			break
		end
    end
    local wsManager = Workshopmanager.getInstance()
    wsManager.nEquipIdInDzSel = self.nItemCellSelId
   
	self:RefreshItemCellSel()
	self:RefreshRight()
    self:refreshMakeTarget()
	return true
end

function WorkshopDzNew:RefreshRight()
	local nSelEquipId = self.nItemCellSelId
	if nSelEquipId == 0 then
		return 
	end
	local equipMakeInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getRecorder(nSelEquipId)
	if equipMakeInfoCfg == nil then
		return 
	end
	local equipConfig = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nSelEquipId)
	if not equipConfig then
		return
	end
	local vMaterialNeed = {} --nId,nNum contain 4 element 
	self:GetNeedMaterial(nSelEquipId,vMaterialNeed)
	--item
	--//=========================
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndexMaterial = 1, #self.vItemCell do
		local  oneItemCell =  self.vItemCell[nIndexMaterial];
		local  oneItemLabel =  self.vItemLabel[nIndexMaterial];
		local  oneNeedItemData = vMaterialNeed[nIndexMaterial];
		local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(oneNeedItemData.nId)
		if itemAttr then
			local nOwnItemNum = roleItemManager:GetItemNumByBaseID(itemAttr.id)
			oneItemCell:setID(itemAttr.id)
			oneItemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttr.icon))
            SetItemCellBoundColorByQulityItemWithIdtm(oneItemCell,itemAttr.id)
			local strNumNeed_own = nOwnItemNum.."/"..oneNeedItemData.nNum
			oneItemCell:SetTextUnit(strNumNeed_own)
			--oneItemCell:SetTextUnitText(CEGUI.String(tostring(99)))
			if nOwnItemNum >= oneNeedItemData.nNum then
				oneItemCell:SetTextUnitColor(MHSD_UTILS.get_greencolor())
			else
				oneItemCell:SetTextUnitColor(MHSD_UTILS.get_redcolor())
			end
			oneItemLabel:setText(itemAttr.name)
			local nItemLevel = itemAttr.level
			local strLevelzi = MHSD_UTILS.get_resstring(351)
			local labItemLevel = self.vLabItemLevel[nIndexMaterial]
			if labItemLevel~=nil then
				local strLevelTitle= tostring(nItemLevel)..strLevelzi
				labItemLevel:setText(strLevelTitle)
			end
		end
	end
	
	--self.vLabItemLevel
	
	--//=====================
	local nUserMoney = roleItemManager:GetPackMoney()
	local nNeedMoney = equipMakeInfoCfg.moneynum
	--//===========================
	if nUserMoney >= nNeedMoney then
		self.needMoneyLabel:setProperty("TextColours", "ffffffff") --ff845c33
	else
		self.needMoneyLabel:setProperty("TextColours", "ffff0000")
	end
	
	local strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nNeedMoney)
	self.needMoneyLabel:setText(strNeedMoney)

	local strUserMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nUserMoney)
	self.ownMoneyLabel:setText(strUserMoney)
	
	--//target 
	self.ItemCellTarget:SetImage(gGetIconManager():GetItemIconByID(equipConfig.icon))
	self.LabTargetName:setText(equipConfig.effectdes)
	self.LabTargetNamec:setText(equipConfig.namecc5)
	self.LabTargetNamecc:setText(equipConfig.namecc4)
	self.ImageTargetCanMake:setVisible(false)
	
    self:refreshSelQianghua()
end

function WorkshopDzNew:refreshSelQianghua()
     local strSelQhLevel = GameTable.common.GetCCommonTableInstance():getRecorder(270).value
     local nSelQhLevel = tonumber(strSelQhLevel)

     local nUserLevel = 1 
     if gGetDataManager() then
        nUserLevel = gGetDataManager():GetMainCharacterLevel()
     end

     local nSel = 0
     local wsManager = Workshopmanager.getInstance()
     if wsManager.nSelQh == -1 then
        if nUserLevel>= nSelQhLevel then
            nSel = 1
        else
            nSel = 0
        end
    else
        nSel = wsManager.nSelQh
    end
    wsManager.nSelQh = nSel
    if nSel==1 then
        self.BtnSelQhItem:setSelected(true)
    else
        self.BtnSelQhItem:setSelected(false)
    end
end


function WorkshopDzNew:RefreshMoney()	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nUserMoney = roleItemManager:GetPackMoney()
	local nNeedMoney = self:GetCurNeedMoney()
	--//===========================
	if nUserMoney >= nNeedMoney then
		self.needMoneyLabel:setProperty("TextColours", "ffffffff") --ff845c33
	else
		self.needMoneyLabel:setProperty("TextColours", "ffff0000")
	end
	--self.needMoneyLabel:setText(tostring(nNeedMoney))
	local strUserMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nUserMoney)
	self.ownMoneyLabel:setText(strUserMoney)
end

function WorkshopDzNew:getEquipIdWithLevel(nLevel,vEauipId)
	local equipMakeTabAllId = ger.getInstance():GetTableByName("item.cequipmakeinfo"):getAllID()
	for i = 1, #equipMakeTabAllId do
		local nEquipId = equipMakeTabAllId[i]
		--7wei
		local nResult = math.floor(nEquipId /1000000)
		if nResult~= 0 then
			local nEquipLevel = math.floor( nEquipId /1000)
			nEquipLevel = nEquipLevel % 1000
			if nEquipLevel==nLevel then
				vEauipId[#vEauipId +1] = nEquipId
			end
		end
		
	end
end

function WorkshopDzNew:OpenShop()
	
end

--//3 num item  and money
function WorkshopDzNew:IsCanMake(nEquipId)
	local strResult = ""
	local equipMakeInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getRecorder(nEquipId)
	if not equipMakeInfoCfg then
		print("not found item in equipMakeInfoCfg")
		return false
	end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nUserMoney = roleItemManager:GetPackMoney()
	local nNeedMoney = equipMakeInfoCfg.moneynum
	--//===========================
	if nUserMoney < nNeedMoney then
		strResult = MHSD_UTILS.get_resstring(1792)
		return false, strResult
	end
	local vMaterialNeed = {} --nId,nNum
	self:GetNeedMaterial(nEquipId,vMaterialNeed)
	for nIndexMaterial = 1, 3 do 
		local oneNeedItemData = vMaterialNeed[nIndexMaterial]
		local nUserItemNum = roleItemManager:GetItemNumByBaseID(oneNeedItemData.nId)
		if nUserItemNum < oneNeedItemData.nNum then
			--strResult = MHSD_UTILS.get_resstring(11006)
            
            strResult = require ("utils.mhsdutils").get_msgtipstring(168004)
			local itemInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(oneNeedItemData.nId)
			if  itemInfoCfg then
				--strResult = strResult..itemInfoCfg.name
                local sb = StringBuilder:new()
                sb:Set("parameter1", itemInfoCfg.name)
	            strResult = sb:GetString(strResult)
	            sb:delete()

			end
			return false, strResult
		end
	end
	--//===========================
	local bVisible = self.BtnSelQhItem:isSelected()
	if bVisible then 
		local  oneNeedItemData = vMaterialNeed[4] --must have 4item
		local nUserItemNum = roleItemManager:GetItemNumByBaseID(oneNeedItemData.nId)
		if nUserItemNum < oneNeedItemData.nNum then
			--strResult = MHSD_UTILS.get_resstring(11006)
             strResult = require ("utils.mhsdutils").get_msgtipstring(168004)
			local itemInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(oneNeedItemData.nId)
			if  itemInfoCfg then
				--strResult = strResult..itemInfoCfg.name
                 local sb = StringBuilder:new()
                sb:Set("parameter1", itemInfoCfg.name)
	            strResult = sb:GetString(strResult)
	            sb:delete()
			end
			return false, strResult
		end
	end
	return true, strResult
end

function WorkshopDzNew:GetNeedMaterial(nEquipId,vNeedMaterial)
	local equipMakeInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getRecorder(nEquipId)
	if equipMakeInfoCfg == nil then
		print("not found item in equipMakeInfoCfg")
		return 
	end
	for nIndexMaterial = 1, 4 do
		local  oneMaterial =  {}
		oneMaterial.nId,oneMaterial.nNum = self:getEquipMaterialIdAndNum(nIndexMaterial,equipMakeInfoCfg)
		vNeedMaterial[nIndexMaterial] = oneMaterial
	end
end

function WorkshopDzNew:getCailiaotieIdAndNum(vcItemId,vcItemNum)
    local nNeedItemId = 0
	local nNeedItemNum = 0
    --local vcItemId = equipMakeInfoCfg.vcailiaotie
    --local vcItemNum = equipMakeInfoCfg.vcailiaotienum

    if vcItemId:size() > 0 then
        nNeedItemId = vcItemId[0]
    end

    if vcItemNum:size() > 0 then
        nNeedItemNum = vcItemNum[0]
    end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    for nIndex=0,vcItemId:size()-1 do
        local  nId = vcItemId[nIndex]
        local  nNum = 0
        if nIndex < vcItemNum:size() then
            nNum = vcItemNum[nIndex]
        end
		local nOwnItemNum = roleItemManager:GetItemNumByBaseID(nId)
		if nOwnItemNum >= nNum then
           nNeedItemId = nId
           nNeedItemNum = nNum
			break
		end
    end
    return nNeedItemId,nNeedItemNum
end

function WorkshopDzNew:getEquipMaterialIdAndNum(nIndexMaterial,equipMakeInfoCfg)
	local nId = 0
	local nNum =0
	if  nIndexMaterial==1 then
		nId = equipMakeInfoCfg.tuzhiid
		nNum = equipMakeInfoCfg.tuzhinum
	elseif nIndexMaterial==2 then
		--nId = equipMakeInfoCfg.hantieid
		--nNum = equipMakeInfoCfg.hantienum
        local vcItemId = equipMakeInfoCfg.vcailiaotie
        local vcItemNum = equipMakeInfoCfg.vcailiaotienum
        nId,nNum = self:getCailiaotieIdAndNum(vcItemId,vcItemNum)
	elseif nIndexMaterial==3 then
		--nId = equipMakeInfoCfg.zhizaofuid
		--nNum = equipMakeInfoCfg.zhizaofunum
        local vcItemId = equipMakeInfoCfg.vcailiaozhizaofu
        local vcItemNum = equipMakeInfoCfg.vcailiaozhizaofunum
        nId,nNum = self:getCailiaotieIdAndNum(vcItemId,vcItemNum)

	elseif nIndexMaterial==4 then
		nId = equipMakeInfoCfg.qianghuaid
		nNum = equipMakeInfoCfg.qianghuanum
	else
	end
	return  nId,nNum
end

function WorkshopDzNew:HandleSelLevelBtnClicked(e) --show select level tip
	if self.bLevelTipOpen == true then
		Workshopdznewcell.DestroyDialog()
		
		self.bLevelTipOpen = false
		self:RefreshLevelBtn()
	else
		local scrollLevel = Workshopdznewcell.getInstanceAndShow(self.m_pMainFrame)
		scrollLevel.dzDlg = self
		self.bLevelTipOpen = true
		self:RefreshLevelBtn()
	end	
	
end

function WorkshopDzNew:CloseLevelTip(nLevelArea)
	self:RefreshLevelBtn()
	if self.nCurLevelArea == nLevelArea then 
		return
	end
    local wsManager = Workshopmanager.getInstance()
    wsManager.nEquipIdInDzSel = -1
	self.nCurLevelArea = nLevelArea
    self.nItemCellSelId = 0
    self:SetSelIdAtTop()
	self:RefreshEquipScroll()

	--self:RefreshEquipScrollState()
end

function WorkshopDzNew:HandlLookBtnClicked(e)
	local preview = Workshopdzpreview.getInstanceAndShow()
    local nMakeType = self:getMakeType()
	preview:RefreshEquip(self.nItemCellSelId,nMakeType)
end

--//�������
function WorkshopDzNew:HandlMakeBtnClicked(e)
	--fire::pb::product::CMakeEquip
	--int equipid; // װ��ID
	--short maketype; // �������� 0 ��ͨ����; 1 ǿ������
	local bVisible = self.BtnSelQhItem:isSelected()
	local nMakeType = 0
	if bVisible==true then
		nMakeType = 1
	else
		nMakeType = 1
	end
	self:OnMakeEquip(nMakeType)
end

function WorkshopDzNew:GetCurNeedMoney()
	LogInfo("WorkshopDzNew:GetCurNeedMoney")
	local nEquipId = self.nItemCellSelId
	local equipMakeInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getRecorder(nEquipId)
	if not equipMakeInfoCfg then
		LogInfo("WorkshopDzNew:GetCurNeedMoney=error=nEquipId="..nEquipId)
		return 0 
	end
	
	local nNeedMoney1 = equipMakeInfoCfg.moneynum
	return nNeedMoney1
end

function WorkshopDzNew:OnMakeEquip(nType) --0=normal 1=qh
	LogInfo("WorkshopDzNew:OnMakeEquip(nType) ")
	local strLevelLimit = MHSD_UTILS.get_resstring(11030)
	local nCurArea = self.nCurLevelArea 
	local nMyArea = self:GetRoleLvelArea()
	local nAreaMax = nMyArea + 1000000
	if nCurArea > nAreaMax then
		GetCTipsManager():AddMessageTip(strLevelLimit)
		return 
	end
	--//
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nUserMoney = roleItemManager:GetPackMoney()
	local nNeedMoney = self:GetCurNeedMoney()
	--//===========================
	if nUserMoney < nNeedMoney then
		local nMoneyType = fire.pb.game.MoneyType.MoneyType_SilverCoin
		LogInfo("nMoneyType="..nMoneyType)
		local nShowNeed = nNeedMoney - nUserMoney
		CurrencyManager.handleCurrencyNotEnough(nMoneyType, nShowNeed)
		return 
	end
	
	local bCan, strResult = self:IsCanMake(self.nItemCellSelId)
	if bCan == false then
		GetCTipsManager():AddMessageTip(strResult)
        return
	end

    local bShowConfirm = self:checkShowCanEquipConfirm()
    if bShowConfirm then
        return
    end

    local bOver = self:checkOverEquipLevel()
    if bOver==false then
        self:sendMakeEquip()
    end

end

function WorkshopDzNew:continueMake()
    local bOver = self:checkOverEquipLevel()
    if bOver==false then
        self:sendMakeEquip()
    end
end


function WorkshopDzNew:checkShowCanEquipConfirm()
    local wsManager = Workshopmanager.getInstance()
    local nEquipId = self.nItemCellSelId
    local bCanEauip = wsManager:isCanEquip(nEquipId)
    if bCanEauip then
        return false
    end

    if wsManager.nNotTishi == 1 then
        return false
    end
    require("logic.workshop.workshopdzconfirm").getInstanceAndShow()

    return true

end

function WorkshopDzNew:sendMakeEquip()
    local nMakeType = self:getMakeType()
    local p = require "protodef.fire.pb.product.cmakeequip":new()
	p.equipid = self.nItemCellSelId
	p.maketype = nMakeType
	require "manager.luaprotocolmanager":send(p)
end

--160231
function WorkshopDzNew:checkOverEquipLevel()
    local nEquipId = self.nItemCellSelId
    local bHaveOver = false

    local equipAttrTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nEquipId)
    if not equipAttrTable then
        return false
    end
    local nEquipLevel = equipAttrTable.level

    local vMaterialNeed = {} --nId,nNum
	self:GetNeedMaterial(nEquipId,vMaterialNeed)
	for nIndexMaterial = 1, 3 do 
		local oneNeedItemData = vMaterialNeed[nIndexMaterial]
		local itemInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(oneNeedItemData.nId)
		if itemInfoCfg then
			if  itemInfoCfg.level > nEquipLevel then
                    bHaveOver = true
            end
		end
	end
    if bHaveOver == false then
        return false
    end

	local strMsg =  require "utils.mhsdutils".get_msgtipstring(160231) --MHSD_UTILS.get_resstring(nTipMsgId)

	gGetMessageManager():AddConfirmBox(eConfirmNormal,
		strMsg,
		WorkshopDzNew.clickConfirmBoxOk_make,
	  	self,
	  	WorkshopDzNew.clickConfirmBoxCancel_make,
	  	self)

    return true
end

function WorkshopDzNew:clickConfirmBoxOk_make()
    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,bSendCancelEvent)
    self:sendMakeEquip()
end

function WorkshopDzNew:clickConfirmBoxCancel_make()
     local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,bSendCancelEvent)
end

function WorkshopDzNew:OnEffectEnd()
	if _instance == nil then
		return
	end
end

function WorkshopDzNew:GetLayoutFileName()
	return "workshopdznew.layout"
end

function WorkshopDzNew.getInstance()
	if _instance == nil then
		_instance = WorkshopDzNew:new()
		_instance:OnCreate()
	end
	return _instance
end

function WorkshopDzNew.getInstanceOrNot()
	return _instance
end

--//==============================
function WorkshopDzNew:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, WorkshopDzNew)
	self:ClearData()
	return self
end

function WorkshopDzNew.DestroyDialog()
	
	LogInfo("WorkshopDzNew:DestroyDialog()")
	if not _instance then
		return
	end
	if _instance.m_LinkLabel then
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

function WorkshopDzNew:ClearData()
	self.m_LinkLabel = nil
	self.nCurLevelArea= 10
	self.bLevelTipOpen = false
	self.nItemCellSelId = 0
	self.vItemCell = {}
	self.vItemLabel = {}
	self.bLevelBtnShow = false

    self.vMakeTarget = {}
end

function WorkshopDzNew:OnClose()
	LogInfo("WorkshopDzNew:OnClose()")
	
    if self.tableView then
        local wsManager = Workshopmanager.getInstance()
        --local bar = self.tableView.scroll:getVertScrollbar()
        wsManager.nOffsetDz = self.tableView.scroll:getVerticalScrollPosition()
    end
    

    self:clearAllMakeTargetCell()
	self:ClearData()	
	self.tableView:destroyCells()

	Dialog.OnClose(self)
    
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
	gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)

    gGetRoleItemManager().m_EventAddPackItem:RemoveScriptFunctor(self.handle_AddBagItem)


	_instance = nil
end

return WorkshopDzNew


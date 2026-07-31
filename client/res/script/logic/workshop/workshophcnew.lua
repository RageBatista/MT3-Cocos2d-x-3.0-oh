require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.workshophelper"
require "utils.commonutil"
require "logic.workshop.workshophccell"
require "logic.workshop.gemtypelist"
require "logic.workshop.gemshopcell"
Workshophcnew = {}
setmetatable(Workshophcnew, Dialog)
Workshophcnew.__index = Workshophcnew
local _instance;

function Workshophcnew.OnCombinResult()
	if not _instance then
		return
	end
	_instance:RefreshGemScroll()
	_instance:RefreshRight()
	
	local wsManager = require "logic.workshop.workshopmanager".getInstance()
	wsManager:RefreshRedPointInRightLabel()
end

function Workshophcnew.getInstance()
    if not _instance then
        _instance = Workshophcnew:new()
        _instance:OnCreate()
    end
    return _instance
end

function Workshophcnew.getInstanceAndShow()
    if not _instance then
        _instance = Workshophcnew:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Workshophcnew.getInstanceOrNot()
    return _instance
end

function Workshophcnew.getInstanceNotCreate()
    return _instance
end

function Workshophcnew.DestroyDialog()
	if not _instance then
		return
	end
    gemtypelist.DestroyDialog()
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

function Workshophcnew.GetLayoutFileName()
    return "workshophcnew.layout"
end

function Workshophcnew:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Workshophcnew)
	self:ClearData()
    return self
end

function Workshophcnew:ClearData()
	self.m_LinkLabel = nil
	self.nItemCellSelId = 0
	self.nShowNumInPage = 7
	self.mapGemTabIdNum = {}
	self.nMaxGemLevel = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(333).value)
end

function Workshophcnew:ClearDataInClose()
	self.m_LinkLabel = nil
	self.nItemCellSelId = 0
	self.nShowNumInPage = 7
	self.mapGemTabIdNum = nil
	self.nMaxGemLevel = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(333).value)
end

function Workshophcnew:OnClose()
	Dialog.OnClose(self)
	self:ClearDataInClose()
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

function Workshophcnew:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(Workshophcnew.OnItemNumChange)
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.gemBg = CEGUI.toScrollablePane(winMgr:getWindow("workshophcnew/rightback/main"))

	self.ItemCell1 = CEGUI.toItemCell(winMgr:getWindow("workshophcnew/Back/di0/equip01"))
	self.LabName1 = winMgr:getWindow("workshophcnew/Back/name01") 	
	self.ItemCell2 = CEGUI.toItemCell(winMgr:getWindow("workshophcnew/Back/di1/equip11"))
	self.LabName2 = winMgr:getWindow("workshophcnew/Back/name11") 
--	self.labelNeedNum = winMgr:getWindow("workshophcnew/Back/pic/txt") 
	self.BtnCombin = CEGUI.toPushButton(winMgr:getWindow("workshophcnew/Back/hecheng1")) --Workshophcnew/Back/hecheng1
	self.BtnCombin:subscribeEvent("Clicked", Workshophcnew.HandlCombinClicked, self)
--	self.BtnCombinAll = CEGUI.toPushButton(winMgr:getWindow("workshophcnew/Back/hecheng2"))
--	self.BtnCombinAll:subscribeEvent("Clicked", Workshophcnew.HandlCombinAllClicked, self)
	self.LabPercent = winMgr:getWindow("workshophcnew/Back/text/1")
    self.m_progress = CEGUI.toProgressBar(winMgr:getWindow("workshophcnew/Back/green1"))
    self.labColourOrg = self.LabPercent:getProperty("TextColours")

    self.m_hcTip = winMgr:getWindow("workshophcnew/Back/note")
    self.m_hcBSCItem = CEGUI.toItemCell(winMgr:getWindow("workshophcnew/Back/qianghautubiao"))
    self.m_hcBSCItemName = winMgr:getWindow("workshophcnew/Back/qianghuadaoju")
    self.m_hcBSCItemCheck = CEGUI.toCheckbox(winMgr:getWindow("workshophcnew/Back/qianghuaqueren"))
    self.m_hcBSCItemCheck:subscribeEvent("CheckStateChanged", Workshophcnew.handleBSCCheck, self)
    self.m_hcBSCItem:subscribeEvent("MouseClick", Workshophcnew.handleClickBSC, self)

    -- 新加控件
    self.m_gemType = CEGUI.toGroupButton(winMgr:getWindow("workshophcnew/rightback1/btn"))
    self.m_gemTypeItem = CEGUI.toItemCell(winMgr:getWindow("workshophcnew/rightback1/btn/item"))
    self.m_gemTypeName = winMgr:getWindow("workshophcnew/rightback1/btn/text1")
    self.m_gemTypeAttribute = winMgr:getWindow("workshophcnew/rightback1/btn/text2")
    self.m_shopGems = CEGUI.toScrollablePane(winMgr:getWindow("workshophcnew/Back/di111/list"))
    self.m_MyseleGems = CEGUI.toScrollablePane(winMgr:getWindow("workshophcnew/Back/di111/list1"))
    self.m_jiahao = CEGUI.toScrollablePane(winMgr:getWindow("workshophcnew/Back/jiahao"))
    self.m_combinBg = winMgr:getWindow("workshophcnew/Back/kuang")
    self.m_combinBgX = self.m_combinBg:getXPosition().offset

    self.m_needSilver = winMgr:getWindow("workshophcnew/Back/needdi/zhi1")
    self.m_myselfSilver = winMgr:getWindow("workshophcnew/Back/needdi/zhi11")
    
    self.m_btnAddSilver = CEGUI.toPushButton(winMgr:getWindow("workshophcnew/Back/jiayinbi"))
    self.m_btnAddSilver:subscribeEvent("MouseClick", Workshophcnew.HandleAddMoneyClick, self)
    
    self.m_gemType:subscribeEvent("MouseButtonUp", Workshophcnew.HandleGemTypeSelectClicked, self)


	self.ItemCell1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)
    self.ItemCell2:subscribeEvent("MouseClick", Workshophcnew.clickItemCell2, self)


    local layoutNamegetSize = "baoshihechengcell.layout"
    local strPrefix = "getsize"
	local nodeCell = winMgr:loadWindowLayout(layoutNamegetSize,strPrefix)
    self.nodeCellSize = nodeCell:getPixelSize()
    winMgr:destroyWindow(nodeCell)

    ShopManager:queryGoodsPrices()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local oldmoney = roleItemManager:GetPackMoney()
    self.m_myselfSilver:setText(oldmoney)

    self.m_shopGemData = {
        [1] = {},
        [2] = {},
        [3] = {}
    }
    self.m_price = 0
    self.m_bagGemData = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {},
        [7] = {},
        [8] = {},
        [9] = {},
        [10] = {},
        [11] = {},
        [12] = {},
        [13] = {},
        [14] = {},
        [15] = {},
        [16] = {},
        [17] = {},
        [18] = {},
        [19] = {},
	    [20] = {},
        [21] = {},
        [22] = {},
        [23] = {},
        [24] = {},
        [25] = {},
        [26] = {},
        [27] = {},
        [28] = {},
	    [29] = {},
        [30] = {},
        [31] = {},
        [32] = {},
        [33] = {},
        [34] = {},
        [35] = {},
        [36] = {},
        [37] = {},
        [38] = {},
        [39] = {},
        [40] = {},
        [41] = {},
		[42] = {},
        [43] = {},
        [44] = {},
        [45] = {},
        [46] = {},
        [47] = {},
        [48] = {},
        [49] = {}		
    }
    for k,v in pairs(self.m_shopGemData) do
        self.m_shopGemData[k].itemIdOrGoodId = 0
        self.m_shopGemData[k].num = 0
    end
    for k,v in pairs(self.m_bagGemData) do
        self.m_bagGemData[k].itemIdOrGoodId = 0
        self.m_bagGemData[k].num = 0
    end
end

function Workshophcnew:initGemList()
    self.gemBg:cleanupNonAutoChildren()
    local gemTypeNum = 0
    if IsPointCardServer() then
        gemTypeNum = 8
    else
        gemTypeNum = 48
    end

    for i = 1, gemTypeNum do
        local data = self:findInfoByTypeAndLevel(self.curGemType, i+1)
        local cell = workshophccell.CreateNewDlg(self.gemBg)
        self:setGemCellInfo(cell, data)
        cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1 +(i- 1) * cell:GetWindow():getPixelSize().height)))
        cell.btnBg:subscribeEvent("MouseClick", Workshophcnew.HandleClickedItem,self)  
    end
    

end

function Workshophcnew:HandleGemTypeSelectClicked(args)
    if gemtypelist.getInstanceNotCreate() then
        gemtypelist.DestroyDialog()
    else
        gemtypelist.getInstanceAndShow()
    end

    return true
end

function Workshophcnew:setGemCellInfo(cell, data)
    local objData = data
	local nTabId = objData.id
	--local nNum = objData.nNum
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nTabId)
	if not itemAttrCfg then
		return
	end
    local stoneCombinCfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("item.cequipcombin")):getRecorder(nTabId)
    if not stoneCombinCfg then 
		return
	end
    --��Ҫ�ϳɵ�(����id)
    cell.btnBg:setID(stoneCombinCfg.lastequipid)
	local nLevel = itemAttrCfg.level
	cell.name:setText(itemAttrCfg.name)
	cell.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(cell.itemCell, itemAttrCfg.id)
	--cell.num = nNum 
	local gemconfig = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nTabId)
    if gemconfig then
	    local strEffect = gemconfig.effectdes --gemconfig.inlayeffect
	    cell.describe:setText(strEffect)
	    cell.describe1:setText(gemconfig.level)
    end
	--cell.itemCell:SetTextUnit(nNum)
	if self.nItemCellSelId ==0 then
		self.nItemCellSelId = nTabId
	end
    if self.nItemCellSelId ~= nTabId then
        cell.btnBg:setSelected(false)
    else
        cell.btnBg:setSelected(true)
    end
end

function Workshophcnew:clickItemCell2(args)
    local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function Workshophcnew.OnItemNumChange(eBagType, nItemKey, nItemId)
    if not _instance then
		return
	end
	_instance:RefreshGemScroll()
	_instance:RefreshRight()
	local wsManager = require "logic.workshop.workshopmanager".getInstance()
	wsManager:RefreshRedPointInRightLabel()
end


function Workshophcnew:getIndexWithId(nTabId)
    for nIndex,objData in pairs(self.mapGemTabIdNum) do
        local nGemId = objData.nGemId
	    --local nNum = objData.nNum
        if nGemId == nTabId then
            return nIndex
        end
    end
    return -1
end

function Workshophcnew:RefreshUI(nBagId,nItemKey)
	self:RefreshGemScroll()
	self:RefreshRight()

    if nBagId and nItemKey then
    	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local pItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagId)
	    if not pItem then
		    return 
	    end
        self.nItemCellSelId = pItem:GetBaseObject().id
        if self.m_tableview then
            self.m_tableview:reloadData()
            local nIndex = self:getIndexWithId(self.nItemCellSelId)
            if nIndex~= -1 then
                self.m_tableview:setContentOffset((nIndex-1)*self.nodeCellSize.height)
            end
            
        end
        self:RefreshRight()
    end
   

end

function Workshophcnew:HandlCombinClicked(e)
	
	local nCurItemkey = self:GetItemKeyWithTableId()
	local useMoney = 0
	local combineAll = 0
	local itemkey = nCurItemkey

    local isUserHanmmer = 0
    if self.m_hcBSCItemCheck:isSelected() then
        isUserHanmmer = 1
    end

    if isUserHanmmer == 1 and not self:checkBSCEnough(false) then
        return
    end

    self.nextItemId = self:getNextGemID()

--	require "protodef.fire.pb.item.chechengitem"
--	local p = CHeChengItem.Create()
--	p.money = useMoney
--	p.isall = combineAll
--	p.keyinpack = itemkey
--    p.hammer = isUserHanmmer
--    LuaProtocolManager.getInstance():send(p)

--<protocol name="CComposeGem" type="1352" maxsize="128"  prior="1" tolua="3"> �ϳɱ�ʯ
--		<variable name="bUseRongHeJi" type="byte"/> �Ƿ�ʹ���ںϼ� 0:��ʹ�� 1:ʹ��
--		<variable name="targetGemItemId" type="int"/> �ϳɱ�ʯ��ID
--		<variable name="bagGems" type="vector" value="fire.pb.item.ComposeGemInfoBean"/> ʹ�õı�����ʯ
--		<variable name="shopGems
--	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemCellSelId)
--	if not itemAttrCfg then
--		return
--	end
    local stoneCombinCfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("item.cequipcombin")):getRecorder(self.nItemCellSelId)
    if not stoneCombinCfg then 
		return
	end

    local bagGems = {}
    for k,v in pairs(self.m_bagGemData) do
        local i = 1
        if v.num ~= 0 then
            local gem = ComposeGemInfoBean:new()
            gem.num = v.num
            gem.itemidorgoodid = v.itemIdOrGoodId
            bagGems[i] = gem
            i = i + 1
        end
    end
    local shopGems = {}
    for k,v in pairs(self.m_shopGemData) do
        local i = 1
        if v.num ~= 0 then
            local gem = ComposeGemInfoBean:new()
            gem.num = v.num
            gem.itemidorgoodid = v.itemIdOrGoodId
            shopGems[i] = gem
            i = i + 1
        end
    end
    require "protodef.fire.pb.item.ccomposegem"
    local p = CComposeGem.Create()
    if isUserHanmmer == 1 then
    	p.buserongheji = 1
    else
		p.buserongheji = 0
    end
    p.targetgemitemid = stoneCombinCfg.nextequipid
    p.curgemitemid = stoneCombinCfg.id
    p.baggems = bagGems
    p.shopgems = shopGems
    LuaProtocolManager.getInstance():send(p)
end
-- 0减 1加
function Workshophcnew:setConbinePlan(level, plusOrReduce)
    local tem = math.pow(2, level - 1)
    if plusOrReduce == 0 then
        self.curPlan = self.curPlan - tem
    else
        self.curPlan = self.curPlan + tem
    end
    self.m_progress:setProgress(self.curPlan/self.maxPlan)
    self.m_progress:setText(self.curPlan.."/"..self.maxPlan)
end

--function Workshophcnew:HandlCombinAllClicked(e)
--	local nCurItemkey = self:GetItemKeyWithTableId()
--	local useMoney = 0
--	local combineAll = 1
--	local itemkey = nCurItemkey

--    local isUserHanmmer = 0
--    if self.m_hcBSCItemCheck:isSelected() then
--        isUserHanmmer = 1
--    end

--    if isUserHanmmer == 1 and not self:checkBSCEnough(true) then
--        return
--    end

--	require "protodef.fire.pb.item.chechengitem"
--	local p = CHeChengItem.Create()
--	p.money = useMoney
--	p.isall = combineAll
--	p.keyinpack = itemkey
--    p.hammer = isUserHanmmer
--    LuaProtocolManager.getInstance():send(p)
--end

function Workshophcnew:IsHaveGemTableId(nTableId)
	for nIndex=1,#self.vTableId do 
		local nId = self.vTableId[nIndex]
		if nId==nTableId then 
			return true
		end
	end
	return false
end
-- 获得下一块宝石id
function Workshophcnew:getNextGemID()
  	for nIndex=1,#self.vTableId do 
		local nId = self.vTableId[nIndex]
		if nId==self.nItemCellSelId then 
            if nIndex < #self.vTableId then
                return self.vTableId[nIndex+1]
            else
                return self.vTableId[1]
            end
		end
	end
    return 0
end



function Workshophcnew:GetTableIdArray(vGemKey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for i = 0, vGemKey:size() - 1 do
		local baggem = roleItemManager:FindItemByBagAndThisID(vGemKey[i], fire.pb.item.BagTypes.BAG)
		if baggem then
			local nTableId = baggem:GetObjectID()
			local itemAttrCfg = baggem:GetBaseObject()
			local nLevel = itemAttrCfg.level
			if nLevel <= self.nMaxGemLevel then
				local bHave = self:IsHaveGemTableId(nTableId)
				if bHave==false then
					self.vTableId[#self.vTableId + 1] = nTableId
				end
			end
		end
	end
end

function Workshophcnew:GetMapIdNum(mapGemTabIdNum)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vTableId do 
		local nGemId = self.vTableId[nIndex]
		local nNum = roleItemManager:GetItemNumByBaseID(nGemId)
		mapGemTabIdNum[nIndex] = {}
		mapGemTabIdNum[nIndex].nGemId = nGemId
		mapGemTabIdNum[nIndex].nNum  = nNum
		local nLevel = 0
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nGemId)
		if itemAttrCfg then
			nLevel = itemAttrCfg.level
		end
        local gemConfig =  BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nGemId);
        
		local nOrderHeight = nNum * 10000
		nOrderHeight = nOrderHeight + (1000-nLevel)
		mapGemTabIdNum[nIndex].nOrderHeight = nOrderHeight
        mapGemTabIdNum[nIndex].level = itemAttrCfg.level
        mapGemTabIdNum[nIndex].gemType = gemConfig.ngemtype
	end
    self:sortCell(mapGemTabIdNum)
end

function Workshophcnew:sortCell(gemTable)
     local function _sort(a, b)
        if a.gemType == b.gemType then
            return a.level < b.level
        end
        return a.gemType < b.gemType
    end
	table.sort(gemTable, _sort)
end

function Workshophcnew:RefreshAllGemData()
	for k,v in pairs(self.mapGemTabIdNum) do
		v = {}
	end
	self.mapGemTabIdNum = {}
	local vGemKey = {}
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	vGemKey = roleItemManager:GetItemKeyListByType(vGemKey,eItemType_GEM, fire.pb.item.BagTypes.BAG)
	self.vTableId = {} 
	self:GetTableIdArray(vGemKey)
	self:GetMapIdNum(self.mapGemTabIdNum) --//sort all
    if self.nItemCellSelId ~= 0 and self:IsHaveGemTableId(self.nItemCellSelId) == false then
        self.nItemCellSelId = self.nextItemId
    end
    if self.m_tableview then
        self.itemOffect = self.m_tableview:getContentOffset()
    end
   -- local objData = self.mapGemTabIdNum[1]
	local nTabId
    if self.mapGemTabIdNum[1] then
        nTabId = self.mapGemTabIdNum[1].nGemId
    else
        local tmp = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getAllID()
        nTabId = tmp[1]
    end
    local gemConfig =  BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nTabId);
    local info = BeanConfigManager.getInstance():GetTableByName("item.cgemtype"):getRecorder(gemConfig.ngemtype)
    self.curGemType = gemConfig.ngemtype
    self:refreshGemType(info)
    self:refreshShopGems()
    self:refreshMyselfGems()
end

function Workshophcnew:refreshGemType(info)
    if info then
        self.curGemType = info.id
        self.m_gemTypeItem:SetImage(gGetIconManager():GetItemIconByID(info.nicon))
        SetItemCellBoundColorByQulityItemWithId(self.itemCell, info.nitemid)
        self.m_gemTypeName:setText(info.strname)
        self.m_gemTypeAttribute:setText(info.stradddes)
        self:initGemList()
        self:refreshShopGems()
        self:refreshMyselfGems()
    end
end

function Workshophcnew:RefreshGemScroll()
	self:RefreshAllGemData()
    self:initGemList()
	local vGemData = {}
    -- 默认选中第一个
	for nIndexCell=1,#self.mapGemTabIdNum do
		local objData = self.mapGemTabIdNum[nIndexCell]
		local nTabId = objData.nGemId
		if self.nItemCellSelId ==0 then
			self.nItemCellSelId = nTabId
		end
	end
    -- 如果没有宝石 设置右边为空
    if #self.mapGemTabIdNum == 0 then
        self.nItemCellSelId = 0
        self:ResetRight()
    end
end

function Workshophcnew:GetItemKeyWithTableId()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local vGemKey = {}
	vGemKey = roleItemManager:GetItemKeyListByType(vGemKey,eItemType_GEM, fire.pb.item.BagTypes.BAG)
	for i = 0, vGemKey:size() - 1 do
		local baggem = roleItemManager:FindItemByBagAndThisID(vGemKey[i], fire.pb.item.BagTypes.BAG)
		if baggem then
			local nTableId = baggem:GetObjectID()
			if nTableId == self.nItemCellSelId then
				return vGemKey[i]
			end
		end
	end
	return -1
end

function Workshophcnew:HandleClickedItem(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
    local id = mouseArgs.window:getID()
    self.m_hcBSCItemCheck:setSelectedNoEvent(false)
	self.nItemCellSelId =  id
	self:RefreshRight()
	return true
end

function Workshophcnew:handleClickBSC(arg)
    local e = CEGUI.toMouseEventArgs(arg)
	local touchPos = e.position

    local stoneCombinCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipcombin"):getRecorder(self.nItemCellSelId)
    if not stoneCombinCfg then return end

	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eComeFrom
	commontipdlg:RefreshItem(nType, stoneCombinCfg.hammerid, nPosX, nPosY)
end

function Workshophcnew:ResetRight()
	self.ItemCell1:SetImage(nil)
    self.ItemCell1:setID(0)
    SetItemCellBoundColorByQulityItemWithId(self.ItemCell1,0)
	self.ItemCell1:SetTextUnit("")
	self.LabName1:setText("")
	self.ItemCell2:SetImage(nil)
    self.ItemCell2:setID(0)
    SetItemCellBoundColorByQulityItemWithId(self.ItemCell2,0)
	self.ItemCell2:SetTextUnit("")
	self.LabName2:setText("")
	self.LabPercent:setText("")
    self.m_needSilver:setText("")
end

function Workshophcnew:RefreshRight()
    --����id
	local nGemId = self.nItemCellSelId
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nGemId)
	if not itemAttrCfg then
		self:ResetRight()
		return
	end 
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nNum1 = roleItemManager:GetItemNumByBaseID(nGemId)
	self.ItemCell1:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(self.ItemCell1,itemAttrCfg.id)
	self.ItemCell1:SetTextUnit(nNum1)
	self.ItemCell1:setID(nGemId)
	self.LabName1:setText(itemAttrCfg.name)
	local stoneCombinCfg = BeanConfigManager.getInstance():GetTableByName(CheckTableName("item.cequipcombin")):getRecorder(nGemId)

    if not stoneCombinCfg then 
		return
	end
    --���ϼ�¼�ĺϳɲ���id
	local nGemId2 = stoneCombinCfg.nextequipid
	local nNeedNum = stoneCombinCfg.equipnum
	local nNeedYinliang = stoneCombinCfg.yinliang
--	self.labelNeedNum:setText(tostring(nNeedNum))
	local itemAttrCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nGemId2)
	if not itemAttrCfg2 then
		return
	end
	local nTargetNum = math.floor(nNum1/nNeedNum)
	self.ItemCell2:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg2.icon))
    self.ItemCell2:setID(itemAttrCfg2.id)
    SetItemCellBoundColorByQulityItemWithId(self.ItemCell2,itemAttrCfg2.id)
	self.ItemCell2:SetTextUnit(nTargetNum)
	self.LabName2:setText(itemAttrCfg2.name)

    self.maxPlan = math.pow(2, itemAttrCfg2.level - 1)
    self.curPlan = 0
    self.m_progress:setProgress(0)
    self.m_progress:setText("0".."/"..self.maxPlan)
    --self.m_needSilver:setText(nNeedYinliang)
	local nPercent = stoneCombinCfg.hechengrate
	local strPercent = tostring(nPercent).."%"
	self.LabPercent:setText(strPercent)

    if self.m_hcBSCItemCheck:isSelected() then
        local textColor = stoneCombinCfg.colorafterqianghua
        self.LabPercent:setProperty("TextColours", textColor)
        self.LabPercent:setText(stoneCombinCfg.hammerrate.."%")
    else
        self.LabPercent:setProperty("TextColours", self.labColourOrg)
        self.LabPercent:setText(stoneCombinCfg.hechengrate.."%")
    end

    if stoneCombinCfg.hammerid > 0 then
        self:setBSCVisible(true)
        local itemConfig = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(stoneCombinCfg.hammerid)
        self.m_hcBSCItem:SetImage(gGetIconManager():GetItemIconByID(itemConfig.icon))
        self:refreshBSCCount()
        self.m_hcBSCItemCheck:setSelected(true)
        self.m_combinBg:setXPosition(CEGUI.UDim(0, self.m_combinBgX))
    else
        self:setBSCVisible(false)
         self.m_combinBg:setXPosition(CEGUI.UDim(0, self.m_combinBgX + 50))
    end
end

function Workshophcnew:findInfoByTypeAndLevel(type, level)
    local gemIds =  BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getAllID()
    for k,v in pairs(gemIds) do
        local config = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(v)
        if config.ngemtype == type and config.level == level then
            return config
        end
    end
    return nil
end

function Workshophcnew:refreshShopGems()
    --local info = BeanConfigManager.getInstance():GetTableByName("item.cgemtype"):getRecorder(self.curGemType)
    self.m_shopGems:cleanupNonAutoChildren()
    if self.curGemType ~= 10 then
        for i = 1, 3 do
            local config = self:findInfoByTypeAndLevel(self.curGemType, i)
            local cell = gemshopcell.CreateNewDlg(self.m_shopGems)
            cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1 +(i- 1) * cell:GetWindow():getPixelSize().height)))
            cell.window:setGroupID(i)
            cell.window:subscribeEvent("MouseClick", Workshophcnew.HandleClickedShopItem,self)
            cell:setShopInfo(config)
        end
        
    end
end

function Workshophcnew:refreshMyselfGems()
   
    self.m_MyseleGems:cleanupNonAutoChildren()
    self.m_bagGemData = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {},
        [7] = {},
        [8] = {},
        [9] = {},
        [10] = {},
        [11] = {},
        [12] = {},
        [13] = {},
        [14] = {},
        [15] = {},
        [16] = {},
        [17] = {},
        [18] = {},
        [19] = {},
	    [20] = {},
        [21] = {},
        [22] = {},
        [23] = {},
        [24] = {},
        [25] = {},
        [26] = {},
        [27] = {},
        [28] = {},
	    [29] = {},
        [30] = {},
        [31] = {},
        [32] = {},
        [33] = {},
        [34] = {},
        [35] = {},
        [36] = {},
        [37] = {},
        [38] = {},
        [39] = {},
        [40] = {},
        [41] = {},
		[42] = {},
        [43] = {},
        [44] = {},
        [45] = {},
        [46] = {},
        [47] = {},
        [48] = {},
        [49] = {}			
    }
    
    for k,v in pairs(self.m_bagGemData) do
        self.m_bagGemData[k].itemIdOrGoodId = 0
        self.m_bagGemData[k].num = 0
    end
    local wsManager = Workshopmanager.getInstance()
	local equipDataList = wsManager:GetAllEquipData()
    local i = 1
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    for k,v in pairs(equipDataList) do
        local nEquipKey = v.nEquipKey
		local eBagType = v.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
    	local equipObj = equipData:GetObject()
	    local vGemList = equipObj:GetGemlist()
        if vGemList._size > 0 then
            for j = 1, vGemList._size do
                local gemconfig = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(vGemList[j - 1])
                if gemconfig.ngemtype == self.curGemType then
                    local cell = gemshopcell.CreateNewDlg(self.m_MyseleGems)
                    --cell.window:setGroupID(i)
                    local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(equipData:GetBaseObject().id)
	                if not equipAttrCfg then
		                return 
	                end --vgemtype
	                local eequiptype = equipAttrCfg.eequiptype --װ���������� 
	                local equipPosNameCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipposname"):getRecorder(eequiptype)
	                if not equipPosNameCfg or equipPosNameCfg.id == -1 then
		                return 
	                end
                    local equipbag = 1
	                if eBagType == fire.pb.item.BagTypes.EQUIP then
		                equipbag = 1
	                else
		                equipbag = 0
	                end
                    cell:setEquipGemInfo(gemconfig, equipPosNameCfg.strname, nEquipKey, equipbag, j-1)
                    cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1 +(i- 1) * cell:GetWindow():getPixelSize().height)))
                    cell.window:subscribeEvent("MouseClick", Workshophcnew.HandleClickedShopItem,self)
                    i = i + 1
                end
            end
        end
    end
    for nIndex,objData in pairs(self.mapGemTabIdNum) do
        local typeId = objData.gemType
        LogInfo("类型"..typeId.."LEIXING"..self.curGemType)
        if typeId == self.curGemType then
            local cell = gemshopcell.CreateNewDlg(self.m_MyseleGems)
            cell:setBagGemInfo(objData)
            cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1 +(i- 1) * cell:GetWindow():getPixelSize().height)))
            cell.window:subscribeEvent("MouseClick", Workshophcnew.HandleClickedShopItem,self)
            i = i + 1   
        end
    end
end

function Workshophcnew:HandleClickedShopItem(args)
    return true
end

function Workshophcnew:addShopGem(level, goodid, gemid)
    if level and goodid then
        self.m_shopGemData[level].num = self.m_shopGemData[level].num + 1
        self.m_shopGemData[level].itemIdOrGoodId = goodid
        local price = ShopManager.goodsPrices[goodid]
        self.m_price = self.m_price + price
        self.m_needSilver:setText(self.m_price)
        self:setConbinePlan(level, 1)
    end
end

function Workshophcnew:removeShopGem(level, goodid, gemid)
    if self.m_shopGemData[level].num > 0 then
        self.m_shopGemData[level].num = self.m_shopGemData[level].num - 1
        local price = ShopManager.goodsPrices[goodid]
        self.m_price = self.m_price - price
        self.m_needSilver:setText(self.m_price)
        self:setConbinePlan(level, 0)
    end
end

function Workshophcnew:removeBagGem(level, gemid)
    if self.m_bagGemData[level].num > 0 then
        self.m_bagGemData[level].num = self.m_bagGemData[level].num - 1
        self:setConbinePlan(level, 0)
    end
end

function Workshophcnew:addBagGem(level, itemid)
    if level and itemid then
        self.m_bagGemData[level].num = self.m_bagGemData[level].num + 1
        self.m_bagGemData[level].itemIdOrGoodId = itemid
        self:setConbinePlan(level, 1)
    end
end

function Workshophcnew:checkBSCEnough(isAll)    
    local isEnough = true
    local stoneCombinCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipcombin"):getRecorder(self.nItemCellSelId)
    if not stoneCombinCfg then return end

    local needItemID = stoneCombinCfg.hammerid
    local oneceNeedCount = stoneCombinCfg.hammernum
    local gemCount = require("logic.item.roleitemmanager").getInstance():GetItemNumByBaseID(self.nItemCellSelId)
    local ownCount = require("logic.item.roleitemmanager").getInstance():GetItemNumByBaseID(needItemID)
    if not isAll then
        if ownCount < oneceNeedCount then
            isEnough = false
        end
    else
        if ownCount < math.floor(gemCount / 2) then
            isEnough = false
        end
    end

    if not isEnough then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(190040))
    end

    return isEnough
end

function Workshophcnew:refreshBSCCount()
    local stoneCombinCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipcombin"):getRecorder(self.nItemCellSelId)
    if stoneCombinCfg and self.m_hcBSCItemCheck:isVisible() then
        local itemCount = require("logic.item.roleitemmanager").getInstance():GetItemNumByBaseID(stoneCombinCfg.hammerid)
        local useCount= stoneCombinCfg.hammernum

        self.m_hcBSCItem:SetTextUnitText(itemCount.."/"..useCount)

        if useCount > itemCount then
            self.m_hcBSCItem:SetTextUnitColor(MHSD_UTILS.get_redcolor())
        else
            self.m_hcBSCItem:SetTextUnitColor(MHSD_UTILS.get_greencolor())
        end
    end
end

function Workshophcnew:setBSCVisible(bShow)
    self.m_hcBSCItem:setVisible(bShow)
    self.m_hcBSCItemName:setVisible(bShow)
    self.m_hcBSCItemCheck:setVisible(bShow)
    self.m_jiahao:setVisible(bShow)
  --  self.m_hcTip:setVisible(not bShow)
end

function Workshophcnew:handleBSCCheck(arg)
    local stoneCombinCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipcombin"):getRecorder(self.nItemCellSelId)
    if not stoneCombinCfg then return end

    if self.m_hcBSCItemCheck:isSelected() then
        local textColor = stoneCombinCfg.colorafterqianghua
        self.LabPercent:setProperty("TextColours", textColor)
        self.LabPercent:setText(stoneCombinCfg.hammerrate.."%")
    else
        self.LabPercent:setProperty("TextColours", self.labColourOrg)
        self.LabPercent:setText(stoneCombinCfg.hechengrate.."%")
    end
end

function Workshophcnew:refreshShopGemData(gemId, gemLevel)
    if self.m_shopGemData[gemLevel].num then
        self.m_shopGemData[gemLevel].num = self.m_shopGemData[gemLevel].num + 1
    else
        self.m_shopGemData[gemLevel].gemId = gemId
        self.m_shopGemData[gemLevel].num = 1
    end
    
end

function Workshophcnew:isPlanFull()
    if self.curPlan >= self.maxPlan then
        return true
    end
    return false
end

function Workshophcnew:HandleAddMoneyClick(args)
    local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)
end



return Workshophcnew

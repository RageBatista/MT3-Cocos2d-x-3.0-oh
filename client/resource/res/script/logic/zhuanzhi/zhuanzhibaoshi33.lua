require "logic.dialog"
require "logic.zhuanzhi.zhuanzhibaoshicell33"

ZhuanZhiBaoShi33 = {}
setmetatable(ZhuanZhiBaoShi33, Dialog)
ZhuanZhiBaoShi33.__index = ZhuanZhiBaoShi33

local GEM_LEVEL_LIMIT = 5

local _instance
function ZhuanZhiBaoShi33.getInstance()
	if not _instance then
		_instance = ZhuanZhiBaoShi33:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiBaoShi33.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiBaoShi33:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiBaoShi33.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiBaoShi33.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiBaoShi33.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiBaoShi33:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiBaoShi33.GetLayoutFileName()
	return "zhuanzhibaoshi33.layout"
end

function ZhuanZhiBaoShi33:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiBaoShi33)
	return self
end

function ZhuanZhiBaoShi33:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	self.m_GemList = winMgr:getWindow("zhuanzhibaoshi/di1/list")

	self.m_CurGem = CEGUI.toItemCell(winMgr:getWindow("zhuanzhibaoshi/di2/baoshi1"))
	self.m_CurGemText = winMgr:getWindow("zhuanzhibaoshi/di2/text1")
	self.m_CurGemText:setText("")
    
	self.m_Cur1Gem = CEGUI.toItemCell(winMgr:getWindow("zhuanzhibaoshi/di2/baoshi11"))
	self.m_Cur1GemText = winMgr:getWindow("zhuanzhibaoshi/di2/text11")
	self.m_Cur1GemText:setText("")
	
	self.m_NextGem = CEGUI.toItemCell(winMgr:getWindow("zhuanzhibaoshi/di2/baoshi2"))
	self.m_NextGemText = winMgr:getWindow("zhuanzhibaoshi/di2/text2")
	self.m_NextGemText:setText("")

	self.nMaxGemLevel = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(333).value)

	self.m_GemListBtn = CEGUI.toPushButton(winMgr:getWindow("zhuanzhibaoshi/gemlist"))
	self.m_GemListBtn:subscribeEvent("MouseButtonUp", ZhuanZhiBaoShi33.HandlerSelectGemList, self)

	self.m_TransfromBtn = CEGUI.toPushButton(winMgr:getWindow("zhuanzhibaoshi/btn"))
	self.m_TransfromBtn:subscribeEvent("MouseButtonUp", ZhuanZhiBaoShi33.HandlerTransfromBtn, self)

	self.m_CurYinBi = winMgr:getWindow("zhuanzhibaoshi/kuang1/di1/text1")
	self.m_CurYinBi:setText(formatMoneyString(roleItemManager:GetPackMoney()))

	self.m_ChaJia = winMgr:getWindow("zhuanzhibaoshi/kuang1/di1/text")
	self.m_ChaJia:setText("0")

	self.m_ChaJiaText = winMgr:getWindow("zhuanzhibaoshi/kuang1/box")
	self.m_ChaJiaText:setText("")

	self.m_TextInfo = CEGUI.toRichEditbox(winMgr:getWindow("zhuanzhibaoshi/rest"))

	self.m_LeftExchangeTimes = 999---��ʯ�ϳɴ���������ʾ

	self.m_BaoshiChaJia = 0

	self.m_CurGemQulity = -1
	self.m_CurGemID = -1
	self.m_Cur1GemID = -1

	self.m_NextGemID = -1

	GEM_LEVEL_LIMIT = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(436).value)

    Commontipdlg.DestroyDialog()
	self:initGemList()

	--����ʯ������ʣ��ת������
	--local cmd = require "protodef.fire.pb.school.change.cchangeschoolextinfo".Create()
	local cmd = 5
	LuaProtocolManager.getInstance():send(cmd)

	--�����̻��б�ʯ�ļ۸�
	local p = require("protodef.fire.pb.shop.crequstshopprice"):new()
	p.shopid = SHOP_TYPE.COMMERCE
	LuaProtocolManager:send(p)
end

function ZhuanZhiBaoShi33:HandlerTransfromBtn(e)
	if self.m_CurGemID == -1 then
		GetCTipsManager():AddMessageTipById(192298)
		return
	end

	if self.m_LeftExchangeTimes == 0 then
		GetCTipsManager():AddMessageTipById(174010)
		return
	end

	if self.m_BaoshiChaJia < 0 then
		local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		if roleItemManager:GetPackMoney() < math.abs(self.m_BaoshiChaJia) then
			GetCTipsManager():AddMessageTipById(120025)
			return
		end
	end
	
		local xianzhi = BeanConfigManager.getInstance():GetTableByName("item.CGemEffect"):getRecorder(self.m_CurGemID)
	if  xianzhi.ngemtype == 20  then
		GetCTipsManager():AddMessageTipById(192299)
		return false
	end
	

	-- local dlg = require "logic.zhuanzhi.zhuanzhibaoshiconfrimdlg33".getInstanceAndShow()
	-- if dlg then
		local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_CurGemID)
		if not itemAttrCfg1 then
			return
		end

		local itemAttrCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_NextGemID)
		if not itemAttrCfg2 then
			return
		end

		local gemItemkey = 0
		for i = 1, #self.vTableId do
			if self.vTableId[i] == self.m_CurGemID then
				gemItemkey = self.vGemKey[i]
				break
			end
		end

	local cmd = require "protodef.fire.pb.school.change.cchangegem33".Create()
	cmd.gemkey = gemItemkey
	cmd.newgemitemid = self.m_NextGemID
	LuaProtocolManager.getInstance():send(cmd)
		-- dlg:SetInfoData(itemAttrCfg1.name, itemAttrCfg2.name, gemItemkey, self.m_NextGemID)
	-- end
end

function ZhuanZhiBaoShi33:HandlerSelectGemList(e)
	if self.m_CurGemQulity == -1 or self.m_CurGemID == -1 then
		GetCTipsManager():AddMessageTipById(192298)
		return
	end

	local dlg = require "logic.zhuanzhi.zhuanzhibaoshilist".getInstanceAndShow()
	if dlg then
		dlg:SetData(self.m_CurGemQulity, self.m_CurGemID)
	end
end

function ZhuanZhiBaoShi33:RefreshAllGemData()
	self.m_CurGemQulity = -1
	self.m_CurGemID = -1

	self.m_NextGemID = -1

	if self.m_LeftExchangeTimes ~= 0 then
		self.m_LeftExchangeTimes = self.m_LeftExchangeTimes - 1
	end

	self:SetTransformTimesText()

	self.m_CurGem:SetImage(nil)
	self.m_CurGemText:setText("")
	SetItemCellBoundColorByQulityItemtm(self.m_CurGem, 0)
	
	self.m_Cur1Gem:SetImage(nil)
	self.m_Cur1GemText:setText("")
	SetItemCellBoundColorByQulityItemtm(self.m_Cur1Gem, 0)
	self.m_NextGem:SetImage(nil)
	self.m_NextGemText:setText("")
	SetItemCellBoundColorByQulityItemtm(self.m_NextGem, 0)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.m_CurYinBi:setText(formatMoneyString(roleItemManager:GetPackMoney()))

	self.m_ChaJia:setText("0")
	self.m_ChaJiaText:setText("")

	self:initGemList()
end

function ZhuanZhiBaoShi33:initGemList()
	self.mapGemTabIdNum = { }
	self.vGemKey = { }
	local keys = {}
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	keys = roleItemManager:GetItemKeyListByType(keys, eItemType_GEM, fire.pb.item.BagTypes.BAG)
	self.vTableId = { }
	self:GetTableIdArray(keys)
	self:GetMapIdNum(self.mapGemTabIdNum)

	if self.m_tableview then
		self.itemOffect = self.m_tableview:getContentOffset()
	end

	local len = #self.vTableId
	if not self.m_tableview then
		local s = self.m_GemList:getPixelSize()
		self.m_tableview = TableView.create(self.m_GemList)
		self.m_tableview:setViewSize(s.width, s.height)
		self.m_tableview:setPosition(0, 0)
		self.m_tableview:setDataSourceFunc(self, ZhuanZhiBaoShi33.tableViewGetCellAtIndex)
	end
	self.m_tableview:setCellCountAndSize(len, 370, 113)
	self.m_tableview:setContentOffset(self.itemOffect or 0)
	self.m_tableview:reloadData()

end

function ZhuanZhiBaoShi33:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        cell = ZhuanZhiBaoShiCell33.CreateNewDlg(tableView.container, tableView:genCellPrefix())
        cell.btnBg:subscribeEvent("MouseClick", ZhuanZhiBaoShi33.HandleClickedItem,self)
    end
    self:setGemCellInfo(cell, idx+1)
    return cell
end

function ZhuanZhiBaoShi33:setGemCellInfo(cell, index)
    local objData = self.mapGemTabIdNum[index]
	local nTabId = objData.nGemId
	local nNum = objData.nNum
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nTabId)
	if not itemAttrCfg then
		return
	end
    cell.btnBg:setID(nTabId)
	local nLevel = itemAttrCfg.level
	cell.name:setText(itemAttrCfg.namec)
	cell.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(cell.itemCell, itemAttrCfg.id)
	cell.num = nNum 
	local gemconfig = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nTabId)
    if gemconfig then
	    local strEffect = gemconfig.effectdes --gemconfig.inlayeffect
	    cell.describe:setText(strEffect)
    end
	cell.itemCell:SetTextUnit(nNum)
	if self.nItemCellSelId ==0 then
		self.nItemCellSelId = nTabId
	end
    if self.nItemCellSelId ~= nTabId then
        cell.btnBg:setSelected(false)
    else
        cell.btnBg:setSelected(true)
    end
    
end


function ZhuanZhiBaoShi33:GetTableIdArray(vGemKey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for i = 0, vGemKey:size() - 1 do
		local baggem = roleItemManager:FindItemByBagAndThisID(vGemKey[i], fire.pb.item.BagTypes.BAG)
		if baggem then
			local nTableId = baggem:GetObjectID()
			local itemAttrCfg = baggem:GetBaseObject()
			local nLevel = itemAttrCfg.level
			if nLevel <= self.nMaxGemLevel and nLevel >= GEM_LEVEL_LIMIT then
				local bHave = self:IsHaveGemTableId(nTableId)
				if bHave==false then
					self.vTableId[#self.vTableId + 1] = nTableId
					self.vGemKey[#self.vGemKey + 1] = vGemKey[i]
				end
			end
		end
	end
end

function ZhuanZhiBaoShi33:IsHaveGemTableId(nTableId)
	for nIndex=1,#self.vTableId do 
		local nId = self.vTableId[nIndex]
		if nId==nTableId then 
			return true
		end
	end
	return false
end

function ZhuanZhiBaoShi33:GetMapIdNum(mapGemTabIdNum)
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
        local gemConfig =  BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nGemId)
        
		local nOrderHeight = nNum * 10000
		nOrderHeight = nOrderHeight + (1000-nLevel)
		mapGemTabIdNum[nIndex].nOrderHeight = nOrderHeight
        mapGemTabIdNum[nIndex].level = itemAttrCfg.level
        mapGemTabIdNum[nIndex].gemType = gemConfig.ngemtype
	end
    self:sortCell(mapGemTabIdNum)
end


function ZhuanZhiBaoShi33:sortCell(gemTable)
     local function _sort(a, b)
        if a.gemType == b.gemType then
            return a.level < b.level
        end
        return a.gemType < b.gemType
    end
	table.sort(gemTable, _sort)
end

function ZhuanZhiBaoShi33:HandleClickedItem(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
    local id = mouseArgs.window:getID()
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
	if not itemAttrCfg then
		return
	end
	self.m_CurGem:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
	self.m_CurGemText:setText(itemAttrCfg.namec)
	SetItemCellBoundColorByQulityItemWithIdtm(self.m_CurGem, itemAttrCfg.id)
	
	self.m_Cur1Gem:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
	self.m_Cur1GemText:setText(itemAttrCfg.namec)
	SetItemCellBoundColorByQulityItemWithIdtm(self.m_CurGem, itemAttrCfg.id)
	self.m_CurGemQulity = itemAttrCfg.level
	self.m_CurGemID = itemAttrCfg.id

	local itemtoCfg = BeanConfigManager.getInstance():GetTableByName("item.CEquipCombin"):getRecorder(itemAttrCfg.id)
	local itemAttrCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemtoCfg.nextequipid)
	if not itemAttrCfg2 then
		return
	end

	self.m_NextGem:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg2.icon))
	self.m_NextGemText:setText(itemAttrCfg2.namec)
	SetItemCellBoundColorByQulityItemWithIdtm(self.m_NextGem, itemAttrCfg2.id)
	self.m_NextGemID = itemAttrCfg2.id

	-- if self.m_NextGemID ~= -1 then
		-- self:CalculateChaJia()
	-- end

end

function ZhuanZhiBaoShi33:SetNextGemData(id)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
	if not itemAttrCfg then
		return
	end
	self.m_NextGem:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
	self.m_NextGemText:setText(itemAttrCfg.namec)
	SetItemCellBoundColorByQulityItemWithIdtm(self.m_NextGem, itemAttrCfg.id)

	self.m_NextGemID = itemAttrCfg.id

	self:CalculateChaJia()
end

function ZhuanZhiBaoShi33:CalculateChaJia()
	local idx1 = self.m_CurGemID - BaoShiLvStartID[self.m_CurGemQulity] + 1
	local idx2 = self.m_NextGemID - BaoShiLvStartID[self.m_CurGemQulity] + 1

	local conf1 = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(BaoShiShopStartID[idx1])
	if not conf1 then
		return
	end

	local conf2 = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(BaoShiShopStartID[idx2])
	if not conf2 then
		return
	end

	local Price1 = ShopManager.goodsPrices[BaoShiShopStartID[idx1]] or conf1.prices[0]
	local Price2 = ShopManager.goodsPrices[BaoShiShopStartID[idx2]] or conf2.prices[0]

	Price1 = Price1 * math.pow(2,self.m_CurGemQulity - 1)
	Price2 = Price2 * math.pow(2,self.m_CurGemQulity - 1)
	
	local value = Price1 - Price2

	self.m_BaoshiChaJia = value
	
	if value >= 0 then
		self.m_ChaJiaText:setText(GameTable.common.GetCCommonTableInstance():getRecorder(457).value)
	else
		self.m_ChaJiaText:setText(GameTable.common.GetCCommonTableInstance():getRecorder(456).value)
	end
	
	self.m_ChaJia:setText(tostring(math.abs(value)))
end

function ZhuanZhiBaoShi33:SetTransformTimes(times)
	self.m_LeftExchangeTimes = times

	self:SetTransformTimesText()
end

function ZhuanZhiBaoShi33:SetTransformTimesText()
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(174009)

	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", self.m_LeftExchangeTimes)
	local strmsg = sb:GetString(tip.msg)
	sb:delete()

	self.m_TextInfo:Clear()
	self.m_TextInfo:AppendParseText(CEGUI.String(strmsg), false)
	self.m_TextInfo:Refresh()
end








return ZhuanZhiBaoShi33
require "logic.dialog"
require "logic.zhuanzhi.zhuanzhiwuqicell"

WeaponSwitchDlg = {}
setmetatable(WeaponSwitchDlg, Dialog)
WeaponSwitchDlg.__index = WeaponSwitchDlg

local _instance
function WeaponSwitchDlg.getInstance()
	if not _instance then
		_instance = WeaponSwitchDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function WeaponSwitchDlg.getInstanceAndShow()
	if not _instance then
		_instance = WeaponSwitchDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function WeaponSwitchDlg.getInstanceNotCreate()
	return _instance
end

function WeaponSwitchDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function WeaponSwitchDlg.ToggleOpenClose()
	if not _instance then
		_instance = WeaponSwitchDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
			EquipSwitchConfrimDlg.DestroyDialog()
		else
			_instance:SetVisible(true)
		end
	end
end

function WeaponSwitchDlg.GetLayoutFileName()
	return "weaponswitch.layout"
end

function WeaponSwitchDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, WeaponSwitchDlg)
	return self
end

function WeaponSwitchDlg:OnCreate()


	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	self.m_WuqiList = winMgr:getWindow("weaponswitch/di1/list")

	self.wuqiScroll = CEGUI.toScrollablePane(winMgr:getWindow("weaponswitch/diban/scroll"))
	self.wuqiScroll:EnableAllChildDrag(self.wuqiScroll)
	self.wuqitable = CEGUI.toItemTable(winMgr:getWindow("weaponswitch/diban/mounttable"))
	self.wuqitable:subscribeEvent("TableClick", WeaponSwitchDlg.HandleClickedItem, self)


	self.m_CurWuqi = CEGUI.toItemCell(winMgr:getWindow("weaponswitch/di2/wuqi1"))
	self.m_CurWuqiText = winMgr:getWindow("weaponswitch/di2/text1")
	self.m_CurWuqiText:setText("")

	self.m_CurWuqiText11 = winMgr:getWindow("weaponswitch/di2/text11")
	self.m_CurWuqiText11:setText("")
	self.m_NextWuqiText12 = winMgr:getWindow("weaponswitch/di2/text12")
	self.m_NextWuqiText12:setText("")


	self.wuqizhuanhuanBtn = CEGUI.toPushButton(winMgr:getWindow("weaponswitch/wuqizhuanhuan"))
	self.wuqizhuanhuanBtn:subscribeEvent("MouseButtonUp", WeaponSwitchDlg.HandlerwuqizhuanhuanBtn, self)

	self.baoshizhuanhuanBtn = CEGUI.toPushButton(winMgr:getWindow("weaponswitch/baoshizhuanhuan"))
	self.baoshizhuanhuanBtn:subscribeEvent("MouseButtonUp", WeaponSwitchDlg.HandlerbaoshizhuanhuanBtn, self)



	self.m_NextWuqi = CEGUI.toItemCell(winMgr:getWindow("weaponswitch/di2/wuqi2"))
	self.m_NextWuqi:subscribeEvent("MouseClick", WeaponSwitchDlg.HandleClickedToItem,self)
	self.m_NextWuqiText = winMgr:getWindow("weaponswitch/di2/text2")
	self.m_NextWuqiText:setText("")
	self.ownStoneNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
	self.m_CurYinBi = winMgr:getWindow("weaponswitch/kuang1/di1/text1")
	self.m_CurYinBi:setText(self.ownStoneNum)
	
	self.m_CurCosumeIcon = CEGUI.toItemCell(winMgr:getWindow("weaponswitch/kuang1/di1/image11"))
	
	self.m_NeedMoneyText = "0"

	self.m_NeedItem = winMgr:getWindow("weaponswitch/kuang1/di1/text")
	self.m_NeedItem:setText(self.m_NeedMoneyText)
	
	self.m_NeedCosumeIcon = CEGUI.toItemCell(winMgr:getWindow("weaponswitch/kuang1/di1/image1"))


	self.m_TransfromBtn = CEGUI.toPushButton(winMgr:getWindow("weaponswitch/btn"))
	self.m_TransfromBtn:subscribeEvent("MouseButtonUp", WeaponSwitchDlg.HandlerTransfromBtn, self)

	--self.m_TextInfo = CEGUI.toRichEditbox(winMgr:getWindow("weaponswitch/rest"))

	self.m_WeaponInfo = CEGUI.toRichEditbox(winMgr:getWindow("weaponswitch/di2/wiqishuxing"))
	self.m_WeaponInfo1 = CEGUI.toRichEditbox(winMgr:getWindow("weaponswitch/di2/wiqishuxing2"))	

	-- local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(174014)
	-- self.m_ShuoMing = CEGUI.toRichEditbox(winMgr:getWindow("weaponswitch/di3/shuoming"))
	-- self.m_ShuoMing:AppendParseText(CEGUI.String(tip.msg))
	-- self.m_ShuoMing:Refresh()
	-- self.m_ShuoMing:getVertScrollbar():setScrollPosition(0)
	-- self.m_ShuoMing:setShowVertScrollbar(true)

	self.m_ShowCanToListBtn = CEGUI.toPushButton(winMgr:getWindow("weaponswitch/tocanlist"))
	self.m_ShowCanToListBtn:subscribeEvent("MouseButtonUp", WeaponSwitchDlg.HandlerSelectToEquipList, self)

	self.ToCanList = winMgr:getWindow("weaponswitch/equipswitchlist")
	self.ToCanList:setVisible(false)

	self.m_WeaponList = CEGUI.toScrollablePane(winMgr:getWindow("weaponswitch/equipswitchlist/list"))

	self.nItemCellSelId = 0

	self.m_CurWeaponID = -1
	self.m_ToWeaponID = -1


	self.m_LeftExchangeTimes = 0

	self.m_OldClass = 0
	self.m_NextWeaponIndex = -1

	--�����ְҵ�б�
	--local cmd1 = require "protodef.fire.pb.school.change.coldschoollist".Create()
	--LuaProtocolManager.getInstance():send(cmd1)
	self:initWeaponList()
	
	--����ʯ������ʣ��ת������
--	local cmd2 = require "protodef.fire.pb.school.change.cchangeschoolextinfo".Create()
--	LuaProtocolManager.getInstance():send(cmd2)
end

function WeaponSwitchDlg:HandlerwuqizhuanhuanBtn(e)
	

end
function WeaponSwitchDlg:HandlerbaoshizhuanhuanBtn(e)
	ZhuanZhiBaoShi.getInstanceAndShow() 
	WeaponSwitchDlg.DestroyDialog()

end
function WeaponSwitchDlg:SetOldSchoolList(schoollist, classlist)
	self.m_OldClass = classlist[#classlist]

	self:initWeaponList()
end

function WeaponSwitchDlg:RefreshAllWeaponData()

	self.m_CurWuqi:SetImage(nil)
	self.m_CurWuqiText:setText("")
	self.m_CurWuqiText11:setText("")
	SetItemCellBoundColorByQulityItem(self.m_CurWuqi, 0)

	self.m_NextWuqi:SetImage(nil)
	self.m_NextWuqi:SetSelected(false)
	self.m_NextWuqiText:setText("")
	self.m_NextWuqiText12:setText("")
	SetItemCellBoundColorByQulityItem(self.m_NextWuqi, 0)

	self.m_CurWeaponID = -1
	self.m_NextWeaponIndex = -1

	self.m_WeaponInfo:Clear()
	self.m_WeaponInfo:Refresh()
	self.m_WeaponInfo1:Clear()
	self.m_WeaponInfo1:Refresh()	

	if self.m_LeftExchangeTimes ~= 0 then
		self.m_LeftExchangeTimes = self.m_LeftExchangeTimes - 1
	end

	self:SetTransformTimesText()

	self:initWeaponList()
end
function WeaponSwitchDlg:initWeaponList()
	self.vWeaponKey = { }
	local keys = {}
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	--keys = roleItemManager:GetItemKeyListByType(keys, eItemType_EQUIP, fire.pb.item.BagTypes.BAG)
	keys = roleItemManager:GetWeaponList(fire.pb.item.BagTypes.BAG)

	self.vTableId = { }
	
	self:GetTableIdArray(keys)

	if self.m_tableview then
		self.itemOffect = self.m_tableview:getContentOffset()
	end

	local num = #self.vTableId
	local row = math.ceil(num/3)
	self.cells={}
	self.cellitem={}

	if self.wuqitable:GetRowCount() < row then
		self.wuqitable:SetRowCount(row)
		local h = self.wuqitable:GetCellHeight()
		local spaceY = self.wuqitable:GetSpaceY()
		local newHeight = (h+spaceY)*row + 5
		self.wuqitable:setHeight(CEGUI.UDim(0, newHeight))
	end
	-- for i=1,self.wuqitable:GetCellCount() do
	-- 	local cell = self.wuqitable:GetCell(i-1)
	-- 	cell:Clear()
	-- 	cell:setVisible(false)
	-- end
	
	
	for i, item in pairs(self.vTableId) do
		local cell = self.wuqitable:GetCell(i-1)
		cell:Clear()
		cell:SetHaveSelectedState(true)
		if i <= num then
			-- local itemAttrCfg = item:GetBaseObject()
			local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.CItemAttr"):getRecorder(item)
			local image = gGetIconManager():GetImageByID(itemAttrCfg.icon)
			cell:SetImage(image)
			cell:setID(itemAttrCfg.id)
			cell:setID2(keys[i-1])
			self:setGemCellInfo(cell, keys[i-1])
			--cell:subscribeEvent("MouseClick", WeaponSwitchDlg.HandleClickedItem,self)
            SetItemCellBoundColorByQulityPet(cell, itemAttrCfg.nquality)
            self.wuqiScroll:EnableChildDrag(cell)
			self.cells[itemAttrCfg.id]=cell
			self.cellitem[itemAttrCfg.id]=item
			if  roleItemManager:getRideItemId()==itemAttrCfg.id then
				cell:SetCornerImageAtPos("common_equip", "equip_biaoqian2", 0, 0.8,5,5)
			 end
			 cell:setVisible(true)
		else
			cell:setVisible(true)
		end
	end
	--self:refreshSelectedMount()


	--self.wuqitable:setDataSourceFunc(self, WeaponSwitchDlg.tableViewGetCellAtIndex)





	-- local len = #self.vTableId
	-- if not self.m_tableview then
	-- 	local s = self.m_WuqiList:getPixelSize()
	-- 	self.m_tableview = TableView.create(self.m_WuqiList)
	-- 	self.m_tableview:setViewSize(s.width, s.height)
	-- 	self.m_tableview:setPosition(0, 0)
	-- 	self.m_tableview:setDataSourceFunc(self, WeaponSwitchDlg.tableViewGetCellAtIndex)
	-- end
	-- self.m_tableview:setCellCountAndSize(len, 370, 113)
	-- self.m_tableview:setContentOffset(self.itemOffect or 0)
	-- self.m_tableview:reloadData()

end

function WeaponSwitchDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        cell = ZhuanZhiWuQiCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
        cell.btnBg:subscribeEvent("MouseClick", WeaponSwitchDlg.HandleClickedItem,self)
    end
    self:setGemCellInfo(cell, idx+1)
    return cell
end

function WeaponSwitchDlg:setGemCellInfo(cell, index)
	local nTabId = self.vTableId[index]
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nTabId)
	if not itemAttrCfg then
		return
	end
    --cell.btnBg:setID(nTabId)
	--cell.btnBg:setID2(self.vWeaponKey[index])
	--cell.name:setText(itemAttrCfg.name)
	--cell.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    --SetItemCellBoundColorByQulityItemWithId(cell.itemCell, itemAttrCfg.id)

	if self.nItemCellSelId ==0 then
		self.nItemCellSelId = nTabId
	end

    -- if self.nItemCellSelId ~= nTabId then
    --     cell.btnBg:setSelected(false)
    -- else
    --     cell.btnBg:setSelected(true)
    -- end
    
end

function WeaponSwitchDlg:GetTableIdArray(vEquipKey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local needlv = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(434).value)
	for i = 0, vEquipKey:size() -1 do
		local bagequip = roleItemManager:FindItemByBagAndThisID(vEquipKey[i], fire.pb.item.BagTypes.BAG)
		if bagequip then
			local nTableId = bagequip:GetObjectID()
			local itemAttrCfg = bagequip:GetBaseObject()
			local switchcfg = BeanConfigManager.getInstance():GetTableByName("item.cequiptoequipex"):getRecorder(itemAttrCfg.id)
			if switchcfg then
			 	self.vTableId[#self.vTableId + 1] = nTableId
				self.vWeaponKey[#self.vWeaponKey + 1] = vEquipKey[i]


			end
		end
	end
end

function WeaponSwitchDlg:HandleClickedItem(e)

	local id = CEGUI.toWindowEventArgs(e).window:getID()
	local key = CEGUI.toWindowEventArgs(e).window:getID2()

	


	local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
	local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    self.m_curweaponKey= key
	if not itemAttrCfg1 then
		return
	end

	self.m_CurWeaponID = id
	self.m_ToWeaponID = -1

	self.m_CurWuqi:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg1.icon))
	self.m_CurWuqiText:setText(itemAttrCfg1.name)
	self.m_CurWuqiText11:setText(itemAttrCfg1.level.."级")
	SetItemCellBoundColorByQulityItemWithId(self.m_CurWuqi, itemAttrCfg1.id)

	self.m_NeedItem:setText("0")
	self.m_NeedMoneyText = formatMoneyString(0)

	self.m_NextWuqi:SetImage(nil)
	self.m_NextWuqi:SetSelected(false)
	self.m_NextWuqiText:setText("")
	self.m_NextWuqiText12:setText("")
	self.m_WeaponInfo1:Clear()
	self.m_WeaponInfo1:Refresh()
	
	self:ShowWeaponProperty(key)
	self:RefreshToItemInfo()
	self.ToCanList:setVisible(false)
end

function WeaponSwitchDlg:ShowWeaponProperty(wid)
	self.m_WeaponInfo:Clear()

	local Itemkey = wid
--	for i = 1, #self.vTableId do
--		if self.vTableId[i] == wid then
--			Itemkey = self.vWeaponKey[i]
--			break
--		end
--	end  

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(Itemkey, fire.pb.item.BagTypes.BAG)
 
	local pObj = nil
	if pItem then
		print("走这里====>%d",pItem:GetBaseObject().id)
		pObj = pItem:GetObject()
		local vcBaseKey = pObj:GetBaseEffectAllKey()
		local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff261407"))
		local color_blue = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF00b1ff"))
		for nIndex = 1, #vcBaseKey do
			local nBaseId = vcBaseKey[nIndex]
			local nBaseValue = pObj:GetBaseEffect(nBaseId)

			if nBaseValue ~= 0 then
				local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
				if propertyCfg and propertyCfg.id ~= -1 then
					local strTitleName = propertyCfg.name
					local nValue = math.abs(nBaseValue)
					if nBaseValue > 0 then
						strTitleName = strTitleName .. " " .. "+" .. tostring(nValue)
					elseif nBaseValue < 0 then
						strTitleName = strTitleName .. " " .. "-" .. tostring(nValue)
					end
					strTitleName = "  " .. strTitleName
					strTitleName = CEGUI.String(strTitleName)
					self.m_WeaponInfo:AppendText(strTitleName, color)
					self.m_WeaponInfo:AppendBreak()
				end
			end
		end

		local vPlusKey = pObj:GetPlusEffectAllKey()
		for nIndex = 1, #vPlusKey do
			local nPlusId = vPlusKey[nIndex]
			local mapPlusData = pObj:GetPlusEffect(nPlusId)
			if mapPlusData.attrvalue ~= 0 then

				local nPropertyId = mapPlusData.attrid
				local nPropertyValue = mapPlusData.attrvalue
				local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
				if propertyCfg and propertyCfg.id ~= -1 then
					local strTitleName = propertyCfg.name
					local nValue = math.abs(nPropertyValue)
					if nPropertyValue > 0 then
						strTitleName = strTitleName .. " " .. "+" .. tostring(nValue)
					else
						strTitleName = strTitleName .. " " .. "-" .. tostring(nValue)
					end
					local strEndSpace = "  "
					local strBeginSpace = "  "
					strTitleName = strTitleName .. strEndSpace
					strTitleName = strBeginSpace .. strTitleName

					strTitleName = CEGUI.String(strTitleName)
					self.m_WeaponInfo:AppendText(strTitleName, color_blue)
					self.m_WeaponInfo:AppendBreak();
				end
			end
			-- if end
		end
		
		-- for end
    local NORMAL_CC = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFd200ff"))



	local nTexiaoId = pObj.skilleffect
    local nTejiId = pObj.skillid
	
    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
    if texiaoTable and texiaoTable.id ~= -1 then
        local strTeXiaozi = require "utils.mhsdutils".get_resstring(11811)
        strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name

        strTeXiaozi = CEGUI.String(strTeXiaozi)
        self.m_WeaponInfo:AppendText(strTeXiaozi, NORMAL_CC)
        self.m_WeaponInfo:AppendBreak();
    end


    local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
    if tejiTable and tejiTable.id ~= -1 then
         local strTejizi = require "utils.mhsdutils".get_resstring(11812)
         strTejizi = "  "..strTejizi.." "..tejiTable.name

         strTejizi = CEGUI.String(strTejizi)
         self.m_WeaponInfo:AppendText(strTejizi, NORMAL_CC)
         self.m_WeaponInfo:AppendBreak();
    end
	


		self.m_WeaponInfo:Refresh()
	end
end

function WeaponSwitchDlg:SetTransformTimes(times)
	self.m_LeftExchangeTimes = times
	self:SetTransformTimesText()
end

function WeaponSwitchDlg:ShowWeaponProperty1()
	self.m_WeaponInfo1:Clear()

	local Itemkey = self.m_curweaponKey
--	for i = 1, #self.vTableId do
--		if self.vTableId[i] == wid then
--			Itemkey = self.vWeaponKey[i]
--			break
--		end
--	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(Itemkey, fire.pb.item.BagTypes.BAG)
	local pObj = nil
	if pItem then
		pObj = pItem:GetObject()
		local vcBaseKey = pObj:GetBaseEffectAllKey()
		local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff261407"))
		local color_blue = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF00b1ff"))
		for nIndex = 1, #vcBaseKey do
			local nBaseId = vcBaseKey[nIndex]
			local nBaseValue = pObj:GetBaseEffect(nBaseId)

			if nBaseValue ~= 0 then
				local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
				if propertyCfg and propertyCfg.id ~= -1 then
					local strTitleName = propertyCfg.name
					local nValue = math.abs(nBaseValue)
					if nBaseValue > 0 then
						strTitleName = strTitleName .. " " .. "+" .. tostring(nValue)
					elseif nBaseValue < 0 then
						strTitleName = strTitleName .. " " .. "-" .. tostring(nValue)
					end
					strTitleName = "  " .. strTitleName
					strTitleName = CEGUI.String(strTitleName)
					self.m_WeaponInfo1:AppendText(strTitleName, color)
					self.m_WeaponInfo1:AppendBreak()
				end
			end
		end

		local vPlusKey = pObj:GetPlusEffectAllKey()
		for nIndex = 1, #vPlusKey do
			local nPlusId = vPlusKey[nIndex]
			local mapPlusData = pObj:GetPlusEffect(nPlusId)
			if mapPlusData.attrvalue ~= 0 then

				local nPropertyId = mapPlusData.attrid
				local nPropertyValue = mapPlusData.attrvalue
				local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
				if propertyCfg and propertyCfg.id ~= -1 then
					local strTitleName = propertyCfg.name
					local nValue = math.abs(nPropertyValue)
					if nPropertyValue > 0 then
						strTitleName = strTitleName .. " " .. "+" .. tostring(nValue)
					else
						strTitleName = strTitleName .. " " .. "-" .. tostring(nValue)
					end
					local strEndSpace = "  "
					local strBeginSpace = "  "
					strTitleName = strTitleName .. strEndSpace
					strTitleName = strBeginSpace .. strTitleName

					strTitleName = CEGUI.String(strTitleName)
					self.m_WeaponInfo1:AppendText(strTitleName, color_blue)
					self.m_WeaponInfo1:AppendBreak();
				end
			end
			-- if end
		end
		
		-- for end
    local NORMAL_CC = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFd200ff"))



	local nTexiaoId = pObj.skilleffect
    local nTejiId = pObj.skillid
	
    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
    if texiaoTable and texiaoTable.id ~= -1 then
        local strTeXiaozi = require "utils.mhsdutils".get_resstring(11811)
        strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name

        strTeXiaozi = CEGUI.String(strTeXiaozi)
        self.m_WeaponInfo1:AppendText(strTeXiaozi, NORMAL_CC)
        self.m_WeaponInfo1:AppendBreak();
    end


    local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
    if tejiTable and tejiTable.id ~= -1 then
         local strTejizi = require "utils.mhsdutils".get_resstring(11812)
         strTejizi = "  "..strTejizi.." "..tejiTable.name

         strTejizi = CEGUI.String(strTejizi)
         self.m_WeaponInfo1:AppendText(strTejizi, NORMAL_CC)
         self.m_WeaponInfo1:AppendBreak();
    end
	


		self.m_WeaponInfo1:Refresh()
	end
end

function WeaponSwitchDlg:SetTransformTimesText()
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(174013)

	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", self.m_LeftExchangeTimes)
	local strmsg = sb:GetString(tip.msg)
	sb:delete()

	-- self.m_TextInfo:Clear()
	-- self.m_TextInfo:AppendParseText(CEGUI.String(strmsg), false)
	-- self.m_TextInfo:Refresh()
end

function WeaponSwitchDlg:HandlerTransfromBtn(e)
	if self.m_CurWeaponID == -1 then
		GetCTipsManager():AddMessageTipById(174023)
		return
	end

	if self.m_ToWeaponID == -1 then
		GetCTipsManager():AddMessageTipById(174023)
		return
	end

	local switchcfg = BeanConfigManager.getInstance():GetTableByName("item.cequiptoequipex"):getRecorder(self.m_CurWeaponID)
	if not switchcfg then
		return
	end

	--local itemNeedAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(switchcfg.needitemid)
	--if not itemNeedAttrCfg then
	--	return
	--end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local curNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
	if curNum < switchcfg.needitemcount then
		GetCTipsManager():AddMessageTipById(160118) --金币不足
		return
	end

	local roleItem = roleItemManager:GetBagItem(self.m_curweaponKey)

	local equipObj = roleItem:GetObject()
	local gemlist = equipObj:GetGemlist()
	if gemlist:size() > 0 then
		GetCTipsManager():AddMessageTipById(191164) --镶嵌宝石的装备不能
		return
	end

	local dlg = require "logic.workshop.equipswitchexconfrimdlg".getInstanceAndShow()
	if dlg then
		local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_CurWeaponID)
		if not itemAttrCfg1 then
			return
		end

		local itemAttrCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_ToWeaponID)
		if not itemAttrCfg2 then
			return
		end

		local Itemkey = 0
		for i = 1, #self.vTableId do
			if self.vTableId[i] == self.m_CurWeaponID then
				Itemkey = self.vWeaponKey[i]
				break
			end
		end
		dlg:SetInfoData(itemAttrCfg1.name,itemAttrCfg2.name,Itemkey, self.m_ToWeaponID ,switchcfg.needitemcount)
	end
end

function WeaponSwitchDlg:HandleClickedToItem(args)

	self:RefreshToItemInfo()
end

function WeaponSwitchDlg:RefreshToItemInfo()
	if self.m_CurWeaponID < 0 then
		return 
	end
	
	local switchcfg = BeanConfigManager.getInstance():GetTableByName("item.cequiptoequipex"):getRecorder(self.m_CurWeaponID)
	if not switchcfg then
		return
	end

	--local costitemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(switchcfg.needitemid)
	--print("costitemAttr.icon==============>%s",costitemAttr.icon)
   -- if costitemAttr then
      --  local costitemimage = gGetIconManager():GetImageByID(costitemAttr.icon)

		-- print("costitemimage==============>%s",costitemimage)
        -- self.m_NeedCosumeIcon:SetImage(costitemimage)
        -- self.m_CurCosumeIcon:SetImage(costitemimage)
   -- end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local curNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
	self.m_CurYinBi:setText(curNum)
	local neednum = switchcfg.needitemcount 
	
	self.m_NeedItem:setText(formatMoneyString(neednum))
	self.m_NeedMoneyText = formatMoneyString(neednum)

end

function WeaponSwitchDlg:RefreshFormInfo()
	self:RefreshAllWeaponData()
	self.m_NeedItem:setText("0")
	local curNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
	self.m_CurYinBi:setText(curNum)
	
end

function WeaponSwitchDlg:HandlerSelectToEquipList(e)
	if self.m_CurWeaponID == -1 then
		GetCTipsManager():AddMessageTipById(191263)
		return
	end

	self.ToCanList:setVisible(true)

	self:ShowToCanList(self.m_CurWeaponID)
	
end

function WeaponSwitchDlg:SetNextEquipData(id)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
	if not itemAttrCfg then
		return
	end
	self.m_NextWuqi:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
	self.m_NextWuqiText:setText(itemAttrCfg.name)
	self.m_NextWuqiText12:setText(itemAttrCfg.level.."级")
	self.m_ToWeaponID = itemAttrCfg.id

	SetItemCellBoundColorByQulityItemWithId(self.m_NextWuqi, itemAttrCfg.id)
  
end


function WeaponSwitchDlg:ShowToCanList(weaponid)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local switchcfg = BeanConfigManager.getInstance():GetTableByName("item.cequiptoequipex"):getRecorder(weaponid)
	if not switchcfg then
		return
	end
	local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(weaponid)
	self.m_WeaponList:cleanupNonAutoChildren()

	local count = 0
	for id = 0, #switchcfg.toitemlist do
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(switchcfg.toitemlist[id])
	 	if itemAttrCfg and  itemAttrCfg.id ~= itemAttrCfg1.id then
	 		local prefix = id + 10000

			local button = CEGUI.toPushButton(winMgr:loadWindowLayout("weaponswitchlistcell.layout", "" .. prefix))
			local itemCell = CEGUI.toItemCell(winMgr:getWindow(prefix .. "weaponswitchlistcell/daojukuang"))
			local name = winMgr:getWindow(prefix .. "weaponswitchlistcell/mingcheng")
			local describe = winMgr:getWindow(prefix .. "weaponswitchlistcell/miaoshu")

			name:setText(itemAttrCfg.name)
			itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
			SetItemCellBoundColorByQulityItemWithId(itemCell, itemAttrCfg.id)

			self.m_WeaponList:addChildWindow(button)

			button:setID(itemAttrCfg.id)

			button:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 2), CEGUI.UDim(0, 2 + count * button:getHeight():asAbsolute(0))))
	 		button:subscribeEvent("MouseClick", WeaponSwitchDlg.ChooseCanToWeapon, self)

	 		count = count + 1

		end
	end

end

function WeaponSwitchDlg:ChooseCanToWeapon(e)

	local wndArg = CEGUI.toWindowEventArgs(e)
	if not wndArg.window then
		return
	end
 
	local nId = wndArg.window:getID()

	self:SetNextEquipData(nId)
	self:ShowWeaponProperty1()
	self.ToCanList:setVisible(false)
	
end

return WeaponSwitchDlg
require "logic.dialog"
require "logic.zhuanzhi.zhuanzhiwuqicell"

ZhuanZhiWuQiDlg = {}
setmetatable(ZhuanZhiWuQiDlg, Dialog)
ZhuanZhiWuQiDlg.__index = ZhuanZhiWuQiDlg

local _instance
function ZhuanZhiWuQiDlg.getInstance()
	if not _instance then
		_instance = ZhuanZhiWuQiDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiWuQiDlg.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiWuQiDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiWuQiDlg.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiWuQiDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiWuQiDlg.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiWuQiDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiWuQiDlg.GetLayoutFileName()
	return "zhuanzhiwuqi.layout"
end

function ZhuanZhiWuQiDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiWuQiDlg)
	return self
end

function ZhuanZhiWuQiDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	self.m_WuqiList = winMgr:getWindow("zhuanzhiwuqi/di1/list")

	self.m_CurWuqi = CEGUI.toItemCell(winMgr:getWindow("zhuanzhiwuqi/di2/wuqi1"))
	self.m_CurWuqiText = winMgr:getWindow("zhuanzhiwuqi/di2/text1")
	self.m_CurWuqiText:setText("")

	self.m_NextWuqi = CEGUI.toItemCell(winMgr:getWindow("zhuanzhiwuqi/di2/wuqi2"))
	self.m_NextWuqiText = winMgr:getWindow("zhuanzhiwuqi/di2/text2")
	self.m_NextWuqiText:setText("")

	self.m_CurYinBi = winMgr:getWindow("zhuanzhiwuqi/kuang1/di1/text1")
	self.m_CurYinBi:setText(formatMoneyString(roleItemManager:GetPackMoney()))

	self.m_NeedMoneyText = GameTable.common.GetCCommonTableInstance():getRecorder(433).value

	self.m_NeedYinBi = winMgr:getWindow("zhuanzhiwuqi/kuang1/di1/text")
	self.m_NeedYinBi:setText(formatMoneyString(self.m_NeedMoneyText))

	self.m_TransfromBtn = CEGUI.toPushButton(winMgr:getWindow("zhuanzhiwuqi/btn"))
	self.m_TransfromBtn:subscribeEvent("MouseButtonUp", ZhuanZhiWuQiDlg.HandlerTransfromBtn, self)

	self.m_TextInfo = CEGUI.toRichEditbox(winMgr:getWindow("zhuanzhiwuqi/rest"))

	self.m_WeaponInfo = CEGUI.toRichEditbox(winMgr:getWindow("zhuanzhiwuqi/di2/wiqishuxing"))

	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(174014)
	self.m_ShuoMing = CEGUI.toRichEditbox(winMgr:getWindow("zhuanzhiwuqi/di3/shuoming"))
	self.m_ShuoMing:AppendParseText(CEGUI.String(tip.msg))
	self.m_ShuoMing:Refresh()
	self.m_ShuoMing:getVertScrollbar():setScrollPosition(0)
	self.m_ShuoMing:setShowVertScrollbar(true)

	self.nItemCellSelId = 0

	self.m_CurWeaponID = -1
	self.m_NextWeaponID = -1

	self.m_LeftExchangeTimes = 0

	self.m_OldClass = 0

	--�����ְҵ�б�
	local cmd1 = require "protodef.fire.pb.school.change.coldschoollist".Create()
	LuaProtocolManager.getInstance():send(cmd1)

	--����ʯ������ʣ��ת������
	local cmd2 = require "protodef.fire.pb.school.change.cchangeschoolextinfo".Create()
	LuaProtocolManager.getInstance():send(cmd2)
end

function ZhuanZhiWuQiDlg:SetOldSchoolList(schoollist, classlist)
	self.m_OldClass = classlist[#classlist]

	self:initWeaponList()
end

function ZhuanZhiWuQiDlg:RefreshAllWeaponData()

	self.m_CurWuqi:SetImage(nil)
	self.m_CurWuqiText:setText("")
	SetItemCellBoundColorByQulityItem(self.m_CurWuqi, 0)

	self.m_NextWuqi:SetImage(nil)
	self.m_NextWuqiText:setText("")
	SetItemCellBoundColorByQulityItem(self.m_NextWuqi, 0)

	self.m_CurWeaponID = -1
	self.m_NextWeaponID = -1

	self.m_WeaponInfo:Clear()
	self.m_WeaponInfo:Refresh()

	if self.m_LeftExchangeTimes ~= 0 then
		self.m_LeftExchangeTimes = self.m_LeftExchangeTimes - 1
	end

	self:SetTransformTimesText()

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.m_CurYinBi:setText(formatMoneyString(roleItemManager:GetPackMoney()))

	self:initWeaponList()
end

function ZhuanZhiWuQiDlg:initWeaponList()
	self.vWeaponKey = { }
	local keys = {}
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	keys = roleItemManager:GetItemKeyListByType(keys, eItemType_EQUIP, fire.pb.item.BagTypes.BAG)
	self.vTableId = { }
	self:GetTableIdArray(keys)

	if self.m_tableview then
		self.itemOffect = self.m_tableview:getContentOffset()
	end

	local len = #self.vTableId
	if not self.m_tableview then
		local s = self.m_WuqiList:getPixelSize()
		self.m_tableview = TableView.create(self.m_WuqiList)
		self.m_tableview:setViewSize(s.width, s.height)
		self.m_tableview:setPosition(0, 0)
		self.m_tableview:setDataSourceFunc(self, ZhuanZhiWuQiDlg.tableViewGetCellAtIndex)
	end
	self.m_tableview:setCellCountAndSize(len, 370, 113)
	self.m_tableview:setContentOffset(self.itemOffect or 0)
	self.m_tableview:reloadData()

end

function ZhuanZhiWuQiDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        cell = ZhuanZhiWuQiCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
        cell.btnBg:subscribeEvent("MouseClick", ZhuanZhiWuQiDlg.HandleClickedItem,self)
    end
    self:setGemCellInfo(cell, idx+1)
    return cell
end

function ZhuanZhiWuQiDlg:setGemCellInfo(cell, index)
	local nTabId = self.vTableId[index]
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nTabId)
	if not itemAttrCfg then
		return
	end
    cell.btnBg:setID(nTabId)
	cell.btnBg:setID2(self.vWeaponKey[index])
	cell.name:setText(itemAttrCfg.name)
	cell.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(cell.itemCell, itemAttrCfg.id)

	if self.nItemCellSelId ==0 then
		self.nItemCellSelId = nTabId
	end

    if self.nItemCellSelId ~= nTabId then
        cell.btnBg:setSelected(false)
    else
        cell.btnBg:setSelected(true)
    end
    
end

function ZhuanZhiWuQiDlg:GetTableIdArray(vGemKey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local needlv = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(434).value)
	for i = 0, vGemKey:size() -1 do
		local baggem = roleItemManager:FindItemByBagAndThisID(vGemKey[i], fire.pb.item.BagTypes.BAG)
		if baggem then
			local nTableId = baggem:GetObjectID()
			local itemAttrCfg = baggem:GetBaseObject()

			local wt = LastClassForWeaponType[self.m_OldClass]

			if itemAttrCfg.itemtypeid == wt and itemAttrCfg.level >= needlv then
				self.vTableId[#self.vTableId + 1] = nTableId
				self.vWeaponKey[#self.vWeaponKey + 1] = vGemKey[i]
			end
			
		end
	end
end

function ZhuanZhiWuQiDlg:HandleClickedItem(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local id = mouseArgs.window:getID()
	local key = mouseArgs.window:getID2()
	local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
	local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
	if not itemAttrCfg1 then
		return
	end

	self.m_CurWeaponID = id
	self.m_NextWeaponID =(itemAttrCfg1.nquality + 3) * 1000000 + itemAttrCfg1.level * 1000 + 100 + WeaponNumber[school.id]

	self.m_CurWuqi:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg1.icon))
	self.m_CurWuqiText:setText(itemAttrCfg1.name)
	SetItemCellBoundColorByQulityItemWithId(self.m_CurWuqi, itemAttrCfg1.id)

	local itemAttrCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_NextWeaponID)
	if not itemAttrCfg2 then
		return
	end

	self.m_NextWuqi:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg2.icon))
	self.m_NextWuqiText:setText(itemAttrCfg2.name)
	SetItemCellBoundColorByQulityItemWithId(self.m_NextWuqi, itemAttrCfg2.id)

	self:ShowWeaponProperty(key)

end

function ZhuanZhiWuQiDlg:ShowWeaponProperty(wid)
	if not  wid then
		self.m_WeaponInfo:Clear()
	end

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
				end
			end
			-- if end
		end
		-- for end

		self.m_WeaponInfo:Refresh()
	end
end

function ZhuanZhiWuQiDlg:SetTransformTimes(times)
	self.m_LeftExchangeTimes = times
	self:SetTransformTimesText()
end

function ZhuanZhiWuQiDlg:SetTransformTimesText()
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(174013)

	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", self.m_LeftExchangeTimes)
	local strmsg = sb:GetString(tip.msg)
	sb:delete()

	self.m_TextInfo:Clear()
	self.m_TextInfo:AppendParseText(CEGUI.String(strmsg), false)
	self.m_TextInfo:Refresh()
end

function ZhuanZhiWuQiDlg:HandlerTransfromBtn(e)
	if self.m_CurWeaponID == -1 then
		GetCTipsManager():AddMessageTipById(174023)
		return
	end

	if self.m_NextWeaponID == -1 then
		GetCTipsManager():AddMessageTipById(174023)
		return
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if roleItemManager:GetPackMoney() < tonumber(self.m_NeedMoneyText) then
		GetCTipsManager():AddMessageTipById(120025)
		return
	end

	if self.m_LeftExchangeTimes == 0 then
		GetCTipsManager():AddMessageTipById(174010)
		return
	end

	local dlg = require "logic.zhuanzhi.zhuanzhiwuqiconfrimdlg".getInstanceAndShow()
	if dlg then
		local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_CurWeaponID)
		if not itemAttrCfg1 then
			return
		end

		local itemAttrCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_NextWeaponID)
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

		dlg:SetInfoData(itemAttrCfg1.name, itemAttrCfg2.name, Itemkey, self.m_NextWeaponID)
	end
end

return ZhuanZhiWuQiDlg
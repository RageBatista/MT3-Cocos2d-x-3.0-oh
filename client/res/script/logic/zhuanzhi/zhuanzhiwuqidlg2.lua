require "logic.dialog"
require "logic.zhuanzhi.zhuanzhiwuqicell1"

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
	LogInfo("")
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
	return "zhuanzhiwuqi2.layout"
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
	self.m_CurWuqicText = winMgr:getWindow("zhuanzhiwuqi/di2/sm1")
	self.m_CurWuqicText:setText("")
	
	--self.m_CurWuqi1Text = winMgr:getWindow("zhuanzhiwuqi/di2/text11")
	--self.m_CurWuqi1Text:setText("")
	--self.m_CurWuqic1Text = winMgr:getWindow("zhuanzhiwuqi/di2/sm2")
	--self.m_CurWuqic1Text:setText("")
	
	self.m_NextWuqi = CEGUI.toItemCell(winMgr:getWindow("zhuanzhiwuqi/di2/wuqi2"))
	self.m_NextWuqi:subscribeEvent("MouseClick", ZhuanZhiWuQiDlg.HandleClickedToItem,self)
	self.m_NextWuqiText = winMgr:getWindow("zhuanzhiwuqi/di2/text2")
	self.m_NextWuqiText:setText("")
	self.m_NextWuqicText = winMgr:getWindow("zhuanzhiwuqi/di2/sm3")
	self.m_NextWuqicText:setText("")

	self.m_NextWuqi2 = CEGUI.toItemCell(winMgr:getWindow("zhuanzhiwuqi/di2/wuqi21"))
	self.m_NextWuqi2:subscribeEvent("MouseClick", ZhuanZhiWuQiDlg.HandleClickedToItem,self)
	self.m_NextWuqiText2 = winMgr:getWindow("zhuanzhiwuqi/di2/text21")
	self.m_NextWuqiText2:setText("")

	self.m_CurYinBi = winMgr:getWindow("zhuanzhiwuqi/kuang1/di1/text1")
	self.m_CurYinBi:setText("")

	self.m_NeedMoneyText = ""

	self.m_NeedYinBi = winMgr:getWindow("zhuanzhiwuqi/kuang1/di1/text")
	self.m_NeedYinBi:setText(self.m_NeedMoneyText)
	
	self.m_Needname = winMgr:getWindow("zhuanzhiwuqi/kuang1/di1/textc")
	self.m_Needname:setText("")

	self.m_CurJinBi = winMgr:getWindow("zhuanzhiwuqi/kuang22/di1/text11")
	self.m_CurJinBi:setText(formatMoneyString(CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)))
	

	self.m_NeedMoneyText1 = GameTable.common.GetCCommonTableInstance():getRecorder(476).value
	
	self.m_NeedJinBi = winMgr:getWindow("zhuanzhiwuqi/kuang2/di1/text2")
	self.m_NeedJinBi:setText(formatMoneyString(self.m_NeedMoneyText1))
	
	self.m_NeedMatImg = winMgr:getWindow("zhuanzhiwuqi/kuang1/di1/image1")
	self.m_CurNeedMatImg = winMgr:getWindow("zhuanzhiwuqi/kuang1/di1/image11")

	self.m_TransfromBtn = CEGUI.toPushButton(winMgr:getWindow("zhuanzhiwuqi/btn"))
	self.m_TransfromBtn:subscribeEvent("MouseButtonUp", ZhuanZhiWuQiDlg.HandlerTransfromBtn, self)
	
	self.m_btnAddzuoqixl = CEGUI.toPushButton(winMgr:getWindow("zhuanzhiwuqi/xiliancc"))---坐骑洗炼	
	self.m_btnAddzuoqixl:subscribeEvent("Clicked", ZhuanZhiWuQiDlg.handleAddtBtnzuoqixlc, self)---坐骑洗炼

	self.m_TextInfo = CEGUI.toRichEditbox(winMgr:getWindow("zhuanzhiwuqi/rest"))

	self.m_WeaponInfo = CEGUI.toRichEditbox(winMgr:getWindow("zhuanzhiwuqi/di2/wiqishuxing"))

	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(192276)
	self.m_ShuoMing = CEGUI.toRichEditbox(winMgr:getWindow("zhuanzhiwuqi/di3/shuoming"))
	self.m_ShuoMing:AppendParseText(CEGUI.String(tip.msg))
	self.m_ShuoMing:Refresh()
	self.m_ShuoMing:getVertScrollbar():setScrollPosition(0)
	self.m_ShuoMing:setShowVertScrollbar(true)

	self.nItemCellSelId = 0

	self.m_CurWeaponID = -1
	self.m_NextWeaponIndex = 0
	self.m_NextWeaponIDArry = {}

	self.m_LeftExchangeTimes = 99

	self.m_OldClass = 0

	--????????б?
	--local cmd1 = require "protodef.fire.pb.school.change.coldschoollist".Create()
	--LuaProtocolManager.getInstance():send(cmd1)
	self:initWeaponList()
	
	--?????????????????????
	--local cmd2 = require "protodef.fire.pb.school.change.cchangeschoolextinfo".Create()
	--LuaProtocolManager.getInstance():send(cmd2)
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

	self.m_NextWeaponInfo:Clear()
	self.m_NextWeaponInfo:Refresh()
	
	if self.m_LeftExchangeTimes ~= 0 then
		self.m_LeftExchangeTimes = self.m_LeftExchangeTimes - 1
	end

	self:SetTransformTimesText()

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.m_CurYinBi:setText(formatMoneyString(roleItemManager:GetPackMoney()))
	self.m_CurJinBi:setText(formatMoneyString(roleItemManager:GetGold()))

	self:initWeaponList()
end

-- 初始化装备列表，将所有背包内的装备加入listCell中
function ZhuanZhiWuQiDlg:initWeaponList()
	self.vWeaponKey = { }
	local keys = {}
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	keys = roleItemManager:GetItemKeyListByType3(keys, eItemType_EQUIP, fire.pb.item.BagTypes.BAG)
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
	cell.name1:setText(itemAttrCfg.effectdes)
	cell.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(cell.itemCell, itemAttrCfg.id)

	if self.nItemCellSelId ==0 then
		self.nItemCellSelId = nTabId
	end

    if self.nItemCellSelId ~= nTabId then
        cell.btnBg:setSelected(false)
    else
        cell.btnBg:setSelected(false)
    end
    
end

function ZhuanZhiWuQiDlg:GetTableIdArray(vGemKey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local needlv = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(434).value)
	for k,v in pairs(vGemKey.data) do
		local baggem = roleItemManager:FindItemByBagAndThisID(v, fire.pb.item.BagTypes.BAG)
		if baggem then
			local nTableId = baggem:GetObjectID()
			self.vTableId[#self.vTableId + 1] = nTableId
			self.vWeaponKey[#self.vWeaponKey + 1] = v
			--local itemAttrCfg = baggem:GetBaseObject()
			
			--local itemtoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequiptoequip"):getRecorder(itemAttrCfg.id)
			--print(itemtoCfg)
			--if itemtoCfg  then
				--if  itemAttrCfg.level >= needlv then
			--		self.vTableId[#self.vTableId + 1] = nTableId
			--		self.vWeaponKey[#self.vWeaponKey + 1] = vGemKey[i]
				--end
			--end
		end
	end
end


function ZhuanZhiWuQiDlg:HandleClickedItem(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local id = mouseArgs.window:getID()
	local key = mouseArgs.window:getID2()
	local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
	local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    self.m_curweaponKey=key
	if not itemAttrCfg1 then
		return
	end

	self.m_CurWeaponID = id
	local itemtoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequiptoequip"):getRecorder(itemAttrCfg1.id)
	self.m_NextWeaponIndex = 0

	self.m_CurWuqi:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg1.icon))
	self.m_CurWuqiText:setText(itemAttrCfg1.name)
	self.m_CurWuqicText:setText(itemAttrCfg1.effectdes)
	--self.m_CurWuqi1Text:setText(itemAttrCfg1.name)
	--self.m_CurWuqic1Text:setText(itemAttrCfg1.effectdes)
	SetItemCellBoundColorByQulityItemWithIdtm(self.m_CurWuqi, itemAttrCfg1.id)

	local itemAttrCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemtoCfg.nextid1)
	if not itemAttrCfg2 then
		return
	end

	self.m_NextWuqi:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg2.icon))
	self.m_NextWuqiText:setText(itemAttrCfg2.name)
	self.m_NextWuqicText:setText(itemAttrCfg2.effectdes)
	SetItemCellBoundColorByQulityItemWithIdtm(self.m_NextWuqi, itemAttrCfg2.id)


	local itemAttrCfg21 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemtoCfg.nextid2)
	if not itemAttrCfg21 then
		return
	end

	self.m_NextWuqi2:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg21.icon))
	self.m_NextWuqiText2:setText(itemAttrCfg21.name)
	SetItemCellBoundColorByQulityItemWithId(self.m_NextWuqi2, itemAttrCfg21.id)

	self:ShowWeaponProperty(key)

	self.m_NextWeaponIDArry[0] = itemtoCfg.nextid1
	self.m_NextWeaponIDArry[1] = itemtoCfg.nextid2

	self.m_NextWuqi:SetSelected(false)
	self.m_NextWuqi2:SetSelected(false)
	self:RefreshToItemInfo(0)
end

function ZhuanZhiWuQiDlg:ShowWeaponProperty(wid)
	self.m_WeaponInfo:Clear()

	local Itemkey = wid
--	for i = 1, #self.vTableId do
--		if self.vTableId[i] == wid then
--			Itemkey = self.vWeaponKey[i]
--			break
--		end
--	end

	self.m_CurJinBi:setText(formatMoneyString(CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)))
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
    local NORMAL_CC = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFd200ff"))
	local NORMAL_CC1 = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFd200ff"))


	local nTejiId = pObj.skillid
	local nTexiaoId = pObj.skilleffect

    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	------第一条
    if texiaoTable and texiaoTable.id ~= -1 then
        local strTeXiaozi = ""
        strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name1
        strTeXiaozi = CEGUI.String(strTeXiaozi)
        self.m_WeaponInfo:AppendText(strTeXiaozi, NORMAL_CC)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
        local strTeXiaozi = ""
        strTeXiaozi = "  ["..texiaoTable.name8.." ]"..strTeXiaozi
        strTeXiaozi = CEGUI.String(strTeXiaozi)
        self.m_WeaponInfo:AppendText(strTeXiaozi, NORMAL_CC1)
        self.m_WeaponInfo:AppendBreak();
    end
----=========特技
    local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
    if tejiTable and tejiTable.id ~= -1 then
         local strTejizi = require "utils.mhsdutils".get_resstring(11002)
         strTejizi = "  "..strTejizi.." "..tejiTable.name

         strTejizi = CEGUI.String(strTejizi)
         self.m_WeaponInfo:AppendText(strTejizi, NORMAL_PURPLE)
         self.m_WeaponInfo:AppendBreak();
    end


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



function ZhuanZhiWuQiDlg:handleAddtBtnzuoqixlc(e)---门派转换
   require "logic.workshop.workshopxilian".getInstanceAndShow()
    ZhuanZhiWuQiDlg.DestroyDialog()
end


function ZhuanZhiWuQiDlg:HandlerTransfromBtn(e)
	if self.m_CurWeaponID == -1 then
		GetCTipsManager():AddMessageTipById(193104)
		return
	end

	local  mNextWeaponId = self.m_NextWeaponIDArry[self.m_NextWeaponIndex]
	if mNextWeaponId == -1 then
		GetCTipsManager():AddMessageTipById(193104)
		return
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin) < tonumber(self.m_NeedMoneyText1) then
		GetCTipsManager():AddMessageTipById(193105)
		return
	end

	--if self.m_LeftExchangeTimes == 0 then
	--	GetCTipsManager():AddMessageTipById(174010)
	--	return
	--end
	local itemtoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequiptoequip"):getRecorder(self.m_CurWeaponID)
	if not itemtoCfg then
		return
	end
	local itemNeedAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemtoCfg.needid)
	if not itemNeedAttrCfg then
		return
	end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local curNum = roleItemManager:GetItemNumByBaseID(itemtoCfg.needid)
	if curNum < tonumber(self.m_NeedMoneyText) then
		local tips = GameTable.message.GetCMessageTipTableInstance():getRecorder(193101).msg-----物品不足，提示
		tips = itemNeedAttrCfg.name .. tips
		GetCTipsManager():AddMessageTip(tips)
		return
	end
            local roleItem = roleItemManager:GetBagItem(self.m_curweaponKey)

            local equipObj = roleItem:GetObject()
            local gemlist = equipObj:GetGemlist()
            if gemlist:size() > 0 then
                GetCTipsManager():AddMessageTipById(193102) --镶嵌宝石的装备不能
                return
            end

	local dlg = require "logic.zhuanzhi.zhuanzhiwuqiconfrimdlg1".getInstanceAndShow()
	if dlg then
		local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_CurWeaponID)
		if not itemAttrCfg1 then
			return
		end

		local itemAttrCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(mNextWeaponId)
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

		dlg:SetInfoData(itemAttrCfg1.name, itemAttrCfg2.name, Itemkey, mNextWeaponId,itemtoCfg.needid,tonumber(self.m_NeedMoneyText))
		-- ZhuanZhiWuQiDlg.DestroyDialog()
	end
end

function ZhuanZhiWuQiDlg:HandleClickedToItem(args)
	print("ZhuanZhiWuQiDlg:HandleClickedToItem")
	local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
	if cell == self.m_NextWuqi then
		self.m_NextWuqi:SetSelected(false)
		self.m_NextWuqi2:SetSelected(false)
		self:RefreshToItemInfo(0)
		
	else
		self.m_NextWuqi:SetSelected(false)
		self.m_NextWuqi2:SetSelected(false)
		self:RefreshToItemInfo(1)
	end
end

function ZhuanZhiWuQiDlg:RefreshToItemInfo( index )
	if index < 0 then
		return 
	end
	local nextid = self.m_NextWeaponIDArry[index]

	self.m_NextWeaponIndex = index

	local itemtoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequiptoequip"):getRecorder(self.m_CurWeaponID)
	if not itemtoCfg then
		return
	end
	local itemNeedAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemtoCfg.needid)
	if not itemNeedAttrCfg then
		return
	end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local curNum = roleItemManager:GetItemNumByBaseID(itemtoCfg.needid)
	self.m_CurYinBi:setText(curNum)
	local neednum = itemtoCfg.needid1num 
	if index == 1 then
		neednum = itemtoCfg.needid2num
	end
	self.m_NeedYinBi:setText(formatMoneyString(neednum))
	self.m_Needname:setText(itemNeedAttrCfg.name)
	self.m_NeedMoneyText = formatMoneyString(neednum)

	local imgbuffer = gGetIconManager():GetImagePathByID(itemNeedAttrCfg.icon):c_str()
	self.m_NeedMatImg:setProperty("Image", imgbuffer)
	self.m_CurNeedMatImg:setProperty("Image", imgbuffer)

	if index == 1 then
		self.m_TransfromBtn:setProperty("Text","注灵")
	else
		self.m_TransfromBtn:setProperty("Text","注灵")
	end
end

function ZhuanZhiWuQiDlg:RefreshFormInfo()
	self.m_NextWeaponIndex = 0
	self:RefreshAllWeaponData()
	self.m_NeedYinBi:setText("")
	self.m_NeedMoneyText = formatMoneyString(0)
	self.m_CurYinBi:setText("")
	
end

return ZhuanZhiWuQiDlg
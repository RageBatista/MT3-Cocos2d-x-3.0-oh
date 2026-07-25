require "logic.dialog"
require "logic.item.xilian.zhuangbeixiliancell"
require "utils.temputil"

ZhuangBeiXiLianDlg = {}
setmetatable(ZhuangBeiXiLianDlg, Dialog)
ZhuangBeiXiLianDlg.__index = ZhuangBeiXiLianDlg

local _instance
function ZhuangBeiXiLianDlg.getInstance()
    if not _instance then
        _instance = ZhuangBeiXiLianDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function ZhuangBeiXiLianDlg.getInstanceAndShow()
    if not _instance then
        _instance = ZhuangBeiXiLianDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function ZhuangBeiXiLianDlg.getInstanceNotCreate()
    return _instance
end

function ZhuangBeiXiLianDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function ZhuangBeiXiLianDlg.ToggleOpenClose()
    if not _instance then
        _instance = ZhuangBeiXiLianDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function ZhuangBeiXiLianDlg.GetLayoutFileName()
    return "zhuangbeixilian.layout"
end

function ZhuangBeiXiLianDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZhuangBeiXiLianDlg)
    return self
end

function ZhuangBeiXiLianDlg:OnCreate()
    --洗练装备最低等级
    self.needlv = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(473).value)
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    --包内装备列表
    self.m_EquipList = winMgr:getWindow("zhuangbeixilian/di1/list")
    self:initWeaponList()

    --当前选择的装备
    self.m_CurEquip = CEGUI.toItemCell(winMgr:getWindow("zhuangbeixilian/di2/wuqi1"))
    self.m_CurEquipText = winMgr:getWindow("zhuangbeixilian/di2/text1")
    self.m_CurEquipText:setText("")

    --目标装备
    self.m_NextEquip = CEGUI.toItemCell(winMgr:getWindow("zhuangbeixilian/di2/wuqi2"))
    self.m_NextEquipText = winMgr:getWindow("zhuangbeixilian/di2/text2")
    self.m_NextEquipText:setText("")

    --TODO 当前金币
    self.m_CurYinBi = winMgr:getWindow("zhuangbeixilian/kuang1/di1/text1")
    --self.m_CurYinBi:setText(formatMoneyString(roleItemManager:GetPackMoney()))
    local roleGold = roleItemManager:GetGold()
    self.m_CurYinBi:setText(tostring(roleGold))

    --self.m_NeedMoneyText = GameTable.common.GetCCommonTableInstance():getRecorder(433).value

    self.m_NeedYinBi = winMgr:getWindow("zhuangbeixilian/kuang1/di1/text")
    self.m_NeedYinBi:setText("0")

    self.m_TransfromBtn = CEGUI.toPushButton(winMgr:getWindow("zhuangbeixilian/btn"))
    self.m_TransfromBtn:subscribeEvent("MouseButtonUp", ZhuangBeiXiLianDlg.HandlerTransfromBtn, self)

    self.m_WeaponInfo = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeixilian/di2/wiqishuxing"))

    local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(191111)
    self.m_ShuoMing = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeixilian/di3/shuoming"))
    self.m_ShuoMing:AppendParseText(CEGUI.String(tip.msg))
    self.m_ShuoMing:Refresh()
    self.m_ShuoMing:getVertScrollbar():setScrollPosition(0)
    self.m_ShuoMing:setShowVertScrollbar(true)

    self.nItemCellSelId = 0

    self.m_CurWeaponID = -1
    self.m_NextWeaponID = -1

    self.m_LeftExchangeTimes = 0

    self.m_OldClass = 0

    --local cmd1 = require "protodef.fire.pb.school.change.coldschoollist".Create()
    --LuaProtocolManager.getInstance():send(cmd1)

    --local cmd2 = require "protodef.fire.pb.school.change.cchangeschoolextinfo".Create()
    --LuaProtocolManager.getInstance():send(cmd2)
end

function ZhuangBeiXiLianDlg:RefreshAllWeaponData()
    self.m_CurEquip:SetImage(nil)
    self.m_CurEquipText:setText("")
    SetItemCellBoundColorByQulityItem(self.m_CurEquip, 0)

    self.m_NextEquip:SetImage(nil)
    self.m_NextEquipText:setText("")
    SetItemCellBoundColorByQulityItem(self.m_NextEquip, 0)

    local curWeaponID = self.m_CurWeaponID
    self.m_CurWeaponID = -1
    self.m_NextWeaponID = -1

    self.m_WeaponInfo:Clear()
    self.m_WeaponInfo:Refresh()

    if self.m_LeftExchangeTimes ~= 0 then
        self.m_LeftExchangeTimes = self.m_LeftExchangeTimes - 1
    end

    --self:SetTransformTimesText()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local roleGold = roleItemManager:GetGold()
    self.m_CurYinBi:setText(tostring(roleGold - self:getNeedChangeItemNum(curWeaponID)))
    self:initWeaponList(curWeaponID)
end

--curWeaponID 当前洗练装备id
function ZhuangBeiXiLianDlg:initWeaponList(curWeaponID)
    self.vWeaponKey = { }
    local keys = {}
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    --包里所有的装备id
    keys = roleItemManager:GetItemKeyListByType(keys, eItemType_EQUIP, fire.pb.item.BagTypes.BAG)
    if curWeaponID then
        local itemKey = roleItemManager:GetItemKeyByBaseID(curWeaponID)
        if itemKey then
            for i = 0, keys:size() - 1 do
                if keys[i] == itemKey then
                    keys[i] = nil
                    break
                end
            end
        end
    end
    self.vTableId = { }
    self:GetTableIdArray(keys)

    if self.m_tableview then
        self.itemOffect = self.m_tableview:getContentOffset()
    end

    if not self.m_tableview then
        local s = self.m_EquipList:getPixelSize()
        self.m_tableview = TableView.create(self.m_EquipList)
        self.m_tableview:setViewSize(s.width, s.height)
        self.m_tableview:setPosition(0, 0)
        self.m_tableview:setDataSourceFunc(self, ZhuangBeiXiLianDlg.tableViewGetCellAtIndex)
    end
    local len = #self.vTableId
    self.m_tableview:setCellCountAndSize(len, 370, 113)
    self.m_tableview:setContentOffset(self.itemOffect or 0)
    self.m_tableview:reloadData()

end

--装备list数据封装
function ZhuangBeiXiLianDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        cell = ZhuangBeiXiLianCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
        cell.btnBg:subscribeEvent("MouseClick", ZhuangBeiXiLianDlg.HandleClickedItem, self)
    end
    self:setGemCellInfo(cell, idx + 1)
    return cell
end

--封装装备
function ZhuangBeiXiLianDlg:setGemCellInfo(cell, index)
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

    if self.nItemCellSelId == 0 then
        self.nItemCellSelId = nTabId
    end

    if self.nItemCellSelId ~= nTabId then
        cell.btnBg:setSelected(false)
    else
        cell.btnBg:setSelected(true)
    end

end

--schoollist 造型列表
--classlist 职业列表
--function ZhuangBeiXiLianDlg:SetOldSchoolList(schoollist, classlist)
--    print("ZhuangBeiXiLianDlg:SetOldSchoolList,schoollist")
--    PrintTable(schoollist, 2)
--    --封装最后一次转职前的造型id
--    self.m_OldClass = schoollist[#schoollist]
--
--    self:initWeaponList()
--end

--vGemKey:包内装备列表id
function ZhuangBeiXiLianDlg:GetTableIdArray(vGemKey)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    for i = 0, vGemKey:size() - 1 do
        local baggem = roleItemManager:FindItemByBagAndThisID(vGemKey[i], fire.pb.item.BagTypes.BAG)
        if baggem then
            local nTableId = baggem:GetObjectID()
            local itemAttrCfg = baggem:GetBaseObject()
            local itemObj = baggem:GetObject()
            --装备大于等于可洗练等级,且有特技
            if itemAttrCfg.level >= self.needlv and itemObj.skillid and itemObj.skilleffect then
                self.vTableId[#self.vTableId + 1] = nTableId
                self.vWeaponKey[#self.vWeaponKey + 1] = vGemKey[i]
            end

        end
    end
end

--p:当前选择的装备id
function ZhuangBeiXiLianDlg:setNeedChangeItemNum(p)
    local needNum = self:getNeedChangeItemNum(p)
    self.m_NeedYinBi:setText(tostring(needNum))
end

--计算洗练需要多少封印石 p:当前选择的装备id
function ZhuangBeiXiLianDlg:getNeedChangeItemNum(p)
    local result
    local minNeed = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(474).value)
    local stepNeed = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(475).value)
    local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(p)
    if not itemAttrCfg1 then
        return
    end
    local level = itemAttrCfg1.level
    if level <= self.needlv then
        result = minNeed
    else
        local limit = (level - self.needlv) / 10
        result = (stepNeed * limit) + minNeed
    end
    return result
end

function ZhuangBeiXiLianDlg:HandleClickedItem(e)
    local mouseArgs = CEGUI.toMouseEventArgs(e)
    local id = mouseArgs.window:getID()
    local key = mouseArgs.window:getID2()
    --装备属性
    local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
    if not itemAttrCfg1 then
        return
    end

    --计算洗练需要多少材料
    self:setNeedChangeItemNum(id)

    self.m_CurWeaponID = id
    --self.m_NextWeaponID = (itemAttrCfg1.nquality + 3) * 1000000 + itemAttrCfg1.level * 1000 + 100 + WeaponNumber[SchoolWithShape[Shape.id]]
    self.m_NextWeaponID = id

    self.m_CurEquip:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg1.icon))
    self.m_CurEquipText:setText(itemAttrCfg1.name)
    SetItemCellBoundColorByQulityItemWithId(self.m_CurEquip, itemAttrCfg1.id)

    self.m_NextEquip:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg1.icon))
    self.m_NextEquipText:setText(itemAttrCfg1.name)
    SetItemCellBoundColorByQulityItemWithId(self.m_NextEquip, itemAttrCfg1.id)

    self:ShowWeaponProperty(key)

end

function ZhuangBeiXiLianDlg:ShowWeaponProperty(wid)
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

        --特技特效展示
        local nTejiId = pObj.skillid
        local nTexiaoId = pObj.skilleffect
        local strTitleColor = "ffff35fd" -- "ff29bbf7"

        local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(nTexiaoId)
        if texiaoPropertyCfg and texiaoPropertyCfg.id ~= -1 then
            local strTexiaozi = MHSD_UTILS.get_resstring(11003)
            local strTexiaoName = texiaoPropertyCfg.name
            self.m_WeaponInfo:AppendText(CEGUI.String(""))
            self.m_WeaponInfo:AppendBreak()

            self.m_WeaponInfo:AppendText(CEGUI.String("  " ..strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strTitleColor)))
            --self.m_WeaponInfo:AppendBreak()
        end
        --CEquipSkill
        --GetCEquipSkillInfoTableInstance
        local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(nTejiId)
        if tejiPropertyCfg and tejiPropertyCfg.id ~= -1 then
            local strTejizi = MHSD_UTILS.get_resstring(11002)
            local strTjiName = tejiPropertyCfg.name
            self.m_WeaponInfo:AppendText(CEGUI.String(""))
            self.m_WeaponInfo:AppendBreak()
            self.m_WeaponInfo:AppendText(CEGUI.String("  " ..strTjiName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strTitleColor)))
            self.m_WeaponInfo:AppendBreak()
            --local strbuilder = StringBuilder:new()
            --strbuilder:Set("parameter1", tejiPropertyCfg.costnum)
            --local content = strbuilder:GetString(tejiPropertyCfg.cost)
            --strbuilder:delete()
            --self.m_WeaponInfo:AppendText(CEGUI.String(content), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
            --self.m_WeaponInfo:AppendText(CEGUI.String(strTjiName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
            --self.m_WeaponInfo:AppendBreak()
        end

        self.m_WeaponInfo:Refresh()
    end
end

--function ZhuangBeiXiLianDlg:SetTransformTimes(times)
--    self.m_LeftExchangeTimes = times
--    self:SetTransformTimesText()
--end
--
--function ZhuangBeiXiLianDlg:SetTransformTimesText()
--    local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(174013)
--
--    local sb = require "utils.stringbuilder":new()
--    sb:Set("parameter1", self.m_LeftExchangeTimes)
--    local strmsg = sb:GetString(tip.msg)
--    sb:delete()
--
--    self.m_TextInfo:Clear()
--    self.m_TextInfo:AppendParseText(CEGUI.String(strmsg), false)
--    self.m_TextInfo:Refresh()
--end

--确认洗练
function ZhuangBeiXiLianDlg:HandlerTransfromBtn(e)
    if self.m_CurWeaponID == -1 then
        GetCTipsManager():AddMessageTipById(174023)
        return
    end

    if self.m_NextWeaponID == -1 then
        GetCTipsManager():AddMessageTipById(174023)
        return
    end

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local roleGold = roleItemManager:GetGold()
    if roleGold < tonumber(self.m_NeedYinBi:getText()) then
        print("into hasChangeItemNum < self.m_NeedYinBi:getText()")
        GetCTipsManager():AddMessageTipById(191101)

        local result1 = self.m_NeedYinBi - roleGold
        CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_GoldCoin, result1)
        return
    end

    --洗练次数
    --if self.m_LeftExchangeTimes == 0 then
    --    GetCTipsManager():AddMessageTipById(174010)
    --    return
    --end

    local dlg = require "logic.item.xilian.zhuangbeixilianconfrimdlg".getInstanceAndShow()
    if dlg then
        local itemAttrCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_CurWeaponID)
        if not itemAttrCfg1 then
            return
        end

        local Itemkey = 0
        for i = 1, #self.vTableId do
            if self.vTableId[i] == self.m_CurWeaponID then
                Itemkey = self.vWeaponKey[i]
                break
            end
        end
        dlg:SetInfoData(itemAttrCfg1.name, Itemkey, self.m_NextWeaponID)
    end
    self:SetZhuangBeiXiLianDlgVisible(false)
end

function ZhuangBeiXiLianDlg:SetZhuangBeiXiLianDlgVisible(bVisible)
    self:SetVisible(bVisible)
end

return ZhuangBeiXiLianDlg
require "logic.dialog"

XingpanDlg = {
    descbg = {},
    desc = {},
    m_pEquipCell = {},
    selected = {},
    richbox = {},
}
setmetatable(XingpanDlg, Dialog)
XingpanDlg.__index = XingpanDlg

local _instance
function XingpanDlg.getInstance()
    if not _instance then
        _instance = XingpanDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function XingpanDlg.getInstanceAndShow()
    if not _instance then
        _instance = XingpanDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function XingpanDlg.getInstanceNotCreate()
    return _instance
end

function XingpanDlg.DestroyDialog()
    if _instance then
        gGetGameUIManager():RemoveUIEffect(_instance.xingyinEffect)
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function XingpanDlg.ToggleOpenClose()
    if not _instance then
        _instance = XingpanDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function XingpanDlg.GetLayoutFileName()
    return "xingpandlg.layout"
end

function XingpanDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, XingpanDlg)


    return self
end

function XingpanDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.xingpanbg = winMgr:getWindow("xingpan/bg")
    self.schoolimg = winMgr:getWindow("xingpan/bg/schoolimg")
    self.suitnamebg = winMgr:getWindow("xingpan/bg/suitnamebg")
    self.suitname = winMgr:getWindow("xingpan/bg/suitnamebg/suitname")
    self.closebtn = CEGUI.toPushButton(winMgr:getWindow("xingpan/bg/closebtn"))
    self.xiangqingBtn = CEGUI.toPushButton(winMgr:getWindow("xingpan/bg/xiangqing"))
    self.xingyinbtn = CEGUI.toPushButton(winMgr:getWindow("xingpan/bg/xingyin"))

    self.closebtn:subscribeEvent("Clicked", XingpanDlg.HandleCloseBtn, self)
    self.xiangqingBtn:subscribeEvent("Clicked", XingpanDlg.HandleXiangQingBtn, self)
    self.xingyinbtn:subscribeEvent("Clicked", XingpanDlg.HandleXingyinBtnClick, self)
    self.xingyinEffect = gGetGameUIManager():AddUIEffect(self.xingpanbg, "spine/my_spine/xinpanbg", true)
    self.xingyinEffect:SetDefaultActName("zt1")
    self.skillbox = CEGUI.toSkillBox(winMgr:getWindow("xingpan/bg/suit/icon"))
    self.skillbox:Clear()
 

    for i = 1, 6 do
        self.descbg[i] = winMgr:getWindow("xingpan/bg/descbg" .. i)
        self.desc[i] = CEGUI.toRichEditbox(winMgr:getWindow("xingpan/bg/desc" .. i))
        self.desc[i]:setReadOnly(true)
        self.descbg[i]:setVisible(false)
        self.selected[i] = winMgr:getWindow("xingpan/bg/selected" .. i)
        self.selected[i]:setVisible(false)
        self.selected[i]:setMousePassThroughEnabled(true);
        self.richbox[i] = winMgr:getWindow("xingpan/bg/desc" .. i)
    end

    self.m_pEquipCell[eEquipType_XPSHE] = CEGUI.toItemCell(winMgr:getWindow("xingpan/bg/item1"));
    self.m_pEquipCell[eEquipType_XPHU] = CEGUI.toItemCell(winMgr:getWindow("xingpan/bg/item2"));
    self.m_pEquipCell[eEquipType_XPNIU] = CEGUI.toItemCell(winMgr:getWindow("xingpan/bg/item3"));
    self.m_pEquipCell[eEquipType_XPTU] = CEGUI.toItemCell(winMgr:getWindow("xingpan/bg/item4"));
    self.m_pEquipCell[eEquipType_XPLONG] = CEGUI.toItemCell(winMgr:getWindow("xingpan/bg/item5"));
    self.m_pEquipCell[eEquipType_XPYANG] = CEGUI.toItemCell(winMgr:getWindow("xingpan/bg/item6"));

    self.m_pEquipCell[eEquipType_XPSHE]:setID(eEquipType_XPSHE)
    self.m_pEquipCell[eEquipType_XPHU]:setID(eEquipType_XPHU)
    self.m_pEquipCell[eEquipType_XPNIU]:setID(eEquipType_XPNIU)
    self.m_pEquipCell[eEquipType_XPTU]:setID(eEquipType_XPTU)
    self.m_pEquipCell[eEquipType_XPLONG]:setID(eEquipType_XPLONG)
    self.m_pEquipCell[eEquipType_XPYANG]:setID(eEquipType_XPYANG)

    self.m_ItemTable = GameItemTable:new(fire.pb.item.BagTypes.EQUIP);
    for k, _ in pairs(self.m_pEquipCell) do
        self.m_pEquipCell[k]:SetImage("xingpan", "y" .. tostring(k - 30))
        self.m_pEquipCell[k]:subscribeEvent(CEGUI.ItemCell.EventCellClick, GameItemTable.HandleShowToolTips,
            self.m_ItemTable);
        self.m_pEquipCell[k]:subscribeEvent(CEGUI.ItemCell.EventCellClick, XingpanDlg.HandleItemClick, self)
        self.m_pEquipCell[k]:SetCellTypeMask(1);
        self.m_pEquipCell[k]:setID2(0);
        self.m_pEquipCell[k]:subscribeEvent(CEGUI.ItemCell.EventCellDoubleClick, CEquipDialog.HandleTableDoubleClick,
            self);
    end

    self.schoolimg:setProperty("Image",
        "set:xingpanschool image:" .. tostring(gGetDataManager():GetMainCharacterSchoolID()))

    self:UpdateEquip()
end

 

function XingpanDlg:HandleItemClick(args)
    local eventargs = CEGUI.toWindowEventArgs(args)
    local id = eventargs.window:getID()
    for i = 1, 6 do
        self.selected[i]:setVisible(false)
    end
    self.selected[id - 30]:setVisible(true)
end

function XingpanDlg:Unequip(item)
    local desPos = CMainPackDlg:GetSingleton():GetFirstEmptyCell();
    if (desPos == -1) then
        if (GetChatManager()) then
            GetChatManager():AddTipsMsg(120059);
        end
    else
        if (item:GetObject() ~= nil) then
            local roleItemManager = require("logic.item.roleitemmanager").getInstance()
            roleItemManager:UnEquipItem(item:GetThisID(), desPos);
        end
    end
end

function XingpanDlg:HandleTableDoubleClick(e)
    local MouseArgs = CEGUI.toMouseEventArgs(e);

    local pCell = CEGUI.toItemCell(MouseArgs.window);
    if (pCell == nil) then
        return false;
    end

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.EQUIP)
    if (pItem == nil) then
        return false;
    end
    self:Unequip(pItem);
    local dlg = require 'logic.tips.commontipdlg'.getInstanceNotCreate();
    if dlg then
        dlg:DestroyDialog();
    end
    return true;
end

function XingpanDlg:HandleCloseBtn(args)
    self:DestroyDialog()
end

function XingpanDlg:HandleXiangQingBtn(args)
    for i = 1, 6 do
        self.descbg[i]:setVisible(not self.descbg[i]:isVisible())
    end
end

function XingpanDlg:HandleXingyinBtnClick(args)
    debugrequire "logic.xingpan.xingpandescdlg":getInstanceAndShow()
end

function XingpanDlg:getXingYinCount()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local ycount = 0
    local fcount = 0
    for k, v in pairs(self.m_pEquipCell) do
        local pItem, key = roleItemManager:GetItemByLoction(fire.pb.item.BagTypes.EQUIP, k)
        if pItem then
            if k == eEquipType_XPSHE or k == eEquipType_XPHU or k == eEquipType_XPTU then
                ycount = ycount + 1
            elseif k == eEquipType_XPNIU or k == eEquipType_XPLONG or k == eEquipType_XPYANG then
                fcount = fcount + 1
            end
        end
    end
    return ycount, fcount
end

function XingpanDlg:UpdateXingyinEffect()
    local ycount, fcount = self:getXingYinCount()
    if ycount > 0 then
        self.xingyinEffect:SetDefaultActName("zt2")
    elseif fcount > 0 then
        self.xingyinEffect:SetDefaultActName("zt3")
    else
        self.xingyinEffect:SetDefaultActName("zt1")
    end
    self.skillbox:Clear()
    if ycount + fcount == 4 then
        local t = BeanConfigManager.getInstance():GetTableByName("item.cxingyincombo")
        local ids = t:getAllID()
        local schoolid = gGetDataManager():GetMainCharacterSchoolID()
        for _, id in pairs(ids) do
            local conf = t:getRecorder(id)
            local hasSchool = conf.school == 0 or conf.school == schoolid
            if conf.yuancount == ycount and conf.fangcount == fcount and hasSchool then
                if  conf.skillid > 0 then
                    SkillBoxControl.SetSkillInfo(self.skillbox, conf.skillid, 0)
                else
                    SkillBoxControl.SetSkillInfo(self.skillbox, conf.buffskillid, 0)
                end
                return
            end
        end
    end
end

-- function XingpanDlg:getProcount()
--     local roleItemManager = require("logic.item.roleitemmanager").getInstance()
--     local count = 0
--     for k, v in pairs(self.m_pEquipCell) do
--         local pItem, key = roleItemManager:GetItemByLoction(fire.pb.item.BagTypes.EQUIP, k)
--         if pItem then
--             local pEquipData = pItem:GetObject()
--             local vcBaseKey = pEquipData:GetBaseEffectAllKey()
--             local vPlusKey = pEquipData:GetPlusEffectAllKey()
--             count = count + #vcBaseKey + #vPlusKey
--             if pEquipData.skilleffect > 0 then
--                 count = count + 1
--             end
--             -- if pEquipData.skillid>0 then --如果需要计算特技在内，取消这里注释
--             --     count = count + 1
--             -- end
--         end
--     end
--     return count
-- end
function XingpanDlg:getProcount()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local count = 0
    for k=31,36 do
        local pItem, key = roleItemManager:GetItemByLoction(fire.pb.item.BagTypes.EQUIP, k)
        if pItem then
            local pEquipData = pItem:GetObject()
            local vcBaseKey = pEquipData:GetBaseEffectAllKey()
            local vPlusKey = pEquipData:GetPlusEffectAllKey()
            count = count + #vcBaseKey + #vPlusKey
            if pEquipData.skilleffect > 0 then
                count = count + 1
            end
            if pEquipData.skillid>0 then --如果需要计算特技在内，取消这里注释
                count = count + 1
            end
        end
    end
    return count
end

function XingpanDlg:UpdateXingPanEffect()
    local ycount, fcount = self:getXingYinCount()
    if ycount + fcount == 4 then
        local schoolid = gGetDataManager():GetMainCharacterSchoolID()
        local comboTable = BeanConfigManager.getInstance():GetTableByName("item.cxingyincombo")
        local comboIds = comboTable:getAllID()
        local matchedComboId = 0
        for _, id in pairs(comboIds) do
            local comboConf = comboTable:getRecorder(id)
            local hasSchool = comboConf.school == 0 or comboConf.school == schoolid
            if comboConf.yuancount == ycount and comboConf.fangcount == fcount and hasSchool then
                matchedComboId = comboConf.id
                break
            end
        end

        if matchedComboId > 0 then
            local suitTable = BeanConfigManager.getInstance():GetTableByName("item.cxingpansuit")
            local suitConf = suitTable:getRecorder(matchedComboId)
            if suitConf and (suitConf.school == 0 or suitConf.school == schoolid) then
                self.suitname:setText(suitConf.name)
                self.suitnamebg:setProperty("Image", "set:xingpan image:jihuoBG"..tostring(suitConf.id))
                return
            end
        end
    end
    self.suitname:setText("无套装")
    self.suitnamebg:setProperty("Image", "set:xingpan image:jihuoBG1")
end

function XingpanDlg:refreshRichBox(richBox, pitem)
    local pEquipData = pitem:GetObject()
    local vcBaseKey = pEquipData:GetBaseEffectAllKey()
    if #vcBaseKey <= 0 then
        return
    end
    
    richBox:Clear()
    richBox:setProperty("HorzTextFormatting", "RightAligned")
    local NORMAL_GREEN = "FF06cc11"
    local NORMAL_WHITE = "fffff2df"
    local NORMAL_LANSE = "ff6ddcf6"--蓝色
    local color_NORMAL_WHITE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_WHITE))
    local color_NORMAL_GREEN = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_GREEN))
    local color_NORMAL_LANSE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_LANSE))
    local basesum = 0;
    local extrsum = 0;
    for nIndex = 1, #vcBaseKey do
        local nBaseId = vcBaseKey[nIndex]
        local nBaseValue = pEquipData:GetBaseEffect(nBaseId)
        local nextraBaseValue = pEquipData:GetExtraBaseEffect(nBaseId)
        if nBaseValue ~= 0 then
            local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(
                nBaseId)
            if propertyCfg and propertyCfg.id ~= -1 then
                local strTitleName = propertyCfg.name
                local nValue = math.abs(nBaseValue)
                if nBaseValue > 0 then
                    strTitleName = strTitleName .. " " .. "+" .. tostring(nValue)
                    basesum = basesum + nBaseValue
                elseif nBaseValue < 0 then
                    strTitleName = strTitleName .. " " .. "-" .. tostring(nValue)
                end
                strTitleName = "  " .. strTitleName
                strTitleName = CEGUI.String(strTitleName)
                richBox:AppendText(strTitleName, color_NORMAL_WHITE)
                local nextraValue = math.abs(nextraBaseValue)
                if nextraValue ~= 0 then
                    extrsum = extrsum + nextraValue
                    local str = "   " .. "[+" .. tostring(nextraValue) .. "]"
                    str = CEGUI.String(str)
                    richBox:AppendText(str, color_NORMAL_WHITE)
                end
                richBox:AppendBreak()
            end
        end
    end

    local vPlusKey = pEquipData:GetPlusEffectAllKey()
    for nIndex = 1, #vPlusKey do
        local nPlusId = vPlusKey[nIndex]
        local mapPlusData = pEquipData:GetPlusEffect(nPlusId)
        local nextraPropertyValue = pEquipData:GetExtraPlusEffect(mapPlusData.attrid)
        if mapPlusData.attrvalue ~= 0 then
            local nPropertyId = mapPlusData.attrid
            local nPropertyValue = mapPlusData.attrvalue
            local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(
                nPropertyId)
            if propertyCfg and propertyCfg.id ~= -1 then
                local strTitleName = propertyCfg.name
                local nValue = math.abs(nPropertyValue)
                local nextraValue = math.abs(nextraPropertyValue)
                if nPropertyValue > 0 then
                    strTitleName = strTitleName .. "" .. "+" .. tostring(nValue)
                else
                    strTitleName = strTitleName .. "" .. "-" .. tostring(nValue)
                end
                local strEndSpace = " "
                local strBeginSpace = "  "
                strTitleName = strTitleName .. strEndSpace
                strTitleName = strBeginSpace .. strTitleName

                strTitleName = CEGUI.String(strTitleName)
                richBox:AppendText(strTitleName, color_NORMAL_GREEN)
                richBox:AppendBreak()
            end
        end
    end

    local nTexiaoId = pEquipData.skilleffect
    local nTejiId = pEquipData.skillid
    local nItemId=pEquipData.data.id
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
     
    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
    if texiaoTable and texiaoTable.id ~= -1 then
        local strTeXiaozi = require "utils.mhsdutils".get_resstring(11811)
        strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name

        strTeXiaozi = CEGUI.String(strTeXiaozi)
        richBox:AppendText(strTeXiaozi, color_NORMAL_LANSE)
        richBox:AppendBreak();
    end
  
    local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
    if tejiTable and tejiTable.id ~= -1 then
         local strTejizi = require "utils.mhsdutils".get_resstring(11812)
         strTejizi = "  "..strTejizi.." "..tejiTable.name

         strTejizi = CEGUI.String(strTejizi)
         richBox:AppendText(strTejizi, color_NORMAL_LANSE)
         richBox:AppendBreak();
    end
 
    richBox:Refresh()
end

function XingpanDlg:UpdateEquip()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    for k, v in pairs(self.m_pEquipCell) do
        local idx=k-30
        local pItem, key = roleItemManager:GetItemByLoction(fire.pb.item.BagTypes.EQUIP, k)
        if pItem then
            local itemid = pItem:GetBaseObject().id
            v:setID2(key)
            self.selected[idx]:setID2(itemid)
            local icon = gGetIconManager():GetItemIconByID(pItem:GetBaseObject().icon)
            v:SetImage(icon)
            self:refreshRichBox(self.richbox[idx], pItem)
        else
            v:Clear()
            v:setID(k)
            v:setID2(0)
            self.selected[idx]:setID2(0)
            v:SetImage("xingpan", "y" .. tostring(idx))
            self.richbox[idx]:Clear()
            self.richbox[idx]:Refresh()
        end
    end
    self:UpdateXingyinEffect()
    self:UpdateXingPanEffect()
end

return XingpanDlg

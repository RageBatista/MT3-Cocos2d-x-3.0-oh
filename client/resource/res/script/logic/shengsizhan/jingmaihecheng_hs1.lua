require "logic.dialog"

jingmaihecheng_hs1 = {}
setmetatable(jingmaihecheng_hs1, Dialog)
jingmaihecheng_hs1.__index = jingmaihecheng_hs1


local _instance
function jingmaihecheng_hs1.getInstance()
    if not _instance then
        _instance = jingmaihecheng_hs1:new()
        _instance:OnCreate()
    end
    return _instance
end

function jingmaihecheng_hs1.getInstanceAndShow()
    if not _instance then
        _instance = jingmaihecheng_hs1:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function jingmaihecheng_hs1.getInstanceNotCreate()
    return _instance
end

function jingmaihecheng_hs1.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function jingmaihecheng_hs1.ToggleOpenClose()
    if not _instance then
        _instance = jingmaihecheng_hs1:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function jingmaihecheng_hs1.GetLayoutFileName()
    return "cwzbdazao.layout"
end

function jingmaihecheng_hs1:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, jingmaihecheng_hs1)
    return self
end

function jingmaihecheng_hs1:OnCreate()
    Dialog.OnCreate(self)
end

function jingmaihecheng_hs1:OnCreate()
    LogInfo("jingmaihecheng_hs oncreate begin")
    Dialog.OnCreate(self)
    self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local scrollPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("jingmaihecheng_hs/huadong1"))

    --	self.m_lyshc = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/lyshc"))
    self.m_lyshc = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/lyshc")) --tips 炼妖石合成
    self.m_lyshc:subscribeEvent("Clicked", jingmaihecheng_hs1.BtnRedPackClicked, self)

    self.m_hc1hs1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs1"))
    self.m_hc1hs2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs2"))
    self.m_hc1hs3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs3"))
    self.m_hc1hs4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs4"))
    self.m_hc1hs5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs5"))
    self.m_hc1hs6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs6"))
    self.m_hc1hs7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs7"))
    self.m_hc1hs8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs8"))
    self.m_hc1hs9 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs9"))

    self.tipsButton1 = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/skillscroll/tips1")) --tips button
    self.tipsButton1:subscribeEvent("Clicked", jingmaihecheng_hs1.handleClickTipButton1, self)

    self.tipsButton2 = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/skillscroll/tips2")) --tips button
    self.tipsButton2:subscribeEvent("Clicked", jingmaihecheng_hs1.handleClickTipButton2, self)

    self.tipsButton3 = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/skillscroll/tips3")) --tips button
    self.tipsButton3:subscribeEvent("Clicked", jingmaihecheng_hs1.handleClickTipButton3, self)

    self.tipsButton4 = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/skillscroll/tips4")) --tips button
    self.tipsButton4:subscribeEvent("Clicked", jingmaihecheng_hs1.handleClickTipButton4, self)

    self.tipsButton5 = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/skillscroll/tips5")) --tips button
    self.tipsButton5:subscribeEvent("Clicked", jingmaihecheng_hs1.handleClickTipButton5, self)

    self.tipsButton6 = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/skillscroll/tips6")) --tips button
    self.tipsButton6:subscribeEvent("Clicked", jingmaihecheng_hs1.handleClickTipButton6, self)

    self.tipsButton7 = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/skillscroll/tips7")) --tips button
    self.tipsButton7:subscribeEvent("Clicked", jingmaihecheng_hs1.handleClickTipButton7, self)

    self.tipsButton8 = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/skillscroll/tips8")) --tips button
    self.tipsButton8:subscribeEvent("Clicked", jingmaihecheng_hs1.handleClickTipButton8, self)

    self.tipsButton9 = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_hs/skillscroll/tips9")) --tips button
    self.tipsButton9:subscribeEvent("Clicked", jingmaihecheng_hs1.handleClickTipButton9, self)


    self.qiehuan1 = winMgr:getWindow("jingmaihecheng_hs/qiehuan1")
    self.qiehuan1:subscribeEvent("MouseClick", jingmaihecheng_hs1.HandleClickQieHuan1, self)

    self.qiehuan2 = winMgr:getWindow("jingmaihecheng_hs/qiehuan2")
    self.qiehuan2:subscribeEvent("MouseClick", jingmaihecheng_hs1.HandleClickQieHuan2, self)

    self.qiehuan3 = winMgr:getWindow("jingmaihecheng_hs/qiehuan3")
    self.qiehuan3:subscribeEvent("MouseClick", jingmaihecheng_hs1.HandleClickQieHuan3, self)

    self.qiehuan4 = winMgr:getWindow("jingmaihecheng_hs/qiehuan4")
    self.qiehuan4:subscribeEvent("MouseClick", jingmaihecheng_hs1.HandleClickQieHuan4, self)

    self.m_item = CEGUI.toItemCell(winMgr:getWindow("jingmaihecheng_hs/item"))
    self.m_item:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.m_item2 = CEGUI.toItemCell(winMgr:getWindow("jingmaihecheng_hs/item2"))
    self.m_item2:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.m_item3 = CEGUI.toItemCell(winMgr:getWindow("jingmaihecheng_hs/item3"))
    self.m_item3:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.m_item4 = CEGUI.toItemCell(winMgr:getWindow("jingmaihecheng_hs/item4"))
    self.m_item4:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.m_item5 = CEGUI.toItemCell(winMgr:getWindow("jingmaihecheng_hs/item5"))
    self.m_item5:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.m_item6 = CEGUI.toItemCell(winMgr:getWindow("jingmaihecheng_hs/item6"))
    self.m_item6:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    ----1
    self.skillTypeTabBtn1 = CEGUI.toGroupButton(winMgr:getWindow("jingmaihecheng_hs/jiemian/skill"))
    self.skillpanel = winMgr:getWindow("jingmaihecheng_hs/skillscroll")
    self.skillTypeTabBtn1:subscribeEvent("SelectStateChanged", jingmaihecheng_hs1.handleSwitchSkillTypeTab, self)
    ----2
    self.skillTypeTabBtn2 = CEGUI.toGroupButton(winMgr:getWindow("jingmaihecheng_hs/jiemian/neidan"))
    self.neidanpanel = winMgr:getWindow("jingmaihecheng_hs/neidanscroll")
    self.skillTypeTabBtn2:subscribeEvent("SelectStateChanged", jingmaihecheng_hs1.handleSwitchSkillTypeTab, self)
    ----3
    self.skillTypeTabBtn3 = CEGUI.toGroupButton(winMgr:getWindow("jingmaihecheng_hs/jiemian/neidan3"))
    self.neidanpanel3 = winMgr:getWindow("jingmaihecheng_hs/neidanscroll3")
    self.skillTypeTabBtn3:subscribeEvent("SelectStateChanged", jingmaihecheng_hs1.handleSwitchSkillTypeTab, self)
    ----4
    self.skillTypeTabBtn4 = CEGUI.toGroupButton(winMgr:getWindow("jingmaihecheng_hs/jiemian/neidan4"))
    self.neidanpanel4 = winMgr:getWindow("jingmaihecheng_hs/neidanscroll4")
    self.skillTypeTabBtn4:subscribeEvent("SelectStateChanged", jingmaihecheng_hs1.handleSwitchSkillTypeTab, self)
    ----5
    self.skillTypeTabBtn5 = CEGUI.toGroupButton(winMgr:getWindow("jingmaihecheng_hs/jiemian/neidan5"))
    self.neidanpanel5 = winMgr:getWindow("jingmaihecheng_hs/neidanscroll5")
    self.skillTypeTabBtn5:subscribeEvent("SelectStateChanged", jingmaihecheng_hs1.handleSwitchSkillTypeTab, self)
    ----6
    self.skillTypeTabBtn6 = CEGUI.toGroupButton(winMgr:getWindow("jingmaihecheng_hs/jiemian/neidan6"))
    self.neidanpanel6 = winMgr:getWindow("jingmaihecheng_hs/neidanscroll6")
    self.skillTypeTabBtn6:subscribeEvent("SelectStateChanged", jingmaihecheng_hs1.handleSwitchSkillTypeTab, self)
    ----7
    self.skillTypeTabBtn7 = CEGUI.toGroupButton(winMgr:getWindow("jingmaihecheng_hs/jiemian/neidan7"))
    self.neidanpanel7 = winMgr:getWindow("jingmaihecheng_hs/neidanscroll7")
    self.skillTypeTabBtn7:subscribeEvent("SelectStateChanged", jingmaihecheng_hs1.handleSwitchSkillTypeTab, self)
    ----8
    self.skillTypeTabBtn8 = CEGUI.toGroupButton(winMgr:getWindow("jingmaihecheng_hs/jiemian/neidan8"))
    self.neidanpanel8 = winMgr:getWindow("jingmaihecheng_hs/neidanscroll8")
    self.skillTypeTabBtn8:subscribeEvent("SelectStateChanged", jingmaihecheng_hs1.handleSwitchSkillTypeTab, self)
    ----9
    self.skillTypeTabBtn9 = CEGUI.toGroupButton(winMgr:getWindow("jingmaihecheng_hs/jiemian/neidan9"))
    self.neidanpanel9 = winMgr:getWindow("jingmaihecheng_hs/neidanscroll9")
    self.skillTypeTabBtn9:subscribeEvent("SelectStateChanged", jingmaihecheng_hs1.handleSwitchSkillTypeTab, self)


    



    --	scrollPane:addChildWindow(self.skillTypeTabBtn1)

    self.smokeBg = winMgr:getWindow("jingmaihecheng_hs/Back/flagbg/smoke")
    local s = self.smokeBg:getPixelSize()
    local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi1", true,
        s.width * 0.5, s.height)




    self.m_hc1hs1:subscribeEvent("Clicked", jingmaihecheng_hs1.hc1hs1, self)
    self.m_hc1hs2:subscribeEvent("Clicked", jingmaihecheng_hs1.hc1hs2, self)
    self.m_hc1hs3:subscribeEvent("Clicked", jingmaihecheng_hs1.hc1hs3, self)
    self.m_hc1hs4:subscribeEvent("Clicked", jingmaihecheng_hs1.hc1hs4, self)
    self.m_hc1hs5:subscribeEvent("Clicked", jingmaihecheng_hs1.hc1hs5, self)
    self.m_hc1hs6:subscribeEvent("Clicked", jingmaihecheng_hs1.hc1hs6, self)
    self.m_hc1hs7:subscribeEvent("Clicked", jingmaihecheng_hs1.hc1hs7, self)
    self.m_hc1hs8:subscribeEvent("Clicked", jingmaihecheng_hs1.hc1hs8, self)
    self.m_hc1hs9:subscribeEvent("Clicked", jingmaihecheng_hs1.hc1hs9, self)





    scrollPane:addChildWindow(self.skillTypeTabBtn1)
    scrollPane:addChildWindow(self.skillTypeTabBtn2)
    scrollPane:addChildWindow(self.skillTypeTabBtn3)
    scrollPane:addChildWindow(self.skillTypeTabBtn4)
    scrollPane:addChildWindow(self.skillTypeTabBtn5)
    scrollPane:addChildWindow(self.skillTypeTabBtn6)
    scrollPane:addChildWindow(self.skillTypeTabBtn7)
    scrollPane:addChildWindow(self.skillTypeTabBtn8)
    scrollPane:addChildWindow(self.skillTypeTabBtn9)

    -- 新增加 800
    local itemid = GameTable.common.GetCCommonTableInstance():getRecorder(800)
    local itemid1 = tonumber(itemid.value)
    local itemnum = GameTable.common.GetCCommonTableInstance():getRecorder(671)
    local itemnum1 = tonumber(itemnum.value)

    -- 新增对 800
    local itemid2 = GameTable.common.GetCCommonTableInstance():getRecorder(803)
    local itemid2_1 = tonumber(itemid2.value)
    local itemnum2 = GameTable.common.GetCCommonTableInstance():getRecorder(671)
    local itemnum2_1 = tonumber(itemnum2.value)

    -- 新增对 801
    local itemid3 = GameTable.common.GetCCommonTableInstance():getRecorder(800)
    local itemid3_1 = tonumber(itemid3.value)
    local itemnum3 = GameTable.common.GetCCommonTableInstance():getRecorder(671)
    local itemnum3_1 = tonumber(itemnum3.value)

    -- 新增对 801
    local itemid4 = GameTable.common.GetCCommonTableInstance():getRecorder(804)
    local itemid4_1 = tonumber(itemid4.value)
    local itemnum4 = GameTable.common.GetCCommonTableInstance():getRecorder(671)
    local itemnum4_1 = tonumber(itemnum4.value)

    -- 新增对 801
    local itemid5 = GameTable.common.GetCCommonTableInstance():getRecorder(800)
    local itemid5_1 = tonumber(itemid5.value)
    local itemnum5 = GameTable.common.GetCCommonTableInstance():getRecorder(671)
    local itemnum5_1 = tonumber(itemnum5.value)

    -- 新增对 801
    local itemid6 = GameTable.common.GetCCommonTableInstance():getRecorder(805)
    local itemid6_1 = tonumber(itemid6.value)
    local itemnum6 = GameTable.common.GetCCommonTableInstance():getRecorder(671)
    local itemnum6_1 = tonumber(itemnum6.value)

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    -----1
    local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid1)
    if not needItemCfg1 then
        return
    end
    self.m_item:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.m_item, needItemCfg1.id)
    self.m_item:setID(needItemCfg1.id)
    local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
    local strNumNeed_own1 = nOwnItemNum1 .. "/" .. itemnum1
    self.m_item:SetTextUnit(strNumNeed_own1)
    if nOwnItemNum1 >= itemnum1 then
        self.m_item:SetTextUnitColor(MHSD_UTILS.get_greencolor())
    else
        self.m_item:SetTextUnitColor(MHSD_UTILS.get_redcolor())
    end

    -- 2
    local needItemCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid2_1)
    if not needItemCfg2 then
        return
    end
    self.m_item2:SetImage(gGetIconManager():GetItemIconByID(needItemCfg2.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.m_item2, needItemCfg2.id)
    self.m_item2:setID(needItemCfg2.id)
    local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(needItemCfg2.id)
    local strNumNeed_own2 = nOwnItemNum2 .. "/" .. itemnum2_1
    self.m_item2:SetTextUnit(strNumNeed_own2)
    if nOwnItemNum2 >= itemnum2_1 then
        self.m_item2:SetTextUnitColor(MHSD_UTILS.get_greencolor())
    else
        self.m_item2:SetTextUnitColor(MHSD_UTILS.get_redcolor())
    end
    ----3
    local needItemCfg3 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid3_1)
    if not needItemCfg3 then
        return
    end
    self.m_item3:SetImage(gGetIconManager():GetItemIconByID(needItemCfg3.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.m_item3, needItemCfg3.id)
    self.m_item3:setID(needItemCfg3.id)
    local nOwnItemNum3 = roleItemManager:GetItemNumByBaseID(needItemCfg3.id)
    local strNumNeed_own3 = nOwnItemNum3 .. "/" .. itemnum3_1
    self.m_item3:SetTextUnit(strNumNeed_own3)
    if nOwnItemNum3 >= itemnum3_1 then
        self.m_item3:SetTextUnitColor(MHSD_UTILS.get_greencolor())
    else
        self.m_item3:SetTextUnitColor(MHSD_UTILS.get_redcolor())
    end

    ----4
    local needItemCfg4 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid4_1)
    if not needItemCfg4 then
        return
    end
    self.m_item4:SetImage(gGetIconManager():GetItemIconByID(needItemCfg4.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.m_item4, needItemCfg4.id)
    self.m_item4:setID(needItemCfg4.id)
    local nOwnItemNum4 = roleItemManager:GetItemNumByBaseID(needItemCfg4.id)
    local strNumNeed_own4 = nOwnItemNum4 .. "/" .. itemnum4_1
    self.m_item4:SetTextUnit(strNumNeed_own4)
    if nOwnItemNum4 >= itemnum4_1 then
        self.m_item4:SetTextUnitColor(MHSD_UTILS.get_greencolor())
    else
        self.m_item4:SetTextUnitColor(MHSD_UTILS.get_redcolor())
    end


    local needItemCfg5 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid5_1)
    if not needItemCfg5 then
        return
    end
    self.m_item5:SetImage(gGetIconManager():GetItemIconByID(needItemCfg5.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.m_item5, needItemCfg5.id)
    self.m_item5:setID(needItemCfg5.id)
    local nOwnItemNum5 = roleItemManager:GetItemNumByBaseID(needItemCfg5.id)
    local strNumNeed_own5 = nOwnItemNum5 .. "/" .. itemnum5_1
    self.m_item5:SetTextUnit(strNumNeed_own5)
    if nOwnItemNum5 >= itemnum5_1 then
        self.m_item5:SetTextUnitColor(MHSD_UTILS.get_greencolor())
    else
        self.m_item5:SetTextUnitColor(MHSD_UTILS.get_redcolor())
    end

    local needItemCfg6 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid6_1)
    if not needItemCfg6 then
        return
    end
    self.m_item6:SetImage(gGetIconManager():GetItemIconByID(needItemCfg6.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.m_item6, needItemCfg6.id)
    self.m_item6:setID(needItemCfg6.id)
    local nOwnItemNum6 = roleItemManager:GetItemNumByBaseID(needItemCfg6.id)
    local strNumNeed_own6 = nOwnItemNum6 .. "/" .. itemnum6_1
    self.m_item6:SetTextUnit(strNumNeed_own6)
    if nOwnItemNum6 >= itemnum6_1 then
        self.m_item6:SetTextUnitColor(MHSD_UTILS.get_greencolor())
    else
        self.m_item6:SetTextUnitColor(MHSD_UTILS.get_redcolor())
    end
    self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(jingmaihecheng_hs1.OnItemNumChangeNotify)
  
    self.selectbtn=self.skillTypeTabBtn1
    self:refreshcount()
end

function jingmaihecheng_hs1.OnItemNumChangeNotify(bagid, itemkey, itembaseid)
    _instance:refreshcount()
end

function jingmaihecheng_hs1:HandleItemClicked(args)
    local e = CEGUI.toMouseEventArgs(args)
    local touchPos = e.position
    local nPosX = touchPos.x
    local nPosY = touchPos.y

    local ewindow = CEGUI.toWindowEventArgs(args)
    local index = ewindow.window:getID()
    local strTable = "fushi.cmonthcardconfig"
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            strTable = "fushi.cmonthcardconfigpay"
        end
    end
    local cfg = BeanConfigManager.getInstance():GetTableByName(strTable):getRecorder(index)

    if cfg then
        local Commontipdlg = require "logic.tips.commontipdlg"
        local commontipdlg = Commontipdlg.getInstanceAndShow()
        local nType = Commontipdlg.eType.eNormal
        local nItemId = cfg.itemid
        commontipdlg:RefreshItem(nType, nItemId, nPosX, nPosY)
    end
end

function jingmaihecheng_hs1:BtnRedPackClicked(args)
    require("logic.libaoduihuan.lyshc1")
    lyshc1.getInstanceAndShow()
end

------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1hs1 = 254100
TaskHelper.m_hc1hs2 = 254101
TaskHelper.m_hc1hs3 = 254102
TaskHelper.m_hc1hs4 = 254103
TaskHelper.m_hc1hs5 = 254104
TaskHelper.m_hc1hs6 = 254105
TaskHelper.m_hc1hs7 = 254106
TaskHelper.m_hc1hs8 = 254107
TaskHelper.m_hc1hs9 = 254108

function jingmaihecheng_hs1:handleClickTipButton1(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7220)  ----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11825) ----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function jingmaihecheng_hs1:handleClickTipButton2(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7221)  ----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11825) ----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function jingmaihecheng_hs1:handleClickTipButton3(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7222)  ----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11825) ----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function jingmaihecheng_hs1:handleClickTipButton4(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7223)  ----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11825) ----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function jingmaihecheng_hs1:handleClickTipButton5(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7224)  ----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11825) ----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function jingmaihecheng_hs1:handleClickTipButton6(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7225)  ----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11825) ----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function jingmaihecheng_hs1:handleClickTipButton7(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7226)  ----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11825) ----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function jingmaihecheng_hs1:handleClickTipButton8(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7227)  ----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11825) ----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

----第九条tips
function jingmaihecheng_hs1:handleClickTipButton9(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7228)  ----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11825) ----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function jingmaihecheng_hs1:HandleClickQieHuan1()
    require "logic.workshop.workshoplabel".Show(1, 3, -1)
    jingmaihecheng_hs1.DestroyDialog()
end

function jingmaihecheng_hs1:HandleClickQieHuan2()
    require "logic.workshop.workshoplabel".Show(2, 3, -1)
    jingmaihecheng_hs1.DestroyDialog()
end

function jingmaihecheng_hs1:HandleClickQieHuan3()
    require "logic.workshop.workshoplabel".Show(3, 3, -1)
    jingmaihecheng_hs1.DestroyDialog()
end

function jingmaihecheng_hs1:HandleClickQieHuan4()
    require "logic.workshop.workshoplabel".Show(4, 3, -1)
    jingmaihecheng_hs1.DestroyDialog()
end

function jingmaihecheng_hs1:refreshcount()
    local selectedBtn =   self.selectbtn
    local id=0
    if self.skillTypeTabBtn1 == selectedBtn then
        id=219001
    elseif self.skillTypeTabBtn2 == selectedBtn then
        id=219031
    elseif self.skillTypeTabBtn3 == selectedBtn then
        id=219061
    elseif self.skillTypeTabBtn4 == selectedBtn then
        id=219091
    elseif self.skillTypeTabBtn5 == selectedBtn then
        id=219121
    elseif self.skillTypeTabBtn6 == selectedBtn then
        id=219151
    elseif self.skillTypeTabBtn7 == selectedBtn then
        id=219181
    elseif self.skillTypeTabBtn8 == selectedBtn then
        id=219211
    elseif self.skillTypeTabBtn9 == selectedBtn then
        id=219241
    end
    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.cpetdazao"):getRecorder(id)
    if itemTable then
        local winMgr = CEGUI.WindowManager:getSingleton()
        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        if self.skillTypeTabBtn1 == selectedBtn then
            self.m_item2:setID(itemTable.bookid)
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.bookid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.booknum)
            self.m_item2:SetTextUnit(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.booknum then
                self.m_item2:SetTextUnitColor(MHSD_UTILS.get_greencolor())
            else
                self.m_item2:SetTextUnitColor(MHSD_UTILS.get_redcolor())
            end
            self.m_item:setID(itemTable.cailiaoid)
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.cailiaoid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.cailiaonum)
            self.m_item:SetTextUnit(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.cailiaonum then
                self.m_item:SetTextUnitColor(MHSD_UTILS.get_greencolor())
            else
                self.m_item:SetTextUnitColor(MHSD_UTILS.get_redcolor())
            end
        elseif self.skillTypeTabBtn2 == selectedBtn then
            self.m_item4:setID(itemTable.bookid)
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.bookid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.booknum)
            self.m_item4:SetTextUnit(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.booknum then
                self.m_item4:SetTextUnitColor(MHSD_UTILS.get_greencolor())
            else
                self.m_item4:SetTextUnitColor(MHSD_UTILS.get_redcolor())
            end
            self.m_item3:setID(itemTable.cailiaoid)
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.cailiaoid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.cailiaonum)
            self.m_item3:SetTextUnit(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.cailiaonum then
                self.m_item3:SetTextUnitColor(MHSD_UTILS.get_greencolor())
            else
                self.m_item3:SetTextUnitColor(MHSD_UTILS.get_redcolor())
            end
        elseif self.skillTypeTabBtn3 == selectedBtn then
            self.m_item5:setID(itemTable.cailiaoid)
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.cailiaoid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.cailiaonum)
            self.m_item5:SetTextUnit(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.cailiaonum then
                self.m_item5:SetTextUnitColor(MHSD_UTILS.get_greencolor())
            else
                self.m_item5:SetTextUnitColor(MHSD_UTILS.get_redcolor())
            end
            self.m_item6:setID(itemTable.bookid)
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.bookid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.booknum)
            self.m_item6:SetTextUnit(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.booknum then
                self.m_item6:SetTextUnitColor(MHSD_UTILS.get_greencolor())
            else
                self.m_item6:SetTextUnitColor(MHSD_UTILS.get_redcolor())
            end
        elseif self.skillTypeTabBtn4 == selectedBtn then
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.bookid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.booknum)
            local book=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc1211")
           
            book:setText(strNumNeed_own2)
             
            if nOwnItemNum2 >= itemTable.booknum then
            
                 book:SetTextColor(0xff00ff00)
            else
                
                 book:SetTextColor(0xffe60000)
            end

            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.cailiaoid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.cailiaonum)
            local cailiao=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc11111")
            cailiao:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.cailiaonum then
                cailiao:SetTextColor(0xff00ff00)
            else
                cailiao:SetTextColor(0xffe60000)
            end
        elseif self.skillTypeTabBtn5 == selectedBtn then
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.bookid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.booknum)
            local book=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc1212")
            book:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.booknum then
                 book:SetTextColor(0xff00ff00)
            else
                 book:SetTextColor(0xffe60000)
            end

            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.cailiaoid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.cailiaonum)
            local cailiao=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc11112")
            cailiao:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.cailiaonum then
                cailiao:SetTextColor(0xff00ff00)
            else
                cailiao:SetTextColor(0xffe60000)
            end
        elseif self.skillTypeTabBtn6 == selectedBtn then
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.bookid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.booknum)
            local book=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc1213")
            book:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.booknum then
                 book:SetTextColor(0xff00ff00)
            else
                 book:SetTextColor(0xffe60000)
            end

            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.cailiaoid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.cailiaonum)
            local cailiao=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc11113")
            cailiao:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.cailiaonum then
                cailiao:SetTextColor(0xff00ff00)
            else
                cailiao:SetTextColor(0xffe60000)
            end
        elseif self.skillTypeTabBtn7 == selectedBtn then
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.bookid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.booknum)
            local book=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc12111")
            book:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.booknum then
                 book:SetTextColor(0xff00ff00)
            else
                 book:SetTextColor(0xffe60000)
            end

            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.cailiaoid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.cailiaonum)
            local cailiao=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc111111")
            cailiao:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.cailiaonum then
                cailiao:SetTextColor(0xff00ff00)
            else
                cailiao:SetTextColor(0xffe60000)
            end
           
        elseif self.skillTypeTabBtn8 == selectedBtn then
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.bookid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.booknum)
            local book=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc12121")
            book:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.booknum then
                 book:SetTextColor(0xff00ff00)
            else
                 book:SetTextColor(0xffe60000)
            end

            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.cailiaoid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.cailiaonum)
            local cailiao=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc111121")
            cailiao:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.cailiaonum then
                cailiao:SetTextColor(0xff00ff00)
            else
                cailiao:SetTextColor(0xffe60000)
            end
           
        elseif self.skillTypeTabBtn9 == selectedBtn then
            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.bookid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.booknum)
            local book=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc12131")
            book:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.booknum then
                 book:SetTextColor(0xff00ff00)
            else
                 book:SetTextColor(0xffe60000)
            end

            local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(itemTable.cailiaoid)
            local strNumNeed_own2 = nOwnItemNum2.."/"..tostring(itemTable.cailiaonum)
            local cailiao=winMgr:getWindow("jingmaihecheng_hs/skillscroll/clbs1/slyqc111131")
            cailiao:setText(strNumNeed_own2)
            if nOwnItemNum2 >= itemTable.cailiaonum then
                cailiao:SetTextColor(0xff00ff00)
            else
                cailiao:SetTextColor(0xffe60000)
            end
        end
 
    end
end

function jingmaihecheng_hs1:handleSwitchSkillTypeTab()
    local selectedBtn = self.skillTypeTabBtn1:getSelectedButtonInGroup()
    self.selectbtn=selectedBtn
    if self.skillTypeTabBtn1 == selectedBtn then
        if not self.skillpanel:isVisible() then
            self.skillpanel:setVisible(true)
            self.neidanpanel:setVisible(false)
            self.neidanpanel3:setVisible(false)
            self.neidanpanel4:setVisible(false)
            self.neidanpanel5:setVisible(false)
            self.neidanpanel6:setVisible(false) -- 隐藏
            self.neidanpanel7:setVisible(false) --隐藏
            self.neidanpanel8:setVisible(false) -- 隐藏 8 面板
            self.neidanpanel9:setVisible(false) -- 隐藏 9 面板
        end
    elseif self.skillTypeTabBtn2 == selectedBtn then
        if not self.neidanpanel:isVisible() then
            self.skillpanel:setVisible(false)
            self.neidanpanel:setVisible(true)
            self.neidanpanel3:setVisible(false)
            self.neidanpanel4:setVisible(false)
            self.neidanpanel5:setVisible(false)
            self.neidanpanel6:setVisible(false) -- 隐藏 6 面板
            self.neidanpanel7:setVisible(false) -- 隐藏 7 面板
            self.neidanpanel8:setVisible(false) -- 隐藏 8 面板
            self.neidanpanel9:setVisible(false) -- 隐藏 9 面板
        end
    elseif self.skillTypeTabBtn3 == selectedBtn then
        if not self.neidanpanel3:isVisible() then
            self.skillpanel:setVisible(false)
            self.neidanpanel:setVisible(false)
            self.neidanpanel3:setVisible(true)
            self.neidanpanel4:setVisible(false)
            self.neidanpanel5:setVisible(false)
            self.neidanpanel6:setVisible(false) -- 隐藏 6 面板
            self.neidanpanel7:setVisible(false) -- 隐藏 7 面板
            self.neidanpanel8:setVisible(false) -- 隐藏 8 面板
            self.neidanpanel9:setVisible(false) -- 隐藏 9 面板
        end
    elseif self.skillTypeTabBtn4 == selectedBtn then
        if not self.neidanpanel4:isVisible() then
            self.skillpanel:setVisible(false)
            self.neidanpanel:setVisible(false)
            self.neidanpanel3:setVisible(false)
            self.neidanpanel4:setVisible(true)
            self.neidanpanel5:setVisible(false)
            self.neidanpanel6:setVisible(false) -- 隐藏 6 面板
            self.neidanpanel7:setVisible(false) -- 隐藏 7 面板
            self.neidanpanel8:setVisible(false) -- 隐藏 8 面板
            self.neidanpanel9:setVisible(false) -- 隐藏 9 面板
        end
    elseif self.skillTypeTabBtn5 == selectedBtn then
        if not self.neidanpanel5:isVisible() then
            self.skillpanel:setVisible(false)
            self.neidanpanel:setVisible(false)
            self.neidanpanel3:setVisible(false)
            self.neidanpanel4:setVisible(false)
            self.neidanpanel5:setVisible(true)
            self.neidanpanel6:setVisible(false) -- 隐藏 6 面板
            self.neidanpanel7:setVisible(false) -- 隐藏 7 面板
            self.neidanpanel8:setVisible(false) -- 隐藏 8 面板
            self.neidanpanel9:setVisible(false) -- 隐藏 9 面板
        end
    elseif self.skillTypeTabBtn6 == selectedBtn then
        if not self.neidanpanel6:isVisible() then
            self.skillpanel:setVisible(false)
            self.neidanpanel:setVisible(false)
            self.neidanpanel3:setVisible(false)
            self.neidanpanel4:setVisible(false)
            self.neidanpanel5:setVisible(false)
            self.neidanpanel6:setVisible(true)  -- 显示内丹 6 面板
            self.neidanpanel7:setVisible(false) -- 隐藏 7 面板
            self.neidanpanel8:setVisible(false) -- 隐藏 8 面板
            self.neidanpanel9:setVisible(false) -- 隐藏 9 面板
        end
    elseif self.skillTypeTabBtn7 == selectedBtn then
        if not self.neidanpanel7:isVisible() then
            self.skillpanel:setVisible(false)
            self.neidanpanel:setVisible(false)
            self.neidanpanel3:setVisible(false)
            self.neidanpanel4:setVisible(false)
            self.neidanpanel5:setVisible(false)
            self.neidanpanel6:setVisible(false) -- 隐藏 6 面板
            self.neidanpanel7:setVisible(true)  -- 显示内丹 7 面板
            self.neidanpanel8:setVisible(false) -- 隐藏 8 面板
            self.neidanpanel9:setVisible(false) -- 隐藏 9 面板
        end
    elseif self.skillTypeTabBtn8 == selectedBtn then
        if not self.neidanpanel8:isVisible() then
            self.skillpanel:setVisible(false)
            self.neidanpanel:setVisible(false)
            self.neidanpanel3:setVisible(false)
            self.neidanpanel4:setVisible(false)
            self.neidanpanel5:setVisible(false)
            self.neidanpanel6:setVisible(false) -- 隐藏 6 面板
            self.neidanpanel7:setVisible(false) -- 隐藏 7 面板
            self.neidanpanel8:setVisible(true)  -- 显示内丹 8 面板
            self.neidanpanel9:setVisible(false) -- 隐藏 9 面板
        end
    elseif self.skillTypeTabBtn9 == selectedBtn then
        if not self.neidanpanel9:isVisible() then
            self.skillpanel:setVisible(false)
            self.neidanpanel:setVisible(false)
            self.neidanpanel3:setVisible(false)
            self.neidanpanel4:setVisible(false)
            self.neidanpanel5:setVisible(false)
            self.neidanpanel6:setVisible(false) -- 隐藏 6 面板
            self.neidanpanel7:setVisible(false) -- 隐藏 7 面板
            self.neidanpanel8:setVisible(false) -- 隐藏 8 面板
            self.neidanpanel9:setVisible(true)  -- 显示内丹 9 面板
        end
    end
    self:refreshcount()
end

function jingmaihecheng_hs1:DestroyDialog1()
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

function jingmaihecheng_hs1.hc1hs1()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_hc1hs1
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function jingmaihecheng_hs1.hc1hs2()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_hc1hs2
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function jingmaihecheng_hs1.hc1hs3()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_hc1hs3
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function jingmaihecheng_hs1.hc1hs4()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_hc1hs4
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function jingmaihecheng_hs1.hc1hs5()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_hc1hs5
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function jingmaihecheng_hs1.hc1hs6()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_hc1hs6
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function jingmaihecheng_hs1.hc1hs7()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_hc1hs7
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function jingmaihecheng_hs1.hc1hs8()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_hc1hs8
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function jingmaihecheng_hs1.hc1hs9()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_hc1hs9
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

return jingmaihecheng_hs1

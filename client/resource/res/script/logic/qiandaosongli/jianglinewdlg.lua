require "logic.dialog"

Jianglinew = { }
setmetatable(Jianglinew, Dialog)
Jianglinew.__index = Jianglinew

Jianglinew.systemId =
{
    everyDaySign = 1,----每日签到
    firstBuyReward = 2,-----首充礼包
    VipReward = 3,-------充值返利
    MonthCard = 4,-------福利周卡
    QQGift = 5,------礼包兑换
    sevenSign = 6,-----七天奖励
    newPlayerReward = 7,-----新手在线
    levelupReward = 8,------升级礼包
    TestReturn = 9,-----封测返还
    PhoneBind = 10,-----手机关联
    systemIdMax = 11-----大型节日
}

local _instance
function Jianglinew.getInstance()
    if not _instance then
        _instance = Jianglinew:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jianglinew.getInstanceAndShow()
    if not _instance then
        _instance = Jianglinew:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Jianglinew.getInstanceNotCreate()
    return _instance
end

function Jianglinew.DestroyDialog()
    if not _instance then
        return
    end

    _instance:OnClose()
    _instance = nil
end

function Jianglinew:OnClose()


    self:removeAllDlg()
    self:resetData()

    Dialog.OnClose(self)

end

function Jianglinew.ToggleOpenClose()
    if not _instance then
        _instance = Jianglinew:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Jianglinew.GetLayoutFileName()
    return "jianglixin.layout"
end

function Jianglinew:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Jianglinew)
    self:resetData()
    return self
end

function Jianglinew:resetData()
    self.mapSysBtn = { }
    self.nCurSysId = 0
    self.vDlg = { }
    self.curDlg = nil

end


function Jianglinew:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    SetPositionScreenCenter(self:GetWindow())
	
	self.tuijianbtn = CEGUI.toGroupButton(winMgr:getWindow("jianglixin/tjbtn"))

	self.tuijianbtn:subscribeEvent("SelectStateChanged", Jianglinew.fuliTypeTab, self)
	
	self.gengduobtn = CEGUI.toGroupButton(winMgr:getWindow("jianglixin/gdbtn"))
	self.gengduobtn:subscribeEvent("SelectStateChanged", Jianglinew.fuliTypeTab, self)
	
    self.scrollPanel = CEGUI.toScrollablePane(winMgr:getWindow("jianglixin/liebiaodi/liebiao"))
	self.scrollPane2 = CEGUI.toScrollablePane(winMgr:getWindow("jianglixin/liebiaodi/liebiaoc"))
    self.panelRightBg = winMgr:getWindow("jianglixin/neirong")
    self:initLeftBtn()
	self.tuijianbtn:setSelected(true)
    self:showSysIdFromBtn(1) 
    LoginRewardManager.getInstance():refreshAllRed()
end

function Jianglinew:fuliTypeTab()
    local selectedBtn = self.tuijianbtn:getSelectedButtonInGroup()
    if self.tuijianbtn == selectedBtn then
        self.scrollPanel:setVisible(true)
        self.scrollPane2:setVisible(false)

        -- 选中列表 1 的第一个按钮 (ID 为 1)
        self:showSysId(1)
    elseif self.gengduobtn == selectedBtn then
        self.scrollPanel:setVisible(false)
        self.scrollPane2:setVisible(true)

        -- 选中列表 2 的第一个按钮 (ID 为 5)
        self:showSysId(5)
    end
end


function Jianglinew:getSysId(vSysId)
    local lrManager = require("logic.qiandaosongli.loginrewardmanager").getInstance()
    for nSysId = 1, Jianglinew.systemId.systemIdMax - 1 do
        local nHave = lrManager.m_listOpenReward[nSysId]
        if nHave and nHave == 1 then
            vSysId[#vSysId + 1] = nSysId
        end
    end
end

function Jianglinew:initLeftBtn()
    local vSysId = { }
    self:getSysId(vSysId)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local nIndex2 = 1 -- 列表2的索引
    local nIndex1 = 1 -- 列表1的索引

    for nIndex = 1, #vSysId do
        local nSysId = vSysId[nIndex]
        local sysTable = BeanConfigManager.getInstance():GetTableByName("fushi.crewardsystembtnshow"):getRecorder(nSysId)
        local btnw = 205
        local btnh = 74
        local btn
        if nSysId == 4 or nSysId == 6 then
            btn = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/CellGroupButtonhd1"))
        else
            btn = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/CellGroupButtonhd"))
        end
        btn:setGroupID(0)
        btn:setProperty("Font", "simhei-13")
        btn:setID(nSysId)
        btn:setText(sysTable.systemname)
        btn:setSize(CEGUI.UVector2(CEGUI.UDim(0, btnw), CEGUI.UDim(0, btnh)))
        btn:EnableClickAni(false)

        local img = winMgr:createWindow("TaharezLook/StaticImage")
        img:setProperty("Image", sysTable.btnimage)
        img:setMousePassThroughEnabled(true)
        img:setAlwaysOnTop(true)
        img:setSize(CEGUI.UVector2(CEGUI.UDim(0, 75), CEGUI.UDim(0, 69)))
        img:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0,1)))
        img:setVisible(true)
        btn:addChildWindow(img)

        if nIndex == Jianglinew.systemId.firstBuyReward then
            self.shouChongBtnName = btn:getName()
        end

        --  把 nSysId == 5 也加到判断条件里
        if nSysId == 5 or nSysId == 6 or nSysId == 7 or nSysId == 10 then  
            self.scrollPane2:addChildWindow(btn)
            btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0,(nIndex2 - 1) *(btnh + 5))))
            nIndex2 = nIndex2 + 1
        else
            self.scrollPanel:addChildWindow(btn)
            btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0,(nIndex1 - 1) *(btnh + 5)))) 
            nIndex1 = nIndex1 + 1 
        end

        btn:subscribeEvent("SelectStateChanged", Jianglinew.handleScoreGroupBtnClicked, self)
        self.mapSysBtn[nSysId] = btn
        self:addRedPoint(nSysId, btn)

        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                if nSysId == Jianglinew.systemId.MonthCard then
                    btn:setText(MHSD_UTILS.get_resstring(11561))
                end       
            end
        end
    end
end



function Jianglinew:addRedPoint(nSysId, btn)
    local winMgr = CEGUI.WindowManager:getSingleton()
    btn.redballOut = winMgr:createWindow("TaharezLook/StaticImage", nSysId .. "Jianglinewred")
    btn.redballOut:setProperty("Image", "set:common_equip image:equip_biaohong")
    btn.redballOut:setSize(CEGUI.UVector2(CEGUI.UDim(0, 30), CEGUI.UDim(0, 30)))

    btn.redballOut:setVisible(false)
    btn.redballOut:setAlwaysOnTop(true)
    btn:addChildWindow(btn.redballOut)

    local btnSize = btn:getPixelSize()
    local x = CEGUI.UDim(0, btnSize.width - 30)
    local y = CEGUI.UDim(0, 0)
    local pos = CEGUI.UVector2(x, y)
    btn.redballOut:setPosition(pos)
end

function Jianglinew:refreshAllRedPoint()
    local lrManager = LoginRewardManager.getInstance()
    local tempRedID = lrManager.m_listRewardEffect

    for nSysId = 1, Jianglinew.systemId.systemIdMax - 1 do

        local pBtn = self.mapSysBtn[nSysId]
        local nRedFlag = tempRedID[nSysId]
        if pBtn then
            if nRedFlag and nRedFlag == 1 then
                pBtn.redballOut:setVisible(true)
            else
                pBtn.redballOut:setVisible(false)
            end
        end
    end
end

function Jianglinew:refreshRedWithSysId(nSysId, bShowRed)
    local pBtn = self.mapSysBtn[nSysId]
    if not pBtn then
        return
    end
    pBtn.redballOut:setVisible(bShowRed)
end

function Jianglinew:handleScoreGroupBtnClicked(args)
    local nSysId = CEGUI.toWindowEventArgs(args).window:getID()
    self:showSysIdFromBtn(nSysId)

end

function Jianglinew:showSysId(nSysIdToShow)
    local dlg = self:showSysIdFromBtn(nSysIdToShow)

    for nSysId, pBtn in pairs(self.mapSysBtn) do
        if nSysId == nSysIdToShow then
            pBtn:setSelected(true)
        else
            pBtn:setSelected(false)
        end
    end
    return dlg
end


function Jianglinew:removeAllDlg()
    if not self.vDlg then
        return
    end

    for k, v in pairs(self.vDlg) do
        self:removeDlg(v)
    end
    self.vDlg = { }
end

function Jianglinew:removeDlg(curDlg)
    if not curDlg then
        return
    end
    local curWin = curDlg.m_pMainFrame
    CEGUI.WindowManager:getSingleton():destroyWindow(curWin)
    curDlg:remove()
end


function Jianglinew:createDlg(nSysId)

    local dlg = nil
    if nSysId == Jianglinew.systemId.everyDaySign then
        dlg = require("logic.qiandaosongli.qiandaosonglidlg_mtg").create()
    elseif nSysId == Jianglinew.systemId.firstBuyReward then
        dlg = require("logic.qiandaosongli.mtg_firstchargedlg").create()
    elseif nSysId == Jianglinew.systemId.VipReward then
        dlg = require("logic.vip.vip").create()
    elseif nSysId == Jianglinew.systemId.MonthCard then
        dlg = require("logic.monthcard.monthcarddlg").getInstance()
    elseif nSysId == Jianglinew.systemId.QQGift then
        dlg = debugrequire("logic.qqgift.qqgiftdlg").getInstance()
    elseif nSysId == Jianglinew.systemId.sevenSign then
        dlg = require("logic.qiandaosongli.continuedayreward").create()
    elseif nSysId == Jianglinew.systemId.newPlayerReward then
        dlg = require("logic.qiandaosongli.mtg_onlinewelfaredlg").create()
    elseif nSysId == Jianglinew.systemId.levelupReward then
        dlg = require("logic.qiandaosongli.leveluprewarddlg").create()
    elseif nSysId == Jianglinew.systemId.TestReturn then
        dlg = require("logic.qiandaosongli.fengcefanhuandlg").create()
    elseif nSysId == Jianglinew.systemId.PhoneBind then
        dlg = require("logic.qiandaosongli.shoujiguanlianjiangli").create()
    end
    return dlg
end

function Jianglinew:getDlg(nSysId)

    local dlg = self.vDlg[nSysId]
    if dlg then
        return dlg
    end
    dlg = self:createDlg(nSysId)
    self.vDlg[nSysId] = dlg
    return dlg

end

function Jianglinew:showSysIdFromBtn(nSysId)

    if nSysId == self.nCurSysId then
        return self.curDlg
    end

    if self.curDlg then
        self.curDlg.m_pMainFrame:setVisible(false)
    end

    self.nCurSysId = nSysId

    local newDlg = self.vDlg[nSysId]
    if not newDlg then
        newDlg = self:createDlg(nSysId)
        if not newDlg then
            return nil
        end
        self.vDlg[nSysId] = newDlg
        local curWin = newDlg.m_pMainFrame
        self.panelRightBg:addChildWindow(curWin)
        local x = CEGUI.UDim(0, 0)
        local y = CEGUI.UDim(0, 0)
        local pos = CEGUI.UVector2(x, y)
        curWin:setPosition(pos)
    else
    end

    newDlg.m_pMainFrame:setVisible(true)
    self.curDlg = newDlg
    return self.curDlg

end

function Jianglinew:ShowVipDialog()
    if self.shouChongBtnName then
        local winMgr = CEGUI.WindowManager:getSingleton()
        local btn = winMgr:getWindow(self.shouChongBtnName)
        if btn ~= nil then
            local nSysId = Jianglinew.systemId.VipRewardnpcshopduihuan_mtg
            local btn = winMgr:getWindow(self.shouChongBtnName)
            btn:setID(nSysId)
            local sysTable = BeanConfigManager.getInstance():GetTableByName("fushi.crewardsystembtnshow"):getRecorder(nSysId)
            btn:setText(sysTable.systemname)
            self.mapSysBtn[nSysId]=nil
            self.mapSysBtn[nSysId]=nil
            self.mapSysBtn[nSysId]=btn
            self:addRedPoint(nSysId, btn)
            self:showSysIdFromBtn(nSysId)
        end
    end
end

return Jianglinew


QiandaosongliDlg = {}
QiandaosongliDlg.__index = QiandaosongliDlg

local _instance

function QiandaosongliDlg.create()
    if not _instance then
        _instance = QiandaosongliDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function QiandaosongliDlg.getInstance()
    local Jianglinew = require("logic.qiandaosongli.jianglinewdlg")
    local jlDlg = Jianglinew.getInstanceAndShow()
    if not jlDlg then
        return nil
    end
    local dlg = jlDlg:showSysId(Jianglinew.systemId.everyDaySign)
    return dlg
end

function QiandaosongliDlg.getInstanceAndShow()
    return QiandaosongliDlg.getInstance()
end

function QiandaosongliDlg.getInstanceNotCreate()
    return _instance
end

function QiandaosongliDlg:remove()
    self.textScrollAnimation:stop()
    self.textScrollAnimation1:stop()
    self:clearData()
    _instance = nil
end

function QiandaosongliDlg:clearData()
    if not self.m_cells then
        return
    end
    for index in pairs(self.m_cells) do
        local cell = self.m_cells[index]
        if cell then
            cell:OnClose()
        end
    end
end

function QiandaosongliDlg.DestroyDialog()
    require("logic.qiandaosongli.jianglinewdlg").DestroyDialog()
end

function QiandaosongliDlg:new()
    local self = {}
    setmetatable(self, QiandaosongliDlg)
    return self
end

function QiandaosongliDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function QiandaosongliDlg:OnCreate()
    local winMgr = CEGUI.WindowManager:getSingleton()

    local layoutName = "qiandaosonglimain.layout"
    self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)
    self.m_bg = CEGUI.toFrameWindow(winMgr:getWindow("qiandaosonglimain"))
    self.m_scrollReward = CEGUI.toScrollablePane(winMgr:getWindow("qiandaosonglimain/down/back"))
    self.m_txtDay = winMgr:getWindow("qiandaosonglimain/leijitian")
    self.m_txtTimes = winMgr:getWindow("qiandaosonglimain/buqiantian")
    self.m_newqiandao = winMgr:getWindow("qiandaosonglimain/newqiandao")

    self.m_ccriqiTxt = winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc/ccriqi")
    self:GetWindow():subscribeEvent("WindowUpdate", self.onUpdate, self)

    self.m_newitemcell = CEGUI.toItemCell(winMgr:getWindow("qiandaosonglimain/newqiandao/item"))
    self.m_newitemcell:subscribeEvent("MouseButtonUp", self.OnNewItemClick, self)

    self.cc_wqd = winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc/btc1/wqd")
    self.cc_yqd = winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc/btc1/yqd")

    self.itemname = winMgr:getWindow("qiandaosonglimain/newqiandao/itemname")

    self.m_newccqdbtn = CEGUI.toPushButton(winMgr:getWindow("qiandaosonglimain/newqiandao/ccqdbtn"))
    self.m_newccqdbtn:subscribeEvent("MouseButtonUp", self.OnSignInButtonClicked, self)

    self.imgCover = winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc/cczy")

    -- self.cc_scrollReward = CEGUI.toScrollablePane(winMgr:getWindow("qiandaosonglimain/newqiandao/zhoukabg"))
    -- self.cc_zkitemcells = {}
    -- for i = 1, 10 do
    --     local itemCell = CEGUI.toItemCell(winMgr:getWindow("qiandaosonglimain/newqiandao/zhoukabg/itemc" .. i))
    --     self.cc_scrollReward:addChildWindow(itemCell)
    --     table.insert(self.cc_zkitemcells, itemCell)
    --     itemCell:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCellc, Workshopmanager)
    -- end


    self.ccrdtips = CEGUI.toRichEditbox(winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc1/ccsjrd"))
    self.ccrdtips:Clear()
    self.ccrdtips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7500)))
    self.ccrdtips:Refresh()

    self.cczhoukatips = CEGUI.toRichEditbox(winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc11/zktipsck/zktips"))
    self.cczhoukatips:Clear()
    self.cczhoukatips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7501)))
    self.cczhoukatips:Refresh()

    local animationDefcc1 = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong1")
    self.textScrollAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDefcc1)
    self.textScrollAnimation:setTargetWindow(self.cczhoukatips)
    self.textScrollAnimation:start()

    local animationDefcc2 = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong2")
    self.textScrollAnimation1 = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDefcc2)
    self.textScrollAnimation1:setTargetWindow(self.cczhoukatips)


    self.cczhoukatips:subscribeEvent(
        "AnimationEnded",
        function(args)
            self.textScrollAnimation1:start()
        end
    )


    self.m_zkdh = CEGUI.Window.toPushButton(winMgr:getWindow("qiandaosonglimain/newqiandao/zkdhbtn"))
    self:addButtonAnimation(self.m_zkdh, "studyBtnPress")
    self.m_zkdh:subscribeEvent("Clicked", QiandaosongliDlg.zkdhcy, self)
    TaskHelper.m_zkdh = 254800

    self.m_month = 0
    self.m_times = 0
    self.m_fillTimes = 0
    self.m_flag = 0
    self.m_nFillTimes = 0
    self.m_dayNums = 0
    self.m_cells = {}
    self:InitCell()
    if NewRoleGuideManager.getInstance() then
        NewRoleGuideManager.getInstance():AddParticalToWnd(self.m_newccqdbtn)
    end
    local mgr = LoginRewardManager:getInstance()
    self:SetData(mgr.signinmonth, mgr.signintimes, mgr.signinrewardflag, mgr.signinsuppsignnums, mgr.signinsuppregdays,
        mgr.cansuppregtimes)
    -- self:LoadZhoukaItemCells()
end

-- function QiandaosongliDlg:LoadZhoukaItemCells()
--     local allItemIds = BeanConfigManager.getInstance():GetTableByName("item.Czhoukaitem"):getAllID()
--     for i = 1, #allItemIds do
--         local nItemId = allItemIds[i]
--         local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
--         if itemTable then
--             local itemCell = self.cc_zkitemcells[i]
--             local nQuality = itemTable.nquality
--             SetItemCellBoundColorByQulityItem(itemCell, nQuality, itemTable.itemtypeid)
--             itemCell:setID(nItemId)
--             itemCell:SetImage(gGetIconManager():GetItemIconByID(itemTable.icon))
--         else

--        end
--     end
-- end

function QiandaosongliDlg:onUpdate(args)
    local currentTime = os.date("*t")
    local formattedDateTime = string.format("%d年/%d月/%d日 %02d:%02d:%02d",
        currentTime.year, currentTime.month, currentTime.day,
        currentTime.hour, currentTime.min, currentTime.sec)

    self.m_ccriqiTxt:setText(formattedDateTime)
end

function QiandaosongliDlg:GetWindow()
    return self.m_pMainFrame
end

function QiandaosongliDlg.zkdhcy()
    local nNpcKey = 0
    local nServiceId = TaskHelper.m_zkdh
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function QiandaosongliDlg:InitCell()
    local parentWidth = self.m_scrollReward:getPixelSize().width
    for i = 1, 31 do
        local curCell = QiandaosongliCell.CreateNewDlg(self.m_scrollReward)
        local cellPerRow = math.floor(parentWidth / curCell.m_width)
        local row = math.floor((i - 1) / cellPerRow)
        local x = CEGUI.UDim(0, 1 + ((i - 1) % cellPerRow) * curCell.m_width)
        local y = CEGUI.UDim(0, 1 + row * curCell.m_height)
        local pos = CEGUI.UVector2(x, y)
        curCell:GetWindow():setPosition(pos)

        curCell:GetWindow():setVisible(false)
        table.insert(self.m_cells, curCell)
    end
end

function QiandaosongliDlg:RefreshText()
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", self.m_times)
    local strTimes = strbuilder:GetString(MHSD_UTILS.get_resstring(11162))
    strbuilder:delete()
    self.m_txtDay:setText(strTimes)

    local strbuilderB = StringBuilder:new()
    strbuilderB:Set("parameter1", self.m_nFillTimes)
    local strFillTimes = strbuilderB:GetString(MHSD_UTILS.get_resstring(11163))
    strbuilderB:delete()
    self.m_txtTimes:setText(strFillTimes)
end

function QiandaosongliDlg:SetData(month, times, flag, fillTimes, days, cansuppregtimes)
    self.m_month = month
    self.m_times = times
    self.m_flag = flag
    self.m_nFillTimes = fillTimes
    self.m_days = days
    self.m_cansuppregtimes = cansuppregtimes
    local nCansuppregtime = self.m_cansuppregtimes
    if self.m_nFillTimes <= self.m_cansuppregtimes then
        nCansuppregtime = self.m_nFillTimes
    end

    local todayCfg = self:GetRecord(self.m_month, self.m_times)

    if todayCfg then
        local itemID = todayCfg.itemid
        if itemID == 0 then
            local conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(todayCfg
            .mtype)
            local set, img = string.match(conf.iconpath, "set:(.*) image:(.*)")
            self.m_newitemcell:SetImage(set, img)
        else
            local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemID)
            if itemAttrCfg then
                self.m_newitemcell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
                SetItemCellBoundColorByQulityItemWithId(self.m_newitemcell, itemAttrCfg.id)
            end
        end
        local itemName = ""
        local itemID = todayCfg.itemid
        if itemID ~= 0 then
            local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemID)
            if itemAttrCfg then
                itemName = itemAttrCfg.name
            end
        end
        self.itemname:setText(itemName)


        local num = todayCfg.itemnum > 0 and todayCfg.itemnum or todayCfg.money

        if num == 1 then
            self.m_newitemcell:SetTextUnitText(CEGUI.String(""))
        else
            self.m_newitemcell:SetTextUnitText(CEGUI.String("" .. num))
        end
    end
    local fillDay = 0
    local daysNum = 0
    for i, v in ipairs(self.m_cells) do
        local curCell = v
        local cfg = self:GetRecord(self.m_month, i)

        curCell:SetID(self.m_month * 100 + i)
        curCell:SetTimes(self.m_times)

        if self.m_flag == 0 then
            if self.m_times + 1 == i then
                curCell:SetFlag(self.m_flag)
            end
        elseif self.m_flag == 1 then
            if self.m_times == i then
                curCell:SetFlag(self.m_flag)
            end
        end

        if self.m_flag == 0 then
            if nCansuppregtime > daysNum and i > self.m_times + 1 then
                curCell:SetBuqian(true)
                daysNum = daysNum + 1
            else
                curCell:SetBuqian(false)
            end
        elseif self.m_flag == 1 then
            if nCansuppregtime > daysNum and i > self.m_times then
                curCell:SetBuqian(true)
                daysNum = daysNum + 1
            else
                curCell:SetBuqian(false)
            end
        end

        curCell:RefreshShow()

        if cfg == nil and daysNum == 0 then
            daysNum = i
        end

        if i == 31 then
            daysNum = 31
        end
    end

    if self.m_flag == 1 and (self.m_month * 100 + self.m_times) % 100 == self.m_times then
        self.imgCover:setAlpha(0)
    else
        self.imgCover:setAlpha(1)
    end

    if self.m_flag == 0 and (self.m_month * 100 + self.m_times + 1) % 100 == self.m_times + 1 then
        self.m_newccqdbtn:setEnabled(true)
        if NewRoleGuideManager.getInstance() then
            NewRoleGuideManager.getInstance():AddParticalToWnd(self.m_newccqdbtn)
        end
    else
        self.m_newccqdbtn:setEnabled(false)
        gGetGameUIManager():RemoveUIEffect(self.m_newccqdbtn)
    end

    if self.m_flag == 0 and (self.m_month * 100 + self.m_times + 1) % 100 == self.m_times + 1 then
        -- 可签到状态下
        self.cc_wqd:setVisible(true)
        self.cc_yqd:setVisible(false)
    else
        -- 已签到状态下
        self.cc_wqd:setVisible(false)
        self.cc_yqd:setVisible(true)
    end


    self.m_dayNums = daysNum

    self:RefreshText()
end

function QiandaosongliDlg:OnSignInButtonClicked(args)
    if self.m_flag == 0 and (self.m_month * 100 + self.m_times + 1) % 100 == self.m_times + 1 then
        local p = require "protodef.fire.pb.activity.reg.creg":new()
        p.month = (self.m_month * 100 + self.m_times + 1) / 100
        require "manager.luaprotocolmanager":send(p)
        local aniMan = CEGUI.AnimationManager:getSingleton()
        local animation = aniMan:getAnimation("qiandaobtn")
        local animationInstance = aniMan:instantiateAnimation(animation)
        if animationInstance ~= nil then
            animationInstance:setTargetWindow(self.imgCover)
            animationInstance:start()
        end
    else
        -- 不可以签到-不需要做，已经做了按钮禁用
        -- 后续迭代可以做类似于官方点击 签到 跳转刮刮乐界面
    end
end

function QiandaosongliDlg:OnNewItemClick(args)
    local e = CEGUI.toMouseEventArgs(args)
    local touchPos = e.position
    local nPosX = touchPos.x
    local nPosY = touchPos.y

    local Commontipdlg = require "logic.tips.commontipdlg"
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    local nType = Commontipdlg.eType.eSignIn
    local nItemId = self.m_month * 100 + self.m_times
    commontipdlg:RefreshItem(nType, nItemId, nPosX, nPosY)
end

function QiandaosongliDlg:GetRecord(month, day)
    local tb = BeanConfigManager.getInstance():GetTableByName("game.cqiandaojiangli")
    local id = month * 100 + day
    return (tb:getRecorder(id))
end

return QiandaosongliDlg
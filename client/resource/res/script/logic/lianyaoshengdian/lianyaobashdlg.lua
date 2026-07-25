require "logic.dialog"

LianYaoBashDlg = {
    cells = {}
}
setmetatable(LianYaoBashDlg, Dialog)
LianYaoBashDlg.__index = LianYaoBashDlg

local _instance
function LianYaoBashDlg.getInstance()
    if not _instance then
        _instance = LianYaoBashDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function LianYaoBashDlg.getInstanceAndShow()
    if not _instance then
        _instance = LianYaoBashDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function LianYaoBashDlg.getInstanceNotCreate()
    return _instance
end

function LianYaoBashDlg.DestroyDialog()
    if _instance then
        CurrencyManager.unregisterTextWidget(_instance.HaveMoneyNum)
        for i = 1, 11 do
            gGetGameUIManager():RemoveUIEffect(_instance.itemCells[i])
        end
        if _instance.m_tableview ~= nil then
            _instance.m_tableview:destroyCells()
            _instance.cells = nil
        end
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function LianYaoBashDlg.ToggleOpenClose()
    if not _instance then
        _instance = LianYaoBashDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function LianYaoBashDlg.GetLayoutFileName()
    return "lianyaoshengdian.layout"
end

function LianYaoBashDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LianYaoBashDlg)
    return self
end

function LianYaoBashDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.BaiChongBnt = CEGUI.toPushButton(winMgr:getWindow("lianyaoshengdian_main/bcxc"))
    self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("lianyaoshengdian_main/guanbi"))
    self.ItemList = CEGUI.toScrollablePane(winMgr:getWindow("lianyaoshengdian_main/main/liebiao_di/liebiao"))
    self.MinItemNum = CEGUI.toPushButton(winMgr:getWindow("lianyaoshengdian_main/main/jian"))
    self.AddItemNum = CEGUI.toPushButton(winMgr:getWindow("lianyaoshengdian_main/main/jia"))
    self.BuyItemNum = winMgr:getWindow("lianyaoshengdian_main/main/numdi/itemnum")
    self.CurrBuyMoneyNum = winMgr:getWindow("lianyaoshengdian_main/main/xianyu1/text1")
    self.HaveMoneyNum = winMgr:getWindow("lianyaoshengdian_main/main/xianyu2/text2")
    self.TopUpBtn = CEGUI.toPushButton(winMgr:getWindow("lianyaoshengdian_main/main/xianyu2/czbtn"))
    self.BuyBtn = CEGUI.toPushButton(winMgr:getWindow("lianyaoshengdian_main/main/okbtn"))
    self.BigAwardItemName = winMgr:getWindow("lianyaoshengdian_main/main/itemname")
    self.AwardList = CEGUI.toScrollablePane(winMgr:getWindow("lianyaoshengdian_main/awardlist"))
    self.ProgressBox = CEGUI.toProgressBar(winMgr:getWindow("lianyaoshengdian_main/awardlist/jindu"))
    self.currprovalue = winMgr:getWindow("lianyaoshengdian_main/awardlist/jindu/jinduzhi")
    self.itemCells = {}
    self.itemNums = {}
    self.shu = {}
    self.AwardList:EnableHorzScrollBar(true)
    self.ItemList:EnableVertScrollBar(true)
    self.AwardList:EnableAllChildDrag(self.AwardList)
    for i = 1, 11 do
        self.itemCells[i] = CEGUI.toItemCell(winMgr:getWindow("lianyaoshengdian_main/awardlist/shu" ..
            tostring(i) .. "/award" .. tostring(i)))
        self.itemNums[i] = winMgr:getWindow("lianyaoshengdian_main/awardlist/shu" ..
            tostring(i) .. "/award" .. tostring(i) .. "/num" .. tostring(i))
        self.itemCells[i]:subscribeEvent("TableClick", LianYaoBashDlg.HandleGetAward, self)
        self.AwardList:EnableChildDrag(self.itemCells[i])
        self.AwardList:EnableChildDrag(self.itemNums[i])
        self.shu[i] = winMgr:getWindow("lianyaoshengdian_main/awardlist/shu" .. tostring(i))
    end
    self.itemCells[12] = CEGUI.toItemCell(winMgr:getWindow("lianyaoshengdian_main/awardlist/shu12/award12"))
    self.itemCells[12]:subscribeEvent("TableClick", LianYaoBashDlg.HandleGetAward, self)
    local awarditem = BeanConfigManager.getInstance():GetTableByName("pet.clianyaopoints"):getRecorder(12)
    local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(awarditem.itemid)
    if item then
        self.itemCells[12]:SetImage(gGetIconManager():GetImageByID(item.icon))
        self.itemCells[12]:setID(awarditem.itemid)
        self.itemCells[12]:setID2(awarditem.id)
        self.BigAwardItemName:setText(item.name)
    end

    self.MinItemNum:subscribeEvent("Clicked", LianYaoBashDlg.HandleSubClick, self)
    self.AddItemNum:subscribeEvent("Clicked", LianYaoBashDlg.HandleAddClick, self)
    self.BaiChongBnt:subscribeEvent("Clicked", LianYaoBashDlg.HandleBaiChongBtn, self)
    self.closeBtn:subscribeEvent("Clicked", LianYaoBashDlg.HandleCloseBtn, self)
    self.TopUpBtn:subscribeEvent("Clicked", LianYaoBashDlg.HandleTopUpBtn, self)
    self.BuyBtn:subscribeEvent("Clicked", LianYaoBashDlg.HandleBuyBtn, self)
    self.BuyItemNum:subscribeEvent("MouseClick", LianYaoBashDlg.handleBuyNumClicked, self)
    self.currInfo = nil

    self.BuyItemNum:setText("1")
    local m_ownYunLingNum = CurrencyManager.getOwnCurrencyMount(3)
    self.HaveMoneyNum:setText(m_ownYunLingNum)
    CurrencyManager.registerTextWidget(3, self.HaveMoneyNum)
    self.shopItems = {}
    self.cells = {}
    self.limitmap = {}
    self:reqAwardItems()
    self:initData()
end

function LianYaoBashDlg:HandleSubClick(args)
    if self.currInfo == nil then
        return
    end
    local currNum = tonumber(self.BuyItemNum:getText())
    if currNum <= 1 then
        self.BuyItemNum:setText("1")
        return
    end
    currNum = currNum - 1

    self:onNumInputChanged(currNum)
end

function LianYaoBashDlg:HandleAddClick(args)
    if self.currInfo == nil then
        return
    end

    local currNum = tonumber(self.BuyItemNum:getText())
    local maxNum = self.currInfo.daylimited - self.limitmap[self.currInfo.id + 1000]
    if currNum >= maxNum then
        self.BuyItemNum:setText(tostring(maxNum))
        return
    end
    currNum = currNum + 1
    self:onNumInputChanged(currNum)
end

function LianYaoBashDlg:handleBuyNumClicked(args)
    if self.currInfo == nil then
        return
    end

    if NumKeyboardDlg.getInstanceNotCreate() then
        NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
        return
    end

    local dlg = NumKeyboardDlg.getInstanceAndShow()
    if dlg then
        dlg:setTriggerBtn(self.BuyItemNum)
        local maxvalue = self.currInfo.daylimited - self.limitmap[self.currInfo.id + 1000]
        dlg:setMaxValue(maxvalue)
        dlg:setInputChangeCallFunc(LianYaoBashDlg.onNumInputChanged, self)

        local p = self.BuyItemNum:GetScreenPos()
        SetPositionOffset(dlg:GetWindow(), p.x - 110, p.y - 10, 0, 1)
    end
end

function LianYaoBashDlg:onNumInputChanged(num)
    if self.currInfo == nil then
        return
    end
    local data = self.currInfo
    if num == 0 then
        self.BuyItemNum:setText(1)
        self.CurrBuyMoneyNum:setText(MoneyFormat(data.curprice))
        CurrencyManager.setCompareTextWidget(self.HaveMoneyNum, self.CurrBuyMoneyNum)
    else
        self.BuyItemNum:setText(num)
        self.CurrBuyMoneyNum:setText(MoneyFormat(data.curprice * num))
        CurrencyManager.setCompareTextWidget(self.HaveMoneyNum, self.CurrBuyMoneyNum)
    end
end

 
function LianYaoBashDlg:HandleGetAward(args)
    local e = CEGUI.toWindowEventArgs(args)
    local nItemId = e.window:getID()
    local awardId = e.window:getID2()
    local e2 = CEGUI.toMouseEventArgs(args)
    local touchPos = e2.position

    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if not itemAttrCfg then
        return
    end
    local nPosX = touchPos.x
    local nPosY = touchPos.y
    local commontipdlg = require "logic.tips.commontipdlg".getInstanceAndShow()
    local nType = Commontipdlg.eType.eNormal
    commontipdlg:RefreshItem(nType, nItemId, nPosX, nPosY)

    --领取奖励
    local award = BeanConfigManager.getInstance():GetTableByName("pet.clianyaopoints"):getRecorder(awardId)

    if gGetDataManager():getLianYaoScore() >= award.needpoints then
        local creqlianyaoaward = require "protodef.fire.pb.pet.creqlianyaoaward"
        local req = creqlianyaoaward.Create()
        req.awardid = awardId
        LuaProtocolManager.getInstance():send(req)
    end
end

function LianYaoBashDlg:reqAwardItems()
    local creqlianyaobuyitems = require "protodef.fire.pb.pet.creqlianyaobuyitems"
    local req = creqlianyaobuyitems.Create()
    LuaProtocolManager.getInstance():send(req)

    local creqlianyaoscore = require "protodef.fire.pb.pet.creqlianyaoscore"
    local req = creqlianyaoscore.Create()
    LuaProtocolManager.getInstance():send(req)
end

function LianYaoBashDlg:onReqLianYaoScore(score)
    self.currprovalue:setText(tostring(score))
    local pwidth = self.ProgressBox:getWidth().offset
    local ppos = self.ProgressBox:GetScreenPosOfCenter()
    local startx = ppos.x - pwidth / 2
    local t = BeanConfigManager.getInstance():GetTableByName("pet.Clianyaopoints")
    if score >= 5000 then
        local posprev = self.shu[11]:GetScreenPosOfCenter()
        local shustart = posprev.x - startx
        local limit = pwidth - shustart
        local confprev = t:getRecorder(11)
        local numnext = 6000 - confprev.needpoints
        local min = limit / numnext * (score - confprev.needpoints)
        self.ProgressBox:setProgress((shustart + min) / pwidth)
        return
    end

    for i = 1, 11 do
        local conf = t:getRecorder(i)
        local num = conf.needpoints
        local pos = self.shu[i]:GetScreenPosOfCenter()
        local shustart = pos.x - startx
        if score >= num then
            self.ProgressBox:setProgress(shustart / pwidth)
        else
            if i < 11 then
                local posnext = self.shu[i + 1]:GetScreenPosOfCenter()
                local shustart1 = posnext.x - startx
                local limit = shustart1 - shustart
                local confnext = t:getRecorder(i + 1)
                local numnext = confnext.needpoints - num
                local min = limit / numnext * (score - num)
                self.ProgressBox:setProgress((shustart + min) / pwidth)
                break
            elseif i == 11 then
                local posprev = self.shu[10]:GetScreenPosOfCenter()
                local shustart1 = posprev.x - startx
                local limit = shustart - shustart1
                local confprev = t:getRecorder(i - 1)
                local numnext = num - confprev.needpoints
                local min = limit / numnext * (score - num)
                self.ProgressBox:setProgress((shustart + min) / pwidth)
                break
            end
        end
    end
end

function LianYaoBashDlg:OnReqAwardItems(map)
    local t = BeanConfigManager.getInstance():GetTableByName("pet.clianyaopoints")
    for i = 1, 11 do
        local awarditem = t:getRecorder(i)
        local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(awarditem.itemid)
        if item then
            self.itemCells[i]:SetImage(gGetIconManager():GetImageByID(item.icon))
            self.itemCells[i]:setID(awarditem.itemid)
            self.itemCells[i]:setID2(awarditem.id)
            if gGetDataManager():getLianYaoScore() >= awarditem.needpoints then
                local s = self.itemCells[i]:getPixelSize()
                --AddParticalEffect 直接使用粒子效果，需要修改
                gGetGameUIManager():AddUIEffect(self.itemCells[i], "geffect/ui/baichongxianchi/lianyao_yuan", true,
                    s.width * 0.5, s.height * 0.5)
            end
        end
        self.itemNums[i]:setText(tostring(awarditem.num))
        if map[i] > 0 then
            self.itemCells[i]:SetAshy(true)
            --self.itemCells[i]:setEnabled(false)
            gGetGameUIManager():RemoveUIEffect(self.itemCells[i])
        end
    end
end

function LianYaoBashDlg:initData()
    local t = BeanConfigManager.getInstance():GetTableByName("pet.clianyaoshengdian")
    local ids = t:getAllID()
    for K, id in pairs(ids) do
        local conf = t:getRecorder(id)
        self.shopItems[K] = conf
    end
    if not self.m_tableview then
        local s = self.ItemList:getPixelSize()
        self.m_tableview = TableView.create(self.ItemList, TableView.VERTICAL)
        self.m_tableview:setViewSize(s.width - 10, s.height - 5)
        self.m_tableview:setPosition(5, 10)
        self.m_tableview:setColumCount(2)
        self.m_tableview:setDataSourceFunc(self, LianYaoBashDlg.tableViewGetCellAtIndex)
    end
    local count = TableUtil.tablelength(self.shopItems)
    self.m_tableview:setCellCountAndSize(count, 250, 190)
    self.m_tableview:setContentOffset(0)
    self.m_tableview:reloadData()
end

function LianYaoBashDlg.onSelected(info)
    _instance.currInfo = info
    _instance.CurrBuyMoneyNum:setText(MoneyFormat(info.curprice))
    _instance.BuyItemNum:setText(1)
end

function LianYaoBashDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    require "logic.lianyaoshengdian.lianyaoshopcell"
    if not cell then
        local info = self.shopItems[idx + 1]
        cell = LyShopItemCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
        cell:setInfo(info)
        cell:registerCallback(LianYaoBashDlg.onSelected)
        if idx == 0 then
            cell.Item:setSelected(true)
            LianYaoBashDlg.onSelected(info)
            self.currInfo = info
        end
        self.cells[info.id] = cell
    end
    return cell
end

function LianYaoBashDlg:updateDayLimit(map)
    self.limitmap = map
    for k, v in pairs(map) do
        self.cells[k - 1000]:setLimit(v)
    end
end

function LianYaoBashDlg:HandleBaiChongBtn(args)
    require("logic.baichongxianchi").getInstanceAndShow()
end

function LianYaoBashDlg:HandleCloseBtn(args)
    self:DestroyDialog()
end

function LianYaoBashDlg:HandleMinBtn(args)

end

function LianYaoBashDlg:HandleMaxBtn(args)

end

function LianYaoBashDlg:HandleTopUpBtn(args)
    ShopLabel.getInstance():showOnly(3)
end

function LianYaoBashDlg:HandleBuyBtn(args)
    if self.currInfo == nil then
        GetCTipsManager():AddMessageTip('请您先选择商品后在进行购买');
        return
    end
    local cbuylianyaoItem = require "protodef.fire.pb.pet.cbuylianyaoItem"
    local req = cbuylianyaoItem.Create()
    req.buynum = self.BuyItemNum:getText()
    req.itemid = self.currInfo.id
    LuaProtocolManager.getInstance():send(req)
end

return LianYaoBashDlg

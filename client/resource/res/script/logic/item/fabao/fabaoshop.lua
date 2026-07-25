require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

FaBaoShop = {}
setmetatable(FaBaoShop, Dialog)
FaBaoShop.__index = FaBaoShop
local _instance;

--//===============================
function FaBaoShop:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.sellItemScroll = CEGUI.toScrollablePane(winMgr:getWindow("fabaoshop/xuanze"))
    self.shopItemTable = CEGUI.toItemTable(winMgr:getWindow("fabaoshop/xuanze/table"))
    self.shopItemTable:subscribeEvent("TableClick", FaBaoShop.handleItemClicked, self)
    self.xinxi = CEGUI.toRichEditbox(winMgr:getWindow("fabaoshop/di11/jieshao"))
    self.xinxi:setReadOnly(true)
    self.jiage = winMgr:getWindow("fabaoshop/textzong")
    self.yongyou = winMgr:getWindow("fabaoshop/textdan")
	
    self.biaqian = winMgr:getWindow("fabaoshop/yong")
	
	
    self.lianhua = CEGUI.toPushButton(winMgr:getWindow("fabaoshop/bt11"))
    self.lianhua:subscribeEvent("MouseButtonUp", FaBaoShop.HandleLianHuaClick, self)

    self.selectedItemId = 0
    local p = require("logic.item.fabao.cfabaoshopsl"):new()
    LuaProtocolManager:send(p)
   -- self:refreshFaBaoShopList()
end
function FaBaoShop:HandleLianHuaClick(arg)
    if self.selectedItemId==0 then
        return
    end
    local p = require("logic.item.fabao.cfabaoshop"):new()
    p.shopid = self.selectedItemId
    LuaProtocolManager:send(p)
end
function FaBaoShop:refreshFaBaoShopList(fabaox)
    local fabaoshops = BeanConfigManager.getInstance():GetTableByName("item.cfabaoshop"):getAllID()
    --local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    --local roleItems = roleItemManager:GaoJiBagItem(true)

    local fabaoshopnum=#fabaoshops
    local foundLastSelected = false
    local column = self.shopItemTable:GetColCount()

    if fabaoshopnum > 0 then
        self.shopItemTable:setVisible(true)
        local row = math.ceil(fabaoshopnum / column)
        if self.shopItemTable:GetRowCount() ~= row then
            self.shopItemTable:SetRowCount(row)
            local h = self.shopItemTable:GetCellHeight()
            local spaceY = self.shopItemTable:GetSpaceY()
            self.shopItemTable:setHeight(CEGUI.UDim(0, (h+spaceY)*row))
            self.sellItemScroll:EnableAllChildDrag(self.sellItemScroll)
        end
        --self.biaqian:setVisible(false)
		--self.biaqian:setVisible(true)
        for i=0, row*column-1 do
            local cell = self.shopItemTable:GetCell(i)
            cell:Clear()
            cell:SetHaveSelectedState(true)
            if i < fabaoshopnum then
                cell:setVisible(true)
				
                local fabaoshop = BeanConfigManager.getInstance():GetTableByName("item.cfabaoshop"):getRecorder(i+1)
                --local item = roleItems[i]
                local img = gGetIconManager():GetImageByID(fabaoshop.icon)
                cell:SetImage(img)

                if fabaox[i+1]  then
                    --cell:SetCornerImage(nil)
					cell:SetCornerImage("teamdbui", "yongyou")
					
                else
                    cell:SetCornerImage("teamdbui", "meng2")
					--cell:setAlpha(0.5)
                end

                --refreshItemCellBind(cell, item:GetObject().loc.tableType, item:GetThisID())
                --SetItemCellBoundColorByQulityItem(cell, item:GetBaseObject().nquality)

                --local curNum = item:GetNum()
                --cell:SetTextUnit(curNum > 1 and curNum or "")

                cell:setID(fabaoshop.id) --baseid
                --cell:setID2(item:GetThisID())  --itemkey

                if self.selectedItemId == fabaoshop.id then
                    foundLastSelected = true
                    cell:SetSelected(true)
                end
            else
                cell:setVisible(false)
            end
        end
    else
        self.shopItemTable:setVisible(false)
    end

    if not foundLastSelected then

        self.selectedItemId = 0
        --self.numText:setText(0)
        --self.priceText:setText(0)
    end
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local itemid = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(520).value)
    local mymoney=roleItemManager:GetItemNumByBaseID(itemid)
    self.yongyou:setText(mymoney)
end
function FaBaoShop:handleItemClicked(args)
    local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
    if not cell then
        return
    end

    local itemid = cell:getID()
    self.selectedItemId = itemid

    self.xinxi:Clear()
    local fabaoshop = BeanConfigManager.getInstance():GetTableByName("item.cfabaoshop"):getRecorder(itemid)
    if not fabaoshop then
        return
    end
    self.xinxi:AppendText(CEGUI.String(fabaoshop.name),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF56361D")))
    self.xinxi:AppendBreak()
    self.xinxi:AppendText(CEGUI.String(" "))
    self.xinxi:AppendBreak()
    if fabaoshop.typeid==1 then
    --判断主动法宝显示主动法宝
        self.xinxi:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11720)),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF06CC11")))
        self.xinxi:AppendBreak()
        self.xinxi:AppendText(CEGUI.String(" "))
        self.xinxi:AppendBreak()
    end
    if fabaoshop.typeid==2 then
    --判断被动法宝显示被动法宝
        self.xinxi:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11721)),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF06CC11")))
        self.xinxi:AppendBreak()
        self.xinxi:AppendText(CEGUI.String(" "))
        self.xinxi:AppendBreak()
    end

    self.xinxi:AppendText(CEGUI.String(fabaoshop.jieshao),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF56361D")))
    self.xinxi:Refresh()
	
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local itemid = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(520).value)
    local mymoney=roleItemManager:GetItemNumByBaseID(itemid)	
	
	if fabaoshop.money <= mymoney then
    self.jiage:setText(fabaoshop.money)
	self.jiage:setProperty("TextColours", "FFEDE0CF")
	else
    self.jiage:setText(fabaoshop.money)
	self.jiage:setProperty("TextColours", "FFFF0000")
end

end

function FaBaoShop.getInstance()
    if not _instance then
        _instance = FaBaoShop:new()
        _instance:OnCreate()
    end
    return _instance
end

function FaBaoShop.getInstanceAndShow()
    if not _instance then
        _instance = FaBaoShop:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function FaBaoShop.getInstanceNotCreate()
    return _instance
end

function FaBaoShop.getInstanceOrNot()
    return _instance
end

function FaBaoShop.GetLayoutFileName()
    return "fabaoshop.layout"
end

function FaBaoShop:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FaBaoShop)
    self:ClearData()
    return self
end

function FaBaoShop.DestroyDialog()
    if not _instance then
        return
    end
    if not _instance.m_bCloseIsHide then
        _instance:OnClose()
        _instance = nil
    else
        _instance:ToggleOpenClose()
    end
end
function FaBaoShop.ToggleOpenClose()
    if not _instance then
        _instance = FaBaoShop:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function FaBaoShop:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function FaBaoShop:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function FaBaoShop:ClearCellAll()
end

function FaBaoShop:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return FaBaoShop

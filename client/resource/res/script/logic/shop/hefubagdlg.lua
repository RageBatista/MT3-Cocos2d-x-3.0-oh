------------------------------------------------------------------
-- 合服摆摊临时背包
------------------------------------------------------------------
require "logic.dialog"
require "logic.shop.hefubagcell"
require "utils.class"


stHeFuGoods = class("stHeFuGoods")

function stHeFuGoods:init()
    self.key = 0
    self.itemid = 0
    self.itemtype = 0
    self.name = ""
    self.icon = 0
    self.num = 0
	self.maxnum = 0
    self.level = 0
end

------------------------------------------------------------------
HeFuBagDlg = {}
setmetatable(HeFuBagDlg, Dialog)
HeFuBagDlg.__index = HeFuBagDlg

local _instance
function HeFuBagDlg.getInstance()
	if not _instance then
		_instance = HeFuBagDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function HeFuBagDlg.getInstanceAndShow()
	if not _instance then
		_instance = HeFuBagDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function HeFuBagDlg.getInstanceNotCreate()
	return _instance
end

function HeFuBagDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function HeFuBagDlg.ToggleOpenClose()
	if not _instance then
		_instance = HeFuBagDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function HeFuBagDlg.GetLayoutFileName()
	return "hefubag.layout"
end

function HeFuBagDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, HeFuBagDlg)
	return self
end

function HeFuBagDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.listBg = winMgr:getWindow("hefubag/dikuang")
	self.okBtn = CEGUI.toPushButton(winMgr:getWindow("hefubag/querentiqu"))

	self.okBtn:subscribeEvent("Clicked", HeFuBagDlg.handleOkClicked, self)

    local s = self.listBg:getPixelSize()
    self.tableView = TableView.create(self.listBg)
	self.tableView:setViewSize(s.width-20, s.height-20)
	self.tableView:setPosition(10, 10)
	self.tableView:setColumCount(2)
	self.tableView:setDataSourceFunc(self, HeFuBagDlg.tableViewGetCellAtIndex)

    self.datas = {}

    --[[<test
    ShopManager.hefuGoodsList = {
        {itemid=900001, num=1, key=1, itemtype=2, level=0},
		{itemid=506012, num=1, key=1, itemtype=2, level=0},
        {itemid=320002, num=1, key=2, itemtype=1, level=0},
        {itemid=6050101,num=1, key=3, itemtype=3, level=70},
        {itemid=320104, num=1, key=4, itemtype=1, level=10},
        {itemid=320001, num=1, key=5, itemtype=1, level=15},
        {itemid=320003, num=1, key=6, itemtype=1, level=20}
	}
    -->]]

    for _,v in ipairs(ShopManager.hefuGoodsList) do
        local data = stHeFuGoods.new()
        data.key = v.key
        data.itemid = v.itemid
        data.itemtype = v.itemtype
        data.num = v.num
        data.level = v.level

        if v.itemtype == STALL_GOODS_T.PET then
            local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(v.itemid)
            if conf then
                data.name = "[colour=\'" .. conf.colour .. "\']" .. conf.name
                data.quality = conf.quality
                local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(conf.modelid)
                data.icon = shapeData.littleheadID
            end

        else
            local conf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.itemid)
            if conf then
                data.name = conf.name
                data.quality = conf.nquality
                data.icon = conf.icon
				data.maxnum = conf.maxNum

				local firstType = conf.itemtypeid % 16
				if firstType == eItemType_EQUIP then
					data.itemtype = STALL_GOODS_T.EQUIP
				end
            end
        end

        table.insert(self.datas, data)
    end
    self.tableView:setCellCount(#self.datas)
	self.tableView:reloadData()
    
end

function HeFuBagDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        cell = HeFuBagCell.CreateNewDlg(tableView.container)
    end

    cell.window:setID(idx+1)
    cell:setData(self.datas[idx+1], idx)
    return cell
end

function HeFuBagDlg:handleOkClicked(args)
	local p = require("protodef.fire.pb.shop.ctakebacktempmarketcontaineritem"):new()
	LuaProtocolManager:send(p)
	self.okBtn:setEnabled(false)
end

return HeFuBagDlg
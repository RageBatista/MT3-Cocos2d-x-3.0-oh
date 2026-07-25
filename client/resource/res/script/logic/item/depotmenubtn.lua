require "logic.dialog"
require "utils.commonutil"

local CELL_NUM_PER_PAGE = 25;  -- 仓库界面，每页显示多少格子
local BTN_NUM_PER_LINE = 3;  -- 仓库切换面板，每行显示多少按钮
local CELL_NUM_PER_BTN_LINE = CELL_NUM_PER_PAGE * BTN_NUM_PER_LINE;  -- 仓库切换面板，每行按钮代表多少格子
local BTN_WIDTH = 140;  -- 仓库切换面板，按钮的宽度
local BTN_HEIGHT = 55;  -- 仓库切换面板，按钮的高度
local MAX_BTN_SHOW_LINES = 7;

DepotMenuBtn = { }
setmetatable(DepotMenuBtn, Dialog)
DepotMenuBtn.__index = DepotMenuBtn

local _instance;

local mWaitingUnlock = nil;

function DepotMenuBtn:clearList()
	if not self.cells or #self.cells == 0 then return end

	for _, v in pairs(self.cells) do
		self.container:removeChildWindow(v)
	end
end

function DepotMenuBtn:HandleCellGrayClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()


	local data = gGetDataManager():GetMainCharacterData();
	local level = data:GetValue(1230);


	local openConfig = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(level)


	local levelArray = { 0, 40, 90 };




	self.DestroyDialog()
end

function DepotMenuBtn:HandleDefaultCancelEvent(args)

end

function DepotMenuBtn:HandleCellClicked(args)


	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	local depotDlg = require "logic.item.depot":getInstanceOrNot()


	local img = self.imgList[id]



	if depotDlg and(not img:isVisible()) then

		if DepotMenuBtn.getInstanceNotCreate() then
			DepotMenuBtn.DestroyDialog()
		end
		--depotDlg:SwitchToDepotPage(id)

        depotDlg:reqPageInfo(id)
		return
	end




	local okfunction = function(self)
		mWaitingUnlock = true;
		local nUserMoney = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_SilverCoin)
		require "protodef.fire.pb.item.cextpacksize";
		if nUserMoney < 500000 then
			
			local dlg = require "logic.item.depot":getInstance()
			dlg:RefreshDepotMianfeiBtn()
			local p = CExtPackSize.Create();
			p.packid = fire.pb.item.BagTypes.DEPOT
			CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, 500000 - nUserMoney, 500000, p)

		else
			local p = CExtPackSize.Create();
			p.packid = fire.pb.item.BagTypes.DEPOT
			LuaProtocolManager.getInstance():send(p)
		end



		gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
	end

	local formatstr = GameTable.message.GetCMessageTipTableInstance():getRecorder(150143).msg
	local sb = require "utils.stringbuilder":new()
	sb:Set("Parameter1", 500000)
	local msg = sb:GetString(formatstr)
	sb:delete()

	gGetMessageManager():AddConfirmBox(eConfirmNormal, msg, okfunction, self, MessageManager.HandleDefaultCancelEvent, MessageManager)



end

function DepotMenuBtn:CalBtnCounts()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.DEPOT)
	local openBtnNum = math.ceil(capacity / CELL_NUM_PER_PAGE);
	local btnLine = math.ceil(capacity / CELL_NUM_PER_BTN_LINE);

	if openBtnNum >= btnLine * BTN_NUM_PER_LINE then
		btnLine = btnLine + 1;
	end

	local MAX_BTN_LINE = self:CalMaxBtnLine();
	if btnLine > MAX_BTN_LINE then
		btnLine = MAX_BTN_LINE;
	end

	return openBtnNum, btnLine;
end


function DepotMenuBtn:RefreshBgSize()
	local _, openLine = self:CalBtnCounts();

	if openLine > MAX_BTN_SHOW_LINES then
		openLine = MAX_BTN_SHOW_LINES
	end

	local width = BTN_WIDTH;
	local height = BTN_HEIGHT;

	local spaceY = 14;

	local size = self.container:getSize()

	size.x.offset = width * BTN_NUM_PER_LINE + 40;
	size.y.offset =(height + spaceY) * openLine + 10;
	self.container:setSize(size);

	size.y.offset =(height + spaceY) * openLine + 20;
	self.m_bg:setSize(size)

	if mWaitingUnlock then
		mWaitingUnlock = nil;

		self.container:setVerticalScrollPosition(1);
	end
	
end

function DepotMenuBtn:RefreshLockStat()
	local winMgr = CEGUI.WindowManager:getSingleton()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.DEPOT);

	for index in pairs(self.cells) do
		local btn = self.cells[index]
		local img = self.imgList[index]

		if CELL_NUM_PER_PAGE * index > capacity then
			img:setVisible(true)
			btn:setText("")
		else
			img:setVisible(false)
		end

	end

end

function DepotMenuBtn:deployAccountList()
	local winMgr = CEGUI.WindowManager:getSingleton()
    
	local _, openLine = self:CalBtnCounts();

	self:clearList()
	self.cells = { }
	self.imgList = { }


	local width = BTN_WIDTH;
	local height = BTN_HEIGHT;

	local xO = 14
	local yO = 20

	local spaceY = 5

	for row = 1, openLine do
		for col = 1, BTN_NUM_PER_LINE do
			local btn = CEGUI.toPushButton(winMgr:createWindow("TaharezLook/common_cangku"))
			btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0,(col - 1) * width +(col - 1) * 5 + xO),
			CEGUI.UDim(0,(row - 1) * height + yO + spaceY *(row - 1))))

			btn:setSize(CEGUI.UVector2(CEGUI.UDim(0, width), CEGUI.UDim(0, height)))

			btn:setID(col + BTN_NUM_PER_LINE *(row - 1))
			btn:setVisible(true)
			btn:setProperty("Font", "simhei-12")
			btn:EnableClickAni(false)
			self.container:addChildWindow(btn)

			local img = winMgr:createWindow("TaharezLook/StaticImage")
			img:setProperty("Image", "set:ccui1 image:suo1")

			img:setMousePassThroughEnabled(true)
			img:setAlwaysOnTop(true)
			img:setSize(CEGUI.UVector2(CEGUI.UDim(0, 30), CEGUI.UDim(0, 36)))
			
			img:setPosition((CEGUI.UVector2(CEGUI.UDim(0,(width - 29) / 2), CEGUI.UDim(0,(height - 36) / 2))))
			img:setVisible(true)


			btn:subscribeEvent("Clicked", DepotMenuBtn.HandleCellClicked, self)




            local strDepotWord
            local index = col + BTN_NUM_PER_LINE *(row - 1)
			if index <= 2 then
				local strbuilder = StringBuilder:new()
				strbuilder:Set("parameter1", index)
				strDepotWord = strbuilder:GetString(MHSD_UTILS.get_resstring(11152))
                strbuilder:delete()
			else
				local strbuilder = StringBuilder:new()
				strbuilder:Set("parameter1", index -2)
				strDepotWord = strbuilder:GetString(MHSD_UTILS.get_resstring(11153))
                strbuilder:delete()
			end
            if RoleItemManager.getInstance():getDepotNamesByIndex(index) then
                strDepotWord = RoleItemManager.getInstance():getDepotNamesByIndex(index)
            end
            btn:setText(strDepotWord)


			btn:addChildWindow(img)
			img:setProperty("AlwaysOnTop", "True")



			table.insert(self.cells, btn)
			table.insert(self.imgList, img)
		end
	end



end


function DepotMenuBtn:OnCreate()

	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()

	self.container = CEGUI.toScrollablePane(winMgr:getWindow("DepotMenuBtn/container"))
	self.m_bg = winMgr:getWindow("DepotMenuBtn/back")

	self:deployAccountList()

	self:RefreshBgSize()
	self:RefreshLockStat()

	self.mbJustCreated = true;
end


function DepotMenuBtn.GetLayoutFileName()
	return "depotmenubtn.layout"
end

function DepotMenuBtn.ToggleOpenClose()
	if not _instance then
		_instance = DepotMenuBtn:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function DepotMenuBtn.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function DepotMenuBtn.getInstanceNotCreate()
	return _instance
end

function DepotMenuBtn.getInstanceAndShow()
	if not _instance then
		_instance = DepotMenuBtn:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end

	return _instance
end

function DepotMenuBtn.getInstance()
	if not _instance then
		_instance = DepotMenuBtn:new()
		_instance:OnCreate()
	end

	return _instance
end

function DepotMenuBtn:new()
	local self = { }
	self = Dialog:new()
	setmetatable(self, DepotMenuBtn)
	return self
end

function DepotMenuBtn:CalMaxBtnLine()

	local vipLevel = gGetDataManager():GetVipLevel()
	local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)

	local maxNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(110).value);

	maxNum = maxNum + record.dpotextracount

	local maxBtnLine = math.ceil(maxNum / CELL_NUM_PER_BTN_LINE);
	return maxBtnLine;
end



return DepotMenuBtn

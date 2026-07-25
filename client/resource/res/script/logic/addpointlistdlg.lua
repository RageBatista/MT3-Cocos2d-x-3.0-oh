require "logic.dialog"
require "utils.commonutil"

AddpointListDlg = {}
setmetatable(AddpointListDlg, Dialog)
AddpointListDlg.__index = AddpointListDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function AddpointListDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AddpointListDlg)
    return self
end

function AddpointListDlg.getInstance(parent)
    if not _instance then
        _instance = AddpointListDlg:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function AddpointListDlg.getInstanceAndShow(parent)
    if not _instance then
        _instance = AddpointListDlg:new()
        _instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function AddpointListDlg.getInstanceNotCreate()
    return _instance
end

function AddpointListDlg.DestroyDialog()
	if _instance then 
        CharacterPropertyAddPtrDlg.getInstance():SetSchemeArrowImg(false);	
		_instance:OnClose()		
		_instance = nil
	end
end

function AddpointListDlg.ToggleOpenClose(parent)
	if not _instance then 
		_instance = AddpointListDlg:new() 
		_instance:OnCreate(parent)
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function AddpointListDlg.GetLayoutFileName()
    return "addpointlistdlg.layout"
end

function AddpointListDlg:OnCreate(parent)

    Dialog.OnCreate(self, parent)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	--local m = CEGUI.toScrollablePane(winMgr:getWindow("AddpointListDlg/container"));
    self.container = CEGUI.toScrollablePane(winMgr:getWindow("AddpointListDlg/container"))
	
	--self:loadAccounts()
	--这里添加方案按钮
	self:deployAccountList()
	
end

function AddpointListDlg:loadAccounts()
	--[[
	self.accounts = {}
	local idx = 0
	while true do
		local user = GetServerIniInfo("AccountList", "user"..idx)
		if not user then break end
		local acc = {idx=idx, user=user}
		table.insert(self.accounts, acc)
		idx = idx+1
	end
	]]--
	
	-- 这里应该是按顺序存储
	--[[
	table.sort(self.accounts, function(v1, v2)
		if v1.idx < v2.idx then
			return true
		end
	end)
	]]--
end

function AddpointListDlg:deployAccountList()
	
	CharacterPropertyAddPtrDlg.getInstance():SetSchemeArrowImg(true);	
	self:clearList()
	self.cells = {}

	local winMgr = CEGUI.WindowManager:getSingleton()
	local s = self.container:getPixelSize()
	local cellh = 60
	
	-- 三个解决方案，
	--local 
	for i=1, 3 do
		--local acc = self.accounts[i]
		local wnd = CEGUI.toPushButton(winMgr:createWindow("TaharezLook/common_button60"))
		--local wnd = winMgr:createWindow("TaharezLook/common_equipbj");
		self.container:addChildWindow(wnd)
		wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, s.width), CEGUI.UDim(0, cellh)))
		wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,3),CEGUI.UDim(0,(i-1)*(cellh - 3))))

		wnd:setID(i)

		-- 这里需要刷新状态， 等级到了， 才能高亮， 否则将背景颜色换了
		local data = gGetDataManager():GetMainCharacterData();	
		local level = data:GetValue(1230);
		
		-- 获取按钮开启等级
		local openConfig = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(level)
		if openConfig.addpointschemenum >= i then
			wnd:setProperty("NormalImage", "set:common image:huang60")
			wnd:setProperty("PushedImage", "set:common image:huang60")
			wnd:subscribeEvent("Clicked", AddpointListDlg.HandleCellClicked, self)
		else	
		-- 如果等级未达到， 则置灰, 同时点击的回调函数也不一样		
			wnd:setProperty("NormalImage", "set:common image:hui60");
			wnd:setProperty("PushedImage", "set:common image:hui60")
			wnd:subscribeEvent("Clicked", AddpointListDlg.HandleCellGrayClicked , self)	
		end
		--common1_button_caidan_2ji         普通态、悬浮态、按下态
		--common1_button_caidan_2jizhihui   灰化态
		wnd:EnableClickAni(false)
		wnd:setProperty("Font", "simhei-16");
		wnd:setProperty("NormalTextColour", "ff6e4506");
		wnd:setProperty("ButtonBorderEnable", "False");
		wnd:setProperty("ButtonBorderColour", "ff015885");
		wnd:setProperty("ButtonDefaultBorderEnable", "False");
		wnd:setProperty("ButtonDefaultColourEnable", "False");

		
		local strbuilder = StringBuilder:new()
		strbuilder:Set("parameter1", i)
		local  str = MHSD_UTILS.get_resstring(10020)
		wnd:setText("  "..strbuilder:GetString(MHSD_UTILS.get_resstring(10020)))
		strbuilder:delete()
		--wnd:setText(MHSD_UTILS.get_resstring(1557)..i)
		
		
		table.insert(self.cells, wnd)
		
	end
	
	
end

function AddpointListDlg:SetPositionSelf(pos)
    if self.container then
	    self.container:setPosition(pos)
    end
end

function AddpointListDlg:HandleCellClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()	
	CharacterPropertyAddPtrDlg.getInstance().m_schemeBtnStatus = false
	for index = 1, 3 do
		if  index == id then
			CharacterPropertyAddPtrDlg.getInstance():UpdateSelectSchemeID(index);
		end		
	end
	
	--SwitchAccountDialog.getInstance():InitAccountList()
	self.DestroyDialog()
end


function AddpointListDlg:HandleDefaultCancelEvent(args)
	gGetMessageManager():CloseCurrentShowMessageBox()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	return
end

function AddpointListDlg:HandleCellGrayClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()	
	
	-- 这里需要刷新状态， 等级到了， 才能高亮， 否则将背景颜色换了
	local data = gGetDataManager():GetMainCharacterData();	
	local level = data:GetValue(1230);
		
	-- 获取按钮开启等级
	local openConfig = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(level)
	--openConfig.addpointschemenum 
	
	local levelArray = {0 , 40, 90};
	
	local strbuilder = StringBuilder:new()
	strbuilder:Set("parameter1", levelArray[id])
	strbuilder:Set("parameter2", id)
	
	--gGetMessageManager():AddConfirmBox(eConfirmOK,strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150014)),
	--MessageManager.HandleDefaultCancelEvent,MessageManager,
	--MessageManager.HandleDefaultCancelEvent,MessageManager)
	
	--local sb = StringBuilder:new()
	--sb:SetNum("parameter1", 1)
	local tipMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150014))
    strbuilder:delete()
	GetCTipsManager():AddMessageTip(tipMsg);
	
	 --GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(144877).msg)

	--[[
	gGetMessageManager():AddMessageBox("",MHSD_UTILS.get_msgtipstring(145202),AddpointListDlg.HandleDefaultCancelEvent,
		self,AddpointListDlg.HandleDefaultCancelEvent,self,eConfirmOK,
		20000,0,0,nil,MHSD_UTILS.get_resstring(1556),MHSD_UTILS.get_resstring(1557));
	]]--
	
	--[[
	for index = 1, 3 do
		if  index == id then
			CharacterPropertyAddPtrDlg.getInstance():UpdateSelectSchemeID(index);
		end		
	end
	]]--
	--SwitchAccountDialog.getInstance():InitAccountList()
	self.DestroyDialog()
end



function AddpointListDlg:HandleDelCellBtnClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	
	--RemoveServerSection("AccountList")
	--self:saveAccount()
	self:deployAccountList()
end

function AddpointListDlg:saveAccount()
	local idx = 0
	for _,v in pairs(self.accounts) do
		SetServerIniInfo("AccountList", "user"..idx, v.user)
		RemoveServerIniInfo("AccountList", "password"..idx)
		idx = idx+1
	end
end

function AddpointListDlg:clearList()
	if not self.cells or #self.cells == 0 then return end
	
	for _,v in pairs(self.cells) do
		self.container:removeChildWindow(v)
	end
end

return AddpointListDlg

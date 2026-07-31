require "logic.dialog"
require "utils.commonutil"

AccountListDlg = {}
setmetatable(AccountListDlg, Dialog)
AccountListDlg.__index = AccountListDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function AccountListDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AccountListDlg)
    return self
end

function AccountListDlg.getInstance(parent)
    if not _instance then
        _instance = AccountListDlg:new()
        _instance:OnCreate(parent)
    end

    return _instance
end

function AccountListDlg.getInstanceAndShow(parent)
    if not _instance then
        _instance = AccountListDlg:new()
        _instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function AccountListDlg.getInstanceNotCreate()
    return _instance
end

function AccountListDlg.DestroyDialog()
	if _instance then
		if _instance.pwdBg then
			_instance.pwdBg:setVisible(true)
		end
		_instance:OnClose()
		_instance = nil
	end
end

function AccountListDlg.toggleShowHide(parent)
	if not _instance then
		return AccountListDlg.getInstance(parent)
	end
	AccountListDlg.DestroyDialog()
	return nil
end

function AccountListDlg:setTriggerBtn(btn)
	self.triggerBtn = btn
end

----/////////////////////////////////////////------

function AccountListDlg.GetLayoutFileName()
    return "accountlistdlg.layout"
end

function AccountListDlg:OnCreate(parent)

    Dialog.OnCreate(self, parent)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.container = CEGUI.toScrollablePane(winMgr:getWindow("AccountListDlg/container"))

	self:loadAccounts()
	if #self.accounts == 0 then
		AccountListDlg.DestroyDialog()
		return
	end
	self:deployAccountList()

	self.pwdBg = winMgr:getWindow("switchaccount/pwdbg")
	self.pwdBg:setVisible(false)

end

function AccountListDlg:loadAccounts()
	self.accounts = {}
	local idx = 0
	while true do
		local user = GetServerIniInfo("AccountList", "user"..idx)
		if not user then break end
		local acc = {idx=idx, user=user, pwd=GetServerIniInfo("AccountList", "password"..idx) or ""}
		table.insert(self.accounts, acc)
		idx = idx+1
	end

	table.sort(self.accounts, function(v1, v2)
		if v1.idx < v2.idx then
			return true
		end
	end)
end

function AccountListDlg:deployAccountList()
	self:clearList()
	self.cells = {}

	local winMgr = CEGUI.WindowManager:getSingleton()
	local cellw = 305
	local cellh = 51

	for i=1,#self.accounts do
		local acc = self.accounts[i]

		local bg = winMgr:createWindow("DefaultWindow")
		bg:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellw+60), CEGUI.UDim(0, cellh)))
		bg:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,(i-1)*(cellh+1))))
		bg:setAlwaysOnTop(true)
		self.container:addChildWindow(bg)

		local wnd = winMgr:createWindow("TaharezLook/common_tittle")
		wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellw), CEGUI.UDim(0, cellh)))
		--wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,(i-1)*cellh)))
		wnd:setID(acc.idx)
		wnd:setAlwaysOnTop(true)
		wnd:subscribeEvent("MouseClick", AccountListDlg.HandleCellClicked, self)
		bg:addChildWindow(wnd)

		local t = winMgr:createWindow("TaharezLook/StaticText")
		t:setSize(CEGUI.UVector2(CEGUI.UDim(0, cellw), CEGUI.UDim(0, cellh)))
		t:setProperty("BackgroundEnabled", "False")
		t:setProperty("FrameEnabled", "False")
		t:setProperty("HorzFormatting", "HorzCentred")
		t:setProperty("VertFormatting", "VertCentred")
		t:setProperty("MousePassThroughEnabled", "True")
		t:setProperty("AlwaysOnTop", "True")
		t:setProperty("TextColours", "FFFFFFFF")
		t:setProperty("Font", "simhei-16")
		t:setText(acc.user)
		wnd:addChildWindow(t)

		local delBtn = winMgr:createWindow("TaharezLook/ImageButton")
		delBtn:setSize(CEGUI.UVector2(CEGUI.UDim(0,51), CEGUI.UDim(0,51)))
		delBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0,cellw+5), CEGUI.UDim(0,0)))
		delBtn:setProperty("NormalImage", "set:login_2 image:login_2_colse")
		delBtn:setProperty("PushedImage", "set:login_2 image:login_2_colse")
		delBtn:setID(acc.idx)
		delBtn:subscribeEvent("Clicked", AccountListDlg.HandleDelCellBtnClicked, self)
		bg:addChildWindow(delBtn)

		table.insert(self.cells, bg)
	end

	self.container:EnableAllChildDrag(self.container)
end

function AccountListDlg:HandleCellClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	for k,v in pairs(self.accounts) do
		if v.idx == id then
			gGetLoginManager():SetAccountInfo(v.user)
			break
		end
	end

	SwitchAccountDialog.getInstance():InitAccountList()
	self.DestroyDialog()
end

function AccountListDlg:HandleDelCellBtnClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	for k,v in pairs(self.accounts) do
		if v.idx == id then
			table.remove(self.accounts, k)
			break
		end
	end
	RemoveServerSection("AccountList")
	self:saveAccount()
	self:deployAccountList()
	if #self.accounts == 0 then
		AccountListDlg.DestroyDialog()
	end
end

function AccountListDlg:saveAccount()
	local idx = 0
	for _,v in pairs(self.accounts) do
		SetServerIniInfo("AccountList", "user"..idx, v.user)
		SetServerIniInfo("AccountList", "password"..idx, v.pwd or "")
		idx = idx+1
	end
end

function AccountListDlg:clearList()
	if not self.cells or #self.cells == 0 then return end

	for _,v in pairs(self.cells) do
		self.container:removeChildWindow(v)
	end
end

return AccountListDlg

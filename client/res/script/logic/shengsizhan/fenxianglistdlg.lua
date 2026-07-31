require "logic.dialog"
require "utils.commonutil"

FenxiangListDlg = {}
setmetatable(FenxiangListDlg, Dialog)
FenxiangListDlg.__index = FenxiangListDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function FenxiangListDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FenxiangListDlg)
    return self
end

function FenxiangListDlg.getInstance(parent,callback)
    if not _instance then
        _instance = FenxiangListDlg:new()
        _instance:OnCreate(parent,callback)
    end
    
    return _instance
end

function FenxiangListDlg.getInstanceAndShow(parent)
    if not _instance then
        _instance = FenxiangListDlg:new()
        _instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FenxiangListDlg.getInstanceNotCreate()
    return _instance
end

function FenxiangListDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function FenxiangListDlg.ToggleOpenClose(parent)
	if not _instance then 
		_instance = FenxiangListDlg:new() 
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

function FenxiangListDlg.GetLayoutFileName()
    return "addpointlistdlg.layout"
end

function FenxiangListDlg:OnCreate(parent,callback)

    Dialog.OnCreate(self, parent)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	--local m = CEGUI.toScrollablePane(winMgr:getWindow("FenxiangListDlg/container"));
    self.container = CEGUI.toScrollablePane(winMgr:getWindow("AddpointListDlg/container"))
	self.callback = callback
	--self:loadAccounts()
	--这里添加方案按钮
	self:deployAccountList()
	self.dindex=0
    
    local back = winMgr:getWindow("AddpointListDlg/back")
    back:setSize(CEGUI.UVector2(CEGUI.UDim(0,175), CEGUI.UDim(0,115)))
end
function FenxiangListDlg:setDIndex(index)
    self.dindex=index
end
function FenxiangListDlg:loadAccounts()
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

function FenxiangListDlg:deployAccountList()
	
	self:clearList()
	self.cells = {}

	local winMgr = CEGUI.WindowManager:getSingleton()
	local s = self.container:getPixelSize()
	local cellh = 50
	
	-- 三个解决方案，
	--local 
	for i=1, 2 do
		--local acc = self.accounts[i]
		local wnd = CEGUI.toPushButton(winMgr:createWindow("TaharezLook/common_ty"))
		--local wnd = winMgr:createWindow("TaharezLook/common_ty");
		self.container:addChildWindow(wnd)
		wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, 167), CEGUI.UDim(0, cellh)))
		wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,(i-1)*(cellh))))

        if i == 1 then	wnd:setID(4)
        elseif i == 2 then	wnd:setID(5)
        end
		--wnd:setProperty("NormalImage", "set:common image:huang60")
		--wnd:setProperty("PushedImage", "set:common image:huang60")
		wnd:subscribeEvent("Clicked", self.callback, self)
		--common1_button_caidan_2ji         普通态、悬浮态、按下态
		--common1_button_caidan_2jizhihui   灰化态
		--wnd:EnableClickAni(false)
		wnd:setProperty("Font", "simhei-16");
		--wnd:setProperty("NormalTextColour", "ff6e4506");
		--wnd:setProperty("ButtonBorderEnable", "False");
		--wnd:setProperty("ButtonBorderColour", "ff015885");
		--wnd:setProperty("ButtonDefaultBorderEnable", "False");
		--wnd:setProperty("ButtonDefaultColourEnable", "False");
        		
		wnd:setText(MHSD_UTILS.get_resstring(11458+i))
		
		table.insert(self.cells, wnd)		
	end	
end

function FenxiangListDlg:clearList()
	if not self.cells or #self.cells == 0 then return end
	
	for _,v in pairs(self.cells) do
		self.container:removeChildWindow(v)
	end
end

return FenxiangListDlg

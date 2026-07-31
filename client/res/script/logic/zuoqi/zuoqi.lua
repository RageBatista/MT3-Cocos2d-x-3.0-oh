require "utils.mhsdutils"
require "logic.dialog"



ZuoQi = {}
setmetatable(ZuoQi, Dialog)
ZuoQi.__index = ZuoQi
local _instance;

function ZuoQi:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZuoQi)
    return self
end

function ZuoQi:clearList()
end

function ZuoQi:HandleCellClicked(args)
end
function ZuoQi:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.bg = winMgr:getWindow("zuoqi")
	--self.richBox =  CEGUI.toScrollablePane(winMgr:getWindow("zuoqi/zuoqi"))
	--self.petScroll:EnableAllChildDrag(self.petScroll)
	self.m_zuoqiList = {}
	self.petlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("zuoqi/zuoqi"));
	self.petlistWnd:EnableHorzScrollBar(false)
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("zuoqi/back"))
	self.m_btnguanbi:subscribeEvent("Clicked", ZuoQi.handleQuitBtnClicked, self)
	--self:refreshPetTable()
end
function ZuoQi:refreshZQTable(zuoqitable)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local sx = 2.0;
	local sy = 2.0;
	self.m_zuoqiList = {}
	local index = 0
	local rideItemId = RoleItemManager.getInstance():getRideItemId()
	for k,v in pairs(zuoqitable) do
		local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v);
		local sID = "zuoqi" .. tostring(v)
		local lyout = winMgr:loadWindowLayout("zuoqicell.layout",v);
		self.petlistWnd:addChildWindow(lyout)
		lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy + index * (lyout:getHeight().offset))))
		lyout:setID(v)
		lyout.key = item.id

		lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(v.."zuoqicell"));
		lyout.addclick:setID(v)
		lyout.addclick:subscribeEvent("MouseButtonUp", ZuoQi.handleZuoqiIconSelected, self)

		lyout.NameText = winMgr:getWindow(v.."zuoqicell/name")
		lyout.NameText:setText(item.name)

		lyout.zuoqiCell = CEGUI.toItemCell(winMgr:getWindow(v.."zuoqicell/touxiang"))
		local image = gGetIconManager():GetImageByID(item.icon)
		lyout.zuoqiCell:SetLockState(false)
		lyout.zuoqiCell:SetImage(image)
		lyout.zuoqiCell:ClearCornerImage(0)
		lyout.zuoqiCell:ClearCornerImage(1)

		lyout.chuzhan = winMgr:getWindow(v.."zuoqicell/zhan")
		lyout.chuzhan:setVisible(false)

		if rideItemId == v then
			lyout.chuzhan:setVisible(true)
		end
		table.insert(self.m_zuoqiList, lyout)
		index = index + 1
	end

end

function ZuoQi:handleZuoqiIconSelected(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)
	local idx = wnd:getID()
	local czuoqishiyong = require "logic.zuoqi.czuoqishiyong":new()
	czuoqishiyong.zuoqiid=idx
	require "manager.luaprotocolmanager":send(czuoqishiyong)
	--if idx < MainPetDataManager.getInstance():GetPetNum() then
	--	local petData = MainPetDataManager.getInstance():getPet(idx+1)
	--	if self.selectedPetKey ~= petData.key then
	--		self:refreshSelectedPet(petData)
	--	end
	--end
	self:DestroyDialog()
end
function ZuoQi:handleQuitBtnClicked(e)
	self:DestroyDialog()
end
--//========================================
function ZuoQi.getInstance()
    if not _instance then
        _instance = ZuoQi:new()
        _instance:OnCreate()
    end
    return _instance
end

function ZuoQi.getInstanceAndShow()
    if not _instance then
        _instance = ZuoQi:new()
        _instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
    end
    return _instance
end

function ZuoQi.getInstanceNotCreate()
    return _instance
end

function ZuoQi.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function ZuoQi.closeDialog()
	if not _instance then 
		return
	end
	_instance:OnClose()
	_instance = nil
end

function ZuoQi:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function ZuoQi.getInstanceOrNot()
	return _instance
end

function ZuoQi.GetLayoutFileName()
    return "zuoqi.layout"
end

return ZuoQi

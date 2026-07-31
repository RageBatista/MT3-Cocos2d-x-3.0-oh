------------------------------------------------------------------
-- °ÚÌ¯ËÑË÷
------------------------------------------------------------------
require "logic.dialog"
require "logic.shop.stallsearchattrcell"


local GROUPID_PAGE = 1
local GROUPID_HISTROY = 2


StallSearchDlg = {}
setmetatable(StallSearchDlg, Dialog)
StallSearchDlg.__index = StallSearchDlg

local _instance
function StallSearchDlg.getInstance()
	if not _instance then
		_instance = StallSearchDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallSearchDlg.getInstanceAndShow()
	if not _instance then
		_instance = StallSearchDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallSearchDlg.getInstanceNotCreate()
	return _instance
end

function StallSearchDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			StallSearchAttrCell.reset()
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallSearchDlg.ToggleOpenClose()
	if not _instance then
		_instance = StallSearchDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallSearchDlg.GetLayoutFileName()
	return "baitansousuo.layout"
end

function StallSearchDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallSearchDlg)
	return self
end

function StallSearchDlg:OnCreate()
	Dialog.OnCreate(self)
	SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.groupBtnNormal = CEGUI.toGroupButton(winMgr:getWindow("baitansousuo/sousuo1"))
	self.groupBtnEquip = CEGUI.toGroupButton(winMgr:getWindow("baitansousuo/sousuo2"))
	self.groupBtnPet = CEGUI.toGroupButton(winMgr:getWindow("baitansousuo/sousuo3"))
	
	self.pageEquip = winMgr:getWindow("baitansousuo/sou2")
	self.pagePet = winMgr:getWindow("baitansousuo/sou3")
	self.pageNormal = winMgr:getWindow("baitansousuo/sou1")
	
	self.groupBtnNormal:subscribeEvent("SelectStateChanged", StallSearchDlg.handleGroupBtnClicked, self)
	self.groupBtnEquip:subscribeEvent("SelectStateChanged", StallSearchDlg.handleGroupBtnClicked, self)
	self.groupBtnPet:subscribeEvent("SelectStateChanged", StallSearchDlg.handleGroupBtnClicked, self)

	self.groupBtnNormal:EnableClickAni(false)
	self.groupBtnEquip:EnableClickAni(false)
	self.groupBtnPet:EnableClickAni(false)

	self.equipSearch = require("logic.shop.stallsearchequip").new()
	self.normalSearch = nil
	self.petSearch = nil

	self.pageNormal:setVisible(false)
	self.pageEquip:setVisible(true)
	self.pagePet:setVisible(false)
	
	self.cc_btnClose = CEGUI.toPushButton(winMgr:getWindow("baitansousuo/close"))
    self.cc_btnClose:subscribeEvent("Clicked", StallSearchDlg.btnCloseCallBack, self)
	
end

function StallSearchDlg:handleGroupBtnClicked(args)
	local btn = CEGUI.toGroupButton(CEGUI.toWindowEventArgs(args).window)
	self.pageNormal:setVisible( btn == self.groupBtnNormal )
	self.pageEquip:setVisible( btn == self.groupBtnEquip )
	self.pagePet:setVisible( btn == self.groupBtnPet )

    self:GetWindow():setText(btn:getText())

	if btn == self.groupBtnEquip then
		if not self.equipSearch then
			self.equipSearch = require("logic.shop.stallsearchequip").new()
			self.equipSearch.parent = self
		end
	elseif btn == self.groupBtnPet then
		if not self.petSearch then
			self.petSearch = require("logic.shop.stallsearchpet").new()
			self.petSearch.parent = self
		end
	end
end

function StallSearchDlg:btnCloseCallBack(args)
    StallSearchDlg.DestroyDialog()
end

return StallSearchDlg
require "logic.dialog"

Spacenpcdialog = {}
setmetatable(Spacenpcdialog, Dialog)
Spacenpcdialog.__index = Spacenpcdialog


local _instance
function Spacenpcdialog.getInstance()
	if not _instance then
		_instance = Spacenpcdialog:new()
		_instance:OnCreate()
        _instance:registerEvent()
	end
	return _instance
end

function Spacenpcdialog.getInstanceAndShow()
	if not _instance then
		_instance = Spacenpcdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Spacenpcdialog.getInstanceNotCreate()
	return _instance
end

function Spacenpcdialog.DestroyDialog()
    if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spacenpcdialog:OnClose()
    if self.liuyanDlg then
        self.liuyanDlg:DestroyDialog()
    end

    self:removeEvent()
	Dialog.OnClose(self)
	_instance = nil
end

function Spacenpcdialog.ToggleOpenClose()
	if not _instance then
		_instance = Spacenpcdialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Spacenpcdialog.GetLayoutFileName()
	return "kongjiandashi.layout"
end

function Spacenpcdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacenpcdialog)
    self:clearData()
	return self
end

function Spacenpcdialog:clearData()

end

function Spacenpcdialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
end

function Spacenpcdialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
  
end


function Spacenpcdialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    SetPositionScreenCenter(self:GetWindow())

    --[[
    self.itemCellHead = CEGUI.toItemCell(winMgr:getWindow("kongjian_mtg/zuo/zhaopian"))
    self.imageHead = winMgr:getWindow("kongjian_mtg/zuo/moxingditu/static")
    self.imageHead:subscribeEvent("MouseClick", Spacenpcdialog.clickShowEditPic, self)

	self.btnHeadChange = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/zhaopian/btnqiehuan")) 
    self.btnHeadChange:subscribeEvent("MouseClick", Spacenpcdialog.clickModelShow, self)

    self.nodeModelBg = winMgr:getWindow("kongjian_mtg/zuo/moxingditu")   
	self.imageRoleModel = winMgr:getWindow("kongjian_mtg/zuo/moxing")

	self.btnModelChange = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/zhaopian/btnqiehuan1")) --qiehuan
	self.btnModelAdd = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/zhaopian/btntianjia")) --tianjia zhanpian
    self.btnModelChange:subscribeEvent("MouseClick", Spacenpcdialog.clickHeadShow, self)
    self.btnModelAdd:subscribeEvent("MouseClick", Spacenpcdialog.clickShowEditPic, self)

	self.imageJob = winMgr:getWindow("kongjian_mtg/zuo/textbg/zhiye")
	self.labelRoleName = winMgr:getWindow("kongjian_mtg/zuo/textbg/zhiye1")
	self.labelLevel = winMgr:getWindow("kongjian_mtg/zuo/level")
	self.labelFamilyJob = winMgr:getWindow("kongjian_mtg/zuo/bg2/text1")
	self.labelSignName = winMgr:getWindow("kongjian_mtg/zuo/qianmingban/shuoming")

    self.labelPlaceholder = winMgr:getWindow("kongjian_mtg/zuo/qianmingban/shuoming")


    self.signColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff50321a"))
    self.editboxSignName:SetColourRect(self.signColor)

	self.btnVoice = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/qianmingban/btnyuyin"))
    self.btnVoice:subscribeEvent("MouseClick", Spacenpcdialog.clickVoice, self)

	self.labelRoleId = winMgr:getWindow("kongjian_mtg/zuo/shuziid1")
	self.familyName = winMgr:getWindow("kongjian_mtg/zuo/gonghui1")
	self.btnWeizhi = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/btnweizhi"))
	self.labelWeizhi = winMgr:getWindow("kongjian_mtg/zuo/weizhi")

    self.btnLocation =  CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/btnweizhi")) 
    self.btnLocation:subscribeEvent("MouseClick", Spacenpcdialog.clickLocation, self)
    self.strOldLocationTitle = self.btnLocation:getText()
    self.btnLocation:setVisible(true)
    --]]

    self.bgRightNode = winMgr:getWindow("kongjiandashi_mtg/1")


    --F:\mt3\client\resource\res\script\logic\space\spaceliuyannpcdialog.lua
    self.liuyanDlg = require"logic.space.spaceliuyannpcdialog".create()

    self.bgRightNode:addChildWindow(self.liuyanDlg.m_pMainFrame)
    self.liuyanDlg.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
end




return Spacenpcdialog
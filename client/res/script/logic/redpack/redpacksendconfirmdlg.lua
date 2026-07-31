require "logic.dialog"

RedPackSendConfirmDlg = {}
setmetatable(RedPackSendConfirmDlg, Dialog)
RedPackSendConfirmDlg.__index = RedPackSendConfirmDlg

local _instance
function RedPackSendConfirmDlg.getInstance()
	if not _instance then
		_instance = RedPackSendConfirmDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function RedPackSendConfirmDlg.getInstanceAndShow()
	if not _instance then
		_instance = RedPackSendConfirmDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RedPackSendConfirmDlg.getInstanceNotCreate()
	return _instance
end

function RedPackSendConfirmDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RedPackSendConfirmDlg.ToggleOpenClose()
	if not _instance then
		_instance = RedPackSendConfirmDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RedPackSendConfirmDlg.GetLayoutFileName()
	return "hongbaofafang.layout"
end

function RedPackSendConfirmDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RedPackSendConfirmDlg)
	return self
end

function RedPackSendConfirmDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_money = winMgr:getWindow("hongbaofafang/shuliang/wenzi")
    self.m_num = winMgr:getWindow("hongbaofafang/shauliang2")
    self.m_dec = CEGUI.toRichEditbox(winMgr:getWindow("hongbaofafang/jiyutxt"))
    self.m_ok = CEGUI.toPushButton(winMgr:getWindow("hongbaofafang/anniu2"))
    self.m_cannel = CEGUI.toPushButton(winMgr:getWindow("hongbaofafang/anniu1"))
    self.m_ok:subscribeEvent("MouseClick", RedPackSendConfirmDlg.HandleSendClicked, self)
    self.m_cannel:subscribeEvent("MouseClick", RedPackSendConfirmDlg.HandleCannelClicked, self)
    self.m_img = winMgr:getWindow("hongbaofafang/tupian")
end
function RedPackSendConfirmDlg:HandleCannelClicked(e)
    self.DestroyDialog()
end
function RedPackSendConfirmDlg:HandleSendClicked(e)
    local p = require("protodef.fire.pb.fushi.redpack.csendredpack"):new()
    p.modeltype = self.m_index
    p.fushinum = self.m_Money
    p.redpacknum = self.m_Num
    p.redpackdes = self.m_dec:GetPureText()
    LuaProtocolManager:send(p)

    local dlg = require("logic.redpack.redpacksenddlg").getInstanceNotCreate()
    if dlg then
        dlg.DestroyDialog()
    end
    self.DestroyDialog()

end
function RedPackSendConfirmDlg:setData(index, money, num, text)
    self.m_index = index
    self.m_Money = money
    self.m_money:setText(money)
    self.m_num:setText(num)
    self.m_Num = num
    self.m_Talk = text
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            self.m_img:setProperty("Image", "set:common image:common_jinb")
        else
            self.m_img:setProperty("Image", "set:lifeskillui image:fushi")
        end
    end
    self.m_dec:Clear()
    local defaultColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF693F00"))
    self.m_dec:AppendText(CEGUI.String(text),defaultColor)
    self.m_dec:Refresh()    

end

return RedPackSendConfirmDlg
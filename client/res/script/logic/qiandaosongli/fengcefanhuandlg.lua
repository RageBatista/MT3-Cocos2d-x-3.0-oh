fengcehuanfandlg = {}
fengcehuanfandlg.__index = fengcehuanfandlg

local _instance
function fengcehuanfandlg.getInstance()
	if not _instance then
		_instance = fengcehuanfandlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function fengcehuanfandlg.getInstanceAndShow()
	if not _instance then
		_instance = fengcehuanfandlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function fengcehuanfandlg.getInstanceNotCreate()
	return _instance
end

function fengcehuanfandlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function fengcehuanfandlg.ToggleOpenClose()
	if not _instance then
		_instance = fengcehuanfandlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function fengcehuanfandlg.create()
    if not _instance then
		_instance = fengcehuanfandlg:new()
		_instance:OnCreate()
	end
	return _instance
end
function fengcehuanfandlg.GetLayoutFileName()
	return "fengcefanhuan.layout"
end

function fengcehuanfandlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, fengcehuanfandlg)
	return self
end
function fengcehuanfandlg:remove()
    _instance = nil
end
function fengcehuanfandlg:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()
    local layoutName = "fengcefanhuan.layout"
    self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)
    self.m_btnReturn = CEGUI.Window.toPushButton(winMgr:getWindow("fengcefanhuan/queren"))
    self.m_btnReturn:subscribeEvent("MouseClick",fengcehuanfandlg.HandleAnswerClicked,self)
    self.m_numOld = winMgr:getWindow("fengcefanhuan/jianglidiban/fushishuliang1")
    self.m_num = winMgr:getWindow("fengcefanhuan/jianglidiban/fushishuliang2")

    self.m_jianglibeijing = winMgr:getWindow("fengcefanhuan/jianglibeijing")

    self.m_jianglidiban = winMgr:getWindow("fengcefanhuan/jianglidiban")
    self.m_jianglidiban1 = winMgr:getWindow("fengcefanhuan/jianglidiban1")
    self.m_jieshutu = winMgr:getWindow("fengcefanhuan/jieshutu")
    self.m_jieshuban = winMgr:getWindow("fengcefanhuan/jieshuban")

    self.m_imgStartText1 = winMgr:getWindow("fengcefanhuan/jianglidiban/gonggao2")
    self.m_imgStartText2 = winMgr:getWindow("fengcefanhuan/jianglidiban/gonggao3")
    self.m_imgStartText3 = winMgr:getWindow("fengcefanhuan/jianglidiban1/")
    self.m_imgEnd1 = winMgr:getWindow("fengcefanhuan/jieshuban")
    self.m_imgEnd2 = winMgr:getWindow("fengcefanhuan/jieshuban/jieshuyu")

    require "logic.qiandaosongli.loginrewardmanager"
	local mgr = LoginRewardManager.getInstance()
    self.m_num:setText(MoneyFormat(mgr.m_TestReturnNum))
    self.m_numOld:setText(MoneyFormat(mgr.m_TestReturnNumOld))
end
function fengcehuanfandlg:End()
    self.m_btnReturn:setVisible(false)
    self.m_jianglibeijing:setVisible(false)

    self.m_jianglidiban:setVisible(false)
    self.m_jianglidiban1:setVisible(false)
    self.m_jieshutu:setVisible(true)
    self.m_jieshuban:setVisible(true)
    
    self.m_imgStartText1:setVisible(false)
    self.m_imgStartText2:setVisible(false)
    self.m_imgStartText3:setVisible(false)
    self.m_imgEnd1:setVisible(true)
    self.m_imgEnd2:setVisible(true)
end
function fengcehuanfandlg:HandleAnswerClicked(e)
    local cgetchargerefunds = require "protodef.fire.pb.fushi.cgetchargerefunds".Create()
    LuaProtocolManager.getInstance():send(cgetchargerefunds)
end

return fengcehuanfandlg
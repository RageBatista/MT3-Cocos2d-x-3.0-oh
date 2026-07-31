require "logic.dialog"

RanseBaoCunDlg = {}
setmetatable(RanseBaoCunDlg, Dialog)
RanseBaoCunDlg.__index = RanseBaoCunDlg

local _instance
function RanseBaoCunDlg.getInstance()
	if not _instance then
		_instance = RanseBaoCunDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function RanseBaoCunDlg.getInstanceAndShow()
	if not _instance then
		_instance = RanseBaoCunDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RanseBaoCunDlg.getInstanceNotCreate()
	return _instance
end

function RanseBaoCunDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RanseBaoCunDlg.ToggleOpenClose()
	if not _instance then
		_instance = RanseBaoCunDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RanseBaoCunDlg.GetLayoutFileName()
	return "ranse1baocun.layout"
end

function RanseBaoCunDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RanseBaoCunDlg)
	return self
end

function RanseBaoCunDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(RanseBaoCunDlg.OnMoneyChange)
	
    self.m_okBtn = CEGUI.toPushButton(winMgr:getWindow("ranse1baocun/yes"))
    self.m_cancelBtn = CEGUI.toPushButton(winMgr:getWindow("ranse1baocun/no"))
	self.m_okBtn:subscribeEvent("MouseButtonUp", RanseBaoCunDlg.handleRSOKClicked, self)
	self.m_cancelBtn:subscribeEvent("MouseButtonUp", RanseBaoCunDlg.handleRSCANCELClicked, self)
    
    self.m_need = winMgr:getWindow("ranse1baocun/huafeidi/huafeizhi")
    self.m_have = winMgr:getWindow("ranse1baocun/yongyoudi/yongyouzhi")
    self:refreshMoney()
end

function RanseBaoCunDlg:refreshMoney()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    local common = GameTable.common.GetCCommonTableInstance():getRecorder(227).value
    self.m_need:setText(common)
    local nUserMoney = roleItemManager:GetPackMoney()
    
    local tColor = ""
    if nUserMoney < tonumber(common) then
        tColor = "[colour=".."\'".."ffff0000".."\'".."]"
    end
    self.m_have:setText(tColor .. tostring(nUserMoney))
end

function RanseBaoCunDlg:OnClose()  
	Dialog.OnClose(self)
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
end

function RanseBaoCunDlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:refreshMoney()
end
function RanseBaoCunDlg:handleRSOKClicked(args)    
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    local nNeedMoney = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(227).value)
    local nUserMoney = roleItemManager:GetPackMoney()
    if nUserMoney >= nNeedMoney then
	    local p = require "protodef.fire.pb.creqsavecolor":new()
        require "manager.luaprotocolmanager".getInstance():send(p)
	    self.DestroyDialog()
    else
        local nMoneyType = fire.pb.game.MoneyType.MoneyType_SilverCoin
		local nShowNeed = nNeedMoney - nUserMoney
		LogInfo("nMoneyType="..nMoneyType)
		CurrencyManager.handleCurrencyNotEnough(nMoneyType, nShowNeed)
    end
end
function RanseBaoCunDlg:handleRSCANCELClicked(args)  
	self.DestroyDialog()
end

return RanseBaoCunDlg

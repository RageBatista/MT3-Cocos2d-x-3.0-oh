------------------------------------------------------------------
-- 宠物选择培养资质
------------------------------------------------------------------
require "logic.dialog"

PetChooseZiZhi = {}
setmetatable(PetChooseZiZhi, Dialog)
PetChooseZiZhi.__index = PetChooseZiZhi

local _instance
function PetChooseZiZhi.getInstance()
	if not _instance then
		_instance = PetChooseZiZhi:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetChooseZiZhi.getInstanceAndShow()
	if not _instance then
		_instance = PetChooseZiZhi:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetChooseZiZhi.getInstanceNotCreate()
	return _instance
end

function PetChooseZiZhi.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetChooseZiZhi.ToggleOpenClose()
	if not _instance then
		_instance = PetChooseZiZhi:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetChooseZiZhi.GetLayoutFileName()
	return "petchoosezizhi_mtg.layout"
end

function PetChooseZiZhi:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetChooseZiZhi)
	return self
end

function PetChooseZiZhi:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.6) 
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function PetChooseZiZhi:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("petchoosezizhi_mtg/window"))
	self.desText = winMgr:getWindow("petchoosezizhi_mtg/window/textqingxuanze")
	self.tiziBtn = CEGUI.toPushButton(winMgr:getWindow("petchoosezizhi_mtg/window/bg"))
	self.tizi = winMgr:getWindow("petchoosezizhi_mtg/window/bg/textjizhi")
	self.suziBtn = CEGUI.toPushButton(winMgr:getWindow("petchoosezizhi_mtg/window/bg1"))
	self.suzi = winMgr:getWindow("petchoosezizhi_mtg/window/bg1/textjizhi1")
	self.gongziBtn = CEGUI.toPushButton(winMgr:getWindow("petchoosezizhi_mtg/window/bg2"))
	self.gongzi = winMgr:getWindow("petchoosezizhi_mtg/window/bg2/textjizhi2")
	self.faziBtn = CEGUI.toPushButton(winMgr:getWindow("petchoosezizhi_mtg/window/bg3"))
	self.fazi = winMgr:getWindow("petchoosezizhi_mtg/window/bg3/textjizhi3")
	self.fangziBtn = CEGUI.toPushButton(winMgr:getWindow("petchoosezizhi_mtg/window/bg4"))
	self.fangzi = winMgr:getWindow("petchoosezizhi_mtg/window/bg4/textjizhi4")
	self.sureBtn = CEGUI.toPushButton(winMgr:getWindow("petchoosezizhi_mtg/window/btnqueren"))
	
	self.tiziBtn:setID(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
	self.suziBtn:setID(fire.pb.attr.AttrType.PET_SPEED_APT)
	self.gongziBtn:setID(fire.pb.attr.AttrType.PET_ATTACK_APT)
	self.faziBtn:setID(fire.pb.attr.AttrType.PET_MAGIC_APT)
	self.fangziBtn:setID(fire.pb.attr.AttrType.PET_DEFEND_APT)

	self.tiziBtn:subscribeEvent("Clicked", PetChooseZiZhi.handleZiZhiChoosed, self)
	self.suziBtn:subscribeEvent("Clicked", PetChooseZiZhi.handleZiZhiChoosed, self)
	self.gongziBtn:subscribeEvent("Clicked", PetChooseZiZhi.handleZiZhiChoosed, self)
	self.faziBtn:subscribeEvent("Clicked", PetChooseZiZhi.handleZiZhiChoosed, self)
	self.fangziBtn:subscribeEvent("Clicked", PetChooseZiZhi.handleZiZhiChoosed, self)
	self.sureBtn:subscribeEvent("Clicked", PetChooseZiZhi.handleSureClicked, self)
	self:addButtonAnimation(self.sureBtn, "stucdyBtnPress")
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", PetChooseZiZhi.DestroyDialog, nil)

end

function PetChooseZiZhi:calcuZizhiDelta(curVal, maxVal)
	local low = math.floor((maxVal-curVal)*0.04+0.5)
	local up = math.floor((maxVal-curVal)*0.06+0.5)
	local low = math.min(math.max(low, 1), maxVal)
	local up = math.min(math.max(up, 1), maxVal)
	if low == up then
		return "+" .. up
	end
	return "+" .. low .. "~" .. up
end

function PetChooseZiZhi:setData(petData, itemConf)
	if not petData then
		return
	end
	self.petData = petData
	self.itemConf = itemConf
	self:refreshData()
end
	
function PetChooseZiZhi:refreshData()
	
	if not self.petData then
		return
	end
	
	local str = self.desText:getText()
	str = string.gsub(str, "xxxx", self.petData.name)
	self.desText:setText(str)
	
	local c = "[colour='ff553923']"
	local c1= "[colour='FF15B211']"
	
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.petData.baseid)
    if not conf then
        return
    end
	
	local curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
	local t = ""
	if curVal >= conf.attackaptmax then
		t = "+0" --MHSD_UTILS.get_resstring(11125)
		self.gongziBtn:setID2(0)
	else
		t = self:calcuZizhiDelta(curVal, conf.attackaptmax)
		self.gongziBtn:setID2(1)
	end
	self.gongzi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
	
	
	curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
	if curVal >= conf.defendaptmax then
		t = "+0" --MHSD_UTILS.get_resstring(11125)
		self.fangziBtn:setID2(0)
	else
		t = self:calcuZizhiDelta(curVal, conf.defendaptmax)
		self.fangziBtn:setID2(1)
	end
	self.fangzi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
	
	
	curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
	if curVal >= conf.phyforceaptmax then
		t = "+0" --MHSD_UTILS.get_resstring(11125)
		self.tiziBtn:setID2(0)
	else
		t = self:calcuZizhiDelta(curVal, conf.phyforceaptmax)
		self.tiziBtn:setID2(1)
	end
	self.tizi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
	
	
	curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
	if curVal >= conf.magicaptmax then
		t = "+0" --MHSD_UTILS.get_resstring(11125)
		self.faziBtn:setID2(0)
	else
		t = self:calcuZizhiDelta(curVal, conf.magicaptmax)
		self.faziBtn:setID2(1)
	end
	self.fazi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
	
	
	curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
	if curVal >= conf.speedaptmax then
		t = "+0" --MHSD_UTILS.get_resstring(11125)
		self.suziBtn:setID2(0)
	else
		t = self:calcuZizhiDelta(curVal, conf.speedaptmax)
		self.suziBtn:setID2(1)
	end
	self.suzi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
end

function PetChooseZiZhi:handleZiZhiChoosed(args)
	local btn = CEGUI.toWindowEventArgs(args).window
	btn:SetPushState(true)
	if self.lastSelectedBtn == btn then
		return
	end
	
	if self.lastSelectedBtn then
		self.lastSelectedBtn:SetPushState(false)
	end
	self.lastSelectedBtn = btn
end

function PetChooseZiZhi:getZiZhiStr(zizhiType)
	local strid = (zizhiType == fire.pb.attr.AttrType.PET_PHYFORCE_APT and 11126 or
		(zizhiType == fire.pb.attr.AttrType.PET_SPEED_APT and 11127 or
		(zizhiType == fire.pb.attr.AttrType.PET_ATTACK_APT and 11128 or
		(zizhiType == fire.pb.attr.AttrType.PET_MAGIC_APT and 11129 or
		(zizhiType == fire.pb.attr.AttrType.PET_DEFEND_APT and 11130 or 0)))))
	return MHSD_UTILS.get_resstring(strid)
end

function PetChooseZiZhi:handleSureClicked(args)
	if self.lastSelectedBtn then
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local itemkey = roleItemManager:GetItemKeyByBaseID(self.itemConf.id)
		if itemkey == 0 then
			ShopManager:tryQuickBuy(self.itemConf.id)
			return
		end
		
		local common = GameTable.common.GetCCommonTableInstance():getRecorder(120) --资质提升丹次数
		if tonumber(common.value) <= self.petData.aptaddcount then
			local str = MHSD_UTILS.get_msgtipstring(150071) --xxx宠物已经不能食用资质丹了
			str = string.gsub(str, "%$parameter1%$", self.petData.name)
			GetCTipsManager():AddMessageTip(str)
			return
		end
		
		local zizhiType = self.lastSelectedBtn:getID()
		local isfull = (self.lastSelectedBtn:getID2()==0 and true or false)
		if not isfull then
			local p = require("protodef.fire.pb.pet.cpetaptitudecultivate"):new()
			p.petkey = self.petData.key
			p.aptid = zizhiType
			p.itemkey = itemkey
			LuaProtocolManager:send(p)
			
		else
			local sb = StringBuilder:new()
			sb:Set("parameter1", self.petData.name)
			sb:Set("parameter2", self:getZiZhiStr(zizhiType))
			sb:Set("parameter3", self.itemConf.name)
			GetCTipsManager():AddMessageTip(sb:GetString(MHSD_UTILS.get_msgtipstring(150069))) --xxx宠物xx资质已满，无法使用xx
            sb:delete()
			return
		end
	else
		GetCTipsManager():AddMessageTipById(150083) --请先选择要提升得资质
	end
end

return PetChooseZiZhi

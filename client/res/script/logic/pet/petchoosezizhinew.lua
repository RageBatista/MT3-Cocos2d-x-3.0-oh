------------------------------------------------------------------
-- ����ѡ����������
------------------------------------------------------------------
require "logic.dialog"

PetChooseZiZhiNew = {}
setmetatable(PetChooseZiZhiNew, Dialog)
PetChooseZiZhiNew.__index = PetChooseZiZhiNew

local _instance
function PetChooseZiZhiNew.getInstance()
	if not _instance then
		_instance = PetChooseZiZhiNew:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetChooseZiZhiNew.getInstanceAndShow()
	if not _instance then
		_instance = PetChooseZiZhiNew:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetChooseZiZhiNew.getInstanceNotCreate()
	return _instance
end

function PetChooseZiZhiNew.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetChooseZiZhiNew.ToggleOpenClose()
	if not _instance then
		_instance = PetChooseZiZhiNew:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetChooseZiZhiNew.GetLayoutFileName()
	return "petchoosezizhi_mtg.layout"
end

function PetChooseZiZhiNew:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetChooseZiZhiNew)
	return self
end

function PetChooseZiZhiNew:OnCreate()
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

	self.tiziBtn:subscribeEvent("Clicked", PetChooseZiZhiNew.handleZiZhiChoosed, self)
	self.suziBtn:subscribeEvent("Clicked", PetChooseZiZhiNew.handleZiZhiChoosed, self)
	self.gongziBtn:subscribeEvent("Clicked", PetChooseZiZhiNew.handleZiZhiChoosed, self)
	self.faziBtn:subscribeEvent("Clicked", PetChooseZiZhiNew.handleZiZhiChoosed, self)
	self.fangziBtn:subscribeEvent("Clicked", PetChooseZiZhiNew.handleZiZhiChoosed, self)
	self.sureBtn:subscribeEvent("Clicked", PetChooseZiZhiNew.handleSureClicked, self)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", PetChooseZiZhiNew.DestroyDialog, nil)

end

function PetChooseZiZhiNew:calcuZizhiDelta(curVal, maxVal)
	local low = math.floor((maxVal-curVal)*0.04+0.5)
	local up = math.floor((maxVal-curVal)*0.06+0.5)
	local low = math.min(math.max(low, 1), maxVal)
	local up = math.min(math.max(up, 1), maxVal)
	if low == up then
		return "+" .. 100
	end
	return "+" .. 100
end

function PetChooseZiZhiNew:calcutiliZizhiDelta(curVal, maxVal)
	local low = math.floor((maxVal-curVal)*0.04+0.5)
	local up = math.floor((maxVal-curVal)*0.06+0.5)
	local low = math.min(math.max(low, 1), maxVal)
	local up = math.min(math.max(up, 1), maxVal)
	if low == up then
		return "+" .. 500
	end
	return "+" .. 500
end

function PetChooseZiZhiNew:setData(petData, itemConf)
	if not petData then
		return
	end
	self.petData = petData
	self.itemConf = itemConf
	self:refreshData()
end
	
function PetChooseZiZhiNew:refreshData()
	
	if not self.petData then
		return
	end
	
	local str = self.desText:getText()
	str = string.gsub(str, "xxxx", self.petData.name)
	self.desText:setText(str)
	
	local c = "[colour='FF78491F']"
	local c1= "[colour='FF15B211']"
	
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.petData.baseid)
    if not conf then
        return
    end
	
	local curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
	local t = ""
	if curVal >= conf.attackaptmax then
		t = "+100" --MHSD_UTILS.get_resstring(11125)
		self.gongziBtn:setID2(100)
	else
		t = self:calcuZizhiDelta(curVal, conf.attackaptmax)
		self.gongziBtn:setID2(1)
	end
	self.gongzi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
	
	
	curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
	if curVal >= conf.defendaptmax then
		t = "+100" --MHSD_UTILS.get_resstring(11125)
		self.fangziBtn:setID2(100)
	else
		t = self:calcuZizhiDelta(curVal, conf.defendaptmax)
		self.fangziBtn:setID2(1)
	end
	self.fangzi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
	
	
	curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
	if curVal >= conf.phyforceaptmax then
		t = "+500" --MHSD_UTILS.get_resstring(11125)
		self.tiziBtn:setID2(500)
	else
		t = self:calcutiliZizhiDelta(curVal, conf.phyforceaptmax)
		self.tiziBtn:setID2(1)
	end
	self.tizi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
	
	
	curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
	if curVal >= conf.magicaptmax then
		t = "+100" --MHSD_UTILS.get_resstring(11125)
		self.faziBtn:setID2(100)
	else
		t = self:calcuZizhiDelta(curVal, conf.magicaptmax)
		self.faziBtn:setID2(1)
	end
	self.fazi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
	
	
	curVal = self.petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
	if curVal >= conf.speedaptmax then
		t = "+100" --MHSD_UTILS.get_resstring(11125)
		self.suziBtn:setID2(100)
	else
		t = self:calcuZizhiDelta(curVal, conf.speedaptmax)
		self.suziBtn:setID2(1)
	end
	self.suzi:setText(c .. curVal .. " (" .. c1 .. t .. c .. ")")
end

function PetChooseZiZhiNew:handleZiZhiChoosed(args)
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

function PetChooseZiZhiNew:getZiZhiStr(zizhiType)
	local strid = (zizhiType == fire.pb.attr.AttrType.PET_PHYFORCE_APT and 11126 or
		(zizhiType == fire.pb.attr.AttrType.PET_SPEED_APT and 11127 or
		(zizhiType == fire.pb.attr.AttrType.PET_ATTACK_APT and 11128 or
		(zizhiType == fire.pb.attr.AttrType.PET_MAGIC_APT and 11129 or
		(zizhiType == fire.pb.attr.AttrType.PET_DEFEND_APT and 11130 or 0)))))
	return MHSD_UTILS.get_resstring(strid)
end

function PetChooseZiZhiNew:handleSureClicked(args)
	if self.lastSelectedBtn then
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local itemkey = roleItemManager:GetItemKeyByBaseID(self.itemConf.id)
		if itemkey == 0 then
			ShopManager:tryQuickBuy(self.itemConf.id)
			return
		end
		
		local common = GameTable.common.GetCCommonTableInstance():getRecorder(120) --��������������
		if tonumber(common.value) <= self.petData.aptaddcount +10 then
			local str = MHSD_UTILS.get_msgtipstring(150071) --xxx�����Ѿ�����ʳ�����ʵ���
			str = string.gsub(str, "%$parameter1%$", self.petData.name)
			GetCTipsManager():AddMessageTip(str)
			return
		end
		
		local zizhiType = self.lastSelectedBtn:getID()
		local isfull = (self.lastSelectedBtn:getID2()==0 and true or false)
		if not isfull then
			local p = require("protodef.fire.pb.pet.cpetaptitudecultivatee"):new()
			p.petkey = self.petData.key
			p.aptid = zizhiType
			p.itemkey = itemkey
			print("789*************提交宠物")
			LuaProtocolManager:send(p)
			
		else
			local sb = StringBuilder:new()
			sb:Set("parameter1", self.petData.name)
			sb:Set("parameter2", self:getZiZhiStr(zizhiType))
			sb:Set("parameter3", self.itemConf.name)
			GetCTipsManager():AddMessageTip(sb:GetString(MHSD_UTILS.get_msgtipstring(150069))) --xxx����xx�����������޷�ʹ��xx
            sb:delete()
			return
		end
	else
		GetCTipsManager():AddMessageTipById(150083) --����ѡ��Ҫ����������
	end
end

return PetChooseZiZhiNew

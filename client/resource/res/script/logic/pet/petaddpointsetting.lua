------------------------------------------------------------------
-- 宠物加点方案
------------------------------------------------------------------
require "logic.dialog"

PetAddPointSetting = {}
setmetatable(PetAddPointSetting, Dialog)
PetAddPointSetting.__index = PetAddPointSetting

local MAX_POINT = 5
local ATTR = {
	TIZHI = 1,	--体质
	MAGIC = 2,	--魔力
	POWER = 3,	--力量
	NAILI = 4,	--耐力
	MINJIE = 5	--敏捷
}

local _instance
function PetAddPointSetting.getInstance()
	if not _instance then
		_instance = PetAddPointSetting:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetAddPointSetting.getInstanceAndShow()
	if not _instance then
		_instance = PetAddPointSetting:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetAddPointSetting.getInstanceNotCreate()
	return _instance
end

function PetAddPointSetting.DestroyDialog()
	if _instance then
		_instance:requestSetting()
		if _instance.sprite then
			_instance.sprite:delete()
			_instance.sprite = nil
			_instance.icon:getGeometryBuffer():setRenderEffect(nil)
		end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetAddPointSetting.ToggleOpenClose()
	if not _instance then
		_instance = PetAddPointSetting:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetAddPointSetting.GetLayoutFileName()
	return "petjiadianfangan.layout"
end

function PetAddPointSetting:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetAddPointSetting)
	return self
end

function PetAddPointSetting:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.icon = winMgr:getWindow("petjiadianfangan/imagedi/image")
	self.levelText = winMgr:getWindow("petjiadianfangan/imagedi/textlv")
	self.curPointText = winMgr:getWindow("petjiadianfangan/textnumber")
    self.kindImg = winMgr:getWindow("petjiadianfangan/imagedi/imagebb")
	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("petjiadianfangan/framewindow"))

	self.pointTexts = {}
	self.minusBtns = {}
	self.plusBtns = {}
	for i=1,5 do
		self.pointTexts[i] = winMgr:getWindow("petjiadianfangan/textbg2/textzhi"..i)
		self.pointTexts[i]:setID(0)
		
		self.minusBtns[i] = winMgr:getWindow("petjiadianfangan/textbg2/btnjianhao"..i)
		self.plusBtns[i] = winMgr:getWindow("petjiadianfangan/textbg2/btnjiahao"..i)
		self.minusBtns[i]:setID(i)
		self.plusBtns[i]:setID(i)
		self.minusBtns[i]:subscribeEvent("MouseButtonDown", PetAddPointSetting.handleMinusClicked, self)
		self.plusBtns[i]:subscribeEvent("MouseButtonDown", PetAddPointSetting.handlePlusClicked, self)
	end
	
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", PetAddPointSetting.DestroyDialog, nil)
	
	self.curPoint = 0
end

function PetAddPointSetting:setPetData(petData)
	self.petData = petData
	--self.levelText:setText("Lv."..petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
	self.levelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL)..MHSD_UTILS.get_resstring(3))

    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if petAttr then
        local imgpath = GetPetKindImageRes(petAttr.kind, petAttr.unusualid)
		self.kindImg:setProperty("Image", imgpath)
        UseImageSourceSize(self.kindImg, imgpath)
    end
	
	local autoBfp = petData.autoBfp
	self.pointTexts[ATTR.TIZHI]:setText(autoBfp.cons)
	self.pointTexts[ATTR.MAGIC]:setText(autoBfp.iq)
	self.pointTexts[ATTR.POWER]:setText(autoBfp.str)
	self.pointTexts[ATTR.NAILI]:setText(autoBfp.endu)
	self.pointTexts[ATTR.MINJIE]:setText(autoBfp.agi)
	
	self.pointTexts[ATTR.TIZHI]:setID(autoBfp.cons)
	self.pointTexts[ATTR.MAGIC]:setID(autoBfp.iq)
	self.pointTexts[ATTR.POWER]:setID(autoBfp.str)
	self.pointTexts[ATTR.NAILI]:setID(autoBfp.endu)
	self.pointTexts[ATTR.MINJIE]:setID(autoBfp.agi)
	
	self.curPoint = autoBfp.cons+autoBfp.iq+autoBfp.str+autoBfp.endu+autoBfp.agi
	self.curPointText:setText(self.curPoint)
	
	self:refreshBtnState()
	
	self:addSprite(petData.shape)    
    if self.sprite and petAttr then
        if petData and petData.petdye1 ~= 0 then
            self.sprite:SetDyePartIndex(0,petData.petdye1)
        else
            self.sprite:SetDyePartIndex(0,petAttr.area1colour)
        end
        if petData and petData.petdye2 ~= 0 then
            self.sprite:SetDyePartIndex(1,petData.petdye2)
        else
            self.sprite:SetDyePartIndex(1,petAttr.area2colour)
        end
    end
end

function PetAddPointSetting:addSprite(shapeID)
	if not shapeID then
		return
	end
	
	if not self.sprite then
		local pos = self.icon:GetScreenPosOfCenter()
		local loc = Nuclear.NuclearPoint(pos.x, pos.y+50)
		self.sprite = UISprite:new(shapeID)
		if self.sprite then
			self.sprite:SetUILocation(loc)
			self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
			self.icon:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, PetAddPointSetting.performPostRenderFunctions))
		end
	elseif self.sprite:GetModelID() ~= shapeID then
		self.sprite:SetModel(shapeID)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end
end

function PetAddPointSetting.performPostRenderFunctions(id)
	if _instance and _instance.sprite then
		_instance.sprite:RenderUISprite()
	end
end

function PetAddPointSetting:requestSetting()
	local autoBfp = self.petData.autoBfp
	if	self.pointTexts[ATTR.TIZHI]:getID() ~= autoBfp.cons or
		self.pointTexts[ATTR.MAGIC]:getID() ~= autoBfp.iq or
		self.pointTexts[ATTR.POWER]:getID() ~= autoBfp.str or
		self.pointTexts[ATTR.NAILI]:getID() ~= autoBfp.endu or
		self.pointTexts[ATTR.MINJIE]:getID() ~= autoBfp.agi then
	
		local p = require('protodef.fire.pb.pet.cpetsetautoaddpoint'):new()
		p.petkey = self.petData.key
		p.cons = self.pointTexts[ATTR.TIZHI]:getID()
		p.iq = self.pointTexts[ATTR.MAGIC]:getID()
		p.str = self.pointTexts[ATTR.POWER]:getID()
		p.endu = self.pointTexts[ATTR.NAILI]:getID()
		p.agi = self.pointTexts[ATTR.MINJIE]:getID()
		LuaProtocolManager:send(p)
	end
	
	local sb = StringBuilder:new()
	sb:Set("parameter1", self.pointTexts[ATTR.TIZHI]:getID())
	sb:Set("parameter2", self.pointTexts[ATTR.MAGIC]:getID())
	sb:Set("parameter3", self.pointTexts[ATTR.POWER]:getID())
	sb:Set("parameter4", self.pointTexts[ATTR.NAILI]:getID())
	sb:Set("parameter5", self.pointTexts[ATTR.MINJIE]:getID())
	GetCTipsManager():AddMessageTip(sb:GetString(MHSD_UTILS.get_msgtipstring(150108))) --您当前设置属性点自动分配方案为...
    sb:delete()
end

function PetAddPointSetting:refreshBtnState()
	for i=1,5 do
		local val = self.pointTexts[i]:getID()
		self.minusBtns[i]:setEnabled(val > 0)
		self.plusBtns[i]:setEnabled(val < 5 and self.curPoint < 5)
	end
end

function PetAddPointSetting:handleMinusClicked(args)
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
	local val = self.pointTexts[idx]:getID()
	if val > 0 then
		val = val-1
		self.curPoint = self.curPoint-1
		self.pointTexts[idx]:setText(val)
		self.pointTexts[idx]:setID(val)
		self.curPointText:setText(self.curPoint)
		
		self:refreshBtnState()
	end
end

function PetAddPointSetting:handlePlusClicked(args)
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
	local val = self.pointTexts[idx]:getID()
	if self.curPoint < MAX_POINT then
		val = val+1
		self.curPoint = self.curPoint+1
		self.pointTexts[idx]:setText(val)
		self.pointTexts[idx]:setID(val)
		self.curPointText:setText(self.curPoint)
		
		self:refreshBtnState()
	end
end

return PetAddPointSetting

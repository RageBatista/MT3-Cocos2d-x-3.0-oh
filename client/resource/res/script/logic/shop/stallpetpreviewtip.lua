------------------------------------------------------------------
-- °ÚÌ¯³èÎïËÑË÷Ô¤ÀÀ
------------------------------------------------------------------

require "logic.dialog"

StallPetPreviewTip = {}
setmetatable(StallPetPreviewTip, Dialog)
StallPetPreviewTip.__index = StallPetPreviewTip

local _instance
function StallPetPreviewTip.getInstance()
	if not _instance then
		_instance = StallPetPreviewTip:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallPetPreviewTip.getInstanceAndShow()
	if not _instance then
		_instance = StallPetPreviewTip:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallPetPreviewTip.getInstanceNotCreate()
	return _instance
end

function StallPetPreviewTip.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallPetPreviewTip.ToggleOpenClose()
	if not _instance then
		_instance = StallPetPreviewTip:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallPetPreviewTip.GetLayoutFileName()
	return "baitanpetpreview.layout"
end

function StallPetPreviewTip:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallPetPreviewTip)
	return self
end

function StallPetPreviewTip:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.nameText = winMgr:getWindow("petprevicetip/namebg/name")
	self.gongzi = winMgr:getWindow("petprevicetip/textzizhi1")
	self.tizi = winMgr:getWindow("petprevicetip/textzizhi2")
	self.suzi = winMgr:getWindow("petprevicetip/textzizhi3")
	self.fangzi = winMgr:getWindow("petprevicetip/textzizhi4")
	self.fazi = winMgr:getWindow("petprevicetip/textzizhi5")
	self.grow = winMgr:getWindow("petprevicetip/textzizhi6")

	self.skillboxes = {}
	for i=1,5 do
		self.skillboxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petprevicetip/skill" .. i))
	end
end

function StallPetPreviewTip:setPetName(name)
	self.nameText:setText(name)
end

function StallPetPreviewTip:setPetId(petId)
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petId)
    if not conf then return end

	self.gongzi:setText(conf.attackaptmin .. '~' .. conf.attackaptmax)
	self.fangzi:setText(conf.defendaptmin .. '~' .. conf.defendaptmax)
	self.tizi:setText(conf.phyforceaptmin .. '~' .. conf.phyforceaptmax)
	self.fazi:setText(conf.magicaptmin .. '~' .. conf.magicaptmax)
	self.suzi:setText(conf.speedaptmin .. '~' .. conf.speedaptmax)
	
	local growrate = conf.growrate
	local growratemax = 0
	local growratemin = 100000
	for i=0, growrate:size()-1 do
		if growratemax < growrate[i] then
			growratemax = growrate[i]
		end
		if growratemin > growrate[i] then
			growratemin = growrate[i]
		end
	end
	growratemax = growratemax/1000
	growratemin = growratemin/1000
	
	if growratemin == growratemax then
		self.grow:setText(math.floor(growratemin*1000)/1000)
	else
        local str = string.format("%.3f-%.3f",math.floor(growratemin*1000)/1000, math.floor(growratemax*1000)/1000)
		self.grow:setText(str)
	end

	for i=1, 5 do
		self.skillboxes[i]:Clear()
		if i <= conf.skillid:size() then
			SetPetSkillBoxInfo(self.skillboxes[i], conf.skillid[i-1])
			--ÏÔÊ¾±Ø´ø½Ç±ê
			for j=0, conf.skillid:size()-1 do
				if conf.skillid[j] == conf.skillid[i-1] then
					if conf.skillrate[j] >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(323).value) then
						self.skillboxes[i]:SetCornerImage("ccui", "chongwu_bidai")
					end
					break
				end
			end
		end
	end
end

return StallPetPreviewTip
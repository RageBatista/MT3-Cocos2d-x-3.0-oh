require "logic.dialog"

FirstChargeGiftPetDlg = {}
setmetatable(FirstChargeGiftPetDlg, Dialog)
FirstChargeGiftPetDlg.__index = FirstChargeGiftPetDlg

local _instance
function FirstChargeGiftPetDlg.getInstance()
	if not _instance then
		_instance = FirstChargeGiftPetDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function FirstChargeGiftPetDlg.getInstanceAndShow(petID)
	if not _instance then
		_instance = FirstChargeGiftPetDlg:new()
		_instance:OnCreate(petID)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FirstChargeGiftPetDlg.getInstanceNotCreate()
	return _instance
end

function FirstChargeGiftPetDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
            if manager.m_isTodayNotFree then
                require "logic.qiandaosongli.loginrewardmanager"
                local mgr = LoginRewardManager.getInstance()
                if mgr.m_firstchargeState == 0 then
                    local dlg = require "logic.pointcardserver.messageforpointcardnotcashdlg".getInstance()
                    if dlg then
                        dlg:Show()
                    end
                else
                    local dlg = require "logic.pointcardserver.messageforpointcarddlg".getInstance()
                    if dlg then
                        dlg:Show()
                    end
                end

            end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FirstChargeGiftPetDlg.ToggleOpenClose()
	if not _instance then
		_instance = FirstChargeGiftPetDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FirstChargeGiftPetDlg.GetLayoutFileName()
	return "libaosongchongwu_mtg.layout"
end

function FirstChargeGiftPetDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FirstChargeGiftPetDlg)
	return self
end

function FirstChargeGiftPetDlg:OnCreate(petID)
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.shapeDi = winMgr:getWindow("libaosongchongwu_mtg/ditu/tu")
    self.gjzzValue = winMgr:getWindow("libaosongchongwu_mtg/diban/1")
    self.tlzzValue = winMgr:getWindow("libaosongchongwu_mtg/diban/2")
    self.sdzzValue = winMgr:getWindow("libaosongchongwu_mtg/diban/3")
    self.fyzzValue = winMgr:getWindow("libaosongchongwu_mtg/diban/4")
    self.mlzzValue = winMgr:getWindow("libaosongchongwu_mtg/diban/21")
    self.czValue = winMgr:getWindow("libaosongchongwu_mtg/diban/22")
    self.petName = winMgr:getWindow("libaosongchongwu_mtg/taitou/text")

    self.m_CanBattleLevel = winMgr:getWindow("libaosongchongwu_mtg/canzhan1")
    self.m_PetType = winMgr:getWindow("libaosongchongwu_mtg/image")

    self.skillBoxes = {}
	for i=1,6 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("libaosongchongwu_mtg/diban/skillbox"..i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", FirstChargeGiftPetDlg.handleSkillClicked, self)
	end

    self:refreshPetSprite(petID)
    self:refreshPetData(petID)
end

function FirstChargeGiftPetDlg:refreshPetData(petId)
    local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petId)
    if not petAttrCfg then
        return
    end

    local atText = petAttrCfg.attackaptmin .. '~' .. petAttrCfg.attackaptmax
    if petAttrCfg.attackaptmin == petAttrCfg.attackaptmax then 
        atText = tostring(petAttrCfg.attackaptmin)
    end
    
    local fyText = petAttrCfg.defendaptmin .. '~' .. petAttrCfg.defendaptmax
    if petAttrCfg.defendaptmin == petAttrCfg.defendaptmax then 
        fyText = tostring(petAttrCfg.defendaptmin)
    end

    local tlText = petAttrCfg.phyforceaptmin .. '~' .. petAttrCfg.phyforceaptmax
    if petAttrCfg.phyforceaptmin == petAttrCfg.phyforceaptmax then
        tlText = petAttrCfg.phyforceaptmin
    end

    local mlText = petAttrCfg.magicaptmin .. '~' .. petAttrCfg.magicaptmax
    if petAttrCfg.magicaptmin == petAttrCfg.magicaptmax then
        mlText = petAttrCfg.magicaptmin
    end

    local sdText = petAttrCfg.speedaptmin .. '~' .. petAttrCfg.speedaptmax
    if petAttrCfg.speedaptmin == petAttrCfg.speedaptmax then
        sdText = petAttrCfg.speedaptmin
    end

    local growratemax = 0
    local growratemin = petAttrCfg.growrate[0]
	for i=0, petAttrCfg.growrate:size()-1 do
	    if growratemax < petAttrCfg.growrate[i] then
		    growratemax = petAttrCfg.growrate[i]
		end
	end

    growratemin = growratemin / 1000
	growratemax = growratemax / 1000

    local czRateText = growratemin.. '~' .. growratemax
    if growratemin == growratemax then
        czRateText = petAttrCfg.speedaptmin
    end

    self.czValue:setText(czRateText)
    self.petName:setText(petAttrCfg.name)
    self.gjzzValue:setText(atText)
	self.fyzzValue:setText(fyText)
	self.tlzzValue:setText(tlText)
	self.mlzzValue:setText(mlText)
	self.sdzzValue:setText(sdText)

    for i=1, 6 do
		self.skillBoxes[i]:Clear()
		if i <= petAttrCfg.skillid:size() then
			SetPetSkillBoxInfo(self.skillBoxes[i], petAttrCfg.skillid[i-1])
		end
	end

    self.m_CanBattleLevel:setText(petAttrCfg.uselevel)
    self.petName:setProperty("TextColours", "ff8c5e2a")
    local imgpath = GetPetKindImageRes(petAttrCfg.kind, petAttrCfg.unusualid)
	self.m_PetType:setProperty("Image", imgpath)
    if petAttrCfg.iszhenshou ==1 then
        self.m_PetType:setProperty("Image", "set:cc25410 image:zhenshou")
            imgpath="set:cc25410 image:zhenshou"
    end
    UseImageSourceSize(self.m_PetType, imgpath)
   

end

function FirstChargeGiftPetDlg:handleSkillClicked(args)
	local wnd = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if wnd:GetSkillID() == 0 then
		return
	end
	local pos = wnd:GetScreenPos()
	PetSkillTipsDlg.ShowTip(wnd:GetSkillID(),pos.x, pos.y)
end

function FirstChargeGiftPetDlg:refreshPetSprite(petID)
    local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petID)
    if not petAttrCfg then
        return
    end

	if not self.sprite then
		local s = self.shapeDi:getPixelSize()
		self.sprite = gGetGameUIManager():AddWindowSprite(self.shapeDi, petAttrCfg.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, false)
	else
		self.sprite:SetModel(petAttrCfg.modelid)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end
    self.sprite:SetDyePartIndex(0,petAttrCfg.area1colour)
    self.sprite:SetDyePartIndex(1,petAttrCfg.area2colour)
end

return FirstChargeGiftPetDlg

require "logic.dialog"

PetAndUserIcon = {}
setmetatable(PetAndUserIcon, Dialog)
PetAndUserIcon.__index = PetAndUserIcon


local s_fpetHeadSize = 94.0
local s_fpetHeadoffset = 5.0

local _instance
function PetAndUserIcon.getInstance()
	if not _instance then
		_instance = PetAndUserIcon:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetAndUserIcon.getInstanceAndShow()
	if not _instance then
		_instance = PetAndUserIcon:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetAndUserIcon.getInstanceNotCreate()
	return _instance
end

function PetAndUserIcon.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            gGetDataManager().m_EventMainCharacterDataChange:RemoveScriptFunctor(_instance.m_eventMainCharacterDataChange) 
            gGetDataManager().m_EventMainCharacterHpMpChange:RemoveScriptFunctor(_instance.m_eventMainCharacterHpMpChange) 
            gGetDataManager().m_EventBattlePetStateChange:RemoveScriptFunctor(_instance.m_eventBattlePetStateChange) 
            gGetDataManager().m_EventBattlePetDataChange:RemoveScriptFunctor(_instance.m_eventBattlePetDataChange) 
            gGetDataManager().m_EventPetNumChange:RemoveScriptFunctor(_instance.m_eventPetNumChange) 
            gGetDataManager().m_EventMainCharacterExpChange:RemoveScriptFunctor(_instance.m_eventExpChange) 
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetAndUserIcon.ToggleOpenClose()
	if not _instance then
		_instance = PetAndUserIcon:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetAndUserIcon.GetLayoutFileName()
	return "petandusericon.layout"
end

function PetAndUserIcon:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetAndUserIcon)
	return self
end

function PetAndUserIcon:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_eventMainCharacterDataChange = gGetDataManager().m_EventMainCharacterDataChange:InsertScriptFunctor(PetAndUserIcon.UpdateUserDataCpp) 
    self.m_eventMainCharacterHpMpChange = gGetDataManager().m_EventMainCharacterHpMpChange:InsertScriptFunctor(PetAndUserIcon.UpdateUserDataCpp) 
    self.m_eventBattlePetStateChange = gGetDataManager().m_EventBattlePetStateChange:InsertScriptFunctor(PetAndUserIcon.UpdateBattlePetStateCpp) 
    self.m_eventBattlePetDataChange = gGetDataManager().m_EventBattlePetDataChange:InsertScriptFunctor(PetAndUserIcon.UpdateBattlePetDataCpp) 
    self.m_eventPetNumChange = gGetDataManager().m_EventPetNumChange:InsertScriptFunctor(PetAndUserIcon.UpdatePetIconShowHideCpp) 
    self.m_eventExpChange = gGetDataManager().m_EventMainCharacterExpChange:InsertScriptFunctor(PetAndUserIcon.UpdateUserExpCpp) 
    self.m_userIcon = CEGUI.Window.toPushButton(winMgr:getWindow("UserPeticon/userIcon"))
    self.m_petIcon = CEGUI.Window.toPushButton(winMgr:getWindow("UserPeticon/PetIcon"))
    self.m_userHead = CEGUI.Window.toPushButton(winMgr:getWindow("UserPeticon/userHead"))
	
	--self.smokeBg = winMgr:getWindow("UserPeticon/UserBack/btnjiangli/image3/dh")
	--local s = self.smokeBg:getPixelSize()
	--local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi12", true, s.width*0.5, s.height)
    

    self.m_friendHead = CEGUI.Window.toItemCell(winMgr:getWindow("UserPeticon/ren"))
    self.m_friendHead:setVisible(false)
    self.m_userHead:setMousePassThroughEnabled(true)
    
    self.m_userSchool = winMgr:getWindow("UserPeticon/UserBack/zhiye")

    self.m_petHead = winMgr:getWindow("UserPeticon/PetHead")
    self.iamgeEmptyPet = winMgr:getWindow("UserPeticon/PetHead/2") 
    --self.m_petHead:setVisible(true)
    self.iamgeEmptyPet:setVisible(false)
    
    self.iamgeEmptyPet:setMousePassThroughEnabled(true)

    self.m_petHead:setMousePassThroughEnabled(true)

    self.m_red = CEGUI.Window.toProgressBarTwoValue(winMgr:getWindow("UserPeticon/redBar"))
    self.m_blue = CEGUI.Window.toProgressBar(winMgr:getWindow("UserPeticon/blueBar"))
    self.m_yuqi = CEGUI.Window.toProgressBar(winMgr:getWindow("UserPeticon/complaintBar"))
    self.m_petRed = CEGUI.Window.toProgressBar(winMgr:getWindow("UserPeticon/PredBar"))
    self.m_petBlue = CEGUI.Window.toProgressBar(winMgr:getWindow("UserPeticon/PBlueBar"))
    self.m_effect = winMgr:getWindow("UserPeticon/RedPackEffect")
    self.m_userIcon:subscribeEvent("Clicked", PetAndUserIcon.HandleUserIconClick, self)
    self.m_petIcon:subscribeEvent("MouseClick", PetAndUserIcon.HandlePetIconClick, self)
    self.m_friendHead:subscribeEvent("MouseClick", PetAndUserIcon.ShowFriendInfo, self)

    self.m_pUserLevel = winMgr:getWindow("UserPeticon/UserBack/Level")
	self.m_pUserZhuanShengLevel = winMgr:getWindow("UserPeticon/UserBack/Level11")
    self.m_pPetLevel = winMgr:getWindow("UserPeticon/PetBack/Level")
	self.m_pPetZsLevel = winMgr:getWindow("UserPeticon/PetBack/zs")

    self:GetWindow():subscribeEvent("WindowUpdate", PetAndUserIcon.HandleUpdateWindow, self)
	
	

    self.m_pPetWnd = winMgr:getWindow("UserPeticon/PetBack")

    self.m_defaultPetIconH = 0
	self.m_defaultPetIconX = 0
	self.m_defaultPetIconY = 0
    self.m_fPrecision = 0.03
    self.m_bRefreshHp = false
    self.m_bRefreshMp = false
    self.m_bRefreshPetHp = false
    self.m_bRefreshPetMp = false
    self.m_bRefreshPetExp = false
    self.m_midlevel = 0
    self.m_midbili = 0
    self.m_defaultPetIconH = self.m_petHead:getPixelSize().height
	self.m_defaultPetIconX = self.m_petHead:getXPosition().offset + self.m_petHead:getPixelSize().width*0.5
	self.m_defaultPetIconY = self.m_petHead:getYPosition().offset + self.m_petHead:getPixelSize().height
    self.m_defaultPetCenterY = self.m_petHead:getYPosition().offset + self.m_petHead:getPixelSize().height*0.5
    
    self.m_ServerlevelUpBtn = CEGUI.Window.toPushButton(winMgr:getWindow("UserPeticon/fuwuqidengjiup"))
    self.m_ServerlevelDownBtn = CEGUI.Window.toPushButton(winMgr:getWindow("UserPeticon/fuwuqidengjidown"))
    self.m_ServerlevelBtn = CEGUI.Window.toPushButton(winMgr:getWindow("UserPeticon/zhengchang"))
    self.m_ServerlevelUpBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleServerLevel, self)
    self.m_ServerlevelUpBtn:setVisible(false)
    self.m_ServerlevelDownBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleServerLevel, self)
    self.m_ServerlevelDownBtn:setVisible(false)
    self.m_ServerlevelBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleServerLevelNormal, self)
    self.m_ServerlevelBtn:setVisible(false)
    self.m_RedPackBg = winMgr:getWindow("UserPeticon/redpack")
    self.m_RedPackBg:subscribeEvent("MouseClick", PetAndUserIcon.HandleRedPack, self)
    self.m_RedPackNormal = winMgr:getWindow("UserPeticon/redpack/img")
    self.m_RedPackGold = winMgr:getWindow("UserPeticon/redpack/img1")
    self.m_RedPackName = winMgr:getWindow("UserPeticon/redpack/text")
    self.m_RedPackBg:setVisible(false)
    self.m_RedPackId = 0
    self.m_RedPackType = 0
    self.m_ServerLevelExp = 0
    self:OnInit()

    self:updateServerLevel()

end
function PetAndUserIcon:HandleRedPack(EventArgs)
    self.m_RedPackBg:setVisible(false)
    local p = require("protodef.fire.pb.fushi.redpack.cgetredpack"):new()
    p.modeltype = self.m_RedPackType
    p.redpackid = self.m_RedPackId
    LuaProtocolManager:send(p)
end

--function PetAndUserIcon:DestroyDialog()----雪花
--	if self._instance then
--       if self.sprite then
--            self.sprite:delete()
--            self.sprite = nil
--        end
--		if self.smokeBg then
--		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
--		end
--		if self.roleEffectBg then
--		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
--		end
--		self:OnClose()
--		getmetatable(self)._instance = nil
 --       _instance = nil
--	end
--end

function PetAndUserIcon:AddRedPackEffect(num)
    local realsize = 1
    realsize = realsize - tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(365).value) / 100
    if num >= 1000 * realsize then
        local flagEffect = gGetGameUIManager():AddUIEffect(self.m_effect, "spine/hongbao/hongbao", false, 0, 0, false)
    else
        local flagEffect = gGetGameUIManager():AddUIEffect(self.m_effect, "spine/hongbao/hongbao", false, 0, 0, false)
        flagEffect:SetDefaultActName("play2")
    end
end
function PetAndUserIcon:AddRedPackEffectForAll(num)
    local realsize = 1
    realsize = realsize - tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(365).value) / 100
    if num == 2000 * realsize then
        local flagEffect = gGetGameUIManager():AddUIEffect(self.m_effect, MHSD_UTILS.get_effectpath(11075), false, 0, 0, false)
    end
end
function PetAndUserIcon:HandleUserIconClick(EventArgs)
    require "logic.characterinfo.characterlabel".Show(1)
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():OnClose()
    end
end
function PetAndUserIcon:HandleServerLevel(EventArgs)
    --tips
    local tip = require('logic.tips.serverleveltipdlg').getInstanceAndShow()
    tip:setData(self.m_midlevel, self.m_midbili)
end
function PetAndUserIcon:HandleServerLevelNormal(EventArgs)
    --tips
    local tip = require('logic.tips.serverleveltipdlg').getInstanceAndShow()
    tip:setData(0, 0)
end
function PetAndUserIcon:updateServerLevel()
    local nCharLevel = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(297).value)
    local nServerLevel = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(296).value)
    local data = gGetDataManager():GetMainCharacterData()
    local level  = data:GetValue(fire.pb.attr.AttrType.LEVEL)
    local server = gGetDataManager():getServerLevel()
    local minLevel = BeanConfigManager.getInstance():GetTableByName("role.cserviceexpconfig"):getRecorder(1).midlevel
    local maxLevel = BeanConfigManager.getInstance():GetTableByName("role.cserviceexpconfig"):getRecorder(1).midlevel
    local minid = 0
    local maxid = 0
    local blnHas = false
    local midLevel = 0
    local bili = 0
    local exp = data.exp
    --����ͻ�Ƶȼ�
    if level == tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(316).value) or
        level == tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(317).value) then
        local expLevel = BeanConfigManager.getInstance():GetTableByName("login.cexitgame"):getRecorder(level).exp
        for i=1,tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(318).value) do 
            if exp >= expLevel then
                level = level + 1
                exp = exp - expLevel
                expLevel = BeanConfigManager.getInstance():GetTableByName("login.cexitgame"):getRecorder(level).exp
                
            else
                break
            end
        end
    end
    if level>=nCharLevel or ( level > server) then
        if server>= nServerLevel or ( level > server) then
            local disLevel = level - server 
        
            local tableAllId = BeanConfigManager.getInstance():GetTableByName("role.cserviceexpconfig"):getAllID()
            for _, v in pairs(tableAllId) do
                --����ñ���
		        local record = BeanConfigManager.getInstance():GetTableByName("role.cserviceexpconfig"):getRecorder(v)
                if record.midlevel == disLevel then
                    self.m_midlevel = record.midlevel
                    self.m_midbili = record.bili
                    blnHas = true
                    break
                end
                if record.midlevel >= minLevel then
                    minLevel = record.midlevel
                    minid = record.id
                end

                if record.midlevel <= maxLevel then
                    maxLevel = record.midlevel
                    maxid = record.id
                end
            end
            if not blnHas then
                if disLevel < maxLevel then
                    local record = BeanConfigManager.getInstance():GetTableByName("role.cserviceexpconfig"):getRecorder(maxid)
                    self.m_midlevel = record.midlevel
                    self.m_midbili = record.bili
                elseif disLevel > minLevel then
                    local record = BeanConfigManager.getInstance():GetTableByName("role.cserviceexpconfig"):getRecorder(minid)
                    self.m_midlevel = record.midlevel
                    self.m_midbili = record.bili
                end
            end
            if self.m_midbili == 1 then
                self.m_ServerlevelUpBtn:setVisible(false) 
                self.m_ServerlevelDownBtn:setVisible(false)
                self.m_ServerlevelBtn:setVisible(true)
            else
                if self.m_midlevel < 0 then
                    self.m_ServerlevelUpBtn:setVisible(true) 
                    self.m_ServerlevelDownBtn:setVisible(false)
                    self.m_ServerlevelBtn:setVisible(false)
                elseif self.m_midlevel > 0 then
                    self.m_ServerlevelUpBtn:setVisible(false) 
                    self.m_ServerlevelDownBtn:setVisible(true)
                    self.m_ServerlevelBtn:setVisible(false)
                else
                    self.m_ServerlevelUpBtn:setVisible(false) 
                    self.m_ServerlevelDownBtn:setVisible(false)
                    self.m_ServerlevelBtn:setVisible(true)
                end
            end

        else
            self.m_ServerlevelUpBtn:setVisible(false) 
            self.m_ServerlevelDownBtn:setVisible(false)
            self.m_ServerlevelBtn:setVisible(true)
            
        end

    else
        self.m_ServerlevelUpBtn:setVisible(false) 
        self.m_ServerlevelDownBtn:setVisible(false)
        self.m_ServerlevelBtn:setVisible(false)
    end
end
function PetAndUserIcon:ShowFriendInfo(EventArgs)
    gGetFriendsManager():SetContactRole(self.m_roleID, true)
	self.m_friendHead:setVisible(false)
end
function PetAndUserIcon:HandlePetIconClick(EventArgs)
    require "logic.pet.petlabel".Show()
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():OnClose()
    end
end
function PetAndUserIcon:HandleUpdateWindow(EventArgs)
    local data = gGetDataManager():GetMainCharacterData()
	local pro = self.m_red:getProgress()
	local dest = data:GetValue(fire.pb.attr.AttrType.HP) / data:GetValue(fire.pb.attr.AttrType.MAX_HP)
	if math.abs(pro - dest) > self.m_fPrecision then
		if self.m_pAddHpEffect==nil then
			self.m_pAddHpEffect=Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(10224))
	    end
		self:RefreshUserHpBar(dest,false)
	elseif self.m_bRefreshHp then
		if self.m_pAddHpEffect then
			Nuclear.GetEngine():ReleaseEffect(self.m_pAddHpEffect)
			self.m_pAddHpEffect=nil
		end
		if dest< 0.000001 then
			self.m_red:setProgress(0.0)
		
		elseif dest >= 1.0 then
			self.m_red:setProgress(1.0)
		else
			self.m_red:setProgress(dest)
		end

		self.m_bRefreshHp = false
	end
	
	local ulhp = 0.0
	if data:GetValue(fire.pb.attr.AttrType.HP) == data:GetValue(fire.pb.attr.AttrType.UP_LIMITED_HP) then
		ulhp = 1.0 - dest
	else
		ulhp = (data:GetValue(fire.pb.attr.AttrType.MAX_HP)-data:GetValue(fire.pb.attr.AttrType.UP_LIMITED_HP))/data:GetValue(fire.pb.attr.AttrType.MAX_HP)
	end
	local revese = self.m_red:getReverseProgress()
	if math.abs(revese - ulhp) > self.m_fPrecision then
		self:RefreshUserHpBar(ulhp,true)
	end
	local fmp = data:GetValue(fire.pb.attr.AttrType.MP)/data:GetValue(fire.pb.attr.AttrType.MAX_MP)
	if math.abs(self.m_blue:getProgress() - fmp) > self.m_fPrecision then
		if self.m_pAddMpEffect==nil then
			self.m_pAddMpEffect=Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(10226))
		end
		self:RefreshMPProgressBarData(self.m_blue,fmp)
	elseif self.m_bRefreshMp then
		if self.m_pAddMpEffect then
			Nuclear.GetEngine():ReleaseEffect(self.m_pAddMpEffect)
			self.m_pAddMpEffect=nil
		end
		if fmp< 0.000001 then
			self.m_blue:setProgress(0.0)
		elseif fmp >= 1.0 then
			self.m_blue:setProgress(1.0)
		else
			self.m_blue:setProgress(fmp)
        end
		self.m_bRefreshMp = false
	end

	local fsp = data:GetValue(fire.pb.attr.AttrType.SP) / data:GetValue(fire.pb.attr.AttrType.MAX_SP)
	if math.abs(self.m_yuqi:getProgress() - fsp) > self.m_fPrecision then
		self:RefreshProgressBarData(self.m_yuqi,fsp)
	elseif self.m_bRefreshYuqi then
	
		if fsp< 0.000001 then
			self.m_yuqi:setProgress(0.0)
		elseif fsp >= 1.0 then
			self.m_yuqi:setProgress(1.0)
		else
			self.m_yuqi:setProgress(fsp)
		end
		self.m_bRefreshYuqi = false
	end

	local pBattlePet = MainPetDataManager.getInstance():GetBattlePet()
	if pBattlePet == nil then
		return
	end

	dest = pBattlePet:getAttribute(fire.pb.attr.AttrType.HP)/pBattlePet:getAttribute(fire.pb.attr.AttrType.MAX_HP)
 	if math.abs(self.m_petRed:getProgress() - dest) > self.m_fPrecision then
 		self:RefreshProgressBarData(self.m_petRed,dest)
	elseif self.m_bRefreshPetHp then
		if dest< 0.000001 then
			self.m_petRed:setProgress(0.0)
		elseif dest >= 1.0 then
			self.m_petRed:setProgress(1.0)
		else
			self.m_petRed:setProgress(dest)
		end
		self.m_bRefreshPetHp = false
	end
 
	dest = pBattlePet:getAttribute(fire.pb.attr.AttrType.MP)/pBattlePet:getAttribute(fire.pb.attr.AttrType.MAX_MP)
 	if math.abs(self.m_petBlue:getProgress() - dest) > self.m_fPrecision then
 		self:RefreshProgressBarData(self.m_petBlue,dest)
	elseif self.m_bRefreshPetMp then
		if dest< 0.000001 then
			self.m_petBlue:setProgress(0.0)
		elseif dest >= 1.0 then
			self.m_petBlue:setProgress(1.0)
		else
			self.m_petBlue:setProgress(dest)
		end
		self.m_bRefreshPetMp = false;
	end
 
end
function PetAndUserIcon:OnInit()
	local data = gGetDataManager():GetMainCharacterData()
	if data:GetValue(fire.pb.attr.AttrType.MAX_HP) > 0 then
		local hlhp = data:GetValue(fire.pb.attr.AttrType.MAX_HP) - data:GetValue(fire.pb.attr.AttrType.UP_LIMITED_HP)/data:GetValue(fire.pb.attr.AttrType.MAX_HP)
		local hp = data:GetValue(fire.pb.attr.AttrType.HP)/data:GetValue(fire.pb.attr.AttrType.MAX_HP)
		self.m_red:setReverseProgress(hlhp)
		self.m_red:setProgress(hp)
		self.m_blue:setProgress(data:GetValue(fire.pb.attr.AttrType.MP)/data:GetValue(fire.pb.attr.AttrType.MAX_MP))
		self.m_yuqi:setProgress(data:GetValue(fire.pb.attr.AttrType.SP)/data:GetValue(fire.pb.attr.AttrType.MAX_SP))
	end
	self:UpdateUserData()
	self:UpdateUserExp()
	self:UpdateUserIcon()
    self:UpdatePetIcon()
    self:UpdateBattlePetState()
end
function PetAndUserIcon:UpdateUserIcon()
	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape())
	local iconpath = gGetIconManager():GetImagePathByID(Shape.littleheadID)
	local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
	self.m_userHead:setProperty("Image",iconpath:c_str())
	self.m_userSchool:setProperty("Image", school.schooliconpath)
end
function PetAndUserIcon:UpdateUserData()
	local data = gGetDataManager():GetMainCharacterData()
	local hptext = ""
	local FormatStr = ""
	if data:GetValue(fire.pb.attr.AttrType.MAX_HP) > 0 then
		self.m_red:setReverseProgress(((data:GetValue(fire.pb.attr.AttrType.MAX_HP)-data:GetValue(fire.pb.attr.AttrType.UP_LIMITED_HP))/data:GetValue(fire.pb.attr.AttrType.MAX_HP)))
	end
	self.m_bRefreshHp= true
	self.m_bRefreshMp= true
	self.m_bRefreshYuqi= true
    local level  = data:GetValue(fire.pb.attr.AttrType.LEVEL)
	local zhuansheng =data:GetValue(1240)
	self.m_pUserLevel:setText(tostring(level)) 
	self.m_pUserZhuanShengLevel:setText(tostring(zhuansheng))
    self:updateServerLevel()
end

function PetAndUserIcon.UpdateUserExpCpp()
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:updateServerLevel()
    end
end
function PetAndUserIcon:UpdateUserExp()
	local data = gGetDataManager():GetMainCharacterData()
	local level  = data:GetValue(fire.pb.attr.AttrType.LEVEL)
end
function PetAndUserIcon:UpdateUserExpWhenLevelUp()
    local data = gGetDataManager():GetMainCharacterData()
end

function PetAndUserIcon:UpdatePetIcon()
	local nOpen = isPetOpen()
	if nOpen == 0 then
		self.m_pPetWnd:setVisible(false)
		return
	end
	self.m_pPetWnd:setVisible(true)

	local pBattlePet = MainPetDataManager.getInstance():GetBattlePet()
	if pBattlePet == nil then
        self.m_petHead:setVisible(false)
       self.iamgeEmptyPet:setVisible(true)

		--self.m_petHead:setProperty("Image","set:diban image:chongwu")
        --self.m_petHead:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.m_defaultPetIconH), CEGUI.UDim(0, self.m_defaultPetIconH)))
        --self.m_petHead:setPosition( NewVector2(self.m_defaultPetIconX - self.m_petHead:getPixelSize().width*0.5, self.m_defaultPetCenterY - self.m_petHead:getPixelSize().height*0.5))
	else
        self.m_petHead:setVisible(true)
        self.iamgeEmptyPet:setVisible(false)

		local petBaseData = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(pBattlePet.baseid)
		if not petBaseData then
			return
        end
		local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petBaseData.modelid)
		local image = gGetIconManager():GetImagePathByID(Shape.littleheadID)
		self.m_petHead:setProperty("Image",image:c_str())

		local image_i = gGetIconManager():GetImageByID(Shape.littleheadID)
		local w = image_i:getWidth()
		local h = image_i:getHeight()
		local scale = self.m_defaultPetIconH / s_fpetHeadSize;
		local width = w*scale+10
		local height = h*scale+12
		self.m_petHead:setProperty("ImageSizeEnable", "True")
		self.m_petHead:setProperty("LimitWindowSize", "False")
		self.m_petHead:setXPosition(CEGUI.UDim(0, self.m_defaultPetIconX - width*0.5))
		self.m_petHead:setYPosition(CEGUI.UDim(0, self.m_defaultPetIconY - height))
		self.m_petHead:setSize(CEGUI.UVector2(CEGUI.UDim(0, width), CEGUI.UDim(0, height+2)))
	end
end
function PetAndUserIcon:UpdateBattlePetState()
	local nOpen = isPetOpen()
	if nOpen == 0 then
		self.m_pPetWnd:setVisible(false)
		return
	end
	self.m_pPetWnd:setVisible(true);
	local pBattlePet = MainPetDataManager.getInstance():GetBattlePet()
	if pBattlePet == nil then
		self.m_petRed:setTooltipText("")
		self.m_petBlue:setTooltipText("")
		self.m_petRed:setProgress(0.0)
		self.m_petBlue:setProgress(0.0)
		self.m_pPetLevel:setText("")
		self.m_pPetZsLevel:setText("")
	else
		self.m_pPetLevel:setText(tostring(pBattlePet:getAttribute(fire.pb.attr.AttrType.LEVEL))) 
		self.m_pPetZsLevel:setText(tostring(pBattlePet:getAttribute(1240))) 
		if pBattlePet:getAttribute(fire.pb.attr.AttrType.MAX_HP) ~= 0 then
			self.m_petRed:setProgress((pBattlePet:getAttribute(fire.pb.attr.AttrType.HP) / pBattlePet:getAttribute(fire.pb.attr.AttrType.MAX_HP)))
		else
			self.m_petRed:setProgress(0.0)
        end
		if pBattlePet:getAttribute(fire.pb.attr.AttrType.MAX_MP) ~= 0 then
			self.m_petBlue:setProgress((pBattlePet:getAttribute(fire.pb.attr.AttrType.MP) / pBattlePet:getAttribute(fire.pb.attr.AttrType.MAX_MP)))
		else
			self.m_petBlue:setProgress(0.0)
        end
	end
	self:UpdatePetIcon()
end

function PetAndUserIcon:SetHpAndMpPro()
	self.m_red:setProgress(0)
	self.m_blue:setProgress(0)
end

function PetAndUserIcon:UpdateBattlePetData()
	local nOpen = isPetOpen()
	if nOpen == 0 then
		self.m_pPetWnd:setVisible(false)
		return
	end
	self.m_pPetWnd:setVisible(true)
	local pBattlePet = MainPetDataManager.getInstance():GetBattlePet()
	if pBattlePet == nil then
		self.m_petRed:setTooltipText("")
		self.m_petBlue:setTooltipText("")
		self.m_pPetLevel:setText("")
		self.m_pPetZsLevel:setText("")
	else
		self.m_pPetLevel:setText(pBattlePet:getAttribute(fire.pb.attr.AttrType.LEVEL))
		self.m_pPetZsLevel:setText(pBattlePet:getAttribute(1240))
		self.m_bRefreshPetHp = true
		self.m_bRefreshPetMp = true
    end
end

function PetAndUserIcon:UpdatePetIconShowHide()

	local nOpen = isPetOpen()
    local blnOpen = false
    if nOpen ~= 0 then
        blnOpen = true
    end
	self.m_pPetWnd:setVisible(blnOpen)
	if self.m_pPetWnd:isVisible() then
		self:UpdatePetIcon()
		self:UpdateBattlePetState()
	end
end
function PetAndUserIcon:RefreshUserHpBar(destData, bReverse)
	if bReverse == false then
		local progress = self.m_red:getProgress()
		if destData > progress then
		
			progress = progress + self.m_fPrecision
		elseif destData < progress then
		
			progress = progress - self.m_fPrecision;
		end
		if math.abs(progress - destData) < self.m_fPrecision  then
		
			progress = destData
		end
		self.m_red:setProgress(progress)
		if self.m_pAddHpEffect then
            local pos = Nuclear.NuclearPoint(self.m_red:GetScreenPos().x+ self.m_red:getPixelSize().width * progress, 
            self.m_red:GetScreenPos().y+self.m_red:getPixelSize().height/2.0)
			self.m_pAddHpEffect:SetLocation(pos);
		end
	else
		self.m_red:setReverseProgress(destData)
	end
end
function PetAndUserIcon:RefreshMPProgressBarData(bar, destData)

	local progress = bar:getProgress()
	    
    if destData > progress then
    	progress = progress + self.m_fPrecision
    elseif destData < progress then
   
    	progress = progress - self.m_fPrecision
    end
	
	if math.abs(progress - destData) < self.m_fPrecision then
	
		progress = destData;
	end
    
	bar:setProgress(progress)
	if self.m_pAddMpEffect and bar == self.m_blue then
        local pos = Nuclear.NuclearPoint(self.m_blue:GetScreenPos().x+ self.m_blue:getPixelSize().width * progress, 
        self.m_blue:GetScreenPos().y+self.m_blue:getPixelSize().height/2.0)
		self.m_pAddMpEffect:SetLocation(pos);        
	end
    
end
function PetAndUserIcon:RefreshProgressBarData(bar, destData)

	local progress = bar:getProgress()
	
    progress = progress + self.m_fPrecision;
    if destData < progress then
        progress = 0.0
    end
	
	if math.abs(progress - destData) < self.m_fPrecision then
		progress = destData
	end

	bar:setProgress(progress)
	if self.m_pAddMpEffect and bar==self.m_blue then    
        local pos = Nuclear.NuclearPoint(self.m_blue:GetScreenPos().x+ self.m_blue:getPixelSize().width * progress, 
        self.m_blue:GetScreenPos().y+self.m_blue:getPixelSize().height/2.0)
		self.m_pAddMpEffect:SetLocation(pos)     
	end

end
function PetAndUserIcon.UpdateUserDataCpp()
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:UpdateUserData()
    end
end

function PetAndUserIcon.UpdateBattlePetStateCpp()
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:UpdateBattlePetState()
    end
end
function PetAndUserIcon.UpdateBattlePetDataCpp()
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:UpdateBattlePetData()
    end
end
function PetAndUserIcon.UpdatePetIconShowHideCpp()
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:UpdatePetIconShowHide()
    end
end
function PetAndUserIcon:ShowFriendHead(roleName,roleID)

	local pChar = gGetScene():FindCharacterByID(tonumber(roleID))
	if pChar ~=  nil then
		local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(pChar:GetShapeID())
		self.m_friendHead:SetImage(gGetIconManager():GetImageByID(Shape.littleheadID))
		self.m_friendHead:setVisible(true)
		self.m_roleID = tonumber(roleID)
		self.m_roleName = tostring(roleName)
	end 
end
function PetAndUserIcon.ShowFriendHeadCpp(roleID, roleName, a,b)
    local datamanager = require "logic.family.familyfightmanager"
    if datamanager then
        if GetIsInFamilyFight() then
            if datamanager:IsEnemy(roleID) and not datamanager:GetIsReadyForFight() then
                local character = gGetScene():FindCharacterByID(roleID)
                if character then
                    if character:IsInBattle() then
                         local p = require("protodef.fire.pb.battle.csendwatchbattle"):new()
                         p.roleid = roleID
	                     LuaProtocolManager:send(p)
                    else
                        local req = require"protodef.fire.pb.clan.fight.cstartclanfightbattle".Create()
                        req.targetid = roleID
                        LuaProtocolManager.getInstance():send(req)
                    end
                end
                return
           else
                local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
                if dlg then
                    dlg:ShowFriendHead(roleName,roleID)
                end
                if datamanager:IsEnemy(roleID)  then
                    GetCTipsManager():AddMessageTipById(410052)
                end
           end
        else
              local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
              if dlg then
                   dlg:ShowFriendHead(roleName,roleID)
              end
        end
    end
end
return PetAndUserIcon

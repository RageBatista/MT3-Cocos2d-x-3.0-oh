local Dialog = require "logic.dialog"
local SingletonDialog = require "logic.singletondialog"

local UserMiniIconDlg = {}
setmetatable(UserMiniIconDlg, SingletonDialog)
UserMiniIconDlg.__index = UserMiniIconDlg

UserMiniIconDlg.Precision = 0.5 -- 每秒改变进度
UserMiniIconDlg.MinBarFlashValue = 0.3 -- 进度条闪烁

local ImageSize = 94 -- 头像原始尺寸

function UserMiniIconDlg.new()
	local inst = {}
	setmetatable(inst, UserMiniIconDlg)
	inst:OnCreate()
	return inst
end

function UserMiniIconDlg.GetLayoutFileName()
    return "petanduserminiicon.layout"
end

function UserMiniIconDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_wIcon = CEGUI.Window.toPushButton(winMgr:getWindow("petanduserminiicon/userHead"))
	self.m_wIconBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petanduserminiicon/userHead/userbutton"))
	self.m_wLevel = winMgr:getWindow("petanduserminiicon/UserBack/Level")
	self.m_wHP = CEGUI.Window.toProgressBarTwoValue(winMgr:getWindow("petanduserminiicon/redBar"))
	self.m_wMP = CEGUI.Window.toProgressBar(winMgr:getWindow("petanduserminiicon/blueBar"))
	self.m_wSP = CEGUI.Window.toProgressBar(winMgr:getWindow("petanduserminiicon/angerBar"))
	
	self.m_wIconBB = CEGUI.Window.toPushButton(winMgr:getWindow("petanduserminiicon/Bbback/bbhead"))
	self.m_wIconBBBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petanduserminiicon/Bbback/bbhead/bbbuttton"))
	self.m_wLevelBB = winMgr:getWindow("petanduserminiicon/Bbback/lev")
	self.m_wHPBB = CEGUI.Window.toProgressBarTwoValue(winMgr:getWindow("petanduserminiicon/Bbback/bbback/hp"))
	self.m_wMPBB = CEGUI.Window.toProgressBar(winMgr:getWindow("petanduserminiicon/Bbback/bbback/mp"))
    
    self.iamgeEmptyPet = winMgr:getWindow("petanduserminiicon/Bbback/2") 
    self.iamgeEmptyPet:setVisible(false)    
    self.iamgeEmptyPet:setMousePassThroughEnabled(true)

    self.m_useSchool = winMgr:getWindow("petanduserminiicon/UserBack/zhiye")
	
	self.m_wIconBtn:subscribeEvent("Clicked", UserMiniIconDlg.HandleIcon, self)
	self.m_wIconBBBtn:subscribeEvent("Clicked", UserMiniIconDlg.HandleIconBB, self)

    self.defaultPetIconH = self.m_wIconBB:getPixelSize().height;
	self.defaultPetIconX = self.m_wIconBB:getXPosition().offset + self.m_wIconBB:getPixelSize().width*0.5;
    self.defaultPetIconY = self.m_wIconBB:getYPosition().offset + self.m_wIconBB:getPixelSize().height;

    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:GetWindow():setVisible(false)
    end
	self:InitData()
	
    local battleID = GetBattleManager():GetBattleID()
    if battleID >= 8401 and battleID <= 8406 then
        winMgr:getWindow("petanduserminiicon/Bbback"):setVisible(false)
    end

    self.m_midlevel = 0
    self.m_midbili = 0

    self.m_ServerlevelUpBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petanduserminiicon/fuwuqidengjiup"))
    self.m_ServerlevelDownBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petanduserminiicon/fuwuqidengjidown"))
    self.m_ServerlevelBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petanduserminiicon/zhengchang"))
    self.m_ServerlevelUpBtn:subscribeEvent("MouseClick", UserMiniIconDlg.HandleServerLevel, self)
    self.m_ServerlevelUpBtn:setVisible(false)
    self.m_ServerlevelDownBtn:subscribeEvent("MouseClick", UserMiniIconDlg.HandleServerLevel, self)
    self.m_ServerlevelDownBtn:setVisible(false)
    self.m_ServerlevelBtn:subscribeEvent("MouseClick", UserMiniIconDlg.HandleServerLevelNormal, self)
    self.m_ServerlevelBtn:setVisible(false)
    self.m_ServerLevelExp = 0
    self.m_RedPackBg = winMgr:getWindow("petanduserminiicon/redpack")
    self.m_RedPackBg:subscribeEvent("MouseClick", PetAndUserIcon.HandleRedPack, self)
    self.m_RedPackName = winMgr:getWindow("petanduserminiicon/redpack/text")
    self.m_RedPackBg:setVisible(false)
    self.m_RedPackNormal =  winMgr:getWindow("petanduserminiicon/redpack/img")
    self.m_RedPackGold =  winMgr:getWindow("petanduserminiicon/redpack/img1")
    self.m_RedPackId = 0
    self.m_RedPackType = 0

    self:updateServerLevel()
    self:updateRedpackLevel()
end
function UserMiniIconDlg:updateRedpackLevel()
    local realsize = 1
    realsize = realsize - tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(365).value) / 100
    local manager = require"logic.redpack.redpackmanager".getInstance()
    if manager then
        if manager.m_Notice ~= nil then
            self.m_RedPackId = manager.m_Notice.redpackid
            self.m_RedPackType = manager.m_Notice.modeltype
            self.m_RedPackBg:setVisible(true)
            self.m_RedPackName:setText(manager.m_Notice.rolename)
            local nNumFushi = 1000
            local pmanager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
            if pmanager then
                if pmanager.m_isPointCardServer then
                    nNumFushi = nNumFushi * 100
                end
            end
            if manager.m_Notice.fushi < nNumFushi * realsize then
                self.m_RedPackNormal:setVisible(true)
                self.m_RedPackGold:setVisible(false)
            else
                self.m_RedPackNormal:setVisible(false)
                self.m_RedPackGold:setVisible(true)
            end
        end
    end
end
function UserMiniIconDlg:HandleRedPack(EventArgs)
    self.m_RedPackBg:setVisible(false)
    local p = require("protodef.fire.pb.fushi.redpack.cgetredpack"):new()
    p.modeltype = self.m_RedPackType
    p.redpackid = self.m_RedPackId
    LuaProtocolManager:send(p)
end
function UserMiniIconDlg:HandleServerLevel(EventArgs)
    --tips
    local tip = require('logic.tips.serverleveltipdlg').getInstanceAndShow()
    tip:setData(self.m_midlevel, self.m_midbili)
end
function UserMiniIconDlg:HandleServerLevelNormal(EventArgs)
    --tips
    local tip = require('logic.tips.serverleveltipdlg').getInstanceAndShow()
    tip:setData(0, 0)
end
function UserMiniIconDlg:updateServerLevel()
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
    --等于突破等级
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
                --活动配置表新
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
function UserMiniIconDlg:HandleIcon(args)
	--gGetGameUIManager():QuickCommand("ShowWindow","CCharacterLabelDlg","0","","")
	require "logic.characterinfo.characterlabel".Show(1)
end

function UserMiniIconDlg:HandleIconBB(args)
	PetLabel.Show()
end

function UserMiniIconDlg:OnClose()
	Dialog.OnClose(self)
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:GetWindow():setVisible(true)
        dlg:UpdatePetIcon()
        dlg:UpdateBattlePetData()
    end
end

function UserMiniIconDlg:InitData()
	-- init icon
	local shapeid = gGetDataManager():GetMainCharacterShape()
	local shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shapeid)
	local iconPath = gGetIconManager():GetImagePathByID(shape.littleheadID):c_str()
	self.m_wIcon:setProperty("Image",iconPath)

    local schoolrecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    self.m_useSchool:setProperty("Image", schoolrecord.schooliconpath)
    --self.m_useSchool
	-- init lv
	local lv = gGetDataManager():GetMainCharacterLevel()
	self.m_wLevel:setText(tostring(lv))

	-- hp, mp, sp
	local data = gGetDataManager():GetMainCharacterData()
	local hp = data:GetValue(fire.pb.attr.AttrType.HP) / data:GetValue(fire.pb.attr.AttrType.MAX_HP)
	local hpR = (data:GetValue(fire.pb.attr.AttrType.MAX_HP)-data:GetValue(fire.pb.attr.AttrType.UP_LIMITED_HP)) / data:GetValue(fire.pb.attr.AttrType.MAX_HP)
	local mp = data:GetValue(fire.pb.attr.AttrType.MP) / data:GetValue(fire.pb.attr.AttrType.MAX_MP)
	local sp = data:GetValue(fire.pb.attr.AttrType.SP) / data:GetValue(fire.pb.attr.AttrType.MAX_SP)
	self.m_wHP:setProgress(hp)
	self.m_wHP:setReverseProgress(hpR)
	self.m_wMP:setProgress(mp)
	self.m_wSP:setProgress(sp)

	-- effect
	if hp < self.MinBarFlashValue then
--		gGetGameUIManager():AddUIEffect(self.m_wHP, MHSD_UTILS.get_effectpath(10223))
		self.m_HPEffect = true
	else
		self.m_HPEffect = false
	end
	if mp < self.MinBarFlashValue then
--		gGetGameUIManager():AddUIEffect(self.m_wMP, MHSD_UTILS.get_effectpath(10225))
		self.m_MPEffect = true
	else
		self.m_MPEffect = false
	end
	
	local PetData = MainPetDataManager.getInstance():GetBattlePet()
	if PetData ~= nil and PetData.battlestate == 0 then
		local PethpMax = PetData:getAttribute(fire.pb.attr.AttrType.MAX_HP)
		local Pethp = PetData:getAttribute(fire.pb.attr.AttrType.HP)
		if Pethp > 0 then
			local PethpRate = 0.0
			if PethpMax > 0 then
				PethpRate = Pethp / PethpMax
			end
			local PetmpMax = PetData:getAttribute(fire.pb.attr.AttrType.MAX_MP)
			local Petmp = PetData:getAttribute(fire.pb.attr.AttrType.MP);
			local PetmpRate = 0.0
			if PetmpMax > 0 then
				PetmpRate = Petmp / PetmpMax
			end
			
			local Petlv = PetData:getAttribute(fire.pb.attr.AttrType.LEVEL)
			
			self.m_wHPBB:setProgress(PethpRate)
			self.m_wMPBB:setProgress(PetmpRate)
			self.m_wLevelBB:setText(tostring(Petlv))
			
			local Petshapeid = PetData:GetShapeID();
			local Petshape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(Petshapeid)
			local PeticonPath = gGetIconManager():GetImagePathByID(Petshape.littleheadID):c_str()

            self:setPetImage(Petshape.littleheadID)
            --UseImageSourceSize(self.m_wIconBB, PeticonPath)
			--:setProperty("Image",)

			self.m_wIconBB:setVisible(true)
			self.m_wLevelBB:setVisible(true)
			self.m_wHPBB:setVisible(true)
			self.m_wMPBB:setVisible(true)
            self.iamgeEmptyPet:setVisible(false)
		else
            self.iamgeEmptyPet:setVisible(true)
			self.m_wIconBB:setVisible(false)
            self:resetPetIcon()
			self.m_wLevelBB:setVisible(false)
			self.m_wHPBB:setVisible(false)
			self.m_wMPBB:setVisible(false)
		end			
	else
        self.iamgeEmptyPet:setVisible(true)
		self.m_wIconBB:setVisible(false)
        self:resetPetIcon()
		self.m_wLevelBB:setVisible(false)
		self.m_wHPBB:setVisible(false)
		self.m_wMPBB:setVisible(false)
	end
	
end

function UserMiniIconDlg:resetPetIcon()
    local petHeadSize = 94.0
    local petHeadoffse = 5.0
    self.m_wIconBB:setSize(CEGUI.UVector2(CEGUI.UDim(0, petHeadSize), CEGUI.UDim(0, petHeadSize)))
    self.m_wIconBB:setPosition( NewVector2(self.defaultPetIconX - self.m_wIconBB:getPixelSize().width*0.5, self.defaultPetIconY - self.m_wIconBB:getPixelSize().height + petHeadoffse))
end

local function calcPro(cur, dest, delta)
	local pdelta = delta*UserMiniIconDlg.Precision/1000
	local value = 0
	if cur < dest then
		value = cur + pdelta
		if value > dest then
			value = dest
		end
	end
	if cur > dest then
		value = cur - pdelta
		if value < dest then
			value = dest
		end
	end
	return value
end

function UserMiniIconDlg:run(delta)
	local data = gGetDataManager():GetMainCharacterData()
	local hp = data:GetValue(fire.pb.attr.AttrType.HP) / data:GetValue(fire.pb.attr.AttrType.MAX_HP)
	local hpR = (data:GetValue(fire.pb.attr.AttrType.MAX_HP)-data:GetValue(fire.pb.attr.AttrType.UP_LIMITED_HP)) / data:GetValue(fire.pb.attr.AttrType.MAX_HP)
	local mp = data:GetValue(fire.pb.attr.AttrType.MP) / data:GetValue(fire.pb.attr.AttrType.MAX_MP)
	local sp = data:GetValue(fire.pb.attr.AttrType.SP) / data:GetValue(fire.pb.attr.AttrType.MAX_SP)

	local whp = self.m_wHP:getProgress()
	local whpR = self.m_wHP:getReverseProgress()
	local wmp = self.m_wMP:getProgress()
	local wsp = self.m_wSP:getProgress()

	-- refresh hp
	if math.abs(hp-whp) > 0.0001 then
		whp = calcPro(whp, hp, delta)
		if self.m_HPEffect and whp >= self.MinBarFlashValue then
			gGetGameUIManager():RemoveUIEffect(self.m_wHP)
			self.m_HPEffect = false
		end
		if not self.m_HPEffect and whp < self.MinBarFlashValue then
			--gGetGameUIManager():AddUIEffect(self.m_wHP, MHSD_UTILS.get_effectpath(10223))
			self.m_HPEffect = true
		end
		self.m_wHP:setProgress(whp)
	end

	-- refresh hpr
	if math.abs(hpR-whpR) > 0.0001 then
		whpR = calcPro(whpR, hpR, delta)
		self.m_wHP:setReverseProgress(whpR)
	end

	-- refresh mp
	if math.abs(mp-wmp) > 0.0001 then
		wmp = calcPro(wmp, mp, delta)
		if self.m_MPEffect and wmp >= self.MinBarFlashValue then
			gGetGameUIManager():RemoveUIEffect(self.m_wMP)
			self.m_MPEffect = false
		end
		if not self.m_MPEffect and wmp < self.MinBarFlashValue then
			--gGetGameUIManager():AddUIEffect(self.m_wMP, MHSD_UTILS.get_effectpath(10225))
			self.m_MPEffect = true
		end
		self.m_wMP:setProgress(wmp)
	end

	-- refresh sp
	if math.abs(sp-wsp) > 0.0001 then
		wsp = calcPro(wsp, sp, delta)
		self.m_wSP:setProgress(wsp)
	end
	local PetData = MainPetDataManager.getInstance():GetBattlePet()
	if PetData ~= nil and PetData.battlestate == 0 then
		local PethpMax = PetData:getAttribute(fire.pb.attr.AttrType.MAX_HP)
		local Pethp = PetData:getAttribute(fire.pb.attr.AttrType.HP)
		if Pethp > 0 then
			local PethpRate = 0.0
			if PethpMax > 0 then
				PethpRate = Pethp / PethpMax
			end
			local PetmpMax = PetData:getAttribute(fire.pb.attr.AttrType.MAX_MP)
			local Petmp = PetData:getAttribute(fire.pb.attr.AttrType.MP);
			local PetmpRate = 0.0
			if PetmpMax > 0 then
				PetmpRate = Petmp / PetmpMax
			end
			local Petlv = PetData:getAttribute(fire.pb.attr.AttrType.LEVEL)
			local Petwhp = self.m_wHPBB:getProgress()
			local Petwmp = self.m_wMPBB:getProgress()
			
			-- refresh hp
			if math.abs(PethpRate-Petwhp) > 0.0001 then
				Petwhp = calcPro(Petwhp, PethpRate, delta)
				self.m_wHPBB:setProgress(Petwhp)
			end
			-- refresh mp
			if math.abs(PetmpRate-Petwmp) > 0.0001 then
				Petwmp = calcPro(Petwmp, PetmpRate, delta)
				self.m_wMPBB:setProgress(Petwmp)
			end
			
			self.m_wLevelBB:setText(tostring(Petlv))
			local Petshapeid = PetData:GetShapeID();
			local Petshape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(Petshapeid)
			local PeticonPath = gGetIconManager():GetImagePathByID(Petshape.littleheadID):c_str()
			self.m_wIconBB:setProperty("Image",PeticonPath)	
            self:setPetImage(Petshape.littleheadID)
			
			self.m_wIconBB:setVisible(true)
			self.m_wLevelBB:setVisible(true)
			self.m_wHPBB:setVisible(true)
			self.m_wMPBB:setVisible(true)
            self.iamgeEmptyPet:setVisible(false)
			
		else
            self.iamgeEmptyPet:setVisible(true)
			self.m_wIconBB:setVisible(false)
            self:resetPetIcon()
			self.m_wLevelBB:setVisible(false)
			self.m_wHPBB:setVisible(false)
			self.m_wMPBB:setVisible(false)
		end
	else
        self.iamgeEmptyPet:setVisible(true)
		self.m_wIconBB:setVisible(false)
        self:resetPetIcon()
		self.m_wLevelBB:setVisible(false)
		self.m_wHPBB:setVisible(false)
		self.m_wMPBB:setVisible(false)
	end
	
end

function UserMiniIconDlg:setPetImage(littleheadID)
    local image_i = gGetIconManager():GetImageByID(littleheadID);
	local w = image_i:getWidth();
	local h = image_i:getHeight();
	local scale = self.defaultPetIconH / ImageSize;
	local width = w*scale+10;
	local height = h*scale+12;
	self.m_wIconBB:setProperty("ImageSizeEnable", "True");
	self.m_wIconBB:setProperty("LimitWindowSize", "False");
	self.m_wIconBB:setXPosition(CEGUI.UDim(0, self.defaultPetIconX - width*0.5));
    self.m_wIconBB:setYPosition(CEGUI.UDim(0, self.defaultPetIconY - height));
    self.m_wIconBB:setSize(CEGUI.UVector2(CEGUI.UDim(0, width), CEGUI.UDim(0, height+2)))
end

return UserMiniIconDlg

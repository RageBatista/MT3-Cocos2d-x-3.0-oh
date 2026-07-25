------------------------------------------------------------------
-- 宠物详情
------------------------------------------------------------------
require "logic.dialog"

local RANDOM_ACT = {
	eActionRun,
	eActionAttack,
	eActionMagic1
}

PetDetailDlg = {}
setmetatable(PetDetailDlg, Dialog)
PetDetailDlg.__index = PetDetailDlg

local _instance
function PetDetailDlg.getInstance()
	if not _instance then
		_instance = PetDetailDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetDetailDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetDetailDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetDetailDlg.getInstanceNotCreate()
	return _instance
end

function PetDetailDlg.DestroyDialog()
	if _instance then
        _instance:GetWindow():removeEvent("AlphaChanged")
		if not _instance.m_bCloseIsHide then
			if _instance.closeCallFunc then
				_instance.closeCallFunc.func(_instance.closeCallFunc.tar)
			end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetDetailDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetDetailDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetDetailDlg.GetLayoutFileName()
	return "petxiangqing.layout"
end

function PetDetailDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetDetailDlg)
	return self
end

function PetDetailDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self:GetWindow():setRiseOnClickEnabled(false)

	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("petxiangqing/jiemian/guanbi"))
	self.kindImg = winMgr:getWindow("petxiangqing/jiemian/ditu/baobao")
	self.profileIcon = winMgr:getWindow("petxiangqing/jiemian/ditu/moxing")
	self.levelText = winMgr:getWindow("petxiangqing/jiemian/ditu/dengji")
	self.scoreText = winMgr:getWindow("petxiangqing/jiemian/ditu/pingfen1")
	self.skillScroll = CEGUI.toScrollablePane(winMgr:getWindow("petxiangqing/skillscroll"))
	self.neidanscroll = CEGUI.toScrollablePane(winMgr:getWindow("petxiangqing/neidanscroll"))
	self.hp = winMgr:getWindow("petxiangqing/jiemian/di2/1zhi")
	self.tizhi = winMgr:getWindow("petxiangqing/jiemian/di2/2zhi")
	self.moli = winMgr:getWindow("petxiangqing/jiemian/di2/4zhi")
	self.phyAttack = winMgr:getWindow("petxiangqing/jiemian/di2/3zhi")
	self.phyDefend = winMgr:getWindow("petxiangqing/jiemian/di2/5zhi")
	self.power = winMgr:getWindow("petxiangqing/jiemian/di2/6zhi")
	self.magicAttack = winMgr:getWindow("petxiangqing/jiemian/di2/7zhi")
	self.naili = winMgr:getWindow("petxiangqing/jiemian/di2/8zhi")
	self.magicDefend = winMgr:getWindow("petxiangqing/jiemian/di2/9zhi1")
	self.minjie = winMgr:getWindow("petxiangqing/jiemian/di2/10zhi")
	self.speed = winMgr:getWindow("petxiangqing/jiemian/di2/11zhi")
	self.qianneng = winMgr:getWindow("petxiangqing/jiemian/di2/12zhi")
	
	
	self.cc_gongzi = winMgr:getWindow("petxiangqing/jiemian/di2/gjzz")--攻击资质
	self.cc_fangzi = winMgr:getWindow("petxiangqing/jiemian/di2/fyzz")--防御资质
	self.cc_tizi = winMgr:getWindow("petxiangqing/jiemian/di2/tlzz")--体力资质
	self.cc_fazi = winMgr:getWindow("petxiangqing/jiemian/di2/fszz")--法术资质
	self.cc_suduzi = winMgr:getWindow("petxiangqing/jiemian/di2/sdzz")--速度资质
	self.cc_chengzhang = winMgr:getWindow("petxiangqing/jiemian/di2/czzz")--成长资质
	
	
	self.gongziBar = CEGUI.toProgressBar(winMgr:getWindow("petxiangqing/jiemian/di2/13jindu"))
	self.fangziBar = CEGUI.toProgressBar(winMgr:getWindow("petxiangqing/jiemian/di2/14jindu"))
	self.tiziBar = CEGUI.toProgressBar(winMgr:getWindow("petxiangqing/jiemian/di2/15jindu"))
	self.faziBar = CEGUI.toProgressBar(winMgr:getWindow("petxiangqing/jiemian/di2/16jindu"))
	self.suziBar = CEGUI.toProgressBar(winMgr:getWindow("petxiangqing/jiemian/di2/17jindu"))
	self.life = winMgr:getWindow("petxiangqing/jiemian/di2/18zhi")-- 寿命
	self.chengzhangBar = CEGUI.toProgressBar(winMgr:getWindow("petxiangqing/jiemian/di2/19jindu"))
	self.zizhidanNum = winMgr:getWindow("petxiangqing/jiemian/di2/21zhi")
	self.growItemUseNum = winMgr:getWindow("petxiangqing/jiemian/di2/22zhi")
	self.lastBtn = CEGUI.toPushButton(winMgr:getWindow("petxiangqing/zuo"))
	self.nextBtn = CEGUI.toPushButton(winMgr:getWindow("petxiangqing/you"))
    self.allwaysLive = winMgr:getWindow("petxiangqing/jiemian/di2/18zhi1")
	self.skillTypeTabBtn1 = CEGUI.toGroupButton(winMgr:getWindow("petxiangqing/jiemian/skill"))
	self.skillTypeTabBtn2 = CEGUI.toGroupButton(winMgr:getWindow("petxiangqing/jiemian/neidan"))
	self.skillpanel = winMgr:getWindow("petxiangqing/skillscroll")
	self.neidanpanel = winMgr:getWindow("petxiangqing/neidanscroll")
	self.skillTypeTabBtn1:subscribeEvent("SelectStateChanged", PetDetailDlg.handleSwitchSkillTypeTab, self)
	self.skillTypeTabBtn2:subscribeEvent("SelectStateChanged", PetDetailDlg.handleSwitchSkillTypeTab, self)
    
    --self.chatBtn = CEGUI.toPushButton(winMgr:getWindow("petxiangqing/jiemian/duihua"))

	self.lastBtn:subscribeEvent("Clicked", PetDetailDlg.handleLastClicked, self)
	self.nextBtn:subscribeEvent("Clicked", PetDetailDlg.handleNextClicked, self)
   -- self.chatBtn:subscribeEvent("Clicked", PetDetailDlg.handleChatClicked, self)
	self.closeBtn:subscribeEvent("Clicked", PetDetailDlg.DestroyDialog, nil)
	
	------------------ init ------------------
	self.skillBoxes = {}
	for i=1,24 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petxiangqing/skillscroll/skill" .. i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", PetDetailDlg.handleSkillClicked, self)
        self.skillBoxes[i]:SetBackGroupOnTop(true)
	end
	self.skillBoxes[24]:setVisible(false)

	self.neidanBoxes = {}
	for i=1,7 do
		self.neidanBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petxiangqing/neidanscroll/skill" .. i))
		self.neidanBoxes[i]:subscribeEvent("MouseClick", PetDetailDlg.handleSkillClicked, self)
      --  self.neidanBoxes[i]:SetBackGroupOnTop(true)
	end
	self.neidanBoxes[7]:setVisible(false)
	self.neidanscroll:EnableAllChildDrag(self.neidanscroll)
	self.skillScroll:EnableAllChildDrag(self.skillScroll)
	
	self.lastBtn:setVisible(false)
	self.nextBtn:setVisible(false)
    
    self.petdye1 = 0
    self.petdye2 = 0
    self:GetWindow():subscribeEvent("AlphaChanged", PetDetailDlg.onEventAlphaChanged, self)

    --先隐藏，收到详细数据后再显示
    self:GetWindow():setVisible(false)
end

function PetDetailDlg:setSwitchPageCallFunc(func, tar)
	if func then
		self.switchCallFunc = {func=func, tar=tar}
	end
end

function PetDetailDlg:setCloseCallFunc(func, tar)
	if func then
		self.closeCallFunc = {func=func, tar=tar}
	end
end

function PetDetailDlg:showSwitchPageArrow(isShow)
	self.lastBtn:setVisible(isShow)
	self.nextBtn:setVisible(isShow)
end

function PetDetailDlg.ShowPetDlg(petBaseId, petKey, ownerId)
	if _instance then
		_instance:setPetNotProtocol(petBaseId, petKey, ownerId)
	end
end

function PetDetailDlg:setPetNotProtocol(petBaseId, petKey, ownerId)
    self:GetWindow():setVisible(true)

	self.petKey = petKey
    self.ownerId = ownerId
   -- self.chatBtn:setVisible(ownerId ~= gGetDataManager():GetMainCharacterID())
	
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petBaseId)
    if petAttr then
        local imgPath = GetPetKindImageRes(petAttr.kind, petAttr.unusualid)
	    self.kindImg:setProperty("Image", imgPath)
		if petAttr.iszhenshou ==1 then
			self.kindImg:setProperty("Image", "set:cc25410 image:chongwu_shenshou")
				imgpath="set:cc25410 image:chongwu_shenshou"
		end
	    UseImageSourceSize(self.kindImg, imgPath)
	    self:addPetSprite(petAttr)
    end
end

--@ownerId 所有者id
function PetDetailDlg:setPet(petBaseId, petKey, ownerId)
    self.tmpKey = petKey
	
	--请求详细信息
	local p = require("protodef.fire.pb.shop.cmarketpettips"):new()
	p.roleid = ownerId
	p.key = petKey
	p.tipstype = PETTIPS_T.PET_DETAIL
	LuaProtocolManager:send(p)
end

--petData: stMainPetData
function PetDetailDlg:refreshPetData(petData)
	self:GetWindow():setVisible(true)
    self.tmpKey = nil

    self.petKey = petData.key
    self.ownerId = petData.ownerid
	
    self.petdye1 = petData.petdye1
    self.petdye2 = petData.petdye2
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if petAttr then
        local imgPath = GetPetKindImageRes(petAttr.kind, petAttr.unusualid)
        self.kindImg:setProperty("Image", imgPath)
		if petAttr.iszhenshou ==1 then
			self.kindImg:setProperty("Image", "set:cc25410 image:zhenshou")
				imgpath="set:cc25410 image:zhenshou"
		end
        UseImageSourceSize(self.kindImg, imgPath)
        self:addPetSprite(petAttr)
    end

	self.levelText:setText("" .. petData:getAttribute(fire.pb.attr.AttrType.LEVEL))---等级
	self.scoreText:setText(petData.score)
	
	--技能
	local skillnum = (petData and petData:getSkilllistlen() or 0)
	-- self.skillBoxes[17]:setVisible(skillnum==17)
	for i = 1, 24 do
		self.skillBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
			SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petData, true, skill.certification)
		end
	end
	
	local neidannum = (petData and petData:getInternallistlen() or 0)
	self.neidanBoxes[7]:setVisible(neidannum==7)
	for i = 1, 7 do
		self.neidanBoxes[i]:Clear()
		if i <= neidannum then
			local neidan = petData:getInternal(i)
			SetPetSkillBoxInfond(self.neidanBoxes[i], neidan.skillid, petData, true, neidan.certification)
		end
	end

	--资质
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if petAttr then
        if petAttr.kind == fire.pb.pet.PetTypeEnum.VARIATION then
            local nBaoBaoId = petAttr.thebabyid 
            local baobaoTable = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nBaoBaoId)
            if baobaoTable then
                petAttr = baobaoTable
            end
        end

	    local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
	    self.gongziBar:setText(curVal)
		self.cc_gongzi:setText(curVal)
	    self.gongziBar:setProgress((curVal-petAttr.attackaptmin)/(petAttr.attackaptmax-petAttr.attackaptmin))

	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
	    self.fangziBar:setText(curVal)
		self.cc_fangzi:setText(curVal)
	    self.fangziBar:setProgress((curVal-petAttr.defendaptmin)/(petAttr.defendaptmax-petAttr.defendaptmin))
	
	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
	    self.tiziBar:setText(curVal)
		self.cc_tizi:setText(curVal)
	    self.tiziBar:setProgress((curVal-petAttr.phyforceaptmin)/(petAttr.phyforceaptmax-petAttr.phyforceaptmin))
	
	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
	    self.faziBar:setText(curVal)
		self.cc_fazi:setText(curVal)
	    self.faziBar:setProgress((curVal-petAttr.magicaptmin)/(petAttr.magicaptmax-petAttr.magicaptmin))
	
	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
	    self.suziBar:setText(curVal)
		self.cc_suduzi:setText(curVal)
	    self.suziBar:setProgress((curVal-petAttr.speedaptmin)/(petAttr.speedaptmax-petAttr.speedaptmin))
	
	    curVal = math.floor(petData.growrate*1000) / 1000
        self.chengzhangBar:setText(curVal)
		self.cc_chengzhang:setText(curVal)
        if petAttr.growrate:size() > 1 then
			    local maxgrow = petAttr.growrate[petAttr.growrate:size()-1] - petAttr.growrate[0]
			    if maxgrow > 0 then
				    self.chengzhangBar:setProgress((math.floor(petData.growrate*1000) - petAttr.growrate[0]) / maxgrow)
                else
				    self.chengzhangBar:setProgress(1)
			    end
		end
    end
	
    self.zizhidanNum:setText(petData.aptaddcount .. "/10") 
    self.growItemUseNum:setText(petData.growrateaddcount .. "/5") 
	
	--属性
	self.hp:setText(petData:getAttribute(fire.pb.attr.AttrType.MAX_HP))
	self.phyAttack:setText(petData:getAttribute(fire.pb.attr.AttrType.ATTACK))
	self.phyDefend:setText(petData:getAttribute(fire.pb.attr.AttrType.DEFEND))
	self.magicAttack:setText(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_ATTACK))
	self.magicDefend:setText(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_DEF))
	self.speed:setText(petData:getAttribute(fire.pb.attr.AttrType.SPEED))
	self.tizhi:setText(petData:getAttribute(fire.pb.attr.AttrType.CONS))
	self.moli:setText(petData:getAttribute(fire.pb.attr.AttrType.IQ))
	self.power:setText(petData:getAttribute(fire.pb.attr.AttrType.STR))
	self.naili:setText(petData:getAttribute(fire.pb.attr.AttrType.ENDU))
	self.minjie:setText(petData:getAttribute(fire.pb.attr.AttrType.AGI))
	self.qianneng:setText(petData:getAttribute(fire.pb.attr.AttrType.POINT))
    self.allwaysLive:setVisible(false)
    self.life:setVisible(true)
	self.life:setText(petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE))
    if petAttr.life == -1 then
        self.allwaysLive:setVisible(true)
        self.life:setVisible(false)
    end
end

function PetDetailDlg:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local s = GetScreenSize()
	SetPositionOffset(tip:GetWindow(), s.width*0.5+50, s.height*0.5, 0, 0.5)
end

function PetDetailDlg:handleLastClicked(args)
	if self.switchCallFunc then
		self.switchCallFunc.func(self.switchCallFunc.tar, false)
	end
end

function PetDetailDlg:handleNextClicked(args)
	if self.switchCallFunc then
		self.switchCallFunc.func(self.switchCallFunc.tar, true)
	end
end

function PetDetailDlg:addPetSprite(petConf)
	if not self.sprite then
		local s = self.profileIcon:getPixelSize()
		self.sprite = gGetGameUIManager():AddWindowSprite(self.profileIcon, petConf.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, false)
	else
		self.sprite:SetModel(petConf.modelid)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end    
    if self.sprite and petConf then        
        if self.petdye1 ~= 0 then
            self.sprite:SetDyePartIndex(0,self.petdye1)
        else
            self.sprite:SetDyePartIndex(0,petConf.area1colour)
        end
        if self.petdye2 ~= 0 then
            self.sprite:SetDyePartIndex(1,self.petdye2)
        else
            self.sprite:SetDyePartIndex(1,petConf.area2colour)
        end
    end
	
	self.elapse = 0
	self.defaultActCurTimes = 0
	self.defaultActRepeatTimes = 3
	self.actType = eActionStand
end

function PetDetailDlg:handleSwitchSkillTypeTab()
	local selectedBtn = self.skillTypeTabBtn1:getSelectedButtonInGroup()
	
	if self.skillTypeTabBtn1 == selectedBtn then
		if not self.skillpanel:isVisible() then
			self.skillpanel:setVisible(true)
			self.neidanpanel:setVisible(false)
		end
	else
		if not self.neidanpanel:isVisible() then
			self.skillpanel:setVisible(false)
			self.neidanpanel:setVisible(true)
		end
	end
end

function PetDetailDlg:handleChatClicked(args)
    if not self.ownerId then
        return
    end
    gGetFriendsManager():RequestSetChatRoleID(self.ownerId)
	PetDetailDlg.DestroyDialog()
end

function PetDetailDlg:onEventAlphaChanged()
    if self:GetWindow():getAlpha() == 1.0 then
        self:GetWindow():moveToFront()
    end
end

function PetDetailDlg:update(dt)
	if not self.sprite then
		return
	end
	self.elapse = self.elapse+dt
	if self.elapse >= self.sprite:GetCurActDuration() then
		self.elapse = 0
		if self.actType == eActionStand then
			self.defaultActCurTimes = self.defaultActCurTimes+1
			if self.defaultActCurTimes == self.defaultActRepeatTimes then
				self.defaultActCurTimes = 0
				local idx = math.random(1, #RANDOM_ACT)
				self.actType = RANDOM_ACT[idx]
				self.sprite:PlayAction(self.actType)
			end
		else
			self.actType = eActionStand
			self.sprite:PlayAction(self.actType)
		end
	end
end

function PetDetailDlg:showCapturePet()
    local key = require "logic.pet.petpropertydlgnew".GetSelectedPetKey()
    if key > 0 then
        local petData = MainPetDataManager.getInstance():FindMyPetByID(key, 1)
        PetDetailDlg.ShowPetDlg(petData.baseid, petData.key, petData.ownerid)
        self:refreshPetData(petData)
    end
end

return PetDetailDlg

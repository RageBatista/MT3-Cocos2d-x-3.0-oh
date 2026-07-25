------------------------------------------------------------------
-- 宠物合成结果
------------------------------------------------------------------
require "logic.dialog"
local RANDOM_ACT = {
    eActionStand
}


PetCombineResultDlg = {}
setmetatable(PetCombineResultDlg, Dialog)
PetCombineResultDlg.__index = PetCombineResultDlg
local _instance

function PetCombineResultDlg.getInstance()
    if not _instance then
        _instance = PetCombineResultDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function PetCombineResultDlg.getInstanceAndShow()
    if not _instance then
        _instance = PetCombineResultDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function PetCombineResultDlg.getInstanceNotCreate()
    return _instance
end

function PetCombineResultDlg:DestroyDialog()
    if _instance then
        -- 在这里添加判断，确保动画实例存在才调用 stop() 方法
		_instance.cc_yjjx.animation:stop()
		_instance.cc_detailBtn.animation:stop()
		_instance.cc_closeBtn.animation:stop()
        if _instance.cc_AnimationInstance then 
           _instance.cc_AnimationInstance:stop()
           _instance.cc_AnimationInstance = nil 
        end
        if _instance.cc_AnimationInstance1 then 
           _instance.cc_AnimationInstance1:stop()
           _instance.cc_AnimationInstance1 = nil 
        end
        if _instance.cc_AnimationInstance2 then 
           _instance.cc_AnimationInstance2:stop()
           _instance.cc_AnimationInstance2 = nil 
        end
        if _instance.cc_AnimationInstance3 then 
           _instance.cc_AnimationInstance3:stop()
           _instance.cc_AnimationInstance3 = nil 
        end
        if _instance.cc_AnimationInstance4 then 
           _instance.cc_AnimationInstance4:stop()
           _instance.cc_AnimationInstance4 = nil 
        end
        if _instance.cc_AnimationInstance5 then 
           _instance.cc_AnimationInstance5:stop()
           _instance.cc_AnimationInstance5 = nil 
        end

        -- 停止所有按钮的动画实例
        for i = 1, #(_instance.cc_zezhaos) do
            if _instance.cc_zezhaos[i]  then  
                if _instance.cc_zezhaos[i].m_aniopen1  then 
                    _instance.cc_zezhaos[i].m_aniopen1:stop()
                    _instance.cc_zezhaos[i].m_aniopen1 = nil 
                end
                if _instance.cc_zezhaos[i].m_aniopen2  then
                    _instance.cc_zezhaos[i].m_aniopen2:stop()
                    _instance.cc_zezhaos[i].m_aniopen2 = nil
                end
            end
        end

        -- 销毁动画定义
        local aniMan = CEGUI.AnimationManager:getSingleton()
        if  _instance.animationOpen2 then
            aniMan:destroyAnimation(_instance.animationOpen2)
            _instance.animationOpen2 = nil
        end
        if  _instance.animationOpen5 then
            aniMan:destroyAnimation(_instance.animationOpen5)
            _instance.animationOpen5 = nil
        end 

        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function PetCombineResultDlg.ToggleOpenClose()
    if not _instance then
        _instance = PetCombineResultDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function PetCombineResultDlg.GetLayoutFileName()
    return "petpropertyjieguo_mtg.layout"
end

function PetCombineResultDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetCombineResultDlg)
    return self
end

function PetCombineResultDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function PetCombineResultDlg:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()
	self:GetWindow():setVisible(true) 
	
	-- 技能滑动窗口
    self.skillScroll = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyjieguo_mtg/skillScroll"))
	
	-- 体力资质
    self.tizi = winMgr:getWindow("petpropertyjieguo_mtg/tilizhi")
	
	-- 速度资质
    self.suzi = winMgr:getWindow("petpropertyjieguo_mtg/suduzhi")
	
	-- 攻击资质
    self.gongzi = winMgr:getWindow("petpropertyjieguo_mtg/gongjizhi")
	
	-- 法术资质
    self.fazi = winMgr:getWindow("petpropertyjieguo_mtg/falizhi")
	
	-- 防御资质
    self.fangzi = winMgr:getWindow("petpropertyjieguo_mtg/fangyuzhi")
	
	-- 宠物成长
    self.grow = winMgr:getWindow("petpropertyjieguo_mtg/chongwuzhi")
	
	-- 关闭按钮
    self.cc_closeBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyjieguo_mtg/text2bg/btnguanbi"))
	self:addButtonAnimation(self.cc_closeBtn, "studyBtnPress")
	self.cc_closeBtn:subscribeEvent("Clicked", PetCombineResultDlg.DestroyDialog, self)
	
	-- 查看详情
    self.cc_detailBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyjieguo_mtg/text2bg/chakanxq"))
	self:addButtonAnimation(self.cc_detailBtn, "studyBtnPress")
	self.cc_detailBtn:subscribeEvent("Clicked", PetCombineResultDlg.handleDetailClicked, self)
	
	-- 一键揭晓
	self.cc_yjjx = CEGUI.toPushButton(winMgr:getWindow("petpropertyjieguo_mtg/text2bg/yjjx"))
	self:addButtonAnimation(self.cc_yjjx, "studyBtnPress")
	self.cc_yjjx:subscribeEvent("Clicked", PetCombineResultDlg.handleCcyjjxbtn, self)
	
	-- 宠物模型
    self.profileIcon = winMgr:getWindow("petpropertyjieguo_mtg/text1bg/diwen/texiao")
	
	-- 宠物名称
    self.nameText = winMgr:getWindow("petpropertyjieguo_mtg/text1bg/title3/texthechong")
	
	-- 宠物等级
    self.levelText = winMgr:getWindow("petpropertyjieguo_mtg/text1bg/diwen/lv")
	
	-- 宠物评分
    self.scoreText = winMgr:getWindow("petpropertyjieguo_mtg/text1bg/diwen/textpingf2")
	
	-- 模型遮罩
	self.cc_zezhao1 = winMgr:getWindow("petpropertyjieguo_mtg/frame/zezhao1")
	self.cc_zezhao1:subscribeEvent("Clicked", PetCombineResultDlg.handleClickCczezhao1Pet, self)
	
	-- 资质遮罩
	self.cc_zezhao2 = winMgr:getWindow("petpropertyjieguo_mtg/frame/zezhao2")
	self.cc_zezhao2:subscribeEvent("Clicked", PetCombineResultDlg.handleClickCczezhao2Pet, self)

	-- 按钮显示/隐藏逻辑
	self.cc_yjjx:subscribeEvent("Clicked", function(args) -- 一键揭晓
	self.cc_yjjx:setVisible(false) -- 一键揭晓 隐藏
	
    self.cc_detailBtn:setVisible(false)--查看详情 隐藏
	self.cc_detailBtn:setVisible(true) --查看详情 显示
	
	self.cc_closeBtn:setVisible(false) --关闭 隐藏
	self.cc_closeBtn:setVisible(true)  --关闭 显示
    end, self)
	
	
	self.skillBoxes = {}
	self.cc_zezhaos = {}
    for i = 1, 24 do
        self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petpropertyjieguo_mtg/Skill"..i))
        self.skillBoxes[i]:subscribeEvent("MouseClick", PetCombineResultDlg.handleSkillClicked, self)
        self.skillBoxes[i]:SetBackGroupOnTop(true)
	local pButton = winMgr:createWindow("TaharezLook/ImageButton", "" .. i)
		pButton:setProperty("NormalImage", "set:cc2549 image:skell1")
		pButton:setProperty("PushedImage", "set:cc2549 image:skell1")
		pButton:setProperty("EnableClickAni", "False")
		pButton:setProperty("SoundResource", "cc.ogg") 
		pButton:setAlwaysOnTop(true)
		pButton:setID(i)
		pButton:setSize(CEGUI.UVector2(CEGUI.UDim(0,75), CEGUI.UDim(0,75)))
	local posi=self.skillBoxes[i]:getPosition()
		pButton:setPosition(CEGUI.UVector2(CEGUI.UDim(0,posi.x.offset-1), CEGUI.UDim(0,posi.y.offset-0)))
		pButton:subscribeEvent("Clicked", PetCombineResultDlg.OnClickMask, self)
		self.skillScroll:addChildWindow(pButton)
		self.cc_zezhaos[i]=pButton
	end

    self.skillScroll:EnableAllChildDrag(self.skillScroll)
	
end

function PetCombineResultDlg:handleClickCczezhao1Pet(args)
	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("hechongyidong111") 
    self.cc_AnimationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.cc_AnimationInstance:setTargetWindow(self.cc_zezhao1)
    self.cc_AnimationInstance:start()
end

function PetCombineResultDlg:handleClickCczezhao2Pet(args)
	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen1 = aniMan:getAnimation("ImageMoveRight") 
    self.cc_AnimationInstance1 = aniMan:instantiateAnimation(animationOpen1) 
    self.cc_AnimationInstance1:setTargetWindow(self.cc_zezhao2)
    self.cc_AnimationInstance1:start()
end

function PetCombineResultDlg:OnClickMask(args)
    local eventargs = CEGUI.toWindowEventArgs(args)
    local id = eventargs.window:getID()	
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen2 = aniMan:getAnimation("moxingdonghua")
    self.cc_zezhaos[id].m_aniopen1 = aniMan:instantiateAnimation(animationOpen2)
    self.cc_zezhaos[id].m_aniopen1:setTargetWindow(self.cc_zezhaos[id])
    self.cc_zezhaos[id].m_aniopen1:start()
end

function PetCombineResultDlg:handleCcyjjxbtn(args)
	local aniMan = CEGUI.AnimationManager:getSingleton()
	if self.cc_zezhao1:getAlpha()>0 then
	local animationOpen3 = aniMan:getAnimation("moxingdonghua") 
    self.cc_AnimationInstance3 = aniMan:instantiateAnimation(animationOpen3) 
    self.cc_AnimationInstance3:setTargetWindow(self.cc_zezhao1)
    self.cc_AnimationInstance3:start()
	end
	
    if self.cc_zezhao2:getAlpha()>0 then
	local animationOpen4 = aniMan:getAnimation("ImageMoveRight") 
    self.cc_AnimationInstance4 = aniMan:instantiateAnimation(animationOpen4) 
    self.cc_AnimationInstance4:setTargetWindow(self.cc_zezhao2)
    self.cc_AnimationInstance4:start()
	end
	
	for k,v in ipairs(self.cc_zezhaos) do
        if v:getAlpha()>0  then
            local aniMan = CEGUI.AnimationManager:getSingleton()
            local animationOpen5 = aniMan:getAnimation("moxingdonghua")
            v.m_aniopen2 = aniMan:instantiateAnimation(animationOpen5)
            v.m_aniopen2:setTargetWindow(v)
            v.m_aniopen2:start()
        end
    end
end

function PetCombineResultDlg:setPetData(petData)
    self.petData = petData
    local s = self.profileIcon:getPixelSize()
    self.sprite = gGetGameUIManager():AddWindowSprite(self.profileIcon, petData.shape, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, false)
    self.elapse = 0
    self.defaultActCurTimes = 0
    self.defaultActRepeatTimes = 3
    self.actType = eActionStand
    self.nameText:setText(petData.name)
    self.nameText:setProperty("TextColours", "ff553923")
    self.scoreText:setText(petData.score)
    self.levelText:setText(''..petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
    local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
    self.gongzi:setText(curVal)
    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
    self.fangzi:setText(curVal)
    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
    self.tizi:setText(curVal)
    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
    self.fazi:setText(curVal)
    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
    self.suzi:setText(curVal)
    curVal = math.floor(petData.growrate * 1000) / 1000
    self.grow:setText(curVal)
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if self.sprite and petAttr then
        if petData and petData.petdye1 ~= 0 then
            self.sprite:SetDyePartIndex(0, petData.petdye1)
        else
            self.sprite:SetDyePartIndex(0, petAttr.area1colour)
        end
        if petData and petData.petdye2 ~= 0 then
            self.sprite:SetDyePartIndex(1, petData.petdye2)
        else
            self.sprite:SetDyePartIndex(1, petAttr.area2colour)
        end
    end
    local skillnum = petData:getSkilllistlen()
    for i = 1, 16 do
        self.skillBoxes[i]:Clear()
        if i <= skillnum then
            local skill = petData:getSkill(i)
            SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petData, true)

        end
    end
end


function PetCombineResultDlg:handleDetailClicked(args)
    _instance:DestroyDialog()-- <---这里
    PetLabel.Show(1)
end

function PetCombineResultDlg:handleSkillClicked(args)
    local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
    if cell:GetSkillID() == 0 then
        return
    end
    local dlg = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
    local s = GetScreenSize()
    SetPositionOffset(dlg:GetWindow(), s.width * 0.5, s.height * 0.5, 1, 0.5)
end

function PetCombineResultDlg:update(dt)
    if not self.sprite then
        return
    end
    self.elapse = self.elapse + dt
    if self.elapse >= self.sprite:GetCurActDuration() then
        self.elapse = 0
        if self.actType == eActionStand then
            self.defaultActCurTimes = self.defaultActCurTimes + 1
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
return PetCombineResultDlg
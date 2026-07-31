------------------------------------------------------------------
-- 宠物属性
------------------------------------------------------------------
require "logic.dialog"
require "logic.pet.petaddpointdlg"
require "protodef.fire.pb.pet.cfreepet1"
require "logic.pet.petfreeconfirm"
require "logic.pet.petchangename"
require "logic.pet.petzbadd"
require "logic.pet.Addndpointintro"

local RANDOM_ACT = {
	eActionRun,
	eActionAttack,
	eActionMagic1
} 

PetPropertyDlgNew = {
	actType = eActionStand,
	elapse = 0,
	defaultActRepeatTimes = 3,
	defaultActCurTimes = 0
}
setmetatable(PetPropertyDlgNew, Dialog)
PetPropertyDlgNew.__index = PetPropertyDlgNew

local _instance
function PetPropertyDlgNew.getInstance()
	if not _instance then
		_instance = PetPropertyDlgNew:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetPropertyDlgNew.getInstanceAndShow()
	if not _instance then
		_instance = PetPropertyDlgNew:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetPropertyDlgNew.getInstanceNotCreate()
	return _instance
end

function PetPropertyDlgNew.DestroyDialog()
	if _instance then
		if _instance.sprite then
			_instance.sprite:delete()
			_instance.sprite = nil
			_instance.icon:getGeometryBuffer():setRenderEffect(nil)
		end
		gGetDataManager().m_EventMainPetAttributeChange:RemoveScriptFunctor(_instance.eventMainPetAttributeChange)
		gGetDataManager().m_EventPetNumChange:RemoveScriptFunctor(_instance.eventPetNumChange)
		gGetDataManager().m_EventPetDataChange:RemoveScriptFunctor(_instance.eventPetDataChange)
		--gGetDataManager().m_EventShowPetChange:RemoveScriptFunctor(_instance.eventShowPetChange)
		gGetDataManager().m_EventBattlePetStateChange:RemoveScriptFunctor(_instance.eventBattlePetStateChange)
		gGetDataManager().m_EventBattlePetDataChange:RemoveScriptFunctor(_instance.eventBattlePetDataChange)
		gGetDataManager().m_EventPetNameChange:RemoveScriptFunctor(_instance.eventPetNameChange)
		gGetDataManager().m_EventPetSkillChange:RemoveScriptFunctor(_instance.eventPetSkillChange)
		Dialog.OnClose(_instance)
		if not _instance.m_bCloseIsHide then
			_instance = nil
		end
	end
end

function PetPropertyDlgNew.ToggleOpenClose()
	if not _instance then
		_instance = PetPropertyDlgNew:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetPropertyDlgNew.GetLayoutFileName()
	return "petpropertynew.layout"
end

function PetPropertyDlgNew:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetPropertyDlgNew)
	return self
end

function PetPropertyDlgNew:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7) 
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

--[[function PetPropertyDlgNew:addButtonAnimation(button) 
---备用的按钮动画，后期调试
    local function playDownAnimation()
        local downAnimation = CEGUI.AnimationManager:getSingleton():getAnimation("ButtonDown")
        if downAnimation then
            local animInst = CEGUI.AnimationManager:getSingleton():instantiateAnimation(downAnimation)
            animInst:setTargetWindow(button)
            animInst:start()
        end
    end
  
    local function playUpAnimation()
        local upAnimation = CEGUI.AnimationManager:getSingleton():getAnimation("ButtonUp")
        if upAnimation then
            local animInst = CEGUI.AnimationManager:getSingleton():instantiateAnimation(upAnimation)
            animInst:setTargetWindow(button)
            animInst:start()
        end
    end
   ----按钮定义事件self:addButtonAnimation(self.equip)
    button:subscribeEvent("MouseButtonDown", playDownAnimation, self)
    button:subscribeEvent("MouseButtonUp", playUpAnimation, self)
end---]]

function PetPropertyDlgNew:handleToggleView(showcwgdjm)
    self.cwgdjm:setVisible(showcwgdjm)
end

function PetPropertyDlgNew:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ccharecterinfo = winMgr:getWindow("PetPropertyNew")
	self.attriView = winMgr:getWindow("PetPropertyNew/attriView")
	self.expBar = CEGUI.toProgressBar(winMgr:getWindow("PetPropertyNew/exp"))
	self.mpBar = CEGUI.toProgressBar(winMgr:getWindow("PetPropertyNew/mp"))
	self.hpBar = CEGUI.toProgressBar(winMgr:getWindow("PetPropertyNew/hp"))
	self.waigongHurt = winMgr:getWindow("PetPropertyNew/damage")
	self.waigongDefend = winMgr:getWindow("PetPropertyNew/defence")
	self.speed = winMgr:getWindow("PetPropertyNew/speed")
	self.neigongHurt = winMgr:getWindow("PetPropertyNew/agile")
	self.neigongDefend = winMgr:getWindow("PetPropertyNew/neifang")
	self.assignPointBtn = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/textbg1/btnshuxingfenpei"))
	self.addExpBtn = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/attriView/addExpBtn"))

	self.skillView = winMgr:getWindow("PetPropertyNew/skillView")
	self.neidanView = winMgr:getWindow("PetPropertyNew/neidanView")
	
	-- 图鉴
	self.m_btntujian = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/tujian1"))
	self.m_btntujian:setText(MHSD_UTILS.get_resstring(7908))
	self:addButtonAnimation(self.m_btntujian, "xstudyBtnPress")
	
	-- 炼妖
	self.lianyaoBtn = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/peiyang"))
	self.lianyaoBtn:setText(MHSD_UTILS.get_resstring(7909))
	self:addButtonAnimation(self.lianyaoBtn, "xstudyBtnPress")
	
	-- 培养
	self.peiyangBtn = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/peiyang1"))
	self.peiyangBtn:subscribeEvent("Clicked", PetPropertyDlgNew.handlelianyaoClicked1, self)
	self:addButtonAnimation(self.peiyangBtn, "stucwdyBtnPress")
	
    -- 改名	
    self.changeNameBtn = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/changename"))
	self.changeNameBtn:subscribeEvent("Clicked", function() self:handleToggleView(false) PetPropertyDlgNew.handleChangeNameOnClicked(self) end, self)
	
	-- 放生
	self.freeBtn = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/free"))
	self.freeBtn:subscribeEvent("Clicked", function() self:handleToggleView(false) PetPropertyDlgNew.handleFreeBtnOnClicked(self) end, self)
	
	-- 染色
	self.cc_petrs = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/ranse")) 
	self.cc_petrs:subscribeEvent("MouseClick", function() self:handleToggleView(false) PetPropertyDlgNew.handleranseClicked(self) end, self)
	
	-- 进阶
	self.cc_petjj = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/jinjie"))
	self.cc_petjj:subscribeEvent("Clicked", function() self:handleToggleView(false) PetPropertyDlgNew.shenshoujinjie(self) end, self)
	
	-- 幻化
	self.cc_pethh = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/huanhua")) 
	self.cc_pethh:subscribeEvent("Clicked", function() self:handleToggleView(false) PetPropertyDlgNew.pethuanhua(self) end, self) 
	
	-- 跟随
	self.cc_petgs = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/gensui"))
	-- self.cc_petgs:subscribeEvent("Clicked", PetPropertyDlgNew.handlegensuiOnClicked, self)
	self.cc_petgs:subscribeEvent("Clicked", function() self:handleToggleView(false) PetPropertyDlgNew.handlegensuiOnClicked(self) end, self) 
	-- 收回
	self.cc_petsh = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/shouhui"))
	-- self.cc_petsh:subscribeEvent("Clicked", PetPropertyDlgNew.handleshouhuiOnClicked, self)
	self.cc_petsh:subscribeEvent("Clicked", function() self:handleToggleView(false) PetPropertyDlgNew.handleshouhuiOnClicked(self) end, self) 
	-- 进阶/界面按钮


	-- 染色/界面按钮
	
	-- 评分
	self.scoreText = winMgr:getWindow("PetPropertyNew/scoreText")

	self.waigongzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar0"))
	self.fangyuzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar1"))
	self.tilizizhiBar = CEGUI.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar2"))
	self.neigongzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar3"))
	self.suduzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar4"))
	self.growBar = CEGUI.toProgressBar(winMgr:getWindow("PetPropertyNew/text2bg/barchengzhang"))
	self.lifeText = winMgr:getWindow("PetPropertyNew/text2bg/chongwushoumingshuzi")
    self.allwaysLive = winMgr:getWindow("PetPropertyNew/text2bg/chongwushoumingshuzi1")
	self.skillScroll = CEGUI.toScrollablePane(winMgr:getWindow("PetPropertyNew/skillView/skillScroll"))
	
	self.fightBtn = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/fight"))
    self.equip = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/equip"))
	self.attrBtn = CEGUI.toGroupButton(winMgr:getWindow("PetPropertyNew/infoback/info1"))
	self.skillBtn = CEGUI.toGroupButton(winMgr:getWindow("PetPropertyNew/infoback/info2"))
	self.neidanBtn = CEGUI.toGroupButton(winMgr:getWindow("PetPropertyNew/infoback/info3"))
    self.shipin = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/shipin"))
	self.nameText = winMgr:getWindow("PetPropertyNew/icon/type")
	self.icon = winMgr:getWindow("PetPropertyNew/icon")
	self.levelText = winMgr:getWindow("PetPropertyNew/level")
	self.typeImg = winMgr:getWindow("PetPropertyNew/icon/kindImg")
	self.petScroll = CEGUI.toScrollablePane(winMgr:getWindow("PetPropertyNew/pets/petScroll"))
    self.fightLevelText = winMgr:getWindow("PetPropertyNew/canzhan1")
	self.shareBtn = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/btnfenxiang"))
	self.hcbtn = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/neidanView/hcbtn"))
    self.xiangquan = CEGUI.toItemCell(winMgr:getWindow("PetPropertyNew/attriView/zhuangbeikuang/xiangquan"))
	self.hujia = CEGUI.toItemCell(winMgr:getWindow("PetPropertyNew/attriView/zhuangbeikuang/hujia"))
	self.hufu = CEGUI.toItemCell(winMgr:getWindow("PetPropertyNew/attriView/zhuangbeikuang/hufu"))
	self.toubox = CEGUI.toSkillBox(winMgr:getWindow("PetPropertyNew/attriView/zhuangbeikuang/tan1"))
	self.yibox = CEGUI.toSkillBox(winMgr:getWindow("PetPropertyNew/attriView/zhuangbeikuang/tan2"))
	self.hubox = CEGUI.toSkillBox(winMgr:getWindow("PetPropertyNew/attriView/zhuangbeikuang/tan3"))
	
    self.cwgdjm = winMgr:getWindow("PetPropertyNew/profileView/cwgdsx")
    self.cwgdjm:setVisible(false)
    self.cc_xxgda = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/xiangxiagda"))

    self.cc_xxgda:subscribeEvent("Clicked", function() 
        self:handleToggleView(true) 
    end, self)
	self:addButtonAnimation(self.cc_xxgda, "stucwdyBtnPress")

    self:GetWindow():subscribeEvent("MouseButtonUp", PetPropertyDlgNew.OnLButtonUp, self)
	
	self.skillScroll2 = CEGUI.toScrollablePane(winMgr:getWindow("PetPropertyNew/skillView/skillScroll2"))
	self.skillTypeTabBtn1 = CEGUI.toGroupButton(winMgr:getWindow("PetPropertyNew/skillView/skilltab1"))
	self.skillTypeTabBtn2 = CEGUI.toGroupButton(winMgr:getWindow("PetPropertyNew/skillView/skilltab2"))
	self.chongwushizhuang = CEGUI.toPushButton(winMgr:getWindow("PetPropertyNew/shizhuang"))   --时装图标

    if MT3.ChannelManager:IsAndroid() == 1 then
        if Config.IsLocojoy() then
            self.shareBtn:setVisible(true)
        else
            self.shareBtn:setVisible(false)
        end
    end

    -- windows �汾���η���
    if Config.IsWinApp() then
        self.shareBtn:setVisible(false)
    end

    self.shareBtn:subscribeEvent("Clicked", PetPropertyDlgNew.handleShareClick, self)
	self.hcbtn:subscribeEvent("Clicked", PetPropertyDlgNew.handleHeChengClick, self)

				self:GetCloseBtn():removeEvent("Clicked")
				self:GetCloseBtn():subscribeEvent("Clicked", PetLabel.hide, nil)
				self:GetCloseBtn():subscribeEvent("Clicked", PetAddZb.CloseIfExist, nil)
				self:GetCloseBtn():subscribeEvent("Clicked", PetPropertyDlgNew.Closetips, nil)
				
				self.fightBtn:subscribeEvent("Clicked", PetPropertyDlgNew.handleFightBtnOnClicked, self)--参战
				self:addButtonAnimation(self.fightBtn, "stucwdyBtnPress")
				
				
				self.attrBtn:subscribeEvent("SelectStateChanged", PetPropertyDlgNew.handleSwitchAtrriAndSkillView, self)
				self.skillBtn:subscribeEvent("SelectStateChanged", PetPropertyDlgNew.handleSwitchAtrriAndSkillView, self)
				
				self.neidanBtn:subscribeEvent("SelectStateChanged", PetPropertyDlgNew.handleSwitchAtrriAndSkillView, self)
				self.assignPointBtn:subscribeEvent("Clicked", PetPropertyDlgNew.handleAssignPointClicked, self)----加点
				self:addButtonAnimation(self.assignPointBtn, "stucwdyBtnPress")
				
				self.addExpBtn:subscribeEvent("Clicked", PetPropertyDlgNew.handleAddExpClicked, self)
				self.lianyaoBtn:subscribeEvent("Clicked", PetPropertyDlgNew.handlelianyaoClicked, self)
				
				
				self.shipin:subscribeEvent("Clicked", PetPropertyDlgNew.handleshipinOnClicked, self)
				self.skillTypeTabBtn1:subscribeEvent("SelectStateChanged", PetPropertyDlgNew.handleSwitchSkillTypeTab, self)
				self.skillTypeTabBtn2:subscribeEvent("SelectStateChanged", PetPropertyDlgNew.handleSwitchSkillTypeTab, self)
				self.xiangquan:subscribeEvent("MouseClick", PetPropertyDlgNew.makepetxiangquantips, self)
				self.hujia:subscribeEvent("MouseClick", PetPropertyDlgNew.makepethujiatips, self)
				self.m_btntujian:subscribeEvent("MouseClick", self.HandleBtntujianClick, self);
				self.hufu:subscribeEvent("MouseClick", PetPropertyDlgNew.makepethufutips, self)

				self.equip:subscribeEvent("MouseClick", PetPropertyDlgNew.handleAddSkillClicked, self)---装备
				self:addButtonAnimation(self.equip, "stucwdyBtnPress")
				self.chongwushizhuang:subscribeEvent("MouseClick", PetPropertyDlgNew.handleshizhuangClicked, self)
				self.petScroll:EnableAllChildDrag(self.petScroll)
				self.skillScroll:EnableAllChildDrag(self.skillScroll)
				self.skillView:setVisible(false)
				self.skillScroll2:EnableAllChildDrag(self.skillScroll2)
				self.skillScroll2:setVisible(false)
				if self.xiangquan:isVisible() then 
				self.xiangquan:SetBackGroundImage("ccui1", "kuang2")
				self.xiangquan:SetImage("renwuui","toubu")
				end
				if self.hujia:isVisible() then 
				self.hujia:SetBackGroundImage("ccui1", "kuang2")
				self.hujia:SetImage("renwuui","yifu")
				end
				if self.hufu:isVisible() then 
				self.hufu:SetBackGroundImage("ccui1", "kuang2")
				self.hufu:SetImage("renwuui","shipin")
				end	
				self.skillBoxes = {}
				for i=1,PET_SKILL_NORCOUNT do
					self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("PetPropertyNew1/Skill" .. i))
					self.skillBoxes[i]:subscribeEvent("MouseClick", PetPropertyDlgNew.handleSkillClicked, self)
					self.skillBoxes[i]:SetBackGroupOnTop(true)
				end
				
	-- self.skillBoxes2 = {}
	-- for i=1,PET_INTERNAL_NORCOUNT do
	-- 	self.skillBoxes2[i] = CEGUI.toSkillBox(winMgr:getWindow("PetPropertyNew2/Skill" .. i))
	-- 	self.skillBoxes2[i]:subscribeEvent("MouseClick", PetPropertyDlgNew.handleSkillClicked, self)
    --     self.skillBoxes2[i]:SetBackGroupOnTop(true)
	-- end
    self.skillBoxes2 = {}
	for i=1,PET_NEIDAN_COUNT do
		--print(PET_INTERNAL_NORCOUNT)
		self.skillBoxes2[i] = CEGUI.toSkillBox(winMgr:getWindow("PetPropertyNew2/Skill" .. i))
		self.skillBoxes2[i]:subscribeEvent("MouseClick", PetPropertyDlgNew.handleSkill2Clicked, self)
        self.skillBoxes2[i]:SetBackGroupOnTop(true)
		 --self.skillBoxes2[i]:setEnabled(false);
		 self.skillBoxes2[i]:setID(i)
	end
	
	self.suo =	winMgr:getWindow("PetPropertyNew/suo")
	self.suo:subscribeEvent("MouseClick", PetPropertyDlgNew.handleSuClicked, self)
	
	self.skillBox2Name={}
	for i=1,PET_NEIDAN_COUNT do
		self.skillBox2Name[i] = winMgr:getWindow("PetPropertyNew/name" .. i)
	end
	
    self.m_petList = {}
    self.petlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("PetPropertyNew/pets/petScroll"));
    self.petlistWnd:EnableHorzScrollBar(false)

	local defaultPet = MainPetDataManager.getInstance():GetBattlePet() or MainPetDataManager.getInstance():getPet(1)
	self:refreshSelectedPet(defaultPet)
	self:refreshPetTable()
		
	self.eventMainPetAttributeChange = gGetDataManager().m_EventMainPetAttributeChange:InsertScriptFunctor(PetPropertyDlgNew.handleEventMainPetRefresh)
	self.eventPetNumChange = gGetDataManager().m_EventPetNumChange:InsertScriptFunctor(PetPropertyDlgNew.handleEventMainPetRefresh) --PetNumChange)
	self.eventPetDataChange = gGetDataManager().m_EventPetDataChange:InsertScriptFunctor(PetPropertyDlgNew.handleEventPetDataChange)
	self.eventBattlePetStateChange = gGetDataManager().m_EventBattlePetStateChange:InsertScriptFunctor(PetPropertyDlgNew.handleEventPetBattleStateChange)
	self.eventBattlePetDataChange = gGetDataManager().m_EventBattlePetDataChange:InsertScriptFunctor(PetPropertyDlgNew.handleEventMainPetRefresh)
	self.eventPetNameChange = gGetDataManager().m_EventPetNameChange:InsertScriptFunctor(PetPropertyDlgNew.handleEventPetDataChange)
	self.eventPetSkillChange = gGetDataManager().m_EventPetSkillChange:InsertScriptFunctor(PetPropertyDlgNew.handleEventPetSkillChange)
end

function PetPropertyDlgNew:OnLButtonUp()
    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if self.cwgdjm:isVisible() and targetWnd ~= self.cwgdjm and not targetWnd:isAncestor(self.cwgdjm) then
        self:handleToggleView(false)
    end
end

function PetPropertyDlgNew:OnLButtonDown()
    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if self.cwgdjm:isVisible() and  not targetWnd:isAncestor(self.cwgdjm) then
        self:handleToggleView(false)
    end
end

function PetPropertyDlgNew:handleSuClicked()

	
GetCTipsManager():AddMessageTip('宠物等级70开启专属内丹');
end
			
function PetPropertyDlgNew.Closetips()
require("logic.tips.petequiptips").getInstance().DestroyDialog()
end
			
function PetPropertyDlgNew:HandleBtntujianClick(args)-- 宠物图鉴
require "logic.pet.petgallerydlg"
PetGalleryDlg.getInstanceAndShow()
end	

function PetPropertyDlgNew:HandleBtnpeiyangClick(args)-- 宠物培养
require "logic.pet.PetFeedDlg"
PetFeedDlg.getInstanceAndShow()
end	

function PetPropertyDlgNew:shenshoujinjie(args) -- 神兽进阶
    if self.selectedPetKey then
        local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
        if petData and petData.kind == 4 then  -- 是否神兽
            require "logic.pet.shenshouIncrease".getInstanceAndShow()
        else
            GetCTipsManager():AddMessageTipById(126005)  -- 只有神兽可以进阶
        end
    end
end

function PetPropertyDlgNew:handleranseClicked(args)-- 染色界面
    if self.selectedPetKey then  
        local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
        if petData and petData.kind ~= 4 then  -- 是否神兽
            debugrequire"logic.ranse.charactershizhuangdlg".getInstanceAndShow().Show(3) 
        else
            GetCTipsManager():AddMessageTipById(126006) -- 神兽无法染色哦
        end
    end 
end

function PetPropertyDlgNew:pethuanhua(args)-- 幻化界面
    PetAddZb.CloseIfExist()
    PetPropertyDlgNew.Closetips()
    if self.selectedPetKey == gGetDataManager():GetBattlePetID() then
        GetCTipsManager():AddMessageTipById(192819)
        return
    end

    local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
    if petData then
        if petData and petData.kind == 4 then  -- 宠物类型为4
            local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
            if petAttr.iszhenshou == 1 then -- 是否珍兽
                local dlg = require('logic.pet.pethuanhuadlg').getInstanceAndShow()
                dlg:setPetAttr(petAttr, self.selectedPetKey)
            else
                GetCTipsManager():AddMessageTipById(126007) -- 珍兽才可以幻化
            end
        else
            GetCTipsManager():AddMessageTipById(126007) -- 珍兽才可以幻化
        end
    end
end

function PetPropertyDlgNew:releasePetIcon()   
    local sz = #self.m_petList
    for index  = 1, sz do
        local lyout = self.m_petList[1]
        lyout.addclick = nil
        lyout.NameText = nil
        lyout.LevelText = nil
        lyout.petCell = nil
        lyout.chuzhan = nil
        lyout.dengji = nil
        self.petlistWnd:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_petList,1)
	end
    if self.addPetButton then
        local lyout = self.addPetButton
        lyout.addclick = nil
        lyout.NameText = nil
        lyout.LevelText = nil
        lyout.petCell = nil
        lyout.chuzhan = nil
        lyout.dengji = nil
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        self.addPetButton = nil
    end
end

function PetPropertyDlgNew.getBattlePet()
	if _instance then
	local num = MainPetDataManager.getInstance():GetPetNum()
	local petInfo
	for i = 1, num  do
	petInfo = MainPetDataManager.getInstance():getPet(i)
	if petInfo.key == gGetDataManager():GetBattlePetID() then
	NewRoleGuideManager.getInstance():setLuaGetWindow(tolua.cast(_instance.m_petList[i], "CEGUI::Window"))
			end
		end
	end
end
				
function PetPropertyDlgNew:SetTou(id)--设置宠物装备图片
  if  id > 0 then 
	local item =  BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
	self.xiangquan:SetImage(gGetIconManager():GetItemIconByID(item.icon))
	SetItemCellBoundColorByQulityItemcwzbk(self.xiangquan,item.nquality)
	else 
	self.xiangquan:SetImage("ccui1","huwan")
	self.xiangquan:SetBackGroundImage("ccui1", "kuang2")
end
end

function PetPropertyDlgNew:SetYi(id)--设置宠物装备图片
	if  id > 0 then 
	local item =  BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
	self.hujia:SetImage(gGetIconManager():GetItemIconByID(item.icon))
	SetItemCellBoundColorByQulityItemcwzbk(self.hujia,item.nquality)
	else 
	self.hujia:SetImage("ccui1","kaijia")
	self.hujia:SetBackGroundImage("ccui1", "kuang2")
	end
end
			
function PetPropertyDlgNew:SetHu(id)--设置宠物装备图片
	if  id > 0 then 
	local item =  BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(id)
	self.hufu:SetImage(gGetIconManager():GetItemIconByID(item.icon))
	SetItemCellBoundColorByQulityItemcwzbk(self.hufu,item.nquality)
	else 
	self.hufu:SetImage("ccui1","xiangquan")
	self.hufu:SetBackGroundImage("ccui1", "kuang2")
end
end

function PetPropertyDlgNew:refreshPetEqiupList(petkey)--获取宠物装备列表
	if petkey > 0 then
	local p = require"protodef.fire.pb.pet.cgetpetequiplist":new()
	p.petkey = petkey
	LogInfo("petneedid"..p.petkey)
	LuaProtocolManager:send(p)
    end
end
			
function PetPropertyDlgNew:makepetxiangquantips()--获取宠物装备tips
    PetAddZb.DestroyDialog()
	local petkey = self.GetSelectedPetKey()
	if petkey > 0 then
	local p = require"protodef.fire.pb.pet.cgetpetequipinfo":new()
	p.petkey = petkey
	p.pos=1
	LuaProtocolManager:send(p)
	end
end

function PetPropertyDlgNew:makepethujiatips()--获取宠物装备tips
	PetAddZb.DestroyDialog()
	local petkey = self.GetSelectedPetKey()
	if petkey > 0 then
	local p = require"protodef.fire.pb.pet.cgetpetequipinfo":new()
	p.petkey = petkey
	p.pos=2
	LuaProtocolManager:send(p)
end
end

function PetPropertyDlgNew:makepethufutips()--获取宠物装备tips
	PetAddZb.DestroyDialog()
	local petkey = self.GetSelectedPetKey()
	if petkey > 0 then
	local p = require"protodef.fire.pb.pet.cgetpetequipinfo":new()
	p.petkey = petkey
	p.pos=3
	LuaProtocolManager:send(p)
	end
end
			
function PetPropertyDlgNew:handleAddSkillClicked()
	PetAddZb.getInstanceAndShow(self.selectedPetKey)
--debugrequire('logic.pet.petzbadd').getInstanceAndShow(self.selectedPetKey)
end

function PetPropertyDlgNew.getNewPet()
    if _instance then
    local num = MainPetDataManager.getInstance():GetPetNum()
    --NewRoleGuideManager.getInstance():setLuaGetWindow(_instance.petTable:GetCell(num-1))
    NewRoleGuideManager.getInstance():setLuaGetWindow(_instance.m_petList[num])
    end
end

function PetPropertyDlgNew:handleShareClick(arg)
    require "logic.share.sharedlg".SetShareType(SHARE_TYPE_PET)
    require "logic.share.sharedlg".SetShareFunc(SHARE_FUNC_CAPTURE)
    require "logic.share.sharedlg".getInstanceAndShow()
end

function PetPropertyDlgNew:handleHeChengClick(e)
	if Addndpointintro.getInstanceNotCreate() then
		Addndpointintro.DestroyDialog()
		return
	end
	local dlg = Addndpointintro.getInstanceAndShow(self.ccharecterinfo);
 
end

function PetPropertyDlgNew:refreshAll(petData)
	self:refreshSelectedPet(petData)
	self:refreshPetTable()
    if NewRoleGuideManager.getInstance():getCurGuideId() == 33150 then
        self.attrBtn:setSelected(true)
        self.attriView:setVisible(true)
	    self.skillView:setVisible(false)
    end
end

function PetPropertyDlgNew.handleEventMainPetRefresh()
	if not _instance or not _instance:IsVisible() then
		return
	end
     

	_instance:refreshPetTableData()
	local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.selectedPetKey)
    if not petData then
        petData = MainPetDataManager.getInstance():getPet(1)
        --[[if petData then
            --_instance.petTable:GetCell(0):SetSelected(true)
            _instance.m_petList[1].addclick:setSelected(true)
        end]]--
    end
	_instance:refreshSelectedPet(petData) 

				local num = MainPetDataManager.getInstance():GetPetNum()
				if num==0 then
					local petLabel = PetLabel.getInstanceNotCreate()
					if petLabel then
						petLabel:ShowOnly(4)
					end
					
				end

			end
			function PetPropertyDlgNew:handleshipinOnClicked(args)
				if GetBattleManager():IsInBattle() then
					GetCTipsManager():AddMessageTipById(131451)
				elseif self.selectedPetKey then
					if MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey) then
					local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
						local dlg = PetShiPin.getInstanceAndShow()
						dlg:setPetKey(petData.key)
					end
				end
			end
			function PetPropertyDlgNew.handleEventPetBattleStateChange()
				if not _instance or not _instance:IsVisible() then
					return
				end
				_instance:refreshPetTableData()
				local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.selectedPetKey)
				_instance:refreshSelectedPet(petData)
			end

function PetPropertyDlgNew.handleEventPetDataChange(key)
    if not _instance or not _instance:IsVisible() then
        return
    end
    _instance:refreshPetTableData()
    if _instance.selectedPetKey == key then
        local petData = MainPetDataManager.getInstance():FindMyPetByID(key)
        _instance:refreshSelectedPet(petData)

        -- 添加这两行来刷新加点相关界面元素
        _instance:refreshAtrriView(petData)
        _instance:refreshSkillView(petData) 
    end
end

function PetPropertyDlgNew.handleEventPetSkillChange(key)
	if not _instance or not _instance:IsVisible() then
		return
	end
	if _instance.selectedPetKey == key then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(key)
		_instance:refreshSkillView(petData)
	end
end

function PetPropertyDlgNew:refreshPetTable()    
    self:releasePetIcon()
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 0.1;
    local sy = 0.1;
    self.m_petList = {}
    local index = 0
    local fightid = gGetDataManager():GetBattlePetID()
    for i = 1, MainPetDataManager.getInstance():GetPetNum() do
		local petData = MainPetDataManager.getInstance():getPet(i)
        local sID = "PetPropertyDlgNew" .. tostring(index)
        local lyout = winMgr:loadWindowLayout("petcell1.layout",sID);
        self.petlistWnd:addChildWindow(lyout)
	   
        local xindex = (index)%5
        local yindex = math.floor((index)/5)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (lyout:getWidth().offset)), CEGUI.UDim(0.0, sy + yindex * (lyout:getHeight().offset))))
        --lyout:setID(index)
        lyout.key = petData.key

        lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
        lyout.addclick:setID(index)
	    lyout.addclick:subscribeEvent("MouseButtonUp", PetPropertyDlgNew.handlePetIconSelected, self)

        if petData.key == self.selectedPetKey then
            lyout.addclick:setSelected(true)
        end
                    
        lyout.NameText = winMgr:getWindow(sID.."petcell/name")
        lyout.NameText:setText(petData.name)
        
        lyout.LevelText = winMgr:getWindow(sID.."petcell/number")
        lyout.LevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))        

        lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."petcell/touxiang"))   
        SetPetItemCellInfo2(lyout.petCell, petData) 

        lyout.chuzhan = winMgr:getWindow(sID.."petcell/zhan")
        lyout.chuzhan:setVisible(false)    

        lyout.addtext = winMgr:getWindow(sID.."petcell/name1")
        lyout.addtext:setVisible(false)

        if fightid == petData.key then
            lyout.chuzhan:setVisible(true) 
        end
        table.insert(self.m_petList, lyout)
        index = index + 1
    end
    self:refreshAddPetBtn(index)
end
function PetPropertyDlgNew:refreshAddPetBtn(index) 
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;      
    if not MainPetDataManager.getInstance():IsMyPetFull() then
        if self.addPetButton == nil then  
            local sID = "PetPropertyDlgNewAdd"
            local lyout = winMgr:loadWindowLayout("petcell1.layout",sID);
            self.petlistWnd:addChildWindow(lyout)
            lyout:setID(index)
            lyout.key = -1

            lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
            lyout.addclick:setID(index)
	        lyout.addclick:subscribeEvent("MouseButtonUp", PetPropertyDlgNew.handleLockedPetIconClicked, self)
                    
            lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."petcell/touxiang"))  
		    lyout.petCell:Clear()
            lyout.petCell:setID(index)
	        lyout.petCell:subscribeEvent("MouseButtonUp", PetPropertyDlgNew.handleLockedPetIconClicked, self)
            local abtn = winMgr:getWindow(sID.."petcell/touxiang/jiahao")
            abtn:setVisible(true)

            lyout.NameText = winMgr:getWindow(sID.."petcell/name")   
            lyout.NameText:setVisible(false)      
            lyout.LevelText = winMgr:getWindow(sID.."petcell/number")  
            lyout.LevelText:setVisible(false)      
            lyout.chuzhan = winMgr:getWindow(sID.."petcell/zhan")
            lyout.chuzhan:setVisible(false) 
            lyout.dengji = winMgr:getWindow(sID.."petcell/dengji")
            lyout.dengji:setVisible(false)        
            lyout.addtext = winMgr:getWindow(sID.."petcell/name1")
            lyout.addtext:setVisible(true)        

            self.addPetButton = lyout 
        end
    else
        if self.addPetButton ~= nil then
            local lyout = self.addPetButton
            lyout.addclick = nil
            lyout.NameText = nil
            lyout.LevelText = nil
            lyout.petCell = nil
            lyout.chuzhan = nil
            lyout.dengji = nil
	        CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
            self.addPetButton = nil
        end
    end
    if self.addPetButton then
        local xindex = (index)%5
        local yindex = math.floor((index)/5)
	    self.addPetButton:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (self.addPetButton:getWidth().offset)), CEGUI.UDim(0.0, sy + yindex * (self.addPetButton:getHeight().offset))))
    end
    local a = NewRoleGuideManager.getInstance():getCurGuideId()
    if NewRoleGuideManager.getInstance():getCurGuideId() == 33190 then
        self:petGuideHandle()
    end
end
function PetPropertyDlgNew:refreshPetTableData() 

	local winMgr = CEGUI.WindowManager:getSingleton()
    local fightid = gGetDataManager():GetBattlePetID()
    local sz = MainPetDataManager.getInstance():GetPetNum()
    local index = 0
    local sx = 0.1;
    local sy = 0.1;   
    local bSelect = false   
    for i = 1, sz do
		local petData = MainPetDataManager.getInstance():getPet(i)
        local lyout = self.m_petList[i]
        if lyout == nil then
            local sID = "PetPropertyDlgNew" .. tostring(index)
            lyout = winMgr:loadWindowLayout("petcell1.layout",sID);
            self.petlistWnd:addChildWindow(lyout)
            lyout.key = petData.key            
            lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
            lyout.addclick:setID(index)
	        lyout.addclick:subscribeEvent("MouseButtonUp", PetPropertyDlgNew.handlePetIconSelected, self)          
            lyout.NameText = winMgr:getWindow(sID.."petcell/name")        
            lyout.LevelText = winMgr:getWindow(sID.."petcell/number")
            lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."petcell/touxiang")) 
            lyout.chuzhan = winMgr:getWindow(sID.."petcell/zhan")
            lyout.addtext = winMgr:getWindow(sID.."petcell/name1")
            lyout.addtext:setVisible(false)
            table.insert(self.m_petList, lyout)
        end
        if petData.key == self.selectedPetKey then
            local btn = CEGUI.toGroupButton(lyout.addclick)
            btn:setSelected(true)
            bSelect = true
        end          
        local xindex = (index)%5
        local yindex = math.floor((index)/5)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (lyout:getWidth().offset)), CEGUI.UDim(0.0, sy + yindex * (lyout:getHeight().offset))))
           
        lyout.NameText:setText(petData.name)        
        lyout.LevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))     
        SetPetItemCellInfo2(lyout.petCell, petData) 
        if fightid == petData.key then
            lyout.chuzhan:setVisible(true) 
        else
            lyout.chuzhan:setVisible(false) 
        end
        lyout:setVisible(true) 
        index = index + 1
    end 
    for i = #self.m_petList, index+1, -1 do
        local lyout = self.m_petList[i]
        lyout.addclick = nil
        lyout.NameText = nil
        lyout.LevelText = nil
        lyout.petCell = nil
        lyout.chuzhan = nil
        lyout.dengji = nil
        self.petlistWnd:removeChildWindow(lyout)
	    CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
        table.remove(self.m_petList,i)
    end
    self:refreshAddPetBtn(index)

    if bSelect ~= true and sz > 0 then
        local btn = CEGUI.toGroupButton(self.m_petList[1].addclick)
        btn:setSelected(true)
    end
end

function PetPropertyDlgNew:refreshSelectedPet(petData)
	if petData then
		self.selectedPetKey = petData.key
		if gGetDataManager():GetBattlePetID() == petData.key then
			self.fightBtn:setText(MHSD_UTILS.get_resstring(2117)) --��Ϣ
		else
			self.fightBtn:setText(MHSD_UTILS.get_resstring(2118)) --��ս
		end
	else
		self.selectedPetKey = 0
	end
	--if petData.kind ==2 or petData.kind ==3 or petData.kind ==4 then
	if petData:getAttribute(fire.pb.attr.AttrType.LEVEL) > 70 then
		self.suo:setVisible(false)
		self.skillBoxes2[5]:setVisible(true)
	else
		self.suo:setVisible(true)
		self.skillBoxes2[5]:setVisible(false)
	end
	
	self:refreshProfileView(petData)
	self:refreshAtrriView(petData)
	self:refreshSkillView(petData)
	PetLabel.getInstance():setSelectedPetKey(self.selectedPetKey)
end

function PetPropertyDlgNew.GetSelectedPetKey()
    if _instance then
        return _instance.selectedPetKey
    else
        return 0
    end
end

function PetPropertyDlgNew:refreshProfileView(petData)
    local petAttr
    if petData then
        --self.nameText:setProperty("TextColours", GetPetNameColour(petData.baseid))-- 原始
		self.nameText:setProperty("TextColours", "FF50321A")-- 宠物界面名字颜色
        petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petAttr then
            local imgpath = GetPetKindImageRes(petAttr.kind, petAttr.unusualid)
            self.typeImg:setVisible(true)
			self.typeImg:setProperty("Image", imgpath)
		   
            UseImageSourceSize(self.typeImg, imgpath)
        end
    else
		self.typeImg:setVisible(false)
    end
	local score = petData and petData.score or "0"  -- 获取评分
    local scoreText = string.format(
    "[font='simhei-13'][colour='FF8C5E2A']%s[/colour][/font][font='hycyj-12'][colour='FF5E3F25']%s[/colour][/font]",
    MHSD_UTILS.get_resstring(7907),
    score
    )
    self.scoreText:setText(scoreText)
	self.nameText:setText(petData and petData.name or "")
	--self.scoreText:setText(petData and petData.score or "0")
	self.levelText:setText(petData and ''..petData:getAttribute(fire.pb.attr.AttrType.LEVEL) or "")
    self.fightLevelText:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.PET_FIGHT_LEVEL) or "")

	self:refreshPetSprite(petData and petData.shape or nil)
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

function PetPropertyDlgNew:refreshAtrriView(petData)
	self.hpBar:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.HP) .. "/" .. petData:getAttribute(fire.pb.attr.AttrType.MAX_HP) or "0")
	self.hpBar:setProgress(petData and petData:getAttribute(fire.pb.attr.AttrType.HP) / petData:getAttribute(fire.pb.attr.AttrType.MAX_HP) or 0)
	
	self.mpBar:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.MP) .. "/" .. petData:getAttribute(fire.pb.attr.AttrType.MAX_MP) or "0")
	self.mpBar:setProgress(petData and petData:getAttribute(fire.pb.attr.AttrType.MP) / petData:getAttribute(fire.pb.attr.AttrType.MAX_MP) or 0)
	
	self.expBar:setText(petData and petData.curexp .. "/" .. petData.nextexp or "0")
	self.expBar:setProgress(petData and petData.curexp / petData.nextexp or 0)
	
	self.waigongHurt:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.ATTACK) or "0")
	self.waigongDefend:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.DEFEND) or "0")
	self.neigongHurt:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.MAGIC_ATTACK) or "0")
	self.neigongDefend:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.MAGIC_DEF) or "0")
	self.speed:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.SPEED) or "0")
	--fire.pb.attr.AttrType.UNSEAL
    self:refreshPetEqiupList(petData.key)
end

function PetPropertyDlgNew:refreshSkillView(petData)
	if petData then
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petAttr then
            if petAttr.kind == fire.pb.pet.PetTypeEnum.VARIATION then
                local nBaoBaoId = petAttr.thebabyid 
                local baobaoTable = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nBaoBaoId)
                if baobaoTable then
                    petAttr = baobaoTable
                end
            end

		    --(cur-min)/(max-min)
		    local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
		    self.waigongzizhiBar:setText(curVal)
		    self.waigongzizhiBar:setProgress((curVal-petAttr.attackaptmin)/(petAttr.attackaptmax-petAttr.attackaptmin))

		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
		    self.fangyuzizhiBar:setText(curVal)
		    self.fangyuzizhiBar:setProgress((curVal-petAttr.defendaptmin)/(petAttr.defendaptmax-petAttr.defendaptmin))
		
		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
		    self.tilizizhiBar:setText(curVal)
		    self.tilizizhiBar:setProgress((curVal-petAttr.phyforceaptmin)/(petAttr.phyforceaptmax-petAttr.phyforceaptmin))
		
		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
		    self.neigongzizhiBar:setText(curVal)
		    self.neigongzizhiBar:setProgress((curVal-petAttr.magicaptmin)/(petAttr.magicaptmax-petAttr.magicaptmin))
		
		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
		    self.suduzizhiBar:setText(curVal)
		    self.suduzizhiBar:setProgress((curVal-petAttr.speedaptmin)/(petAttr.speedaptmax-petAttr.speedaptmin))
		
		    curVal = math.floor(petData.growrate*1000) / 1000
            local str = string.format("%.3f",curVal)
		    self.growBar:setText(str)
		    if petAttr.growrate:size() > 1 then
			    local maxgrow = petAttr.growrate[petAttr.growrate:size()-1] - petAttr.growrate[0]
			    if maxgrow > 0 then
				    self.growBar:setProgress((math.floor(petData.growrate*1000) - petAttr.growrate[0]) / maxgrow)
                else
				    self.growBar:setProgress(1)
			    end
		    end
		
		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE)
            self.lifeText:setVisible(true)
            self.allwaysLive:setVisible(false)
		    self.lifeText:setText(curVal)
            if petAttr.life == -1 then
                self.lifeText:setVisible(false)
                self.allwaysLive:setVisible(true)
            end
        end
	else
		self.waigongzizhiBar:setText("0")
		self.waigongzizhiBar:setProgress(0)
		self.fangyuzizhiBar:setText("0")
		self.fangyuzizhiBar:setProgress(0)
		self.tilizizhiBar:setText("0")
		self.tilizizhiBar:setProgress(0)
		self.neigongzizhiBar:setText("0")
		self.neigongzizhiBar:setProgress(0)
		self.suduzizhiBar:setText("0")
		self.suduzizhiBar:setProgress(0)
		self.growBar:setText("0")
		self.growBar:setProgress(0)
		self.lifeText:setText("0")
	end
	
	self:refreshSkillTable(petData)
	self:refreshSkillTable2(petData)
end

function PetPropertyDlgNew:refreshSkillTable(petData)
	local skillnum = (petData and petData:getSkilllistlen() or 0)
	--self.skillBoxes[PET_SKILL_ALLCOUNT]:setVisible(skillnum==PET_SKILL_ALLCOUNT)
	for i = 1, PET_SKILL_NORCOUNT do
		self.skillBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
            local isSkillBind = petData:isSkillBind(skill.skillid)
			SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petData, true, skill.certification, isSkillBind)
		end
	end
end

function PetPropertyDlgNew:refreshPetSprite(shapeID)
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
			self.icon:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, PetPropertyDlgNew.performPostRenderFunctions))
		end
	else
		self.sprite:SetModel(shapeID)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end
	
	self.elapse = 0
	self.defaultActCurTimes = 0
end

function PetPropertyDlgNew.performPostRenderFunctions(id)
	if _instance and _instance:IsVisible() and _instance:GetWindow():getEffectiveAlpha() > 0.95 and _instance.selectedPetKey ~= 0 and _instance.sprite then
		_instance.sprite:RenderUISprite()
	end
end

function PetPropertyDlgNew:update(dt)
	if not self.sprite then
		return
	end
	
	self.elapse = self.elapse+dt
	if self.elapse >= self.sprite:GetCurActDuration() then
		--print('pet duration', self.actType, self.sprite:GetCurActDuration())
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

function PetPropertyDlgNew:clickFreePet()
    

	if self.selectedPetKey ~= 0 then
        if GetBattleManager():IsInBattle() then
		    GetCTipsManager():AddMessageTipById(160302) --ս���в��ܷ���
		    return
	    end

		if gGetDataManager():GetBattlePetID() == self.selectedPetKey then
			GetCTipsManager():AddMessageTipById(150040) --��ս���ﲻ�ܷ�����������Ϊ��Ϣ
            return
		end

		local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
        if petData.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL and petData.iszhenshou==0 then
            GetCTipsManager():AddMessageTipById(162116) --���޲��ܷ���

	    elseif petData.kind ~= fire.pb.pet.PetTypeEnum.WILD and petData.kind ~= fire.pb.pet.PetTypeEnum.BABY then
			local dlg = PetFreeConfirm.getInstanceAndShow()
			dlg:setPetData(petData)
        elseif petData.kind == fire.pb.pet.PetTypeEnum.BABY then --����
            local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
            if petAttr then
                if petAttr.unusualid == 0 then  --��ͨ����
                    local bTreasure = isPetTreasure(petData)
                    if bTreasure then
                        local dlg = PetFreeConfirm.getInstanceAndShow()
			            dlg:setPetData(petData)
                    else
                        local freePet = CFreePet1.Create()
			            freePet.petkeys = { self.selectedPetKey }
			            LuaProtocolManager.getInstance():send(freePet)
                    end
                else
                        local dlg = PetFreeConfirm.getInstanceAndShow()
			            dlg:setPetData(petData)
                end
            end
	   else
			local freePet = CFreePet1.Create()
			freePet.petkeys = { self.selectedPetKey }
			LuaProtocolManager.getInstance():send(freePet)
		end
	end

end


function PetPropertyDlgNew:openLockSuccess()
    self:clickFreePet()
end


function PetPropertyDlgNew:handleFreeBtnOnClicked(args)
	if self.selectedPetKey ~= 0 then
        if GetBattleManager():IsInBattle() then
		    GetCTipsManager():AddMessageTipById(160302) --战斗中不能放生
		    return
	    end

		if gGetDataManager():GetBattlePetID() == self.selectedPetKey then
			GetCTipsManager():AddMessageTipById(150040) --出战宠物不能放生，请先设为休息
            return
		end

		local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
        if petData.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL and petData.iszhenshou==0 then
            GetCTipsManager():AddMessageTipById(162116) --神兽不能放生

	    elseif petData.kind ~= fire.pb.pet.PetTypeEnum.WILD and petData.kind ~= fire.pb.pet.PetTypeEnum.BABY then
			local dlg = PetFreeConfirm.getInstanceAndShow()
			dlg:setPetData(petData)
        elseif petData.kind == fire.pb.pet.PetTypeEnum.BABY then --宝宝
            local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
            if petAttr then
                if petAttr.unusualid == 0 then  --普通宝宝
                    local bTreasure = isPetTreasure(petData)
                    if bTreasure then
                        local dlg = PetFreeConfirm.getInstanceAndShow()
			            dlg:setPetData(petData)
                    else
                        local freePet = CFreePet1.Create()
			            freePet.petkeys = { self.selectedPetKey }
			            LuaProtocolManager.getInstance():send(freePet)
                    end
                else
                        local dlg = PetFreeConfirm.getInstanceAndShow()
			            dlg:setPetData(petData)
                end
            end
	   else
			local freePet = CFreePet1.Create()
			freePet.petkeys = { self.selectedPetKey }
			LuaProtocolManager.getInstance():send(freePet)
		end
	end
end

function PetPropertyDlgNew:handleFightBtnOnClicked(args)
	--[[if GetBattleManager():IsInBattle() then
		GetCTipsManager():AddMessageTipById(131451) --ս���в��ܽ��д˲�����
	else--]]if self.selectedPetKey then
		if MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey) then
			local petinfo = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
			if petinfo.key == gGetDataManager():GetBattlePetID()  then
				local p = require("protodef.fire.pb.pet.csetfightpetrest"):new()
                LuaProtocolManager:send(p)
			else
			    local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petinfo.baseid)
				if conf and conf.uselevel > gGetDataManager():GetMainCharacterLevel() then
					GetCTipsManager():AddMessageTipById(150084) --你的等级低于宠物的参战等级，不能出战
				elseif (petinfo:getAttribute(fire.pb.attr.AttrType.LEVEL) - gGetDataManager():GetMainCharacterLevel()) > 10 then
					GetCTipsManager():AddMessageTipById(141394) --你的宠物已经高于你自身等级10级，无法参加战斗。
				elseif petinfo:getAttribute(fire.pb.attr.AttrType.PET_LIFE) < 50 and petinfo.kind ~= fire.pb.pet.PetTypeEnum.SACREDANIMAL then
					GetCTipsManager():AddMessageTipById(150089) --你的宠物寿命低于50，无法参战
				else 
                    local p = require("protodef.fire.pb.pet.csetfightpet"):new()
                    p.petkey = petinfo.key
	                LuaProtocolManager:send(p)
				end
			end
		end
	end
    if NewRoleGuideManager.getInstance():getCurGuideId() == 33021 then
        self:petGuideHandle()
    end
end

function PetPropertyDlgNew:handleChangeNameOnClicked(args)
	if GetBattleManager():IsInBattle() then
		GetCTipsManager():AddMessageTipById(131451)
	elseif self.selectedPetKey then
		if MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey) then
			local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
            local dlg = petChangeName.getInstanceAndShow()
            dlg:setPetKey(petData.key)
		end
	end
end

function PetPropertyDlgNew:handleSwitchAtrriAndSkillView(args)
     PetPropertyDlgNew.Closetips()
	local selectedBtn = self.attrBtn:getSelectedButtonInGroup()
	
	if self.attrBtn == selectedBtn then
		if not self.attriView:isVisible() then
			self.attriView:setVisible(true)
			self.skillView:setVisible(false)
			self.neidanView:setVisible(false)
		end
		
	elseif self.skillBtn == selectedBtn then
		if not self.skillView:isVisible() then
			self.attriView:setVisible(false)
			self.skillView:setVisible(true)
			self.neidanView:setVisible(false)
		end
		
	else
		if not self.neidanView:isVisible() then
			self.attriView:setVisible(false)
			self.neidanView:setVisible(true)
			self.skillView:setVisible(false)
		end
	end
end

function PetPropertyDlgNew:handlePetIconSelected(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)
	--local idx = cell:GetIndex()
    local idx = wnd:getID()
	print('pet cell idx:', idx)
	if idx < MainPetDataManager.getInstance():GetPetNum() then
		local petData = MainPetDataManager.getInstance():getPet(idx+1)
		if self.selectedPetKey ~= petData.key then
			self:refreshSelectedPet(petData)
		end
	end
end

function PetPropertyDlgNew:handleLockedPetIconClicked(args)
	local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
	cell:setMouseOnThisCell(false)
	print('locked cell', cell:GetIndex())
	
	require("logic.shop.npcpetshop").getInstanceAndShow()
end

function PetPropertyDlgNew:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local s = GetScreenSize()
	SetPositionOffset(tip:GetWindow(), s.width*0.5, s.height*0.5, 1, 0.5)
end

function PetPropertyDlgNew:handleSkill2Clicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		--如果没有内丹，让它学习去
        local dlg = require('logic.pet.petaddneidanbook').getInstanceAndShow(self.selectedPetKey, cell:getID())
		return
	end
	local tip = PetSkillTipsDlg.ShowTipWithYiWang(self.selectedPetKey,cell:GetSkillID(), cell:getID())
	local s = GetScreenSize()
	SetPositionOffset(tip:GetWindow(), s.width*0.5, s.height*0.5, 1, 0.5)
end

function PetPropertyDlgNew:handleAssignPointClicked(args)
	PetAddZb.CloseIfExist()
	PetPropertyDlgNew.Closetips()
	print('click', self.selectedPetKey)
	local petData = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
	if petData then
		local dlg = require('logic.pet.petaddpointdlg').getInstanceAndShow()
		dlg:setPetData(petData)
	end
end

-- 跟随函数
function PetPropertyDlgNew:handlegensuiOnClicked(args)
	if self.selectedPetKey then
		if MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey) then
			local petinfo = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
			local p = require("protodef.fire.pb.pet.cshowpet"):new()
			p.petkey= petinfo.key
			LuaProtocolManager:send(p)
			GetCTipsManager():AddMessageTipById(126003)
		end
	end
end

-- 收回函数
function PetPropertyDlgNew:handleshouhuiOnClicked(args)
	if self.selectedPetKey then
		if MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey) then
			local petinfo = MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
			local p = require("protodef.fire.pb.pet.cshowpetoff"):new()
			p.petkey= petinfo.key
			LuaProtocolManager:send(p)
			GetCTipsManager():AddMessageTipById(126004)
		end
	end
end

function PetPropertyDlgNew:handleAddExpClicked(args)
	PetLabel.Show(3)
end

function PetPropertyDlgNew:handlelianyaoClicked(args)
	PetLabel.Show(2)
end

function PetPropertyDlgNew:handlelianyaoClicked1(args)
	PetLabel.Show(3)
end
function PetPropertyDlgNew:handleshizhuangClicked(args)
    PetLabel.DestroyDialog()
    require("logic.pet.petshizhuangdlg").getInstanceAndShow()
end
function PetPropertyDlgNew:petGuideHandle()
    local bar = self.petlistWnd:getVertScrollbar()
    local pageH = bar:getPageSize()
	local docH  = bar:getDocumentSize()
	local offset = math.max(0, docH-pageH) / docH
	self.petlistWnd:getVertScrollbar():Stop()
	self.petlistWnd:setVerticalScrollPosition(offset)
end

--技能tab切换
function PetPropertyDlgNew:handleSwitchSkillTypeTab(args)
	local selectedBtn = self.skillTypeTabBtn1:getSelectedButtonInGroup()
	
	if self.skillTypeTabBtn1 == selectedBtn then
		if not self.skillScroll:isVisible() then
			self.skillScroll:setVisible(true)
			self.skillScroll2:setVisible(false)
		end
	else
		if not self.skillScroll2:isVisible() then
			self.skillScroll:setVisible(false)
			self.skillScroll2:setVisible(true)
		end
	end
end
function PetPropertyDlgNew:refreshSkillTable2(petData)
    local skillnum = (petData and petData:getInternallistlen() or 0)
    for i = 1, 6 do
    	gGetGameUIManager():AddUIEffect(self.skillBoxes2[i], MHSD_UTILS.get_effectpath(10374), true) -- 显示加号
        self.skillBoxes2[i]:Clear()
       
    end
    for i = 1, skillnum do
        local skill = petData:getInternal(i)
        if skill and skill.skillid and skill.skillid ~= 0 then
            local isSkillBind = petData:isSkillBind(skill.skillid)           
            if self.skillBoxes2[i] then
                SetPetSkillBoxInfo(self.skillBoxes2[i], skill.skillid, petData, true, skill.certification, isSkillBind)
                gGetGameUIManager():RemoveUIEffect(self.skillBoxes2[i])
            end
        end
    end
end

-- function PetPropertyDlgNew:setDiJiNeiDan (idx,petData)
-- 	self.skillBoxes2[idx]:setEnabled(true)
-- 	local advskill=nil
-- 	local zhuanshuSkill=nil
-- 	local normalskill={}
 
-- 	 for k,v in ipairs(petData.petinternallist) do
-- 			local skillconf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(v.skillid)
		 
-- 			if skillconf then
-- 				if skillconf.color==3 then
					 
-- 					advskill=v
-- 				elseif skillconf.color==5 then
					 
-- 					zhuanshuSkill=v
-- 				else
					 
-- 					table.insert(normalskill,v)
-- 				end
-- 			end
-- 	 end
	
-- 	 if idx==6 and advskill~=nil then
-- 		self:SetPetNeiDanSkillInfo(self.skillBoxes2[idx], advskill.skillid, petData)
-- 		return
-- 	 elseif idx==5 and zhuanshuSkill~=nil then
-- 		self:SetPetNeiDanSkillInfo(self.skillBoxes2[idx], zhuanshuSkill.skillid, petData)
-- 		return
-- 	 else
-- 		local skill = normalskill[idx]
-- 		if skill then
-- 			self:SetPetNeiDanSkillInfo(self.skillBoxes2[idx], skill.skillid, petData)
-- 			return
-- 	 	end
-- 	end
--   	gGetGameUIManager():AddUIEffect(self.skillBoxes2[idx], MHSD_UTILS.get_effectpath(10374), true)

-- end
function PetPropertyDlgNew:choosedSkillBookItem(cellid,itemkey, skillid)
	--self:SetPetNeiDanSkillInfo(self.skillBoxes2[cellid], skillid)
	gGetGameUIManager():RemoveUIEffect(self.skillBoxes2[cellid])
	local skillconf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skillid)
	if skillconf then
		self.skillBox2Name[cellid]:setText(skillconf.skillname)
	end

end
-- function PetPropertyDlgNew:SetPetNeiDanSkillInfo(skillBox, skillid, petData)
-- 	if skillid == 0 then
--         return
--     end

--     skillBox:SetSkillID(skillid)
-- 	local skillexpiretime = petData and petData:getPetSkillExpires(skillid) or 0
-- 	skillBox:SetSkillDueDate(skillexpiretime)

-- 	local skillicon = RoleSkillManager.GetSkillIconByID(skillid)
-- 	skillBox:SetImage(gGetIconManager():GetSkillIconByID(skillicon))
-- 	skillBox:setTooltipText("")
-- 	skillBox:SetBackgroundDynamic(true)
-- end
-- function PetPropertyDlgNew:refreshSkillNeiDan(petData)
-- 	local skillnum = (petData and petData:getInternallistlen() or 0)
-- 	--self.skillBoxes2[PET_INTERNAL_NORCOUNT]:setVisible(skillnum==PET_INTERNAL_NORCOUNT)
-- 	for i = 1, PET_NEIDAN_COUNT do
-- 		self.skillBoxes2[i]:Clear()
-- 		self.skillBoxes2[i]:setEnabled(false)
-- 		gGetGameUIManager():RemoveUIEffect(self.skillBoxes2[i])
-- 	end
-- 	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
-- 	if petAttr then
-- 		if petAttr.kind==1 then --野生宝宝直接退出
-- 			return
-- 		end
 
-- 		if  petAttr.kind~=4 then
-- 		 if petAttr.uselevel>=1 and petAttr.uselevel<115 then
-- 			self:setDiJiNeiDan(1,petData)
-- 			self:setDiJiNeiDan(2,petData)
-- 			self:setDiJiNeiDan(3,petData)
-- 			self:setDiJiNeiDan(4,petData)
-- 		 end
-- 		elseif petAttr.kind==4  then
-- 			--神兽
-- 			self:setDiJiNeiDan(1,petData)
-- 			self:setDiJiNeiDan(2,petData)
-- 			self:setDiJiNeiDan(3,petData)
-- 			self:setDiJiNeiDan(5,petData)
-- 			--提升过的神兽
-- 			if petData.shenshouinccount>0 then
-- 				self:setDiJiNeiDan(4,petData)
				
-- 			end
-- 		end
	
-- 		self:setDiJiNeiDan(6,petData)
-- 	end
-- end

return PetPropertyDlgNew

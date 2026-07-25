------------------------------------------------------------------
-- 炼妖
------------------------------------------------------------------
require "logic.dialog"
require "logic.pet.petchoosedlg"
require "logic.pet.petpreviewdlg"
require "logic.pet.petaddskillbook"
require "logic.pet.petskillidentify"
require "logic.pet.petskillidentifylingwu"
require "logic.pet.petskillidentifyyiwang"
require "logic.pet.petcombineresultdlg"
require "logic.pet.Addndpointintro"

local RANDOM_ACT = {
	eActionRun,
	eActionAttack,
	eActionMagic1
}

local _isFirstXiLian = true
local _washitemid = 0
local _washitemname = ""

PetLianYaoDlg = {
	selectedPetKey = 0,
	actType = eActionStand,
	defaultActRepeatTimes = 3,
	combinePetKey1 = 0,
	combinePetKey2 = 0,
	bookItemKey = 0,
	internalbookItemKey  = 0,
	internalSelectId = 0
}
setmetatable(PetLianYaoDlg, Dialog)
PetLianYaoDlg.__index = PetLianYaoDlg

local _instance
function PetLianYaoDlg.getInstance()
	if not _instance then
		_instance = PetLianYaoDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetLianYaoDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetLianYaoDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetLianYaoDlg.getInstanceNotCreate()
	return _instance
end

function PetLianYaoDlg.DestroyDialog()
	if _instance then 
		if _instance.sprite then
			_instance.sprite:delete()
			_instance.sprite = nil
			_instance.profileIcon:getGeometryBuffer():setRenderEffect(nil)
		end
		
		if _instance.sprite1 then

			gGetGameUIManager():RemoveWindowSprite(_instance.sprite1)
		end
		
		if _instance.sprite2 then

			gGetGameUIManager():RemoveWindowSprite(_instance.sprite2)
		end
        if _instance.m_aniopen1 then
            local aniMan = CEGUI.AnimationManager:getSingleton()
            aniMan:destroyAnimationInstance(_instance.m_aniopen1)
			_instance.m_aniopen1=nil
        end
        if _instance.m_aniopen2 then
            local aniMan = CEGUI.AnimationManager:getSingleton()
            aniMan:destroyAnimationInstance(_instance.m_aniopen2)
			_instance.m_aniopen2=nil
        end
		
		gGetDataManager().m_EventMainPetAttributeChange:RemoveScriptFunctor(_instance.eventMainPetAttributeChange)
		gGetDataManager().m_EventPetNumChange:RemoveScriptFunctor(_instance.eventPetNumChange)
		gGetDataManager().m_EventPetDataChange:RemoveScriptFunctor(_instance.eventPetDataChange)
		gGetDataManager().m_EventBattlePetStateChange:RemoveScriptFunctor(_instance.eventBattlePetStateChange)
		gGetDataManager().m_EventBattlePetDataChange:RemoveScriptFunctor(_instance.eventBattlePetDataChange)
		gGetDataManager().m_EventPetNameChange:RemoveScriptFunctor(_instance.eventPetNameChange)
		gGetDataManager().m_EventPetSkillChange:RemoveScriptFunctor(_instance.eventPetSkillChange)
		gGetDataManager().m_EventPetInternalChange:RemoveScriptFunctor(_instance.eventPetInternalChange)
		gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)	
		
		Dialog.OnClose(_instance)
		if not _instance.m_bCloseIsHide then
			_instance = nil
		end
	end
end

function PetLianYaoDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetLianYaoDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetLianYaoDlg.GetLayoutFileName()
	return "petpropertyxilian_mtg.layout"
end

function PetLianYaoDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetLianYaoDlg)
	return self
end

function PetLianYaoDlg:addButtonAnimation(button, animationName)
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

function PetLianYaoDlg:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ccharecterinfo = winMgr:getWindow("petpropertyxilian_mtg")
	    self.ccharecterinfo:subscribeEvent("Hidden", function(args)
        -- 重置技能名称文本
        local winMgr = CEGUI.WindowManager:getSingleton()
        local nameText = winMgr:getWindow("petpropertyxilian_mtg/xuejineng/name")
        nameText:setText("请放入兽决")  -- 空字符串
    end, self)
	--petpropertyxilian_mtg
	self.xilianGroupBtn = CEGUI.toGroupButton(winMgr:getWindow("petpropertyxilian_mtg/xilianBtn"))
	self.combineGroupBtn = CEGUI.toGroupButton(winMgr:getWindow("petpropertyxilian_mtg/combineBtn"))
	self.learnSkillGroupBtn = CEGUI.toGroupButton(winMgr:getWindow("petpropertyxilian_mtg/learnSkillBtn"))
	self.internalGroupBtn = CEGUI.toGroupButton(winMgr:getWindow("petpropertyxilian_mtg/internalBtn"))
	self.fanhuiBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/fanhui"))
	
	--profile view-----------------------------------------------------------------------------
	self.profileView = winMgr:getWindow("petpropertyxilian_mtg/profileView")
	self.profileIcon = winMgr:getWindow("petpropertyxilian_mtg/icon")
	self.levelText = winMgr:getWindow("petpropertyxilian_mtg/level")
	self.babyImg = winMgr:getWindow("petpropertyxilian_mtg/icon/imagebb")
	self.nameText = winMgr:getWindow("petpropertyxilian_mtg/nameText")
	self.scoreText = winMgr:getWindow("petpropertyxilian_mtg/scoreText")

	self.tutengImg = winMgr:getWindow("petpropertyxilian_mtg/bgfazhen")
    self.fightLevelText = winMgr:getWindow("petpropertyxilian_mtg/scoreText2")
	

	
    self.m_petList = {}
    self.petlistWnd = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyxilian_mtg/pets/petScroll"));
    self.petlistWnd:EnableHorzScrollBar(false)
	
	
	--attribute view---------------------------------------------------------------------------
	self.attriView = winMgr:getWindow("petpropertyxilian_mtg/attriView")
	self.waigongzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg1/Back2/bar0"))
	self.fangyuzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg1/Back2/bar1"))
	self.tilizizhiBar = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg1/Back2/bar2"))
	self.neigongzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg1/Back2/bar3"))
	self.suduzizhiBar = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg1/Back2/bar4"))
	self.growBar = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/text2bg/barchengzhang"))
	self.skillAttriScroll = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyxilian_mtg/skillView/skillScroll"))
	self.xilianEffectBg = winMgr:getWindow("petpropertyxilian_mtg/skillbg/xilianeffectbg")
    self.skillScroll = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/skillScroll"))


    self.attack1 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi1"))
    self.defense1 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi2"))
    self.endurance1 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi3"))
    self.magic1 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi4"))
    self.speed1 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi5"))
    self.grow1 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/chengzhang1"))


    self.attack2 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi7"))
    self.defense2 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi8"))
    self.endurance2 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi9"))
    self.magic2 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi10"))
    self.speed2 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/zhi11"))
    self.grow2 = CEGUI.toProgressBar(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/chengzhang2"))
    
    
	self.xilianItem = CEGUI.toItemCell(winMgr:getWindow("petpropertyxilian_mtg/itemxichongdaoju"))
	self.xilianItemName = winMgr:getWindow("petpropertyxilian_mtg/textjinliulu")---洗炼物品名字
	self.xilianItemCount = winMgr:getWindow("petpropertyxilian_mtg/daojugeshu")
	self.xilianTipBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/btnzhiyin"))
	self.xilianBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/btnxiliananniu"))--洗炼宠物
	self.xiechu = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/neidan/buttonxx"))---内丹卸下
	self:addButtonAnimation(self.xiechu, "studyBtnPress")
	self.xiechu:subscribeEvent("Clicked", PetLianYaoDlg.xuechuClicked, self)
	self.fanhuiBtn:subscribeEvent("Clicked", PetLianYaoDlg.handlefanhuiClicked, self)---返回宠物界面
	
	

	self.neidantishi = CEGUI.toRichEditbox(winMgr:getWindow("petpropertyxilian_mtg/internalView/neidantishi"))--内丹卸下提示
	self.neidantishi:Clear()
    self.neidantishi:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7411)))
    self.neidantishi:Refresh()

	self.xiliantishi = CEGUI.toRichEditbox(winMgr:getWindow("petpropertyxilian_mtg/attriView/xilianshuoming"))--神兽洗炼提示-不可洗炼
	self.xiliantishi:Clear()
    self.xiliantishi:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7413)))
    self.xiliantishi:Refresh()    	
	
	self.attriSkillBoxes = {}
	for i=1,PET_SKILL_NORCOUNT do
		self.attriSkillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petpropertyxilian_mtg1/Skill" .. i))
		self.attriSkillBoxes[i]:subscribeEvent("MouseClick", PetLianYaoDlg.handleSkillClicked, self)
        self.attriSkillBoxes[i]:SetBackGroupOnTop(true)
	end
	
	self.skillAttriScroll:EnableAllChildDrag(self.skillAttriScroll)
	
	self.xilianItem:subscribeEvent("TableClick", PetLianYaoDlg.HandleShowToolTipsWithItemID, self)

	
    self.itemcell1 = CEGUI.toItemCell(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/petdi1/pet1"))
    self.itemcell2 = CEGUI.toItemCell(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/petdi1/pet2"))
    self.attack3 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/gongji")
    self.defense3 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/fangyu")
    self.endurance3 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/tili")
    self.magic3 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/fafang")
    self.speed3 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/sudu")
    self.attack3 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/gongji")
    self.grow3 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/chengzhang")

    self.finalSkillBoxes = {}
	for i=1,PET_SKILL_NORCOUNT do
		self.finalSkillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/Skill" .. i))
		self.finalSkillBoxes[i]:subscribeEvent("MouseClick", PetLianYaoDlg.handleSkillClicked, self)
        self.finalSkillBoxes[i]:SetBackGroupOnTop(true)
	end
    self.skillScroll:EnableAllChildDrag(self.skillScroll)
	
	--skill view-------------------------------------------------------------------------------
	self.skillView = winMgr:getWindow("petpropertyxilian_mtg/skillView")
	self.bookItem = CEGUI.toSkillBox(winMgr:getWindow("petpropertyxilian_mtg/xuejineng/jinengdi/bookitem"))
    self.bookItem:SetBackGroupOnTop(true)
--	self.xuexijinengc = winMgr:getWindow("petpropertyxilian_mtg/bgfazhen11")---普通宠物
	self.learnBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/xuejineng/btnxuexi"))---学习
	self.learnTipBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/xuejineng/xuexizhiyin"))
	self.skillLearnScroll = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyxilian_mtg/xuejineng/skillScroll"))
	self.identifyBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/xuejinengtextbg/buttonfashurenzheng"))
	self.identifyBtn1 = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/xuejinengtextbg/buttonfashurenzheng1"))---特殊学习
	self.identifyBtn11 = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/xuejinengtextbg/buttonfashurenzheng11"))
	self.identifyTipBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/xuejinengtextbg/btnfashurenzhengzhiyin"))
	
	gGetGameUIManager():AddUIEffect(self.bookItem, MHSD_UTILS.get_effectpath(10374), true)
	
	self.learnSkillBoxes = {}
	for i=1,PET_SKILL_NORCOUNT do
		self.learnSkillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petpropertyxilian_mtg/xuejineng/Skill" .. i))
		self.learnSkillBoxes[i]:subscribeEvent("MouseClick", PetLianYaoDlg.handleSkillClicked, self)
	end
	self.skillLearnScroll:EnableAllChildDrag(self.skillLearnScroll)
		
	self.bookItem:subscribeEvent("MouseClick", PetLianYaoDlg.handleAddSkillClicked, self)
	
	self.nameText2 = winMgr:getWindow("petpropertyxilian_mtg/skillView/text1")
	self.scoreText2 = winMgr:getWindow("petpropertyxilian_mtg/skillView/pingfen1")
	self.kindImg = winMgr:getWindow("petpropertyxilian_mtg/skillView/image1")
		
	--combine view---炼妖合宠--------------------------------------------------------------------------
	
	self.leftpet = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/leftpet")---一号
	self.rightpet = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/rightpet")---二号
	self.m_aniopen1Status=0
	self.m_aniopen2Status=0
	self.combineView = winMgr:getWindow("petpropertyxilian_mtg/combineView")
	self.combinePet1 = CEGUI.toItemCell(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/hechongitem"))
	self.cb_tizi1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/tilizhi")
	self.cb_suzi1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/suduzhi")
	self.cb_gongzi1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/gongjizhi")
	self.cb_fazi1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/falizhi")
	self.cb_fangzi1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/fangyuzhi")
	self.cb_grow1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/chongwuzhi")
	self.cb_skillScroll1 = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/leftpet/skillScroll"))
	self.cb_cwname1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/1hao1")---一号宠物名字
	self.cb_cwname2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/1hao12")----二号宠物名字
	self.cb_cwleve1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/1haolvel1")---一号宠物等级
	self.cb_cwleve2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/1haolvel2")---一二号宠物等级
	self.cb_cwpinfen1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/pinfen1")---一号宠物评分
	self.cb_cwpinfen2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/pinfen2")----二号宠物评分
	self.annUI = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2")
	self.annUI:setVisible(false)

self.gengduo = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/combineView/cb_previewBtn1"))
self.gengduoa = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/combineView/cb_previewBtn11"))
self.gengduo:subscribeEvent("Clicked", PetLianYaoDlg.handleFreeGDOnClicked, self)
self.gengduoa:subscribeEvent("Clicked", PetLianYaoDlg.handleFreeGDAOnClicked, self)
self.gengduoa:setVisible(false)
local aniMan = CEGUI.AnimationManager:getSingleton()
self.animationShow = aniMan:getAnimation("lianyao1") 
self.animationHide = aniMan:getAnimation("lianyao2") 
print("animationHide name:", self.animationHide) 

self.gengduo:subscribeEvent("Clicked", function(args)
    self.annUI:setVisible(true)
    self.m_aniShow = aniMan:instantiateAnimation(self.animationShow)
    self.m_aniShow:setTargetWindow(self.annUI)
    self.m_aniShow:unpause()
    self.gengduo:setVisible(true)
    self.gengduoa:setVisible(true)
end, self)

self.gengduoa:subscribeEvent("Clicked", function(args)
    self.m_aniHide = aniMan:instantiateAnimation(self.animationHide)
    if self.m_aniHide then 
        self.m_aniHide:setTargetWindow(self.annUI)
        self.m_aniHide:unpause()
 
        self.m_aniHide.AnimationEnded = function(self)
            self.annUI:setVisible(false)
            self.gengduo:setVisible(true)
            self.gengduoa:setVisible(true)
        end
    end
end, self)


	
	

	self.skillBoxes1={}
	self.skillBoxes2={}
	for i = 1, 25 do
		table.insert(self.skillBoxes1,0)
		table.insert(self.skillBoxes2,0)
	end


	
	self.cb_skillBoxes1 = {}
	self.cb_skillBoxes1xiangtong = {}
	for i=1,25 do
		self.cb_skillBoxes1[i] = CEGUI.toSkillBox(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/leftpet/Skill" .. i))
		self.cb_skillBoxes1[i]:subscribeEvent("MouseClick", PetLianYaoDlg.handleSkillClicked, self)
		self.cb_skillBoxes1xiangtong[i] = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/leftpet/Skill" .. i .. "/xiangtong")
		self.cb_skillBoxes1xiangtong[i]:setVisible(false)
	end
	self.cb_skillBoxes1[25]:setVisible(false)
	self.cb_skillScroll1:EnableAllChildDrag(self.cb_skillScroll1)

	
	
	---============================
	self.combinePet2 = CEGUI.toItemCell(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/hechongitem2"))
	self.cb_tizi2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/tilizhi2")
	self.cb_suzi2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/suduzhi2")
	self.cb_gongzi2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/gongjizhi2")
	self.cb_fazi2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/falizhi2")
	self.cb_fangzi2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/fangyuzhi2")
	self.cb_grow2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg2/chongwuzhi2")
	self.cb_skillScroll2 = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/rightpet/skillScroll"))
	
	
	self.cb_skillBoxes2 = {}
	self.cb_skillBoxes2xiangtong = {}
	for i=1,25 do
		self.cb_skillBoxes2[i] = CEGUI.toSkillBox(winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/rightpet/Skill" .. i))
		self.cb_skillBoxes2[i]:subscribeEvent("MouseClick", PetLianYaoDlg.handleSkillClicked, self)
		self.cb_skillBoxes2xiangtong[i] = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/rightpet/Skill" .. i .. "/xiangtong")
		self.cb_skillBoxes2xiangtong[i]:setVisible(false)
	end
	self.cb_skillBoxes2[25]:setVisible(false)
	self.cb_skillScroll2:EnableAllChildDrag(self.cb_skillScroll2)
	
	
	self.cbPreviewBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/combineView/cb_previewBtn"))
	self.combineBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/combineView/combineBtn"))
	self.combineBtn1 = winMgr:getWindow("petpropertyxilian_mtg/combineView/combineBtn1")
	self.cbTipBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/combineView/cbTipBtn"))
	self.combineBtn:setVisible(true)
	self.combineBtn1:setVisible(false)
	self.petmob1 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/mob1")
	self.petmob2 = winMgr:getWindow("petpropertyxilian_mtg/hechongtextbg1/mob2")
	
	self.xilianGroupBtn:subscribeEvent("SelectStateChanged", PetLianYaoDlg.handleGroupBtnClicked, self)
	self.combineGroupBtn:subscribeEvent("SelectStateChanged", PetLianYaoDlg.handleGroupBtnClicked, self)
	self.learnSkillGroupBtn:subscribeEvent("SelectStateChanged", PetLianYaoDlg.handleGroupBtnClicked, self)
	self.internalGroupBtn:subscribeEvent("SelectStateChanged", PetLianYaoDlg.handleGroupBtnClicked, self)

	self.xilianTipBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleXiLianTipClicked, self)
	self.xilianBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleXiLianClicked, self)---宠物洗炼
	self:addButtonAnimation(self.xilianBtn, "studyBtnPress")--技能学习
	
	self.learnBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleLearnClicked, self)---技能学习
	self:addButtonAnimation(self.learnBtn, "studyBtnPress")--技能学习
	self.learnTipBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleLearnTipClicked, self)
	self.identifyBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleIdentifyClicked, self)
	self.identifyBtn1:subscribeEvent("Clicked", PetLianYaoDlg.handleIdentifyClicked1, self)---特殊学习
	self:addButtonAnimation(self.identifyBtn1, "studyBtnPress")--特殊学习
	self.identifyBtn11:subscribeEvent("Clicked", PetLianYaoDlg.handleIdentifyClicked11, self)
	self.identifyTipBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleIdentifyTipClicked, self)
	self.cbPreviewBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleCombinePreviewClicked, self)
	self.combineBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleCombineClicked, self)
	self.cbTipBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleCombineTipClicked, self)
	
	self.smokeBg = winMgr:getWindow("petpropertyxilian_mtg/combineView/donghuacc1")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_hchuoyan", true, s.width*0.5, s.height)
	self.smokeBg1 = winMgr:getWindow("petpropertyxilian_mtg/combineView/donghuacc2")
	local s = self.smokeBg1:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg1, "geffect/ui/mt_shengqishi/mt_lianyaoc", true, s.width*0.5, s.height)
	
	gGetGameUIManager():AddUIEffect(self.combinePet1, MHSD_UTILS.get_effectpath(10374), true)----按钮动画
	gGetGameUIManager():AddUIEffect(self.combinePet2, MHSD_UTILS.get_effectpath(10374), true)
	
	self.combinePet1:subscribeEvent("TableClick", PetLianYaoDlg.handleAddCombinePetClicked, self)
	self.combinePet2:subscribeEvent("TableClick", PetLianYaoDlg.handleAddCombinePetClicked, self)
	
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", PetLabel.hide, nil)

	
	-----------------------------------------------------------------------------------------------
	--内丹
	self.internalView = winMgr:getWindow("petpropertyxilian_mtg/internalView")
	self.internalnameText = winMgr:getWindow("petpropertyxilian_mtg/internalView/text1")
	self.internalscoreText = winMgr:getWindow("petpropertyxilian_mtg/internalView/pingfen1")
	self.internalkindImg = winMgr:getWindow("petpropertyxilian_mtg/internalView/image1")
	self.internallearnBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/neidan/btnxuexi"))---内丹学习
	self:addButtonAnimation(self.internallearnBtn, "studyBtnPress")
	self.internallearnTipBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyxilian_mtg/neidan/xuexizhiyin"))
	self.internalScroll = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyxilian_mtg/neidan/skillScroll"))
	self.internalbookItem = CEGUI.toSkillBox(winMgr:getWindow("petpropertyxilian_mtg/neidan/jinengdi/internalbookItem"))
	self.internalbookItem:SetBackGroupOnTop(true)
	
	gGetGameUIManager():AddUIEffect(self.internalbookItem, MHSD_UTILS.get_effectpath(10374), true)
	self.internalbookItem:subscribeEvent("MouseClick", PetLianYaoDlg.handleAddSkillClicked, self)
	
	self.internallearnBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleLearnInternalClicked, self)


	self.learnInternlBoxes = {}
	for i=1,PET_INTERNAL_NORCOUNT do
		self.learnInternlBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petpropertyxilian_mtg/neidan/Skill" .. i))
		self.learnInternlBoxes[i]:subscribeEvent("MouseClick", PetLianYaoDlg.handleInternalClicked, self)
	end
	self.internalScroll:EnableAllChildDrag(self.internalScroll)
	---self.internallearnTipBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleLearnInternalTipClicked, self)
	self.internallearnTipBtn:subscribeEvent("Clicked", PetLianYaoDlg.handleLearnInternalTipClicked, self);


	
	-------------------------------------------------------------------------------------------
	self.eventMainPetAttributeChange = gGetDataManager().m_EventMainPetAttributeChange:InsertScriptFunctor(PetLianYaoDlg.onEventMainPetRefresh)
	self.eventPetNumChange = gGetDataManager().m_EventPetNumChange:InsertScriptFunctor(PetLianYaoDlg.onEventPetNumChange)
	self.eventPetDataChange = gGetDataManager().m_EventPetDataChange:InsertScriptFunctor(PetLianYaoDlg.onEventPetDataChange)
	self.eventBattlePetStateChange = gGetDataManager().m_EventBattlePetStateChange:InsertScriptFunctor(PetLianYaoDlg.onEventPetBattleStateChange)
	self.eventBattlePetDataChange = gGetDataManager().m_EventBattlePetDataChange:InsertScriptFunctor(PetLianYaoDlg.onEventMainPetRefresh)
	self.eventPetNameChange = gGetDataManager().m_EventPetNameChange:InsertScriptFunctor(PetLianYaoDlg.onEventPetDataChange)
	self.eventPetSkillChange = gGetDataManager().m_EventPetSkillChange:InsertScriptFunctor(PetLianYaoDlg.onEventPetSkillChange)
	self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(PetLianYaoDlg.OnEventItemNumChange)
	self.eventPetInternalChange = gGetDataManager().m_EventPetInternalChange:InsertScriptFunctor(PetLianYaoDlg.onEventPetInternalChange)
	-------------------------------------------------------------------------------------------
	
	self:showOnly(self.attriView)
	self:refreshPetTableOnProfileView()
	local defaultPet = MainPetDataManager.getInstance():getPet(1)
	if defaultPet then
            _instance.m_petList[1].addclick:setSelected(true)
	end
	self:refreshSelectedPet(defaultPet)

    self.firstXiLianPetKeys = {} 

	self.waitingForResult = false
end

function PetLianYaoDlg:releasePetIcon()   
    local sz = #self.m_petList
    for index  = 1, sz do
        local lyout = self.m_petList[1]
        lyout.addclick = nil
        lyout.NameText = nil
        lyout.LevelText = nil 
        lyout.petCell = nil
        lyout.chuzhan = nil

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

function PetLianYaoDlg:HandleShowToolTipsWithItemID(args)
	
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e2 = CEGUI.toMouseEventArgs(args)
	local touchPos = e2.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg.id then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()

	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function PetLianYaoDlg:showOnly(wnd)
	self.profileView:setVisible( wnd == self.attriView or wnd == self.skillView or wnd == self.internalView )
	self.attriView:setVisible( wnd == self.attriView )
	self.skillView:setVisible( wnd == self.skillView )
	self.combineView:setVisible( wnd == self.combineView )
	self.internalView:setVisible( wnd == self.internalView )
end

function PetLianYaoDlg:refreshAll(petData)
	self:refreshSelectedPet(petData)
	self:refreshPetTableOnProfileView()
	
	self:refreshCombinePet(1, nil)
    self:refreshCombinePet(2, nil)

	self.bookItemKey = 0
	self.bookItem:Clear()
	gGetGameUIManager():AddUIEffect(self.bookItem, MHSD_UTILS.get_effectpath(10374), true)

	self.internalbookItemKey = 0
	self.internalbookItem:Clear()
	gGetGameUIManager():AddUIEffect(self.internalbookItem, MHSD_UTILS.get_effectpath(10374), true)

end

function PetLianYaoDlg:getSelectedPet()
	return MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
end

function PetLianYaoDlg:showLearnSkillView()
	self:showOnly(self.skillView)
	self.learnSkillGroupBtn:setSelected(true)
end

function PetLianYaoDlg:showXiLianView()
    self:showOnly(self.attriView)
	self.xilianGroupBtn:setSelected(true)
end

function PetLianYaoDlg:showBineView()
    self:showOnly(self.combineView)
	self.combineGroupBtn:setSelected(true)
end

function PetLianYaoDlg:showInternalView()
	self:showOnly(self.internalView)
	self.internalGroupBtn:setSelected(true)
end

function PetLianYaoDlg:handleGroupBtnClicked(args)--内丹学习按钮
	local selectedBtn = self.xilianGroupBtn:getSelectedButtonInGroup()
	if selectedBtn == self.xilianGroupBtn then
        PetAddSkillBook.CloseIfExist()
		self:showOnly(self.attriView)
	elseif selectedBtn == self.combineGroupBtn then
        self:refreshCombinePet(1, nil)
        self:refreshCombinePet(2, nil)
        PetAddSkillBook.CloseIfExist()
		self:showOnly(self.combineView)
	elseif selectedBtn == self.learnSkillGroupBtn then
		self:showOnly(self.skillView)
	elseif selectedBtn == self.internalGroupBtn then
		GetCTipsManager():AddMessageTipById(201087)--改正常内丹
		--self.internalSelectId = 0
		--self:showOnly(self.internalView)
	end
end

function PetLianYaoDlg:DestroyDialogc()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.smokeBg1 then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg1)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

function PetLianYaoDlg:refreshSelectedPet(petData)
	if petData then
		self.selectedPetKey = petData.key
	else
		self.selectedPetKey = 0
	end

    --神兽洗炼隐藏按钮
    if not petData or petData.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then
        self.xilianItem:setVisible(false)
        self.xilianItemCount:setVisible(false)
        self.xilianTipBtn:setVisible(false)
        self.xilianBtn:setVisible(false)
		self.xilianItemName:setVisible(false)
		self.xiliantishi:setVisible(true)
    else
        self.xilianItem:setVisible(true)
        self.xilianItemCount:setVisible(true)
        self.xilianTipBtn:setVisible(true)
        self.xilianBtn:setVisible(true)
		self.xilianItemName:setVisible(true)
		self.xiliantishi:setVisible(false)
    end
	
	self:refreshProfile(petData)
	self:refreshAttributeView(petData)
	self:refreshAttributeSkillView(petData)
	self:refreshSkillView(petData)

	self:refreshInternalView(petData)
	
	PetLabel.getInstance():setSelectedPetKey(self.selectedPetKey)
end

--[[function PetLianYaoDlg:refreshSelectedPet(petData)
    if petData then
        self.selectedPetKey = petData.key
    else
        self.selectedPetKey = 0
    end

    petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)---
    if petData and petData.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL and petAttr.quality > 4 then----神兽品质大于4的时候隐藏洗炼的按钮与操作
        self.xilianItem:setVisible(false)
        self.xilianItemCount:setVisible(false)
        self.xilianTipBtn:setVisible(false)
        self.xilianBtn:setVisible(false)
    else
        self.xilianItem:setVisible(true)
        self.xilianItemCount:setVisible(true)
        self.xilianTipBtn:setVisible(true)
        self.xilianBtn:setVisible(true)
    end

    self:refreshProfile(petData)
    self:refreshAttributeView(petData)
    self:refreshAttributeSkillView(petData)
    self:refreshSkillView(petData)

    self:refreshInternalView(petData)

    PetLabel.getInstance():setSelectedPetKey(self.selectedPetKey)
end--]]

--profile view ----------------------------------------------------------------------------
function PetLianYaoDlg:refreshProfile(petData)
    local petAttr
    if petData then

		self.nameText:setProperty("TextColours", "FF50321A")--宠物名字颜色
		self.nameText2:setProperty("TextColours", GetPetNameColour(petData.baseid))
		self.internalnameText:setProperty("TextColours", GetPetNameColour(petData.baseid))

        petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petAttr then
            local imgpath = GetPetKindImageRes(petAttr.kind, petAttr.unusualid)
            self.babyImg:setVisible(true)
		    self.babyImg:setProperty("Image", imgpath)

            UseImageSourceSize(self.babyImg, imgpath)
            self.kindImg:setVisible(true)
		    self.kindImg:setProperty("Image", imgpath)

			UseImageSourceSize(self.kindImg, imgpath)
			self.internalkindImg:setVisible(true)
		    self.internalkindImg:setProperty("Image", imgpath)

            UseImageSourceSize(self.internalkindImg, imgpath)
        end
    else
		self.babyImg:setVisible(false)
		self.kindImg:setVisible(false)
		self.internalkindImg:setVisible(false)
    end
	self.nameText:setText(petData and petData.name or "")
	self.nameText2:setText(petData and petData.name or "")
	self.internalnameText:setText(petData and petData.name or "")

	self.scoreText:setText(petData and petData.score or "0")
	self.scoreText2:setText(petData and petData.score or "0")
	self.internalscoreText:setText(petData and petData.score or "0")

	self.levelText:setText(petData and 'Lv.'..petData:getAttribute(fire.pb.attr.AttrType.LEVEL) or "")
    self.fightLevelText:setText(petData and petData:getAttribute(fire.pb.attr.AttrType.PET_FIGHT_LEVEL) or "")
	--self.fightSign:setVisible(petData and petData.key == gGetDataManager():GetBattlePetID())

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

function PetLianYaoDlg:refreshPetTableOnProfileView()
   
    self:releasePetIcon()
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;
    self.m_petList = {}
    local index = 0
    local fightid = gGetDataManager():GetBattlePetID()
    for i = 1, MainPetDataManager.getInstance():GetPetNum() do
		local petData = MainPetDataManager.getInstance():getPet(i)
        local sID = "PetLianYaoDlg" .. tostring(index)
        local lyout = winMgr:loadWindowLayout("petcell1.layout",sID);
        self.petlistWnd:addChildWindow(lyout)
	    
        local xindex = (index)%5
        local yindex = math.floor((index)/5)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (lyout:getWidth().offset)), CEGUI.UDim(0.0, sy + yindex * (lyout:getHeight().offset))))


        lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
        lyout.addclick:setID(index)
	    lyout.addclick:subscribeEvent("MouseButtonUp", PetLianYaoDlg.handlePetIconSelected, self)

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

function PetLianYaoDlg:refreshAddPetBtn(index) 
	local winMgr = CEGUI.WindowManager:getSingleton()
    local sx = 2.0;
    local sy = 2.0;      
    if not MainPetDataManager.getInstance():IsMyPetFull() then
        if self.addPetButton == nil then  
            local sID = "PetLianYaoDlgNewAdd"
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
end
function PetLianYaoDlg:refreshPetTableOnProfileViewData()      
	local winMgr = CEGUI.WindowManager:getSingleton()
    local fightid = gGetDataManager():GetBattlePetID()
    local sz = MainPetDataManager.getInstance():GetPetNum()
    local sx = 2.0;
    local sy = 2.0;      
    local index = 0
    for i = 1, sz do
		local petData = MainPetDataManager.getInstance():getPet(i)
        if petData then
            local lyout = self.m_petList[i]  
            if lyout == nil then
                local sID = "PetLianYaoDlg" .. tostring(index)
                lyout = winMgr:loadWindowLayout("petcell1.layout",sID);
                self.petlistWnd:addChildWindow(lyout)
                lyout.key = petData.key            
                lyout.addclick =  CEGUI.toGroupButton(winMgr:getWindow(sID.."petcell"));
                lyout.addclick:setID(index)
	            lyout.addclick:subscribeEvent("MouseButtonUp", PetPropertyDlgNew.handlePetIconSelected, self)
                if petData.key == self.selectedPetKey then
                    lyout.addclick:setSelected(true)
                end                    
                lyout.NameText = winMgr:getWindow(sID.."petcell/name")        
                lyout.LevelText = winMgr:getWindow(sID.."petcell/number")
                lyout.petCell = CEGUI.toItemCell(winMgr:getWindow(sID.."petcell/touxiang")) 
                lyout.chuzhan = winMgr:getWindow(sID.."petcell/zhan")
                lyout.addtext = winMgr:getWindow(sID.."petcell/name1")
                lyout.addtext:setVisible(false)
                table.insert(self.m_petList, lyout)
            end
	       local xindex = (index)%5
        local yindex = math.floor((index)/5)
	    lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx + xindex * (lyout:getWidth().offset)), CEGUI.UDim(0.0, sy + yindex * (lyout:getHeight().offset))))
       
            lyout.NameText:setText(petData.name)  
            lyout.LevelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))        
            SetPetItemCellInfo2(lyout.petCell, petData) 
            lyout.chuzhan:setVisible(false) 
            if fightid == petData.key then
                lyout.chuzhan:setVisible(true) 
            end
            lyout:setVisible(true)
        else
            lyout:setVisible(false)            
        end
        index=index+1
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
end
function PetLianYaoDlg:handlePetIconSelected(args)
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

function PetLianYaoDlg:handleLockedPetIconClicked(args)
	local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
	cell:setMouseOnThisCell(false)
	print('locked cell', cell:GetIndex())
	
	require("logic.shop.npcpetshop").getInstanceAndShow()
end

function PetLianYaoDlg:refreshPetSprite(shapeID)
	if not shapeID then
		return
	end
	
	if not self.sprite then
		local pos = self.profileIcon:GetScreenPosOfCenter()
		local loc = Nuclear.NuclearPoint(pos.x, pos.y+50)
		self.sprite = UISprite:new(shapeID)
		if self.sprite then
			self.sprite:SetUILocation(loc)
			self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
			self.profileIcon:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, PetLianYaoDlg.performPostRenderFunctions))
		end
	else
		print('change sprite model id:', shapeID)
		self.sprite:SetModel(shapeID)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end
	
	self.elapse = 0
	self.defaultActCurTimes = 0
	self.actType = eActionStand
end

function PetLianYaoDlg.performPostRenderFunctions(id)
	if _instance and _instance:IsVisible() and _instance:GetWindow():getEffectiveAlpha() > 0.95 and _instance.selectedPetKey ~= 0 and _instance.sprite then
		_instance.sprite:RenderUISprite()
	end
end

function PetLianYaoDlg:update(dt)
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

--attribute view --------------------------------------------------------------------------
function PetLianYaoDlg:refreshAttributeView(petData)
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
		    --self.waigongzizhiBar:setProgress(curVal/petAttr.attackaptmax)
		    self.waigongzizhiBar:setProgress((curVal-petAttr.attackaptmin)/(petAttr.attackaptmax-petAttr.attackaptmin))

		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
		    self.fangyuzizhiBar:setText(curVal)
		    --self.fangyuzizhiBar:setProgress(curVal/petAttr.defendaptmax)
		    self.fangyuzizhiBar:setProgress((curVal-petAttr.defendaptmin)/(petAttr.defendaptmax-petAttr.defendaptmin))

		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
		    self.tilizizhiBar:setText(curVal)
		    --self.tilizizhiBar:setProgress(curVal/petAttr.phyforceaptmax)
		    self.tilizizhiBar:setProgress((curVal-petAttr.phyforceaptmin)/(petAttr.phyforceaptmax-petAttr.phyforceaptmin))

		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
		    self.neigongzizhiBar:setText(curVal)
		    --self.neigongzizhiBar:setProgress(curVal/petAttr.magicaptmax)
		    self.neigongzizhiBar:setProgress((curVal-petAttr.magicaptmin)/(petAttr.magicaptmax-petAttr.magicaptmin))

		    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
		    self.suduzizhiBar:setText(curVal)
		    --self.suduzizhiBar:setProgress(curVal/petAttr.speedaptmax)
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
        self.attack1:setText("0")
        self.attack1:setProgress(0)
        self.attack2:setText("0")
        self.attack2:setProgress(0)
        self.defense1:setText("0")
        self.defense1:setProgress(0)
        self.defense2:setText("0")
        self.defense2:setProgress(0)
        self.endurance1:setText("0")
        self.endurance1:setProgress(0)
        self.endurance2:setText("0")
        self.endurance2:setProgress(0)
        self.magic1:setText("0")
        self.magic1:setProgress(0)
        self.magic2:setText("0")
        self.magic2:setProgress(0)
        self.speed1:setText("0")
        self.speed1:setProgress(0)
        self.speed2:setText("0")
        self.speed2:setProgress(0)
        self:clearRightUiInfo()
	end
	
	self:refreshXiLianItem(petData)
end

function PetLianYaoDlg:refreshAttributeSkillView(petData)
	local skillnum = (petData and petData:getSkilllistlen() or 0)

	for i = 1, PET_SKILL_NORCOUNT do
		self.attriSkillBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
            local isSkillBind = petData:isSkillBind(skill.skillid)
			SetPetSkillBoxInfo(self.attriSkillBoxes[i], skill.skillid, petData, true, skill.certification, isSkillBind)
		end
	end
	self.skillAttriScroll:setVerticalScrollPosition(0)
end

function PetLianYaoDlg:handlefanhuiClicked(args)---返回
	PetLabel.Show(1)
end

function PetLianYaoDlg:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local dlg = PetSkillTipsDlg.ShowTip(cell:GetSkillID())

	if self.combineView:isVisible() then
		local pos = self:GetWindow():GetScreenPosOfCenter()
		SetPositionOffset(dlg:GetWindow(), pos.x+40, pos.y, 1, 0.5)
	else
		local pos = self:GetWindow():GetScreenPosOfCenter()
		SetPositionOffset(dlg:GetWindow(), pos.x-135, pos.y, 1, 0.5)
	end
	

end

function PetLianYaoDlg:refreshXiLianItem(petData)
	if petData then
		local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
		if not petConf then return end
		local washitem = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(petConf.washitemid)
		if not washitem then return end
		_washitemid = washitem.id
		_washitemname = washitem.name
		self.xilianItemName:setText(washitem.name)
		
		local img = gGetIconManager():GetImageByID(washitem.icon)
		self.xilianItem:SetImage(img)
		self.xilianItem:setID(washitem.id)
		
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local curNum = roleItemManager:GetItemNumByBaseID(petConf.washitemid)
		self.xilianItemCount:setText(curNum .. "/" .. petConf.washitemnum)
	else
		self.xilianItem:Clear()
		self.xilianItemName:setText("")
		self.xilianItemCount:setText("")
	end
end

function PetLianYaoDlg:recvWashSuccess()
	self.waitingForResult = false
	GetCTipsManager():AddMessageTipById(150059) --ϴ���ɹ�
	local s = self.tutengImg:getPixelSize()
	gGetGameUIManager():AddUIEffect(self.tutengImg, MHSD_UTILS.get_effectpath(11067), false, s.width*0.5, s.height*0.5+10)
	gGetGameUIManager():AddUIEffect(self.xilianEffectBg, MHSD_UTILS.get_effectpath(11067), false)
end----宠物洗炼动画

function PetLianYaoDlg:handleXiLianTipClicked(args)
	local xiLianTip = TextTip.CreateNewDlg()
	local str = MHSD_UTILS.get_msgtipstring(150045)
	local name = (self.selectedPetKey>0 and _washitemname or MHSD_UTILS.get_resstring(679))
	str = string.gsub(str, "%$parameter1%$", name)
	xiLianTip:setTipText(str)
end

function PetLianYaoDlg:handleConfirmXiLianClicked()
	
    self:sendxl()

	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

    self.firstXiLianPetKeys[self.selectedPetKey] = true
end

function PetLianYaoDlg:handleXiLianClicked(args)
	if self.waitingForResult then
		return
	end

	if self.selectedPetKey == 0 then
		return
	end
	

	
	if self.selectedPetKey == gGetDataManager():GetBattlePetID() then
		GetCTipsManager():AddMessageTipById(150047) --��ս���ﲻ�ܽ���ϴ��
		return
	end

	local petData = self:getSelectedPet()
	if petData then
		if petData.flag == 1 then
			GetCTipsManager():AddMessageTipById(150049) --�������ﲻ�ܽ���ϴ��
			return
		end
		
		if petData.flag == 2 then
			GetCTipsManager():AddMessageTipById(150048) --�󶨳��ﲻ�ܽ���ϴ��
			return
		end
	end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if not petConf then return end
	local curNum = roleItemManager:GetItemNumByBaseID(petConf.washitemid)
	if curNum < petConf.washitemnum then
		ShopManager:tryQuickBuy(petConf.washitemid, petConf.washitemnum-curNum)
		return
	end
	
    local bTreasure = isPetTreasure(petData)
	if bTreasure and petConf.unusualid == 5 then-----是否提示宠物是珍品 需不需要洗炼
        gGetMessageManager():AddConfirmBox(
			eConfirmNormal,
			MHSD_UTILS.get_msgtipstring(160314), --�˱�������Ʒ,�Ƿ����ϴ��
			PetLianYaoDlg.handleConfirmXiLianClicked,self,
			MessageManager.HandleDefaultCancelEvent,MessageManager
		)		
	elseif not self.firstXiLianPetKeys[self.selectedPetKey] then
        MessageBoxSimple.show(
            MHSD_UTILS.get_resstring(11117), --ϴ�������ó�����������ʺͼ��ܣ��Ƿ������
            PetLianYaoDlg.handleConfirmXiLianClicked, self
        )

    else
        self:sendxl()
	end

end

function PetLianYaoDlg:sendxl()

    local petData = self:getSelectedPet()
    local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if not petConf then
        return
    end

   if  (petConf.kind == fire.pb.pet.PetTypeEnum.VARIATION or petConf.kind == fire.pb.pet.PetTypeEnum.BABY ) and
        (petData.washcount==petConf.nskillnumfull-1)
     then
        local confirmDlg = require("logic.pet.petxlconfirm").getInstanceAndShow()
        if confirmDlg then
            confirmDlg:refreshSkill(petConf.id)
        end
    else
        self:confirmToSendxl()
    end
end

function PetLianYaoDlg:confirmToSendxl()
   local p = require("protodef.fire.pb.pet.cpetwash").Create()
   p.petkey = self.selectedPetKey
   LuaProtocolManager:send(p)

   self.waitingForResult = true
end

--skill view ------------------------------------------------------------------------------
function PetLianYaoDlg:refreshSkillView(petData)

	local skillnum = (petData and petData:getSkilllistlen() or 0)
	--self.learnSkillBoxes[PET_SKILL_ALLCOUNT]:setVisible(skillnum==PET_SKILL_ALLCOUNT)
	for i = 1, PET_SKILL_NORCOUNT do
		self.learnSkillBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
            local isSkillBind = petData:isSkillBind(skill.skillid)
			SetPetSkillBoxInfo(self.learnSkillBoxes[i], skill.skillid, petData, true, skill.certification, isSkillBind)
		end
	end
	self.skillLearnScroll:setVerticalScrollPosition(0)
	self.identifyBtn:setText( (petData and petData:getIdentifiedSkill()==nil) and MHSD_UTILS.get_resstring(11121) or MHSD_UTILS.get_resstring(11120) )
end

function PetLianYaoDlg:handleAddSkillClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local booktype = 49
	if e.window == self.internalbookItem then
		booktype = 50
	end
	if not PetAddSkillBook.getInstanceNotCreate() then 
		PetAddSkillBook.getInstanceAndShow(booktype)
	elseif PetAddSkillBook.getInstance().booktype ~= booktype then
		PetAddSkillBook:DestroyDialog()
		PetAddSkillBook.getInstanceAndShow(booktype)
	end
end

function PetLianYaoDlg:choosedSkillBookItem(booktype,itemkey, skillid)
    --SkillBoxControl.SetSkillInfo(self.bookItem, skillid)
    if booktype == 49 then
        SetPetSkillBoxInfo(self.bookItem, skillid)
        gGetGameUIManager():RemoveUIEffect(self.bookItem)
        self.bookItemKey = itemkey
        self.bookItemSkill = skillid

        -- 设置技能名称文本
        local skillConfig = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skillid)
        local skillName = skillConfig.skillname
        local winMgr = CEGUI.WindowManager:getSingleton()
        local nameText = winMgr:getWindow("petpropertyxilian_mtg/xuejineng/name")
        nameText:setText(skillName)
    else
        SetPetSkillBoxInfo(self.internalbookItem, skillid)
        gGetGameUIManager():RemoveUIEffect(self.internalbookItem)
        self.internalbookItemKey = itemkey
        self.internalbookItemSkill = skillid
    end
end

function PetLianYaoDlg:checkPetSkill()
	local petData = self:getSelectedPet()
	local skillnum = petData:getSkilllistlen()
	for i = 1, skillnum do
		local skill = petData:getSkill(i)
		if skill.skillid == self.bookItemSkill then
			return false
		end
	end
	return true
end

function PetLianYaoDlg:recvSkillIdentifySuccess(petkey, skillid, isconfirm)
	local str = MHSD_UTILS.get_msgtipstring(isconfirm==1 and 150076 or 150077)
	local petData = MainPetDataManager.getInstance():FindMyPetByID(petkey)
	str = string.gsub(str, "%$parameter1%$", petData.name)
	GetCTipsManager():AddMessageTip(str)
end

function PetLianYaoDlg:handleLearnClicked___(args)
	local p = require("protodef.fire.pb.pet.cpetlearnskillbybook"):new()
    p.petkey = 1000000
	p.bookkey = 1000000
	LuaProtocolManager:send(p)
end

function PetLianYaoDlg:handleLearnClicked(args)
	if self.selectedPetKey == 0 or self.bookItemKey == 0 then
		return
	end
	

    if GetBattleManager():IsInBattle() then    
	    if self.selectedPetKey == gGetDataManager():GetBattlePetID() then
		    GetCTipsManager():AddMessageTipById(150062) --ս���в��ܽ��д˲���
		    return
	    end
    end
	
	local petData = self:getSelectedPet()
	if petData then
		if petData.flag == 1 then
			GetCTipsManager():AddMessageTipById(150063) --�������ﲻ��ѧϰ����
			return
		end
	end

	if not self:checkPetSkill() then
		local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(self.bookItemSkill)
		local str = MHSD_UTILS.get_msgtipstring(150064)
		str = string.gsub(str, "%$parameter1%$", skillconfig.skillname)
		GetCTipsManager():AddMessageTip(str) --���ĳ����Ѿ�ѧϰxxx������
		return
	end
	
    local p = require("protodef.fire.pb.pet.cpetlearnskillbybook"):new()
    p.petkey = self.selectedPetKey
	p.bookkey = self.bookItemKey
	LuaProtocolManager:send(p)
	    -- 清除 bookItem 并添加按钮动画
    self.bookItemKey = 0
    self.bookItem:Clear()
    gGetGameUIManager():AddUIEffect(self.bookItem, MHSD_UTILS.get_effectpath(10374), true)
	
	local winMgr = CEGUI.WindowManager:getSingleton()
    local nameText = winMgr:getWindow("petpropertyxilian_mtg/xuejineng/name")
    nameText:setText("请放入兽决")
end

function PetLianYaoDlg:handleLearnTipClicked(args)
	local tip = TextTip.CreateNewDlg()
	tip:setTipText(MHSD_UTILS.get_msgtipstring(150060))
end

function PetLianYaoDlg:handleIdentifyClicked(args)
    -- ���޲��ܽ��з�����֤
    local petData = self:getSelectedPet()
  --  if petData.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then
   --     GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(162117))
   --     return
  --  end

    PetAddSkillBook.CloseIfExist()
    local dlg = PetSkillIdentify.getInstanceNotCreate()
	if not dlg or not dlg:IsVisible() then
		dlg = PetSkillIdentify.getInstanceAndShow()
		dlg:setPetData(self:getSelectedPet())
	end
end
function PetLianYaoDlg:handleIdentifyClicked1(args)
    -- 判断珍兽技能数量是否达到 8 个---
    local petData = self:getSelectedPet()
    if petData and petData:getSkilllistlen() >= 14 then--这里领悟技能最多8个
        GetCTipsManager():AddMessageTipById(193532)
        return
    end


    PetAddSkillBook.CloseIfExist()
    local dlg = PetSkillIdentifyLingWu.getInstanceNotCreate()
    if not dlg or not dlg:IsVisible() then
        dlg = PetSkillIdentifyLingWu.getInstanceAndShow()
        dlg:setPetData(self:getSelectedPet())
    end
end

function PetLianYaoDlg:handleIdentifyClicked11(args)
    local petData = self:getSelectedPet()
    if petData.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL  and petData.iszhenshou==1 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(162117))
        return
    end

    --  判断宠物技能数量是否少于 4 个
    if petData:getSkilllistlen() < 4 then
        GetCTipsManager():AddMessageTipById(193538) -- 发送提示信息
        return
    end

    PetAddSkillBook.CloseIfExist()
    local dlg = PetSkillIdentifyYiWang.getInstanceNotCreate()
    if not dlg or not dlg:IsVisible() then
        dlg = PetSkillIdentifyYiWang.getInstanceAndShow()
        dlg:setPetData(self:getSelectedPet())
    end
end

function PetLianYaoDlg:handleIdentifyTipClicked(args)
	local tip = TextTip.CreateNewDlg()
	tip:setTipText(MHSD_UTILS.get_msgtipstring(150061))
end

--combine view  下面是合宠----------------------------------------------------------------------------
function PetLianYaoDlg:handleAddCombinePetClicked(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)
	local id = (cell==self.combinePet1 and 1 or 2)
	local dlg = PetChooseDlg.getInstanceAndShow()
	 
	if id == 1 then
	    dlg:setIndex(id,self.combinePetKey2,self.combinePetKey1)
	else 
		dlg:setIndex(id,self.combinePetKey1,self.combinePetKey2)
	end 
end

function PetLianYaoDlg:setAttribute1(petData)
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
    self.attack1:setText(curVal)


    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
    self.defense1:setText(curVal)


    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
    self.endurance1:setText(curVal)


    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
    self.magic1:setText(curVal)


    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
    self.speed1:setText(curVal)


    curVal = math.floor(petData.growrate*1000) / 1000
    local str = string.format("%.3f",curVal)
	self.grow1:setText(str)
	if petAttr.growrate:size() > 1 then
		local maxgrow = petAttr.growrate[petAttr.growrate:size()-1] - petAttr.growrate[0]
		if maxgrow > 0 then
		--	self.grow1:setProgress((math.floor(petData.growrate*1000) - petAttr.growrate[0]) / maxgrow)
        else
		--	self.grow1:setProgress(1)
		end
	end
	local s1 = self.petmob1:getPixelSize()
    local sprite = gGetGameUIManager():AddWindowSprite(self.petmob1, tonumber(petAttr.modelid), Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)

    -- 读取默认染色
    sprite:SetDyePartIndex(0, petAttr.area1colour)  -- 设置区域 1 的颜色
    sprite:SetDyePartIndex(1, petAttr.area2colour)  -- 设置区域 2 的颜色
end

function PetLianYaoDlg:setAttribute2(petData)
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
    self.attack2:setText(curVal)


    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
    self.defense2:setText(curVal)


    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
    self.endurance2:setText(curVal)


    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
    self.magic2:setText(curVal)

    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
    self.speed2:setText(curVal)


    curVal = math.floor(petData.growrate*1000) / 1000
    local str = string.format("%.3f",curVal)
	self.grow2:setText(str)
	if petAttr.growrate:size() > 1 then
		local maxgrow = petAttr.growrate[petAttr.growrate:size()-1] - petAttr.growrate[0]
		if maxgrow > 0 then
		--	self.grow2:setProgress((math.floor(petData.growrate*1000) - petAttr.growrate[0]) / maxgrow)
        else
		--	self.grow2:setProgress(1)
		end
	end
	local s1 = self.petmob2:getPixelSize()
    local sprite = gGetGameUIManager():AddWindowSprite(self.petmob2, tonumber(petAttr.modelid), Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)

    -- 读取默认染色
    sprite:SetDyePartIndex(0, petAttr.area1colour)  -- 设置区域 1 的颜色
    sprite:SetDyePartIndex(1, petAttr.area2colour)  -- 设置区域 2 的颜色
end

function PetLianYaoDlg:addCombinePet(id, petData)----------合宠的动画0
	if id == 1 and petData.key == self.combinePetKey2 then
        self.combinePetKey2 = 0
        self.combinePet2:Clear()
        gGetGameUIManager():AddUIEffect(self.combinePet2, MHSD_UTILS.get_effectpath(11103), true)

    elseif id == 2 and petData.key == self.combinePetKey1 then
        self.combinePetKey1 = 0
        self.combinePet1:Clear()
        gGetGameUIManager():AddUIEffect(self.combinePet1, MHSD_UTILS.get_effectpath(11103), true)

    end
	
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid) -- 获取宠物属性配置
	
	if id == 1 then
		self.combinePetKey1 = petData.key
        self:setAttribute1(petData)
	else
		self.combinePetKey2 = petData.key
        self:setAttribute2(petData)
	end
	
	

	local petItemCell = (id==1 and self.combinePet1 or self.combinePet2)
	gGetGameUIManager():RemoveUIEffect(petItemCell)
	petItemCell:Clear()
	

	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData:GetShapeID())
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
 

	
    local aniMan = CEGUI.AnimationManager:getSingleton()
	self.animationOpen = aniMan:getAnimation("cchechong1")
	if id == 1 then
		if self.m_aniopen1Status ~= 1 then
			self.m_aniopen1Status=1
			self.leftpet:setVisible(true)
			self.m_aniopen1 = aniMan:instantiateAnimation(self.animationOpen)
			self.m_aniopen1:setTargetWindow(self.leftpet)
			self.leftpet:subscribeEvent("AnimationEnded", PetLianYaoDlg.HandleAnimationOver1, self)
			self.m_aniopen1:unpause()
		end
		-- 模型1号
        self.sprite1 = UISprite:new(petData.shape)
        self.sprite1 = gGetGameUIManager():AddWindowSprite(self.combinePet1, petData.shape, Nuclear.XPDIR_BOTTOMRIGHT, 50, 90, true)

        -- 判断是否染色过，选择合适的颜色
        if petData.petdye1 ~= 0 then
            self.sprite1:SetDyePartIndex(0, petData.petdye1) 
        else
            self.sprite1:SetDyePartIndex(0, petAttr.area1colour) 
        end
        if petData.petdye2 ~= 0 then
            self.sprite1:SetDyePartIndex(1, petData.petdye2)
        else
            self.sprite1:SetDyePartIndex(1, petAttr.area2colour)
        end
	else
		if self.m_aniopen2Status ~= 1 then
			self.m_aniopen2Status=1
			self.rightpet:setVisible(true)
			self.m_aniopen2 = aniMan:instantiateAnimation(self.animationOpen)
			self.m_aniopen2:setTargetWindow(self.rightpet)
			self.rightpet:subscribeEvent("AnimationEnded", PetLianYaoDlg.HandleAnimationOver2, self)
			self.m_aniopen2:unpause()
		end

        -- 模型2号
        self.sprite2 = UISprite:new(petData.shape)
        self.sprite2 = gGetGameUIManager():AddWindowSprite(self.combinePet2, petData.shape, Nuclear.XPDIR_BOTTOMRIGHT, 50, 90, true)

        -- 判断是否染色过，选择合适的颜色
        if petData.petdye1 ~= 0 then
            self.sprite2:SetDyePartIndex(0, petData.petdye1) 
        else
            self.sprite2:SetDyePartIndex(0, petAttr.area1colour) 
        end
        if petData.petdye2 ~= 0 then
            self.sprite2:SetDyePartIndex(1, petData.petdye2)
        else
            self.sprite2:SetDyePartIndex(1, petAttr.area2colour)
        end
	end

	self:refreshCombinePet(id, petData)
	
    if self.combinePetKey1 ~= 0 and self.combinePetKey2 ~= 0 then
        local petData1 = MainPetDataManager.getInstance():FindMyPetByID(self.combinePetKey1)
	    local petData2 = MainPetDataManager.getInstance():FindMyPetByID(self.combinePetKey2)
        self:setPreViewPetData(petData1, petData2)
    end
end




function PetLianYaoDlg:HandleAnimationOver1(args)
	self.m_aniopen1:stop()
	self.m_aniopen1Status=0
end
function PetLianYaoDlg:HandleAnimationOver2(args)
	self.m_aniopen2:stop()
	self.m_aniopen2Status=0
end

function PetLianYaoDlg:refreshCombinePet(idx, petData)

	if petData and petData:getIdentifiedSkill() ~= nil then
		petData = nil
	end
	
	if petData then
		local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
		self["cb_gongzi"..idx]:setText(curVal)

		curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
		self["cb_fangzi"..idx]:setText(curVal)
		
		curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
		self["cb_tizi"..idx]:setText(curVal)
		
		curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
		self["cb_fazi"..idx]:setText(curVal)
		
		curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
		self["cb_suzi"..idx]:setText(curVal)
		
		curVal = math.floor(petData.growrate*1000) / 1000
		self["cb_grow"..idx]:setText(curVal)
	else
	
		self.leftpet:setVisible(false)
		self.rightpet:setVisible(false)
		self["cb_gongzi"..idx]:setText("0")
		self["cb_fangzi"..idx]:setText("0")
		self["cb_tizi"..idx]:setText("0")
		self["cb_fazi"..idx]:setText("0")
		self["cb_suzi"..idx]:setText("0")
		self["cb_grow"..idx]:setText("0")
		
		self["combinePetKey"..idx] = 0
		self["combinePet"..idx]:Clear()
        if idx == 1 then
            self.attack1:setText("0")
     
            self.defense1:setText("0")
        
            self.endurance1:setText("0")
     
            self.magic1:setText("0")
      
            self.speed1:setText("0")

            self.grow1:setText("0")

        else
            self.attack2:setText("0")
  
            self.defense2:setText("0")
 
            self.endurance2:setText("0")

            self.magic2:setText("0")
    
            self.speed2:setText("0")

            self.grow2:setText("0")

        end
        self:clearRightUiInfo()
		gGetGameUIManager():AddUIEffect(self["combinePet"..idx], MHSD_UTILS.get_effectpath(11100), true)
	end
	local skillnum = (petData and petData:getSkilllistlen() or 0)
	if self.combinePetKey1 ~= 0 or self.combinePetKey2 ~= 0 then
        self.combineBtn1:setVisible(true)
    else
        self.combineBtn1:setVisible(false)
    end
	
	if self.combinePetKey1 ~= 0 and self.combinePetKey2 ~= 0 then
        self.cbTipBtn:setVisible(true)
    else
        self.cbTipBtn:setVisible(false)
    end
	
	if self.combinePetKey1 ~= 0 and self.combinePetKey2 ~= 0 then
        self.cbPreviewBtn:setVisible(false)
        self.gengduo:setVisible(true)
    else
        self.cbPreviewBtn:setVisible(true)
        self.gengduo:setVisible(false)
    end
	
	
	local skillnum = (petData and petData:getSkilllistlen() or 0)
	if skillnum == 0 then
		self["cb_skillBoxes"..idx][25]:setVisible(false)
	else
		self["cb_skillBoxes"..idx][25]:setVisible(false)
	end
	self["skillBoxes"..idx]={}
	for i = 1, 25 do
		self["cb_skillBoxes"..idx][i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
			table.insert(self["skillBoxes"..idx],skill.skillid)
			SetPetSkillBoxInfo(self["cb_skillBoxes"..idx][i], skill.skillid, petData, true, skill.certification)
		else
			table.insert(self["skillBoxes"..idx],0)
		end
	end
	self:checkSkill(idx)

	self["cb_skillScroll"..idx]:setVerticalScrollPosition(0)
	
	 if petData then
        -- 根据 idx 设置不同的宠物名字
        if idx == 1 then
            self.cb_cwname1:setText(petData.name)
            self.cb_cwleve1:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL).. "级")
            self.cb_cwpinfen1:setText("评分 ".. petData.score)		
        elseif idx == 2 then
            self.cb_cwname2:setText(petData.name)
            self.cb_cwleve2:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL).. "级")
            self.cb_cwpinfen2:setText("评分 ".. petData.score)
        end
    else
        -- 清空宠物名字、等级和评分
        self.cb_cwname1:setText("")
        self.cb_cwname2:setText("")
        self.cb_cwleve1:setText("")
        self.cb_cwleve2:setText("")
        self.cb_cwpinfen1:setText("")
        self.cb_cwpinfen2:setText("")
    end
	

end

function PetLianYaoDlg:checkSkill(idx)
	if idx == 1 then
		ids = 2
	else
		ids = 1
	end
	
	for i = 1, 25 do
		self["cb_skillBoxes"..idx.."xiangtong"][i]:setVisible(false)
		self["cb_skillBoxes"..ids.."xiangtong"][i]:setVisible(false)
	end
	for i, value1 in ipairs(self["skillBoxes"..idx]) do
		for s, value2 in ipairs(self["skillBoxes"..ids]) do
			if value2~=0 then
				if value1==value2 then
				self["cb_skillBoxes"..idx.."xiangtong"][i]:setVisible(true)
				self["cb_skillBoxes"..ids.."xiangtong"][s]:setVisible(true)
				--print(i..'===='..s)
				end
			end
		end
	end
end

function PetLianYaoDlg:handleFreeGDAOnClicked()
	self.annUI:setVisible(true)
	self.gengduo:setVisible(true)
	self.gengduoa:setVisible(true)
end
function PetLianYaoDlg:handleFreeGDOnClicked()
	self.gengduo:setVisible(true)
	self.gengduoa:setVisible(true)
end


function PetLianYaoDlg:showCombineResultDlg()
	if self.effectEnd and self.resultPetKey then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(self.resultPetKey)
		local dlg = PetCombineResultDlg.getInstanceAndShow()
		dlg:setPetData(petData)
		self:refreshSelectedPet(petData)
		
		self.effectEnd = nil
		self.resultPetKey = nil
	end
end

function PetLianYaoDlg:recvCombineSuccess(petKey)
	self.resultPetKey = petKey
	self:showCombineResultDlg()
end




function PetLianYaoDlg.onEffectEnd()
	if _instance then
		_instance.effectEnd = true
		_instance:showCombineResultDlg()
	end
end

function PetLianYaoDlg:handleCombinePreviewClicked(args)
	if self.combinePetKey1 == 0 or self.combinePetKey2 == 0 then
		GetCTipsManager():AddMessageTipById(150057) 
		return
	end
	debugrequire('logic.pet.petpreviewdlg')
	local dlg = PetPreviewDlg.getInstanceAndShow()
	
	local petData1 = MainPetDataManager.getInstance():FindMyPetByID(self.combinePetKey1)
	local petData2 = MainPetDataManager.getInstance():FindMyPetByID(self.combinePetKey2)
	dlg:setPetData(petData1, petData2)
end



function PetLianYaoDlg:addCombineEffect()
    local effect = gGetGameUIManager():AddUIEffect(self.combineBtn, MHSD_UTILS.get_effectpath(11005), false) --合宠
    if effect then
        effect:AddNotify(GameUImanager:createNotify(self.onEffectEnd))
    end
end



function PetLianYaoDlg:handleCombineClicked(args)
	if self.combinePetKey1 == 0 or self.combinePetKey2 == 0 then
        GetCTipsManager():AddMessageTipById(150087) 
		return
	end
    local petData11 = MainPetDataManager.getInstance():FindMyPetByID(self.combinePetKey1)
    local petData12 = MainPetDataManager.getInstance():FindMyPetByID(self.combinePetKey2)
	local hasInternal1 = false
	local hasInternal2 = false
	
	for k, v in ipairs(petData11.petinternallist) do
		if v.skillid and v.skillid > 0 then
			hasInternal1 = true
			break
		end
	end
	
	for k, v in ipairs(petData12.petinternallist) do
		if v.skillid and v.skillid > 0 then
			hasInternal2 = true
			break
		end
	end
	
	if hasInternal1 or hasInternal2 then
        GetCTipsManager():AddMessageTipById(192301) 
		return
	end
	if self.m_aniopen1 then
	 	local aniMan = CEGUI.AnimationManager:getSingleton()
	 	aniMan:destroyAnimationInstance(self.m_aniopen1)
	 end
	 if self.m_aniopen2 then
	 	local aniMan = CEGUI.AnimationManager:getSingleton()
	 	aniMan:destroyAnimationInstance(self.m_aniopen2)
	 end
	self.m_aniopen1Status = 0
	self.m_aniopen2Status = 0
 
    local petData1 = MainPetDataManager.getInstance():FindMyPetByID(self.combinePetKey1)
	local skillnum1 = petData1:getSkilllistlen()
    local petAttr1 = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData1.baseid)
    local petBasicSkillNum1 = petAttr1.skillid._size
	for i = 1, skillnum1 do
		local skill = petData1:getSkill(i)
        for j = 1 , petBasicSkillNum1 do
		    if skill.skillid == petAttr1.skillid[j-1] then
			    if petAttr1.skillrate[j-1] >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(323).value) then
		
                    local strMsg =  require "utils.mhsdutils".get_msgtipstring(162161)
                    local function ClickYes(args)
                        self:addCombineEffect()
	                    local p = require("protodef.fire.pb.pet.cpetsynthesize").Create()
	                    p.petkey1 = self.combinePetKey1
	                    p.petkey2 = self.combinePetKey2
	                    LuaProtocolManager:send(p)
                        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
                    end
                    gGetMessageManager():AddConfirmBox(eConfirmNormal, strMsg, ClickYes, 0, MessageManager.HandleDefaultCancelEvent, MessageManager)
                    return
	            end
		    end
        end
	end
	local petData2 = MainPetDataManager.getInstance():FindMyPetByID(self.combinePetKey2)
    local skillnum2 = petData2:getSkilllistlen()
    local petAttr2 = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData2.baseid)
    local petBasicSkillNum2 = petAttr1.skillid._size
	for i = 1, skillnum2 do
		local skill = petData2:getSkill(i)
        for j = 1, petBasicSkillNum2 do
		    if skill.skillid == petAttr2.skillid[j-1] then
			    if petAttr2.skillrate[j-1] >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(323).value) then
		            -- �ش�
                    local strMsg =  require "utils.mhsdutils".get_msgtipstring(162161)
                    local function ClickYes(args)
                        self:addCombineEffect()
	                    local p = require("protodef.fire.pb.pet.cpetsynthesize").Create()
	                    p.petkey1 = self.combinePetKey1
	                    p.petkey2 = self.combinePetKey2
	                    LuaProtocolManager:send(p)
                        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
                    end
                    gGetMessageManager():AddConfirmBox(eConfirmNormal, strMsg, ClickYes, 0, MessageManager.HandleDefaultCancelEvent, MessageManager)
                    return
	            end
		    end
        end
	end

	for i = 1,skillnum1 do
        local skill = petData1:getSkill(i)
        for j = 1,skillnum2 do
            local skill2 = petData2:getSkill(j)
            if skill.skillid == skill2.skillid then
                local strMsg =  require "utils.mhsdutils".get_msgtipstring(162162)
                local function ClickYes(args)
                    self:addCombineEffect()
	                local p = require("protodef.fire.pb.pet.cpetsynthesize").Create()
	                p.petkey1 = self.combinePetKey1
	                p.petkey2 = self.combinePetKey2
	                LuaProtocolManager:send(p)
                    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
                end
                gGetMessageManager():AddConfirmBox(eConfirmNormal, strMsg, ClickYes, 0, MessageManager.HandleDefaultCancelEvent, MessageManager)
                return                
            end
        end
    end
	self:addCombineEffect()
	local p = require("protodef.fire.pb.pet.cpetsynthesize").Create()
	p.petkey1 = self.combinePetKey1
	p.petkey2 = self.combinePetKey2
	LuaProtocolManager:send(p)
end

function PetLianYaoDlg:handleCombineTipClicked(args)
	local xiLianTip = TextTip.CreateNewDlg()
	local str = MHSD_UTILS.get_msgtipstring(150050)
	xiLianTip:setTipText(str)
	SetPositionScreenCenter(xiLianTip.back)
end

-------------------------------------------------------------------------------------------
function PetLianYaoDlg.onEventMainPetRefresh()
	print('PetLianYaoDlg.onEventMainPetRefresh')
	if not _instance or not _instance:IsVisible() then
		return
	end
	_instance:refreshPetTableOnProfileViewData()
	if _instance.selectedPetKey == gGetDataManager():GetBattlePetID() then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.selectedPetKey)
        if petData then
		    _instance:refreshSelectedPet(petData)
        end
	end
end

function PetLianYaoDlg.onEventPetBattleStateChange()
	print('PetLianYaoDlg.onEventPetBattleStateChange')
	if not _instance or not _instance:IsVisible() then
		return
	end
end

function PetLianYaoDlg.onEventPetNumChange()
	print('PetLianYaoDlg.onEventPetNumChange')
	if not _instance or not _instance:IsVisible() then
		return
	end
	_instance:refreshPetTableOnProfileViewData()
	local defaultPet = MainPetDataManager.getInstance():FindMyPetByID(_instance.selectedPetKey) or MainPetDataManager.getInstance():getPet(1)
	_instance:refreshSelectedPet(defaultPet)
	
	if _instance.combinePetKey1 > 0 and not MainPetDataManager.getInstance():FindMyPetByID(_instance.combinePetKey1) then
		_instance:refreshCombinePet(1, nil)
	end
	
	if _instance.combinePetKey2 > 0 and not MainPetDataManager.getInstance():FindMyPetByID(_instance.combinePetKey2) then
		_instance:refreshCombinePet(2, nil)
	end
end

function PetLianYaoDlg.onEventPetDataChange(key)
	print('PetLianYaoDlg.onEventPetDataChange', key, _instance.selectedPetKey)
	if not _instance or not _instance:IsVisible() then
		return
	end
	_instance:refreshPetTableOnProfileViewData()
	if _instance.selectedPetKey == key then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.selectedPetKey)
		_instance:refreshSelectedPet(petData)
	end
	
	if _instance.combinePetKey1 == key then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.combinePetKey1)
		_instance:refreshCombinePet(1, petData)
	elseif _instance.combinePetKey2 == key then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.combinePetKey2)
		_instance:refreshCombinePet(2, petData)
	end
end

function PetLianYaoDlg.onEventPetSkillChange(key)
	print('PetLianYaoDlg.onEventPetSkillChange')
	if not _instance or not _instance:IsVisible() then
		return
	end
	if _instance.selectedPetKey == key then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.selectedPetKey)
		_instance:refreshSkillView(petData)
		_instance:refreshAttributeSkillView(petData)
	end
	
	if _instance.combinePetKey1 == key then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.combinePetKey1)
		_instance:refreshCombinePet(1, petData)
	elseif _instance.combinePetKey2 == key then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.combinePetKey2)
		_instance:refreshCombinePet(2, petData)
	end
end
function PetLianYaoDlg.OnEventItemNumChange(bagid, itemkey, itembaseid)
	print('PetLianYaoDlg.OnEventItemNumChange')
	if not _instance or not _instance:IsVisible() or bagid ~= fire.pb.item.BagTypes.BAG then
		return
	end
	
	if _washitemid == itembaseid then
		local petData = _instance:getSelectedPet()
		_instance:refreshXiLianItem(petData)
	elseif _instance.bookItemKey == itemkey then
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
		if not item then
			_instance.bookItemKey = 0
			_instance.bookItem:Clear()
			gGetGameUIManager():AddUIEffect(_instance.bookItem, MHSD_UTILS.get_effectpath(10374), true)
		end
	end
end

function PetLianYaoDlg:getAttrMaxValue(petBaseId, attrType)
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petBaseId)
    if conf then
	    if attrType == fire.pb.attr.AttrType.PET_ATTACK_APT then --����
		    return conf.attackaptmax
	    elseif attrType == fire.pb.attr.AttrType.PET_DEFEND_APT then --����
		    return conf.defendaptmax
	    elseif attrType == fire.pb.attr.AttrType.PET_PHYFORCE_APT then --����
		    return conf.phyforceaptmax
	    elseif attrType == fire.pb.attr.AttrType.PET_MAGIC_APT then --����
		    return conf.magicaptmax
	    elseif attrType == fire.pb.attr.AttrType.PET_SPEED_APT then --����
		    return conf.speedaptmax
	    end
    end
	return 0
end

function PetLianYaoDlg:getAttrRange(attrType)
	local v1 = self.petData1:getAttribute(attrType)
	local v2 = self.petData2:getAttribute(attrType)
	
	--ͨ��ȡֵ��Χ
	local low = GameTable.common.GetCCommonTableInstance():getRecorder(102).value --����ϳ���������ȡֵ
	local up = GameTable.common.GetCCommonTableInstance():getRecorder(103).value --����ϳ���������ȡֵ

	local min = math.floor((v1 + v2) / 2 * low)
	local max = math.floor((v1 + v2) / 2 * up)

	--���2ֻ�趼�Ǳ����, �������ɵ����ʡ���ֻ��֮���������޸ߵĳ����������
	if self.petData1.kind == fire.pb.pet.PetTypeEnum.VARIATION and
	   self.petData2.kind == fire.pb.pet.PetTypeEnum.VARIATION then
		local maxAttr1 = self:getAttrMaxValue(self.petData1.baseid, attrType)
		local maxAttr2 = self:getAttrMaxValue(self.petData2.baseid, attrType)
		max = math.min(max, math.max(maxAttr1, maxAttr2))

	--���1ֻ���Ǳ���1ֻ������ͨ:
	--����ͨ����������*1.08�����������ʱȽϣ��Ըߵ�һ����Ϊ���ɳ�������������
	elseif self.petData1.kind == fire.pb.pet.PetTypeEnum.BABY and
		   self.petData2.kind == fire.pb.pet.PetTypeEnum.VARIATION then
		local maxAttr1 = math.floor(self:getAttrMaxValue(self.petData1.baseid, attrType) * up)
		local maxAttr2 = self:getAttrMaxValue(self.petData2.baseid, attrType)
		max = math.min(max, math.max(maxAttr1, maxAttr2))

	elseif self.petData1.kind == fire.pb.pet.PetTypeEnum.VARIATION and
		   self.petData2.kind == fire.pb.pet.PetTypeEnum.BABY then
		local maxAttr1 = self:getAttrMaxValue(self.petData1.baseid, attrType)
		local maxAttr2 = math.floor(self:getAttrMaxValue(self.petData2.baseid, attrType) * up)
		max = math.min(max, math.max(maxAttr1, maxAttr2))
	end

	return min .. "-" .. max
end

function PetLianYaoDlg:getGrowRange()
	local v1 = self.petData1.growrate
	local v2 = self.petData2.growrate
	
	local low = GameTable.common.GetCCommonTableInstance():getRecorder(104).value/1000 --����ϳɳɳ����޼���ֵ
	local up = GameTable.common.GetCCommonTableInstance():getRecorder(105).value/1000 --����ϳɳɳ���������ֵ
	
	local min = math.floor(((v1 + v2) / 2 - low)*1000)/1000
	local max = math.floor(((v1 + v2) / 2 + up)*1000)/1000
	return min .. "-" .. max
end

function PetLianYaoDlg:clearRightUiInfo()
    self.itemcell1:Clear()
    self.itemcell2:Clear()
    self.attack3:setText("1000-2000")
    self.defense3:setText("1000-2000")
    self.endurance3:setText("1000-2000")
    self.magic3:setText("1000-2000")
    self.speed3:setText("1000-2000")
    self.attack3:setText("1000-2000")
    self.grow3:setText("1000-2000")

	local pet2allcount = PET_SKILL_NORCOUNT * 2
    if self.allSkills then
        for i=1,pet2allcount do
            if self.finalSkillBoxes[i] then
                self.finalSkillBoxes[i]:Clear()
                if i > PET_SKILL_NORCOUNT then
                    CEGUI.WindowManager:getSingleton():destroyWindow(self.finalSkillBoxes[i])
                    self.finalSkillBoxes[i] = nil
                end
            else
                break
            end
	    end
    end
	local s1 = self.petmob1:getPixelSize()
	gGetGameUIManager():AddWindowSprite(self.petmob1,  0, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
	local s1 = self.petmob2:getPixelSize()
	gGetGameUIManager():AddWindowSprite(self.petmob2,  0, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
end

function PetLianYaoDlg:setPreViewPetData(petData1, petData2)
	self.petData1 = petData1
	self.petData2 = petData2

    local petAttr1 = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData1.baseid)
    local petAttr2 = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData2.baseid)
    if not petAttr1 or not petAttr2 then
        return
    end
	
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData1:GetShapeID())
    SetItemCellBoundColorByQulityPet(self.itemcell1, petAttr1.quality)
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.itemcell1:SetImage(image)
	self.itemcell1:SetTextUnit(petData1:getAttribute(fire.pb.attr.AttrType.LEVEL))
	--self.petName1:setText(petData1.name)
	
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData2:GetShapeID())
    SetItemCellBoundColorByQulityPet(self.itemcell2, petAttr2.quality)
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.itemcell2:SetImage(image)
	self.itemcell2:SetTextUnit(petData2:getAttribute(fire.pb.attr.AttrType.LEVEL))
	

	self.attack3:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_ATTACK_APT) )
	self.defense3:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_DEFEND_APT) )
	self.endurance3:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_PHYFORCE_APT) )
	self.magic3:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_MAGIC_APT) )
	self.speed3:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_SPEED_APT) )
	self.grow3:setText( self:getGrowRange() )
	

	self.allSkills = {}
	self.skillidMap = {}

    --���ӳ���1����
	local skillnum = petData1:getSkilllistlen()
	for i=1, skillnum do
		local skill = petData1:getSkill(i)
		local t = {[1]=skill, [2]=petData1}
		table.insert(self.allSkills, t)
		self.skillidMap[skill.skillid] = t
	end
	
    --���ӳ���2�ļ���
	skillnum = petData2:getSkilllistlen()
	for i=1, skillnum do
		local skill = petData2:getSkill(i)
		if not self.skillidMap[skill.skillid] then
			local t = {[1]=skill, [2]=petData2}
			table.insert(self.allSkills, t)
			self.skillidMap[skill.skillid] = t
		end
	end

     --���ش�����
    local pos = 1
    for i=0, petAttr1.skillid:size()-1 do
        local skillid = petAttr1.skillid[i]
		if skillid ~= 0 and petAttr1.skillrate[i] >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(323).value) and not self.skillidMap[skillid] then
			local skill = {skillid=skillid, certification=0}
            local t = {[1]=skill, [2]=petData1}
			table.insert(self.allSkills, pos, t)
			self.skillidMap[skillid] = t
            pos = pos+1
		end
	end

    for i=0, petAttr2.skillid:size()-1 do
        local skillid = petAttr2.skillid[i]
		if skillid ~= 0 and petAttr2.skillrate[i] >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(323).value) and not self.skillidMap[skillid] then
			local skill = {skillid=skillid, certification=0}
            local t = {[1]=skill, [2]=petData2}
			table.insert(self.allSkills, pos, t)
			self.skillidMap[skillid] = t
            pos = pos+1
		end
	end

	local pet2allcount = 2*PET_SKILL_NORCOUNT
    for i=1,pet2allcount do
        if self.finalSkillBoxes[i] then
            self.finalSkillBoxes[i]:Clear()
            if i > PET_SKILL_NORCOUNT then
                CEGUI.WindowManager:getSingleton():destroyWindow(self.finalSkillBoxes[i])
                self.finalSkillBoxes[i] = nil
            end
        else
            break
        end
	end
	--���ܴ���16���������µĸ���
	local more = 0
	if #self.allSkills > PET_SKILL_NORCOUNT then
        local left = self.finalSkillBoxes[1]:getXPosition().offset
        local width = self.finalSkillBoxes[1]:getPixelSize().width
        local height = self.finalSkillBoxes[1]:getPixelSize().height 
        local top = self.finalSkillBoxes[1]:getYPosition().offset
        local deltaX = self.finalSkillBoxes[2]:getXPosition().offset - left
        local deltaY = self.finalSkillBoxes[5]:getYPosition().offset - top
		--self.moreSkillTip:setVisible(true)
		local winMgr = CEGUI.WindowManager:getSingleton()
		more = #self.allSkills-PET_SKILL_NORCOUNT
		for i=1, more do
			local skillbox = CEGUI.toSkillBox(winMgr:createWindow("TaharezLook/SkillBox1"))
			skillbox:setSize(CEGUI.UVector2(CEGUI.UDim(0,90), CEGUI.UDim(0,90)))
			local row = math.ceil((i+PET_SKILL_NORCOUNT)/4)
			local col = (i+PET_SKILL_NORCOUNT)%4
            if col == 0 then
                col = 4
            end
			--SetPositionOffset(skillbox, left + deltaX * (col - 1), top + deltaY * (row-1))

            skillbox:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, left + deltaX * (col - 1)), CEGUI.UDim(0.0, top + deltaY * (row-1))))
			skillbox:subscribeEvent("MouseClick", PetPreviewDlg.handleSkillClicked, self)
			self.finalSkillBoxes[PET_SKILL_NORCOUNT+i] = skillbox
			self.skillScroll:addChildWindow(skillbox)
		end
	end
	
	for i = 1, PET_SKILL_NORCOUNT+more do
		self.finalSkillBoxes[i]:Clear()
		if i <= #self.allSkills then
			local skill = self.allSkills[i][1]
			SetPetSkillBoxInfo(self.finalSkillBoxes[i], skill.skillid, self.allSkills[i][2], true, skill.certification)
		end
	end
end

function PetLianYaoDlg:checkPetInternal()
	local petData = self:getSelectedPet()
	local skillnum = petData:getInternallistlen()
	for i = 1, skillnum do
		local skill = petData:getInternal(i)
		if skill.skillid == self.internalbookItemSkill then
			return false
		end
	end
	return true
end


function PetLianYaoDlg:handleLearnInternalClicked(args)
    if self.selectedPetKey == 0  then 
        return
    end

    if GetBattleManager():IsInBattle() then    
        if self.selectedPetKey == gGetDataManager():GetBattlePetID() then
            GetCTipsManager():AddMessageTipById(150062)
            return
        end
    end
    
    local petData = self:getSelectedPet()
    if petData then
        if petData.flag == 1 then
            GetCTipsManager():AddMessageTipById(150063) 
            return
        end
    end
    
    --  检查是否添加了内丹
    if self.internalbookItemKey == 0 then
        GetCTipsManager():AddMessageTipById(193537)
        return
    end

    -- 检查是否已学习该内丹
    if not self:checkPetInternal() then
        local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(self.internalbookItemSkill)
        local str = MHSD_UTILS.get_msgtipstring(150064)
        str = string.gsub(str, "%$parameter1%$", skillconfig.skillname)
        GetCTipsManager():AddMessageTip(str) 
        return
    end

    local function getLearnInternalIdx(curPetData, skillId)
        local skillType = math.floor((skillId or 0) / 10000)
        if skillType == 27 then
            return 6
        elseif skillType == 28 then
            return 5
        elseif skillType == 26 then
            for i = 1, 4 do
                local curInternal = curPetData and curPetData:getInternal(i) or nil
                if (not curInternal) or curInternal.skillid == 0 then
                    return i
                end
            end
        end
        return 0
    end
    local learnIdx = getLearnInternalIdx(petData, self.internalbookItemSkill)
    if learnIdx <= 0 then
        GetCTipsManager():AddMessageTipById(201090)
        return
    end

    local p = require("protodef.fire.pb.pet.cpetlearninternalbybook"):new()
    p.petkey = self.selectedPetKey
    p.bookkey = self.internalbookItemKey
    p.idx = learnIdx
    --  不需要添加 p.internalid
    LuaProtocolManager:send(p)
    self.internalbookItemKey = 0
    self.internalbookItem:Clear()
    gGetGameUIManager():AddUIEffect(self.internalbookItem, MHSD_UTILS.get_effectpath(10374), true)
end

function PetLianYaoDlg:handleInternalClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	self.internalSelectId = cell:GetSkillID()
	--self:refreshInternalLevelup()
	for i=1,PET_INTERNAL_NORCOUNT do
		if self.learnInternlBoxes[i] == cell then
			self.learnInternlBoxes[i]:SetSelected(true)
		else
			self.learnInternlBoxes[i]:SetSelected(false)
		end
	end
	if cell:GetSkillID() == 0 then
		return
	end

	local dlg = PetSkillTipsDlg.ShowTip(cell:GetSkillID())

	if self.combineView:isVisible() then
		local pos = self:GetWindow():GetScreenPosOfCenter()
		SetPositionOffset(dlg:GetWindow(), pos.x+40, pos.y, 1, 0.5)
	else
		local pos = self:GetWindow():GetScreenPosOfCenter()
		SetPositionOffset(dlg:GetWindow(), pos.x-135, pos.y, 1, 0.5)
	end
	
end

function PetLianYaoDlg:refreshInternalView(petData)

	local skillnum = (petData and petData:getInternallistlen() or 0)
	for i = 1, PET_INTERNAL_NORCOUNT do
		self.learnInternlBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getInternal(i)
            local isSkillBind = petData:isSkillBind(skill.skillid)
			SetPetSkillBoxInfo(self.learnInternlBoxes[i], skill.skillid, petData, true, skill.certification, isSkillBind)
		end
	end
	petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
	--if petAttr.iszhenshou == 1 then
     --   self.identifyBtn:setVisible(false)
    --    self.identifyBtn1:setVisible(true)
	--	self.identifyBtn11:setVisible(true)
	--	self.learnBtn:setVisible(false)
	--	self.bookItem:setVisible(false)
   -- else
        self.identifyBtn:setVisible(true)
        self.identifyBtn1:setVisible(false)
		self.identifyBtn11:setVisible(false)
		self.learnBtn:setVisible(true)
		self.bookItem:setVisible(true)
    --end
	self.skillLearnScroll:setVerticalScrollPosition(0)
	self.identifyBtn:setText( (petData and petData:getIdentifiedSkill()==nil) and MHSD_UTILS.get_resstring(11121) or MHSD_UTILS.get_resstring(11120) )
	self.identifyBtn1:setText( (petData and petData:getIdentifiedSkill()==nil) and MHSD_UTILS.get_resstring(11708) or MHSD_UTILS.get_resstring(11708) )
	self.identifyBtn11:setText( (petData and petData:getIdentifiedSkill()==nil) and MHSD_UTILS.get_resstring(11711) or MHSD_UTILS.get_resstring(11711) )
end

function PetLianYaoDlg.onEventPetInternalChange(key)
	print('PetLianYaoDlg.onEventPetInternalChange')
	if not _instance or not _instance:IsVisible() then
		return
	end
	if _instance.selectedPetKey == key then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(_instance.selectedPetKey)
		_instance:refreshInternalView(petData)
	end

end

function PetLianYaoDlg:handleLearnInternalTipClicked( args )
	if Addndpointintro.getInstanceNotCreate() then
		Addndpointintro.DestroyDialog()
		return
	end
	local dlg = Addndpointintro.getInstanceAndShow(self.ccharecterinfo);
end	



function PetLianYaoDlg:xuechuClicked(args)
	if self.internalSelectId == 0 then
		return
	end
	local p = require("protodef.fire.pb.pet.cxiechuneidan"):new()
	p.internalid = self.internalSelectId
	p.petkey = self.selectedPetKey
	LuaProtocolManager:send(p)
	self.internalSelectId = 0
end


return PetLianYaoDlg

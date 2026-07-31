require "logic.dialog"

CharacterProDlg = { }
setmetatable(CharacterProDlg, Dialog)
CharacterProDlg.__index = CharacterProDlg

local _instance

local EnumBtnState = { Base = 1, Adn = 2 }

function CharacterProDlg.getInstance()
    if not _instance then
        _instance = CharacterProDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function CharacterProDlg.getInstanceAndShow()
    if not _instance then
        _instance = CharacterProDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function CharacterProDlg.getInstanceNotCreate()
    return _instance
end

function CharacterProDlg.DestroyDialog()
    if _instance then
	_instance.m_btnToHonorDlg.animation:stop()
	_instance.m_btnUseActi.animation:stop()
	_instance.m_btnIntro.animation:stop()
	_instance.cc_qiehuan.animation:stop()
	_instance.m_btnAddzhuanzhic.animation:stop()
        local characterprodlg = require "logic.characterinfo.characterprodlg".getInstanceNotCreate()
		
        if characterprodlg.spine then
            characterprodlg.spine:delete()
            characterprodlg.spine = nil
        end
		
		if characterprodlg.spriteBack then
            characterprodlg.spriteBack:getGeometryBuffer():setRenderEffect(nil)
        end
		
		if _instance.animationInstance then 
            _instance.animationInstance:stop()
            _instance.animationInstance = nil 
        end
		
		
        gGetDataManager().m_EventMainCharacterDataChange:RemoveScriptFunctor(characterprodlg.m_eventData)
        gGetDataManager().m_EventMainCharacterExpChange:RemoveScriptFunctor(characterprodlg.m_eventExp)
        gGetDataManager().m_EventMainCharacterHpMpChange:RemoveScriptFunctor(characterprodlg.m_eventHpMp)
        gGetDataManager().m_EventMainBattlerAttributeChange:RemoveScriptFunctor(characterprodlg.m_eventMainBattlerAtt)
        gGetDataManager().m_EventExtendSkillMapChange:RemoveScriptFunctor(characterprodlg.m_eventSkillMap)
        gGetDataManager().m_EventMainCharacterQiLiChange:RemoveScriptFunctor(characterprodlg.m_eventQili)

        Dialog.OnClose(_instance)
        _instance = nil

    end
end


function CharacterProDlg.ToggleOpenClose()
    if not _instance then
        _instance = CharacterProDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function CharacterProDlg.GetLayoutFileName()
    return "characterproperty.layout"
end

function CharacterProDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, CharacterProDlg)
    return self
end

function CharacterProDlg:addButtonAnimation(button, animationName)
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

function CharacterProDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	local scrollPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("CharacterPropertyDlg/text4/huadong1"))
    local ccPrefix = "CharacterPropertyDlg/text4/cc"
    for i = 1, 14 do
       self["m_cc" .. i] = winMgr:getWindow(ccPrefix .. i)
       scrollPane:addChildWindow(self["m_cc" .. i])
    end
	
    self.m_eventData = gGetDataManager().m_EventMainCharacterDataChange:InsertScriptFunctor(CharacterProDlg.UpdateProData)
    self.m_eventExp = gGetDataManager().m_EventMainCharacterExpChange:InsertScriptFunctor(CharacterProDlg.UpdateProData)
    self.m_eventHpMp = gGetDataManager().m_EventMainCharacterHpMpChange:InsertScriptFunctor(CharacterProDlg.UpdateProData)
    self.m_eventMainBattlerAtt = gGetDataManager().m_EventMainBattlerAttributeChange:InsertScriptFunctor(CharacterProDlg.UpdateProData)
    self.m_eventSkillMap = gGetDataManager().m_EventExtendSkillMapChange:InsertScriptFunctor(CharacterProDlg.UpdateProData)
    self.m_eventQili = gGetDataManager().m_EventMainCharacterQiLiChange:InsertScriptFunctor(CharacterProDlg.UpdateProData)
    SetPositionOfWindowWithLabel(self:GetWindow())
	
    self.m_bg = CEGUI.toFrameWindow(winMgr:getWindow("CharacterPropertyDlg"))
    self.m_txtPlayerName = winMgr:getWindow("CharacterPropertyDlg/left/diban/baojudaduiduizhang")
    self.m_txtLvl = winMgr:getWindow("CharacterPropertyDlg/left/diban/LvNum")
	self.m_txtLvl:setProperty("TextColours", "FFFFFFFF")
	
	self.cc_chenwei = winMgr:getWindow("CharacterPropertyDlg/left/chengwei")
	self.cc_chenwei:setProperty("TextColours", "FFFFFFFF")
	
    self.m_txtZsl = winMgr:getWindow("CharacterPropertyDlg/left/diban/zsNum")
    self.m_txtID = winMgr:getWindow("CharacterPropertyDlg/left/123456")
    self.m_txtHonour = winMgr:getWindow("CharacterPropertyDlg/left/text2/jinshi")
    self.m_btnToHonorDlg = CEGUI.toPushButton(winMgr:getWindow("CharacterPropertyDlg/left/chengweibutton"))
	self:addButtonAnimation(self.m_btnToHonorDlg, "studyBtnPress")--
    self.m_imgSchool = winMgr:getWindow("CharacterPropertyDlg/left/zhiyetubiao")
    self.m_btnNormalPro = CEGUI.toGroupButton(winMgr:getWindow("CharacterPropertyDlg/jichu"))
    self.m_btnNormalPro:SetMouseLeaveReleaseInput(false)
    self.m_btnAdvnPro = CEGUI.toGroupButton(winMgr:getWindow("CharacterPropertyDlg/gaoji"))
    self.m_btnAdvnPro:SetMouseLeaveReleaseInput(false)
    self.m_btnIntro = CEGUI.toPushButton(winMgr:getWindow("CharacterPropertyDlg/tishibutton"))
	self:addButtonAnimation(self.m_btnIntro, "studyBtnPress")--
    self.m_gressExp = CEGUI.toProgressBar(winMgr:getWindow("CharacterPropertyDlg/jingyantiao"))
    self.m_txtExpSurplus = winMgr:getWindow("CharacterPropertyDlg/0")
    self.m_gressAngry = CEGUI.toProgressBar(winMgr:getWindow("CharacterPropertyDlg/yellow"))
    self.m_gressEnergy = CEGUI.toProgressBar(winMgr:getWindow("CharacterPropertyDlg/purple"))
    self.m_gressMp = CEGUI.toProgressBar(winMgr:getWindow("CharacterPropertyDlg/Mp"))
    self.m_gressHp = CEGUI.toProgressBar(winMgr:getWindow("CharacterPropertyDlg/Hp"))
    self.m_btnUseActi = CEGUI.toPushButton(winMgr:getWindow("CharacterPropertyDlg/shiyong"))
	self:addButtonAnimation(self.m_btnUseActi, "studyBtnPress")
    self.m_shareBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterPropertyDlg/btnfenxiang"))
	
	self.m_btnAddzhuanzhic = CEGUI.toPushButton(winMgr:getWindow("CharacterPropertyDlg/zhuanzhi"))---门派转换	
	self:addButtonAnimation(self.m_btnAddzhuanzhic, "xstudyBtnPress")
	self.m_btnAddzhuanzhic:setText(MHSD_UTILS.get_resstring(1660))
	self.m_btnAddzhuanzhic:subscribeEvent("Clicked", CharacterProDlg.handleAddtBtnzhuanzhic, self)---门派转换
	
    self.cc_chengweik = winMgr:getWindow("CharacterPropertyDlg/left/text2")
	self.cc_cwname = winMgr:getWindow("CharacterPropertyDlg/left/ccguge/cctext1")
	
    self.cc_qiehuan = CEGUI.toPushButton(winMgr:getWindow("CharacterPropertyDlg/left/ccqiehuan"))
    self:addButtonAnimation(self.cc_qiehuan, "xstudyBtnPress")
    self.cc_guge = winMgr:getWindow("CharacterPropertyDlg/left/ccguge")
	self.cc_Score = winMgr:getWindow("CharacterPropertyDlg/left/ccguge/ccScore")
	self:UpdatePlayerScore() 
	self.cc_fzlvel = winMgr:getWindow("CharacterPropertyDlg/left/ccguge/fenji")

    self.cc_rwmb = winMgr:getWindow("CharacterPropertyDlg/left")

    self.cc_lihuic = winMgr:getWindow("CharacterPropertyDlg/left/cclihui")
	--local lihuiid = gGetDataManager():GetMainCharacterShape()
	--gGetGameUIManager():AddUIEffect(self.cc_lihuic, "geffect/ui/MY_actor_lihui/my_lihui".. lihuiid%100, true)	
	
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("huadongc3") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_lihuic)
    self.animationInstance:start()
	
    self.currentView = "cc_lihuic" 
    self.cc_guge:setVisible(false)
    self.cc_chengweik:setVisible(true) 
	self.last_click_time = 0  -- 记录上次点击时间
    self.click_interval = 0.6    -- 点击间隔，单位：秒
	
    self.cc_qiehuan:subscribeEvent("Clicked", function() 
        if self:checkClickInterval() then  -- 检查点击间隔
            self:ToggleSpineAndImage()
        end
    end, self)
    
	self.headIcon = CEGUI.toItemCell(winMgr:getWindow("CharacterPropertyDlg/left/cctxicon"))
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape()%100+1010100)
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.headIcon:SetImage(image)
	
	self.cc_moxing = CEGUI.toWindow(winMgr:getWindow("CharacterPropertyDlg/left/ccguge/ccmoxing"))
    local shapeId = gGetDataManager():GetMainCharacterShape() 
    print("shapeid===>%d",shapeId)
    local s = self.cc_moxing:getPixelSize() 
    local characterModel = gGetGameUIManager():AddWindowSprite(self.cc_moxing, shapeId, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 48, true)

    local mainCharacter = GetMainCharacter() 
    local weapon = mainCharacter:GetSpriteComponent(eSprite_Weapon)
    local rsA = mainCharacter:GetSpriteComponent(eSprite_DyePartA)
    local rsB = mainCharacter:GetSpriteComponent(eSprite_DyePartB)

    characterModel:SetSpriteComponent(eSprite_Weapon, weapon)
    characterModel:SetDyePartIndex(0, rsA)
    characterModel:SetDyePartIndex(1, rsB)
	
    if MT3.ChannelManager:IsAndroid() == 1 then
        if Config.IsLocojoy() then
            self.m_shareBtn:setVisible(true)
        else
            self.m_shareBtn:setVisible(false)
        end
    end

    if Config.IsWinApp() then
        self.m_shareBtn:setVisible(false)
    end

    self.m_shareBtn:subscribeEvent("Clicked", self.HandleClickBtnShare, self)
    self.m_btnToHonorDlg:subscribeEvent("Clicked", self.HandleClickBtnAppellation, self)
    self.m_btnIntro:subscribeEvent("Clicked", self.HandleClikBtnIntro1, self)

    self.m_btnNormalPro:subscribeEvent("SelectStateChanged", self.HandleClickBtnBasePro, self)
    self.m_btnAdvnPro:subscribeEvent("SelectStateChanged", self.HandleClikBtnAdnPro, self)
    
    self.m_btnUseActi:subscribeEvent("Clicked", self.HandleClickBtnUseActi, self)

    self:GetCloseBtn():removeEvent("Clicked")
    self:GetCloseBtn():subscribeEvent("Clicked", CharacterLabel.DestroyDialog, nil)
    self.m_bgBasePro = winMgr:getWindow("CharacterPropertyDlg/text3")
    self.m_bgAdnPro = winMgr:getWindow("CharacterPropertyDlg/text4")

    self.m_txtSchool = winMgr:getWindow("CharacterPropertyDlg/youbg2/zhiyedi/zhiye")
    self.m_txtFaction = winMgr:getWindow("CharacterPropertyDlg/youbg2/gonghuidi/gonghui")

    self.m_btnSchool = CEGUI.toPushButton(winMgr:getWindow("CharacterPropertyDlg/youbg2/btn"))
    self.m_btnFaction = CEGUI.toPushButton(winMgr:getWindow("CharacterPropertyDlg/youbg2/btn1"))
    self.m_btnFaction:subscribeEvent("Clicked", CharacterProDlg.HandlerBtnFactionClicked, self)
	self.m_btnSchool:subscribeEvent("Clicked", CharacterProDlg.HandlerBtnSchoolClicked, self)

    self.m_btnNormalPro:setSelected(true)

    self.m_proBaseResName = {
        "CharacterPropertyDlg/text3/1","CharacterPropertyDlg/text3/2","CharacterPropertyDlg/text3/3",
        "CharacterPropertyDlg/text4/11","CharacterPropertyDlg/text3/4","CharacterPropertyDlg/text3/5",
        "CharacterPropertyDlg/text3/6","CharacterPropertyDlg/text4/16",
    }
    self.m_proAdnResName = {
        "CharacterPropertyDlg/text4/12","CharacterPropertyDlg/text4/13","CharacterPropertyDlg/text4/14","CharacterPropertyDlg/text4/15",
        "CharacterPropertyDlg/text4/17","CharacterPropertyDlg/text4/18","CharacterPropertyDlg/text4/19","CharacterPropertyDlg/text4/20",
        "CharacterPropertyDlg/text4/21","CharacterPropertyDlg/text4/22","CharacterPropertyDlg/text4/23","CharacterPropertyDlg/text4/24"
    }
    self.m_proBaseEnum = {
        fire.pb.attr.AttrType.ATTACK,fire.pb.attr.AttrType.MAGIC_ATTACK,fire.pb.attr.AttrType.SPEED,
        fire.pb.attr.AttrType.SEAL,fire.pb.attr.AttrType.DEFEND,fire.pb.attr.AttrType.MAGIC_DEF,
        fire.pb.attr.AttrType.MEDICAL,fire.pb.attr.AttrType.UNSEAL,
    }
    self.m_proAdnEnum = {
        fire.pb.attr.AttrType.MAGIC_CRITC_LEVEL,fire.pb.attr.AttrType.PHY_CRITC_LEVEL,
        fire.pb.attr.AttrType.ANTI_PHY_CRITC_LEVEL,fire.pb.attr.AttrType.ANTI_MAGIC_CRITC_LEVEL,
        fire.pb.attr.AttrType.HEAL_CRIT_LEVEL,fire.pb.attr.AttrType.KONGZHI_MIANYI,fire.pb.attr.AttrType.KONGZHI_JIACHENG,
        fire.pb.attr.AttrType.ZHILIAO_JIASHEN,fire.pb.attr.AttrType.WULI_DIKANG,fire.pb.attr.AttrType.FASHU_DIKANG,
        fire.pb.attr.AttrType.FASHU_CHUANTOU,fire.pb.attr.AttrType.WULI_CHUANTOU
    }
	--self.m_listRoleSpine   = winMgr:getWindow("CharacterPropertyDlg/left/aimuti")
    self.m_listBaseTxtProData = { }
    self.m_listAdnTxtProData = { }
    for i, v in pairs(self.m_proBaseResName) do
        table.insert(self.m_listBaseTxtProData, winMgr:getWindow(v))
    end
    for i, v in pairs(self.m_proAdnResName) do
        table.insert(self.m_listAdnTxtProData, winMgr:getWindow(v))
    end
    local notmgr = require "manager.notifymanager"
    notmgr.SendOpenFactionProtocol()
    self:UpdateProData()
    self:UpdateBtnPro(EnumBtnState.Base)
    self:UpdateYingFuJingYan()
    self:UpdateFactionAndSchool()
	self:ShowPlayerSpine()
	self:UpdateFZLLevelImage()
end

function CharacterProDlg:UpdatePlayerScore()
    local data = gGetDataManager():GetMainCharacterData()
    local roleScore = data.roleScore -- 获取总评分
    local scoreText = "人物评分：" .. roleScore 
    self.cc_Score:setText(scoreText) 
end

function CharacterProDlg:checkClickInterval()
    local current_time = os.time()
    if current_time - self.last_click_time < self.click_interval then
        local strbuilder = StringBuilder:new()
        local tempStrTip = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(201067))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(tempStrTip)
        return false
    end
    self.last_click_time = current_time
    return true
end

function CharacterProDlg:UpdateFactionAndSchool()
	local nSchoolName = gGetDataManager():GetMainCharacterSchoolName()
	self.m_txtSchool:setText(nSchoolName)
    local datamanager = require "logic.faction.factiondatamanager"
    if not datamanager.factionid then
        local text =  MHSD_UTILS.get_resstring(11290)
        self.m_txtFaction:setText(text)
    elseif datamanager.factionid>0 then
        self.m_txtFaction:setText(datamanager.factionname)
    else
        local text =  MHSD_UTILS.get_resstring(11290)
        self.m_txtFaction:setText(text)
    end
    if datamanager then
        self.m_btnFaction:setEnabled(datamanager:IsHasFaction())
    end
    local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
	local mapRecord =BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(schoolConfig.schooljobmapid)
    local mapName = mapRecord.mapName
    local strbuilder = StringBuilder:new()
	strbuilder:Set("parameter1", mapName)
    local msg=strbuilder:GetString(MHSD_UTILS.get_resstring(11322))
    strbuilder:delete()
    self.m_btnSchool:setText(msg)
    
end

function CharacterProDlg:HandleClickBtnShare(args)
    require "logic.share.sharedlg".SetShareType(SHARE_TYPE_CHARACTOR)
    require "logic.share.sharedlg".SetShareFunc(SHARE_FUNC_CAPTURE)
    require "logic.share.sharedlg".getInstanceAndShow()
end

function CharacterProDlg:HandlerBtnSchoolClicked(args)
	
	if GetTeamManager() and  not GetTeamManager():CanIMove() then
	
		if GetChatManager() then
			GetChatManager():AddTipsMsg(150030)	--����޷�����
		end
		return true
	end

	local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
	local  nMapID = schoolConfig.schooljobmapid
	local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(nMapID)
	
	if mapRecord == nil then	
		return true;
	end

	if mapRecord.maptype == 1 or mapRecord.maptype == 2  then
	
		local randX = mapRecord.bottomx - mapRecord.topx
		randX = mapRecord.topx + math.random(0, randX)

		local randY = mapRecord.bottomy - mapRecord.topy
		randY = mapRecord.topy + math.random(0, randY)
		gGetNetConnection():send(fire.pb.mission.CReqGoto(nMapID, randX, randY));
        if gGetScene()  then
			gGetScene():EnableJumpMapForAutoBattle(false);
		end
		CharacterLabel.DestroyDialog()
	else
		return false
	end	
		
	return true;
	
end
function CharacterProDlg:HandlerBtnFactionClicked(args)

    if GetBattleManager():IsInBattle() then
        GetCTipsManager():AddMessageTipById(144879)
        CharacterLabel.DestroyDialog()
        return
    end
    local p = require "protodef.fire.pb.clan.centerclanmap":new()
    require "manager.luaprotocolmanager".getInstance():send(p)
    CharacterLabel.DestroyDialog()
end
function CharacterProDlg:UpdateProData()
    local data = gGetDataManager():GetMainCharacterData()
    local characterprodlg = require "logic.characterinfo.characterprodlg".getInstanceNotCreate()
    if not _instance then
        print(" CharacterProDlg:UpdateProData the instance is null")
        return
    end
    local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
    local nZsl = data:GetValue(1240)
    _instance.m_txtLvl:setText(tostring(nLvl) .. MHSD_UTILS.get_resstring(2397))
    _instance.m_txtZsl:setText(tostring(nZsl))
    _instance.m_txtPlayerName:setText(gGetDataManager():GetMainCharacterName())
    local crc = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(nLvl)
    if crc == nil then
    else
        if crc.nextexp == 0 then
            _instance.m_gressExp:setText(data.exp)
            _instance.m_gressExp:setProgress(0.0)
        else
            local nExpScale = data.exp / crc.nextexp
            _instance.m_gressExp:setText(data.exp .. "/" .. crc.nextexp)
            _instance.m_gressExp:setProgress(nExpScale)
        end
    end
    _instance.m_txtID:setText("ID  " .. gGetDataManager():GetMainCharacterID())
    local nstrMp = data:GetValue(fire.pb.attr.AttrType.MP) .. "/" .. data:GetValue(fire.pb.attr.AttrType.MAX_MP)
    _instance.m_gressMp:setText(nstrMp)
    local nMPScale = data:GetValue(fire.pb.attr.AttrType.MP) / data:GetValue(fire.pb.attr.AttrType.MAX_MP)
    _instance.m_gressMp:setProgress(nMPScale)

    local nHPScale = data:GetValue(fire.pb.attr.AttrType.HP) / data:GetValue(fire.pb.attr.AttrType.UP_LIMITED_HP)
    _instance.m_gressHp:setProgress(nHPScale)
    local nstrHp = ""
    local nHp = data:GetValue(fire.pb.attr.AttrType.HP)
    local nLimitHp = data:GetValue(fire.pb.attr.AttrType.UP_LIMITED_HP)
    local nMax = data:GetValue(fire.pb.attr.AttrType.MAX_HP)
    if nLimitHp == nMax then
        nstrHp = nHp .. "/" .. nLimitHp
        _instance.m_gressHp:setText(nstrHp)
    else
        nstrHp = nHp .. "/" .. "[colrect='tl:ffffff00 tr:ffffff00 bl:ffffff00 br:ffffff00']" .. nLimitHp
        _instance.m_gressHp:setText(nstrHp)
    end

    local nEnergyScale = data:GetValue(fire.pb.attr.AttrType.ENERGY) / data:GetValue(fire.pb.attr.AttrType.ENLIMIT)
    _instance.m_gressEnergy:setProgress(nEnergyScale)
    local nStrEn = data:GetValue(fire.pb.attr.AttrType.ENERGY) .. "/" .. data:GetValue(fire.pb.attr.AttrType.ENLIMIT)
    _instance.m_gressEnergy:setText(nStrEn)
    local nAngryScale = data:GetValue(fire.pb.attr.AttrType.SP) / data:GetValue(fire.pb.attr.AttrType.MAX_SP)
    _instance.m_gressAngry:setProgress(nAngryScale)
    local nStrAngry = data:GetValue(fire.pb.attr.AttrType.SP) .. "/" .. data:GetValue(fire.pb.attr.AttrType.MAX_SP)
    _instance.m_gressAngry:setText(nStrAngry)

    local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    _instance.m_imgSchool:setProperty("Image", schoolConfig.schooliconpath)

    local nStrHonor = gGetDataManager():GetCurTilte()
    local splited = false
    nStrHonor, splited = SliptStrByCharCount(nStrHonor, 20)
    if splited then
        nStrHonor, splited = SliptStrByCharCount(nStrHonor, 20)
        nStrHonor = nStrHonor .."..."
    end
    _instance.m_txtHonour:setText(nStrHonor)
    _instance.cc_cwname:setText(nStrHonor)
    _instance:UpdateAttrDetail()
end

function CharacterProDlg:UpdateFZLLevelImage()--分级标识
    local nLvl = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.LEVEL)
    local imagePath = ""
    
    if nLvl >= 1 and nLvl <= 69 then
        imagePath = "set:ccui image:ccfz1" 
    elseif nLvl >= 70 and nLvl <= 89 then
        imagePath = "set:ccui image:ccfz2" 
    elseif nLvl >= 90 and nLvl <= 129 then
        imagePath = "set:ccui image:ccfz3" 
    end
    if imagePath ~= "" then
        self.cc_fzlvel:setProperty("Image", imagePath) 
    end
end


--匹配 j角色创建配置表里 模型
function CharacterProDlg:ShowPlayerSpine()
    local npcid = gGetDataManager():GetMainCharacterShape() % 100 +1010100
	local ids = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getAllID()
	for index, var in pairs(ids) do
		local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(var)
        if conf ~=nil and  npcid ==  conf.model then
	        self:createSpineSprite( conf ) 
            break;			
        end 
	end
end



function CharacterProDlg.performPostRenderFunctions(id)
    if CharacterProDlg:getInstance():GetWindow():getAlpha() > 0.2 and CharacterProDlg:getInstance().spine then
	    CharacterProDlg:getInstance().spine:RenderUISprite()
	end
end

function CharacterProDlg:createSpineSprite( conf )
    if not conf then return end
    local pos = self.cc_lihuic:GetScreenPosOfCenter()
	local loc = Nuclear.NuclearPoint(pos.x-50, pos.y+50)
    if not self.spine then
        self.spine = UISpineSprite:new(conf.spine)
        self.spine:SetUILocation(loc)
        self.spine:PlayAction(eActionAttack)
		self.spine:SetUIScale(1.2)
		local winMgr = CEGUI.WindowManager:getSingleton()
		self.spriteBack = winMgr:getWindow("CharacterPropertyDlg/left/guge")
		self.spriteBack:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, CharacterProDlg.performPostRenderFunctions))
	end
end

function CharacterProDlg:adjustForCapture()
	if not self.spine then
		return
	end
	self.spine:SetUIScale(0.4)
	local pos = self.cc_lihuic:GetScreenPosOfCenter()
	pos.x = pos.x + 100
	local loc = Nuclear.NuclearPoint(pos.x, pos.y)
	self.spine:SetUILocation(loc)
end

function CharacterProDlg:ToggleSpineAndImage()
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_chengweik)
    self.animationInstance:start()
	
	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_guge)
    self.animationInstance:start()

	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("huadongc2") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_lihuic)
    self.animationInstance:start()

	
    if self.currentView == "cc_guge" then
        self.cc_guge:setVisible(false)
        self.cc_lihuic:setVisible(true)
        self.currentView = "cc_lihuic"

        self.cc_chengweik:setVisible(true) -- 隐藏称号背景
    else
        self.cc_lihuic:setVisible(false)
        self.cc_guge:setVisible(true)
        self.currentView = "cc_guge"

        self.cc_chengweik:setVisible(false) -- 显示称号背景
    end
end



function CharacterProDlg:UpdateAttrDetail()
    local data = gGetDataManager():GetMainCharacterData()
    for i, v in pairs(self.m_listBaseTxtProData) do
        local nD = data:GetValue(self.m_proBaseEnum[i])
        v:setText(nD)
    end

    self:UpdateAttrDetailPercent()
end
function CharacterProDlg:UpdateAttrDetailPercent()
    local data = gGetDataManager():GetMainCharacterData()
    for i, v in pairs(self.m_listAdnTxtProData) do
        local nD = data:GetValue(self.m_proAdnEnum[i])
        local percent = nD / 10
        if percent < 0.1 then
            percent = 0
        end
        local strPercent = string.format("%.1f%%", percent)  -- 先格式化，保留一位小数
        strPercent = strPercent:gsub("%.0", "")   -- 将 ".0" 替换为空字符串
        v:setText(strPercent) 
    end
end
function CharacterProDlg:UpdateBtnPro(index)
    if index == EnumBtnState.Base then
        self.m_bgBasePro:setVisible(true)
        self.m_bgAdnPro:setVisible(false)
    elseif index == EnumBtnState.Adn then
        self.m_bgBasePro:setVisible(false)
        self.m_bgAdnPro:setVisible(true)
    end
end

function CharacterProDlg:HandleClickBtnAppellation(e)
    local dlg = require "logic.title.titledlg".getInstanceAndShow()

    return true
end

function CharacterProDlg:handleAddtBtnzhuanzhic(e)--转职
    local nLvl = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.LEVEL)
    if nLvl < 60 then 
        GetCTipsManager():AddMessageTipById(193543)
        return 
    end
    require "logic.zhuanzhi.ZhuanZhiDlg".getInstanceAndShow()
end

function CharacterProDlg:HandleClikBtnIntro1(arg)
    local tipsStr = require("utils.mhsdutils").get_resstring(11329)
    if IsPointCardServer() then
        tipsStr = require("utils.mhsdutils").get_resstring(11328)
    end
    local title = require("utils.mhsdutils").get_resstring(11328)
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

--[[function CharacterProDlg:HandleClikBtnIntro1(arg)

    local title = MHSD_UTILS.get_resstring(11328)
    local strAllString = MHSD_UTILS.get_resstring(11329)
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", tostring(gGetDataManager():getServerLevel()))
    strbuilder:Set("parameter2", tostring(gGetDataManager():getServerLevelDays()))
    strAllString = strbuilder:GetString(strAllString)
    strbuilder:delete()
    local tips1 = require "logic.workshop.tips1"
    tips1.getInstanceAndShow(strAllString, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
    return true
end]]

function CharacterProDlg:HandleClickBtnBasePro(e)
    _instance:UpdateBtnPro(EnumBtnState.Base)
end



function CharacterProDlg:HandleClikBtnAdnPro(e)
    _instance:UpdateBtnPro(EnumBtnState.Adn)
end

function CharacterProDlg:HandleClickBtnUseActi(arg)
    local dlg = require "logic.skill.strengthusedlg".getInstanceAndShow()
    dlg:GetWindow():setAlwaysOnTop(true)
	local p = require("protodef.fire.pb.skill.liveskill.crequestattr").Create()
    local attr = {}
    attr[1] = fire.pb.attr.AttrType.ENERGY
	p.attrid = attr
	LuaProtocolManager:send(p)
    return true

end
local p = require "protodef.fire.pb.attr.sapplyyingfuexprience"
function p:process()
    local dlg =  CharacterProDlg.getInstanceNotCreate()
    if dlg then
        if dlg.m_txtExpSurplus then
            dlg.m_txtExpSurplus:setText(tostring(self.exprience))
        end
    end
    local dlg =  require"logic.characterinfo.characterinfodlg".getInstanceNotCreate()
    if dlg then
        if dlg.m_txtExpSurplus then
            dlg.m_txtExpSurplus:setText(tostring(self.exprience))
        end
    end
end
function CharacterProDlg:UpdateYingFuJingYan()
    local send = require "protodef.fire.pb.attr.capplyyingfuexprience":new()
    require "manager.luaprotocolmanager":send(send)
end
return CharacterProDlg

TeamMemberCard = { }

setmetatable(TeamMemberCard, Dialog)
TeamMemberCard.__index = TeamMemberCard
local prefix = 1

local SIGN_T = {
	LEADER	= 1,	--�ӳ�
	ASSIST	= 2,	--��ս
	OFFLINE = 3,	--����
	ABSENT 	= 4,	--����
	ORDER 	= 5		--ָ��
}

TeamMemberCard.MYSELF = 0
TeamMemberCard.MEMBER = 1
TeamMemberCard.ASSIST = 2

TeamMemberCard.allInstances = {}

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function TeamMemberCard.CreateNewDlg(pParentDlg)
    local newDlg = TeamMemberCard:new()
    newDlg:OnCreate(pParentDlg)
    table.insert(TeamMemberCard.allInstances, newDlg)
    return newDlg
end

----/////////////////////////////////////////------

function TeamMemberCard.GetLayoutFileName()
    return "teamplay.layout"
end

function TeamMemberCard:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeamMemberCard)
    return self
end

function TeamMemberCard:DestroyDialog()
    for k,v in pairs(TeamMemberCard.allInstances) do
        if v == self then
            table.remove(TeamMemberCard.allInstances, k)
        end
    end
    self:OnClose()
end

function TeamMemberCard:OnCreate(pParentDlg)
    prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.signImg = winMgr:getWindow(prefixstr .. 'teamplay/ditu/biaoji')
    self.numImg = winMgr:getWindow(prefixstr .. 'teamplay/ditu/weizhi')
    self.name = winMgr:getWindow(prefixstr .. 'teamplay/ditu/name')
    self.level = winMgr:getWindow(prefixstr .. 'teamplay/ditu/lv')
    self.acceptBtn = winMgr:getWindow(prefixstr .. 'teamplay/acceptBtn')
    self.back = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. 'teamplay/ditu'))
    self.swapPos = winMgr:getWindow(prefixstr .. 'teamplay/ditu/swapPos')
    self.swapPos1 = winMgr:getWindow(prefixstr .. 'teamplay/ditu/swapPos1')
    self.canvas = winMgr:getWindow(prefixstr .. 'teamplay/ditu/diwen')
    self.school = winMgr:getWindow(prefixstr .. 'teamplay/ditu/school')
	self.schoolc = winMgr:getWindow(prefixstr .. 'teamplay/ditu/school')
    self.schoolname = winMgr:getWindow(prefixstr .. 'teamplay/ditu/zhiye')
    self.zhenfaEffectName1 = winMgr:getWindow(prefixstr .. "teamplay/ditu/jiacheng")
    self.zhenfaEffectSign1 = winMgr:getWindow(prefixstr .. "teamplay/ditu/up")
    self.zhenfaEffectName2 = winMgr:getWindow(prefixstr .. "teamplay/ditu/shuaijian")
    self.zhenfaEffectSign2 = winMgr:getWindow(prefixstr .. "teamplay/ditu/down")
	self.zhenfaEffectName3 = winMgr:getWindow(prefixstr .. "teamplay/ditu/guanghuan/123")


    self.acceptBtn:subscribeEvent('Clicked', self.handleAcceptBtnClicked, self)
    self.back:subscribeEvent('Clicked', self.handleCardClicked, self)

    self.savedXPos1 = self.zhenfaEffectName1:getXPosition().offset
    self.savedXPos2 = self.zhenfaEffectSign1:getXPosition().offset

    self.back:EnableClickAni(false)
    self.signImg:setVisible(false)
    self.numImg:setVisible(false)
    self.acceptBtn:setVisible(false)
    self.effectid = -1

end

-- stTeamMember ������桢��ӽ���
-- @order ˳��
function TeamMemberCard:loadTeamMemberData(memberInfo, order)
    self.cardType = TeamMemberCard.MEMBER
    self.id = memberInfo.id
    self.idx = order -- 0~5
    self:changeNumImage(order)
    if memberInfo == GetTeamManager():GetTeamLeader() then
        self:changeSignImage(SIGN_T.LEADER)
    elseif memberInfo.eMemberState == eTeamMemberAbsent then
        self:changeSignImage(SIGN_T.ABSENT)
    elseif memberInfo.eMemberState == eTeamMemberFallline then
        self:changeSignImage(SIGN_T.OFFLINE)
    elseif memberInfo.id == GetTeamManager():getTeamOrder() then
        self:changeSignImage(SIGN_T.ORDER)
    else
        self.signImg:setVisible(false)
    end
    self.name:setText(memberInfo.strName)
    local rolelv = ""..memberInfo.level
    
    if memberInfo.level>1000 then
        local zscs,t2 = math.modf(memberInfo.level/1000)
        rolelv = zscs..""..(memberInfo.level-zscs*1000)
    end
    self.level:setText("" ..tostring(rolelv))
    self.acceptBtn:setVisible(false)
    self:showSwapButton(false)

    if memberInfo.id == gGetDataManager():GetMainCharacterID() then
        local data = gGetDataManager():GetMainCharacterData()
        local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
        local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
        local weapon = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
        local zuoqi = GetMainCharacter():GetSpriteComponent(eSprite_Horse)
        self:addSprite(data.shape, weapon,zuoqi , pA, pB)
        if memberInfo:getComponent(eSprite_Effect) then -- ��װ��Ч
            self:checkEquipEffect(self.sprite, memberInfo:getComponent(eSprite_Effect))
        end
    else
        local pA = memberInfo:getComponent(eSprite_DyePartA)
        local pB = memberInfo:getComponent(eSprite_DyePartB)
        self:addSprite(memberInfo.shapeID, memberInfo:getComponent(eSprite_Weapon), memberInfo:getComponent(eSprite_Horse), pA, pB)
        if memberInfo:getComponent(eSprite_Effect) then -- ��װ��Ч
            self:checkEquipEffect(self.sprite, memberInfo:getComponent(eSprite_Effect))
        end
    end


    local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(memberInfo.eSchool)
    if schoolconf then
        self.school:setProperty("Image", schoolconf.schooliconpath)
        self.schoolname:setText(schoolconf.name)
		--self.schoolc:setProperty("Image", schoolconf.schoolpicpathc)
    end
end

function TeamMemberCard:checkEquipEffect(roleSprite, quality)
    if quality ~= 0 then
        if quality>10 then
			quality= 10
		end
        local record = BeanConfigManager.getInstance():GetTableByName("role.cequipeffectconfig"):getRecorder(quality)
        if record then
            if self.effectid > 0 then
                roleSprite:RemoveEngineSpriteDurativeEffect(self.Spriteeffect)
                self.effectid = -1
            end
            self.Spriteeffect = roleSprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(record.effectId), false);
            self.effectid = record.effectId
        else
            if self.Spriteeffect ~= nil then
                roleSprite:RemoveEngineSpriteDurativeEffect(self.Spriteeffect)
                self.Spriteeffect = nil
            end

        end
    else
        if self.Spriteeffect ~= nil then
            roleSprite:RemoveEngineSpriteDurativeEffect(self.Spriteeffect)
            self.Spriteeffect = nil
        end
    end
end

-- stApplyMember ����������
function TeamMemberCard:loadApplyMemberData(applyinfo)
    self.id = applyinfo.id
    self.name:setText(applyinfo.strName)
    local rolelv = ""..applyinfo.level
    if applyinfo.level>1000 then
        local zscs,t2 = math.modf(applyinfo.level/1000)
        rolelv = zscs..""..(applyinfo.level-zscs*1000)
    end
    self.level:setText("" .. tostring(rolelv))
    self.signImg:setVisible(false)
    self.acceptBtn:setVisible(true)
    self:showSwapButton(false)
    local weapon = applyinfo:getComponent(eSprite_Weapon)
    local zuoqi = applyinfo:getComponent(eSprite_Horse)
    local pA = applyinfo:getComponent(eSprite_DyePartA)
    local pB = applyinfo:getComponent(eSprite_DyePartB)
    self:addSprite(applyinfo.shape, weapon, zuoqi,pA, pB)
    if applyinfo:getComponent(eSprite_Effect) then -- ��װ��Ч
        self:checkEquipEffect(self.sprite, applyinfo:getComponent(eSprite_Effect))
    end

    local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(applyinfo.eSchool)
    if schoolconf then
        self.school:setProperty("Image", schoolconf.schooliconpath)
        self.schoolname:setText(schoolconf.name)
    end
end

-- CHeroBaseInfo ��ս��Ա
function TeamMemberCard:loadAssistMember(data, order)
    self.cardType = TeamMemberCard.ASSIST
    self.id = data.id
    self.idx = order
    self.name:setText(data.name)
	
    local rolelv= gGetDataManager():GetMainCharacterLevel()
    local rolelevel = ""..rolelv
    if rolelv>1000 then
        local zscs,t2 = math.modf(rolelv/1000)
        rolelevel = zscs..""..(rolelv-zscs*1000)
    end
    self.level:setText("" .. tostring(rolelevel))
    self.school:setProperty("Image", GetRoleTypeIconPath(data.type))
	--self.schoolc:setProperty("Image", GetRoleTypeIconPath(data.type))
--	self.schoolc:setProperty("Image", schoolconf.schoolpicpathc)
    self.schoolname:setText(GetRoleTypeName(data.type))
    self:changeSignImage(SIGN_T.ASSIST)
    self:changeNumImage(order)
    self.acceptBtn:setVisible(false)
    self:showSwapButton(false)    
	local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(data.shapeid)
    local weapon = 0
    if shapeConf then
        weapon = shapeConf.showWeaponId
    end
    self:addSprite(data.shapeid, weapon, 0, 0, 0)
    self:checkEquipEffect(self.sprite, 0)
    self.sprite:SetUIAlpha(150)
end

-- stMainCharacterData
function TeamMemberCard:loadSelfData()
    self.cardType = TeamMemberCard.MYSELF
    local data = gGetDataManager():GetMainCharacterData()
    self.id = data.roleid
    self.idx = 1
    self.name:setText(data.strName)
    local rolelv= gGetDataManager():GetMainCharacterLevel()
    local rolelevel = ""..rolelv
    if rolelv>1000 then
        local zscs,t2 = math.modf(rolelv/1000)
        rolelevel = zscs..""..(rolelv-zscs*1000)
    end
    self.level:setText("" .. tostring(rolelevel))
    self.signImg:setVisible(true)
    self:changeNumImage(1)
    self:changeSignImage(SIGN_T.LEADER)
    self:showSwapButton(false)
    self.acceptBtn:setVisible(false)
    local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
    local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
    local weapon = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
    local zuoqi = GetMainCharacter():GetSpriteComponent(eSprite_Horse)
    self:addSprite(data.shape, weapon,zuoqi, pA, pB)
    if GetMainCharacter():GetSpriteComponent(eSprite_Effect) then -- ��װ��Ч
        self:checkEquipEffect(self.sprite, GetMainCharacter():GetSpriteComponent(eSprite_Effect))
    end

    local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(data.school)
    if schoolconf then
        self.school:setProperty("Image", schoolconf.schooliconpath)
        self.schoolname:setText(schoolconf.name)
    end
end

function TeamMemberCard:changeSignImage(signType)
    self.signImg:setVisible(true)
    if signType == SIGN_T.LEADER then
        self.signImg:setProperty('Image', 'set:team_1 image:team_duizhang')
    elseif signType == SIGN_T.ASSIST then
        self.signImg:setProperty('Image', 'set:team_1 image:team_zhuzhan')
    elseif signType == SIGN_T.OFFLINE then
        self.signImg:setProperty('Image', 'set:team_1 image:team_lixian')
    elseif signType == SIGN_T.ABSENT then
        self.signImg:setProperty('Image', 'set:team_1 image:team_zanli')
    elseif signType == SIGN_T.ORDER then
        self.signImg:setProperty('Image', 'set:teamui image:zhihui')
    end
end

function TeamMemberCard:getDefaultWeaponByModel(modelId)
    local  allId = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getAllID()
    for k,v in pairs(allId) do
        local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(v)
        if conf.model == modelId or conf.model % 100 == modelId then
            return conf.weapon
        end
    end
    return 0
end

function TeamMemberCard:addSprite(modelId, weapon,zuoqi, rsA, rsB)
    if modelId <= 17 then
        modelId = 1010100 + modelId
    elseif modelId < 300 then
        modelId = 2010100 + modelId % 100
    end

    if self.sprite then
		self.sprite:SetUIAlpha(255)
        if self.sprite:GetModelID() == modelId then
            self.sprite:SetSpriteComponent(eSprite_Weapon, weapon)
            self.sprite:SetDyePartIndex(0, rsA)
            self.sprite:SetDyePartIndex(1, rsB)
            return
        end
        self.sprite:SetModel(modelId)
        self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
    else
        local s = self.canvas:getPixelSize()
        self.sprite = gGetGameUIManager():AddWindowSprite(self.canvas, modelId, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 48, true)
    end

    if weapon == 0 and self.cardType == TeamMemberCard.ASSIST then
        weapon = self:getDefaultWeaponByModel(modelId)
    end
    self.sprite:SetSpriteComponent(eSprite_Weapon, weapon)
    if zuoqi == 0 and self.cardType == TeamMemberCard.ASSIST then
        zuoqi = self:getDefaultWeaponByModel(modelId)
    end
    -- local zuoqi = GetMainCharacter():GetSpriteComponent(eSprite_Horse)
    self.sprite:SetSpriteComponent(eSprite_Horse, zuoqi)
    self.sprite:SetDyePartIndex(0, rsA)
    self.sprite:SetDyePartIndex(1, rsB)
end

function TeamMemberCard:refreshSpriteComponent()
    if not self.sprite or not self.id then
        return
    end
    if self.cardType == TeamMemberCard.MEMBER then
        local memberInfo = GetTeamManager():GetTeamMemberByID(self.id)
        if not memberInfo then
            return
        end
        local weapon = memberInfo:getComponent(eSprite_Weapon)
        local pA = memberInfo:getComponent(eSprite_DyePartA)
        local pB = memberInfo:getComponent(eSprite_DyePartB)
        self.sprite:SetSpriteComponent(eSprite_Weapon, weapon)
        self.sprite:SetDyePartIndex(0, pA)
        self.sprite:SetDyePartIndex(1, pB)
    end
end

function TeamMemberCard:changeNumImage(num)
    self.numImg:setVisible(true)
    self.numImg:setProperty('Image', 'set:teamui image:team_' .. num)
end

--[[function TeamMemberCard:showAcceptBtn(willShow)
	self.acceptBtn:setVisible(willShow)
end--]]

function TeamMemberCard:showSwapButton(willShow)
    self.toSwap = willShow
    self.swapPos:setVisible(willShow)
    self.swapPos1:setVisible(false)
end
function TeamMemberCard:showWeiRenButton(willShow)
    self.swapPos:setVisible(false)
    self.swapPos1:setVisible(willShow)
end

function TeamMemberCard:setSelectedCallFunc(func, target)
    self.selectedCallFunc = { target = target, func = func }
end

function TeamMemberCard:setZhenfaEffect(effectStr)
    if not effectStr then
        self.zhenfaEffectName1:setVisible(false)
        self.zhenfaEffectSign1:setVisible(false)
        self.zhenfaEffectName2:setVisible(false)
        self.zhenfaEffectSign2:setVisible(false)
		self.zhenfaEffectName3:setVisible(false)
    else
        local effects = {}
        for str in effectStr:gmatch("\"([^\"]+)\"") do
            table.insert(effects, str)
        end

        if effects[1] then
            local p = effects[1]:find("[+-]")
            self.zhenfaEffectName1:setText(effects[1]:sub(1, p-1))
            if effects[1]:find("+") then
                self.zhenfaEffectSign1:setProperty("Image", "set:teamui image:team_up")
            else
                self.zhenfaEffectSign1:setProperty("Image", "set:teamui image:team_down")
            end

            self.zhenfaEffectName1:setVisible(true)
            self.zhenfaEffectSign1:setVisible(true)
			self.zhenfaEffectName3:setVisible(true)
        end

        if effects[2] then
            local p = effects[2]:find("[+-]")
            self.zhenfaEffectName2:setText(effects[2]:sub(1, p-1))
            if effects[2]:find("+") then
                self.zhenfaEffectSign2:setProperty("Image", "set:teamui image:team_up")
            else
                self.zhenfaEffectSign2:setProperty("Image", "set:teamui image:team_down")
            end

            self.zhenfaEffectName2:setVisible(true)
            self.zhenfaEffectSign2:setVisible(true)
			--self.zhenfaEffectName3:setVisible(true)
        else
            self.zhenfaEffectName2:setVisible(false)
            self.zhenfaEffectSign2:setVisible(false)
			--self.zhenfaEffectName3:setVisible(false)
        end

        if effects[1] and effects[2] then
            self.zhenfaEffectName1:setXPosition(CEGUI.UDim(0, self.savedXPos1))
            self.zhenfaEffectSign1:setXPosition(CEGUI.UDim(0, self.savedXPos2))
        else
            local offset = (self:GetWindow():getPixelSize().width-(self.savedXPos2+self.zhenfaEffectSign1:getPixelSize().width-self.savedXPos1))*0.5-self.savedXPos1
            self.zhenfaEffectName1:setXPosition(CEGUI.UDim(0, self.savedXPos1+offset))
            self.zhenfaEffectSign1:setXPosition(CEGUI.UDim(0, self.savedXPos2+offset))
        end
    end
end

function TeamMemberCard:handleAcceptBtnClicked(arg)
    GetTeamManager():RequestAcceptToMyTeam(self.id)
end

function TeamMemberCard:handleCardClicked(arg)
    print('member card clicked')
    if self.selectedCallFunc then
        self.selectedCallFunc.func(self.selectedCallFunc.target, self)
    end
end

return TeamMemberCard

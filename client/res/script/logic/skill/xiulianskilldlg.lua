require "logic.dialog"

XiulianSkillDlg = { }
setmetatable(XiulianSkillDlg, Dialog)
XiulianSkillDlg.__index = XiulianSkillDlg

local _instance

function XiulianSkillDlg.getInstance()
    if not _instance then
        _instance = XiulianSkillDlg.new()
        _instance:OnCreate()
    end
    return _instance
end

function XiulianSkillDlg.getInstanceAndShow()
    if not _instance then
        _instance = XiulianSkillDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function XiulianSkillDlg.getInstanceOrNot()
    return _instance
end

function XiulianSkillDlg.new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, XiulianSkillDlg)
    self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(XiulianSkillDlg.OnMoneyChange)
    return self
end

function XiulianSkillDlg.DestroyDialog()
    if _instance then
        if SkillLable.getInstanceNotCreate() then
            SkillLable.getInstanceNotCreate().DestroyDialog()
        else
            _instance:CloseDialog()
        end
    end
end

function XiulianSkillDlg:CloseDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end


function XiulianSkillDlg:OnClose()
    Dialog.OnClose(self)
    gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    _instance = nil
end

function XiulianSkillDlg.GetLayoutFileName()
    return "xiulianskill_mtg.layout"
end

function XiulianSkillDlg:OnCreate()
    Dialog.OnCreate(self)
    SetPositionOfWindowWithLabel(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_scrollSkillPanel = CEGUI.Window.toScrollablePane(winMgr:getWindow("xiulianskill/left/list"))
    self.m_skillList = { }
    self.m_skills = { }
    self.m_curSkillIndex = 1
    self.m_skillID = 0
    self.m_skillLevel = 0
	self.m_maxSkillLevel = 0
    self.m_skillMaxLevel = 0
    self.m_skillExp = 0
    self.m_skillEffects = { }
    self.m_skillNextEffects = { }
    self.m_needYinbi = 0
    self.m_curBanggong = 0

    -- 技能学习按钮事件
    local studyOnceBtn = CEGUI.toPushButton(winMgr:getWindow("xiulianskill/btn1"))---学习一次
    local studyOnceBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")  
    if studyOnceBtnPressAnimationDef then
        local studyOnceBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(studyOnceBtnPressAnimationDef)
        studyOnceBtnPressAnimation:setTargetWindow(studyOnceBtn)
        studyOnceBtnPressAnimation:setSpeed(0.7) 

        studyOnceBtn:subscribeEvent("MouseButtonDown", 
            function()
                studyOnceBtnPressAnimation:start() 
            end, self)
    end
    studyOnceBtn:setID(1)
    studyOnceBtn:subscribeEvent("MouseClick", XiulianSkillDlg.HandleStudyBtnClicked, self)

    local studyTenBtn = CEGUI.toPushButton(winMgr:getWindow("xiulianskill/btn2"))---学习十次
    local studyTenBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")  
    if studyTenBtnPressAnimationDef then
        local studyTenBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(studyTenBtnPressAnimationDef)
        studyTenBtnPressAnimation:setTargetWindow(studyTenBtn)
        studyTenBtnPressAnimation:setSpeed(0.7) 

        studyTenBtn:subscribeEvent("MouseButtonDown", 
            function()
                studyTenBtnPressAnimation:start() 
            end, self)
    end
    studyTenBtn:setID(10)
    studyTenBtn:subscribeEvent("MouseClick", XiulianSkillDlg.HandleStudyBtnClicked, self)

    local studyItemBtn = CEGUI.toPushButton(winMgr:getWindow("xiulianskill/btn3"))---使用道具
    local studyItemBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")  
    if studyItemBtnPressAnimationDef then
        local studyItemBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(studyItemBtnPressAnimationDef)
        studyItemBtnPressAnimation:setTargetWindow(studyItemBtn)
        studyItemBtnPressAnimation:setSpeed(0.7)  

        studyItemBtn:subscribeEvent("MouseButtonDown", 
            function()
                studyItemBtnPressAnimation:start()  
            end, self)
    end
    studyItemBtn:setID(334100)
    studyItemBtn:subscribeEvent("MouseClick", XiulianSkillDlg.HandleStudyBtnClicked, self)

    local infoBtn = CEGUI.toPushButton(winMgr:getWindow("xiulianskill/bg/tishibtn"))
    infoBtn:subscribeEvent("MouseClick", XiulianSkillDlg.HandleInfoBtnClicked, self)
    infoBtn:EnableClickAni(true)

    local infoBtn2 = CEGUI.toPushButton(winMgr:getWindow("xiulianskill/bg/tishibtn1"))
    infoBtn2:subscribeEvent("MouseClick", XiulianSkillDlg.HandleInfo2BtnClicked, self)
    infoBtn2:EnableClickAni(true)
    self.m_needYinbi_st = winMgr:getWindow("xiulianskill/di1/qian1")
    self.m_yinbiColor = self.m_needYinbi_st:getProperty("TextColours")
    self.m_haveYinbi_st = winMgr:getWindow("xiulianskill/di1/qian11")

    local p = require "protodef.fire.pb.skill.particleskill.crequestparticleskilllist".Create()
    LuaProtocolManager.getInstance():send(p)
end


function XiulianSkillDlg:RefreshSkillList()

    if table.getn(self.m_skillList) == 0 then
        return
    end

    table.sort(self.m_skillList, function(v1, v2)
        if v1.id < v2.id then
            return true
        end
    end )

    self.m_scrollSkillPanel:cleanupNonAutoChildren()
    local winMgr = CEGUI.WindowManager:getSingleton()
    local roleLevel = gGetDataManager():GetMainCharacterLevel()
    for i, v in ipairs(self.m_skillList) do
        local skillBean = v
        LogInfo("skillID: " .. tostring(skillBean.id))
        local namePrefix = tostring(skillBean.id)
        local curRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(skillBean.id)
        local cellWnd = winMgr:loadWindowLayout("lifeskillcell.layout", namePrefix)

        if i == self.m_curSkillIndex then
            self.m_skillID = skillBean.id
            self.m_skillLevel = skillBean.level
            self.m_skillMaxLevel = skillBean.maxlevel
            self.m_skillExp = skillBean.exp
            self.m_skillEffects = skillBean.effects
            self.m_skillNextEffects = skillBean.nexteffect
        end
        if cellWnd then
            self.m_scrollSkillPanel:addChildWindow(cellWnd)
            local cellSkill = winMgr:getWindow(namePrefix .. "lifeskillcell/skill")
            local cellSkillBg = winMgr:getWindow(namePrefix.."lifeskillcell")
            local cellHeight = cellSkillBg:getPixelSize().height
            local cellWidth = cellSkillBg:getPixelSize().width
            local yDistance = 1.0
            local xDistance = 1.0
            local yPosData = math.floor((i - 1) / 2)
            if yPosData < 0 then
                yPosData = 0
            end
            local yPos = 8 + (cellHeight + yDistance) * yPosData
            local xPos = 8

            if math.mod(i, 2) == 0 then
                xPos = 1 + cellWidth + xDistance + 10
            end
            cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))

            local skillBoxName = namePrefix .. "lifeskillcell/skill"
            local skillLayout = { }
            skillLayout.skillBox = CEGUI.toSkillBox(winMgr:getWindow(skillBoxName))
            skillLayout.skillBox:setID(skillBean.id)
            skillLayout.skillLevel = skillBean.level
            skillLayout.skillBg = CEGUI.toGroupButton(winMgr:getWindow(namePrefix.."lifeskillcell"))
            skillLayout.skillBg:setID(skillBean.id)
            LogInfo("---curRecord.icon: " .. tostring(curRecord.icon))
            skillLayout.skillBox:SetImage(gGetIconManager():GetImageByID(curRecord.icon))
            -- 右下角等级值
            local skillLevel_st = winMgr:getWindow(namePrefix .. "lifeskillcell/skill/level")
            skillLevel_st:setText("" .. tostring(skillBean.level))

            skillLayout.skillBg:subscribeEvent("SelectStateChanged", XiulianSkillDlg.HandleSkillClicked, self)
            -- 技能名称
            skillLayout.name = winMgr:getWindow(namePrefix .. "lifeskillcell/name")
            skillLayout.name:setText(curRecord.name)
            self.m_skills[i] = skillLayout
        end

        if i >= 4 and roleLevel < 55 then
            break
        end

    end

    -- 设置当前选择的技能
    if self.m_skills[self.m_curSkillIndex] then
        --self.m_skills[self.m_curSkillIndex].skillBox:SetSelected(true)
        self.m_skills[self.m_curSkillIndex].skillBg:setSelected(true)
        self:RefreshSkill()
    end

end

function XiulianSkillDlg:HandleInfo2BtnClicked(args)
    local tips1 = require "logic.workshop.tips1"
    local title = MHSD_UTILS.get_resstring(11486)
    local strAllString = MHSD_UTILS.get_resstring(11476)
    local tips_instance = tips1.getInstanceAndShow(strAllString, title)
    local size = tips_instance.richBox:GetExtendSize()
    local vec2 = NewVector2(size.width + 80, size.height + 70)
    tips_instance.richBox:setSize(vec2)

    vec2.x.offset = size.width + 80
    vec2.y.offset = size.height+ 70
    tips_instance.bg:setSize(vec2)

    local titleWidth_offset = tips_instance.title_st:getWidth().offset
    local titleWidth_scale = tips_instance.title_st:getWidth().scale
    tips_instance.title_st:setWidth(CEGUI.UDim(titleWidth_scale, titleWidth_offset))

end
function XiulianSkillDlg:HandleInfoBtnClicked(args)
    local limit = 0


    local tips1 = require "logic.workshop.tips1"
    local title = MHSD_UTILS.get_resstring(11258)
    local strAllString
    if not IsPointCardServer() then
        strAllString = MHSD_UTILS.get_resstring(11259)
    else
        strAllString = MHSD_UTILS.get_resstring(11580)
    end
    local strbuilder = StringBuilder:new()
    -- 获得玩家工会等级
    local factionLevelMax = 0
    local factionData = require "logic.faction.factiondatamanager"
    local factionLevelNumber = tonumber(factionData.factionlevel)
    if factionData.factionlevel then
        local ids
        if not IsPointCardServer() then
            ids = BeanConfigManager.getInstance():GetTableByName("skill.cparticeskilllevelup"):getAllID()
        else
            ids = BeanConfigManager.getInstance():GetTableByName("skill.cpointcardparticeskilllevelup"):getAllID()
        end
        for i = 1, #ids do
            local v = ids[i]
            local recordcp1
            if not IsPointCardServer() then
                recordcp1 = BeanConfigManager.getInstance():GetTableByName("skill.cparticeskilllevelup"):getRecorder(v)
            else
                recordcp1 = BeanConfigManager.getInstance():GetTableByName("skill.cpointcardparticeskilllevelup"):getRecorder(v)
            end
            if factionLevelNumber >= recordcp1.factionlevel then
                if factionLevelMax < recordcp1.id then
                    factionLevelMax = recordcp1.id
                end
            end
        end
    end
    if factionLevelMax ~= 0 then
        factionLevelMax = factionLevelMax + 1
    end
    if factionLevelMax > 20 then
        factionLevelMax = 20
    end
    limit = factionLevelMax
    -- 获取玩家当前等级
    local roleLevel = gGetDataManager():GetMainCharacterLevel()
    local roleLevelMax = 0
    local ids
    if not IsPointCardServer() then
        ids = BeanConfigManager.getInstance():GetTableByName("skill.cparticeskilllevelup"):getAllID()
    else
        ids = BeanConfigManager.getInstance():GetTableByName("skill.cpointcardparticeskilllevelup"):getAllID()
    end
    for i = 1, #ids do
        local v = ids[i]
        local record
        if not IsPointCardServer() then
            record = BeanConfigManager.getInstance():GetTableByName("skill.cparticeskilllevelup"):getRecorder(v)
        else
            record = BeanConfigManager.getInstance():GetTableByName("skill.cpointcardparticeskilllevelup"):getRecorder(v)
        end
        if record.playerlevel <= roleLevel then
            if roleLevelMax < record.id then
                roleLevelMax = record.id
            end
        end
    end
    roleLevelMax = roleLevelMax + 1
    if roleLevelMax > 20 then
        roleLevelMax = 20
    end
    if roleLevelMax < limit then
        limit = roleLevelMax
    end
    local roleMaxStr = tostring(roleLevelMax)
    if roleLevelMax >= 20 then
        roleMaxStr = MHSD_UTILS.get_resstring(11274)
    end
    -- 获取玩家公会历史贡献
    strbuilder:Set("parameter3", tostring(self.m_curBanggong))
    local banggongMax
    if not IsPointCardServer() then
        banggongMax = math.floor(self.m_curBanggong / 150) + 5
    else
        banggongMax = math.floor(self.m_curBanggong / 150) + 2
    end
    if banggongMax > 20 then
        banggongMax = 20
    end
    if banggongMax < limit then
        limit = banggongMax
    end
    local banggongMaxStr = tostring(banggongMax)
    if banggongMax >= 20 then
        banggongMaxStr = MHSD_UTILS.get_resstring(11274)
    end

    local greenColor = "ff17d604"
    local redColor = "fffe0d0d"
    local factionMaxStr = tostring(factionLevelMax)
    if factionLevelMax >= 20 then
        factionMaxStr = MHSD_UTILS.get_resstring(11274)
    end
    strbuilder:Set("parameter1", factionMaxStr)
    if self.m_skillLevel > factionLevelMax then
        strbuilder:Set("color1", redColor)
    else

        if factionLevelMax <= roleLevelMax and factionLevelMax <= banggongMax then
            strbuilder:Set("color1", redColor)
        else
            strbuilder:Set("color1", greenColor)
        end
    end
    strbuilder:Set("parameter2", roleMaxStr)
    if self.m_skillLevel > roleLevelMax then
        strbuilder:Set("color2", redColor)
    else
        if roleLevelMax <= factionLevelMax and roleLevelMax <= banggongMax then
            strbuilder:Set("color2", redColor)
        else
            strbuilder:Set("color2", greenColor)
        end

    end
    strbuilder:Set("parameter4", banggongMaxStr)
    if self.m_skillLevel > banggongMax then
        strbuilder:Set("color4", redColor)
    else
        if banggongMax <= factionLevelMax and banggongMax <= roleLevelMax then
            strbuilder:Set("color4", redColor)
        else
            strbuilder:Set("color4", greenColor)
        end
    end

    limit = self.m_maxSkillLevel
    strbuilder:Set("parameter5", tostring(limit))
    strbuilder:Set("color5", greenColor)
    local content = strbuilder:GetString(strAllString)
    strbuilder:delete()
    tips1.getInstanceAndShow(content, title)

    local tips_instance = tips1.getInstanceAndShow(content, title)

end

function XiulianSkillDlg:HandleSkillClicked(args)
    local event = CEGUI.toWindowEventArgs(args)
    local skillID = event.window:getID()
    -- 如果点击是当前已选择的技能，就返回
    if self.m_skills[self.m_curSkillIndex].skillBox:getID() == skillID then
        return
    end

    self.m_skillList[self.m_curSkillIndex].id = self.m_skillID
    self.m_skillList[self.m_curSkillIndex].level = self.m_skillLevel
    self.m_skillList[self.m_curSkillIndex].maxlevel = self.m_skillMaxLevel
    self.m_skillList[self.m_curSkillIndex].exp = self.m_skillExp
    self.m_skillList[self.m_curSkillIndex].effects = self.m_skillEffects
    self.m_skillList[self.m_curSkillIndex].nexteffect = self.m_skillNextEffects
    for i, v in ipairs(self.m_skills) do
        if self.m_skills[i].skillBox:getID() == skillID then
            self.m_skills[self.m_curSkillIndex].skillBox:SetSelected(false)
            self.m_curSkillIndex = i
            break
        end
    end
    --self.m_skills[self.m_curSkillIndex].skillBox:SetSelected(true)
    
    local skillBean = self.m_skillList[self.m_curSkillIndex]
    self.m_skillID = skillBean.id
    self.m_skillLevel = skillBean.level
    self.m_skillMaxLevel = skillBean.maxlevel
    self.m_skillExp = skillBean.exp
    self.m_skillEffects = skillBean.effects
    self.m_skillNextEffects = skillBean.nexteffect
    self:RefreshSkill()
end


function XiulianSkillDlg:HandleStudyBtnClicked(args)
    local event = CEGUI.toWindowEventArgs(args)
    local studyType = event.window:getID()
    local curSkillID = self.m_skills[self.m_curSkillIndex].skillBox:getID()
    local itemID = 0
    local times = 0

    -- 当前是否有工会判断，没有工会进入加入公会UI
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager:IsHasFaction() == false then
        --XiulianSkillDlg.DestroyDialog()
        GetCTipsManager():AddMessageTipById(160139)
        --Familyjiarudialog.getInstanceAndShow()
        return
    end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    -- 使用道具
    if studyType > 10 then
        itemID = studyType
    -- 花银币学习
    else
        times = studyType
    end

    -- 如果不使用道具且银币不足
    local yinbiCount = roleItemManager:GetPackMoney()
    if itemID == 0 and self.m_needYinbi * times > yinbiCount then
        local result1 = self.m_needYinbi * times - yinbiCount
        CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, result1)
        return
    end

    -- 如果使用道具
    if itemID > 0 then
        local itemCount = roleItemManager:GetItemNumByBaseID(itemID)

        -- 道具数量不足
        if itemCount == 0 then
            if itemID == 334100 then
                GetCTipsManager():AddMessageTipById(160105)
            else
                GetCTipsManager():AddMessageTipById(160104)
            end
            return
        end

        -- 默认使用所有的道具
        times = itemCount
    end

    -- 如果使用道具，则计算使用的道具数量
    if itemID > 0 then
        local xiulianRecord
        if not IsPointCardServer() then
            xiulianRecord = BeanConfigManager.getInstance():GetTableByName("skill.cparticeskilllevelup"):getRecorder(self.m_skillLevel)
        else
            xiulianRecord = BeanConfigManager.getInstance():GetTableByName("skill.cpointcardparticeskilllevelup"):getRecorder(self.m_skillLevel)
        end


        local maxExp = xiulianRecord.vecskillexp[self.m_curSkillIndex - 1]
        local nowExp = self.m_skillExp
        local expRecord = BeanConfigManager.getInstance():GetTableByName("skill.cpracticeitemexp"):getRecorder(itemID)

        -- 计算提升等级需要的道具数量
        local needTimes = (maxExp - nowExp) / expRecord.exp
        if needTimes - math.floor(needTimes) > 0 then
            needTimes = math.floor(needTimes) + 1
        else
            needTimes = math.floor(needTimes)
        end

        -- 如果使用的道具数量不得超过提升等级需要的道具数量
        if times > needTimes then
            times = needTimes
        end
    end

    -- 发送学习请求
    local p = require "protodef.fire.pb.skill.particleskill.crequestlearnparticleskill".Create()
    p.id = curSkillID
    p.times = times
    p.itemid = itemID
    LuaProtocolManager.getInstance():send(p)

end


function XiulianSkillDlg:RefreshSkill(skillTbl)
    local winMgr = CEGUI.WindowManager:getSingleton()
    if skillTbl then
        self.m_skillID = skillTbl.id
        self.m_skillLevel = skillTbl.level
        self.m_skillMaxLevel = skillTbl.maxlevel
        self.m_skillExp = skillTbl.exp
        self.m_skillEffects = skillTbl.effects
        self.m_skillNextEffects = skillTbl.nexteffect
    end
    local curRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(self.m_skillID)
    if not curRecord then
        return
    end
    local skillName_st = winMgr:getWindow("xiulianskill/bg/taitou/name")
    skillName_st:setText(curRecord.name)
    local skillLevel_st = winMgr:getWindow("xiulianskill/bg/taitou/level")
    skillLevel_st:setText("" .. tostring(self.m_skillLevel))
    local maxLevel_st = winMgr:getWindow("xiulianskill/bg/dengjitext")
    maxLevel_st:setText("" .. tostring(self.m_skillMaxLevel))
	self.m_maxSkillLevel = self.m_skillMaxLevel

    local skillBox = CEGUI.toSkillBox(winMgr:getWindow("xiulianskill/bg/tubiao"))
    skillBox:SetImage(gGetIconManager():GetImageByID(curRecord.icon))

    local progressBar = CEGUI.toProgressBar(winMgr:getWindow("xiulianskill/bg/tiao"))
    progressBar:setProperty("VerticalProgress", "False")
    if self.m_skillLevel > 40 then
        self.m_skillLevel = 40
    end
    local xiulianRecord
    if not IsPointCardServer() then
        xiulianRecord = BeanConfigManager.getInstance():GetTableByName("skill.cparticeskilllevelup"):getRecorder(self.m_skillLevel)
    else
        xiulianRecord = BeanConfigManager.getInstance():GetTableByName("skill.cpointcardparticeskilllevelup"):getRecorder(self.m_skillLevel)
    end
    local maxExp = xiulianRecord.vecskillexp[self.m_curSkillIndex - 1]

    if self.m_skillLevel < 40 then
        if self.m_skillExp == 0 then
            progressBar:setProgress(0)
            progressBar:setText("0/" .. tostring(maxExp))
        else
            progressBar:setProgress(self.m_skillExp / maxExp)
            progressBar:setText(tostring(self.m_skillExp) .. "/" .. tostring(maxExp))
        end
    else
        local tRecord
        if not IsPointCardServer() then
            tRecord = BeanConfigManager.getInstance():GetTableByName("skill.cparticeskilllevelup"):getRecorder(self.m_skillLevel - 1)
        else
            tRecord = BeanConfigManager.getInstance():GetTableByName("skill.cpointcardparticeskilllevelup"):getRecorder(self.m_skillLevel - 1)
        end

        local fulLevelMaxExp = tRecord.vecskillexp[self.m_curSkillIndex - 1]
        progressBar:setProgress(1)
        progressBar:setText(tostring(fulLevelMaxExp) .. "/" .. tostring(fulLevelMaxExp))
    end

    -- 影响对象
    local targetType_st = winMgr:getWindow("xiulianskill/bg/yingxiong")
    targetType_st:setText(curRecord.description)

    -- 技能说明
    local skilldesc_st = winMgr:getWindow("xiulianskill/bg/tishen1")
   -- skilldesc_st:setText(curRecord.upgradeVariable)
    skilldesc_st:setText("")
    local skilldesc_st2 = winMgr:getWindow("xiulianskill/bg/tishen2")
    --skilldesc_st2:setText(curRecord.upgradeVariable2)
    skilldesc_st2:setText("")
    local skilldesc_st3 = winMgr:getWindow("xiulianskill/bg/tishen3")
    --skilldesc_st3:setText(curRecord.upgradeVariable3)
    skilldesc_st3:setText("")
    local skilldesc_st4 = winMgr:getWindow("xiulianskill/bg/tishen4")
    --skilldesc_st4:setText(curRecord.upgradeVariable4)
    skilldesc_st4:setText("")
    
    -- 技能说明
    local jiantou_st = winMgr:getWindow("xiulianskill/bg/2/tu")
    local jiantou_st2 = winMgr:getWindow("xiulianskill/bg/2/tu1")
    local jiantou_st3 = winMgr:getWindow("xiulianskill/bg/2/tu2")
    local jiantou_st4 = winMgr:getWindow("xiulianskill/bg/2/tu3")

    -- 提升数值
    local nextSkillLevel = self.m_skillLevel + 1
    if nextSkillLevel > 40 then
        nextSkillLevel = 40
    end

    local curValue_st5 = winMgr:getWindow("xiulianskill/bg/yue5")
    local curValue_st5val = winMgr:getWindow("xiulianskill/bg/yueda1")
    local desc = curRecord.upgradeDesc
    local countEffcts = 0
    for _ in pairs(self.m_skillEffects) do countEffcts = countEffcts + 1 end
    if string.len(curRecord.upgradeDesc) > 0 then
        curValue_st5:setVisible(true)
        curValue_st5val:setVisible(true)
        skilldesc_st:setVisible(true)
        curValue_st5:setText(curRecord.cureffect1)
        if countEffcts ~= 0 then
    local effectValue = self.m_skillEffects[tonumber(curRecord.curid1)] 
    local percent = effectValue / 10
    if percent < 0.1 then
        percent = 0 
    end
    local strPercent = string.format("%.1f%%", percent) 
    strPercent = strPercent:gsub("%.0", "") 
    curValue_st5val:setText("[colour='FFFFFFFF']" .. strPercent)  -- 应用百分比显示
else
    curValue_st5val:setText("[colour='FFFFFFFF']" .. "0%")  --  初始值设置为 0% 
end
        if self.m_skillNextEffects[tonumber(curRecord.curid1)] ~= nil then
    local effectValue = self.m_skillNextEffects[tonumber(curRecord.curid1)] 
    local percent = effectValue / 10
    if percent < 0.1 then
        percent = 0 
    end
    local strPercent = string.format("%.1f%%", percent) 
    strPercent = strPercent:gsub("%.0", "") 
    skilldesc_st:setText("[colour='FFFFFFFF']" .. strPercent) 
    jiantou_st:setVisible(true)
else
            skilldesc_st:setText("")
            jiantou_st:setVisible(false)
        end
    else
        curValue_st5:setVisible(false)
        curValue_st5val:setVisible(false)
        skilldesc_st:setVisible(false)
        jiantou_st:setVisible(false)
    end

    local curValue_st6 = winMgr:getWindow("xiulianskill/bg/yue6")
    local curValue_st6val = winMgr:getWindow("xiulianskill/bg/yueda2")
    local desc2 = curRecord.upgradeDesc2
    if string.len(desc2) > 0 then
        curValue_st6:setVisible(true)
        curValue_st6val:setVisible(true)
        skilldesc_st2:setVisible(true)
        jiantou_st2:setVisible(true)
        curValue_st6:setText(curRecord.cureffect2)
		if countEffcts ~= 0 then
    local effectValue = self.m_skillEffects[tonumber(curRecord.curid2)] 
    local percent = effectValue / 10
    if percent < 0.1 then
        percent = 0 
    end
    local strPercent = string.format("%.1f%%", percent) 
    strPercent = strPercent:gsub("%.0", "") 
    curValue_st6val:setText("[colour='FFFFFFFF']" .. strPercent)  -- 应用百分比显示
else
    curValue_st6val:setText("[colour='FFFFFFFF']" .. "0%")  --  初始值设置为 0% 
end
	        if self.m_skillNextEffects[tonumber(curRecord.curid2)] ~= nil then
    local effectValue = self.m_skillNextEffects[tonumber(curRecord.curid2)] 
    local percent = effectValue / 10
    if percent < 0.1 then
        percent = 0 
    end
    local strPercent = string.format("%.1f%%", percent) 
    strPercent = strPercent:gsub("%.0", "") 
    skilldesc_st2:setText("[colour='FFFFFFFF']" .. strPercent) 
    jiantou_st2:setVisible(true)
else
            skilldesc_st2:setText("")
            jiantou_st2:setVisible(false)
        end
    else
        curValue_st6:setVisible(false)
        curValue_st6val:setVisible(false)
        skilldesc_st2:setVisible(false)
        jiantou_st2:setVisible(false)
    end

    local curValue_st7 = winMgr:getWindow("xiulianskill/bg/yue7")
    local curValue_st7val = winMgr:getWindow("xiulianskill/bg/yueda3")
    local desc3 = curRecord.upgradeDesc3
    if string.len(desc3) > 0 then
        curValue_st7:setVisible(true)
        curValue_st7val:setVisible(true)
        skilldesc_st3:setVisible(true)
        jiantou_st3:setVisible(true)
        curValue_st7:setText(curRecord.cureffect3)
		if countEffcts ~= 0 then
    local effectValue = self.m_skillEffects[tonumber(curRecord.curid3)] 
    local percent = effectValue / 10
    if percent < 0.1 then
        percent = 0 
    end
    local strPercent = string.format("%.1f%%", percent) 
    strPercent = strPercent:gsub("%.0", "") 
    curValue_st7val:setText("[colour='FFFFFFFF']" .. strPercent)  -- 应用百分比显示
else
    curValue_st7val:setText("[colour='FFFFFFFF']" .. "0%")  --  初始值设置为 0% 
end
        if self.m_skillNextEffects[tonumber(curRecord.curid3)] ~= nil then
        local effectValue = self.m_skillNextEffects[tonumber(curRecord.curid3)] 
        local percent = effectValue / 10
        if percent < 0.1 then
           percent = 0 
        end
        local strPercent = string.format("%.1f%%", percent) 
        strPercent = strPercent:gsub("%.0", "") 
        skilldesc_st3:setText("[colour='FFFFFFFF']" .. strPercent) 
        jiantou_st3:setVisible(true)
    else
            skilldesc_st3:setText("")
            jiantou_st3:setVisible(false)
        end
    else
        curValue_st7:setVisible(false)
        curValue_st7val:setVisible(false)
        skilldesc_st3:setVisible(false)
        jiantou_st3:setVisible(false)
        end

    local curValue_st8 = winMgr:getWindow("xiulianskill/bg/yue8")
    local curValue_st8val = winMgr:getWindow("xiulianskill/bg/yueda4")
    local desc4 = curRecord.upgradeDesc4
    if string.len(desc4) > 0 then
        curValue_st8:setVisible(true)
        curValue_st8val:setVisible(true)
        skilldesc_st4:setVisible(true)
        jiantou_st4:setVisible(true)
        curValue_st8:setText(curRecord.cureffect4)
		if countEffcts ~= 0 then
    local effectValue = self.m_skillEffects[tonumber(curRecord.curid4)] 
    local percent = effectValue / 10
    if percent < 0.1 then
        percent = 0 
    end
    local strPercent = string.format("%.1f%%", percent) 
    strPercent = strPercent:gsub("%.0", "") 
    curValue_st8val:setText("[colour='FFFFFFFF']" .. strPercent)  -- 应用百分比显示
else
    curValue_st8val:setText("[colour='FFFFFFFF']" .. "0%")  --  初始值设置为 0% 
end
		if self.m_skillNextEffects[tonumber(curRecord.curid4)] ~= nil then
        local effectValue = self.m_skillNextEffects[tonumber(curRecord.curid4)] 
        local percent = effectValue / 10
        if percent < 0.1 then
           percent = 0 
        end
        local strPercent = string.format("%.1f%%", percent) 
        strPercent = strPercent:gsub("%.0", "") 
        skilldesc_st4:setText("[colour='FFFFFFFF']" .. strPercent) 
        jiantou_st4:setVisible(true)
    else
            skilldesc_st4:setText("")
            jiantou_st4:setVisible(false)
        end
    else
        curValue_st8:setVisible(false)
        curValue_st8val:setVisible(false)
        skilldesc_st4:setVisible(false)
        jiantou_st4:setVisible(false)
    end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    local yinbiCount = roleItemManager:GetPackMoney()
    local formatStr = require "utils.mhsdutils".GetMoneyFormatString(yinbiCount)
    self.m_haveYinbi_st:setText(formatStr)
    local common = GameTable.common.GetCCommonTableInstance():getRecorder(165)
    local needYinbi = tonumber(common.value)
    self.m_needYinbi = needYinbi
    local formatStr1 = require "utils.mhsdutils".GetMoneyFormatString(common.value)
    if yinbiCount < needYinbi then
        self.m_needYinbi_st:setText("[colour='FFFFFFFF']" .. formatStr1)
    else
        self.m_needYinbi_st:setText(formatStr1)
    end

    self.xiulianDan = CEGUI.toItemCell(winMgr:getWindow("xiulianskill/wupin"))
    local itemID = 334100
    if self.m_skillID >= 360020 and self.m_skillID < 360030 then
        itemID = 334101
    end
    local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemID)
    if item then
        self.xiulianDan:SetImage(gGetIconManager():GetImageByID(item.icon))
    end
    self.xiulianDan:setID(itemID)
    local itemCount = roleItemManager:GetItemNumByBaseID(itemID)
    self.xiulianDan:SetTextUnit(itemCount)

    self.xiulianDan:subscribeEvent("TableClick", XiulianSkillDlg.HandleItemClickWithItemID, self)


    local studyItemBtn = CEGUI.toPushButton(winMgr:getWindow("xiulianskill/btn3"))
    studyItemBtn:setID(itemID)

    -- 右下角等级值
    local namePrefix = tostring(self.m_skillID)
    local cellname = namePrefix .. "lifeskillcell/skill/level"
    if winMgr:isWindowPresent(cellname) then
        local skillLevel_st = winMgr:getWindow(cellname)
        skillLevel_st:setText("" .. tostring(self.m_skillLevel))
    end
end

function XiulianSkillDlg:HandleItemClickWithItemID(args)
    local event = CEGUI.toWindowEventArgs(args)
    local itemID = event.window:getID()
    local Commontipdlg = require "logic.tips.commontipdlg"
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    -- 计算提示窗口位置
    local winMgr = CEGUI.WindowManager:getSingleton()
    local itemPos = self.xiulianDan:getPosition()
    local posX = itemPos.x.offset - self.xiulianDan:getWidth().offset * 3.2
    local posY = itemPos.y.offset + self.xiulianDan:getHeight().offset * 1.25

    local nType = Commontipdlg.eType.eSkill
    local pObj = -1
    commontipdlg:RefreshItem(nType, itemID, posX, posY)

end



function XiulianSkillDlg.OnMoneyChange()
    local dlg = XiulianSkillDlg:getInstanceOrNot()
    if dlg then
        local winMgr = CEGUI.WindowManager:getSingleton()
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local yinbiCount = roleItemManager:GetPackMoney()
        local formatStr = require "utils.mhsdutils".GetMoneyFormatString(yinbiCount)
        dlg.m_haveYinbi_st:setText(formatStr)
        local formatStr1 = debugrequire "utils.mhsdutils".GetMoneyFormatString(dlg.m_needYinbi)
        if dlg.m_needYinbi > yinbiCount then
            dlg.m_needYinbi_st:setText("[colour='FFFF0000']" .. formatStr1)
        else
            dlg.m_needYinbi_st:setProperty("TextColours", dlg.m_yinbiColor)
            dlg.m_needYinbi_st:setText(formatStr1)
        end
    end
end

return XiulianSkillDlg


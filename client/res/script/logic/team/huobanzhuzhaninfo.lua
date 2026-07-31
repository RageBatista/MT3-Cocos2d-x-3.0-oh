require "logic.dialog"

huobanzhuzhaninfo = { }
setmetatable(huobanzhuzhaninfo, Dialog)
huobanzhuzhaninfo.__index = huobanzhuzhaninfo

function huobanzhuzhaninfo:addSprite(modelId)
    local pos = self.canvas:GetScreenPosOfCenter()
    local loc = Nuclear.NuclearPoint(pos.x, pos.y + 50)
    if self.sprite then
        self.sprite:delete()
        self.sprite = nil
        self.canvas:getGeometryBuffer():setRenderEffect(nil)
    end
    self.sprite = UISprite:new(modelId)
    if self.sprite then
        self.sprite:SetUILocation(loc)
        self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
        local weapon = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(modelId)
        self.sprite:SetSpriteComponent(eSprite_Weapon, weapon.showWeaponId)
        local heroTable = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(self.heroId)
        self.sprite:SetUIScale(heroTable.scalefactor)
        self.canvas:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, huobanzhuzhaninfo.performPostRenderFunctions))
    end
end

function huobanzhuzhaninfo.performPostRenderFunctions(id)
    if huobanzhuzhaninfo:getInstance().sprite and huobanzhuzhaninfo:getInstance():IsVisible() and huobanzhuzhaninfo:getInstance():GetWindow():getEffectiveAlpha() > 0.95 then
        huobanzhuzhaninfo:getInstance().sprite:RenderUISprite()
    end
end

-- 点图标
function huobanzhuzhaninfo:HandleSkillIcon(args)
    -- 获得人物信息
    local record = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(self.heroId)
    local mouseEvent = CEGUI.toMouseEventArgs(args)
    local window = mouseEvent.window
    local skillId = window:getID()
    if skillId == 0 then
        return
    end
    local battleTip = BattleSkillTip.getInstanceAndShow()
    battleTip:SetSkill(skillId)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local skillUi = winMgr:getWindow("skilltipsdialog")
    local backupUi = winMgr:getWindow("huobanzhuzhaninfo")
    -- local pos=mouseEvent.position
    local width = skillUi:getWidth()
    -- 当前技能是本伙伴的精通技能，追加一个精通文本
    if skillId == record.first_skill then
        -- local strbuilder = StringBuilder:new()
        -- local strMsg = strbuilder:GetString()
        battleTip:AppendSkillDescLine(CEGUI.String(MHSD_UTILS.get_resstring(11216)))
    end

    -- width.offset=280
    --skillUi:setWidth(width)
    local attrUi = winMgr:getWindow("huobanzhuzhaninfo/titlename/name")
    --skillUi:setHeight(attrUi:getHeight())
    local pos = backupUi:getPosition()
    -- pos.y=skillUi:getPosition().y
    skillUi:setPosition(CEGUI.UVector2(CEGUI.UDim(pos.x.scale, pos.x.offset + 10), pos.y + skillUi:getPosition().y))
    skillUi:setTopMost(true)

end
-- wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,10),CEGUI.UDim(0,(i-1)*(cellh+5))))
-- 检查是否处于出战状态
function huobanzhuzhaninfo:IsFightState(heroId)
    local activeGroupId = MT3HeroManager.getInstance():getSelectGroupId()
    local members = MT3HeroManager.getInstance():getGroupMember(activeGroupId)
    for i = 0, members:size() -1 do
        if members[i] == heroId then
            return true
        end
    end
    return false
end

-- 刷新一下解锁状态
function huobanzhuzhaninfo:refreshUI()
    local winMgr = CEGUI.WindowManager:getSingleton()
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
    local heroId = self.heroId
    local record = tableInstance:getRecorder(heroId)
    local heroInfo = MT3HeroManager.getInstance():getHeroInfo(heroId)
    local unlockBtn = winMgr:getWindow("huobanzhuzhaninfo/btnjiesuo")
    self.freeWnd = winMgr:getWindow("huobanzhuzhaninfo/shengyushijian")
    -- 设置解锁状态
    if heroInfo.mState == 0 then
        -- 未解锁
        unlockBtn:setVisible(true)
        self.freeWnd:setVisible(false)
    elseif heroInfo.mState == 1 then
        -- 永久解锁
        unlockBtn:setVisible(false)
        self.freeWnd:setVisible(false)
    elseif heroInfo.mState > 0 then
        -- 不是永久免费
        if heroInfo.mWeekFree then
            unlockBtn:setVisible(true)
            self.freeWnd:setVisible(true)
            self.freeWnd:setText(self.mWord_benzhoumianfei)
        else
            unlockBtn:setVisible(true)
            self.freeWnd:setVisible(true)
            self.freeWnd:setText(self:GetFreeTimeString(heroInfo))
        end

    end

    -- 设置上下阵状态
    local min = heroInfo.mState
    if heroInfo.mState > 0 then
        if self:IsFightState(heroId) then
            self.quitBtn:setVisible(true)
            self.johnBtn:setVisible(false)
        else
            -- 没有上阵
            self.quitBtn:setVisible(false)
            self.johnBtn:setVisible(true)
        end
    else
        self.quitBtn:setVisible(false)
        self.johnBtn:setVisible(false)
    end


    --[[	if heroInfo.mState == 2 then
	freeWnd:setText(self.mWord_benzhoumianfei)
	freeWnd:setVisible(true)
elseif heroInfo.mState > 10 then
	local fenzhongNumber=heroInfo.mState-10
	local tianNumber=math.floor(fenzhongNumber/1440)
	if heroInfo.mWeekFree then
		tianNumber=tianNumber+7
	end
	freeWnd:setText(tostring(tianNumber)..self.mWord_tian)
	freeWnd:setVisible(true)
else
	freeWnd:setVisible(false)
	end]]

end
function huobanzhuzhaninfo:GetFreeTimeString(heroData)
    if heroData.mEnableTime >= 86400 then
        -- 一天有86400秒
        local tian = math.floor(heroData.mEnableTime / 86400)
        return tostring(tian) .. self.mWord_tian
    elseif heroData.mEnableTime >= 3600 then
        -- 一小时有3600秒
        local xiaoshi = math.floor(heroData.mEnableTime / 3600)
        return tostring(xiaoshi) .. self.mWord_xiaoshi
    elseif heroData.mEnableTime >= 60 then
        -- 一分钟60秒
        local fenzhong = math.floor(heroData.mEnableTime / 60)
        return tostring(fenzhong) .. self.mWord_fenzhong
    else
        return tostring(math.floor(heroData.mEnableTime)) .. self.mWord_miao
    end

    return "0" .. self.mWord_miao
end
-- 刷新时间
function huobanzhuzhaninfo:SetTime(text)
    if self.freeWnd ~= nil then
        -- 文本内容为“”不显示 文本
        if text ~= "" then
            self.freeWnd:setVisible(true)
            self.freeWnd:setText(text)
        end

    end

end
function huobanzhuzhaninfo:update(delta)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local heroId = self.heroId

    if heroId == nil or heroId == 0 then
        return
    end

    local heroInfo = MT3HeroManager.getInstance():getHeroInfo(heroId)
    local unlockBtn = winMgr:getWindow("huobanzhuzhaninfo/btnjiesuo")
    self.freeWnd = winMgr:getWindow("huobanzhuzhaninfo/shengyushijian")
    -- 设置解锁状态
    if heroInfo.mState == 0 then
        -- 未解锁
        unlockBtn:setVisible(true)
        self.freeWnd:setVisible(false)
    elseif heroInfo.mState == 1 then
        -- 永久解锁
        unlockBtn:setVisible(false)
        self.freeWnd:setVisible(false)
    elseif heroInfo.mState > 0 then
        -- 不是永久免费
        if heroInfo.mWeekFree then
            unlockBtn:setVisible(true)
            self.freeWnd:setVisible(true)
            self.freeWnd:setText(self.mWord_benzhoumianfei)
        else
            unlockBtn:setVisible(true)
            self.freeWnd:setVisible(true)
            self.freeWnd:setText(self:GetFreeTimeString(heroInfo))
        end

    end
end
-- 设置英雄的ID.
function huobanzhuzhaninfo:setHeroId(heroId)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
    self.heroId = heroId
    if heroId == nil or heroId == 0 then
        return
    end
    local record = tableInstance:getRecorder(heroId)
    local heroInfo = MT3HeroManager.getInstance():getHeroInfo(heroId)
    self.mWord_benzhoumianfei = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11104).msg
    self.mWord_tian = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11105).msg
    self.mWord_job1 = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11106).msg
    self.mWord_job2 = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11107).msg
    self.mWord_job3 = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11108).msg
    self.mWord_job4 = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11109).msg
    self.mWord_job5 = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11110).msg

    local heroName = winMgr:getWindow("huobanzhuzhaninfo/titlename/name")
	local heroNamec = winMgr:getWindow("huobanzhuzhaninfo/titlename/namec")
    heroName:setText(record.name)
	heroNamec:setText(record.namec)
    self.canvas = winMgr:getWindow("huobanzhuzhaninfo/ditu/renwutu")
    local id = record.shapeid
    self:addSprite(id)
    -- self.m_pSprite:SetUIDirection(Nuclear.XPDIR_BOTTOM)
    local heroJobType = winMgr:getWindow("huobanzhuzhaninfo/zhiyeleixing")
    local heroJobIcon = winMgr:getWindow("huobanzhuzhaninfo/zhiyetubiao")

    if record.acttype == 1 then
        self.m_FagongButton:setVisible(false)
        self.m_WugongButton:setVisible(true)
    else
        self.m_FagongButton:setVisible(true)
        self.m_WugongButton:setVisible(false)
    end
    local schoolrecord = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(record.school)
    heroJobIcon:setProperty("Image", schoolrecord.schoolpicpathc)
    heroJobType:setText(schoolrecord.namecc)
    -- if record.type==1 then
    -- 	heroJobIcon:setProperty("Image","set:huobanui image:huobanwugong")
    -- 	heroJobType:setText(self.mWord_job1)
    -- 	self.m_FagongButton:setVisible(false)
    -- 	self.m_WugongButton:setVisible(true)
    -- elseif record.type==2 then
    -- 	heroJobIcon:setProperty("Image","set:huobanui image:huoban_fagong")
    -- 	heroJobType:setText(self.mWord_job2)
    -- 	self.m_FagongButton:setVisible(true)
    -- 	self.m_WugongButton:setVisible(false)
    -- elseif record.type==3 then
    -- 	heroJobIcon:setProperty("Image","set:huobanui image:huoban_zhiliao")
    -- 	heroJobType:setText(self.mWord_job3)
    -- 	self.m_FagongButton:setVisible(true)
    -- 	self.m_WugongButton:setVisible(false)
    -- elseif record.type==4 then
    -- 	heroJobIcon:setProperty("Image","set:huobanui image:huoban_fuzhu")
    -- 	heroJobType:setText(self.mWord_job4)
    -- 	self.m_FagongButton:setVisible(true)
    -- 	self.m_WugongButton:setVisible(false)
    -- elseif record.type==5 then
    -- 	heroJobIcon:setProperty("Image","set:huobanui image:huoban_fengyin")
    -- 	heroJobType:setText(self.mWord_job5)
    -- 	self.m_FagongButton:setVisible(true)
    -- 	self.m_WugongButton:setVisible(false)
    -- end
    local heroLevel = winMgr:getWindow("huobanzhuzhaninfo/level")
    heroLevel:setText("" .. tostring(gGetDataManager():GetMainCharacterLevel()))
    --[[
	if self.mSelectGroupId~=-1 and self.mSelectGroupPos~=-1 and stateNumber>0 then
		iconWnd:SetMaskImage(1,"huobanui","huoban_UP")
	end
	--]]
    local attrs = { }
    attrs[1] = winMgr:getWindow("huobanzhuzhaninfo/textbg/qixueshu")
    attrs[2] = winMgr:getWindow("huobanzhuzhaninfo/textbg/fashangshu")
    attrs[3] = winMgr:getWindow("huobanzhuzhaninfo/textbg/fengyinshu")
    attrs[4] = winMgr:getWindow("huobanzhuzhaninfo/textbg/sudushu")
    attrs[5] = winMgr:getWindow("huobanzhuzhaninfo/textbg/zhiliaoshu")
    attrs[6] = winMgr:getWindow("huobanzhuzhaninfo/textbg/fashangshu1")
    attrs[7] = winMgr:getWindow("huobanzhuzhaninfo/textbg/fafangshu")
    attrs[8] = winMgr:getWindow("huobanzhuzhaninfo/textbg/kangfengshu")
    -- 修改属性对应不上BUG  local len = record.skillid:size() 没看明白有什么用 也许会有问题 by wangjianfeng
    local len = record.skillid:size()
    --[[	for i=1,8 do
		if i<(len+1) then
			local strAttrib=tostring(heroInfo.mAttrib[i-1])
			attrs[i]:setText(strAttrib)
		end

	end--]]
    attrs[1]:setText(heroInfo.mAttrib[7])
    if record.acttype == 1 then
        attrs[2]:setText(heroInfo.mAttrib[1])
    else
        attrs[2]:setText(heroInfo.mAttrib[3])
    end
    attrs[3]:setText(heroInfo.mAttrib[2])
    attrs[4]:setText(heroInfo.mAttrib[4])
    attrs[5]:setText(heroInfo.mAttrib[6])
    attrs[6]:setText(heroInfo.mAttrib[8])
    attrs[7]:setText(heroInfo.mAttrib[0])
    attrs[8]:setText(heroInfo.mAttrib[9])

    -- 显示伙伴技能
    for i = 1, 8 do
        self.skills[i]:setID(0)
        self.skills[i]:SetImage(nil)
        local skillId = 0
        if i <(len + 1) then
            skillId = record.skillid[i - 1]
            if skillId ~= 0 then
                local SkillInfor = BeanConfigManager.getInstance():GetTableByName("skill.cfriendskill"):getRecorder(skillId)
                if SkillInfor ~= nil then
                    local image = gGetIconManager():GetImageByID(SkillInfor.imageID)
                    if SkillInfor.imageID ~= 0 then
                        self.skills[i]:SetImage(image)
                    end
                end
                if SkillInfor.imageID ~= 0 then
                    self.skills[i]:setID(skillId)
                end
            end
        end


        if skillId == record.first_skill and skillId ~= 0 then
            self.firstSkills[i]:setVisible(true)
        else
            self.firstSkills[i]:setVisible(false)
        end
    end

    self:refreshUI()
    --[[
	--设置状态
	if heroInfo.mState == 0 then--未解锁
		unlockBtn:setVisible(true)
		self.johnBtn:setVisible(false)
		self.quitBtn:setVisible(false)
	elseif heroInfo.mState==1 then--永久解锁
		unlockBtn:setVisible(false)
		self.johnBtn:setVisible(false)
		self.quitBtn:setVisible(false)
	elseif heroInfo.mState > 0 then--不是永久免费
		unlockBtn:setVisible(true)
		if self:IsFightState(heroId) then -- 已经上阵
			self.quitBtn:setVisible(true)
			self.johnBtn:setVisible(false)
		else --没有上阵
			self.quitBtn:setVisible(false)
			self.johnBtn:setVisible(true)
		end
	end

	local freeWnd=winMgr:getWindow("huobanzhuzhaninfo/shengyushijian")
	if heroInfo.mState == 2 then
		freeWnd:setText(self.mWord_benzhoumianfei)
		freeWnd:setVisible(true)
	elseif heroInfo.mState > 10 then
		local fenzhongNumber=heroInfo.mState-10
		local tianNumber=math.floor(fenzhongNumber/1440)
		if heroInfo.mWeekFree then
			tianNumber=tianNumber+7
		end
		freeWnd:setText(tostring(tianNumber)..self.mWord_tian)
		freeWnd:setVisible(true)
	else
		freeWnd:setVisible(false)
	end
	--]]
end

-- 解锁
function huobanzhuzhaninfo:HandleUnlockBtn(args)
    if self.heroId == nil or self.heroId == 0 then
        return
    end
    gGetGameUIManager():RemoveUISprite(self.sprite)
    require("logic.team.huobanzhuzhanjiesuo").getInstanceAndShow()
    huobanzhuzhanjiesuo.getInstance():setHeroId(self.heroId)
end

-- 恢复
function huobanzhuzhaninfo:UndoSprit(args)
    if self.heroId == nil or self.heroId == 0 then
        return
    end
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
    local record = tableInstance:getRecorder(self.heroId)
    self:addSprite(record.shapeid)
end

-- 上阵
function huobanzhuzhaninfo:HandleJohnBtn(args)
    -- 检查是否处于战斗状态
    local activeGroupId = MT3HeroManager.getInstance():getSelectGroupId()
    local members = MT3HeroManager.getInstance():getGroupMember(activeGroupId)
    -- 上阵人数大于4
    local menber = members:size()
    if menber == 4 then
        local strbuilder = StringBuilder:new()
        msgid = 150113
        strbuilder:Set("Paramenet1", activeGroupId + 1)
        strbuilder:Set("Paramenet2", 4)
        local msg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(msgid))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(msg)
        huobanzhuzhaninfo.getInstance().DestroyDialog()
        return
    end


    if MT3HeroManager.getInstance():johnGroup(self.heroId, activeGroupId, menber) then
        self.johnBtn:setVisible(false)
        self.quitBtn:setVisible(true)

        huobanzhuzhaninfo.getInstance().DestroyDialog()
    end
end

-- 下阵
function huobanzhuzhaninfo:HandleQuitBtn(args)

    for i = 1, 3 do
        local members = MT3HeroManager.getInstance():getGroupMember(i - 1)
        for j = 1, members:size() do
            if members[j - 1] == self.heroId then
                if MT3HeroManager.getInstance():quitGroup(i - 1, j - 1) then
                    self.johnBtn:setVisible(true)
                    self.quitBtn:setVisible(false)

                end
                huobanzhuzhaninfo.getInstance().DestroyDialog()
                return
            end
        end
    end
    huobanzhuzhaninfo.getInstance().DestroyDialog()
end

-------------------------------------------------------------------------------------------------
local _instance
function huobanzhuzhaninfo.getInstance()
    if not _instance then
        _instance = huobanzhuzhaninfo:new()
        _instance:OnCreate()
    end
    return _instance
end

function huobanzhuzhaninfo.getInstanceAndShow()
    if not _instance then
        _instance = huobanzhuzhaninfo:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function huobanzhuzhaninfo.getInstanceNotCreate()
    return _instance
end

function huobanzhuzhaninfo.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            if _instance.sprite then
                _instance.sprite:delete()
                _instance.sprite = nil
                _instance.canvas:getGeometryBuffer():setRenderEffect(nil)
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function huobanzhuzhaninfo.ToggleOpenClose()
    if not _instance then
        _instance = huobanzhuzhaninfo:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end
function huobanzhuzhaninfo.HandleCloseBtnClick()
    huobanzhuzhaninfo.getInstance().DestroyDialog()
end
function huobanzhuzhaninfo.GetLayoutFileName()
    return "huobanzhuzhaninfo.layout"
end

function huobanzhuzhaninfo:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, huobanzhuzhaninfo)
    return self
end

function huobanzhuzhaninfo:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 左右按钮
    self.m_LeftButton = CEGUI.toPushButton(winMgr:getWindow("huobanzhuzhaninfo/left"))
    self.m_RightButton = CEGUI.toPushButton(winMgr:getWindow("huobanzhuzhaninfo/right"))
    self.m_WugongButton = CEGUI.toPushButton(winMgr:getWindow("huobanzhuzhaninfo/textbg/fashang"))
    self.m_FagongButton = CEGUI.toPushButton(winMgr:getWindow("huobanzhuzhaninfo/textbg/fagong"))
    self.m_LeftButton:setID(1)
    self.m_RightButton:setID(2)
    self.m_LeftButton:subscribeEvent("Clicked", self.HandleLeftAndRightClicked, self)
    self.m_RightButton:subscribeEvent("Clicked", self.HandleLeftAndRightClicked, self)
    local tableInstance = BeanConfigManager.getInstance():GetTableByName("message.cstringres")
    self.mWord_benzhoumianfei = tableInstance:getRecorder(11104).msg
    self.mWord_tian = tableInstance:getRecorder(11105).msg
    self.mWord_xiaoshi = tableInstance:getRecorder(315).msg
    self.mWord_fenzhong = tableInstance:getRecorder(314).msg
    self.mWord_miao = tableInstance:getRecorder(10015).msg
    self.skills = { }
    self.firstSkills = { }

    for i = 1, 8 do
        self.skills[i] = CEGUI.Window.toSkillBox(winMgr:getWindow("huobanzhuzhaninfo/textbg/skillbg" .. i))
        self.firstSkills[i] = winMgr:getWindow("huobanzhuzhaninfo/textbg/skillbg" .. i .. "/tubiao" .. i)
        self.skills[i]:subscribeEvent("SKillBoxClick", self.HandleSkillIcon, self)
    end

    local unlockBtn = winMgr:getWindow("huobanzhuzhaninfo/btnjiesuo")
    unlockBtn:subscribeEvent("MouseClick", self.HandleUnlockBtn, self)
    self.johnBtn = winMgr:getWindow("huobanzhuzhaninfo/btnxiazhen")
    self.johnBtn:subscribeEvent("MouseClick", self.HandleJohnBtn, self)
    self.quitBtn = winMgr:getWindow("huobanzhuzhaninfo/btnxiazhen1")
    self.quitBtn:subscribeEvent("MouseClick", self.HandleQuitBtn, self)

    self.mBtnClose = winMgr:getWindow("huobanzhuzhaninfo/close")
    self.mBtnClose:subscribeEvent("MouseClick", self.HandleCloseBtnClick, self)
end

-- 左右按钮事件
function huobanzhuzhaninfo:HandleLeftAndRightClicked(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    local MyIDTable = HuoBanZhuZhanDialog.getInstance().m_IconIDCollection
    -- 点击左
    if id == 1 then
        if HuoBanZhuZhanDialog.getInstance().m_SelectIndex ~= 1 then
            HuoBanZhuZhanDialog.getInstance().m_SelectIndex = HuoBanZhuZhanDialog.getInstance().m_SelectIndex - 1
            self.heroId = self:getIDByIndex(MyIDTable, HuoBanZhuZhanDialog.getInstance().m_SelectIndex)
            HuoBanZhuZhanDialog.getInstance():SendMessage_CGetHuobanDetailInfo(self.heroId)
            HuoBanZhuZhanDialog.getInstance():ChangeHeroCellWnd()
            HuoBanZhuZhanDialog.getInstance():ChangeHeroIconWnd()
        else
            GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(160018))
            return
        end
        -- 点击右
    elseif id == 2 then
        local len = self:Size(MyIDTable)
        if HuoBanZhuZhanDialog.getInstance().m_SelectIndex ~= len then
            HuoBanZhuZhanDialog.getInstance().m_SelectIndex = HuoBanZhuZhanDialog.getInstance().m_SelectIndex + 1
            self.heroId = self:getIDByIndex(MyIDTable, HuoBanZhuZhanDialog.getInstance().m_SelectIndex)
            HuoBanZhuZhanDialog.getInstance():SendMessage_CGetHuobanDetailInfo(self.heroId)
            HuoBanZhuZhanDialog.getInstance():ChangeHeroCellWnd()
            HuoBanZhuZhanDialog.getInstance():ChangeHeroIconWnd()
        else
            GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(160019))
            return
        end
    end

end
-- 根据集合索引获得申请伙伴详细信息的ID
function huobanzhuzhaninfo:getIDByIndex(arg, index)
    local step = 1
    if type(arg) == "table" then
        for _, v in pairs(arg) do
            if index == step then
                return v
            end
            step = step + 1
        end
    end
end
-- 获得table长度
function huobanzhuzhaninfo:Size(Table)
    local step = 0
    if type(Table) == "table" then
        for _, v in pairs(Table) do
            step = step + 1
        end
    end
    return step
end


return huobanzhuzhaninfo

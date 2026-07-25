require "logic.dialog"

JinmaiSkillDlg = { }

setmetatable(JinmaiSkillDlg, Dialog)
JinmaiSkillDlg.__index = JinmaiSkillDlg

local _instance

function JinmaiSkillDlg.getInstance()
    if not _instance then
        _instance = JinmaiSkillDlg:new()
        _instance:OnCreate()
    end
    return _instance
end


function JinmaiSkillDlg.getInstanceAndShow()
    if not _instance then
        _instance = JinmaiSkillDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JinmaiSkillDlg.new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, JinmaiSkillDlg)
    return self
end

function JinmaiSkillDlg.getInstanceOrNot()
    return _instance
end


function JinmaiSkillDlg.DestroyDialog()
    if _instance then
        if SkillLable.getInstanceNotCreate() then
            SkillLable.getInstanceNotCreate().DestroyDialog()
        else
            _instance:CloseDialog()
        end
    end
end

function JinmaiSkillDlg:CloseDialog()
    if _instance ~= nil then

        if _instance.m_startJuejiEffect == true then
            _instance.m_startJuejiEffect = false
            if _instance.m_juejiBox then
                RoleSkillManager.getInstance():UpdateAcupointLevel(_instance.m_juejiID, _instance.m_juejiNewLevel)
            end
        end

        _instance:OnClose()
        _instance = nil
    end
end

function JinmaiSkillDlg:OnClose()
    Dialog.OnClose(self)
    _instance = nil
end

function JinmaiSkillDlg.GetLayoutFileName()
    return "jinmaidlg.layout"
end

local MAX_SKILLNUM = 29

function JinmaiSkillDlg:OnCreate()
    Dialog.OnCreate(self)
    SetPositionOfWindowWithLabel(self:GetWindow())

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_skillBox = { }
    self.m_skillName_st = { }
    self.m_skillLevel_st = { }
    self.m_effectWnds = { }
    self.m_skillUpdateType = 0
    self.m_step = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(329).value)
    self.m_juejiID = 0
    self.m_juejiLevel = 0
    self.m_skillBoxes = { }
    self.m_juejiBox = nil
    self.m_startJuejiEffect = false
    self.m_oneKeyMap = { }
    self.m_skillCell = {}
    for i = 1, MAX_SKILLNUM do
        local localSkillBox = CEGUI.toSkillBox(winMgr:getWindow("SkillStudyDlg/left/skill" .. i))
        table.insert(self.m_skillBox, localSkillBox)
        local localSkillName_st = winMgr:getWindow("SkillStudyDlg/left/name" .. i)
        table.insert(self.m_skillName_st, localSkillName_st)
        local localSkillLevel_st = winMgr:getWindow("SkillStudyDlg/left/level" .. i)
        table.insert(self.m_skillLevel_st, localSkillLevel_st)
        local localSkillCell = CEGUI.Window.toGroupButton(winMgr:getWindow("SkillStudyDlg/left/" .. i))
        table.insert(self.m_skillCell, localSkillCell)
        localSkillBox:setAlwaysOnTop(true)
        localSkillName_st:setText("")
        localSkillLevel_st:setAlwaysOnTop(true)
        localSkillLevel_st:setMousePassThroughEnabled(true)
        localSkillLevel_st:setText("0")
        localSkillLevel_st:setVisible(false)
        localSkillLevel_st:setProperty("TextColours", "tl:FF50321A tr:FF50321A bl:FF50321A br:FF50321A")
        --localSkillLevel_st:setProperty("BorderEnable", "True")
        --localSkillLevel_st:setProperty("BorderColour", "FFFF2DFF")
    end
    self.m_skillCell[1]:setSelected(true)
    local skilljuejiLevel = winMgr:getWindow("SkillStudyDlg/left/level29")
    skilljuejiLevel:setProperty("TextColours", "tl:ffd729ea tr:ffd729ea bl:ffd729ea br:ffd729ea")

    self.m_titleName = winMgr:getWindow("SkillStudyDlg/titlename")
    self.m_shuomingPane = CEGUI.toScrollablePane(winMgr:getWindow("SkillStudyDlg/paneshuoming"))
    self.m_rightDown = winMgr:getWindow("SkillStudyDlg/rightdown")
    self.m_jiesuoJieneng = winMgr:getWindow("SkillStudyDlg/jiesuojieneng")
    self.m_juejiJiesuo = winMgr:getWindow("SkillStudyDlg/juejijiesuo")

    self.m_curSkillName_st = winMgr:getWindow("SkillStudyDlg/titlename/skillname")
    self.m_curSkillLevel_st = winMgr:getWindow("SkillStudyDlg/titlename/level")
    self.m_levelup_btn = CEGUI.toPushButton(winMgr:getWindow("SkillStudyDlg/yes"))
    self.m_onekeyLevelup_btn = CEGUI.toPushButton(winMgr:getWindow("SkillStudyDlg/yesall"))
    self.m_levelUpNeedMoney_st = winMgr:getWindow("SkillStudyDlg/rightdown/num4")
    self.m_haveMoney_st = winMgr:getWindow("SkillStudyDlg/rightdown/num5")
    self.m_haveDeportMoney_st = winMgr:getWindow("SkillStudyDlg/rightdown/num6")
    self.m_levelUpNeedExp_st = winMgr:getWindow("SkillStudyDlg/rightdown/num2")
    self.m_haveExp_st = winMgr:getWindow("SkillStudyDlg/rightdown/num3")
    self.m_levelUpDes_box = CEGUI.toRichEditbox(winMgr:getWindow("SkillStudyDlg/paneshuoming/box"))
    self.m_levelUpDes_box:setReadOnly(true)
    self.m_levelUpDes_box:SetForceHideVerscroll(true)

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("SkillStudyDlg/right/cailiaolist/item1"))
    self.m_makeBtn = CEGUI.toPushButton(winMgr:getWindow("SkillStudyDlg/left/btnshiyong"))
    self.m_makeBtn:setEnabled(false)
    self.m_makeBtn:setMousePassThroughEnabled(true)
    self.m_makeBtn:subscribeEvent("Clicked", JinmaiSkillDlg.HandleMakeBtnClicked, self)
    self.m_bigSkill = CEGUI.toSkillBox(winMgr:getWindow("SkillStudyDlg/left/skill8"))
    local bigSkillPos = self.m_bigSkill:getPosition()
    self.m_bigCenterX = bigSkillPos.x.offset + self.m_bigSkill:getWidth().offset * 0.5
    self.m_bigCenterY = bigSkillPos.y.offset + self.m_bigSkill:getHeight().offset * 0.5
    self.m_levelup_btn:subscribeEvent("Clicked", JinmaiSkillDlg.HandleLevelupBtnClicked, self)
	self.m_onekeyLevelup_btn:subscribeEvent("MouseClick", JinmaiSkillDlg.HandleSkillOneKeyBtnClicked, self)

    gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(JinmaiSkillDlg.refreshSelfGoldChange)

    self:getAllSkillInfo(true)
    self:GetWindow():subscribeEvent("WindowUpdate", JinmaiSkillDlg.HandleWindowUpdate, self)

    self.m_ticks = -1000
    self.m_juejiNewLevel = 0

end


function JinmaiSkillDlg:SetPointMap()
    local skillMap = RoleSkillManager.getInstance():GetRoleAcupointVec()
    self.m_chaSkillMap = { }
    local pointSize = #skillMap
    local pointID = nil
    local pointLevel = nil
    for i = 0, pointSize - 1 do
        if i % 2 == 0 then
            pointID = skillMap[i+1]
        else
            pointLevel = skillMap[i+1]
            local localTbl = { }
            localTbl.pointID = pointID
            localTbl.pointLevel = pointLevel
            table.insert(self.m_chaSkillMap, localTbl)
        end
    end
    table.sort(self.m_chaSkillMap, function(a,b) return a.pointID<b.pointID end)
end

function JinmaiSkillDlg:getAllSkillInfo(bUpdateCurrent)
    self:SetPointMap()
    local meetJueji = false
    for i = 1, MAX_SKILLNUM do
        local acuTbl = self.m_chaSkillMap[i]
        if acuTbl and not meetJueji then
            local pointID = acuTbl.pointID
            --local skillInfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(pointID)
            local skillInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(pointID)
            -- 判断是不是绝技
            local jueji = skillInfo.isJueji
            if skillInfo.isJueji == true then
                i = 7
                meetJueji = false
                self.m_juejiID = pointID
                self.m_juejiLevel = acuTbl.pointLevel
            end

            self.m_skillBox[i]:setVisible(true)
            self.m_skillBox[i]:setID(pointID)
            self.m_skillCell[i]:setID(pointID)
            self.m_skillCell[i]:subscribeEvent("SelectStateChanged", JinmaiSkillDlg.HandleSkillBtnClicked, self)
            local skillSize = skillInfo.pointToSkillList:size()
            local skillID = 0
            if skillSize > 0 then

                skillID = skillInfo.pointToSkillList[0]
                local skillConfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillID)
                self.m_skillName_st[i]:setText(skillConfig.skillname)
            end
            self.m_skillName_st[i]:setProperty("TextColours", "tl:FF50321A tr:FF50321A bl:FF50321A br:FF50321A")
            self.m_skillLevel_st[i]:setProperty("TextColours", "tl:FF50321A tr:FF50321A bl:FF50321A br:FF50321A")
local actualLevel = RoleSkillManager.getInstance():GetAcupointLevelByID(acuTbl.pointID)
            if actualLevel <= 0 then
			-- LogInfo("**" ..acuTbl.pointID)
            -- if self:checkSkillLearned(acuTbl.pointID) == false then
                self.m_skillBox[i]:Clear()
                SkillBoxControl.SetSkillInfo(self.m_skillBox[i], skillID,0)
                self.m_skillBox[i]:SetCornerImage("skillui", "meng")
                self.m_skillLevel_st[i]:setProperty("Font", "simhei-12")
                if meetJueji then
                    self.m_skillLevel_st[i]:setVisible(true)
                    local strTable = StringBuilder.Split(skillInfo.juejiDependLevel, ",")
                    self.m_skillLevel_st[i]:setText(strTable[1]..MHSD_UTILS.get_resstring(3)..MHSD_UTILS.get_resstring(2903))
                else
                    self.m_skillLevel_st[i]:setVisible(true)
                    self.m_skillLevel_st[i]:setText(skillInfo.dependLevel..MHSD_UTILS.get_resstring(3)..MHSD_UTILS.get_resstring(2903))
                end

            else
                self.m_skillBox[i]:Clear()
                SkillBoxControl.SetSkillInfo(self.m_skillBox[i], skillID,0)
                self.m_skillLevel_st[i]:setVisible(true)
                self.m_skillLevel_st[i]:setText(skillInfo.dependLevel..MHSD_UTILS.get_resstring(3)..MHSD_UTILS.get_resstring(2903))
                self.m_skillLevel_st[i]:setProperty("Font", "simhei-12")
                if skillInfo.id ~= -1 then
                    self.m_skillLevel_st[i]:setVisible(true)
                    --self.m_skillLevel_st[i]:setProperty("TextColours", "tl:FFFFF2DF tr:FFFFF2DF bl:FFFFF2DF br:FFFFF2DF")
                    self.m_skillLevel_st[i]:setText(tostring("LV."..acuTbl.pointLevel))
                    self.m_skillLevel_st[i]:setProperty("Font", "simhei-14")
                    self.m_skillName_st[i]:setProperty("TextColours", "tl:FF50321A tr:FF50321A bl:FF50321A br:FF50321A")
                    if meetJueji then
                        self.m_skillLevel_st[i]:setProperty("TextColours", "tl:FF50321A tr:FF50321A bl:FF50321A br:FF50321A")
                    else
                        self.m_skillLevel_st[i]:setProperty("TextColours", "tl:FF50321A tr:FF50321A bl:FF50321A br:FF50321A")
                    end
                    
                end
            end
        else
            if meetJueji == true then
                i = i - 1
            end
            --self.m_skillBox[i]:SetImage(CEGUI.String("common_pack"), CEGUI.String("suo"))
            self.m_skillName_st[i]:setText(MHSD_UTILS.get_resstring(11179))
        end
    end

    local nMakeBtnPos  = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(239).value)
    self.m_makeBtn:setEnabled(self.m_skillLevel_st[nMakeBtnPos]:isVisible() and self.m_chaSkillMap[nMakeBtnPos].pointLevel > 0)
    self.m_makeBtn:setMousePassThroughEnabled(not (self.m_skillLevel_st[nMakeBtnPos]:isVisible() and self.m_chaSkillMap[nMakeBtnPos].pointLevel > 0))
    JinmaiSkillDlg.fumoPointLevel = self.m_chaSkillMap[nMakeBtnPos].pointLevel
    JinmaiSkillDlg.fumoPointID = self.m_chaSkillMap[nMakeBtnPos].pointID

    if bUpdateCurrent then
        if not self.m_selectAcuPoint then
            self.m_selectAcuPoint = self.m_chaSkillMap[1].pointID
        end
        self:UpdateCurrentSkill(self.m_selectAcuPoint)
    end
end

function JinmaiSkillDlg:UpdateCurrentSkill(acuPointID)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self:SetPointMap()
    if self.m_lastSkillBox then
        self.m_lastSkillBox:SetSelected(false)
    end
    --local skillPointInfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(acuPointID)
    local skillPointInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(acuPointID)
    local acuPointLevel = RoleSkillManager.getInstance():GetAcupointLevelByID(acuPointID)
    local index = self:GetSkillIndexByID(acuPointID)
    self.m_lastSkillBox = self.m_skillBox[index]
    --self.m_lastSkillBox:SetSelected(true)
    if skillPointInfo.isJueji == false then
        self.m_titleName:setVisible(true)
        self.m_shuomingPane:setVisible(true)
        self.m_juejiJiesuo:setVisible(false)
        
        --self.m_skillLevel_st[index]:setProperty("TextColours", "tl:FFFFF2DF tr:FFFFF2DF bl:FFFFF2DF br:FFFFF2DF")
        self.m_skillLevel_st[index]:setText(skillPointInfo.dependLevel..MHSD_UTILS.get_resstring(3)..MHSD_UTILS.get_resstring(2903))
        self.m_skillLevel_st[index]:setVisible(true)
        self.m_skillLevel_st[index]:setProperty("Font", "simhei-12")
        if self:checkSkillLearned(acuPointID) == true then
            self.m_skillLevel_st[index]:setVisible(true)
            self.m_skillLevel_st[index]:setText("LV."..tostring(acuPointLevel))
            self.m_skillLevel_st[index]:setProperty("Font", "simhei-14")
        end

        local skillID = skillPointInfo.pointToSkillList[0]
        local skillConfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillID)
        self.m_curSkillName_st:setText(skillConfig.skillname)
        for _, v in ipairs(self.m_chaSkillMap) do
            if acuPointID == v.pointID then
                self.m_curSkillLevel_st:setText("Lv." .. v.pointLevel)
                break
            end
        end

	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local levelupMoney = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(650).value)
        local levelupMoney1 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(651).value)
        local levelupMoney2 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(652).value)
        local levelupMoney3 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(653).value)
        local levelupMoney4 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(654).value)
        local levelupMoney5 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(655).value)
        local levelupMoney6 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(656).value)
        local levelupMoney7 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(657).value)
        local levelupMoney8 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(658).value)
        local leveexp = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(659).value)
        local leveexp1 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(660).value)
        local leveexp2 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(661).value)
        local leveexp3 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(662).value)
        local leveexp4 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(663).value)
        local leveexp5 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(664).value)
        local leveexp6 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(665).value)
        local leveexp7 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(666).value)
        local leveexp8 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(667).value)
        local haveMoney = roleItemManager:GetGold()
        local data = gGetDataManager():GetMainCharacterData()
        local havedeportmoney = roleItemManager:GetReserveMoney()

        if haveMoney + havedeportmoney >= levelupMoney then
            self.m_levelUpNeedMoney_st:setProperty("TextColours", "ff00ff00")
        else
            self.m_levelUpNeedMoney_st:setProperty("TextColours", "ffff0000")
        end

	local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(606).value))
	self.ItemCellNeedItem1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithId(self.ItemCellNeedItem1,needItemCfg1.id)
	
	
            if acuPointID == 1119 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1120 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1121 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1122 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1123 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1124 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1125 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 1126 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1127 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1128 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1129 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1130 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1131 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1132 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 1133 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1134 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1135 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1136 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1137 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1138 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1139 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 1219 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1220 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1221 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1222 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1223 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1224 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1225 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 1226 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1227 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1228 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1229 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1230 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1231 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1232 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 1233 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1234 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1235 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1236 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1237 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1238 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1239 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 1319 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1320 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1321 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1322 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1323 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1324 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1325 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 1326 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1327 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1328 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1329 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1330 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1331 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1332 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 1333 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1334 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1335 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1336 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1337 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1338 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1339 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 1419 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1420 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1421 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1422 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1423 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1424 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1425 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 1426 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1427 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1428 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1429 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1430 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1431 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1432 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 1433 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1434 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1435 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1436 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1437 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1438 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1439 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 1519 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1520 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1521 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1522 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1523 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1524 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1525 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 1526 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1527 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1528 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1529 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1530 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1531 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1532 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 1533 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1534 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1535 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1536 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1537 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1538 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1539 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 1619 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1620 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1621 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1622 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1623 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1624 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1625 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 1626 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1627 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1628 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1629 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1630 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1631 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1632 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 1633 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1634 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1635 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1636 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1637 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1638 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1639 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 1719 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1720 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1721 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1722 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1723 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1724 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1725 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 1726 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1727 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1728 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1729 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1730 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1731 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1732 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 1733 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1734 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1735 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1736 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1737 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1738 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1739 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 1819 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1820 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1821 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1822 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1823 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1824 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1825 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 1826 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1827 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1828 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1829 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1830 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1831 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1832 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 1833 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1834 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1835 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1836 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1837 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1838 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1839 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 1919 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1920 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1921 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1922 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1923 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1924 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1925 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 1926 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1927 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1928 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1929 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1930 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1931 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1932 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 1933 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 1934 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 1935 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 1936 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 1937 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 1938 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 1939 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 2119 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 2120 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 2121 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 2122 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 2123 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 2124 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 2125 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 2126 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 2127 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 2128 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 2129 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 2130 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 2131 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 2132 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 2133 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 2134 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 2135 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 2136 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 2137 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 2138 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 2139 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 2219 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 2220 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 2221 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 2222 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 2223 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 2224 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 2225 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 2226 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 2227 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 2228 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 2229 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 2230 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 2231 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 2232 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 2233 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 2234 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 2235 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 2236 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 2237 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 2238 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 2239 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
            if acuPointID == 2519 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 2520 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 2521 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 2522 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 2523 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 2524 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 2525 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney7))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp7))
            end
		 if acuPointID == 2526 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 2527 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 2528 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 2529 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 2530 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 2531 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 2532 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney6))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp6))
            end
		 if acuPointID == 2533 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp))
            end
		 if acuPointID == 2534 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney1))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp1))
            end
		 if acuPointID == 2535 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney2))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp2))
            end
		 if acuPointID == 2536 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney3))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp3))
            end
		 if acuPointID == 2537 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney4))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp4))
            end
		 if acuPointID == 2538 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney5))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp5))
            end
		 if acuPointID == 2539 then
        self.m_levelUpNeedMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(levelupMoney8))
            self.m_haveExp_st:setProperty("TextColours", "ff00ff00")
		self.m_haveExp_st:setText(MHSD_UTILS.GetMoneyFormatString(leveexp8))
            end
        self.m_levelUpNeedExp_st:setText(MHSD_UTILS.GetMoneyFormatString(data.exp))
        self.m_haveMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(haveMoney))
        self.m_haveDeportMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(havedeportMoney))

        self:updateTips(skillID)

        local nMakeBtnPos  = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(239).value)
        self.m_makeBtn:setEnabled(self.m_skillLevel_st[nMakeBtnPos]:isVisible() and self.m_chaSkillMap[nMakeBtnPos].pointLevel > 0)
        self.m_makeBtn:setMousePassThroughEnabled(not (self.m_skillLevel_st[nMakeBtnPos]:isVisible() and self.m_chaSkillMap[nMakeBtnPos].pointLevel > 0))

        if self:checkSkillLearned(acuPointID) == false then
            self.m_levelup_btn:setVisible(false)
            self.m_onekeyLevelup_btn:setVisible(false)
            self.m_rightDown:setVisible(false)
            self.m_jiesuoJieneng:setVisible(true)

            local dependAcupoints = StringBuilder.Split(skillPointInfo.dependAcupoint, ",")
            local dependAcupointID = tonumber(dependAcupoints[1])
            --local acuInfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(dependAcupointID)
            local acuInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(dependAcupointID)
            local skillID = acuInfo.pointToSkillList[0]
            local skillConfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillID)
            local dependLevel = skillPointInfo.dependLevel
            local strbuilder = StringBuilder.new()
            strbuilder:Set("parameter1", string.format("角色等级"))
            strbuilder:Set("parameter2", tostring(dependLevel))

            local unlockCond = winMgr:getWindow("SkillStudyDlg/jiesuojieneng/text12bg/xianzhi")
            unlockCond:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(11181)))
            strbuilder:delete()
            local skillBox = CEGUI.toSkillBox(winMgr:getWindow("SkillStudyDlg/jiesuojieneng/skibox"))
            skillBox:Clear()
            SkillBoxControl.SetSkillInfo(skillBox, skillID,0)

        else
            self.m_levelup_btn:setVisible(true)
            self.m_onekeyLevelup_btn:setVisible(false)
            self.m_rightDown:setVisible(true)
            self.m_jiesuoJieneng:setVisible(false)
        end
    else
        self.m_titleName:setVisible(false)
        self.m_shuomingPane:setVisible(false)
        self.m_levelup_btn:setVisible(false)
        self.m_onekeyLevelup_btn:setVisible(false)
        self.m_rightDown:setVisible(false)
        self.m_jiesuoJieneng:setVisible(false)
        self.m_juejiJiesuo:setVisible(true)
       -- local acuInfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(acuPointID)
        local acuInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(acuPointID)
        local skillID = acuInfo.pointToSkillList[0]
        local skillBox = CEGUI.toSkillBox(winMgr:getWindow("SkillStudyDlg/juejijiesuo/skillbox"))
        skillBox:Clear()
        SkillBoxControl.SetSkillInfo(skillBox, skillID,0)

        local skillConfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillID)
        local skillName_st = winMgr:getWindow("SkillStudyDlg/juejijiesuo/name")
        skillName_st:setText(skillConfig.skillname)

        local progressBar = CEGUI.toProgressBar(winMgr:getWindow("SkillStudyDlg/juejijiesuo/jindu"))
        progressBar:setProperty("VerticalProgress", "False")
        if acuPointLevel == 0 then
            progressBar:setProgress(0)
            progressBar:setText(MHSD_UTILS.get_resstring(11179))
        else
            progressBar:setProgress(acuPointLevel / 3)
            local strbuilder = StringBuilder.new()
            strbuilder:Set("parameter1", tostring(acuPointLevel))
            progressBar:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(10030)))
            strbuilder:delete()
        end
        self:updateTipsOfJueji(skillID)
        if acuPointLevel < tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(225).value) then
            local bf = winMgr:getWindow("SkillStudyDlg/juejijiesuo/bf")
            bf:setVisible(true)
            local part1 = MHSD_UTILS.get_resstring(2903)
            local strbuilder = StringBuilder.new()
            strbuilder:Set("parameter1", tostring(acuPointLevel + 1))
            local part2 = strbuilder:GetString(MHSD_UTILS.get_resstring(10030))
            strbuilder:delete()
            local part3 = "(" .. MHSD_UTILS.get_resstring(3175) .. ")"

            local dependLevels = StringBuilder.Split(skillPointInfo.juejiDependLevel, ",")
            local strbuilder2 = StringBuilder.new()
            strbuilder2:Set("parameter1", tostring(dependLevels[acuPointLevel + 1]))
            local part4 = strbuilder2:GetString(MHSD_UTILS.get_resstring(11180))
            strbuilder2:delete()
            local upgradeDesc = self:GetJuejiSkillTextNext(skillID)
            local part = part1 .. part2 .. part3 .. "\n" .. part4 .. "\n" .. upgradeDesc
            local desc_st = winMgr:getWindow("SkillStudyDlg/juejijiesuo/bf/bianliang")
            desc_st:setProperty("TextColours", "tl:ff8e582c tr:ff8e582c bl:ff8e582c br:ff8e582c")
            desc_st:setText(part)
        end
    end
end

function JinmaiSkillDlg:updateSkillLevel(acupoints)
    local winMgr = CEGUI.WindowManager:getSingleton()
    if self.m_skillUpdateType == 0 then
        for acuPointID, acuPointLevel in pairs(acupoints) do
            if self.m_selectAcuPoint == acuPointID then
                local skillBox = self:GetSkillBoxByID(acuPointID)
                table.insert(self.m_skillBoxes, skillBox)
                local effect = gGetGameUIManager():AddUIEffect(skillBox, MHSD_UTILS.get_effectpath(11017), false, 0, 0)
            end
            if self.m_juejiID == acuPointID then
                if acuPointLevel ~= self.m_juejiLevel then
                    self.m_juejiBox = self:GetSkillBoxByID(acuPointID)
                    --self.m_startJuejiEffect = true
                    self.m_juejiNewLevel = acuPointLevel
                    local effect = gGetGameUIManager():AddUIEffect(self.m_juejiBox, MHSD_UTILS.get_effectpath(11017), false, 0, 0)
                end
            end
        end
        self:getAllSkillInfo(true)
    else
        self.m_oneKeyMap = { }

        for acuPointID, acuPointLevel in pairs(acupoints) do
            self.m_oneKeyMap[acuPointID] = acuPointLevel
            if self.m_juejiID ~= acuPointID then
                local skillBox = self:GetSkillBoxByID(acuPointID)
                table.insert(self.m_skillBoxes, skillBox)
                local effect = gGetGameUIManager():AddUIEffect(skillBox, MHSD_UTILS.get_effectpath(11017), false, 0, 0)
            else
                self.m_juejiBox = self:GetSkillBoxByID(acuPointID)
                --self.m_startJuejiEffect = true
                self.m_juejiNewLevel = acuPointLevel
                table.insert(self.m_skillBoxes, skillBox)
                local effect = gGetGameUIManager():AddUIEffect(self.m_juejiBox, MHSD_UTILS.get_effectpath(11017), false, 0, 0)
            end
        end
        self:getAllSkillInfo(true)
    end
end

function JinmaiSkillDlg.effectFinishCallback()
--    local winMgr = CEGUI.WindowManager:getSingleton()
--    local self = JinmaiSkillDlg:getInstanceOrNot()
--    if not self then
--        return
--    end
--    for _, skillBox in ipairs(self.m_skillBoxes) do
--        local winPos = skillBox:getPosition()
--        local winWidth = skillBox:getWidth().offset
--        local winHeight = skillBox:getHeight().offset
--        local effectWnd = winMgr:createWindow("DefaultWindow")
--        effectWnd:setMousePassThroughEnabled(false)
--        skillBox:addChildWindow(effectWnd)
--        effectWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 1)))
--        effectWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, winWidth * 0.5), CEGUI.UDim(0.0, winHeight * 0.5)))

--        gGetGameUIManager():AddUIEffect(effectWnd, MHSD_UTILS.get_effectpath(11018), true, 0, 0)
--        table.insert(self.m_effectWnds, effectWnd)
--        effectWnd:activate()
--    end
end

function JinmaiSkillDlg:HandleSkillBtnClicked(eventArgs)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local args = CEGUI.toWindowEventArgs(eventArgs)

    local localSkillBox = args.window
    --localSkillBox:SetSelected(true)
    self.m_selectAcuPoint = localSkillBox:getID()
    self:UpdateCurrentSkill(self.m_selectAcuPoint)
end

function JinmaiSkillDlg:HandleMakeBtnClicked(eventArgs)
    local p = require "protodef.fire.pb.skill.liveskill.cliveskillmakeenhancement".Create()
    LuaProtocolManager.getInstance():send(p)
end

function JinmaiSkillDlg:HandleLevelupBtnClicked(eventArgs)
    local result1 = RoleSkillManager.getInstance():RequestAcupointLevelUp(self.m_selectAcuPoint,true)
    if result1 == 0 then
        self.m_skillUpdateType = 0
        local p = require "protodef.fire.pb.skill.cupdateinborn".Create()
        p.id = self.m_selectAcuPoint
        p.flag = 0
        LuaProtocolManager.getInstance():send(p)
    elseif result1 > 0 then
        CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_GoldCoin, result1)

    end
end

function JinmaiSkillDlg:HandleSkillOneKeyBtnClicked(eventArgs)
    self.m_skillUpdateType = 1
    local p = require "protodef.fire.pb.skill.cupdateinborn".Create()
    p.id = self.m_selectAcuPoint
    p.flag = 1

    if JinmaiSkillDlg.checkCouldOnekeyUp() then
        LuaProtocolManager.getInstance():send(p)
    else
        local needMoney = JinmaiSkillDlg.getSkillUpToFullLevelMoney()

        if needMoney == 0 then
            LuaProtocolManager.getInstance():send(p)
            return
        end

	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local dif = roleItemManager:GetGold() - needMoney

        if dif < 0 then
            CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_GoldCoin, -dif, needMoney, p)
        end
    end
end

function JinmaiSkillDlg.refreshSelfGoldChange()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local haveMoney = roleItemManager:GetGold()
    local dlg = JinmaiSkillDlg:getInstanceOrNot()
    if dlg then
        dlg.m_haveMoney_st:setText(MHSD_UTILS.GetMoneyFormatString(haveMoney))
        local levelupMoney = dlg.m_levelUpNeedMoney_st:getText()
        local moneyTbl = StringBuilder.Split(levelupMoney, ",")
        local makeupMoney = table.concat(moneyTbl)
        if haveMoney >= tonumber(makeupMoney) then
            dlg.m_levelUpNeedMoney_st:setProperty("TextColours", "ff00ff00")
        else
            dlg.m_levelUpNeedMoney_st:setProperty("TextColours", "ffff0000")
        end

        dlg.m_levelUpNeedMoney_st:setText(levelupMoney)
    end
end

function JinmaiSkillDlg:updateTipsOfJueji(skillID)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local showLevel = RoleSkillManager.getInstance():GetRoleSkillLevel(skillID)

    local richBox = CEGUI.Window.toRichEditbox(winMgr:getWindow("SkillStudyDlg/juejijiesuo/riche"))
    richBox:setReadOnly(true)
    richBox:SetForceHideVerscroll(true)
    richBox:Clear()
    local skillConfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillID)
    if (not skillConfig) or(skillConfig.id == -1) then
        return
    end
    local Color1 = "ff472b20"

    richBox:SetLineSpace(3.0)
    local schoolSkillInfo = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(skillID)
    local nIndex = string.find(schoolSkillInfo.skillScript, "<T")
    if nIndex then
        richBox:AppendParseText(CEGUI.String(schoolSkillInfo.skillScript))
    else
        richBox:AppendText(CEGUI.String(schoolSkillInfo.skillScript), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color1)))
    end
    
    richBox:AppendBreak()
    richBox:AppendText(CEGUI.String(" "))
    richBox:AppendBreak()

    local Color2 = "ff8e582c"

    richBox:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11698)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color2)))
    richBox:AppendText(CEGUI.String(" "))
    richBox:AppendText(CEGUI.String(self:GetJuejiSkillText(skillID)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color2)))
    richBox:AppendBreak()
    richBox:AppendText(CEGUI.String(" "))
    richBox:AppendBreak()

    local costA = showLevel * schoolSkillInfo.paramA + schoolSkillInfo.paramB
    local strbuilder = StringBuilder.new()
    strbuilder:Set("parameter1", tostring(costA))
    local consume = schoolSkillInfo.costA

    if schoolSkillInfo.costB and schoolSkillInfo.costB ~= "" then
        local costB = showLevel * schoolSkillInfo.paramC + schoolSkillInfo.paramD
        strbuilder:Set("parameter2", costB)
        consume = schoolSkillInfo.costA .. "，" .. schoolSkillInfo.costB
    end

    richBox:AppendText(CEGUI.String(strbuilder:GetString(consume)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color1)))
    strbuilder:delete()
    richBox:AppendBreak()
    richBox:AppendText(CEGUI.String(" "))
    richBox:AppendBreak()

    richBox:Refresh()
    richBox:HandleTop()
end

function JinmaiSkillDlg:GetJuejiSkillText(id)
    local showLevel = RoleSkillManager.getInstance():GetRoleSkillLevel(id)
    local schoolSkillInfo = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(id)
    local strJuejiText = ""
    if showLevel == 0 then
        strJuejiText = schoolSkillInfo.skilldescribe
    else
        if showLevel - 1 <= schoolSkillInfo.skilldescribelist:size() -1 then
            strJuejiText = schoolSkillInfo.skilldescribelist[showLevel-1]
        end
    end
    
    return strJuejiText
end
function JinmaiSkillDlg:GetJuejiSkillTextNext(id)
    local showLevel = RoleSkillManager.getInstance():GetRoleSkillLevel(id)
    local schoolSkillInfo = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(id)
    local strJuejiText = ""
    if showLevel == 0 then
        strJuejiText = schoolSkillInfo.leveldescribezero
    else
        if showLevel - 1 <= schoolSkillInfo.leveldescribe:size() -1 then
            strJuejiText = schoolSkillInfo.leveldescribe[showLevel - 1]
        end
    end
    
    return strJuejiText
end

function JinmaiSkillDlg:GetSkillUpgradeDesc(skillID)
    local skillConfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillID)
    if not skillConfig or skillConfig.id == -1 then
        return ""
    end
    local showLevel = RoleSkillManager.getInstance():GetRoleSkillLevel(skillID)

    local schoolSkillInfo = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(skillID)
    local desc = ""
    local levelRank = 0
    for i = 0, schoolSkillInfo.levellimit:size() -1 do
        if schoolSkillInfo.levellimit[i] <= showLevel then
            levelRank = i
        else
            break
        end
    end
    if levelRank <= schoolSkillInfo.leveldescribe:size() -1 then
        desc = schoolSkillInfo.leveldescribe[levelRank]
    else
        desc = schoolSkillInfo.leveldescribezero
    end
    return desc
end

function JinmaiSkillDlg:updateTips(skillID)
    self.m_levelUpDes_box:Clear()
    local skillConfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillID)
    if not skillConfig then
        return
    end
    local schoolSkillInfo = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(skillID)
    if skillConfig then
        self.m_curSkillName_st:setText(skillConfig.skillname)
        local mp_enough = true
        local hp_enough = true
        local sp_enough = true
        local showLevel = RoleSkillManager.getInstance():GetRoleSkillLevel(skillID)

        local Color1 = "ffffffff"
        self.m_levelUpDes_box:SetLineSpace(3.0)

        local desc = ""
        if schoolSkillInfo then
            local levelRank = 0
            for i = 0, schoolSkillInfo.levellimit:size() -1 do
                if schoolSkillInfo.levellimit[i] <= showLevel then
                    levelRank = i
                else
                    break
                end
            end
            if levelRank <= schoolSkillInfo.leveldescribe:size() -1 then
                desc = schoolSkillInfo.skilldescribelist[levelRank]
            else
                desc = schoolSkillInfo.skilldescribe
            end
        else
            desc = schoolSkillInfo.skilldescribe
        end
       
        self.m_levelUpDes_box:AppendText(CEGUI.String(schoolSkillInfo.sType), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color1)))
        self.m_levelUpDes_box:AppendBreak()
        self.m_levelUpDes_box:AppendText(CEGUI.String(" "))
        self.m_levelUpDes_box:AppendBreak()

        local Color2 = "ffffffff"
        self.m_levelUpDes_box:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11698)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color2)))
        self.m_levelUpDes_box:AppendText(CEGUI.String(" "))
        self.m_levelUpDes_box:AppendText(CEGUI.String(desc), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color2)))
        self.m_levelUpDes_box:AppendBreak()
        self.m_levelUpDes_box:AppendText(CEGUI.String(" "))
        self.m_levelUpDes_box:AppendBreak()

        local costA = showLevel * schoolSkillInfo.paramA + schoolSkillInfo.paramB
        local strbuilder = StringBuilder.new()
        
        strbuilder:Set("parameter1", tostring(math.floor(costA)))--+ 0.5
        local consume = schoolSkillInfo.costA

        if schoolSkillInfo.costB and schoolSkillInfo.costB ~= "" then
            local costB = showLevel * schoolSkillInfo.paramC + schoolSkillInfo.paramD
            strbuilder:Set("parameter2", math.floor(costB))-- + 0.5
            consume = math.floor(schoolSkillInfo.costA) .. "，" .. math.floor(schoolSkillInfo.costB)-- + 0.5 + 0.5
        end

        self.m_levelUpDes_box:AppendText(CEGUI.String(strbuilder:GetString(consume)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color1)))
        strbuilder:delete()
        self.m_levelUpDes_box:AppendBreak()
        self.m_levelUpDes_box:AppendText(CEGUI.String(" "))
        self.m_levelUpDes_box:AppendBreak()

        desc = ""
        if schoolSkillInfo then
            local levelRank = 0
            for i = 0, schoolSkillInfo.levellimit:size() -1 do
                if schoolSkillInfo.levellimit[i] <= showLevel then
                    levelRank = i
                else
                    break
                end
            end
            if levelRank <= schoolSkillInfo.leveldescribe:size() -1 then
                desc = schoolSkillInfo.leveldescribe[levelRank]
            else
                desc = schoolSkillInfo.leveldescribezero
            end
        else
            desc = schoolSkillInfo.leveldescribezero
        end

        local MHSD_UTILS = require "utils.mhsdutils"
        local prefix = MHSD_UTILS.get_resstring(11699) .. "："

        self.m_levelUpDes_box:AppendText(CEGUI.String(prefix), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color2)))
        self.m_levelUpDes_box:AppendText(CEGUI.String(desc), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(Color2)))

        self.m_levelUpDes_box:Refresh()
        self.m_levelUpDes_box:HandleTop()
    end

end

function JinmaiSkillDlg:HandleWindowUpdate(eventArgs)
--    for index, eachWnd in ipairs(self.m_effectWnds) do
--        if eachWnd:isVisible() == true then
--            local eachPos = eachWnd:getPosition()
--            local parentWndPos = eachWnd:getParent():getPosition()
--            local calculatePosX = self.m_bigCenterX - parentWndPos.x.offset
--            local calculatePosY = self.m_bigCenterY - parentWndPos.y.offset
--            local angle = math.atan2(math.abs(calculatePosY - eachPos.y.offset), math.abs(calculatePosX - eachPos.x.offset))
--            local directX = 1
--            if calculatePosX < eachPos.x.offset then
--                directX = -1
--            end
--            local directY = 1
--            if calculatePosY < eachPos.y.offset then
--                directY = -1
--            end
--            local newPosX = eachPos.x.offset + self.m_step * math.cos(angle) * directX
--            local newPosY = eachPos.y.offset + self.m_step * math.sin(angle) * directY
--            eachWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, newPosX), CEGUI.UDim(0.0, newPosY)))
--            if (math.abs(newPosX - calculatePosX) <= 5) and(math.abs(newPosY - calculatePosY) <= 5) then
--                gGetGameUIManager():RemoveUIEffect(eachWnd)
--                eachWnd:setVisible(false)
--                table.remove(self.m_effectWnds, index)
--                table.remove(self.m_skillBoxes, index)
--                eachWnd:getParent():removeChildWindow(eachWnd)
--                if table.maxn(self.m_effectWnds) == 0 then
--                    -- 如果要播放绝技特效
--                    if self.m_startJuejiEffect == true then
--                        self.m_startJuejiEffect = false
--                        if self.m_juejiBox then
--                            RoleSkillManager.getInstance():UpdateAcupointLevel(self.m_juejiID, self.m_juejiNewLevel)
--                            gGetGameUIManager():AddUIEffect(self.m_juejiBox, MHSD_UTILS.get_effectpath(11017), false, 0, 0)
--                            self:getAllSkillInfo(true)
--                        end
--                    end
--                end
--            end
--        end
--    end

--    if self.m_ticks >= 0 then
--        if self.m_ticks == 1 then
--            self.m_ticks = -1000
--            self:getAllSkillInfo(true)
--        end
--        self.m_ticks = self.m_ticks + 1
--    end
end

function JinmaiSkillDlg:GetSkillBoxByID(acupointID)
    for i = 1, MAX_SKILLNUM do
        local curID = self.m_skillBox[i]:getID()
        if curID == acupointID then
            return self.m_skillBox[i]
        end
    end
    return nil
end

function JinmaiSkillDlg:GetSkillIndexByID(acupointID)
    for i = 1, MAX_SKILLNUM do
        local curID = self.m_skillBox[i]:getID()
        if curID == acupointID then
            return i
        end
    end
    return -1
end

function JinmaiSkillDlg:checkSkillLearned(acupointID)
    --local acuPointInfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(acupointID)
    local acuPointInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(acupointID)
	if acuPointInfo.id >= 1119 and acuPointInfo.id <= 1139 
	or acuPointInfo.id >= 1219 and acuPointInfo.id <= 1239 
	or acuPointInfo.id >= 1319 and acuPointInfo.id <= 1339 
	or acuPointInfo.id >= 1419 and acuPointInfo.id <= 1439 
	or acuPointInfo.id >= 1519 and acuPointInfo.id <= 1539 
	or acuPointInfo.id >= 1619 and acuPointInfo.id <= 1639 
	or acuPointInfo.id >= 1719 and acuPointInfo.id <= 1739 
	or acuPointInfo.id >= 1819 and acuPointInfo.id <= 1839 
	or acuPointInfo.id >= 1919 and acuPointInfo.id <= 1939 
	or acuPointInfo.id >= 2119 and acuPointInfo.id <= 2139 
	or acuPointInfo.id >= 2219 and acuPointInfo.id <= 2239 
	or acuPointInfo.id >= 2519 and acuPointInfo.id <= 2539  then
	if gGetDataManager():GetMainCharacterLevel() >= acuPointInfo.dependLevel then
        return true
end
            return false
end
    -- if acuPointInfo.isJueji == false then
        -- local dependAcupoints = StringBuilder.Split(acuPointInfo.dependAcupoint, ",")
        -- local dependAcupointID = tonumber(dependAcupoints[1])
        -- if dependAcupointID <= 0 then
            -- return true
        -- end
        -- local dependLevel = acuPointInfo.dependLevel
        -- local actualLevel = RoleSkillManager.getInstance():GetAcupointLevelByID(dependAcupointID)
        -- return(actualLevel >= dependLevel)
    -- else
        -- local actualLevel = RoleSkillManager.getInstance():GetAcupointLevelByID(acupointID)
        -- if actualLevel <= 0 then
            -- return false
        -- end
        -- return true
    -- end
end


function JinmaiSkillDlg.getSkillIDataTable()
    local acupointVec = RoleSkillManager.getInstance():GetRoleAcupointVec()
    local m_chaSkillMap = { }
    local pointSize = #acupointVec
    local pointID = nil
    local pointLevel = nil
    for i = 0, pointSize - 1 do
        if i % 2 == 0 then
            pointID = acupointVec[i+1]
        else
            pointLevel = acupointVec[i+1]
            local localTbl = { }
            localTbl.pointID = pointID
            localTbl.pointLevel = pointLevel
            table.insert(m_chaSkillMap, localTbl)
        end
    end
    return m_chaSkillMap
end

function JinmaiSkillDlg.checkCouldOnekeyUp()
    local acupointTable = JinmaiSkillDlg.getSkillIDataTable()

    local data = gGetDataManager():GetMainCharacterData()
    local roleLevel = data:GetValue(fire.pb.attr.AttrType.LEVEL)

    local MAX_SKILLNUM = 30

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    for i = 1, MAX_SKILLNUM do
        local tb = acupointTable[i]
        if tb then
            --local acupointInfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(tb.pointID)
            local acupointInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(tb.pointID)

            local couldUp = false
            if tb.pointLevel < roleLevel then
                local dependAcupoints = StringBuilder.Split(acupointInfo.dependAcupoint, ",")
                local dependAcupointID = tonumber(dependAcupoints[1])
                local actualLevel = RoleSkillManager.getInstance():GetAcupointLevelByID(dependAcupointID)
                if dependAcupointID > 0 and actualLevel >= acupointInfo.dependLevel or dependAcupointID == 0 then
                    local costRule = acupointInfo.studyCostRule
                    if costRule and costRule > 0 then
                        for k = tb.pointLevel, roleLevel-1 do

                            local AcupointLevelUpInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointlevelup"):getRecorder(k + 1)
                            local needMoney = AcupointLevelUpInfo.moneyCostRule[costRule]
                            if k ~=0 and needMoney <= roleItemManager:GetGold() then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end


function JinmaiSkillDlg.getSkillUpToFullLevelMoney()
    local acupointTable = JinmaiSkillDlg.getSkillIDataTable()

    local data = gGetDataManager():GetMainCharacterData()
    local roleLevel = data:GetValue(fire.pb.attr.AttrType.LEVEL)

    local MAX_SKILLNUM = 30
    local needMoney = 0

    for i = 1, MAX_SKILLNUM do
        local tb = acupointTable[i]
        if tb then
            --local acupointInfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(tb.pointID)
            local acupointInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(tb.pointID)

            local couldUp = false
            if tb.pointLevel < roleLevel then
                local dependAcupoints = StringBuilder.Split(acupointInfo.dependAcupoint, ",")
                local dependAcupointID = tonumber(dependAcupoints[1])
                if dependAcupointID > 0 and roleLevel >= acupointInfo.dependLevel or dependAcupointID == 0 then
                    local costRule = acupointInfo.studyCostRule
                    if costRule and costRule > 0 then
                        for k = tb.pointLevel, roleLevel-1 do
                            local AcupointLevelUpInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointlevelup"):getRecorder(k + 1)
                            needMoney = needMoney + AcupointLevelUpInfo.moneyCostRule[costRule]
                        end
                    end
                end
            end
        end
    end
    return needMoney
end

return JinmaiSkillDlg




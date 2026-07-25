require "logic.dialog"
require "logic.skill.zuoyaodlg"
require "logic.skill.lifeskilltipdlg"
require "manager.currencymanager"
GonghuiSkillDlg = {}

setmetatable(GonghuiSkillDlg,Dialog)
GonghuiSkillDlg.__index = GonghuiSkillDlg

local _instance

function GonghuiSkillDlg.getInstance() 
	if not _instance then
		_instance = GonghuiSkillDlg:new()
		_instance:OnCreate()
	end
	return _instance

end


function GonghuiSkillDlg.getInstanceAndShow()
	if not _instance then
		_instance = GonghuiSkillDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function GonghuiSkillDlg.getInstanceOrNot()
	return _instance
end


function GonghuiSkillDlg.DestroyDialog()
	if _instance then
		if SkillLable.getInstanceNotCreate() then
			SkillLable.getInstanceNotCreate().DestroyDialog()
		else
			_instance:CloseDialog()
		end
	end
end

function GonghuiSkillDlg:CloseDialog()
    if _instance ~= nil then
        _instance:OnClose()
        _instance = nil
    end
end

function GonghuiSkillDlg:OnClose()
	Dialog.OnClose(self)
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    local strengthusedlg = require "logic.skill.strengthusedlg".getInstanceNotCreate()
    if strengthusedlg then
        strengthusedlg:refreshHyd()
    end
	_instance = nil
end

function GonghuiSkillDlg.GetLayoutFileName()
	return "lifeskill.layout"
end

function GonghuiSkillDlg:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel(self:GetWindow())
	self.m_skills = {}
	self.m_curSkillIndex = 1
	self.nSelSkillId = 0
	self.m_iMaxPage = 1
	self.m_iCurPage = 1
	self.m_pageGap = 0
	self.m_timeElapsed = 0
	self.m_scrollPaneState = 0
	self.m_scrollSpeed = 0
	self.m_scrollEndPos = 0
	self.m_scrollTime = 0.5
	self.m_insertDazaoPanel = false
	self.m_itemIDList = {}
	self.m_drugSkillLevel = 0 
	self.m_needHuoli = 0 
	self.m_needHuoli_st = nil
	self.m_needYinbi = 0
	self.m_needYinbi_layout = nil
    self.id_index = 0
    local winMgr = CEGUI.WindowManager:getSingleton()
    local needYinbi_layout = winMgr:getWindow("lifeskill/study/needyinbi_num")
    self.m_defaultColor = needYinbi_layout:getProperty("TextColours")
	
	self.m_scrollSkillPanel = CEGUI.Window.toScrollablePane(winMgr:getWindow("lifeskill/left/list"))
	local studyBtn = CEGUI.toPushButton(winMgr:getWindow("lifeskill/study/studybtn"))
    local studyBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress") 
    if studyBtnPressAnimationDef then
        local studyBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(studyBtnPressAnimationDef)
        studyBtnPressAnimation:setTargetWindow(studyBtn)
        studyBtnPressAnimation:setSpeed(0.7)
        studyBtn:subscribeEvent("MouseButtonDown", 
            function()
                studyBtnPressAnimation:start()
            end, self)
    end

    studyBtn:subscribeEvent("MouseButtonUp", GonghuiSkillDlg.HandleStudyBtnClicked, self)

	if not GonghuiSkillDlg.m_skillList or GonghuiSkillDlg.m_skillOwnerID ~= gGetDataManager():GetMainCharacterID() then
		local p = require "protodef.fire.pb.skill.liveskill.crequestliveskilllist".Create()
		LuaProtocolManager.getInstance():send(p)
	else
		self:RefreshScrollSkillList(GonghuiSkillDlg.m_skillList)
	end


end



function GonghuiSkillDlg:SetSkill(skill)
	for _, v in ipairs(GonghuiSkillDlg.m_skillList) do
		if skill.id == v.id then
			v.level = skill.level
			local curRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(skill.id)
			-- 学习技能成功提示
			local msg = require "utils.mhsdutils".get_msgtipstring(150099)
			msg = string.gsub(msg, "%$parameter1%$", curRecord.name)
			msg = string.gsub(msg, "%$parameter2%$", tostring(skill.level))
			GetCTipsManager():AddMessageTip(msg)
            self:RefreshOneSkill(v)
			return
		end
	end
end



function GonghuiSkillDlg:SetSkillList(skillList)
	-- 从技能表中拿出未学习的技能
	local allId = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getAllID()
	for k,v in pairs(allId) do
		local curRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(v)
		-- 是否是公会技能
		if curRecord.skillType == 2 then
			local found = false
			for _, v in ipairs(skillList) do
				if curRecord.id == v.id then
					found = true
					v.paixuID = curRecord.paixuID
					break
				end
			end
			if found == false then
				table.insert(skillList, {id=curRecord.id,level=0,paixuID=curRecord.paixuID})
			end
		end
	end
	table.sort(skillList, function(v1, v2)
		if v1.paixuID < v2.paixuID then
			return true
		end
	end)
	GonghuiSkillDlg.m_skillList = skillList
    GonghuiSkillDlg.m_skillOwnerID = gGetDataManager():GetMainCharacterID()
	self:RefreshScrollSkillList(GonghuiSkillDlg.m_skillList)
	
end

function GonghuiSkillDlg:RefreshOneSkill(skill)
	local skillBean = skill
	local namePrefix = tostring(skillBean.id)
	local curRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(skillBean.id)
	local winMgr = CEGUI.WindowManager:getSingleton()	
	for i, v in ipairs(self.m_skills) do
        if v.skillBox:getID() == skillBean.id then
		    if skillBean.id == 310101 then
			    self.m_drugSkillLevel = skillBean.level
		    end
		    local skillLayout = {}
            local skillBoxName = namePrefix .. "lifeskillcell/skill"
		    skillLayout.skillBox = CEGUI.toSkillBox(winMgr:getWindow(skillBoxName))
		    skillLayout.skillBox:setID(skillBean.id)
		    skillLayout.skillLevel = skillBean.level
            skillLayout.skillbg = CEGUI.toGroupButton(winMgr:getWindow(namePrefix.."lifeskillcell"))
            skillLayout.skillbg:setID(skillBean.id)
		    local skillLevel_st = winMgr:getWindow(namePrefix.."lifeskillcell/skill/level")
		    skillLevel_st:setText(""..tostring(skillBean.level))
            self.m_skills[i] = skillLayout
            break
        end
    end	

    self:RefreshSkillBoxSel()
end

function GonghuiSkillDlg:RefreshScrollSkillList(skillList)
	self.m_scrollSkillPanel:cleanupNonAutoChildren()
	local winMgr = CEGUI.WindowManager:getSingleton()

	for i, v in ipairs(skillList) do
		local skillBean = v
		local namePrefix = tostring(skillBean.id)
		local curRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(skillBean.id)
		
		local cellWnd = winMgr:loadWindowLayout("lifeskillcell.layout", namePrefix)
		
		if cellWnd then
			LogInfo("__ get rootwnd: ".. namePrefix .. "lifeskillcell.layout")
			self.m_scrollSkillPanel:addChildWindow(cellWnd)
			local cellSkill = winMgr:getWindow(namePrefix.."lifeskillcell/skill")

            local cellBg = CEGUI.toGroupButton(winMgr:getWindow(namePrefix.."lifeskillcell"))
		    
			local cellHeight = cellBg:getPixelSize().height
			local cellWidth = cellBg:getPixelSize().width
			local yDistance = 1.0
			local xDistance = 1.0
			local yPosData = math.floor((i-1)/2)
			if yPosData < 0 then
				yPosData = 0
			end
			local yPos = 8 + (cellHeight+yDistance)*yPosData
			local xPos = 8
			
			if math.mod(i,2) == 0 then
				xPos = 1 + cellWidth+xDistance + 10
			end
			cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))

			local skillBoxName = namePrefix .. "lifeskillcell/skill"
			local skillLayout = {}
			skillLayout.skillBox = CEGUI.toSkillBox(winMgr:getWindow(skillBoxName))
			skillLayout.skillBox:setID(skillBean.id)
			skillLayout.skillLevel = skillBean.level
            skillLayout.skillbg = CEGUI.toGroupButton(winMgr:getWindow(namePrefix.."lifeskillcell"))
            skillLayout.skillbg:setID(skillBean.id)
			skillLayout.skillBox:SetImage(gGetIconManager():GetImageByID(curRecord.icon))

			local skillLevel_st = winMgr:getWindow(namePrefix.."lifeskillcell/skill/level")
			skillLevel_st:setText(""..tostring(skillBean.level))
			-- 记录炼药技能等级
			if skillBean.id == 310101 then
				self.m_drugSkillLevel = skillBean.level
			end

            skillLayout.skillbg:subscribeEvent("SelectStateChanged", GonghuiSkillDlg.HandleSkillClicked, self)
			skillLayout.name = winMgr:getWindow(namePrefix.."lifeskillcell/name")
			skillLayout.name:setText(curRecord.name)
			self.m_skills[i] = skillLayout
		end
	end
	
	self:RefreshSkillBoxSel()
end




function GonghuiSkillDlg:RefreshSkillBoxSel()
	local skillID = self.nSelSkillId
	
	if #self.m_skills <= 0 then
		return
	end
	
	for i,v in ipairs(self.m_skills) do
		if self.m_skills[i].skillBox:getID() == skillID then
			self.m_skills[self.m_curSkillIndex].skillBox:SetSelected(false)
            self.m_skills[self.m_curSkillIndex].skillbg:setSelected(false)
			self.m_curSkillIndex = i
			break
		end
	end
	--self.m_skills[self.m_curSkillIndex].skillBox:SetSelected(true)
    self.m_skills[self.m_curSkillIndex].skillbg:setSelected(true)
	self.m_scrollEndPos = 0
	self:RefreshSkillDesc()
	self:RefreshSkillDetail()
end


function GonghuiSkillDlg:RefreshSkillDesc()
	if not self.m_skills[self.m_curSkillIndex] then
		return
	end
	local curSkillID = self.m_skills[self.m_curSkillIndex].skillBox:getID()
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	local curLifeSkillRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(curSkillID)
	local skillTitle = winMgr:getWindow("lifeskill/study/title")
	skillTitle:setText(curLifeSkillRecord.name)

	local skillLevel = self.m_skills[self.m_curSkillIndex].skillLevel
	local skillLevel_layout = winMgr:getWindow("lifeskill/study/lv")
	skillLevel_layout:setText(""..tostring(skillLevel))
	
	local skillDesc_layout = CEGUI.Window.toRichEditbox(winMgr:getWindow("lifeskill/study/explain"))

	skillDesc_layout:Clear()

	if string.match(curLifeSkillRecord.description, "$parameter1") then
		local strbld = StringBuilder.new()
		strbld:Set("parameter1", curLifeSkillRecord.ParaIndexList[0])
		strbld:Set("parameter2", curLifeSkillRecord.ParaIndexList[1])
		strbld:Set("parameter3", curLifeSkillRecord.ParaIndexList[2])
		skillDesc_layout:AppendParseText(CEGUI.String(strbld:GetString(curLifeSkillRecord.description)))
        strbld:delete()
	else
		local textColour = CEGUI.PropertyHelper:stringToColourRect("ff8c5e2a")
		skillDesc_layout:AppendText(CEGUI.String(curLifeSkillRecord.description), textColour, false)
	end
	skillDesc_layout:AppendBreak()
	skillDesc_layout:Refresh()
	skillDesc_layout:HandleTop()
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local haveYinbi_layout = winMgr:getWindow("lifeskill/study/haveyinbi_num")
	
	-- 修改部分开始：根据技能ID决定显示的货币
	if curSkillID == 320105 then
		-- 技能320105显示金币
		self.m_curYinbiCount = roleItemManager:GetGold()
		-- 设置金币图标
		local needYinbi_image = winMgr:getWindow("lifeskill/study/needyinbi_num/imageyinb")
		local haveYinbi_image = winMgr:getWindow("lifeskill/study/needyinbi_num/imageyinb1")
		needYinbi_image:setProperty("Image", "set:common image:common_jinb")
		haveYinbi_image:setProperty("Image", "set:common image:common_jinb")
	else
		-- 其他技能显示银币
		self.m_curYinbiCount = roleItemManager:GetPackMoney()
		-- 设置银币图标
		local needYinbi_image = winMgr:getWindow("lifeskill/study/needyinbi_num/imageyinb")
		local haveYinbi_image = winMgr:getWindow("lifeskill/study/needyinbi_num/imageyinb1")
		needYinbi_image:setProperty("Image", "set:common image:common_yinb")
		haveYinbi_image:setProperty("Image", "set:common image:common_yinb")
	end
	-- 修改部分结束
	
	local formatStr = require "utils.mhsdutils".GetMoneyFormatString(self.m_curYinbiCount)
	haveYinbi_layout:setText(formatStr)
	local studyCostRule = curLifeSkillRecord.studyCostRule
	local skillCostRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskillcost"):getRecorder(skillLevel+1)
	if skillCostRecord then
		local silverCostList = skillCostRecord.silverCostList
		local needYinbi_layout = winMgr:getWindow("lifeskill/study/needyinbi_num")
		LogInfo("silverCostList:size():  "..silverCostList:size())
		if studyCostRule and studyCostRule > 0 and studyCostRule <= silverCostList:size() then
			local needYinbi = silverCostList[studyCostRule-1]
			self.m_needYinbi = tonumber(needYinbi)
			self.m_needYinbi_layout = needYinbi_layout
			local formatStr = require "utils.mhsdutils".GetMoneyFormatString(needYinbi)
			needYinbi_layout:setText(formatStr)
			if self.m_curYinbiCount < self.m_needYinbi then
                needYinbi_layout:setProperty("TextColours", "FFFF0000")
			else 
                needYinbi_layout:setProperty("TextColours", self.m_defaultColor)
			end
		end

		self.m_gonghuiContri = gGetDataManager():getContribution()
		
		local haveBanggong_layout = winMgr:getWindow("lifeskill/study/havebanggong_num")
        local formatStr = require "utils.mhsdutils".GetMoneyFormatString(self.m_gonghuiContri)
		haveBanggong_layout:setText(formatStr)
		
		local guildCostList = skillCostRecord.guildContributeCostList
		local needBanggong_layout = winMgr:getWindow("lifeskill/study/needbanggong_num")
		if studyCostRule and studyCostRule > 0 and studyCostRule <= guildCostList:size() then
			local needBanggong = guildCostList[studyCostRule-1]
			needBanggong_layout:setText(needBanggong)
            formatStr = require "utils.mhsdutils".GetMoneyFormatString(needBanggong)
 			needBanggong_layout:setText(formatStr)
			if self.m_gonghuiContri < needBanggong then
 				needBanggong_layout:setProperty("TextColours", "FFFF0000")
			else
 				needBanggong_layout:setProperty("TextColours", self.m_defaultColor)
            end
		end
	end
end

function GonghuiSkillDlg.new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, GonghuiSkillDlg)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(GonghuiSkillDlg.OnMoneyChange)
	return self	
end


function GonghuiSkillDlg:HandleStudyBtnClicked(args)
    local datamanager = require "logic.faction.factiondatamanager"
    if not datamanager:IsHasFaction() then
        if require "logic.xingongnengkaiqi.xingongnengopendlg".checkFeatureOpened(5) then
            Familyjiarudialog.getInstanceAndShow()
        else
            local msg = require "utils.mhsdutils".get_msgtipstring(145390)
		    GetCTipsManager():AddMessageTip(msg)                   
        end
    end

    self.m_bStudyBtnClicked = true
	local curSkillID = self.m_skills[self.m_curSkillIndex].skillBox:getID()
	local lifeSkillRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(curSkillID)
	local skillLevel = self.m_skills[self.m_curSkillIndex].skillLevel
	local roleLevel = gGetDataManager():GetMainCharacterLevel()
	local studyLevelRule = lifeSkillRecord.studyLevelRule
	
	local skillCostRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskillcost"):getRecorder(skillLevel+1)
	if skillCostRecord then
		local needLevelList = skillCostRecord.needLevelList
		-- 检查等级是否足够
		print("needLevelList:size(): "..needLevelList:size())
		if studyLevelRule and studyLevelRule > 0 and studyLevelRule <= needLevelList:size() then
			local needLevel = needLevelList[studyLevelRule-1]
			if needLevel and roleLevel < needLevel then
				GetCTipsManager():AddMessageTipById(150016)
                self.m_bStudyBtnClicked = false
				return
			end
		end
		
		-- 检查银币是否足够
local studyCostRule = lifeSkillRecord.studyCostRule
local silverCostList = skillCostRecord.silverCostList
if studyCostRule and studyCostRule > 0 and studyCostRule <= silverCostList:size() then
    local silverCost = silverCostList[studyCostRule-1]
    
    -- 修改部分开始：技能320105检查金币
    if curSkillID == 320105 then
        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local goldCount = roleItemManager:GetGold()
        if goldCount < silverCost then
            local result1 = silverCost - goldCount
            CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_GoldCoin, result1)
            self.m_bStudyBtnClicked = false
            return
        end
    else
        -- 其他技能检查银币
        if self.m_curYinbiCount < silverCost then
            local result1 = silverCost - self.m_curYinbiCount
            CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, result1)
            self.m_bStudyBtnClicked = false
            return
        end
    end
    -- 修改部分结束
end  -- 这个end是关闭if studyCostRule的
        
-- 检查帮贡是否足够
local guildCostList = skillCostRecord.guildContributeCostList
if studyCostRule and studyCostRule > 0 and studyCostRule <= guildCostList:size() then
    local guildCost = guildCostList[studyCostRule-1]
    if self.m_gonghuiContri < guildCost then
        GetCTipsManager():AddMessageTipById(150017)
        self.m_bStudyBtnClicked = false
        return
    end
end

		-- 发送学习请求
		local p = require "protodef.fire.pb.skill.liveskill.crequestlearnliveskill".Create()
		p.id = curSkillID
		LuaProtocolManager.getInstance():send(p)
	end
end

local refreshSkill = false
function GonghuiSkillDlg:HandleSkillClicked(args)
	LogInfo("HandleSkillClicked")
	local event = CEGUI.toWindowEventArgs(args)
	local skillID = event.window:getID()
    self.nSelSkillId = skillID
	-- 如果点击是当前已选择的技能，就返回
	if self.m_skills[self.m_curSkillIndex].skillBox:getID() == skillID then
		return 
	end
	for i,v in ipairs(self.m_skills) do
		if self.m_skills[i].skillBox:getID() == skillID then
			self.m_skills[self.m_curSkillIndex].skillBox:SetSelected(false)
			self.m_curSkillIndex = i
			break
		end
	end
	--self.m_skills[self.m_curSkillIndex].skillBox:SetSelected(true)
	self.m_scrollEndPos = 0
	self:RefreshSkillDesc()
	self:RefreshSkillDetail()
	local p = require("protodef.fire.pb.skill.liveskill.crequestattr").Create()
    local attr = {}
    attr[1] = fire.pb.attr.AttrType.ENERGY
	p.attrid = attr
	LuaProtocolManager:send(p)	
end

function GonghuiSkillDlg.setSelectedSkillId(skillID)
	if not skillID then
		return
	end
	if not _instance then
		return
	end	
	_instance.nSelSkillId = skillID
	_instance:RefreshSkillBoxSel()
	
end

local ids = std.vector_int_()


function GonghuiSkillDlg:RefreshSkillDetail()
    if not self.m_skills[self.m_curSkillIndex] then
        self.m_bStudyBtnClicked = false
        return
    end
    local winMgr = CEGUI.WindowManager:getSingleton()
    local pathTable = {"lifeskill/zhiyao","lifeskill/pengren","lifeskill/dazao","lifeskill/beidong"}
    
    for _,v in ipairs(pathTable) do
        local skillWnd = winMgr:getWindow(v)
        skillWnd:setVisible(false)
    end
    
    local curSkillID = self.m_skills[self.m_curSkillIndex].skillBox:getID()
    local curLifeSkillRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(curSkillID)

    if self.m_skill_cs then
        self.m_skill_cs:setVisible(false)
    end
    
    if curSkillID == 310101 then
        self.m_layoutPath = pathTable[1]
        self.m_skillType = 1 -- 炼药
    elseif curSkillID == 310201 then
        self.m_layoutPath = pathTable[2]
        self.m_skillType = 2 -- 烹饪
    elseif curSkillID == 300101 or curSkillID == 300201 or curSkillID == 300301 then
        self.m_layoutPath = pathTable[3]
        self.m_skillType = 3 -- 锻造，裁缝，炼金
    elseif curSkillID == 320103 or curSkillID == 320104 or curSkillID == 330102 or curSkillID == 330103 or curSkillID == 320105 then
        self.m_layoutPath = pathTable[4]
        self.m_skillType = 4 -- 强体术，冥想术，追捕术，逃离术，变身之术
    end
    
    -- 确保设置了有效的路径
    if self.m_layoutPath then
        self.m_skill_cs = winMgr:getWindow(self.m_layoutPath)
        self.m_skill_cs:setVisible(true)
    end

	
	local skillDetail_layout = CEGUI.Window.toRichEditbox(winMgr:getWindow(self.m_layoutPath.."/explain"))
	skillDetail_layout:Clear()
	local textColour = CEGUI.PropertyHelper:stringToColourRect("ff8c5e2a")
	skillDetail_layout:AppendText(CEGUI.String(curLifeSkillRecord.gangdescription),textColour,false)
	skillDetail_layout:AppendBreak()
	skillDetail_layout:Refresh()
	skillDetail_layout:HandleTop()
	

	if self.m_skillType == 3 or self.m_skillType == 1 or self.m_skillType == 2 then
		local btnPath = self.m_layoutPath.."/dazao"
		if self.m_skillType == 1 or self.m_skillType == 2 then
			btnPath = self.m_layoutPath.."/btn"
		end
		local skill_btn = CEGUI.Window.toPushButton(winMgr:getWindow(btnPath))
		local skillBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress") 
    if skillBtnPressAnimationDef then
        local skillBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(skillBtnPressAnimationDef)
        skillBtnPressAnimation:setTargetWindow(skill_btn)
        skillBtnPressAnimation:setSpeed(0.7) -- 

        skill_btn:subscribeEvent("MouseButtonDown", 
            function()
                skillBtnPressAnimation:start() -- 
            end, self)
    end
		
		-- 炼药按钮
		if self.m_skillType == 1 then
			skill_btn:removeEvent("Clicked")
			skill_btn:subscribeEvent("Clicked", GonghuiSkillDlg.HandleZuoyaoClicked, self)
		elseif self.m_skillType == 2 then
			skill_btn:removeEvent("MouseButtonUp")
			skill_btn:subscribeEvent("MouseButtonUp", GonghuiSkillDlg.HandlePengrenClicked, self)
		end
	end

	local skillLevel = self.m_skills[self.m_curSkillIndex].skillLevel

	-- 获取玩家活力值
	self.m_huoli = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	if self.m_skillType == 1 or self.m_skillType == 2 or self.m_skillType == 3 then
		local needHuoliPath = self.m_layoutPath.."/needhuoli_num"
		if self.m_skillType == 3 then
			needHuoliPath = self.m_layoutPath .. "/diban/xiaohao0"
		end
		self.m_needHuoli_st = winMgr:getWindow(needHuoliPath)
		if not self.m_orinalColor then
			self.m_orginalColor = self.m_needHuoli_st:getProperty("TextColours")
		end
		
		-- 需要消耗的活力值
		self:SetNeedHuoli(skillLevel)
	end
	
	
	if self.m_skillType == 1 or self.m_skillType == 2 then
		-- 烹饪需要的道具列表
		local itemList = {}
		local ids = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getAllID()
        for _, v in pairs(ids) do
			local itemRecord = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(v)
			if self.m_skillType == 2 then
				if itemRecord.needPengrenLevel ~= "" then
					local eachItem = {id=v, needLevel=itemRecord.needPengrenLevel}
					table.insert(itemList, eachItem)
				end
			else 
				if itemRecord.needLianyaoLevel ~= "" then
					local eachItem = {id=v, needLevel=itemRecord.needLianyaoLevel}
					table.insert(itemList, eachItem)
				end
			end
		end
		table.sort(itemList, function(v1, v2)
			if v1.needLevel < v2.needLevel then
				return true
			end
		end)

		local cellCount = 8
		if self.m_skillType == 1 then
			cellCount = 6
		end
		local skillEnabled = false
		for j=1, table.getn(itemList) do
			if j > cellCount then
				break
			end
			local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemList[j].id)
			local cellPath = self.m_layoutPath.."/Table1/ItemCell"..j
			local item_cell = CEGUI.toItemCell(winMgr:getWindow(cellPath))
            if itemBean then
			    item_cell:SetImage(gGetIconManager():GetImageByID(itemBean.icon))
            end
			if skillLevel < tonumber(itemList[j].needLevel) and self.m_skillType == 2 then
				local levelStr = ""
				item_cell:SetTextUnit(levelStr..itemList[j].needLevel)
				item_cell:SetTextUnitColor(require "utils.mhsdutils".get_redcolor())
            else
                item_cell:SetTextUnit("")
			end
			item_cell:setID(itemList[j].id)
			item_cell:removeEvent("TableClick")
            SetItemCellBoundColorByQulityItemWithId(item_cell, itemList[j].id)
			-- 这里的物品提示需要修改为通用LUA接口

			item_cell:subscribeEvent("TableClick", GonghuiSkillDlg.HandleItemClickWithItemID, self)
			-- 判断是否达到最低的等级
			if j == 1 then
				if skillLevel >= tonumber(itemList[j].needLevel) then
					skillEnabled = true
				end
			end
			
		end
		local skillBtnPath = self.m_layoutPath.."/btn"
		local skillBtn = CEGUI.Window.toPushButton(winMgr:getWindow(skillBtnPath))
		if skillEnabled == false then
			skillBtn:setEnabled(false)
		else
			skillBtn:setEnabled(true)
		end
	end
	
    	-- 被动技能
	if self.m_skillType == 4 then
		-- 获取被动技能的数值
		local lifeSkillRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(curSkillID)
		local lifeSkillVar = lifeSkillRecord.upgradeVariable
		-- 属性说明
		local curDesc_st = winMgr:getWindow("lifeskill/beidong/xiaoguo/heizi1")
		curDesc_st:setText(lifeSkillRecord.upgradeDesc)
		local nextDesc_st = winMgr:getWindow("lifeskill/beidong/xiaoguo/heizi2")
		nextDesc_st:setText(lifeSkillRecord.upgradeDesc)
		-- 图标
		local effect_si = winMgr:getWindow("lifeskill/beidong/tubiao")
		local imagePath = gGetIconManager():GetImagePathByID(lifeSkillRecord.icon):c_str()
		effect_si:setProperty("Image", imagePath)
        local curEffect_st = winMgr:getWindow("lifeskill/beidong/xiaoguo/lvzi1")
        curEffect_st:setText("+"..tostring(math.floor(skillLevel*lifeSkillVar)))
        local nextEffect_st = winMgr:getWindow("lifeskill/beidong/xiaoguo/lvzi2")
        nextEffect_st:setText("+"..tostring(math.floor((skillLevel+1)*lifeSkillVar)))
		
	end

	
	if self.m_skillType == 3 then
        self.m_insertDazaoPanel = false
        
        if self.m_bStudyBtnClicked == true then
            self.m_bStudyBtnClicked = false
            if (skillLevel%10) ~= 0 then
                return
            end
        end
        self.m_itemIDList = {}
		self.id_index = 0
		self.m_iCurPage = 1
		self.m_pageGap = 0
		
		if not self.m_scrollItemPanel then
			self.m_scrollItemPanel = CEGUI.Window.toScrollablePane(winMgr:getWindow("lifeskill/dazao/list"))

			self.m_scrollItemPanel:EnableHorzScrollBar(true)
			self.m_scrollItemPanel:EnablePageScrollMode(true)
		end
		self.m_scrollItemPanel:cleanupNonAutoChildren()
		
		ids = BeanConfigManager.getInstance():GetTableByName("item.cgroceryeffect"):getAllID()
		local index = 0
		self.m_iMaxPage = 0
		for _, v in pairs(ids) do
			local itemRecord = BeanConfigManager.getInstance():GetTableByName("item.cgroceryeffect"):getRecorder(v)
			local needLevelValue = itemRecord.needDuanzaoLevel
			if curSkillID == 300201 then
				needLevelValue = itemRecord.needCaifengLevel
			elseif curSkillID == 300301 then
				needLevelValue = itemRecord.needLianjinLevel
			end
			-- 第一个制造符不检查等级条件 skillLevel >= tonumber(needLevelValue)
			if needLevelValue ~= ""  then
				eachItem = {id=v, needLevel=needLevelValue}
				local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(eachItem.id)
                    if itemBean then
				    local namePrefix = tostring(itemBean.id)
				    print("namePrefix: "..namePrefix)
				    local cellWnd = winMgr:loadWindowLayout("lifeskilldazaocell.layout", namePrefix)
				    self.m_scrollItemPanel:addChildWindow(cellWnd)
                    self.m_scrollItemPanel:SetLoadedDraw(true)
				
				    local item_cell = CEGUI.toItemCell(winMgr:getWindow(namePrefix.."lifeskilldazaocell/item"))
				    item_cell:SetImage(gGetIconManager():GetImageByID(itemBean.icon))
				    item_cell:setID(eachItem.id)
				    item_cell:subscribeEvent("TableClick", GonghuiSkillDlg.HandleItemClickWithItemID, self)
				    item_cell:setProperty("ClippedByParent", "true")
				    -- 打造符名称
				    local itemName_st = winMgr:getWindow(namePrefix.."lifeskilldazaocell/dazaofu")
				    itemName_st:setText(itemBean.name)
				    itemName_st:setProperty("ClippedByParent", "true")
				    local level_st = winMgr:getWindow(namePrefix.."lifeskilldazaocell/dengji")
				    local strbuilder = StringBuilder:new()
				    strbuilder:Set("parameter1", eachItem.needLevel)
				    level_st:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(10030)))
                    strbuilder:delete()
				    level_st:setProperty("ClippedByParent", "true")
				    -- 打造符等级
				    

				    local cellWidth = cellWnd:getPixelSize().width
				    local xGap = 0
				    local yPos = 0.1
				    local xPos = 0.1 + (xGap + cellWidth)*index
				    self.m_pageGap = xGap + cellWidth
				
				    cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
				    index = index + 1
				    self.m_iMaxPage = self.m_iMaxPage + 1
				    table.insert(self.m_itemIDList,itemBean)
                end
			end
			if index >= 1 then
				self.id_index = v
				break
			end

		end
		self.m_insertDazaoPanel = true
		
		local leftArrow_si = winMgr:getWindow("lifeskill/dazao/leftjiantou")
		leftArrow_si:removeEvent("MouseButtonUp")
		leftArrow_si:subscribeEvent("MouseButtonUp", GonghuiSkillDlg.ScrollToPrePage, self)
		local rightArrow_si = winMgr:getWindow("lifeskill/dazao/rightjiantou")
		rightArrow_si:removeEvent("MouseButtonUp")
		rightArrow_si:subscribeEvent("MouseButtonUp", GonghuiSkillDlg.ScrollToNextPage, self)
		if not self.m_arrowEvent then
			self.m_arrowEvent = true
			
		end	
		self.m_pMainFrame:removeEvent("WindowUpdate")
		self.m_pMainFrame:subscribeEvent("WindowUpdate", GonghuiSkillDlg.HandleWindowUpdate, self)

		local winMgr = CEGUI.WindowManager:getSingleton()
    local dazaoBtn = CEGUI.toPushButton(winMgr:getWindow("lifeskill/dazao/dazao"))

    local dazaoBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress") --  
    if dazaoBtnPressAnimationDef then
        -- 
        local dazaoBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(dazaoBtnPressAnimationDef)


        dazaoBtnPressAnimation:setTargetWindow(dazaoBtn)
        dazaoBtnPressAnimation:setSpeed(0.7)  -- 


        dazaoBtn:subscribeEvent("MouseButtonDown", 
            function()
                dazaoBtnPressAnimation:start() -- 
            end, self)
    end

    dazaoBtn:removeEvent("MouseButtonUp")
    dazaoBtn:subscribeEvent("MouseButtonUp", GonghuiSkillDlg.HandleDazaoClicked, self)

		-- 左右箭头与底部按钮的显示
		if skillLevel < 10 then
			leftArrow_si:setVisible(false)
			rightArrow_si:setVisible(false)
			dazaoBtn:setEnabled(false)
		else
			dazaoBtn:setEnabled(true)
		end
	end
end


function GonghuiSkillDlg:SetNeedHuoli(skillLevel)

    if skillLevel == 0 then
        self.m_needHuoli = 0
        self.m_needHuoli_st:setText("0")
    else
        local curSkillID = self.m_skills[self.m_curSkillIndex].skillBox:getID()
        local curLifeSkillRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskill"):getRecorder(curSkillID)
        -- 需要消耗的活力值
        local skillCostRecord = BeanConfigManager.getInstance():GetTableByName("skill.clifeskillcost"):getRecorder(skillLevel)
        local strengthCostRule = curLifeSkillRecord.strengthCostRule
        local strengthCostList = skillCostRecord.strengthCostList
        if strengthCostRule and strengthCostRule >= 1 and strengthCostRule <= strengthCostList:size() then
            local needHuoli = strengthCostList[strengthCostRule-1]
            self.m_needHuoli = tonumber(needHuoli)
        

            self.m_needHuoli_st:setText(self.m_huoli) 

            local winMgr = CEGUI.WindowManager:getSingleton()
            local consumeHuoli_st = winMgr:getWindow(self.m_layoutPath .. "/consumeHuoli_st") 

            consumeHuoli_st:setText(needHuoli) 
            if self.m_huoli < self.m_needHuoli then
                local huoliColor = "FFFF0000"
                local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor

                consumeHuoli_st:setProperty("TextColours", textColor)  
            else
                consumeHuoli_st:setProperty("TextColours", self.m_orginalColor)
            end

        else 
            self.m_needHuoli_st:setText("0")
        end
    end

end


function GonghuiSkillDlg:InsertDazaoPanel()
	if self.m_skillType ~= 3 then
		return
	end
	local skillLevel = self.m_skills[self.m_curSkillIndex].skillLevel
	local curSkillID = self.m_skills[self.m_curSkillIndex].skillBox:getID()
	local index = 1
    for _, v in pairs(ids) do
        if v >= self.id_index + 1 then
            local itemRecord = BeanConfigManager.getInstance():GetTableByName("item.cgroceryeffect"):getRecorder(v)
		    local needLevelValue = itemRecord.needDuanzaoLevel
		    if curSkillID == 300201 then
			    needLevelValue = itemRecord.needCaifengLevel
		    elseif curSkillID == 300301 then
			    needLevelValue = itemRecord.needLianjinLevel
		    end

		    if needLevelValue ~= "" and skillLevel >= tonumber(needLevelValue) then
			    eachItem = {id=v, needLevel=needLevelValue}
			    local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(eachItem.id)
                if itemBean then
			        local namePrefix = tostring(itemBean.id)
			        local winMgr = CEGUI.WindowManager:getSingleton()
			        local cellWnd = winMgr:loadWindowLayout("lifeskilldazaocell.layout", namePrefix)
			        self.m_scrollItemPanel:addChildWindow(cellWnd)
			        local item_cell = CEGUI.toItemCell(winMgr:getWindow(namePrefix.."lifeskilldazaocell/item"))
			        item_cell:SetImage(gGetIconManager():GetImageByID(itemBean.icon))
			        item_cell:setID(eachItem.id)
			        item_cell:setProperty("ClippedByParent", "true")
			        item_cell:subscribeEvent("TableClick", GonghuiSkillDlg.HandleItemClickWithItemID, self)
			        -- 打造符名称
			        local itemName_st = winMgr:getWindow(namePrefix.."lifeskilldazaocell/dazaofu")
			        itemName_st:setText(itemBean.name)
			        itemName_st:setProperty("ClippedByParent", "true")
			        local level_st = winMgr:getWindow(namePrefix.."lifeskilldazaocell/dengji")
			        local strbuilder = StringBuilder:new()
			        strbuilder:Set("parameter1", eachItem.needLevel)
			        level_st:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(10030)))
                    strbuilder:delete()
			        level_st:setProperty("ClippedByParent", "true")
			        

			        local cellWidth = cellWnd:getPixelSize().width
			        local xGap = self.m_scrollItemPanel:getPixelSize().width - cellWidth
			        local yPos = 0.1
			        local xPos = (xGap + cellWidth)*index
			        self.m_pageGap = xGap + cellWidth
			        index = index  + 1
			        cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
			        self.m_iMaxPage = self.m_iMaxPage + 1
			        table.insert(self.m_itemIDList, itemBean)
                    SetHorizontalScrollCellRight(self.m_scrollItemPanel,cellWnd)
                end
		    end
        end
		
	end
	if index > 1 then
		self.m_iCurPage = self.m_iCurPage + index - 1
		local curPos = self.m_scrollItemPanel:getHorzScrollbar():getScrollPosition()
		self.m_scrollEndPos = curPos
	end
	self.m_insertDazaoPanel = false
	
	-- 如果是锻造，裁缝，炼金，技能等级以当前的制造符的等级为准
    
	if self.m_skillType == 3 then
		local needLevel = self.m_itemIDList[self.m_iCurPage].level
		self:SetNeedHuoli(needLevel)
	end
    
	
end

function GonghuiSkillDlg:HandleItemClickWithItemID(args)
	local event = CEGUI.toWindowEventArgs(args)
	local itemID = event.window:getID()
	local needLevel = 0
	for i = 1, table.getn(self.m_itemIDList) do
		local eachBean = self.m_itemIDList[i]
		if eachBean.id == itemID then
			needLevel = eachBean.level
		end
	end

	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	-- 计算提示窗口位置
	local winMgr = CEGUI.WindowManager:getSingleton()
	local rootWnd = winMgr:getWindow("lifeskill")
	local rootWidth = rootWnd:getWidth().offset
	local rootHeight = rootWnd:getHeight().offset
	local posX = rootWidth*0.5-120.0
	local posY = rootHeight*0.5-140.0
		
	local nType = Commontipdlg.eType.eSkill
	if needLevel == 0 then
		commontipdlg:RefreshItem(nType,itemID,posX,posY)
	else
		commontipdlg:RefreshItem(nType,itemID,posX,posY)
	end
end


function GonghuiSkillDlg:HandleZuoyaoClicked(args)
	local p = require("protodef.fire.pb.skill.liveskill.crequestattr").Create()
    local attr = {}
    attr[1] = fire.pb.attr.AttrType.ENERGY
	p.attrid = attr
	LuaProtocolManager:send(p)	
	ZuoyaoDlg.getInstanceAndShow()
end

function GonghuiSkillDlg:HandlePengrenClicked(args)
	-- 检查活力是否足够
	if self.m_huoli < self.m_needHuoli then
		GetCTipsManager():AddMessageTipById(150100)
		return
	end
	
	-- 发送烹饪请求
	local p = require "protodef.fire.pb.skill.liveskill.cliveskillmakefood".Create()
	LuaProtocolManager.getInstance():send(p)
end

function GonghuiSkillDlg:HandleDazaoClicked(args)
    -- 判断等级是否足够
	local skillLevel = self.m_skills[self.m_curSkillIndex].skillLevel
	if skillLevel < 10 then
		GetCTipsManager():AddMessageTipById(150016)
		return
	end
	
	
	-- 检查活力是否足够
	if self.m_huoli < self.m_needHuoli then
		GetCTipsManager():AddMessageTipById(150100)
		return
	end
	
	-- 发送打造请求
	local p = require "protodef.fire.pb.skill.liveskill.cliveskillmakestuff".Create()
	p.itemid = self.m_itemIDList[self.m_iCurPage].id
	p.itemnum = 1
	LuaProtocolManager.getInstance():send(p)

end

local scrollTime1 = 0
local scrollTime2 = 0


function GonghuiSkillDlg:ScrollToNextPage(args)
	if self.m_scrollPaneState == 0 and self.m_iCurPage < self.m_iMaxPage then
		self.m_iCurPage = self.m_iCurPage + 1
		local curPos = self.m_scrollItemPanel:getHorzScrollbar():getScrollPosition()
		self.m_scrollEndPos = curPos + self.m_pageGap
		
		self.m_scrollSpeed = self.m_pageGap/self.m_scrollTime
		self.m_timeElapsed = 0
		self.m_scrollPaneState = 1
		self:ResetArrow()
		local needLevel = self.m_itemIDList[self.m_iCurPage].level
		self:SetNeedHuoli(needLevel)
	end
end

function GonghuiSkillDlg:ScrollToPrePage(args)
	if self.m_scrollPaneState == 0 and self.m_iCurPage > 1 then
		self.m_iCurPage = self.m_iCurPage - 1
		local curPos = self.m_scrollItemPanel:getHorzScrollbar():getScrollPosition()
		self.m_scrollEndPos = curPos - self.m_pageGap
		self.m_scrollSpeed = -self.m_pageGap/self.m_scrollTime
		self.m_timeElapsed = 0
		self.m_scrollPaneState = 1
		self:ResetArrow()
		local needLevel = self.m_itemIDList[self.m_iCurPage].level
		self:SetNeedHuoli(needLevel)
	end
end



function GonghuiSkillDlg:HandleWindowUpdate(args)
	if self.m_skillType ~= 3 then
		return
	end
	local updateArgs = CEGUI.toUpdateEventArgs(args)
	local elapsed = updateArgs.d_timeSinceLastFrame
	if self.m_scrollPaneState == 1 then
		self.m_timeElapsed = self.m_timeElapsed + elapsed
		local curPosition = self.m_scrollItemPanel:getHorzScrollbar():getScrollPosition()
		if self.m_timeElapsed < self.m_scrollTime then
			self.m_scrollItemPanel:getHorzScrollbar():setScrollPosition(curPosition + elapsed*self.m_scrollSpeed)
		else 
			self.m_scrollItemPanel:getHorzScrollbar():setScrollPosition(self.m_scrollEndPos)
			self.m_scrollPaneState = 0
		end
	end	

	-- 设置Scrollpanel
	if self.m_insertDazaoPanel == true then
		self:InsertDazaoPanel()
	end

	local endPos = self.m_scrollItemPanel:getScrollEndPos()
	if endPos == 0 and self.m_scrollPaneState == 0 then

		local curPos = self.m_scrollItemPanel:getHorzScrollbar():getScrollPosition()
		local movedPos = curPos - self.m_scrollEndPos
		
		if math.abs(movedPos) > self.m_pageGap*0.5 then
			if movedPos > 0 and self.m_iCurPage < self.m_iMaxPage then
				self.m_iCurPage = self.m_iCurPage + 1
				self.m_scrollEndPos = self.m_scrollEndPos + self.m_pageGap

				self.m_scrollItemPanel:getHorzScrollbar():setScrollPosition(self.m_scrollEndPos)
				self.m_scrollItemPanel:getHorzScrollbar():Stop()
			end
			if movedPos < 0 and self.m_iCurPage > 1 then
				self.m_iCurPage = self.m_iCurPage - 1
				self.m_scrollEndPos = self.m_scrollEndPos - self.m_pageGap

				self.m_scrollItemPanel:getHorzScrollbar():setScrollPosition(self.m_scrollEndPos)
				self.m_scrollItemPanel:getHorzScrollbar():Stop()
			end
			
		end
		self:ResetArrow()
		
	end

end

function GonghuiSkillDlg:ResetArrow()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local leftArrow_si = winMgr:getWindow("lifeskill/dazao/leftjiantou")
	local rightArrow_si = winMgr:getWindow("lifeskill/dazao/rightjiantou")
	if self.m_iMaxPage == 1 then
		leftArrow_si:setVisible(false)
		rightArrow_si:setVisible(false)
		return
	end
	if self.m_iCurPage > 1 and self.m_iCurPage < self.m_iMaxPage then
		leftArrow_si:setVisible(true)
		rightArrow_si:setVisible(true)
	else
		if self.m_iCurPage <= 1 then
			rightArrow_si:setVisible(true)
		else
			rightArrow_si:setVisible(false)
		end
		if self.m_iCurPage >= self.m_iMaxPage then
			leftArrow_si:setVisible(true)
		else
			leftArrow_si:setVisible(false)
		end
	end
	
end

function GonghuiSkillDlg:OnMoneyChange()
	local dlg = GonghuiSkillDlg:getInstanceOrNot()
	if dlg then
		local winMgr = CEGUI.WindowManager:getSingleton()
		local haveYinbi_layout = winMgr:getWindow("lifeskill/study/haveyinbi_num")
		local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		
		-- 修改部分开始：根据当前技能ID决定更新哪种货币
		local curSkillID = dlg.m_skills[dlg.m_curSkillIndex].skillBox:getID()
		if curSkillID == 320105 then
			dlg.m_curYinbiCount = roleItemManager:GetGold()
		else
			dlg.m_curYinbiCount = roleItemManager:GetPackMoney()
		end
		-- 修改部分结束
		
		local formatStr = require "utils.mhsdutils".GetMoneyFormatString(dlg.m_curYinbiCount)
		haveYinbi_layout:setText(formatStr)
		if dlg.m_needYinbi_layout then
			local formatStr1 = require "utils.mhsdutils".GetMoneyFormatString(dlg.m_needYinbi)
			dlg.m_needYinbi_layout:setText(formatStr1)
			if dlg.m_curYinbiCount < dlg.m_needYinbi then
				dlg.m_needYinbi_layout:setProperty("TextColours", "FFFFFFFF")
			else
				dlg.m_needYinbi_layout:setProperty("TextColours", dlg.m_defaultColor)
			end
		end
	end
end


function GonghuiSkillDlg:OnStrengthChange()

    local dlg = GonghuiSkillDlg:getInstanceOrNot()
    if dlg then
        dlg.m_huoli = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
        if dlg.m_skillType == 1 or dlg.m_skillType == 2 or dlg.m_skillType == 3 then	
            local needHuoliPath = dlg.m_layoutPath.."/needhuoli_num" 
            local consumeHuoliPath = dlg.m_layoutPath.."/consumeHuoli_st" 
            if dlg.m_skillType == 3 then
                needHuoliPath = dlg.m_layoutPath .. "/diban/xiaohao0" 
            end
            local winMgr = CEGUI.WindowManager:getSingleton()
            local needHuoli_st = winMgr:getWindow(needHuoliPath)
            local consumeHuoli_st = winMgr:getWindow(consumeHuoliPath) 

            if dlg.m_needHuoli > dlg.m_huoli then
                local huoliColor = "FFFF0000"
                local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
          --      needHuoli_st:setProperty("TextColours", textColor)
                consumeHuoli_st:setProperty("TextColours", textColor)  -- 不足时显示红色
            else

                consumeHuoli_st:setProperty("TextColours", self.m_orginalColor)
            end
            needHuoli_st:setText(dlg.m_huoli)
            consumeHuoli_st:setText(dlg.m_needHuoli) 
        end
    end
    
end

function GonghuiSkillDlg:MakeFoodCallback(result, itemid)
	-- 烹饪成功
	if result == 0 then 
		local itemRecord = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(itemid)
        if itemRecord then
		    local strbuilder = StringBuilder:new()
		    strbuilder:Set("parameter1", itemRecord.name)
		    strbuilder:Set("parameter2", itemRecord.itemNameColor)
		    GetCTipsManager():AddMessageTip(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150102)))
            strbuilder:delete()
        end
	elseif result == 1 then
		GetCTipsManager():AddMessageTipById(150101)
	end
	if result == 0 or result == 1 then 
		-- 重置的活力值
		self:OnStrengthChange()
	end
end

function GonghuiSkillDlg:MakeStuffCallback(result)
	-- 制作打造符成功
	if result == 0 then 
		local itemid = self.m_itemIDList[self.m_iCurPage].id
		local itemBean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid)
        if itemBean then
		    local msg = require "utils.mhsdutils".get_msgtipstring(150107)
		    msg = string.gsub(msg, "%$parameter1%$", itemBean.name)
		    msg = string.gsub(msg, "%$parameter2%$", itemBean.colour)
		    GetCTipsManager():AddMessageTip(msg)
        end
	elseif result == 1 then
		GetCTipsManager():AddMessageTipById(150106)
	end
	if result == 0 or result == 1 then 
		-- 重置的活力值
		self:OnStrengthChange()
	end
	
end

function GonghuiSkillDlg.onInternetReconnected()
	if _instance then
		if _instance.m_skillList == nil then
            local crequestliveskilllist = require "protodef.fire.pb.skill.liveskill.crequestliveskilllist".Create()
		    LuaProtocolManager.getInstance():send(crequestliveskilllist)
        else
            local ncount = 0
            for k,v in pairs(_instance.m_skillList) do
                ncount = ncount + 1
	        end
            if ncount == 0 then
                local crequestliveskilllist = require "protodef.fire.pb.skill.liveskill.crequestliveskilllist".Create()
		        LuaProtocolManager.getInstance():send(crequestliveskilllist)
            end
        end
	end
end

return GonghuiSkillDlg

------------------------------------------------------------------
-- 宠物技能tip
------------------------------------------------------------------
require "logic.dialog"

PetSkillTipsDlg = {}
setmetatable(PetSkillTipsDlg, Dialog)
PetSkillTipsDlg.__index = PetSkillTipsDlg

local SKILLCELL_WIDTH = 38

local _instance
function PetSkillTipsDlg.getInstance()
	if not _instance then
		_instance = PetSkillTipsDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetSkillTipsDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetSkillTipsDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetSkillTipsDlg.getInstanceNotCreate()
	return _instance
end

function PetSkillTipsDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetSkillTipsDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetSkillTipsDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetSkillTipsDlg.GetLayoutFileName()
	return "petskilltips.layout"
end

function PetSkillTipsDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetSkillTipsDlg)
	return self
end

function PetSkillTipsDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_bg = winMgr:getWindow("petskilltips")
	self.editbox = CEGUI.toRichEditbox(winMgr:getWindow("petskilltips/rich"))
	self.petSkillName = winMgr:getWindow("petskilltips/name")
	self.petSkillName1 = winMgr:getWindow("petskilltips/name1")
	self.petSkillName2 = winMgr:getWindow("petskilltips/name2")
	self.petSkillIcon = CEGUI.toSkillBox(winMgr:getWindow("petskilltips/jineng"))
	self.petSkillIcon:SetBackGroundEnable(true)
    self.petSkillIcon:SetBackGroupOnTop(true)

	self.triggerWnd = nil
	self.skillid = 0
	self.duedate = 0

    self.originRichboxWidth = self.editbox:getPixelSize().width
    self.originBgWidth = self.m_bg:getPixelSize().width
	self.yiwangBtn= CEGUI.Window.toPushButton(winMgr:getWindow("petskilltips/yiwangbtn"))
	self.yiwangBtn:subscribeEvent("MouseButtonDown", PetSkillTipsDlg.HandleClickYiWangBtn, self)
end

function PetSkillTipsDlg:HandleClickYiWangBtn()
    local function ClickYes(self, args)
 
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        local p = require("protodef.fire.pb.pet.cxiechuneidan"):new()
        p.petkey = self.petkey
        p.idx=self.idx
		p.internalid=self.skillid
	    LuaProtocolManager:send(p)
    end
    local function ClickNo(self, args)
 
		gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
    gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(201084), ClickYes, 
    self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(11520),MHSD_UTILS.get_resstring(2036))
end

function PetSkillTipsDlg.ShowTipWithYiWang(petkey,skillid, idx, xpos, ypos, duedate)
	PetSkillTipsDlg.getInstanceAndShow()
	_instance.petkey=petkey
	_instance.skillid=skillid
	_instance.idx = idx
	_instance.yiwangBtn:setVisible(true)

	_instance:showPetSkillTips(skillid, xpos, ypos, duedate)
	return _instance
end
function PetSkillTipsDlg.GetPetData(petkey,idx)
	_instance.petkey = petkey
	_instance.idx = idx

end
function PetSkillTipsDlg.ShowTip(skillid, xpos, ypos, duedate)
	PetSkillTipsDlg.getInstanceAndShow()
	_instance:showPetSkillTips(skillid, xpos, ypos, duedate)
	return _instance
end

function PetSkillTipsDlg:showPetSkillTips(skillid, xpos, ypos, duedate)
	local petskill = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skillid)
	if petskill == nil then
		self:GetWindow():setVisible(false)
		return
	end

	if self.skillid ~= skillid or self.duedate ~= duedate then
		self.skillid = skillid
		self.duedate = duedate
--宠物技能框修改
		self.editbox:Clear()
		self.petSkillName:setText(petskill.skillname1)
		self.petSkillName1:setText(petskill.skillname2)
		self.petSkillName2:setText(petskill.skillname3)
		self.petSkillIcon:SetImage(gGetIconManager():GetSkillIconByID(petskill.icon))
		--self.editbox:AppendImage(CEGUI.String("common"), CEGUI.String("common_biaoshi_cc"))
		--self.editbox:AppendBreak()
        self.petSkillIcon:SetBackgroundDynamic(true)
        if petskill and petskill.id ~= -1 then
            local img = (petskill.skilltype==1 and "beiji" or "zhuji")
			img = img .. (petskill.color==1 and 1 or petskill.color==2 and 2 or petskill.color==3 and 3 or petskill.color==4 and 4 or 5)
      --      img = img .. (petskill.color==1 and 1 or 2)
            self.petSkillIcon:SetBackGroundImage(CEGUI.String("chongwuui"), CEGUI.String(img))
        end
		
		--技能描述
		self.editbox:AppendParseText(CEGUI.String(petskill.skilldescribe))
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		self.editbox:AppendBreak()
		
		
		local skillEffectColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFFF2DF")) --		
		if petskill.skilltype == 1 then
			self.editbox:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11813)), skillEffectColor) --被动
		else
			self.editbox:AppendText(CEGUI.String(petskill.param), skillEffectColor)
		end
        self.editbox:AppendBreak()
		--self.editbox:AppendImage(CEGUI.String("common"), CEGUI.String("common_biaoshi_cc"))
		--self.editbox:AppendBreak()
        
 
		--判断技能是否魔法值足够
		if GetBattleManager():IsInBattle() and GetBattleManager():IsMainPetOperate() then
			local battlepet = MainPetDataManager.getInstance():GetBattlePet()
			if battlepet then
				local num = battlepet:getSkilllistlen()
				for i=1, num do
					local skill = battlepet:getSkill(i)
					if petskill.id == skill.skillid then
						local mpneed = 60
						local effectnum = 0
--						local skillconsume = GameTable.skill.GetCSkillConsumeTableInstance():getRecorder(petskill.id)
--						if skillconsume.id ~= -1 then
--							for j=0, skillconsume.numberrand:size()-1 do
--								local val = skillconsume.numberrand[j]
--								if battlepet:getAttribute(fire.pb.attr.AttrType.LEVEL) >= val then
--									effectnum = effectnum+1
--								else
--									break
--								end
--							end
--						else
							effectnum = 1
--						end
						mpneed = mpneed * effectnum
						break
					end
				end
			end
		end

		--有时效的宠物技能，tips要显示技能剩余时间
		if duedate and duedate > 0 then
			local curTime = gGetServerTime()
			local strLeftTime = self:leftTimeToString(duedate - curTime)
			self.editbox:AppendText(CEGUI.String(strLeftTime), skillEffectColor)
			self.editbox:AppendBreak()
		end

		self.editbox:setSize(NewVector2(self.originRichboxWidth, 30))
		self.editbox:Refresh()

		local needSize = self.editbox:GetExtendSize()
		if needSize.width < self.originRichboxWidth then
			needSize.width = self.originRichboxWidth
		end
		needSize.height = needSize.height+10
		self.editbox:setSize(NewVector2(needSize.width, needSize.height))
        self.m_bg:setSize(NewVector2(self.originBgWidth, needSize.height + 150))
		self.yiwangBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 230), CEGUI.UDim(0, 0 + needSize.height + 100)))
	end

	local x
	local y

	if xpos then
		local tw = self:GetWindow():getPixelSize().width
		local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width

		x = xpos + SKILLCELL_WIDTH
		if xpos == 0 then
			x = (pw - tw) * 0.5
		else
			if x + tw > pw then
				x = x - tw
			end
		end
	end

	if ypos then
		local th = self:GetWindow():getPixelSize().height
		local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height

		y = ypos + SKILLCELL_WIDTH
		if ypos == 0 then
			y = (ph - th) * 0.5
		else
			if y + th > ph then
				if y > th then
					y = y - th
				else
					y = ph - th
				end
			end
		end
	end

	if x and y then
		self.m_bg:setPosition(NewVector2(x, y))
	elseif x then
		self.m_bg:setXPosition(CEGUI.UDim(0, x))
	elseif y then
		self.m_bg:setYPosition(CEGUI.UDim(0, y))
	end

	self.willCheckTipsWnd = false
end

function PetSkillTipsDlg:leftTimeToString(lefttime)
	if lefttime < 0 then
		return MHSD_UTILS.get_resstring(2161) --已到期
	end

	local day = math.floor(lefttime/1000) / (24*3600)
	local hour = math.floor((math.floor(lefttime/1000) % (24*3600)) / 3600)

	local str = MHSD_UTILS.get_resstring(2162) --剩余:
	if day == 0 and hour == 0 then
		return str .. MHSD_UTILS.get_resstring(2163) --不足一小时
	end

	if day >= 1 then
		return str .. day .. MHSD_UTILS.get_resstring(2164) --天
	end

	return str .. hour .. MHSD_UTILS.get_resstring(2165) --小时
end

return PetSkillTipsDlg

require "logic.dialog"

PetPropertyInBattleDlg = {}
setmetatable(PetPropertyInBattleDlg, Dialog)
PetPropertyInBattleDlg.__index = PetPropertyInBattleDlg

local _instance
function PetPropertyInBattleDlg.getInstance()
	if not _instance then
		_instance = PetPropertyInBattleDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetPropertyInBattleDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetPropertyInBattleDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetPropertyInBattleDlg.getInstanceNotCreate()
	return _instance
end

function PetPropertyInBattleDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetPropertyInBattleDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetPropertyInBattleDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetPropertyInBattleDlg.GetLayoutFileName()
	return "battlechongwuxiangqing.layout"
end

function PetPropertyInBattleDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetPropertyInBattleDlg)
	return self
end

function PetPropertyInBattleDlg:OnCreate()
	Dialog.OnCreate(self)
  --  SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_petName = winMgr:getWindow("battlechongwuxiangqing/taitou/text")
    self.m_petSprite = winMgr:getWindow("battlechongwuxiangqing/ditu/tu")
    self.m_SM_Text = winMgr:getWindow("battlechongwuxiangqing/diban/2")  --生命
    self.m_GJ_Text = winMgr:getWindow("battlechongwuxiangqing/diban/1")    --攻击
    self.m_FY_Text = winMgr:getWindow("battlechongwuxiangqing/diban/3")   --防御
    self.m_FG_Text = winMgr:getWindow("battlechongwuxiangqing/diban/21") --法攻
    self.m_FF_Text = winMgr:getWindow("battlechongwuxiangqing/diban/22") --法防
    self.m_SD_Text = winMgr:getWindow("battlechongwuxiangqing/diban/4")   --速度
	self.m_dj_Text = winMgr:getWindow("battlechongwuxiangqing/taitou/text1")
    
	
	self.skillTypeTabBtn1 = CEGUI.toGroupButton(winMgr:getWindow("battlechongwuxiangqing/jiemian/skill"))
	self.skillTypeTabBtn2 = CEGUI.toGroupButton(winMgr:getWindow("battlechongwuxiangqing/jiemian/neidan"))
	
	self.skillpanel = winMgr:getWindow("battlechongwuxiangqing/jineng/dis/list")
	self.neidanpanel = winMgr:getWindow("battlechongwuxiangqing/jineng/dis/list1")
	
	self.skillTypeTabBtn1:subscribeEvent("SelectStateChanged", PetPropertyInBattleDlg.handleSwitchSkillTypeTab, self)
	self.skillTypeTabBtn2:subscribeEvent("SelectStateChanged", PetPropertyInBattleDlg.handleSwitchSkillTypeTab, self)
	
	
    
    self.petScroll = CEGUI.toScrollablePane(winMgr:getWindow("battlechongwuxiangqing/jineng/dis/list"))
    self.neidanscroll = CEGUI.toScrollablePane(winMgr:getWindow("battlechongwuxiangqing/jineng/dis/list1"))
	
    self.skillBoxes = {}
	for i=1, 25 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("battlechongwuxiangqing/diban/skillbox"..i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", PetPropertyInBattleDlg.handleSkillClicked, self)
        self.petScroll:EnableChildDrag(self.skillBoxes[i])
	end
	
	self.neidanBoxes = {}
	for i=1,7 do
		self.neidanBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("battlechongwuxiangqing/neidanscroll/skill" .. i))
		self.neidanBoxes[i]:subscribeEvent("MouseClick", PetPropertyInBattleDlg.handleSkillClicked, self)
		self.neidanscroll:EnableAllChildDrag(self.neidanscroll)
		
	end
	self.neidanBoxes[7]:setVisible(false)
end

function PetPropertyInBattleDlg:handleSwitchSkillTypeTab()
	local selectedBtn = self.skillTypeTabBtn1:getSelectedButtonInGroup()
	
	if self.skillTypeTabBtn1 == selectedBtn then
		if not self.skillpanel:isVisible() then
			self.skillpanel:setVisible(true)
			self.neidanpanel:setVisible(false)
		end
	else
		if not self.neidanpanel:isVisible() then
			self.skillpanel:setVisible(false)
			self.neidanpanel:setVisible(true)
		end
	end
end

function PetPropertyInBattleDlg:refreshPetData(petKey)
    local petData = MainPetDataManager.getInstance():FindMyPetByID(petKey)
    self:refreshPetSprite(petData.baseid)
    self.m_petName:setText(petData.name)

    self.m_SM_Text:setText(tostring(petData:getAttribute(fire.pb.attr.AttrType.MAX_HP)))
    self.m_GJ_Text:setText(tostring(petData:getAttribute(fire.pb.attr.AttrType.ATTACK)))
    self.m_FY_Text:setText(tostring(petData:getAttribute(fire.pb.attr.AttrType.DEFEND)))
    self.m_FG_Text:setText(tostring(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_ATTACK)))
    self.m_FF_Text:setText(tostring(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_DEF)))
    self.m_SD_Text:setText(tostring(petData:getAttribute(fire.pb.attr.AttrType.SPEED)))
	self.m_dj_Text:setText(tostring(petData:getAttribute(fire.pb.attr.AttrType.LEVEL)))
    --self.levelText:setText("" .. petData:getAttribute(fire.pb.attr.AttrType.LEVEL))---等级
	
    local skillnum = (petData and petData:getSkilllistlen() or 0)
    for i = 1, 25 do
        self.skillBoxes[i]:Clear()
        if i <= skillnum then
            local skill = petData:getSkill(i)
            SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petData, true, skill.certification)
        end
    end
	
	local neidannum = (petData and petData:getInternallistlen() or 0)
	self.neidanBoxes[7]:setVisible(neidannum==7)
	for i = 1, 7 do
		self.neidanBoxes[i]:Clear()
		if i <= neidannum then
			local neidan = petData:getInternal(i)
			SetPetSkillBoxInfond(self.neidanBoxes[i], neidan.skillid, petData, true, neidan.certification)
		end
	end
	
end

function PetPropertyInBattleDlg:refreshPetSprite(petID)
    local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petID)
    if not petAttrCfg then
        return
    end

	if not self.sprite then
		local s = self.m_petSprite:getPixelSize()
		self.sprite = gGetGameUIManager():AddWindowSprite(self.m_petSprite, petAttrCfg.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, false)
	else
		self.sprite:SetModel(petAttrCfg.modelid)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end
    self.sprite:SetDyePartIndex(0,petAttrCfg.area1colour)
    self.sprite:SetDyePartIndex(1,petAttrCfg.area2colour)
end

function PetPropertyInBattleDlg:handleSkillClicked(args)
    local wnd = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if wnd:GetSkillID() == 0 then
		return
	end
	local pos = wnd:GetScreenPos()
	PetSkillTipsDlg.ShowTip(wnd:GetSkillID(),pos.x, pos.y)
end

return PetPropertyInBattleDlg
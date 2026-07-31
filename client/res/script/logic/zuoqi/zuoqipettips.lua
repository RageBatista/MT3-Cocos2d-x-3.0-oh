------------------------------------------------------------------
-- ���＼��tip
------------------------------------------------------------------
require "logic.dialog"

ZuoQiPetTips = {}
setmetatable(ZuoQiPetTips, Dialog)
ZuoQiPetTips.__index = ZuoQiPetTips

local SKILLCELL_WIDTH = 38

local _instance
function ZuoQiPetTips.getInstance()
	if not _instance then
		_instance = ZuoQiPetTips:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZuoQiPetTips.getInstanceAndShow()
	if not _instance then
		_instance = ZuoQiPetTips:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZuoQiPetTips.getInstanceNotCreate()
	return _instance
end

function ZuoQiPetTips.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZuoQiPetTips.ToggleOpenClose()
	if not _instance then
		_instance = ZuoQiPetTips:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZuoQiPetTips.GetLayoutFileName()
	return "zuoqipettips.layout"
end

function ZuoQiPetTips:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZuoQiPetTips)
	return self
end
function ZuoQiPetTips:handleSkillClicked(args)
	--打内丹
	local wnd = CEGUI.toWindowEventArgs(args).window
	local idx = wnd:getID()

	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)

	if cell:GetSkillID() ~= 0 then
		local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())

		PetSkillTipsDlg.GetPetData(self.selectedPetKey,idx)
		local s = GetScreenSize()
		SetPositionOffset(tip:GetWindow(), s.width*0.5, s.height*0.5, 1, 0.5)
	end

end
function ZuoQiPetTips:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_bg = winMgr:getWindow("zuoqipettips")
	self.petSkillName = winMgr:getWindow("zuoqipettips/name")
	self.petSkillIcon = CEGUI.toItemCell(winMgr:getWindow("zuoqipettips/icon"))

	self.tihuan = CEGUI.toPushButton(winMgr:getWindow( "zuoqipettips/tihuan"))
	self.quxia = CEGUI.toPushButton(winMgr:getWindow( "zuoqipettips/quxia"))
	self.zuoqiname = winMgr:getWindow("zuoqipettips/zuoqiname")
	
	self.close = winMgr:getWindow("zuoqipettips/x")
	self.close:subscribeEvent("MouseClick", self.DestroyDialog, nil)

	self.tihuan:subscribeEvent("MouseClick", ZuoQiPetTips.handletihuanClicked, self)
	self.quxia:subscribeEvent("MouseClick", ZuoQiPetTips.handlequxiaClicked, self)
	self.skillBoxes = {}
	for i=1,25 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("zuoqipettips/Skill" .. i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", ZuoQiPetTips.handleSkillClicked, self)
		self.skillBoxes[i]:SetBackGroupOnTop(true)
	end


	self.triggerWnd = nil
	self.skillid = 0
	self.duedate = 0
	self.data = nil
	self.index = 0
	self.zuoqiid = 0
	self.petkey = 0


end
function ZuoQiPetTips:handletihuanClicked(args)
	require "logic.zuoqi.zuoqicell2":GetSingletonDialogAndShowIt(self.index,self.zuoqiid,self.data,self.petkey)
	self:DestroyDialog();
	return true
end
function ZuoQiPetTips:handlequxiaClicked(args)


	local p = require "logic.zuoqi.czuoqizyshiyong":new()
	p.zuoqiid = self.zuoqiid--normal
	p.idx = 6--normal
	p.index = self.index--normal
	p.key = self.petkey--normal
	require "manager.luaprotocolmanager":send(p)

	self:DestroyDialog();

	return true
end



function ZuoQiPetTips.ShowTip(data,index,zuoqiid)
	ZuoQiPetTips.getInstanceAndShow()
	_instance:showSkillTips(data,index,zuoqiid)
	return _instance
end
function ZuoQiPetTips:showSkillTips(data,index,zuoqiid)
	_instance.index=index
	_instance.data=data
	_instance.zuoqiid=zuoqiid

	local petData = MainPetDataManager.getInstance():FindMyPetByID(data.petkey[index])
	_instance.petkey=petData.key
	self.petSkillName:setText(petData.name)
	SetPetItemCellInfo2(self.petSkillIcon, petData)


	local zuoqiidx=0
	for k,v in pairs(data.petkeys) do
		for key,value in pairs(v.petkeys) do
			if petData.key==value then
				zuoqiidx=key
				break
			end
		end
	end

	local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(zuoqiidx)

	self.zuoqiname:setText(itemattr.name)






	local skillnum = (petData and petData:getSkilllistlen() or 0)
	--self.skillBoxes[PET_SKILL_ALLCOUNT]:setVisible(skillnum==PET_SKILL_ALLCOUNT)
	for i = 1, 25 do
		self.skillBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
			local isSkillBind = petData:isSkillBind(skill.skillid)
			SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petData, true, skill.certification, isSkillBind)
		end
	end
end

function ZuoQiPetTips:leftTimeToString(lefttime)
	if lefttime < 0 then
		return MHSD_UTILS.get_resstring(2161) --�ѵ���
	end

	local day = math.floor(lefttime/1000) / (24*3600)
	local hour = math.floor((math.floor(lefttime/1000) % (24*3600)) / 3600)

	local str = MHSD_UTILS.get_resstring(2162) --ʣ��:
	if day == 0 and hour == 0 then
		return str .. MHSD_UTILS.get_resstring(2163) --����һСʱ
	end

	if day >= 1 then
		return str .. day .. MHSD_UTILS.get_resstring(2164) --��
	end

	return str .. hour .. MHSD_UTILS.get_resstring(2165) --Сʱ
end

return ZuoQiPetTips

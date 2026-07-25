require "logic.dialog"
require "logic.pet.petlabel"

deathNoteDlg = {}
setmetatable(deathNoteDlg, Dialog)
deathNoteDlg.__index = deathNoteDlg

local _instance
function deathNoteDlg.getInstance()
	if not _instance then
		_instance = deathNoteDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function deathNoteDlg.getInstanceAndShow()
	if not _instance then
		_instance = deathNoteDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function deathNoteDlg.getInstanceNotCreate()
	return _instance
end

function deathNoteDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function deathNoteDlg.ToggleOpenClose()
	if not _instance then
		_instance = deathNoteDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function deathNoteDlg.GetLayoutFileName()
	return "warndilalog_mtg.layout"
end

function deathNoteDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, deathNoteDlg)
	return self
end
-- 初始化要显示的图标列表
function deathNoteDlg:initNoteTable()
local tableAllId = BeanConfigManager.getInstance():GetTableByName("game.cdeathnote"):getAllID()
	for _, v in pairs(tableAllId) do
		local noteInfo = BeanConfigManager.getInstance():GetTableByName("game.cdeathnote"):getRecorder(v)
		if gGetDataManager():GetMainCharacterLevel() >= noteInfo.level and XinGongNengOpenDLG.checkFeatureOpened(noteInfo.functionId) then
			if #self.noteTable >= 4 then
				self:resetNoteTable()
			end
			self.noteTable[#self.noteTable + 1] = noteInfo.id
		end
	end
	
end
-- 删除不显示的图标列表
function deathNoteDlg:resetNoteTable()
	local tableSize = #self.noteTable
	for i = 1, tableSize do
		self.noteTable[i] = self.noteTable[i+1]
	end
	--table.remove(self.noteTable, #self.noteTable)
end

function deathNoteDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pBtn = {}
	self.m_tText = {}
		
	self.mask = winMgr:getWindow("warndilalog_mtg/mask")
	self.m_pBtn[1] = CEGUI.toPushButton(winMgr:getWindow("warndilalog_mtg/button1"))
	self.m_pBtn[2] = CEGUI.toPushButton(winMgr:getWindow("warndilalog_mtg/button2"))
	self.m_pBtn[3] = CEGUI.toPushButton(winMgr:getWindow("warndilalog_mtg/button3"))
	self.m_pBtn[4] = CEGUI.toPushButton(winMgr:getWindow("warndilalog_mtg/button4"))
	self.m_tText[1] = winMgr:getWindow("warndilalog_mtg/text1")
	self.m_tText[2] = winMgr:getWindow("warndilalog_mtg/text2")
	self.m_tText[3] = winMgr:getWindow("warndilalog_mtg/text3")
	self.m_tText[4] = winMgr:getWindow("warndilalog_mtg/text4")
	self.m_pBtn[1]:setVisible(false)
	self.m_pBtn[2]:setVisible(false)
	self.m_pBtn[3]:setVisible(false)
	self.m_pBtn[4]:setVisible(false)
	
	self.noteTable = {}
	self:initNoteTable()
	self:initBtnInfo()
		
	self.mask:subscribeEvent("MouseClick", deathNoteDlg.maskClickedCallBack, self)
	for i = 1, #self.noteTable do
		self.m_pBtn[i]:setVisible(true)
		self.m_pBtn[i]:setID(i)
		self.m_pBtn[i]:subscribeEvent("Clicked", deathNoteDlg.btnClickedCallBack, self)
	end

end

function deathNoteDlg:maskClickedCallBack(e)
	print("maskClickedCallBack")
	--GetMainCharacter():setMovingStat(true) 
	deathNoteDlg.DestroyDialog()
end

-- eventId 对应跳转
-- 1 技能
-- 2 升级
-- 3 助战
-- 4 队伍
-- 5 宠物
-- 6 装备强化
-- 7 装备打造
-- 8 修炼
-- 9 宝石镶嵌
function deathNoteDlg:initBtnInfo()
	self._eventId = {} 
	for i = 1, #self.noteTable do
		local noteInfo = BeanConfigManager.getInstance():GetTableByName("game.cdeathnote"):getRecorder(self.noteTable[i])
		if noteInfo then
			self.m_pBtn[i]:setProperty("NormalImage", noteInfo.icon)
			self.m_pBtn[i]:setProperty("PushedImage", noteInfo.icon)
			self.m_tText[i]:setText(noteInfo.text)
			self._eventId[i] = noteInfo.eventId  
		end
	end
end

function deathNoteDlg:btnClickedCallBack(args)
	local e = CEGUI.toWindowEventArgs(args)
	local curID = e.window:getID()
	local curBtn = self.m_pBtn[curID]
    self:GetWindow():setProperty("AllowModalStateClick", "False")
	if self._eventId[curID] == 1 then     -- 技能
		CharacterSkillUpdateDlg.getInstanceAndShow()
		SkillLable.Show(1)
	elseif self._eventId[curID] == 2 then -- 升级
		if not require "logic.xingongnengkaiqi.xingongnengopendlg".checkFeatureOpened(5) then
			GetCTipsManager():AddMessageTipById(160011)
		else 
            LogoInfoDialog.openHuoDongDlg()
		end
	elseif self._eventId[curID] == 3 then -- 助战
		HuoBanZhuZhanDialog.getInstanceAndShow()
	elseif self._eventId[curID] == 4 then -- 队伍
		TeamDialogNew.getInstanceAndShow()
	elseif self._eventId[curID] == 5 then -- 宠物
		PetLabel.Show()
	elseif self._eventId[curID] == 6 then 
		require "logic.workshop.workshoplabel".Show(1)
	elseif self._eventId[curID] == 7 then 
		require "logic.workshop.workshoplabel".Show(2)
	elseif self._eventId[curID] == 8 then -- 修炼
		--XiulianSkillDlg.getInstanceAndShow()
		SkillLable.Show(3)
	elseif self._eventId[curID] == 9 then 
		require "logic.workshop.workshoplabel".Show(3)
	end
end

return deathNoteDlg

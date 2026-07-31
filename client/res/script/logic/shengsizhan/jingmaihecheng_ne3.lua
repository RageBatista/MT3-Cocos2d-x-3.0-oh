require "logic.dialog"

jingmaihecheng_ne3 = {}
setmetatable(jingmaihecheng_ne3, Dialog)
jingmaihecheng_ne3.__index = jingmaihecheng_ne3

local _instance
function jingmaihecheng_ne3.getInstance()
	if not _instance then
		_instance = jingmaihecheng_ne3:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_ne3.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_ne3:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_ne3.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_ne3.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_ne3.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_ne3:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_ne3.GetLayoutFileName()
	return "jingmaihecheng_ne.layout"
end

function jingmaihecheng_ne3:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_ne3)
	return self
end

function jingmaihecheng_ne3:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_ne3:OnCreate()
    LogInfo("jingmaihecheng_ne oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1ne1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/ne1"))
	self.m_hc1ne2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/ne2"))
	self.m_hc1ne3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/ne3"))
	self.m_hc1ne4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/ne4"))
	self.m_hc1ne5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/ne5"))
	self.m_hc1ne6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/ne6"))
	self.m_hc1ne7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/ne7"))
	self.m_hc1ne8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/ne8"))
	self.m_nebiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/nebiaoti1"))
	self.m_nebiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/nebiaoti2"))
	self.m_nebiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/nebiaoti3"))
	self.m_nebiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/nebiaoti4"))
	self.m_nebiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/nebiaoti5"))
	self.m_nebiaoti1:setVisible(false)
	self.m_nebiaoti2:setVisible(false)
	self.m_nebiaoti4:setVisible(false)
	self.m_nebiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ne/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1ne1:subscribeEvent("Clicked", jingmaihecheng_ne3.hc1ne1, self)
	self.m_hc1ne2:subscribeEvent("Clicked", jingmaihecheng_ne3.hc1ne2, self)
	self.m_hc1ne3:subscribeEvent("Clicked", jingmaihecheng_ne3.hc1ne3, self)
	self.m_hc1ne4:subscribeEvent("Clicked", jingmaihecheng_ne3.hc1ne4, self)
	self.m_hc1ne5:subscribeEvent("Clicked", jingmaihecheng_ne3.hc1ne5, self)
	self.m_hc1ne6:subscribeEvent("Clicked", jingmaihecheng_ne3.hc1ne6, self)
	self.m_hc1ne7:subscribeEvent("Clicked", jingmaihecheng_ne3.hc1ne7, self)
	self.m_hc1ne8:subscribeEvent("Clicked", jingmaihecheng_ne3.hc1ne8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_ne3.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1ne1 = 8022031
TaskHelper.m_hc1ne2 = 8022032
TaskHelper.m_hc1ne3 = 8022033
TaskHelper.m_hc1ne4 = 8022034
TaskHelper.m_hc1ne5 = 8022035
TaskHelper.m_hc1ne6 = 8022036
TaskHelper.m_hc1ne7 = 8022037
TaskHelper.m_hc1ne8 = 8022038

-- function jingmaihecheng_ne3:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_ne3:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_ne3:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_ne3:jingmaibeibao(args)
    LogInfo("maincontrol pack button clicked")

    -- �����˵��ر���������
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():OnClose()
    end
	CMainPackLabelDlg:GetSingletonDialogAndShowIt():Show()
    self.m_fAutoHideTime = 0

   local Taskuseitemdialog = require("logic.task.taskuseitemdialog")
   local useItemDlg = Taskuseitemdialog.getInstanceNotCreate()
   if useItemDlg then
      if useItemDlg.nType == Taskuseitemdialog.eUseType.chuanzhuangbei then
            Taskuseitemdialog.DestroyDialog()
      end
   end
    return true
end


function jingmaihecheng_ne3.hc1ne1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1ne1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ne3.hc1ne2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1ne2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ne3.hc1ne3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1ne3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ne3.hc1ne4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1ne4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ne3.hc1ne5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1ne5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ne3.hc1ne6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1ne6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ne3.hc1ne7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1ne7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ne3.hc1ne8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1ne8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_ne3

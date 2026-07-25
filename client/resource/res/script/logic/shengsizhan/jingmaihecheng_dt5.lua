require "logic.dialog"

jingmaihecheng_dt5 = {}
setmetatable(jingmaihecheng_dt5, Dialog)
jingmaihecheng_dt5.__index = jingmaihecheng_dt5

local _instance
function jingmaihecheng_dt5.getInstance()
	if not _instance then
		_instance = jingmaihecheng_dt5:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_dt5.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_dt5:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_dt5.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_dt5.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_dt5.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_dt5:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_dt5.GetLayoutFileName()
	return "jingmaihecheng_dt.layout"
end

function jingmaihecheng_dt5:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_dt5)
	return self
end

function jingmaihecheng_dt5:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_dt5:OnCreate()
    LogInfo("jingmaihecheng_dt oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1dt1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt1"))
	self.m_hc1dt2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt2"))
	self.m_hc1dt3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt3"))
	self.m_hc1dt4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt4"))
	self.m_hc1dt5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt5"))
	self.m_hc1dt6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt6"))
	self.m_hc1dt7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt7"))
	self.m_hc1dt8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt8"))
	self.m_dtbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dtbiaoti1"))
	self.m_dtbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dtbiaoti2"))
	self.m_dtbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dtbiaoti3"))
	self.m_dtbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dtbiaoti4"))
	self.m_dtbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dtbiaoti5"))
	self.m_dtbiaoti1:setVisible(false)
	self.m_dtbiaoti2:setVisible(false)
	self.m_dtbiaoti3:setVisible(false)
	self.m_dtbiaoti4:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1dt1:subscribeEvent("Clicked", jingmaihecheng_dt5.hc1dt1, self)
	self.m_hc1dt2:subscribeEvent("Clicked", jingmaihecheng_dt5.hc1dt2, self)
	self.m_hc1dt3:subscribeEvent("Clicked", jingmaihecheng_dt5.hc1dt3, self)
	self.m_hc1dt4:subscribeEvent("Clicked", jingmaihecheng_dt5.hc1dt4, self)
	self.m_hc1dt5:subscribeEvent("Clicked", jingmaihecheng_dt5.hc1dt5, self)
	self.m_hc1dt6:subscribeEvent("Clicked", jingmaihecheng_dt5.hc1dt6, self)
	self.m_hc1dt7:subscribeEvent("Clicked", jingmaihecheng_dt5.hc1dt7, self)
	self.m_hc1dt8:subscribeEvent("Clicked", jingmaihecheng_dt5.hc1dt8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_dt5.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1dt1 = 8011051
TaskHelper.m_hc1dt2 = 8011052
TaskHelper.m_hc1dt3 = 8011053
TaskHelper.m_hc1dt4 = 8011054
TaskHelper.m_hc1dt5 = 8011055
TaskHelper.m_hc1dt6 = 8011056
TaskHelper.m_hc1dt7 = 8011057
TaskHelper.m_hc1dt8 = 8011058

-- function jingmaihecheng_dt5:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_dt5:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_dt5:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_dt5:jingmaibeibao(args)
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


function jingmaihecheng_dt5.hc1dt1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt5.hc1dt2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt5.hc1dt3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt5.hc1dt4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt5.hc1dt5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt5.hc1dt6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt5.hc1dt7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt5.hc1dt8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_dt5

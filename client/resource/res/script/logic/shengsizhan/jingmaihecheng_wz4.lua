require "logic.dialog"

jingmaihecheng_wz4 = {}
setmetatable(jingmaihecheng_wz4, Dialog)
jingmaihecheng_wz4.__index = jingmaihecheng_wz4

local _instance
function jingmaihecheng_wz4.getInstance()
	if not _instance then
		_instance = jingmaihecheng_wz4:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_wz4.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_wz4:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_wz4.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_wz4.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_wz4.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_wz4:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_wz4.GetLayoutFileName()
	return "jingmaihecheng_wz.layout"
end

function jingmaihecheng_wz4:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_wz4)
	return self
end

function jingmaihecheng_wz4:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_wz4:OnCreate()
    LogInfo("jingmaihecheng_wz oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1wz1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wz1"))
	self.m_hc1wz2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wz2"))
	self.m_hc1wz3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wz3"))
	self.m_hc1wz4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wz4"))
	self.m_hc1wz5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wz5"))
	self.m_hc1wz6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wz6"))
	self.m_hc1wz7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wz7"))
	self.m_hc1wz8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wz8"))
	self.m_wzbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wzbiaoti1"))
	self.m_wzbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wzbiaoti2"))
	self.m_wzbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wzbiaoti3"))
	self.m_wzbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wzbiaoti4"))
	self.m_wzbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/wzbiaoti5"))
	self.m_wzbiaoti1:setVisible(false)
	self.m_wzbiaoti2:setVisible(false)
	self.m_wzbiaoti3:setVisible(false)
	self.m_wzbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_wz/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1wz1:subscribeEvent("Clicked", jingmaihecheng_wz4.hc1wz1, self)
	self.m_hc1wz2:subscribeEvent("Clicked", jingmaihecheng_wz4.hc1wz2, self)
	self.m_hc1wz3:subscribeEvent("Clicked", jingmaihecheng_wz4.hc1wz3, self)
	self.m_hc1wz4:subscribeEvent("Clicked", jingmaihecheng_wz4.hc1wz4, self)
	self.m_hc1wz5:subscribeEvent("Clicked", jingmaihecheng_wz4.hc1wz5, self)
	self.m_hc1wz6:subscribeEvent("Clicked", jingmaihecheng_wz4.hc1wz6, self)
	self.m_hc1wz7:subscribeEvent("Clicked", jingmaihecheng_wz4.hc1wz7, self)
	self.m_hc1wz8:subscribeEvent("Clicked", jingmaihecheng_wz4.hc1wz8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_wz4.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1wz1 = 8021041
TaskHelper.m_hc1wz2 = 8021042
TaskHelper.m_hc1wz3 = 8021043
TaskHelper.m_hc1wz4 = 8021044
TaskHelper.m_hc1wz5 = 8021045
TaskHelper.m_hc1wz6 = 8021046
TaskHelper.m_hc1wz7 = 8021047
TaskHelper.m_hc1wz8 = 8021048

-- function jingmaihecheng_wz4:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_wz4:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_wz4:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_wz4:jingmaibeibao(args)
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


function jingmaihecheng_wz4.hc1wz1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1wz1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_wz4.hc1wz2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1wz2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_wz4.hc1wz3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1wz3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_wz4.hc1wz4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1wz4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_wz4.hc1wz5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1wz5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_wz4.hc1wz6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1wz6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_wz4.hc1wz7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1wz7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_wz4.hc1wz8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1wz8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_wz4

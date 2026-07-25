require "logic.dialog"

jingmaihecheng_mw1 = {}
setmetatable(jingmaihecheng_mw1, Dialog)
jingmaihecheng_mw1.__index = jingmaihecheng_mw1

local _instance
function jingmaihecheng_mw1.getInstance()
	if not _instance then
		_instance = jingmaihecheng_mw1:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_mw1.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_mw1:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_mw1.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_mw1.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_mw1.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_mw1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_mw1.GetLayoutFileName()
	return "jingmaihecheng_mw.layout"
end

function jingmaihecheng_mw1:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_mw1)
	return self
end

function jingmaihecheng_mw1:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_mw1:OnCreate()
    LogInfo("jingmaihecheng_mw oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1mw1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mw1"))
	self.m_hc1mw2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mw2"))
	self.m_hc1mw3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mw3"))
	self.m_hc1mw4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mw4"))
	self.m_hc1mw5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mw5"))
	self.m_hc1mw6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mw6"))
	self.m_hc1mw7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mw7"))
	self.m_hc1mw8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mw8"))
	self.m_mwbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mwbiaoti1"))
	self.m_mwbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mwbiaoti2"))
	self.m_mwbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mwbiaoti3"))
	self.m_mwbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mwbiaoti4"))
	self.m_mwbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/mwbiaoti5"))
	self.m_mwbiaoti2:setVisible(false)
	self.m_mwbiaoti3:setVisible(false)
	self.m_mwbiaoti4:setVisible(false)
	self.m_mwbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_mw/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1mw1:subscribeEvent("Clicked", jingmaihecheng_mw1.hc1mw1, self)
	self.m_hc1mw2:subscribeEvent("Clicked", jingmaihecheng_mw1.hc1mw2, self)
	self.m_hc1mw3:subscribeEvent("Clicked", jingmaihecheng_mw1.hc1mw3, self)
	self.m_hc1mw4:subscribeEvent("Clicked", jingmaihecheng_mw1.hc1mw4, self)
	self.m_hc1mw5:subscribeEvent("Clicked", jingmaihecheng_mw1.hc1mw5, self)
	self.m_hc1mw6:subscribeEvent("Clicked", jingmaihecheng_mw1.hc1mw6, self)
	self.m_hc1mw7:subscribeEvent("Clicked", jingmaihecheng_mw1.hc1mw7, self)
	self.m_hc1mw8:subscribeEvent("Clicked", jingmaihecheng_mw1.hc1mw8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_mw1.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1mw1 = 8017011
TaskHelper.m_hc1mw2 = 8017012
TaskHelper.m_hc1mw3 = 8017013
TaskHelper.m_hc1mw4 = 8017014
TaskHelper.m_hc1mw5 = 8017015
TaskHelper.m_hc1mw6 = 8017016
TaskHelper.m_hc1mw7 = 8017017
TaskHelper.m_hc1mw8 = 8017018

-- function jingmaihecheng_mw1:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_mw1:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_mw1:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_mw1:jingmaibeibao(args)
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


function jingmaihecheng_mw1.hc1mw1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1mw1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_mw1.hc1mw2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1mw2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_mw1.hc1mw3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1mw3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_mw1.hc1mw4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1mw4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_mw1.hc1mw5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1mw5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_mw1.hc1mw6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1mw6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_mw1.hc1mw7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1mw7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_mw1.hc1mw8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1mw8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_mw1

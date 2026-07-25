require "logic.dialog"

jingmaihecheng_fc4 = {}
setmetatable(jingmaihecheng_fc4, Dialog)
jingmaihecheng_fc4.__index = jingmaihecheng_fc4

local _instance
function jingmaihecheng_fc4.getInstance()
	if not _instance then
		_instance = jingmaihecheng_fc4:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_fc4.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_fc4:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_fc4.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_fc4.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_fc4.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_fc4:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_fc4.GetLayoutFileName()
	return "jingmaihecheng_fc.layout"
end

function jingmaihecheng_fc4:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_fc4)
	return self
end

function jingmaihecheng_fc4:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_fc4:OnCreate()
    LogInfo("jingmaihecheng_fc oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1fc1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fc1"))
	self.m_hc1fc2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fc2"))
	self.m_hc1fc3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fc3"))
	self.m_hc1fc4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fc4"))
	self.m_hc1fc5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fc5"))
	self.m_hc1fc6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fc6"))
	self.m_hc1fc7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fc7"))
	self.m_hc1fc8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fc8"))
	self.m_fcbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fcbiaoti1"))
	self.m_fcbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fcbiaoti2"))
	self.m_fcbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fcbiaoti3"))
	self.m_fcbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fcbiaoti4"))
	self.m_fcbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fcbiaoti5"))
	self.m_fcbiaoti1:setVisible(false)
	self.m_fcbiaoti2:setVisible(false)
	self.m_fcbiaoti3:setVisible(false)
	self.m_fcbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1fc1:subscribeEvent("Clicked", jingmaihecheng_fc4.hc1fc1, self)
	self.m_hc1fc2:subscribeEvent("Clicked", jingmaihecheng_fc4.hc1fc2, self)
	self.m_hc1fc3:subscribeEvent("Clicked", jingmaihecheng_fc4.hc1fc3, self)
	self.m_hc1fc4:subscribeEvent("Clicked", jingmaihecheng_fc4.hc1fc4, self)
	self.m_hc1fc5:subscribeEvent("Clicked", jingmaihecheng_fc4.hc1fc5, self)
	self.m_hc1fc6:subscribeEvent("Clicked", jingmaihecheng_fc4.hc1fc6, self)
	self.m_hc1fc7:subscribeEvent("Clicked", jingmaihecheng_fc4.hc1fc7, self)
	self.m_hc1fc8:subscribeEvent("Clicked", jingmaihecheng_fc4.hc1fc8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_fc4.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1fc1 = 8012041
TaskHelper.m_hc1fc2 = 8012042
TaskHelper.m_hc1fc3 = 8012043
TaskHelper.m_hc1fc4 = 8012044
TaskHelper.m_hc1fc5 = 8012045
TaskHelper.m_hc1fc6 = 8012046
TaskHelper.m_hc1fc7 = 8012047
TaskHelper.m_hc1fc8 = 8012048

-- function jingmaihecheng_fc4:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_fc4:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_fc4:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_fc4:jingmaibeibao(args)
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


function jingmaihecheng_fc4.hc1fc1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1fc1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc4.hc1fc2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1fc2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc4.hc1fc3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1fc3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc4.hc1fc4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1fc4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc4.hc1fc5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1fc5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc4.hc1fc6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1fc6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc4.hc1fc7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1fc7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc4.hc1fc8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1fc8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_fc4

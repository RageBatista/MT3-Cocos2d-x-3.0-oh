require "logic.dialog"

jingmaihecheng_yg5 = {}
setmetatable(jingmaihecheng_yg5, Dialog)
jingmaihecheng_yg5.__index = jingmaihecheng_yg5

local _instance
function jingmaihecheng_yg5.getInstance()
	if not _instance then
		_instance = jingmaihecheng_yg5:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_yg5.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_yg5:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_yg5.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_yg5.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_yg5.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_yg5:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_yg5.GetLayoutFileName()
	return "jingmaihecheng_yg.layout"
end

function jingmaihecheng_yg5:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_yg5)
	return self
end

function jingmaihecheng_yg5:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_yg5:OnCreate()
    LogInfo("jingmaihecheng_yg oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1yg1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/yg1"))
	self.m_hc1yg2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/yg2"))
	self.m_hc1yg3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/yg3"))
	self.m_hc1yg4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/yg4"))
	self.m_hc1yg5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/yg5"))
	self.m_hc1yg6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/yg6"))
	self.m_hc1yg7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/yg7"))
	self.m_hc1yg8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/yg8"))
	self.m_ygbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/ygbiaoti1"))
	self.m_ygbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/ygbiaoti2"))
	self.m_ygbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/ygbiaoti3"))
	self.m_ygbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/ygbiaoti4"))
	self.m_ygbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/ygbiaoti5"))
	self.m_ygbiaoti1:setVisible(false)
	self.m_ygbiaoti2:setVisible(false)
	self.m_ygbiaoti3:setVisible(false)
	self.m_ygbiaoti4:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1yg1:subscribeEvent("Clicked", jingmaihecheng_yg5.hc1yg1, self)
	self.m_hc1yg2:subscribeEvent("Clicked", jingmaihecheng_yg5.hc1yg2, self)
	self.m_hc1yg3:subscribeEvent("Clicked", jingmaihecheng_yg5.hc1yg3, self)
	self.m_hc1yg4:subscribeEvent("Clicked", jingmaihecheng_yg5.hc1yg4, self)
	self.m_hc1yg5:subscribeEvent("Clicked", jingmaihecheng_yg5.hc1yg5, self)
	self.m_hc1yg6:subscribeEvent("Clicked", jingmaihecheng_yg5.hc1yg6, self)
	self.m_hc1yg7:subscribeEvent("Clicked", jingmaihecheng_yg5.hc1yg7, self)
	self.m_hc1yg8:subscribeEvent("Clicked", jingmaihecheng_yg5.hc1yg8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_yg5.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1yg1 = 8018051
TaskHelper.m_hc1yg2 = 8018052
TaskHelper.m_hc1yg3 = 8018053
TaskHelper.m_hc1yg4 = 8018054
TaskHelper.m_hc1yg5 = 8018055
TaskHelper.m_hc1yg6 = 8018056
TaskHelper.m_hc1yg7 = 8018057
TaskHelper.m_hc1yg8 = 8018058

-- function jingmaihecheng_yg5:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_yg5:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_yg5:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_yg5:jingmaibeibao(args)
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


function jingmaihecheng_yg5.hc1yg1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg5.hc1yg2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg5.hc1yg3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg5.hc1yg4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg5.hc1yg5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg5.hc1yg6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg5.hc1yg7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg5.hc1yg8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_yg5

require "logic.dialog"

jingmaihecheng_lg5 = {}
setmetatable(jingmaihecheng_lg5, Dialog)
jingmaihecheng_lg5.__index = jingmaihecheng_lg5

local _instance
function jingmaihecheng_lg5.getInstance()
	if not _instance then
		_instance = jingmaihecheng_lg5:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_lg5.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_lg5:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_lg5.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_lg5.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_lg5.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_lg5:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_lg5.GetLayoutFileName()
	return "jingmaihecheng_lg.layout"
end

function jingmaihecheng_lg5:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_lg5)
	return self
end

function jingmaihecheng_lg5:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_lg5:OnCreate()
    LogInfo("jingmaihecheng_lg oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1lg1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lg1"))
	self.m_hc1lg2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lg2"))
	self.m_hc1lg3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lg3"))
	self.m_hc1lg4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lg4"))
	self.m_hc1lg5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lg5"))
	self.m_hc1lg6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lg6"))
	self.m_hc1lg7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lg7"))
	self.m_hc1lg8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lg8"))
	self.m_lgbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lgbiaoti1"))
	self.m_lgbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lgbiaoti2"))
	self.m_lgbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lgbiaoti3"))
	self.m_lgbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lgbiaoti4"))
	self.m_lgbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/lgbiaoti5"))
	self.m_lgbiaoti1:setVisible(false)
	self.m_lgbiaoti2:setVisible(false)
	self.m_lgbiaoti3:setVisible(false)
	self.m_lgbiaoti4:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_lg/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1lg1:subscribeEvent("Clicked", jingmaihecheng_lg5.hc1lg1, self)
	self.m_hc1lg2:subscribeEvent("Clicked", jingmaihecheng_lg5.hc1lg2, self)
	self.m_hc1lg3:subscribeEvent("Clicked", jingmaihecheng_lg5.hc1lg3, self)
	self.m_hc1lg4:subscribeEvent("Clicked", jingmaihecheng_lg5.hc1lg4, self)
	self.m_hc1lg5:subscribeEvent("Clicked", jingmaihecheng_lg5.hc1lg5, self)
	self.m_hc1lg6:subscribeEvent("Clicked", jingmaihecheng_lg5.hc1lg6, self)
	self.m_hc1lg7:subscribeEvent("Clicked", jingmaihecheng_lg5.hc1lg7, self)
	self.m_hc1lg8:subscribeEvent("Clicked", jingmaihecheng_lg5.hc1lg8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_lg5.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1lg1 = 8015051
TaskHelper.m_hc1lg2 = 8015052
TaskHelper.m_hc1lg3 = 8015053
TaskHelper.m_hc1lg4 = 8015054
TaskHelper.m_hc1lg5 = 8015055
TaskHelper.m_hc1lg6 = 8015056
TaskHelper.m_hc1lg7 = 8015057
TaskHelper.m_hc1lg8 = 8015058

-- function jingmaihecheng_lg5:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_lg5:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_lg5:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_lg5:jingmaibeibao(args)
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


function jingmaihecheng_lg5.hc1lg1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1lg1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_lg5.hc1lg2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1lg2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_lg5.hc1lg3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1lg3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_lg5.hc1lg4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1lg4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_lg5.hc1lg5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1lg5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_lg5.hc1lg6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1lg6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_lg5.hc1lg7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1lg7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_lg5.hc1lg8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1lg8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_lg5

require "logic.dialog"

jingmaihecheng_df2 = {}
setmetatable(jingmaihecheng_df2, Dialog)
jingmaihecheng_df2.__index = jingmaihecheng_df2

local _instance
function jingmaihecheng_df2.getInstance()
	if not _instance then
		_instance = jingmaihecheng_df2:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_df2.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_df2:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_df2.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_df2.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_df2.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_df2:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_df2.GetLayoutFileName()
	return "jingmaihecheng_df.layout"
end

function jingmaihecheng_df2:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_df2)
	return self
end

function jingmaihecheng_df2:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_df2:OnCreate()
    LogInfo("jingmaihecheng_df oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1df1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/df1"))
	self.m_hc1df2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/df2"))
	self.m_hc1df3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/df3"))
	self.m_hc1df4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/df4"))
	self.m_hc1df5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/df5"))
	self.m_hc1df6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/df6"))
	self.m_hc1df7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/df7"))
	self.m_hc1df8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/df8"))
	self.m_dfbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/dfbiaoti1"))
	self.m_dfbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/dfbiaoti2"))
	self.m_dfbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/dfbiaoti3"))
	self.m_dfbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/dfbiaoti4"))
	self.m_dfbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/dfbiaoti5"))
	self.m_dfbiaoti1:setVisible(false)
	self.m_dfbiaoti3:setVisible(false)
	self.m_dfbiaoti4:setVisible(false)
	self.m_dfbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1df1:subscribeEvent("Clicked", jingmaihecheng_df2.hc1df1, self)
	self.m_hc1df2:subscribeEvent("Clicked", jingmaihecheng_df2.hc1df2, self)
	self.m_hc1df3:subscribeEvent("Clicked", jingmaihecheng_df2.hc1df3, self)
	self.m_hc1df4:subscribeEvent("Clicked", jingmaihecheng_df2.hc1df4, self)
	self.m_hc1df5:subscribeEvent("Clicked", jingmaihecheng_df2.hc1df5, self)
	self.m_hc1df6:subscribeEvent("Clicked", jingmaihecheng_df2.hc1df6, self)
	self.m_hc1df7:subscribeEvent("Clicked", jingmaihecheng_df2.hc1df7, self)
	self.m_hc1df8:subscribeEvent("Clicked", jingmaihecheng_df2.hc1df8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_df2.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1df1 = 8014021
TaskHelper.m_hc1df2 = 8014022
TaskHelper.m_hc1df3 = 8014023
TaskHelper.m_hc1df4 = 8014024
TaskHelper.m_hc1df5 = 8014025
TaskHelper.m_hc1df6 = 8014026
TaskHelper.m_hc1df7 = 8014027
TaskHelper.m_hc1df8 = 8014028

-- function jingmaihecheng_df2:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_df2:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_df2:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_df2:jingmaibeibao(args)
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


function jingmaihecheng_df2.hc1df1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df2.hc1df2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df2.hc1df3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df2.hc1df4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df2.hc1df5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df2.hc1df6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df2.hc1df7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df2.hc1df8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_df2

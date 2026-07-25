require "logic.dialog"

jingmaihecheng_st4 = {}
setmetatable(jingmaihecheng_st4, Dialog)
jingmaihecheng_st4.__index = jingmaihecheng_st4

local _instance
function jingmaihecheng_st4.getInstance()
	if not _instance then
		_instance = jingmaihecheng_st4:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_st4.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_st4:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_st4.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_st4.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_st4.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_st4:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_st4.GetLayoutFileName()
	return "jingmaihecheng_st.layout"
end

function jingmaihecheng_st4:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_st4)
	return self
end

function jingmaihecheng_st4:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_st4:OnCreate()
    LogInfo("jingmaihecheng_st oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1st1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/st1"))
	self.m_hc1st2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/st2"))
	self.m_hc1st3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/st3"))
	self.m_hc1st4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/st4"))
	self.m_hc1st5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/st5"))
	self.m_hc1st6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/st6"))
	self.m_hc1st7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/st7"))
	self.m_hc1st8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/st8"))
	self.m_stbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/stbiaoti1"))
	self.m_stbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/stbiaoti2"))
	self.m_stbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/stbiaoti3"))
	self.m_stbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/stbiaoti4"))
	self.m_stbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/stbiaoti5"))
	self.m_stbiaoti1:setVisible(false)
	self.m_stbiaoti2:setVisible(false)
	self.m_stbiaoti3:setVisible(false)
	self.m_stbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_st/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1st1:subscribeEvent("Clicked", jingmaihecheng_st4.hc1st1, self)
	self.m_hc1st2:subscribeEvent("Clicked", jingmaihecheng_st4.hc1st2, self)
	self.m_hc1st3:subscribeEvent("Clicked", jingmaihecheng_st4.hc1st3, self)
	self.m_hc1st4:subscribeEvent("Clicked", jingmaihecheng_st4.hc1st4, self)
	self.m_hc1st5:subscribeEvent("Clicked", jingmaihecheng_st4.hc1st5, self)
	self.m_hc1st6:subscribeEvent("Clicked", jingmaihecheng_st4.hc1st6, self)
	self.m_hc1st7:subscribeEvent("Clicked", jingmaihecheng_st4.hc1st7, self)
	self.m_hc1st8:subscribeEvent("Clicked", jingmaihecheng_st4.hc1st8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_st4.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1st1 = 8013041
TaskHelper.m_hc1st2 = 8013042
TaskHelper.m_hc1st3 = 8013043
TaskHelper.m_hc1st4 = 8013044
TaskHelper.m_hc1st5 = 8013045
TaskHelper.m_hc1st6 = 8013046
TaskHelper.m_hc1st7 = 8013047
TaskHelper.m_hc1st8 = 8013048

-- function jingmaihecheng_st4:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_st4:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_st4:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_st4:jingmaibeibao(args)
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


function jingmaihecheng_st4.hc1st1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1st1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_st4.hc1st2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1st2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_st4.hc1st3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1st3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_st4.hc1st4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1st4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_st4.hc1st5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1st5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_st4.hc1st6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1st6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_st4.hc1st7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1st7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_st4.hc1st8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1st8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_st4

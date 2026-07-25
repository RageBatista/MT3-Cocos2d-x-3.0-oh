require "logic.dialog"

jingmaihecheng_hs2 = {}
setmetatable(jingmaihecheng_hs2, Dialog)
jingmaihecheng_hs2.__index = jingmaihecheng_hs2

local _instance
function jingmaihecheng_hs2.getInstance()
	if not _instance then
		_instance = jingmaihecheng_hs2:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_hs2.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_hs2:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_hs2.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_hs2.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_hs2.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_hs2:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_hs2.GetLayoutFileName()
	return "jingmaihecheng_hs.layout"
end

function jingmaihecheng_hs2:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_hs2)
	return self
end

function jingmaihecheng_hs2:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_hs2:OnCreate()
    LogInfo("jingmaihecheng_hs oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1hs1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs1"))
	self.m_hc1hs2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs2"))
	self.m_hc1hs3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs3"))
	self.m_hc1hs4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs4"))
	self.m_hc1hs5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs5"))
	self.m_hc1hs6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs6"))
	self.m_hc1hs7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs7"))
	self.m_hc1hs8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hs8"))
	self.m_hsbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hsbiaoti1"))
	self.m_hsbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hsbiaoti2"))
	self.m_hsbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hsbiaoti3"))
	self.m_hsbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hsbiaoti4"))
	self.m_hsbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/hsbiaoti5"))
	self.m_hsbiaoti1:setVisible(false)
	self.m_hsbiaoti3:setVisible(false)
	self.m_hsbiaoti4:setVisible(false)
	self.m_hsbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_hs/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1hs1:subscribeEvent("Clicked", jingmaihecheng_hs2.hc1hs1, self)
	self.m_hc1hs2:subscribeEvent("Clicked", jingmaihecheng_hs2.hc1hs2, self)
	self.m_hc1hs3:subscribeEvent("Clicked", jingmaihecheng_hs2.hc1hs3, self)
	self.m_hc1hs4:subscribeEvent("Clicked", jingmaihecheng_hs2.hc1hs4, self)
	self.m_hc1hs5:subscribeEvent("Clicked", jingmaihecheng_hs2.hc1hs5, self)
	self.m_hc1hs6:subscribeEvent("Clicked", jingmaihecheng_hs2.hc1hs6, self)
	self.m_hc1hs7:subscribeEvent("Clicked", jingmaihecheng_hs2.hc1hs7, self)
	self.m_hc1hs8:subscribeEvent("Clicked", jingmaihecheng_hs2.hc1hs8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_hs2.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1hs1 = 8019021
TaskHelper.m_hc1hs2 = 8019022
TaskHelper.m_hc1hs3 = 8019023
TaskHelper.m_hc1hs4 = 8019024
TaskHelper.m_hc1hs5 = 8019025
TaskHelper.m_hc1hs6 = 8019026
TaskHelper.m_hc1hs7 = 8019027
TaskHelper.m_hc1hs8 = 8019028

-- function jingmaihecheng_hs2:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_hs2:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_hs2:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_hs2:jingmaibeibao(args)
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


function jingmaihecheng_hs2.hc1hs1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1hs1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_hs2.hc1hs2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1hs2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_hs2.hc1hs3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1hs3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_hs2.hc1hs4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1hs4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_hs2.hc1hs5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1hs5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_hs2.hc1hs6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1hs6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_hs2.hc1hs7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1hs7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_hs2.hc1hs8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1hs8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_hs2

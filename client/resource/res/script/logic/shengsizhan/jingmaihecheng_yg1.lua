require "logic.dialog"

jingmaihecheng_yg1 = {}
setmetatable(jingmaihecheng_yg1, Dialog)
jingmaihecheng_yg1.__index = jingmaihecheng_yg1

local _instance
function jingmaihecheng_yg1.getInstance()
	if not _instance then
		_instance = jingmaihecheng_yg1:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_yg1.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_yg1:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_yg1.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_yg1.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_yg1.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_yg1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_yg1.GetLayoutFileName()
	return "hecheng3.layout"
end

function jingmaihecheng_yg1:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_yg1)
	return self
end

function jingmaihecheng_yg1:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_yg1:OnCreate()
    LogInfo("jingmaihecheng_yg oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local scrollPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("jingmaihecheng_yg/huadong1"))

	
    self.m_hc1yg1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/dt1"))
	self.m_hc1yg2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/dt2"))
	self.m_hc1yg3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/dt3"))
	self.m_hc1yg4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/dt4"))
	self.m_hc1yg5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/kn1"))
	self.m_hc1yg6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/kn2"))
	self.m_hc1yg7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/kn3"))
	self.m_hc1yg8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/kn4"))
	self.m_hc1yg9 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/ys1"))
	self.m_hc1yg10 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/ys2"))
	self.m_hc1yg11 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/ys3"))
	self.m_hc1yg12 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/ys4"))
	self.m_hc1yg13 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/lh1"))
	self.m_hc1yg14 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/lh2"))
	self.m_hc1yg15 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/lh3"))
	self.m_hc1yg16 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/lh4"))
	self.m_hc1yg17 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/qx1"))
	self.m_hc1yg18 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/qx2"))
	self.m_hc1yg19 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/qx3"))
    self.m_hc1yg20 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/qx4"))
	
	self.zhw1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/wulineidan"))----物理内丹
	self.zhw1:subscribeEvent("Clicked", jingmaihecheng_yg1.handleAddtBtnzhw1, self)----物理内丹
	
	self.zhw2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/fashuneidan"))----法术内丹
	self.zhw2:subscribeEvent("Clicked", jingmaihecheng_yg1.handleAddtBtnzhw2, self)----法术内丹
	
	self.zhw3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_yg/gaojineidan"))----高级内丹
	self.zhw3:subscribeEvent("Clicked", jingmaihecheng_yg1.handleAddtBtnzhw3, self)----高级内丹


	self.m_hc1yg1:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg1, self)
	self.m_hc1yg2:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg2, self)
	self.m_hc1yg3:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg3, self)
	self.m_hc1yg4:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg4, self)
	self.m_hc1yg5:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg5, self)
	self.m_hc1yg6:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg6, self)
	self.m_hc1yg7:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg7, self)
	self.m_hc1yg8:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg8, self)
	self.m_hc1yg9:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg9, self)
	self.m_hc1yg10:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg10, self)
	self.m_hc1yg11:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg11, self)
	self.m_hc1yg12:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg12, self)
	self.m_hc1yg13:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg13, self)
	self.m_hc1yg14:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg14, self)
	self.m_hc1yg15:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg15, self)
	self.m_hc1yg16:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg16, self)
	self.m_hc1yg17:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg17, self)
	self.m_hc1yg18:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg18, self)
	self.m_hc1yg19:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg19, self)
	self.m_hc1yg20:subscribeEvent("Clicked", jingmaihecheng_yg1.hc1yg20, self)
	
	self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
	
	scrollPane:addChildWindow(self.m_hc1yg1)
    scrollPane:addChildWindow(self.m_hc1yg2)
    scrollPane:addChildWindow(self.m_hc1yg3)
    scrollPane:addChildWindow(self.m_hc1yg4)
    scrollPane:addChildWindow(self.m_hc1yg5)
    scrollPane:addChildWindow(self.m_hc1yg6)
    scrollPane:addChildWindow(self.m_hc1yg7)
    scrollPane:addChildWindow(self.m_hc1yg8)
    scrollPane:addChildWindow(self.m_hc1yg9)
    scrollPane:addChildWindow(self.m_hc1yg10)
    scrollPane:addChildWindow(self.m_hc1yg11)
    scrollPane:addChildWindow(self.m_hc1yg12)
    scrollPane:addChildWindow(self.m_hc1yg13)
    scrollPane:addChildWindow(self.m_hc1yg14)
    scrollPane:addChildWindow(self.m_hc1yg15)
    scrollPane:addChildWindow(self.m_hc1yg16)
    scrollPane:addChildWindow(self.m_hc1yg17)
    scrollPane:addChildWindow(self.m_hc1yg18)
    scrollPane:addChildWindow(self.m_hc1yg19)
    scrollPane:addChildWindow(self.m_hc1yg20)

	
end
------------------------------------------------------

------------------------------------------------------

TaskHelper.m_hc1yg1 = 254940
TaskHelper.m_hc1yg2 = 254941
TaskHelper.m_hc1yg3 = 254942
TaskHelper.m_hc1yg4 = 254943
TaskHelper.m_hc1yg5 = 254944
TaskHelper.m_hc1yg6 = 254945
TaskHelper.m_hc1yg7 = 254946
TaskHelper.m_hc1yg8 = 254947
TaskHelper.m_hc1yg9 = 254948
TaskHelper.m_hc1yg10 = 254949
TaskHelper.m_hc1yg11 = 254950
TaskHelper.m_hc1yg12 = 254951
TaskHelper.m_hc1yg13 = 254952
TaskHelper.m_hc1yg14 = 254953
TaskHelper.m_hc1yg15 = 254954
TaskHelper.m_hc1yg16 = 254955
TaskHelper.m_hc1yg17 = 254956
TaskHelper.m_hc1yg18 = 254957
TaskHelper.m_hc1yg19 = 254958
TaskHelper.m_hc1yg20 = 254959


function jingmaihecheng_yg1:handleAddtBtnzhw1(args)-----物理内丹合成
   require("logic.shengsizhan.jingmaihecheng_dt1").getInstanceAndShow()
    jingmaihecheng_yg1.DestroyDialog()
end

function jingmaihecheng_yg1:handleAddtBtnzhw2(args)-----法术内丹
   require("logic.shengsizhan.jingmaihecheng_df1").getInstanceAndShow()
    jingmaihecheng_yg1.DestroyDialog()
end

function jingmaihecheng_yg1:handleAddtBtnzhw3(args)-----高级内丹
   require("logic.shengsizhan.jingmaihecheng_fc1").getInstanceAndShow()
    jingmaihecheng_yg1.DestroyDialog()
end


function jingmaihecheng_yg1.hc1yg1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg9()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg9
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg10()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg10
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg11()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg11
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg12()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg12
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg13()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg13
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg14()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg14
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg15()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg15
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg16()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg16
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg17()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg17
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg18()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg18
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg19()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg19
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_yg1.hc1yg20()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg20
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_yg1

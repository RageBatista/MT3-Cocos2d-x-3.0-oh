require "logic.dialog"

jingmaihecheng_dt1 = {}
setmetatable(jingmaihecheng_dt1, Dialog)
jingmaihecheng_dt1.__index = jingmaihecheng_dt1

local _instance
function jingmaihecheng_dt1.getInstance()
	if not _instance then
		_instance = jingmaihecheng_dt1:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_dt1.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_dt1:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_dt1.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_dt1.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_dt1.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_dt1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_dt1.GetLayoutFileName()
	return "hecheng1.layout"
end

function jingmaihecheng_dt1:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_dt1)
	return self
end

function jingmaihecheng_dt1:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_dt1:OnCreate()
    LogInfo("jingmaihecheng_dt oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
	local scrollPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("jingmaihecheng_dt/huadong1"))

	
    self.m_hc1dt1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt1"))
	self.m_hc1dt2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt2"))
	self.m_hc1dt3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt3"))
	self.m_hc1dt4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/dt4"))
	self.m_hc1dt5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/kn1"))
	self.m_hc1dt6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/kn2"))
	self.m_hc1dt7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/kn3"))
	self.m_hc1dt8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/kn4"))
	self.m_hc1dt9 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/ys1"))
	self.m_hc1dt10 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/ys2"))
	self.m_hc1dt11 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/ys3"))
	self.m_hc1dt12 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/ys4"))
	self.m_hc1dt13 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/lh1"))
	self.m_hc1dt14 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/lh2"))
	self.m_hc1dt15 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/lh3"))
	self.m_hc1dt16 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/lh4"))
	self.m_hc1dt17 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/qx1"))
	self.m_hc1dt18 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/qx2"))
	self.m_hc1dt19 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/qx3"))
    self.m_hc1dt20 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/qx4"))
	
	self.fashuneidanbat = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/fashuneidan"))----法术内丹合成
	self.fashuneidanbat:subscribeEvent("Clicked", jingmaihecheng_dt1.handleAddtBtnfashuneidanbat, self)----法术内丹合成
	
	self.fuzhubat = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/fuzhuneidan"))----辅助内丹
	self.fuzhubat:subscribeEvent("Clicked", jingmaihecheng_dt1.handleAddtBtnfuzhubat, self)----辅助内丹
	
	self.zhw1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_dt/gaojineidan"))----高级内丹
	self.zhw1:subscribeEvent("Clicked", jingmaihecheng_dt1.handleAddtBtnzhw1, self)----高级内丹



    
	self.m_hc1dt1:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt1, self)
	self.m_hc1dt2:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt2, self)
	self.m_hc1dt3:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt3, self)
	self.m_hc1dt4:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt4, self)
	self.m_hc1dt5:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt5, self)
	self.m_hc1dt6:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt6, self)
	self.m_hc1dt7:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt7, self)
	self.m_hc1dt8:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt8, self)
	self.m_hc1dt9:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt9, self)
	self.m_hc1dt10:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt10, self)
	self.m_hc1dt11:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt11, self)
	self.m_hc1dt12:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt12, self)
	self.m_hc1dt13:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt13, self)
	self.m_hc1dt14:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt14, self)
	self.m_hc1dt15:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt15, self)
	self.m_hc1dt16:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt16, self)
	self.m_hc1dt17:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt17, self)
	self.m_hc1dt18:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt18, self)
	self.m_hc1dt19:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt19, self)
	self.m_hc1dt20:subscribeEvent("Clicked", jingmaihecheng_dt1.hc1dt20, self)


    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)

    -- 创建可滚动窗口
    

    -- 添加按钮到可滚动窗口
    scrollPane:addChildWindow(self.m_hc1dt1)
    scrollPane:addChildWindow(self.m_hc1dt2)
    scrollPane:addChildWindow(self.m_hc1dt3)
    scrollPane:addChildWindow(self.m_hc1dt4)
    scrollPane:addChildWindow(self.m_hc1dt5)
    scrollPane:addChildWindow(self.m_hc1dt6)
    scrollPane:addChildWindow(self.m_hc1dt7)
    scrollPane:addChildWindow(self.m_hc1dt8)
    scrollPane:addChildWindow(self.m_hc1dt9)
    scrollPane:addChildWindow(self.m_hc1dt10)
    scrollPane:addChildWindow(self.m_hc1dt11)
    scrollPane:addChildWindow(self.m_hc1dt12)
    scrollPane:addChildWindow(self.m_hc1dt13)
    scrollPane:addChildWindow(self.m_hc1dt14)
    scrollPane:addChildWindow(self.m_hc1dt15)
    scrollPane:addChildWindow(self.m_hc1dt16)
    scrollPane:addChildWindow(self.m_hc1dt17)
    scrollPane:addChildWindow(self.m_hc1dt18)
    scrollPane:addChildWindow(self.m_hc1dt19)
    scrollPane:addChildWindow(self.m_hc1dt20)
	
end

------------------------------------------------------

------------------------------------------------------

TaskHelper.m_hc1dt1 = 254900
TaskHelper.m_hc1dt2 = 254901
TaskHelper.m_hc1dt3 = 254902
TaskHelper.m_hc1dt4 = 254903
TaskHelper.m_hc1dt5 = 254904
TaskHelper.m_hc1dt6 = 254905
TaskHelper.m_hc1dt7 = 254906
TaskHelper.m_hc1dt8 = 254907
TaskHelper.m_hc1dt9 = 254908
TaskHelper.m_hc1dt10 = 254909
TaskHelper.m_hc1dt11 = 254910
TaskHelper.m_hc1dt12 = 254911
TaskHelper.m_hc1dt13 = 254912
TaskHelper.m_hc1dt14 = 254913
TaskHelper.m_hc1dt15 = 254914
TaskHelper.m_hc1dt16 = 254915
TaskHelper.m_hc1dt17 = 254916
TaskHelper.m_hc1dt18 = 254917
TaskHelper.m_hc1dt19 = 254918
TaskHelper.m_hc1dt20 = 254919


function jingmaihecheng_dt1:handleAddtBtnfashuneidanbat(args)-----法术内丹合成
   require("logic.shengsizhan.jingmaihecheng_df1").getInstanceAndShow()
    jingmaihecheng_dt1.DestroyDialog()
end

function jingmaihecheng_dt1:handleAddtBtnfuzhubat(args)-----辅助内丹
   require("logic.shengsizhan.jingmaihecheng_yg1").getInstanceAndShow()
    jingmaihecheng_dt1.DestroyDialog()
end

function jingmaihecheng_dt1:handleAddtBtnzhw1(args)-----高级内丹
   require("logic.shengsizhan.jingmaihecheng_fc1").getInstanceAndShow()
    jingmaihecheng_dt1.DestroyDialog()
end



function jingmaihecheng_dt1.hc1dt1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt9()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt9
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt10()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt10
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt11()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt11
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt12()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt12
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt13()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt13
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt14()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt14
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt15()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt15
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt16()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt16
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt17()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt17
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt18()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt18
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt19()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt19
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_dt1.hc1dt20()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1dt20
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
return jingmaihecheng_dt1

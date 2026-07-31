require "logic.dialog"

jingmaihecheng_df1 = {}
setmetatable(jingmaihecheng_df1, Dialog)
jingmaihecheng_df1.__index = jingmaihecheng_df1

local _instance
function jingmaihecheng_df1.getInstance()
	if not _instance then
		_instance = jingmaihecheng_df1:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_df1.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_df1:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_df1.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_df1.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_df1.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_df1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_df1.GetLayoutFileName()
	return "hecheng2.layout"
end

function jingmaihecheng_df1:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_df1)
	return self
end

function jingmaihecheng_df1:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_df1:OnCreate()
    LogInfo("jingmaihecheng_df oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    local scrollPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("jingmaihecheng_df/huadong1"))

	
    self.m_hc1df1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/dt1"))
	self.m_hc1df2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/dt2"))
	self.m_hc1df3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/dt3"))
	self.m_hc1df4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/dt4"))
	self.m_hc1df5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/kn1"))
	self.m_hc1df6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/kn2"))
	self.m_hc1df7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/kn3"))
	self.m_hc1df8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/kn4"))
	self.m_hc1df9 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/ys1"))
	self.m_hc1df10 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/ys2"))
	self.m_hc1df11 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/ys3"))
	self.m_hc1df12 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/ys4"))
	self.m_hc1df13 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/lh1"))
	self.m_hc1df14 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/lh2"))
	self.m_hc1df15 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/lh3"))
	self.m_hc1df16 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/lh4"))
	self.m_hc1df17 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/qx1"))
	self.m_hc1df18 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/qx2"))
	self.m_hc1df19 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/qx3"))
    self.m_hc1df20 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/qx4"))
	self.zhw1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/wulineidan"))----物理内丹
	self.zhw1:subscribeEvent("Clicked", jingmaihecheng_df1.handleAddtBtnzhw1, self)----物理内丹
	
	self.zhw2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/fuzhuneidan"))----辅助内丹
	self.zhw2:subscribeEvent("Clicked", jingmaihecheng_df1.handleAddtBtnzhw2, self)----辅助内丹
	
	self.zhw3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_df/gaojineidan"))----高级内丹
	self.zhw3:subscribeEvent("Clicked", jingmaihecheng_df1.handleAddtBtnzhw3, self)----高级内丹




	self.m_hc1df1:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt1, self)
	self.m_hc1df2:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt2, self)
	self.m_hc1df3:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt3, self)
	self.m_hc1df4:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt4, self)
	self.m_hc1df5:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt5, self)
	self.m_hc1df6:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt6, self)
	self.m_hc1df7:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt7, self)
	self.m_hc1df8:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt8, self)
	self.m_hc1df9:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt9, self)
	self.m_hc1df10:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt10, self)
	self.m_hc1df11:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt11, self)
	self.m_hc1df12:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt12, self)
	self.m_hc1df13:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt13, self)
	self.m_hc1df14:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt14, self)
	self.m_hc1df15:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt15, self)
	self.m_hc1df16:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt16, self)
	self.m_hc1df17:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt17, self)
	self.m_hc1df18:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt18, self)
	self.m_hc1df19:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt19, self)
	self.m_hc1df20:subscribeEvent("Clicked", jingmaihecheng_df1.hc1dt20, self)


    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)

    -- 创建可滚动窗口
    

    -- 添加按钮到可滚动窗口
    scrollPane:addChildWindow(self.m_hc1df1)
    scrollPane:addChildWindow(self.m_hc1df2)
    scrollPane:addChildWindow(self.m_hc1df3)
    scrollPane:addChildWindow(self.m_hc1df4)
    scrollPane:addChildWindow(self.m_hc1df5)
    scrollPane:addChildWindow(self.m_hc1df6)
    scrollPane:addChildWindow(self.m_hc1df7)
    scrollPane:addChildWindow(self.m_hc1df8)
    scrollPane:addChildWindow(self.m_hc1df9)
    scrollPane:addChildWindow(self.m_hc1df10)
    scrollPane:addChildWindow(self.m_hc1df11)
    scrollPane:addChildWindow(self.m_hc1df12)
    scrollPane:addChildWindow(self.m_hc1df13)
    scrollPane:addChildWindow(self.m_hc1df14)
    scrollPane:addChildWindow(self.m_hc1df15)
    scrollPane:addChildWindow(self.m_hc1df16)
    scrollPane:addChildWindow(self.m_hc1df17)
    scrollPane:addChildWindow(self.m_hc1df18)
    scrollPane:addChildWindow(self.m_hc1df19)
    scrollPane:addChildWindow(self.m_hc1df20)
	

end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1df1 = 254920
TaskHelper.m_hc1df2 = 254921
TaskHelper.m_hc1df3 = 254922
TaskHelper.m_hc1df4 = 254923
TaskHelper.m_hc1df5 = 254924
TaskHelper.m_hc1df6 = 254925
TaskHelper.m_hc1df7 = 254926
TaskHelper.m_hc1df8 = 254927
TaskHelper.m_hc1df9 = 254928
TaskHelper.m_hc1df10 = 254929
TaskHelper.m_hc1df11 = 254930
TaskHelper.m_hc1df12 = 254931
TaskHelper.m_hc1df13 = 254932
TaskHelper.m_hc1df14 = 254933
TaskHelper.m_hc1df15 = 254934
TaskHelper.m_hc1df16 = 254935
TaskHelper.m_hc1df17 = 254936
TaskHelper.m_hc1df18 = 254937
TaskHelper.m_hc1df19 = 254938
TaskHelper.m_hc1df20 = 254939


function jingmaihecheng_df1:handleAddtBtnzhw1(args)-----物理内丹合成
   require("logic.shengsizhan.jingmaihecheng_dt1").getInstanceAndShow()
    jingmaihecheng_df1.DestroyDialog()
end

function jingmaihecheng_df1:handleAddtBtnzhw2(args)-----辅助内丹
   require("logic.shengsizhan.jingmaihecheng_yg1").getInstanceAndShow()
    jingmaihecheng_df1.DestroyDialog()
end

function jingmaihecheng_df1:handleAddtBtnzhw3(args)-----高级内丹
   require("logic.shengsizhan.jingmaihecheng_fc1").getInstanceAndShow()
    jingmaihecheng_df1.DestroyDialog()
end




function jingmaihecheng_df1.hc1dt1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt9()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df9
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt10()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df10
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt11()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df11
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt12()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df12
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt13()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df13
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt14()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df14
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt15()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df15
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt16()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df16
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt17()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df17
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt18()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df18
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt19()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df19
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_df1.hc1dt20()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1df20
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end



return jingmaihecheng_df1

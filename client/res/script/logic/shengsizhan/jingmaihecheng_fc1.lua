require "logic.dialog"

jingmaihecheng_fc1 = {}
setmetatable(jingmaihecheng_fc1, Dialog)
jingmaihecheng_fc1.__index = jingmaihecheng_fc1

local _instance
function jingmaihecheng_fc1.getInstance()
	if not _instance then
		_instance = jingmaihecheng_fc1:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_fc1.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_fc1:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_fc1.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_fc1.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_fc1.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_fc1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_fc1.GetLayoutFileName()
	return "hecheng4.layout"
end

function jingmaihecheng_fc1:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_fc1)
	return self
end

function jingmaihecheng_fc1:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_fc1:OnCreate()
    LogInfo("jingmaihecheng_fc oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local scrollPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("jingmaihecheng_fc/huadong1"))
	
	self.m_zhw1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl1"))
	self.m_zhw2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl2"))
	self.m_zhw3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl3"))
	self.m_zhw4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl4"))
	self.m_zhw5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl5"))
	self.m_zhw6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl6"))
	self.m_zhw7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl7"))
	self.m_zhw8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl8"))
	self.m_zhw9 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl9"))
	self.m_zhw10 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl10"))
	self.m_zhw11 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl11"))
	self.m_zhw12 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wl12"))
	self.m_zhw13 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs1"))
	self.m_zhw14 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs2"))
	self.m_zhw15 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs3"))
	self.m_zhw16 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs4"))
	self.m_zhw17 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs5"))
	self.m_zhw18 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs6"))
	self.m_zhw19 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs7"))
	self.m_zhw20 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs8"))
	self.m_zhw21 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs9"))
	self.m_zhw22 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs10"))
	self.m_zhw23 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs11"))
	self.m_zhw24 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fs12"))
	self.m_zhw25 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz1"))
	self.m_zhw26 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz2"))
	self.m_zhw27 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz3"))
	self.m_zhw28 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz4"))
	self.m_zhw29 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz5"))
	self.m_zhw30 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz6"))
	self.m_zhw31 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz7"))
	self.m_zhw32 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz8"))
	self.m_zhw33 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz9"))
	self.m_zhw34 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz10"))
	self.m_zhw35 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz11"))
	self.m_zhw36 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fz12"))
	
	self.aniuzhw1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/wulineidan"))----物理内丹
	self.aniuzhw1:subscribeEvent("Clicked", jingmaihecheng_fc1.handleAddtBtnaniuzhw1, self)----物理内丹
	
	self.aniuzhw2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fashuneidan"))----法术内丹
	self.aniuzhw2:subscribeEvent("Clicked", jingmaihecheng_fc1.handleAddtBtnaniuzhw2, self)----法术内丹
	
	self.aniuzhw3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_fc/fuzhuneidan"))----辅助内丹
	self.aniuzhw3:subscribeEvent("Clicked", jingmaihecheng_fc1.handleAddtBtnaniuzhw3, self)----辅助内丹

	self.m_zhw1:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc1, self)
	self.m_zhw2:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc2, self)
	self.m_zhw3:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc3, self)
	self.m_zhw4:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc4, self)
	self.m_zhw5:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc5, self)
	self.m_zhw6:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc6, self)
	self.m_zhw7:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc7, self)
	self.m_zhw8:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc8, self)
	self.m_zhw9:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc9, self)
	self.m_zhw10:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc10, self)
	self.m_zhw11:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc11, self)
	self.m_zhw12:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc12, self)
	self.m_zhw13:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc13, self)
	self.m_zhw14:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc14, self)
	self.m_zhw15:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc15, self)
	self.m_zhw16:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc16, self)
	self.m_zhw17:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc17, self)
	self.m_zhw18:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc18, self)
	self.m_zhw19:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc19, self)
	self.m_zhw20:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc20, self)
	self.m_zhw21:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc21, self)
	self.m_zhw22:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc22, self)
	self.m_zhw23:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc23, self)
	self.m_zhw24:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc24, self)
	self.m_zhw25:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc25, self)
	self.m_zhw26:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc26, self)
	self.m_zhw27:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc27, self)
	self.m_zhw28:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc28, self)
	self.m_zhw29:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc29, self)
	self.m_zhw30:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc30, self)
	self.m_zhw31:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc31, self)
	self.m_zhw32:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc32, self)
	self.m_zhw33:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc33, self)
	self.m_zhw34:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc34, self)
	self.m_zhw35:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc35, self)
	self.m_zhw36:subscribeEvent("Clicked", jingmaihecheng_fc1.zhwhc36, self)
	
	self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)

	scrollPane:addChildWindow(self.m_zhw1)
	scrollPane:addChildWindow(self.m_zhw2)
	scrollPane:addChildWindow(self.m_zhw3)
	scrollPane:addChildWindow(self.m_zhw4)
	scrollPane:addChildWindow(self.m_zhw5)
	scrollPane:addChildWindow(self.m_zhw6)
	scrollPane:addChildWindow(self.m_zhw7)
	scrollPane:addChildWindow(self.m_zhw8)
	scrollPane:addChildWindow(self.m_zhw9)
	scrollPane:addChildWindow(self.m_zhw10)
	scrollPane:addChildWindow(self.m_zhw11)
	scrollPane:addChildWindow(self.m_zhw12)
	scrollPane:addChildWindow(self.m_zhw13)
	scrollPane:addChildWindow(self.m_zhw14)
	scrollPane:addChildWindow(self.m_zhw15)
	scrollPane:addChildWindow(self.m_zhw16)
	scrollPane:addChildWindow(self.m_zhw17)
	scrollPane:addChildWindow(self.m_zhw18)
	scrollPane:addChildWindow(self.m_zhw19)
	scrollPane:addChildWindow(self.m_zhw20)
	scrollPane:addChildWindow(self.m_zhw21)
	scrollPane:addChildWindow(self.m_zhw22)
	scrollPane:addChildWindow(self.m_zhw23)
	scrollPane:addChildWindow(self.m_zhw24)
	scrollPane:addChildWindow(self.m_zhw25)
	scrollPane:addChildWindow(self.m_zhw26)
	scrollPane:addChildWindow(self.m_zhw27)
	scrollPane:addChildWindow(self.m_zhw28)
	scrollPane:addChildWindow(self.m_zhw29)
	scrollPane:addChildWindow(self.m_zhw30)
	scrollPane:addChildWindow(self.m_zhw31)
	scrollPane:addChildWindow(self.m_zhw32)
	scrollPane:addChildWindow(self.m_zhw33)
	scrollPane:addChildWindow(self.m_zhw34)
	scrollPane:addChildWindow(self.m_zhw35)
	scrollPane:addChildWindow(self.m_zhw36)

end


function jingmaihecheng_fc1:handleAddtBtnaniuzhw1(args)-----物理内丹合成
   require("logic.shengsizhan.jingmaihecheng_dt1").getInstanceAndShow()
    jingmaihecheng_fc1.DestroyDialog()
end

function jingmaihecheng_fc1:handleAddtBtnaniuzhw2(args)-----法术内丹
   require("logic.shengsizhan.jingmaihecheng_df1").getInstanceAndShow()
    jingmaihecheng_fc1.DestroyDialog()
end

function jingmaihecheng_fc1:handleAddtBtnaniuzhw3(args)-----辅助内丹
   require("logic.shengsizhan.jingmaihecheng_yg1").getInstanceAndShow()
    jingmaihecheng_fc1.DestroyDialog()
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_zhw1 = 254960
TaskHelper.m_zhw2 = 254961
TaskHelper.m_zhw3 = 254962
TaskHelper.m_zhw4 = 254963
TaskHelper.m_zhw5 = 254964
TaskHelper.m_zhw6 = 254965
TaskHelper.m_zhw7 = 254966
TaskHelper.m_zhw8 = 254967
TaskHelper.m_zhw9 = 254968
TaskHelper.m_zhw10 = 254969
TaskHelper.m_zhw11 = 254970
TaskHelper.m_zhw12 = 254971
TaskHelper.m_zhw13 = 254972
TaskHelper.m_zhw14 = 254973
TaskHelper.m_zhw15 = 254974
TaskHelper.m_zhw16 = 254975
TaskHelper.m_zhw17 = 254976
TaskHelper.m_zhw18 = 254977
TaskHelper.m_zhw19 = 254978
TaskHelper.m_zhw20 = 254979
TaskHelper.m_zhw21 = 254980
TaskHelper.m_zhw22 = 254981
TaskHelper.m_zhw23 = 254982
TaskHelper.m_zhw24 = 254983
TaskHelper.m_zhw25 = 254984
TaskHelper.m_zhw26 = 254985
TaskHelper.m_zhw27 = 254986
TaskHelper.m_zhw28 = 254987
TaskHelper.m_zhw29 = 254988
TaskHelper.m_zhw30 = 254989
TaskHelper.m_zhw31 = 254990
TaskHelper.m_zhw32 = 254991
TaskHelper.m_zhw33 = 254992
TaskHelper.m_zhw34 = 254993
TaskHelper.m_zhw35 = 254994
TaskHelper.m_zhw36 = 254995






function jingmaihecheng_fc1.zhwhc1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc9()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw9
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc10()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw10
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc11()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw11
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc12()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw12
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc13()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw13
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc14()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw14
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc15()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw15
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc16()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw16
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc17()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw17
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc18()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw18
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc19()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw19
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc20()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw20
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc21()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw21
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc22()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw22
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc23()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw23
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc24()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw24
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc25()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw25
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc26()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw26
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc27()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw27
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc28()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw28
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc29()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw29
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc30()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw30
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc31()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw31
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc32()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw32
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc33()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw33
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc34()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw34
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc35()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw35
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_fc1.zhwhc36()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_zhw36
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_fc1

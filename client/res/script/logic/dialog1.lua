Dialog = {}

DialogTypeTable = {
    eDialogType_Null = 1,
	eDialogType_TimeLimit = 2,
	eDialogType_BattleClose = 3,
	eDialogType_MoveClose = 4,
	eDialogType_RBtnClose = 5,
	eDialogType_MapChangeClose = 6,
	eDialogType_SceneMovieWnd = 7,
	eDialogType_InScreenCenter = 8,
	eDialogType_Max = 9
}

Dialog.__index = Dialog
--[[
Dialog.ma_OpenDlgs={}
Dialog.ma_CloseDlgs={}
Dialog.m_PlayingAnimationCount=0
Dialog.m_PlayingEffectCount=0
--]]
function Dialog:new()
    local self = {}
    setmetatable(self, Dialog)
	self.m_eDialogType = {}
    return self
end

function Dialog.DestroyDialog()
end

function Dialog:OnCreateEffect(wnd)
	for i=0,wnd:getChildCount()-1 do
		self:OnCreateEffect(wnd:getChildAtIdx(i))
	end
	if wnd:GetOnCreateEffectName()~="" then
		local sz=wnd:getPixelSize()
		local effectName=wnd:GetOnCreateEffectName()
		gGetGameUIManager():AddUIEffect(wnd,effectName)
	end
end

function Dialog:OnCreate(parentwindow,nameprefix)
	if not nameprefix then nameprefix = "" end
	 --print("lua load layout=nameprefix= "..nameprefix)

	--if this dialog is singleton
	if self.m_pMainFrame and self.m_bCloseIsHide then
		self:SetVisible(true)
		return
	end

    local winMgr = CEGUI.WindowManager:getSingleton()

	if not self.m_pMainFrame then
	    local fileName = self.GetLayoutFileName()
		--print("lua load layout "..nameprefix..fileName)
	    self.m_pMainFrame = winMgr:loadWindowLayout(fileName, nameprefix)
	end

	if not self.m_pMainFrame then 
	    LogErr("layout load error --> " .. filename)
		return
	end

    --self.m_pMainFrame:subscribeEvent("DestructStart", Dialog.OnDialogDestructStarted, self)

	--m_bCloseIsHide evaluate
	--self.m_bCloseIsHide = self.m_pMainFrame:GetCloseIsHide()

    -- if sheet not exist, return 
    local root = CEGUI.System:getSingleton():getGUISheet() 
    if not root then return end
	if self.m_pMainFrame == root then return end

	if not parentwindow then
		print(">>>>>>fileName:"..fileName.." 是parentwindow")
		if gGetSceneMovieManager() then
			if gGetSceneMovieManager():isOnSceneMovie() then
				if gGetGameUIManager():GetMainRootWnd() then
					if self.m_eDialogType and self.m_eDialogType[DialogTypeTable.eDialogType_SceneMovieWnd] then
						root:addChildWindow(self.m_pMainFrame)
					else
						gGetGameUIManager():AddWndToRootWindow(self.m_pMainFrame)
					end
				end
			else
				root:addChildWindow(self.m_pMainFrame)
			end
		else
			print(">>>>>>fileName:"..fileName.." 不是parentwindow")
			root:addChildWindow(self.m_pMainFrame)
		end
	else
		parentwindow:addChildWindow(self.m_pMainFrame)
		self.m_pParentWindow = parentwindow
	end

--[[
	if self.m_pMainFrame:GetCreateWndEffect() ~= CEGUI.CreateWndEffect_None then
		self.m_pMainFrame:BeginCreateEffect()
	end
--]]
	local closeBtn = self:GetCloseBtn()
	if closeBtn then 
		closeBtn:subscribeEvent("Clicked", self.HandleCloseBtnClick, self);
	end

	self.m_pMainFrame:subscribeEvent("Shown", self.HandleDialogOpen, self);
	self.m_pMainFrame:subscribeEvent("Hidden", self.HandleDialogClose, self);
	self.m_pMainFrame:subscribeEvent("DestructStart", self.HandleDialogClose, self);
--[[
	if self.m_pMainFrame:GetCloseWndEffect() ~= CEGUI.CloseWndEffect_None then
		self.m_pMainFrame:subscribeEvent("CloseWndEffectEnd", self.HandleCloseEffectEnd, self)
	end
--]]
	if self.m_pMainFrame:isModalAfterShow() then
		self.m_pMainFrame:setModalState(true)
	end
	if not self.m_pParentWindow then
		LuaUIManager.getInstance():AddDialog(self.m_pMainFrame, self)
	end
	
	--增加配置的播放动画和特效的功能
	--Dialog.ma_OpenDlgs[#Dialog.ma_OpenDlgs+1]=self
	self.m_ElapseTime=0
	self.ma_EffectNotify={}
	
end

--be sure this dialog is removed from Dialog.ma_OpenDlgs. by lg
function Dialog:OnDialogDestructStarted(args)
--[[
    for i,v in pairs(Dialog.ma_OpenDlgs) do
		if v==self then
			table.remove(Dialog.ma_OpenDlgs,i)
			break
		end
	end
--]]
end

function Dialog:checkPlayingEffectCount(closeWnd)
	Dialog.m_PlayingEffectCount=#self.ma_EffectNotify
end

function Dialog:checkPlayingAnimationCount(closeWnd)
end

function Dialog.OnEffectOver(effect,param1,param2)
end

function Dialog.OnTickAllDlg(deltaTime)
end

function Dialog:OnDestroyAnimation(thisWnd)
	for i=0,thisWnd:getChildCount()-1 do
		local childWnd=thisWnd:getChildAtIdx(i)
		self:OnDestroyAnimation(childWnd)
	end
end

function Dialog:OnDestroyEffect(wnd)
	gGetGameUIManager():RemoveUIEffect(wnd)
	for i=0,wnd:getChildCount()-1 do
		self:OnDestroyEffect(wnd:getChildAtIdx(i))
	end
end

function Dialog:OnClose(waitAnimAndEffect,ClearGameUIManager)

    if not self.m_pMainFrame then return end

	if self.m_bCloseIsHide then
		self.m_pMainFrame:hide()
	else
		-- ycl 窗口将要销毁了，移除所有之前注册的事件处理函数
		self:RemoveAllScriptFunctors();
		if not self.m_pParentWindow then
			LuaUIManager.getInstance():RemoveUIDialog(self.m_pMainFrame)
		end
		CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
		self.m_pMainFrame = nil
		self = nil
	end

end

function Dialog:IsVisible()
	if self.m_pMainFrame then
		return self.m_pMainFrame:isVisible()
	else
		return false
	end
end

function Dialog:SetVisible(bVisible)
    if not self.m_pMainFrame then return end

	if bVisible == self.m_pMainFrame:isVisible() then
		return
	end

    self.m_pMainFrame:setVisible(bVisible)

    if bVisible then 
		self.m_pMainFrame:activate() 

		if self.m_pMainFrame:isModalAfterShow() then
			self.m_pMainFrame:setModalState(true)
		end
	end

end
    
function Dialog.GetLayoutFileName()
    return ""
end

function Dialog:GetMainFrame()
    return self.m_pMainFrame
end

function Dialog:GetCloseBtn()
	if not self.m_pMainFrame then return nil end
	if self.m_pMainFrame:getType():find("FrameWindow") then
		pFrame = CEGUI.toFrameWindow(self.m_pMainFrame)
		return pFrame:getCloseButton()
	end
	

	return nil
end

function Dialog:GetWindow()
	return self.m_pMainFrame
end

function Dialog:HandleDialogOpen(args)
    if self:GetWindow():isModalAfterShow() then
        self:GetWindow():setModalState(true)
	end
	return true
end

function Dialog:HandleDialogClose(args)
    if self:GetWindow():isModalAfterShow() then
        self:GetWindow():setModalState(false)
	end
	return true
end

function Dialog:HandleCloseEffectEnd(args)
	if not self.m_pMainFrame then return true end

    local windowArgs = CEGUI.toWindowEventArgs(args)
	if windowArgs.window == self:GetWindow() then
        self:OnClose()
	end

	return true
end

function Dialog:HandleCloseBtnClick(args)
	self:DestroyDialog()
	return true
end

-- ycl 添加事件处理函数并保存
function Dialog:InsertScriptFunctor(eventGetter, func)
    local event = eventGetter();
    if event then
	    local funcHandle = event:InsertScriptFunctor(func);
	    self.mScriptFunctors = self.mScriptFunctors or {};
	    table.insert(self.mScriptFunctors, {eventGetter, funcHandle});
    end
end

-- ycl 移除所有之前添加的事件处理函数
function Dialog:RemoveAllScriptFunctors()
	if(self.mScriptFunctors)then
		for _, ef in pairs(self.mScriptFunctors) do
			if(ef)then
                local eventGetter = ef[1];
				local event = eventGetter();
				local funcHandle = ef[2];
				if(event and funcHandle)then
					event:RemoveScriptFunctor(funcHandle);
				end
			end
		end
		self.mScriptFunctors = nil;
	end
end

function Dialog:SetCloseIsHide(bVal)
	self.m_bCloseIsHide = bVal;
end

return Dialog

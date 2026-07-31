require "logic.dialog"

FriendAddDialog = {
	m_vDataList = {};
	m_vCellList = {};
	m_nLastReplaceTime = 0;
}
setmetatable(FriendAddDialog, Dialog)
FriendAddDialog.__index = FriendAddDialog 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FriendAddDialog.getInstance()
	LogInfo("enter FriendAddDialog")
    if not _instance then
        _instance = FriendAddDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FriendAddDialog.getInstanceAndShow()
	LogInfo("enter instance show")
    if not _instance then
        _instance = FriendAddDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FriendAddDialog.getInstanceNotCreate()
    return _instance
end 

function FriendAddDialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FriendAddDialog.ToggleOpenClose()
	if not _instance then 
		_instance = FriendAddDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function FriendAddDialog.GetLayoutFileName()
	return "friendadddialog.layout"
end

function FriendAddDialog:OnCreate()
	LogInfo("enter FriendAddDialog oncreate")
	Dialog.OnCreate(self)

--	SetPositionScreenCenter(self:GetWindow())

	self:GetWindow():setZOrderingEnabled(false)
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	-- get windows
	

	-- role list
	self.m_pRoleList = CEGUI.Window.toScrollablePane(winMgr:getWindow("friendadddialog/tuijian/liebiao"))

	-- replace button
	self.m_pReplaceBtn = CEGUI.Window.toPushButton(winMgr:getWindow("friendadddialog/huanyipi"))
	self.m_pReplaceBtn:subscribeEvent("Clicked", FriendAddDialog.HandleClickReplaceBtn, self)

	-- input box
	self.placeHolder = winMgr:getWindow("friendadddialog/shurukuang/tishiwenzi") 
	self.m_pEditBox = CEGUI.Window.toEditbox(winMgr:getWindow("friendadddialog/shurukuang/wenben"))
    self.m_pEditBox:SetNormalColourRect(0xff8c5e2a);
    self.m_pEditBox:subscribeEvent("TextChanged", self.OnEditNumChange, self)
    self.m_pEditBox:subscribeEvent("CaptureLost", self.OnEditActive, self)
	self.m_pEditBox:setMaxTextLength(15)


	-- find button
	self.m_pFindBtn = CEGUI.Window.toPushButton(winMgr:getWindow("friendadddialog/chazhao"))
	self.m_pFindBtn:subscribeEvent("Clicked", FriendAddDialog.HandleClickFindBtn, self)
	
	self.btnClose = CEGUI.toPushButton(winMgr:getWindow("friendadddialog/guanbi"))
    self.btnClose:subscribeEvent("Clicked", FriendAddDialog.btnCloseCallBack, self)

	--
	FriendAddDialog.m_vDataList = {}
	FriendAddDialog.m_vCellList = {}
	FriendAddDialog.m_nLastReplaceTime = 0

	self:RequestRecommendRoleList()

    FriendAddDialog.m_nLastReplaceTime = 0

	LogInfo("exit FriendAddDialog OnCreate")
end

function FriendAddDialog:btnCloseCallBack(args)
    FriendAddDialog.DestroyDialog()
end

function FriendAddDialog:OnEditActive(args)
    if self.m_pEditBox:isInputFocus() then
        self.placeHolder:setVisible(false)
    else        
        if string.len(self.m_pEditBox:getText()) == 0 then
            self.placeHolder:setVisible(true)
        end
    end
end

function FriendAddDialog:OnEditNumChange()
    if string.len(self.m_pEditBox:getText()) > 0 then
        self.placeHolder:setVisible(false) 
    else
        self.placeHolder:setVisible(true) 
    end
end

------------------- private: -----------------------------------

function FriendAddDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FriendAddDialog)

    return self
end

function FriendAddDialog:HandleClickReplaceBtn(args)
	LogInfo("FriendAddDialog:HandleClickReplaceBtn")
	self:RequestRecommendRoleList()
	return true
end

function FriendAddDialog:HandleClickFindBtn(args)
	LogInfo("FriendAddDialog:HandleClickFindBtn")
	local text = self.m_pEditBox:getText()
	local len = string.len(text)
	if len == 0 then
		GetCTipsManager():AddMessageTipById(145344)
		return
	end

	-- find number id or string id
	local req = CRequestSearchFriend.Create()
	req.roleid = text
	LuaProtocolManager.getInstance():send(req)
	return true
end

function FriendAddDialog:HandleClickAddBtn(args)
	LogInfo("FriendAddDialog:HandleClickAddBtn")

	local e = CEGUI.toWindowEventArgs(args)

	local strRoleID = e.window:getUserString("id")

	if strRoleID == nil then
		return true
	end

	local roleID = tonumber(strRoleID)
	if roleID <= 0 then
		return true
	end

	if BanListManager.getInstance():IsInBanList(roleID) then
		GetCTipsManager():AddMessageTipById(145665)
		return true
	end

	-- add friend
	gGetFriendsManager():RequestAddFriend(roleID)
	-- hide add button
	e.window:setVisible(false)
	-- show selected
	local winMgr = CEGUI.WindowManager:getSingleton()
	local selectedWndName = e.window:getUserString("selectedWndName")
	local selectedWnd = winMgr:getWindow(selectedWndName)
	if selectedWnd then
		selectedWnd:setVisible(true)
	end
	return true
end

function FriendAddDialog:RefreshRoleList()

	local index = 1
	local size = #FriendAddDialog.m_vDataList
	for i = 1, size, 1 do
		local roleid = FriendAddDialog.m_vDataList[index].roleid
		local name = FriendAddDialog.m_vDataList[index].name
		local level = FriendAddDialog.m_vDataList[index].rolelevel
		local school = FriendAddDialog.m_vDataList[index].school
		local online = FriendAddDialog.m_vDataList[index].online
		local shape = FriendAddDialog.m_vDataList[index].shape
		local camp = FriendAddDialog.m_vDataList[index].camp
		local relation = FriendAddDialog.m_vDataList[index].relation

		local namePrefix = tostring(index)
		local winMgr = CEGUI.WindowManager:getSingleton()
		local curCell = FriendAddDialog.m_vCellList[index]
		if curCell == nil then
			curCell = winMgr:loadWindowLayout("friendaddcell.layout", namePrefix)
			self.m_pRoleList:addChildWindow(curCell)
			FriendAddDialog.m_vCellList[index] = curCell
			-- 2 column
            local width = curCell:getPixelSize().width
            local height = curCell:getPixelSize().height
            local xPos = 10.0 
            local yPos = 2.0+(height+1.0)*(index-1)
            curCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))
		end

        
        local btnCellName = namePrefix.."friendaddcell"
		local btnCell= CEGUI.Window.toGroupButton(winMgr:getWindow(btnCellName))
        btnCell:EnableClickAni(false)

		local isMyFriend = gGetFriendsManager():isMyFriend(roleid)
		local strRoleID = tostring(roleid)

		--
		local headWndName = namePrefix.."friendaddcell/icon"
		local headWnd = winMgr:getWindow(headWndName)
		do
			local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shape)
			if shapeConf then
				local strHeadImg = gGetIconManager():GetImagePathByID(shapeConf.littleheadID):c_str()
				if strHeadImg ~= "" then
					headWnd:setProperty("Image",strHeadImg)
				end
			end
		end
		--
		local nameWndName = namePrefix.."friendaddcell/name"
		local nameWnd = winMgr:getWindow(nameWndName)
		nameWnd:setText(name)
		--
		local levelWndName = namePrefix.."friendaddcell/level"
		local levelWnd = winMgr:getWindow(levelWndName)
		levelWnd:setText(tostring(level))
		--
		local schoolWndName = namePrefix.."friendaddcell/zhiye"
		local schoolWnd = winMgr:getWindow(schoolWndName)
		local schoolConf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school)
		if schoolConf then
			schoolWnd:setProperty("Image", schoolConf.schooliconpath)
		end
		--
		local addBtnName = namePrefix.."friendaddcell/tianjia"
		local addBtn = winMgr:getWindow(addBtnName)
		addBtn:setUserString("id", strRoleID)
		addBtn:subscribeEvent("Clicked", FriendAddDialog.HandleClickAddBtn, self)
		addBtn:setVisible(isMyFriend == false)
		--
		local delBtnName = namePrefix.."friendaddcell/shanchu"
		local delBtn = winMgr:getWindow(delBtnName)
		delBtn:setVisible(false)
		--
		local selectedWndName = namePrefix.."friendaddcell/gouxuan"
		local selectedWnd = winMgr:getWindow(selectedWndName)
		selectedWnd:setID(1000 + index)
		selectedWnd:setVisible(isMyFriend == true)
		--
		addBtn:setUserString("selectedWndName", selectedWndName)

		index = index + 1
	end

end

function FriendAddDialog:RequestRecommendRoleList()
	-- request recommend friend list
	local t = os.time()
	if FriendAddDialog.m_nLastReplaceTime + 2 < t then
		FriendAddDialog.m_nLastReplaceTime = t
		local msg = CRecommendFriend.Create()
		LuaProtocolManager.getInstance():send(msg)
	else
        if FriendAddDialog.m_nLastReplaceTime ~= 0 then
		    GetCTipsManager():AddMessageTipById(142848)
        end
	end
end

function FriendAddDialog:Init(friendBean)
	-- cleanup cell
	self.m_pRoleList:cleanupNonAutoChildren()
	-- find friend to list[1]
	FriendAddDialog.m_vDataList = {}
	FriendAddDialog.m_vDataList[1] = friendBean
	FriendAddDialog.m_vCellList = {}
	-- refresh list
	self:RefreshRoleList()
end

function FriendAddDialog:InitList(friendBeanList)
	-- cleanup cell
	self.m_pRoleList:cleanupNonAutoChildren()
	-- init friend data list
	FriendAddDialog.m_vDataList = {}
	FriendAddDialog.m_vDataList = friendBeanList
	FriendAddDialog.m_vCellList = {}
	-- refresh list
	self:RefreshRoleList()
end

return FriendAddDialog

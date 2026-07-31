require "logic.dialog"
require "logic.family.familyduizhanzuduicell"
require "logic.family.familyduizhanzuduichildcell"
require "logic.team.anyteammenu"
 


familyduizhanzudui = {}
setmetatable(familyduizhanzudui, Dialog)
familyduizhanzudui.__index = familyduizhanzudui

local _instance
function familyduizhanzudui.getInstance()
	if not _instance then
		_instance = familyduizhanzudui:new()
		_instance:OnCreate()
	end
	return _instance
end

function familyduizhanzudui.getInstanceAndShow()
	if not _instance then
		_instance = familyduizhanzudui:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function familyduizhanzudui.getInstanceNotCreate()
	return _instance
end

function familyduizhanzudui.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function familyduizhanzudui.ToggleOpenClose()
	if not _instance then
		_instance = familyduizhanzudui:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function familyduizhanzudui.GetLayoutFileName()
	return "familyduizhanzudui.layout"
end

function familyduizhanzudui:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, familyduizhanzudui)
	return self
end


function familyduizhanzudui:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	--队伍列表
	self.ScrollGemType = CEGUI.toMultiColumnList(winMgr:getWindow("FrameWindow2/di1/list1"))
	
	--未组队玩家列表
	self.m_MemberScroll = CEGUI.toMultiColumnList(winMgr:getWindow("FrameWindow2/di2/list")) 
	
	--队伍数量和单人数量
	self.m_nTeamNum = winMgr:getWindow("FrameWindow2/text4")
	self.m_nMemberNum = winMgr:getWindow("FrameWindow2/text41")
	
	--刷新事件
    self.m_FreshBtn = CEGUI.Window.toPushButton(winMgr:getWindow("FrameWindow2/btn"))
    self.m_FreshBtn:subscribeEvent("MouseClick",familyduizhanzudui.FreshBtnClicked,self)
	
	--关闭事件
    self.m_CloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("FrameWindow2/X"))
    self.m_CloseBtn:subscribeEvent("MouseClick",familyduizhanzudui.OnCloseBtnEx,self)
	self.m_timeCount 	= 0       -- 控制刷新按钮平凡刷新
	self.m_IsCanFresh   = 0   -- 0 可以刷新 1 不可以刷新
	self.m_OtherMember ={}
	self.m_vTeamlist ={}
	self.ScreenMaxMemberNum     = 10 -- 一次请求的最大玩家数量
	self.ScreenMaxTeamMemberNum = 6   -- 一次请求的最大队伍数量
    self.m_bHasMoreRole   = 0
	self.m_bHasMoreTeam   = 0
	
    self:ClearData()
    self:SetTeamNumAndNoTeamMemberNum(0,0)

	self:Requestclanfightteamrolenum()
	self:Requestclanfightrolelist( 0 )
	self:Requestclanfightteamlist( 1)
end

function familyduizhanzudui:Requestclanfightteamrolenum()
    local p = require("protodef.fire.pb.team.crequestclanfightteamrolenum"):new()
    LuaProtocolManager:send(p)
end

function familyduizhanzudui:Requestclanfightrolelist( bFresh )
  	local p = require("protodef.fire.pb.team.crequestclanfightrolelist"):new()
    p.isfresh  = bFresh
	p.start = 0
	p.num   = self.ScreenMaxMemberNum 
    LuaProtocolManager:send(p)
end

function familyduizhanzudui:Requestclanfightteamlist( bFresh )
	local p = require("protodef.fire.pb.team.crequestclanfightteamlist"):new()
    p.isfresh  = bFresh
	p.start = 0
	p.num   = self.ScreenMaxTeamMemberNum
    LuaProtocolManager:send(p)
end

function familyduizhanzudui:ClearData()
    self.vMemberCell = {}
    self.vTeamCell = {}
    self.treeView = nil
end


--------------------------------------------------------------------------------------------------------------------------------
function familyduizhanzudui:RefreshTeamList( bHasMoreTeam, teamlist , bFresh)
   -- print("self.m_bHasMoreTeam ==============================" .. bHasMoreTeam)
   -- print("self.bTeamFresh ============================" .. bFresh)
    self.m_bHasMoreTeam = bHasMoreTeam
	
	if teamlist == nil then 
		return;
	end
	--print("self.teamlist num ============================" .. #teamlist )
	if bHasMoreTeam ~= 0 and #teamlist == 0 then 
		--刷新清理数据
		if  bFresh ~= 0  then
			self:ClearAllGemTeamCell()
			self:ClearAllMemberCell()
			self.treeView = nil
			self.ScrollGemType:cleanupNonAutoChildren()
			self.m_vTeamlist = nil
			self.m_vTeamlist ={}
		end
	
		return;
	end 
	
		--刷新清理数据
	if  bFresh ~= 0  then
	    self:ClearAllGemTeamCell()
		self:ClearAllMemberCell()
		self.treeView = nil
		self.ScrollGemType:cleanupNonAutoChildren()
		self.m_vTeamlist = nil
		self.m_vTeamlist ={}
		local sizeScroll = self.ScrollGemType:getPixelSize()
		local treeView = TreeView.create(self.ScrollGemType, sizeScroll.width, sizeScroll.height)
		self.treeView = treeView
		treeView:setPosition(0, 0)
		treeView:setParentItemClickCallFunc(familyduizhanzudui.clickTreeParentItem, self)  --父控件回调函数
		treeView:setChildItemClickCallFunc(familyduizhanzudui.clickTreeChildItem, self)    --子控件回调函数
		treeView:setReachEdgeCallFunc(self, familyduizhanzudui.OnNextPage)  
	end
   
    local start  =  #self.m_vTeamlist
	 
    --追加数据过滤重复数据
	if teamlist then
        for k,v in pairs(teamlist) do
		    local has = 0
			local pTeamInfo2 = v.teaminfobasic
		    for kk,vv in pairs(self.m_vTeamlist) do
			    local pTeamInfo = vv.teaminfobasic
				if( pTeamInfo.teamid == pTeamInfo2.teamid ) then 
					has = 1
					break
				end 
			end
			if  has == 0 then 
				table.insert(self.m_vTeamlist, v)
			end 
		end
    end

	local len =#self.m_vTeamlist
	 
	for nIndex=start+1, len do
        self:createOneTeam(self.treeView,nIndex)
	end
	if  bFresh ~= 0  then
		local offset = -10
		self.treeView:setScrollPos(offset)
    end
    self.treeView:fresh()
end

	

function familyduizhanzudui:createOneTeam(treeView,nIndex)
    local sizeScroll = self.ScrollGemType:getPixelSize()   
    local parentItem = treeView:addParentItem("TaharezLook/CellGroupButton2", sizeScroll.width, 106)
    if not parentItem then
        return 
    end
	
	local pTeamInfo = self.m_vTeamlist[nIndex].teaminfobasic
	local nTeamId  = pTeamInfo.teamid
	local nTeamLeaderId  = pTeamInfo.leaderid
	
    parentItem.item:setID( nTeamId )
    
	local layoutName = "familyduizhanzuduicell2.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
    local prefix = "familyduizhanzuduicell2"..nTeamLeaderId
	--print("prefix =============================" .. prefix)
	local teamCell = winMgr:loadWindowLayout(layoutName,prefix)
  
	teamCell.m_item 		= CEGUI.toItemCell(winMgr:getWindow(prefix .. "familyduizhanzuduicell2/item"))  
	teamCell.m_item			:Clear()
	teamCell.m_Eventbtn 	= CEGUI.toGroupButton(winMgr:getWindow(prefix .. "familyduizhanzuduicell2/item/button"));  
	teamCell.m_InfoBg 		= winMgr:getWindow(prefix .. "familyduizhanzuduicell2/kuang")
	teamCell.m_Name 		= winMgr:getWindow(prefix .. "familyduizhanzuduicell2/name")
	teamCell.m_Lv 	    	= winMgr:getWindow(prefix .. "familyduizhanzuduicell2/lv1")
	teamCell.m_TeamIcon 	= winMgr:getWindow(prefix .. "familyduizhanzuduicell2/image")
	teamCell.m_Arrow 		= winMgr:getWindow(prefix .. "familyduizhanzuduicell2/arrow")
	
	teamCell.m_Eventbtn:subscribeEvent("MouseButtonUp", self.clickTreeParentIcon, self)  
	teamCell.m_Eventbtn:setID( nTeamLeaderId )
	
	local pLeaderInfo = self.m_vTeamlist[nIndex].memberlist[1] -- 会长信息
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder( pLeaderInfo.shape)
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	teamCell.m_item:SetImage(image)
	teamCell.m_Name:setText( pLeaderInfo.rolename )
	teamCell.m_Lv:setText(tostring( pLeaderInfo.level))
	local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(pLeaderInfo.school)
	teamCell.m_TeamIcon:setProperty("Image", schoolconf.schooliconpath)
    teamCell.m_Arrow:setProperty("Image","set:diban2 image:xiafan" ) 
	teamCell.m_Arrow:setVisible(true)
	
    parentItem.item:addChildWindow(teamCell)
    parentItem.teamCell = teamCell
    self.vTeamCell[#self.vTeamCell + 1] = teamCell
   
   ----------------------------------
   --子接口
    local pMemberlist = self.m_vTeamlist[nIndex].memberlist
	for nIndexCell=2,pTeamInfo.membermaxnum  do 
	    if nIndexCell > pTeamInfo.membernum then
			self:createOneNullCellToTree(treeView,parentItem,nTeamId,nTeamLeaderId)  --空的格子
		else
			local pMemberInfo = pMemberlist[nIndexCell]
			self:createOneMemberCellToTree(treeView,parentItem,nTeamId,nTeamLeaderId,nIndexCell,pMemberInfo)	--成员
		end		
    end
end

-- 一个成员信息
function familyduizhanzudui:createOneMemberCellToTree(treeView,parentItem,nTeamId,nTeamLeaderId,nIndexCell,memberInfo)
    local sizeScroll = self.ScrollGemType:getPixelSize()
    local childItem = treeView:addChildItem("TaharezLook/CellGroupButton2", parentItem, sizeScroll.width, 106)
	if not childItem then
        return 
    end
   
    local memberCell = familyduizhanzuduichildcell.new(childItem,0) 
	memberCell.m_Eventbtn:setVisible(false)
	memberCell.m_AddTeam:setVisible(false)
	memberCell.m_TipText:setVisible(false)
	memberCell.m_InfoBg:setVisible(true)
	memberCell.m_item:setVisible(true)
	
 
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(memberInfo.shape)
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	memberCell.m_item:SetImage(image)
	memberCell.m_Name:setText(memberInfo.rolename)
	memberCell.m_Lv:setText(tostring(memberInfo.level))
	local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(memberInfo.school)
	memberCell.m_TeamIcon:setProperty("Image", schoolconf.schooliconpath)

	memberCell.m_nTeamid 		= nTeamId 
	memberCell.m_nTeamLeaderId 	= nTeamLeaderId 
	memberCell.m_nIndexCell     = nIndexCell
	memberCell.m_nMemberid 		= memberInfo.roleid
	
    childItem.MemberCell 		= memberCell
    self.vMemberCell[#self.vMemberCell + 1] = memberCell
end
 

-- 空的格子
function familyduizhanzudui:createOneNullCellToTree(treeView,parentItem,nTeamId,nTeamLeaderId)
    local sizeScroll = self.ScrollGemType:getPixelSize()
    local childItem = treeView:addChildItem("TaharezLook/CellGroupButton2", parentItem, sizeScroll.width, 106)
    if not childItem then
        return
    end
    local nullCell = familyduizhanzuduichildcell.new(childItem,0) 
	nullCell.m_InfoBg:setVisible(false)
	nullCell.m_Eventbtn:setVisible(false)
	nullCell.m_item:setVisible(true) 
	nullCell.m_AddTeam:setVisible(true)
	nullCell.m_TipText:setVisible(true)
	
	nullCell.m_nTeamid 		 = nTeamId 
	nullCell.m_nTeamLeaderId = nTeamLeaderId 
	nullCell.m_nIndexCell    = -1
	nullCell.m_nMemberid     = -1
	
    childItem.MemberCell = nullCell
    self.vMemberCell[#self.vMemberCell + 1] = nullCell
end



function familyduizhanzudui:ClearAllMemberCell()
	for k, v in pairs(self.vMemberCell) do
		v:DestroyDialog()
        self.vMemberCell[k] = nil
	end
    self.vMemberCell = {}
end

function familyduizhanzudui:ClearAllGemTeamCell()
	for k, v in pairs(self.vTeamCell) do
	    if v then
            local parentLayout = v:getParent()
            if parentLayout then
                parentLayout:removeChildWindow(v)
                CEGUI.WindowManager:getSingleton():destroyWindow(v)
            end
        end
        self.vTeamCell[k] = nil
	end
    self.vTeamCell = {}
end


--刷新箭头
function familyduizhanzudui:refreshOpenParentItem(treeView,nGemTypeId)
    for k,v in pairs(treeView.parentItems) do
        if v.item:getID() == nGemTypeId then
            if treeView.openedParentItem then
                v.teamCell.m_Arrow:setProperty("Image","set:diban2 image:up")  
            else
                v.teamCell.m_Arrow:setProperty("Image","set:diban2 image:xiafan")  
            end
        else
           v.teamCell.m_Arrow:setProperty("Image","set:diban2 image:xiafan")
        end
    end
end
 
 
 --父头像控件回调函数
function familyduizhanzudui:clickTreeParentIcon(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    local nMemberId = wnd:getID()
	local dlg = Anyteammenu.getInstanceAndShow()
	local t = nil
	local myId = gGetDataManager():GetMainCharacterID()
	if  nMemberId  == myId then
		t = dlg.TYPE.MAINUI_SELF
	else
		t = dlg.TYPE.MAINUI_MEMBER_SEE_MEMBER
	end
	dlg:InitBtn(t, nMemberId, 1)
	dlg:setTriggerWnd(wnd)
	local p = wnd:GetScreenPos()
	local s = dlg:GetWindow():getPixelSize()
	dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, p.x-s.width-10), CEGUI.UDim(0, p.y)))
end

--父控件回调函数
function familyduizhanzudui:clickTreeParentItem(wnd)
    if not wnd then
        return
    end
    local nGemTypeId = wnd:getID()
    self:refreshOpenParentItem(self.treeView, nGemTypeId)
end

--子控件回调函数
function familyduizhanzudui:clickTreeChildItem(wnd)
    if not wnd then
        return
    end    
    local nTeamId 			= wnd.MemberCell.m_nTeamid 
	local nTeamLeaderId		= wnd.MemberCell.m_nTeamLeaderId 
	local nMemberId			= wnd.MemberCell.m_nMemberid  
	local nMemberIndex		= wnd.MemberCell.m_nIndexCell  -- 成员在队伍中的索引
	if nTeamId >= 0 then 
	    if nMemberId >=0 then 
			local dlg = Anyteammenu.getInstanceAndShow()
			local t = nil
			local myId = gGetDataManager():GetMainCharacterID()
			if  nMemberId  == myId then
				t = dlg.TYPE.MAINUI_SELF
			elseif nTeamLeaderId == myId    then
				t = dlg.TYPE.MAINUI_LEADER_SEE_MEMBER
			else
				t = dlg.TYPE.MAINUI_MEMBER_SEE_MEMBER
			end
			dlg:InitBtn(t, nMemberId, nMemberIndex)
			dlg:setTriggerWnd(wnd)
			local p = wnd:GetScreenPos()
			local s = dlg:GetWindow():getPixelSize()
			dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, p.x-s.width-10), CEGUI.UDim(0, p.y)))
		else 
			if GetTeamManager():IsOnTeam() then
				GetCTipsManager():AddMessageTipById(140855)
			else
				GetTeamManager():RequestJoinOneTeam(nTeamLeaderId)
			end
		end 
	else
       	print("error:  familyduizhanzudui:clickTreeChildItem")
	end 
end

 

 
--------------------------------------------------------------------------------------------------------------------------------------------------
--设置队伍数量和未组队玩家数
function familyduizhanzudui:SetTeamNumAndNoTeamMemberNum(nTeamNum,nMemberNum)
    if nTeamNum == nil then
        self.m_nTeamNumm_nTeamNum:setText("0")
    else
        self.m_nTeamNum:setText(tonumber(nTeamNum))
	end
	
	if nMemberNum == nil then
        self.m_nMemberNum:setText("0")
    else
        self.m_nMemberNum:setText(tonumber(nMemberNum))
	end
	
end
 

----------------------------------------------------------------------------------------------------------------- 
--刷新未组队玩家列表
function familyduizhanzudui:UpdateNoTeamMemberList( bHasMoreRole,memberData , bFresh)
 
    self.m_bHasMoreRole = bHasMoreRole
	if memberData == nil then 
		return;
	end
	if bHasMoreRole ~= 0 and #memberData == 0 then 
		--刷新清理数据
		if  bFresh ~= 0  then
			if self.m_MemberList then
				self.m_MemberList:destroyCells()
			end 
			self.m_MemberList = nil
			self.m_OtherMember = nil
			self.m_OtherMember = {}
		end
		return;
	end 
	
	--刷新清理数据
	if  bFresh ~= 0  then
	    if self.m_MemberList then
			self.m_MemberList:destroyCells()
        end 
		self.m_MemberList = nil
		self.m_OtherMember = nil
		self.m_OtherMember = {}
	end
	
	--追加数据
	if memberData then
        for k,v in pairs(memberData) do
			table.insert(self.m_OtherMember, v)
		end
    end
	
	local len = #self.m_OtherMember
    if not self.m_MemberList then
        local listSize = self.m_MemberScroll:getPixelSize()
        self.m_MemberList = TableView.create(self.m_MemberScroll)
        self.m_MemberList:setViewSize(listSize.width, listSize.height)
        self.m_MemberList:setPosition(0, 0)
        self.m_MemberList:setDataSourceFunc(self, familyduizhanzudui.tableViewGetCellAtIndex)
        self.m_MemberList:setReachEdgeCallFunc(self, familyduizhanzudui.HandleNextPage) 
    end
    self.m_MemberList:setCellCountAndSize(len, 350, 450)
    self.m_MemberList:reloadData()
end

-- 设置单个列表项的数据
function familyduizhanzudui:tableViewGetCellAtIndex(tableView, idx, cell)
   if idx == nil then
        return
    end
    if tableView == nil then
        return
    end
    idx = idx + 1
    if not cell then
        cell = familyduizhanzuduicell.CreateNewDlg(tableView.container)
		cell.m_Eventbtn:subscribeEvent("MouseButtonUp", self.handleIconClicked, self)
    end
    if cell and self.m_OtherMember then
        cell:SetTeamInfo(self.m_OtherMember[idx].roleid, self.m_OtherMember[idx].level, self.m_OtherMember[idx].rolename, self.m_OtherMember[idx].shape , self.m_OtherMember[idx].schoold)
		cell.m_Eventbtn:setID(cell.m_ID)
    end
    return cell
end

function familyduizhanzudui:handleIconClicked(args) 
    local wnd = CEGUI.toWindowEventArgs(args).window
	if not wnd then
        return
    end  
    local nMemberId = wnd:getID()
	local dlg = Anyteammenu.getInstanceAndShow()
	local t = nil
	if GetTeamManager():IsOnTeam() then  -- 有队伍
		t = dlg.TYPE.MAINUI_INVITEADDTEAN
	else -- 没队
	    local myId = gGetDataManager():GetMainCharacterID() 
		if  myId ==  nMemberId then  --点自己
			t = dlg.TYPE.MAINUI_CREATE
		else --点别人
			t = dlg.TYPE.MAINUI_INVITEADDTEAN
		end
	end 
	dlg:InitBtn(t, nMemberId, -1)
	dlg:setTriggerWnd(wnd)
	local p = wnd:GetScreenPos()
	local s = dlg:GetWindow():getPixelSize()
	dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, p.x-s.width-10), CEGUI.UDim(0, p.y)))
end

-----------------------------------------------------------------------------------------
--队伍列表滑动回调
function familyduizhanzudui:OnNextPage(args, isTop)
	 if  isTop == false then 
        if self.m_bHasMoreTeam == 0 then
	        self.m_bHasMoreTeam  = -1
            local BarPos = self.ScrollGemType:getVertScrollbar():getScrollPosition()
            self.ScrollGemType:getVertScrollbar():Stop()
            self.ScrollGemType:getVertScrollbar():setScrollPosition(BarPos)
			local p = require("protodef.fire.pb.team.crequestclanfightteamlist"):new()
			p.isfresh  = 0
			local nTeamId =  0
			for k,v in pairs(self.m_vTeamlist) do
				local pTeamInfo = v.teaminfobasic
				 if( pTeamInfo.teamid > nTeamId ) then 
					nTeamId =  pTeamInfo.teamid
				 end 
			end
			p.start = nTeamId
			p.num   = self.ScreenMaxTeamMemberNum
			--print("p.start============================== " .. p.start)
			--print("p.num=============================== " .. p.num)
			LuaProtocolManager:send(p)
        end
    end
end

--未组队玩家列表滑动回调 
function familyduizhanzudui:HandleNextPage(tableView, isTop)
 
    if  isTop == false then 
        if self.m_bHasMoreRole == 0 then
	        self.m_bHasMoreRole  = -1
            local BarPos = self.m_MemberScroll:getVertScrollbar():getScrollPosition()
            self.m_MemberScroll:getVertScrollbar():Stop()
            self.m_MemberScroll:getVertScrollbar():setScrollPosition(BarPos)
			local p = require("protodef.fire.pb.team.crequestclanfightrolelist"):new()
			p.isfresh  = 0
			local roleId =  0
			for k,v in pairs(self.m_OtherMember) do
				 if( v.roleid > roleId ) then 
					roleId =  v.roleid
				 end 
			end
			p.start = roleId
			p.num   = self.ScreenMaxMemberNum
			--print("p.start============================== " .. p.start)
			--print("p.num=============================== " .. p.num)
			LuaProtocolManager:send(p)
        end
    end
    return true
end

 

 -------------------------------------------------------------------------------------------------------------------------
 --自动刷新
function familyduizhanzudui:update(delta)
	if m_IsCanFresh ~= 0  then 
		if gGetServerTime() - self.m_timeCount > (1000 * 5 * 1 ) then
			m_IsCanFresh = 0
		end
	end
end


--刷新事件
function familyduizhanzudui:FreshBtnClicked(args)
   if m_IsCanFresh == 0 then
        m_IsCanFresh = 1    
        self.m_timeCount = gGetServerTime()
		self:Requestclanfightteamrolenum()
		self:Requestclanfightrolelist(1)
		self:Requestclanfightteamlist(1)
	else
	    GetCTipsManager():AddMessageTipById(410063)
		--print(" no can fresh !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    end 	
end

--关闭
function familyduizhanzudui:OnCloseBtnEx()
    self:DestroyDialog()
end

	
return familyduizhanzudui
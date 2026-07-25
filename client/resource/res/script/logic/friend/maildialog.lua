require "logic.dialog"

MailDialog = {}
setmetatable(MailDialog, Dialog)
MailDialog.__index = MailDialog

local _instance
function MailDialog.getInstance()
	if not _instance then
		_instance = MailDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function MailDialog.getInstanceAndShow()
	if not _instance then
		_instance = MailDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function MailDialog.getInstanceNotCreate()
	return _instance
end

function MailDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            if _instance.m_MailContentDlg then
                _instance.m_MailContentDlg:OnClose()
           end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function MailDialog.ToggleOpenClose()
	if not _instance then
		_instance = MailDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function MailDialog.GetLayoutFileName()
	return "friendyoujianlog.layout"
end

function MailDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MailDialog)
	return self
end

function MailDialog:OnCreate()
	Dialog.OnCreate(self)

    SetPositionOfWindowWithLabel(self:GetWindow())

	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_MailList = CEGUI.Window.toScrollablePane(winMgr:getWindow("friendyoujianlog/liebiao/diban/maillist"))

    self.m_MailFrame = winMgr:getWindow("friendyoujianlog/mailframe")
    self.m_MailContentFrame = winMgr:getWindow("friendyoujianlog/mailframe/xinxi")

    self.m_MailBackgroundTips = winMgr:getWindow("friendyoujianlog/mailbackgroundtips")
    self.m_MailBackgroundTips:setVisible(true)

    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", FriendMailLabel.DestroyDialog, nil)

    self.m_vMailCellList = {}

    self:RefreshMailListView()
end


function MailDialog:RefreshMailListView()
	local vDataList = MailListManager.getInstance():GetMailList()
	local nSize = #vDataList

	local vCellList = self.m_vMailCellList
	local pListView = self.m_MailList

	local index = 1
	for i = 1, nSize do
		local kind = vDataList[index].kind
		local id = vDataList[index].id
		local title = vDataList[index].title
		local time = vDataList[index].time
		local isRead = (vDataList[index].readflag == 1)
		local isGotoNpc = (vDataList[index].npcid > 0)

		local namePrefix = tostring(index)
		local winMgr = CEGUI.WindowManager:getSingleton()
		local curCell = vCellList[index]
		if curCell == nil then
			curCell = winMgr:loadWindowLayout("friendmailcell.layout", namePrefix)
			pListView:addChildWindow(curCell)
			vCellList[index] = curCell
			local height = curCell:getPixelSize().height
			local yPos = 1.0 +(height + 2.0) *(index - 1)
			local xPos = 5.0
			curCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
		end

		local cellBtn = CEGUI.Window.toGroupButton(curCell)
		if cellBtn:isEventPresent("SelectStateChanged") == false then
			cellBtn:subscribeEvent("SelectStateChanged", MailDialog.HandleClickMailCell, self)
		end
		cellBtn:setUserString("kind", tostring(kind))
		cellBtn:setUserString("id", tostring(id))
		cellBtn:EnableClickAni(false)

		local titleWndName = namePrefix .. "friendmailcell/title"
		local titleWnd = winMgr:getWindow(titleWndName)
		titleWnd:setText(title)

		local iconWndName = namePrefix .. "friendmailcell/bg/icon"
		local iconWnd = winMgr:getWindow(iconWndName)
		local strIconImg = ""
		if isGotoNpc == false then
			if isRead then
				strIconImg = gGetIconManager():GetImagePathByID(1153):c_str()
			else
				strIconImg = gGetIconManager():GetImagePathByID(1153):c_str()
			end
		else
			if isRead then
				strIconImg = gGetIconManager():GetImagePathByID(1048):c_str()
			else
				strIconImg = gGetIconManager():GetImagePathByID(1048):c_str()
			end
		end
		if strIconImg ~= "" then
			iconWnd:setProperty("Image", strIconImg)
		end

		local timeWndName = namePrefix .. "friendmailcell/time"
		local timeWnd = winMgr:getWindow(timeWndName)
		timeWnd:setText(time)

		index = index + 1
	end

	for i = index, #vCellList, 1 do
		vCellList[index]:setVisible(false)
		index = index + 1
	end
end

function MailDialog:HandleClickMailCell(args)
	local e = CEGUI.toWindowEventArgs(args)

	local strKind = e.window:getUserString("kind")
	local strID = e.window:getUserString("id")

	if not strID then
		return true
	end

	local kind = tonumber(strKind)
	local id = tonumber(strID)

	self:OnSelectMailCell(kind, id)
	return true
end

function MailDialog:OnSelectMailCell(kind, id)
	self:ChangeMailFrameForSelectMail()

	if self.m_MailContentDlg == nil then
		self.m_MailContentDlg = FriendDialogMailContent.CreateNewDlg(self.m_MailContentFrame, 0)
		self.m_MailContentDlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, 5.0), CEGUI.UDim(0.0, 5.0)))
	end

	local strContent = ""
	local awardID = 0
	local items = {}
	local npcID = 0
	local isAlreadyGet = false
    local awardmoney = 0
    local awardexp = 0
    local awardgold = 0
    local awardfushi = 0
    local awardvipexp = 0
	local vDataList = MailListManager.getInstance():GetMailList()
	for k, v in pairs(vDataList) do
		if kind == v.kind and id == v.id then

			if v.readflag == 0 then
				v.readflag = 1
				local req = require "protodef.fire.pb.item.cmailread".Create()
				req.kind = v.kind
				req.id = v.id
				LuaProtocolManager.getInstance():send(req)
			end

			if v.kind == 0 then
				strContent = GameTable.message.GetCMessageTipTableInstance():getRecorder(v.contentid).msg
			elseif v.kind == 1 then
				
				--dumpT(v.content,"v.content")
				strContent = v.content
			end

			awardID = v.awardid
			items = v.items
			npcID = v.npcid
			isAlreadyGet = (v.getflag == 1)
            awardmoney = v.awardmoney
            awardexp = v.awardexp
            awardgold = v.awardgold
            awardfushi = v.awardfushi
            awardvipexp = v.awardvipexp
			break
		end
	end

	self.m_MailContentDlg:Init(kind, id, strContent, awardID, items, npcID > 0, npcID, isAlreadyGet)
    self.m_MailContentDlg:AddMoneyItem(awardmoney,awardexp,awardgold,awardfushi, awardvipexp)
    self.m_MailContentDlg:checkGetButtonShow()
end

function MailDialog:ChangeMailFrameForSelectMail()
	self.m_MailFrame:setVisible(true)
	self.m_MailBackgroundTips:setVisible(false)
end

function MailDialog:RefreshMailLabelNotify()
	local mailNotReadMsgNum = MailListManager.getInstance():GetNotReadNum()
--	self.m_MailGroupNotify:setVisible(mailNotReadMsgNum > 0)   --���������
end

function MailDialog.GlobalOnNewMail()
	if CChatOutBoxOperatelDlg.getInstanceNotCreate() then
		CChatOutBoxOperatelDlg.getInstanceNotCreate():RefreshNotify()
	end
	if _instance then
		_instance:RefreshMailLabelNotify()
	end
end

function MailDialog.GlobalGetMailNotReadNum()
	if MailListManager.getInstanceNotCreate() then
		return MailListManager.getInstance():GetNotReadNum()
	end
	return 0
end


return MailDialog
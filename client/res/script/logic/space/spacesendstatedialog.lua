require "logic.dialog"

Spacesendstatedialog = {}
setmetatable(Spacesendstatedialog, Dialog)
Spacesendstatedialog.__index = Spacesendstatedialog

local _instance

function Spacesendstatedialog.getInstance()
	if not _instance then
		_instance = Spacesendstatedialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Spacesendstatedialog.getInstanceAndShow()
	if not _instance then
		_instance = Spacesendstatedialog:new()
		_instance:OnCreate()
        _instance:registerEvent()
	else
		_instance:SetVisible(true)
	end
	return _instance
end


function Spacesendstatedialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spacesendstatedialog:OnClose()
    self:removeEvent()
    self:clearData()
	Dialog.OnClose(self)
end

function Spacesendstatedialog.GetLayoutFileName()
	return "kongjianfazhuangtai_mtg.layout"
end

function Spacesendstatedialog.getInstanceNotCreate()
	return _instance
end


function Spacesendstatedialog:clearData()
    m_PrevContentWidth = 0

end

function Spacesendstatedialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacesendstatedialog)
    self:clearData()
	return self
end

function Spacesendstatedialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:removeEvent(Eventmanager.eCmd.sendStateGetImageResult,self,Spacesendstatedialog.sendStateGetImageResult)
end

function Spacesendstatedialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:addEvent(Eventmanager.eCmd.sendStateGetImageResult,self,Spacesendstatedialog.sendStateGetImageResult)

end

function Spacesendstatedialog:sendStateGetImageResult(vstrParam)
    if #vstrParam < 1 then
        return
    end
   
    local Spacemanager = require("logic.space.spacemanager")
    local strUrlKey = Spacemanager.strSendStateUrlKey
    local pCeguiImage = gGetSpaceManager():GetCeguiImageWithUrl(strUrlKey)
    if pCeguiImage then
        self.itemCellHead:SetImage(pCeguiImage)
        self.pEffect:Stop()
    end
end

function Spacesendstatedialog:OnCreate()
     Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	--local layoutName = "kongjianfazhuangtai_mtg.layout"
	--self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)

	--self.btnBack = CEGUI.toPushButton(winMgr:getWindow("kongjianliuyan_mtg/btnfanhui"))
    self.labelPlaceholder = winMgr:getWindow("kongjianfazhuangtai_mtg/bg1/haineng")

    self.richEditBox = CEGUI.toRichEditbox(winMgr:getWindow("kongjianfazhuangtai_mtg/bg1/ed"))
    self.richEditBox:SetTextAcceptMode(CEGUI.eTextAcceptMode_OnlyEnter)
	--self.richEditBox:setWordWrapping(false)
	--self.richEditBox:SetBackGroundEnable(false)
	--self.richEditBox:SetForceHideVerscroll(true)
	--self.richEditBox:SetTextBottomEdge(0)
	self.richEditBox:SetEmotionScale(CEGUI.Vector2(1, 1))-- s_EmotionScale)
	--self.richEditBox:setMaxTextLength(CHAT_INPUT_CHAR_COUNT_MAX)
	self.richEditBox:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.richEditBox:getProperty("NormalTextColour")))
	--self.richEditBox:subscribeEvent("EditboxFullEvent", CChatOutputDialog.OnInputBoxFull, self)
	--self.richEditBox:subscribeEvent("TextAccepted", CChatOutputDialog.HandleSendChat, self)
	self.richEditBox:subscribeEvent("TextChanged", Spacesendstatedialog.TextContentChanged, self)
    self.richEditBox:subscribeEvent("KeyboardTargetWndChanged", Spacesendstatedialog.OnKeyboardTargetWndChanged, self)

    self.itemCellHead = CEGUI.toItemCell(winMgr:getWindow("kongjianfazhuangtai_mtg/bg2/btn"))
    self.itemCellHead:subscribeEvent("MouseClick", Spacesendstatedialog.clickAddImage, self)
    --self.itemCellHead:SetBackGroundEnable(false)

    self.labelLeftWordCount = winMgr:getWindow("kongjianfazhuangtai_mtg/shuzi")

    self.btnEmotion = CEGUI.toPushButton(winMgr:getWindow("kongjianfazhuangtai_mtg/btn")) 
    self.btnEmotion:subscribeEvent("MouseClick", Spacesendstatedialog.clickEmotion, self)

    self.btnSend = CEGUI.toPushButton(winMgr:getWindow("kongjianfazhuangtai_mtg/btn2")) 
    self.btnSend:subscribeEvent("MouseClick", Spacesendstatedialog.clickSendAll, self)

    self:refreshLeftCountLabel()

    self.pEffect = gGetGameUIManager():AddUIEffect(self.itemCellHead, MHSD_UTILS.get_effectpath(10374), true)
end

function  Spacesendstatedialog:TextContentChanged(e)
--[[
    local tw = self.richEditBox:GetExtendSize().width
	local rw = self.richEditBox:getWidth().offset

	if tw > rw and m_PrevContentWidth > tw then
		self.richEditBox:getHorzScrollbar():setScrollPosition(rw - tw)
		self.richEditBox:Refresh()
		self.richEditBox:activate()
	end

	m_PrevContentWidth = tw
    --]]

    self:refreshLeftCountLabel()

end

function Spacesendstatedialog:refreshLeftCountLabel()
    
    local strText = self.richEditBox:GetParseText() --""
    local strPurText = self.richEditBox:GetPureText() --"1"
    local strGenParseText = self.richEditBox:GenerateParseText(false) --<T t="1">

    --local 
    local nCurLen = self.richEditBox:GetCharCount() --string.len(strGenParseText)
    local nMaxLen = getSpaceManager().nMaxSendState

    local nLeftLen = nMaxLen - nCurLen
    if nLeftLen < 0  then
        nLeftLen = 0
    end
    --self.labelLeftWordCount:setText(tostring(nLeftLen))

    local strLeftNum = require("utils.mhsdutils").get_resstring(11530)
    local sb = StringBuilder.new()
    sb:Set("parameter1",nLeftLen)
    strLeftNum = sb:GetString(strLeftNum)
    sb:delete()
    self.labelLeftWordCount:setText(strLeftNum)

end


function Spacesendstatedialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richEditBox then
        self.labelPlaceholder:setVisible(false)
    elseif self.richEditBox:GenerateParseText() == "" then
        self.labelPlaceholder:setVisible(true)
    end
end

function Spacesendstatedialog:inputCallBack(insertDlg,nType,nKey)
    local chatManager = GetChatManager()
    local richEditBox = self.richEditBox
    local InsertDlg = require("logic.chat.insertdlg")
    if InsertDlg.eFunType.emotion == nType then
        chatManager:inputCallBack_emotion(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.normalChat == nType then
        chatManager:inputCallBack_normalChat(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.sell == nType then
        chatManager:inputCallBack_sell(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.history == nType then
        chatManager:inputCallBack_history(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.item == nType then
        chatManager:inputCallBack_item(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.pet == nType then
        chatManager:inputCallBack_pet(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.task == nType then
        
        chatManager:inputCallBack_task_space(insertDlg,nType,nKey,richEditBox)
    end
    self:refreshLeftCountLabel()
end

function Spacesendstatedialog:clickEmotion(args)
    local InsertDlg = require("logic.chat.insertdlg")
    local dlg = InsertDlg.getInstanceAndShow()
	dlg.willCheckTipsWnd = true
    dlg:setDelegate(self,Spacesendstatedialog.inputCallBack)

    self.labelPlaceholder:setVisible(false)
end

function Spacesendstatedialog:clickAddImage(args)

    local Spaceselpicdialog = require("logic.space.spaceselpicdialog")
    local selPicDialog = Spaceselpicdialog.getInstanceAndShow()
    selPicDialog:setDelegate(self,Spaceselpicdialog.eCallBackType.clickCamera ,Spacesendstatedialog.clickCamera)
    selPicDialog:setDelegate(self,Spaceselpicdialog.eCallBackType.clickPhoto ,Spacesendstatedialog.clickPhoto)
    selPicDialog:setDelegate(self,Spaceselpicdialog.eCallBackType.clickDel ,Spacesendstatedialog.clickDel)

end


function Spacesendstatedialog:clickCamera(selPicDialog)
    
    local SpaceManager = require("logic.space.spacemanager")
    local spManager = getSpaceManager()
    spManager:registerCallBack(Spacemanager.ePhotoCallBackType.sendState)
    local photoPicker = PhotoPicker:shared()
    photoPicker:openCamera()

    --wangbin test
    --local pCocosImage = gGetSpaceManager():getTestCocos2dImage("/testhead.png")
    --getSpaceManager():sendStateGetImageResultFromPhone(pCocosImage)
end

function Spacesendstatedialog:clickPhoto(selPicDialog)
    local SpaceManager = require("logic.space.spacemanager")

    local spManager = getSpaceManager()
    spManager:registerCallBack(Spacemanager.ePhotoCallBackType.sendState)
    local photoPicker = PhotoPicker:shared()
    photoPicker:openAlbum()
end

function Spacesendstatedialog:clickDel(selPicDialog)
    self.itemCellHead:SetImage(nil)
    self.pEffect:Play()
end

function Spacesendstatedialog:clickSendAll(args)
    local strContent = self.richEditBox:GenerateParseText(false)

    if strContent =="" then
        local strShowTip = require("utils.mhsdutils").get_resstring(11531)
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end

    local nLen = self.richEditBox:GetCharCount() --string.len(strContent)
    local nMaxLen = getSpaceManager().nMaxSendState
    if nLen >= nMaxLen then
        local strShowTip = require("utils.mhsdutils").get_resstring(11544)
        local sb = StringBuilder.new()
        sb:Set("parameter1",nMaxLen)
        strShowTip = sb:GetString(strShowTip)
        sb:delete()

		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end

    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType

    local nnRoleId = getSpaceManager():getMyRoleId()
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local strImageData = "" --Spaceprotocol.strFileDataParam
    local nShapeId = gGetDataManager():GetMainCharacterShape()
    local nLevel = gGetDataManager():GetMainCharacterLevel()

    local pHeadImage = self.itemCellHead:GetImage()
    if pHeadImage then
        local pCocosImage = getSpaceManager():getSendStateCocosImage()
        getSpaceManager():saveImageToCurString(pCocosImage)
        strImageData = Spaceprotocol.strFileDataParam --"$filedata$"

        local nLength = gGetSpaceManager():GetCurStringLength()
        if nLength > getSpaceManager().nPicLengthMax then
            local strShowTip = require("utils.mhsdutils").get_msgtipstring(162168)
		    GetCTipsManager():AddMessageTip(strShowTip)
            return
        end

    else

    end

    local strOldText = self.richEditBox:GenerateParseText(false)
    local wstrPureText = self.richEditBox:GetPureText()

    strContent = self:ProcessChatLinks(wstrPureText, self.richEditBox)

    --local wstrPureText = self.richEditBox:GetPureText()
    --strContent = GetChatManager():ProcessChatLinks(wstrPureText, self.richEditBox)


    require("logic.space.spacepro.spaceprotocol_sendState").request(nnRoleId,strContent,strImageData,nSpaceType,nShapeId,nLevel)

     if GetChatManager() then
        local strHistory = self.richEditBox:GenerateParseText(false)
        local strColor = getSpaceManager():getNormalTextColor()
        strHistory = getSpaceManager():stringReplaceToColor(strHistory,strColor)

        GetChatManager():AddToChatHistory(strHistory)
    end

    Spacesendstatedialog.DestroyDialog()


   
 
end


function Spacesendstatedialog:ProcessChatLinks(pureText, inputbox)

    local m_TipsLinkVec = GetChatManager():getTempData()

	local Text = pureText:gsub("\"", "&quot;")
    local strCorrectText = string.gsub(Text,"-","_")

	local ret = ""
	local tmpVec = { }
	local pos = nil
	local color = CEGUI.PropertyHelper:colourToString(inputbox:GetColourRect().top_left)
	local link = ""

	for k, v in ipairs(m_TipsLinkVec) do
        local strName = v.name
        strName = string.gsub(strName,"-","_")
		pos = string.find(strCorrectText,"%[" .. strName .. "%]") --Text:find("%[" .. v.name .. "%]")
		if pos then
			local len1 = string.len("%[" .. v.name .. "%]")
			local len2 = string.len(Text)

			tmpVec[1] = string.sub(Text, 1, pos-1 ) 
			tmpVec[2] = string.sub(Text, pos - 2 + len1, len2)

			link = v.link
			break
		end
	end

	m_TipsLinkVec = { }
    GetChatManager():clearTempData()

	if not pos then
		tmpVec[1] = Text
	end

	for k, v in ipairs(tmpVec) do
		local tmpText = v
		if k == 2 then
			ret = ret .. link
		end

		local subPos1 = tmpText:find("#%d%d%d")

		if not subPos1 then
			ret = ret .. "<T t=\"" .. tmpText .. "\" c=\"" .. color .. "\"></T>"
		else
			while subPos1 do
				local sub1 = tmpText:sub(1, subPos1 - 1)
				local sub2 = tmpText:sub(subPos1 + 1, subPos1 + 3)

				if sub1 ~= "" then
					ret = ret .. "<T t=\"" .. sub1 .. "\" c=\"" .. color .. "\"></T>" .. "<E e=\"" .. sub2 .. "\"></E>"
				else
					ret = ret .. "<E e=\"" .. sub2 .. "\"></E>"
				end

				tmpText = tmpText:sub(subPos1 + 4, tmpText:len())

				subPos1 = tmpText:find("#%d%d%d")
				if not subPos1 then
					ret = ret .. "<T t=\"" .. tmpText .. "\" c=\"" .. color .. "\"></T>"
				end
			end
		end

	end

	return ret
end

return Spacesendstatedialog

Spaceinputdialog = {}
Spaceinputdialog.__index = Spaceinputdialog

Spaceinputdialog.eCallBackType = 
{
    clickBack = 1,
    clickSend=2
}

local nPrefix = 0
function Spaceinputdialog.create()
    local dlg = Spaceinputdialog:new()
	dlg:OnCreate()
	return dlg
end

function Spaceinputdialog:new()
	local self = {}
	setmetatable(self, Spaceinputdialog)
    self:clearData()
	return self
end

function Spaceinputdialog:clearData()
     self.mapCallBack = {}
     self.nToCommentId = -1
     self.nToBbsId = -1 
     self.m_PrevContentWidth =0
end

function Spaceinputdialog:DestroyDialog()
    self:clearData()
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end


function Spaceinputdialog:OnCreate() 
    nPrefix = nPrefix + 1
    local strPrefix = tostring(nPrefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local layoutName = "kongjianliuyan.layout"
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,strPrefix)

	self.btnBack = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjianliuyan_mtg/btnfanhui"))
    self.btnBack:subscribeEvent("MouseClick", Spaceinputdialog.clickBack, self)

    self.richEditBox = CEGUI.toRichEditbox(winMgr:getWindow(strPrefix.."kongjianliuyan_mtg/shurubg"))
    self.richEditBox:SetTextAcceptMode(CEGUI.eTextAcceptMode_OnlyEnter)
	self.richEditBox:setWordWrapping(false)
	self.richEditBox:SetBackGroundEnable(false)
	self.richEditBox:SetForceHideVerscroll(true)
	self.richEditBox:SetTextBottomEdge(0)
	self.richEditBox:SetEmotionScale(CEGUI.Vector2(1, 1))-- s_EmotionScale)

    self.btnEmotion = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjianliuyan_mtg/btnbiaoqi")) 
    self.btnEmotion:subscribeEvent("MouseClick", Spaceinputdialog.clickEmotion, self)

    self.richEditBox:subscribeEvent("TextChanged", Spaceinputdialog.TextContentChanged, self)
    self.richEditBox:subscribeEvent("KeyboardTargetWndChanged", Spaceinputdialog.OnKeyboardTargetWndChanged, self)

    self.labelPlaceholder = winMgr:getWindow(strPrefix.."kongjianliuyan_mtg1/hoder")

    self.btnSend = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjianliuyan_mtg/btnfa")) 
    self.btnSend:subscribeEvent("MouseClick", Spaceinputdialog.clickSend, self)

end


function  Spaceinputdialog:TextContentChanged(e)
    local tw = self.richEditBox:GetExtendSize().width
	local rw = self.richEditBox:getWidth().offset

	if tw > rw and self.m_PrevContentWidth > tw then
		self.richEditBox:getHorzScrollbar():setScrollPosition(rw - tw)
		self.richEditBox:Refresh()
		self.richEditBox:activate()
	end

	self.m_PrevContentWidth = tw

end


function Spaceinputdialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richEditBox then
        self.labelPlaceholder:setVisible(false)
    elseif self.richEditBox:GenerateParseText() == "" then
        self.labelPlaceholder:setVisible(true)
    end
end



function Spaceinputdialog:clearContent()
    self.richEditBox:Clear()
    self.richEditBox:Refresh()
end

function Spaceinputdialog:setPlaceHolder(strTitle)
    self.labelPlaceholder:setVisible(true)
    self.labelPlaceholder:setText(strTitle)
end

function Spaceinputdialog:setDelegate(pTarget,callBackType,callBack)
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end
function Spaceinputdialog:callEvent(eType)
    local callBackData =  self.mapCallBack[eType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self)
end

function Spaceinputdialog:clickEmotion(args)
    local InsertDlg = require("logic.chat.insertdlg")
    local dlg = InsertDlg.getInstanceAndShow()
	dlg.willCheckTipsWnd = true

    local vShowType  = {}
    table.insert(vShowType,InsertDlg.eFunType.emotion)
    table.insert(vShowType,InsertDlg.eFunType.history)

    dlg:refreshFunctionBtn(vShowType)

    dlg:setDelegate(self,Spaceinputdialog.inputCallBack)

    self.labelPlaceholder:setVisible(false)

end

function Spaceinputdialog:inputCallBack(insertDlg,nType,nKey)
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
        chatManager:inputCallBack_task(insertDlg,nType,nKey,richEditBox)
    end
end

function Spaceinputdialog:clickBack(args)
    self:callEvent(Spaceinputdialog.eCallBackType.clickBack)
end

function Spaceinputdialog:clickSend(args)
    local strContent = self.richEditBox:GenerateParseText(false)

    if strContent =="" then
        local strShowTip = require("utils.mhsdutils").get_resstring(11531)
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end

    local nLen  = self.richEditBox:GetCharCount() --string.len(strContent)
    local nMaxLen = getSpaceManager().nMaxLenBbs
    if nLen >= nMaxLen then
        local strShowTip = require("utils.mhsdutils").get_resstring(11544)
        local sb = StringBuilder.new()
        sb:Set("parameter1",nMaxLen)
        strShowTip = sb:GetString(strShowTip)
        sb:delete()

		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end

    self:callEvent(Spaceinputdialog.eCallBackType.clickSend)
end

function Spaceinputdialog:setSendBtnTitle(strTitle)
    self.btnSend:setText(strTitle)
end




return Spaceinputdialog
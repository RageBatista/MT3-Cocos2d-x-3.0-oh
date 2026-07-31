
require "logic.dialog"

Spacecommentcell = {}
setmetatable(Spacecommentcell, Dialog)
Spacecommentcell.__index = Spacecommentcell


Spacecommentcell.eCallBackType = 
{
    clickDel=1,
    clickBg =2
}

local nPrefix = 0
function Spacecommentcell.create(parent)
    local dlg = Spacecommentcell:new()
	dlg:OnCreate(parent)
	return dlg
end

function Spacecommentcell:clearData()
    self.mapCallBack = {}
    self.oneCellData = nil
end

function Spacecommentcell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacecommentcell)
    self:clearData()
	return self
end

function Spacecommentcell:OnClose()
    self:clearData()
    Dialog.OnClose(self)
end

function Spacecommentcell:OnCreate(parent)
    nPrefix = nPrefix + 1
    local strPrefix = tostring(nPrefix)
    Dialog.OnCreate(self,parent,strPrefix)

	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richBoxComment = CEGUI.toRichEditbox(winMgr:getWindow(strPrefix.."kongjianpingluncell/richboxpinglun")) 
    self.richBoxComment:setReadOnly(true)
    self.richBoxComment:getVertScrollbar():EnbalePanGuesture(false)
    self.richBoxComment:getVertScrollbar():setScrollPosition(0)


    self.btnDel = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjianpingluncell/btndel"))
    self.btnDel:subscribeEvent("MouseClick", Spacecommentcell.clickDel, self)

    self.richBoxComment:subscribeEvent("MouseClick", Spacecommentcell.clickBg, self)
    self:GetWindow():subscribeEvent("MouseClick", Spacecommentcell.clickBg, self)

    self.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
    
    self.nOldBoxSize = self.richBoxComment:getPixelSize()
    self.nOldBgSize = self:GetWindow():getPixelSize()

    --self.richBoxComment:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.nOldBoxSize.width), CEGUI.UDim(0,self.nOldBgSize.height)))

    self.spaceManager = require("logic.space.spacemanager").getInstance()
end


function Spacecommentcell:setDelVisible(bVisible)
    self.btnDel:setVisible(bVisible)
end

function Spacecommentcell:refreshSize()
    local nBoxWidth = self.nOldBoxSize.width
	local nFrameWidth = self.nOldBgSize.width

    local nAddHeight = self.richBoxComment:GetExtendSize().height - self.nOldBoxSize.height
    nAddHeight = nAddHeight + 20
    nAddHeight = nAddHeight > 0 and nAddHeight or 0

    local nNewFrameHeight =  self.nOldBgSize.height + nAddHeight
    local nNewBoxHeight = self.nOldBoxSize.height + nAddHeight
	
    self.richBoxComment:setSize(CEGUI.UVector2(CEGUI.UDim(0, nBoxWidth), CEGUI.UDim(0,nNewBoxHeight)))
    self:GetWindow():setSize(CEGUI.UVector2(CEGUI.UDim(0, nFrameWidth), CEGUI.UDim(0,nNewFrameHeight)))
end


function Spacecommentcell:setDelegate(pTarget,callBackType,callBack)
    
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end

function Spacecommentcell:GetLayoutFileName()
	return "kongjianpingluncell.layout"
end
--oneCellData = {strSayContent="<T t="77" c="FFFFFFFF"></T>" targetRole={} nCommentId=53 sendRole={} nnRoleId=8193 nStateId=8 nToCommentId=0 }
function Spacecommentcell:refreshOneCell(commentData,bShowCommentIcon)
    if not bShowCommentIcon then
        bShowCommentIcon = false
    end
    if not commentData then
        return
    end
    self.oneCellData = commentData
    local nCommentId = commentData.nCommentId
    local nToCommentId = commentData.nToCommentId
    self.richBoxComment:Clear()
    ----set:common_pack image£ºliuyan1

    if bShowCommentIcon then
        self.richBoxComment:AppendImage(CEGUI.String("common_pack"), CEGUI.String("liuyan1"))
    else
        --self.richBoxComment:AppendImage(CEGUI.String("common_pack"), CEGUI.String("liuyan1"))
    end
    local sendRole = commentData.sendRole
    local targetRole = commentData.targetRole
        local strSayContent = commentData.strSayContent

        local nnRoleIdSend = sendRole.nnRoleId
        local strRoleNameSend = sendRole.strUserName
        local nnRoleIdTarget = targetRole.nnRoleId
        local strRoleNameTarget = targetRole.strUserName

        local strUserNameLinkSend  = self.spaceManager:getUserNameLink(nnRoleIdSend,strRoleNameSend)
        self.richBoxComment:AppendParseText(CEGUI.String(strUserNameLinkSend))

        if nToCommentId~= 0 and nnRoleIdTarget~= nnRoleIdSend then
            local strSayTozi = require("utils.mhsdutils").get_resstring(11536) 
            self.richBoxComment:AppendParseText(CEGUI.String(strSayTozi))

            local strUserNameLinkTarget  = self.spaceManager:getUserNameLink(nnRoleIdTarget,strRoleNameTarget)
            self.richBoxComment:AppendParseText(CEGUI.String(strUserNameLinkTarget))
        end
        
        local strColor = "fffff2df"
        strSayContent = string.gsub(strSayContent, "c=['\"].-['\"]", "c='" .. strColor .. "'")
        self.richBoxComment:AppendParseText(CEGUI.String(strSayContent))

    --self.richBoxComment:AppendBreak()
    self.richBoxComment:Refresh()

    local bCanDel = getSpaceManager():getCommentCanDel(self.oneCellData)
    self:refreshDelBtnVisible(bCanDel)

    self:refreshSize()

end


function Spacecommentcell:refreshDelBtnVisible(bVisible)
    self.btnDel:setVisible(bVisible)
end

function Spacecommentcell:callEvent(callType)
     local callBackData =  self.mapCallBack[callType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self)
end

function Spacecommentcell:clickBg(args)
    self:callEvent(Spacecommentcell.eCallBackType.clickBg)
end

function Spacecommentcell:clickDel(args)

    local strMsg =  require("utils.mhsdutils").get_msgtipstring(162155) 
    gGetMessageManager():AddConfirmBox(eConfirmNormal,
	strMsg,
	Spacecommentcell.clickConfirmBoxOk_delComment,
	self,
	Spacecommentcell.clickConfirmBoxCancel_delComment,
	self)

   -- self:callEvent(Spacecommentcell.eCallBackType.clickDel)
end


function Spacecommentcell:clickConfirmBoxOk_delComment()

    self:callEvent(Spacecommentcell.eCallBackType.clickDel)

    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Spacecommentcell:clickConfirmBoxCancel_delComment()
    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end


return Spacecommentcell
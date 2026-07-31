
Spacedetaildialog = {}
Spacedetaildialog.__index = Spacedetaildialog

local nPrefix = 0

Spacedetaildialog.eCallBackType = 
{
    clicBack = 1,
}

function Spacedetaildialog.create()
	local dlg = Spacedetaildialog:new()
	dlg:OnCreate()
    dlg:registerEvent()
	return dlg
end

function Spacedetaildialog:new()
	local self = {}
	setmetatable(self, Spacedetaildialog)
    self:clearData()
	return self
end

function Spacedetaildialog:clearData()
    self.mapCallBack = {}
    self.cell = nil
    self.oneCellData = nil
end

function Spacedetaildialog:DestroyDialog()
    self:removeEvent()
    if self.cell then
        self.cell:DestroyDialog()
        self.cell = nil
    end
    self:clearData()
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end


function Spacedetaildialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:removeEvent(Eventmanager.eCmd.refreshClickLike,self,Spacedetaildialog.refreshClickLike)
    eventManager:removeEvent(Eventmanager.eCmd.refreshAddComment,self,Spacedetaildialog.refreshAddComment)
    eventManager:removeEvent(Eventmanager.eCmd.delComment,self,Spacedetaildialog.delComment)

    eventManager:removeEvent(Eventmanager.eCmd.delState,self,Spacedetaildialog.delState)
    eventManager:removeEvent(Eventmanager.eCmd.reloadCommentList,self,Spacedetaildialog.reloadCommentList)
    eventManager:removeEvent(Eventmanager.eCmd.refreshCommentListDownNextPage,self,Spacedetaildialog.refreshCommentListDownNextPage)
    
end

function Spacedetaildialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:addEvent(Eventmanager.eCmd.refreshClickLike,self,Spacedetaildialog.refreshClickLike)
    eventManager:addEvent(Eventmanager.eCmd.refreshAddComment,self,Spacedetaildialog.refreshAddComment)
    eventManager:addEvent(Eventmanager.eCmd.delComment,self,Spacedetaildialog.delComment)

    eventManager:addEvent(Eventmanager.eCmd.delState,self,Spacedetaildialog.delState)
    eventManager:addEvent(Eventmanager.eCmd.reloadCommentList,self,Spacedetaildialog.reloadCommentList)
    eventManager:addEvent(Eventmanager.eCmd.refreshCommentListDownNextPage,self,Spacedetaildialog.refreshCommentListDownNextPage)
end


function Spacedetaildialog:reloadCommentList()
    self.cell.sayList:destroyCells()

    --local spManager = getSpaceManager()
    --self.vRoleState = spManager.vFriendSay
    self.cell.nHaveShowNum =0
    self.cell:addNextPage()
end


function Spacedetaildialog:refreshCommentListDownNextPage()
     self.cell:addNextPage()
end

function Spacedetaildialog:delState(vstrParam)
    self:callEvent(Spacedetaildialog.eCallBackType.clicBack)
end

function Spacedetaildialog:delComment(vstrParam)
--[[
    if #vstrParam <4 then
        return
    end
    local nSpaceType = tonumber(vstrParam[2])
    local nStateId = tonumber(vstrParam[3])
    local nCommentId = tonumber(vstrParam[4])
    --]]

    --self.cell:refreshOneCell(self.oneCellData)

    self.cell:refreshCommentList()
end


function Spacedetaildialog:refreshAddComment(vstrParam)
    self.cell:refreshOneCell(self.oneCellData)
end

function Spacedetaildialog:refreshClickLike(vstrParam)
    self.cell:refreshOneCell(self.oneCellData)
end

function Spacedetaildialog:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local strLayoutName = "kongjiandetail.layout"
    nPrefix = nPrefix +1
    local strPrefix = "Spacedetaildialog"..nPrefix
	self.m_pMainFrame = winMgr:loadWindowLayout(strLayoutName,strPrefix)

    self.btnSay = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjiandetail/btnsay"))--kongjiandetail/btnsay
    self.nodeSayBg = winMgr:getWindow(strPrefix.."kongjiandetail/wndsaybg") 

    self.btnSay:subscribeEvent("MouseClick", Spacedetaildialog.clickBack, self)

    
    self.scrollBg = CEGUI.toScrollablePane(winMgr:getWindow(strPrefix.."kongjiandetail/wndsaybg/scroll") )
    self.scrollBg:setVisible(true)

    local sizeBg = self.nodeSayBg:getPixelSize()


    local Spacerolesaycell = require("logic.space.spacerolesaycell")
    local bShowAllComment = true
    self.cell = Spacerolesaycell.create(self.scrollBg,bShowAllComment)
    self.cell:GetWindow():setHeight( CEGUI.UDim(0,sizeBg.height))

    self.cell:GetWindow():setSize(CEGUI.UVector2(CEGUI.UDim(0, sizeBg.width), CEGUI.UDim(0,sizeBg.height)))
    self.cell:setDelegate(self,Spacerolesaycell.eCallBackType.clickLike,Spacedetaildialog.cellClickLike)
    self.cell:setDelegate(self,Spacerolesaycell.eCallBackType.clickSayTo,Spacedetaildialog.cellClickSayTo)
    self.cell:setDelegate(self,Spacerolesaycell.eCallBackType.clickDel,Spacedetaildialog.cellClickDelete)
    self.cell:setDelegate(self,Spacerolesaycell.eCallBackType.commentClickBg,Spacedetaildialog.commentClickBg)
    self.cell:setDelegate(self,Spacerolesaycell.eCallBackType.inputSend,Spacedetaildialog.inputSend)

    self.scrollBg:setVerticalScrollPosition(0.0)
end

function Spacedetaildialog:inputSend(cellState,inputDlg)

    local strContent = inputDlg.richEditBox:GenerateParseText(false)
    local nToCommentId  = inputDlg.nToCommentId
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType

    local nnRoleId = getSpaceManager():getMyRoleId()
    local nnTargetRoleId = cellState.oneCellData.nnRoleId
    local nStateId = cellState.oneCellData.nStateId

    local wstrPureText = inputDlg.richEditBox:GetPureText()
    strContent = GetChatManager():ProcessChatLinks(wstrPureText, inputDlg.richEditBox)

    require("logic.space.spacepro.spaceprotocol_comment").request(nnRoleId,nnTargetRoleId,nStateId,strContent,nSpaceType,nToCommentId)

     if GetChatManager() then
        local strHistory = inputDlg.richEditBox:GenerateParseText(false)
        local strColor = getSpaceManager():getNormalTextColor()
        strHistory = getSpaceManager():stringReplaceToColor(strHistory,strColor)

        GetChatManager():AddToChatHistory(strHistory)
    end

    inputDlg:clearContent()

    

end

function Spacedetaildialog:setInputVisible(bVisible)
    self.cell:setInputVisible(bVisible)
end

function Spacedetaildialog:setDelegate(pTarget,callBackType,callBack)
    
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end

function Spacedetaildialog:callEvent(callType)
     local callBackData =  self.mapCallBack[callType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self)
end

function Spacedetaildialog:clickBack(args)
    self:callEvent(Spacedetaildialog.eCallBackType.clicBack)
end

function Spacedetaildialog:cellClickLike(cellState)
    local nnRoleId = getSpaceManager():getMyRoleId()
    local nnTargetId = cellState.oneCellData.nnRoleId
    local nStateId = cellState.oneCellData.nStateId
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType
    require("logic.space.spacepro.spaceprotocol_clickLike").request(nnRoleId,nnTargetId,nStateId,nSpaceType)
end

function Spacedetaildialog:cellClickSayTo(cell)
    self.cell:setInputVisible(true)
end

function Spacedetaildialog:cellClickDelete(cell)
    
    local nnRoleId = getSpaceManager():getMyRoleId()
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType
    local nStateId = self.cell.oneCellData.nStateId
    require("logic.space.spacepro.spaceprotocol_deleteState").request(nnRoleId,nSpaceType,nStateId)
end


function Spacedetaildialog:refreshWithOneCellData(oneCellData)
    self.oneCellData = oneCellData
    self.cell:refreshOneCell(self.oneCellData)

    local bCanDel = getSpaceManager():getStateCanDel(oneCellData)
    self.cell:setDelBtnVisible(bCanDel)

    self.scrollBg:setVerticalScrollPosition(0.0)

end

function Spacedetaildialog:setToCommentId(nToCommentId)
    self.cell.spInputDlg.nToCommentId = nToCommentId
end

function Spacedetaildialog:commentClickBg(cell,commentCell)

    local nToCommentId = commentCell.oneCellData.nCommentId


    self.cell:setInputVisible(true)
    self.cell.spInputDlg.nToCommentId = nToCommentId

    local strUserName = commentCell.oneCellData.sendRole.strUserName
    
    local strTitle = require("utils.mhsdutils").get_resstring(11546) 
    strTitle = strTitle..strUserName
    self.cell.spInputDlg:setPlaceHolder(strTitle)
    self.cell.spInputDlg.labelPlaceholder:setVisible(true)
    self.cell.spInputDlg:clearContent()

    
end

return Spacedetaildialog
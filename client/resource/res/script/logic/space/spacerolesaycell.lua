
require "logic.dialog"

Spacerolesaycell = {}
setmetatable(Spacerolesaycell, Dialog)
Spacerolesaycell.__index = Spacerolesaycell


Spacerolesaycell.eCallBackType = 
{
    clickLike = 1,
    clickSayTo=2,
    clickDel=3,
    clickBg =4,
    inputSend=5,
    commentClickBg=6,
}

local nPrefix = 0
function Spacerolesaycell.create(parent,bShowAllComment)
    if not bShowAllComment then
        bShowAllComment = false
    end
    local dlg = Spacerolesaycell:new()
	dlg:OnCreate(parent)
    dlg.bShowCommentAll = bShowAllComment
	return dlg
end

function Spacerolesaycell:clearData()
    self.mapCallBack = {}
    self.oneCellData = nil
    self.bShowCommentAll = false
    self.nCurAllHeight =0
    self.nCurAllHeight = 0
    self.vComment = {}
    self.vRoleComment = {}
    self.nHaveShowNum = 0
end

function Spacerolesaycell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacerolesaycell)
    self:clearData()
	return self
end


function Spacerolesaycell:OnClose()
    --self:clearCommentAll()
    self.sayList:destroyCells()
    if  self.spInputDlg then
        self.spInputDlg:DestroyDialog()
    end

    self:clearData()
    Dialog.OnClose(self)
end


function Spacerolesaycell:initUI(strPrefix)
    
	local winMgr = CEGUI.WindowManager:getSingleton()
   
    self.itemCell = CEGUI.toItemCell(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/itemcell"))
    self.labelSendTimeSelf = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/sendtime")  
    self.labelSendTimeSelf:setVisible(false)

    self.labelSendTime = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/time")  
    self.labelRoleName = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/name") 
    self.richBoxSayContent = CEGUI.toRichEditbox(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/neirong")) 
    self.richBoxSayContent:setReadOnly(true)
    self.richBoxSayContent:getVertScrollbar():EnbalePanGuesture(false)

    self.itemCellPic = CEGUI.toItemCell(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/statepic"))
    self.itemCellPic:subscribeEvent("MouseClick", Spacerolesaycell.clickLookPic, self)
    self.itemCellPic:SetBackGroundEnable(false)

    self.nodeInputBg = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/imputbg")
    self.nodeLikeBg = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/jiedian")
    self.nodeDelBtnBg = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/imputbg1")
    self.nodeDelBtnBg:setMousePassThroughEnabled(true)
    
    self.nodeCommentBg = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/diban")
    self.richBoxLike = CEGUI.toRichEditbox(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/diban/rich2")) 
    self.richBoxLike:setReadOnly(true)
    self.richBoxLike:getVertScrollbar():EnbalePanGuesture(false)

    self.btnLike = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/btnzan"))
    self.btnLike:subscribeEvent("MouseClick", Spacerolesaycell.clickLike, self)

    self.imageLike = winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/btnzan/xin") 

    self.btnSayTo = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/btnpinglun"))
    self.btnSayTo:subscribeEvent("MouseClick", Spacerolesaycell.clickSayTo, self)

    self.btnDel = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/btnshanchu"))
    self.btnDel:subscribeEvent("MouseClick", Spacerolesaycell.clickDel, self)

    self:GetWindow():subscribeEvent("MouseClick", Spacerolesaycell.clickBg, self)

    self.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
    self.spaceManager = require("logic.space.spacemanager").getInstance()

    --self:setInputVisible(false)

    self.nodeInputBg:setVisible(false)
    --self.btnLike:setVisible(true)
    --self.btnSayTo:setVisible(true)

    self.nodeLikeBg:setVisible(true)

   self.scrollComment = CEGUI.toScrollablePane(winMgr:getWindow(strPrefix.."kongjianzhuangtaicell/diban/comment")) 

   self.oldLikeSize = self.richBoxLike:getPixelSize()
   self.oldSayContentSize = self.richBoxSayContent:getPixelSize()
   self.oldInputPos = self.nodeInputBg:getPosition()

   self.oldContentSize = self:GetWindow():getPixelSize()

   local Spacecommentcell = require("logic.space.spacecommentcell")
    self.getSizeCell =  Spacecommentcell.create(self.m_pMainFrame)
    self.getSizeCell:GetWindow():setVisible(false)

    local TableView2 = require "logic.space.tableview2"
    local sizeBg = self.scrollComment:getPixelSize()
    self.sayList = TableView2.create(self.scrollComment, TableView2.VERTICAL)
    self.sayList:setViewSize(sizeBg.width, sizeBg.height)
    self.sayList:setScrollContentSize(sizeBg.width, sizeBg.height)
    self.sayList:setPosition(0, 0)
    self.sayList:setDataSourceFunc(self, Spacerolesaycell.tableViewGetCellAtIndex)
    self.sayList:setGetCellHeightCallFunc(self, Spacerolesaycell.tableViewGetCellHeight)
    self.sayList:setReachEdgeCallFunc(self, Spacerolesaycell.tableViewReachEdge)
end

function Spacerolesaycell:tableViewReachEdge(tableView, isTop)
    local spManager = getSpaceManager()
    if isTop then
        return
    end

    --self:callEvent(Spacerolesaycell.eCallBackType.commentScrollDown)

    self:commentScrollDown()
end

function Spacerolesaycell:clickLookPic(args)
    local strPicUrl = self.oneCellData.strPicUrl
    local pCeguiImage = gGetSpaceManager():GetCeguiImageWithUrl(strPicUrl)
    if not pCeguiImage then
        return
    end
    local lookPicDialog = require("logic.space.spacelookpicdialog").getInstanceAndShow()

    lookPicDialog.itemCell:SetImage(pCeguiImage)
end

function Spacerolesaycell:refreshCommentList()
    self.sayList:clearCellPosData()
    local nNum = #self.vRoleComment
    self.sayList:setCellCount(nNum)

    --self.sayList:refreshScrollSize()

    self.sayList:reloadData()

    local nCommentCount =  self.oneCellData.nSayToCount
    self.btnSayTo:setText(tostring(nCommentCount))
end

function Spacerolesaycell:refreshCommentCount()
     local nCommentCount =  self.oneCellData.nSayToCount
    self.btnSayTo:setText(tostring(nCommentCount))
end

function Spacerolesaycell:setDelBtnVisible(bVisible)
    self.btnDel:setVisible(bVisible)
end


function Spacerolesaycell:tableViewGetCellHeight(nIdx)
    local nIndex = nIdx + 1 
    local oneCellData = self.vRoleComment[nIndex]

    local bShowCommentIcon = false
    if nIndex==1 then
        bShowCommentIcon = true
    end 
    self.getSizeCell:refreshOneCell(oneCellData,bShowCommentIcon)
    
    local nHeight = self.getSizeCell:GetWindow():getPixelSize().height
    return nHeight

end

function Spacerolesaycell:OnCreate(parent)
    nPrefix = nPrefix + 1
    local strPrefix = tostring(nPrefix)
    Dialog.OnCreate(self,parent,strPrefix)
    self:initUI(strPrefix)
end


function Spacerolesaycell:refreshSizeAndPos(oneCellData,bLimitCommentSize)
    
    local nAddHeight = self.richBoxSayContent:GetExtendSize().height - self.oldSayContentSize.height
    nAddHeight = nAddHeight > 0 and nAddHeight or 0
    nAddHeight = nAddHeight +20
    local nNewBoxHeight = self.oldSayContentSize.height + nAddHeight

    self.richBoxSayContent:setHeight(CEGUI.UDim(0,nNewBoxHeight))

    local nPosYContent = self.richBoxSayContent:getPosition().y.offset
    local nSayContentBottomPosY = nPosYContent + nNewBoxHeight

    local nInputPosY = 0
    if oneCellData.strPicUrl=="" then
        nInputPosY = nSayContentBottomPosY
    else
        local Spacemanager = require("logic.space.spacemanager")
        self.itemCellPic:setWidth(CEGUI.UDim(0,Spacemanager.nUIStatePicWidth))
        self.itemCellPic:setHeight(CEGUI.UDim(0,Spacemanager.nUIStatePicHeight))

        self.itemCellPic:setYPosition( CEGUI.UDim(0, nSayContentBottomPosY))
        local nPosYPic = self.itemCellPic:getPosition().y.offset
        nInputPosY  = nPosYPic + self.itemCellPic:getPixelSize().height
    end
    
    --local posInput = self.nodeInputBg:getPosition()
    self.nodeInputBg:setYPosition( CEGUI.UDim(0, nInputPosY))
    self.nodeLikeBg:setYPosition( CEGUI.UDim(0, nInputPosY))
    self.nodeDelBtnBg:setYPosition( CEGUI.UDim(0, nInputPosY))
    
    local inputPos = self.nodeInputBg:getPosition()
    local inputSize = self.nodeInputBg:getPixelSize()
    local nCommentPosY =  inputPos.y.offset + inputSize.height

    local nLikeNum = #oneCellData.vLikeRole 
    local nSayToNum = #oneCellData.vSayToRole 
    
    if nLikeNum==0  and bLimitCommentSize then
        self:GetWindow():setHeight( CEGUI.UDim(0,nCommentPosY))
        return
    end
    --local posBgComment = self.nodeCommentBg:getPosition()
    self.nodeCommentBg:setYPosition( CEGUI.UDim(0, nCommentPosY))
    local contentSize = self:GetWindow():getPixelSize()
    --local commentBgSize = self.nodeCommentBg:getPixelSize()

    --in detail 
    if bLimitCommentSize==false then
        --local nSpaceCommentBgToFrame = 10
        local nCommentHeight = 300 -- contentSize.height - nCommentPosY-nSpaceCommentBgToFrame
        self.nodeCommentBg:setHeight( CEGUI.UDim(0,nCommentHeight))
        local nScrollCommentHeight = nCommentHeight -10
        self.scrollComment:setHeight(CEGUI.UDim(0,nScrollCommentHeight))
        local nContentHeight = nCommentPosY + self.nodeCommentBg:getPixelSize().height
        self:GetWindow():setHeight(CEGUI.UDim(0,nContentHeight+10))
    else
        local nContentHeight = nCommentPosY + self.nodeCommentBg:getPixelSize().height
        if nContentHeight > self.oldContentSize.height then
            self:GetWindow():setHeight(CEGUI.UDim(0,nContentHeight+10))
        end 
    end
    
    

    --like
    local likeSize = self.richBoxLike:GetExtendSize()
    local nLikeHeightAdd  = likeSize.height - self.oldLikeSize.height
    if nLikeHeightAdd < 0 then 
        nLikeHeightAdd = 0
    end
    nLikeHeightAdd = nLikeHeightAdd + 10
    local nLikeNewHeight = self.oldLikeSize.height + nLikeHeightAdd
    self.richBoxLike:setHeight(CEGUI.UDim(0,nLikeNewHeight))

    
    local  nLikePosY = self.richBoxLike:getPosition().y.offset
    local nTableViewPosY = nLikePosY + nLikeNewHeight
    if #oneCellData.vLikeRole == 0 then
        nTableViewPosY = nLikePosY
    end
    
    self.sayList:setPosition(0, nTableViewPosY)

    local sizeBg = self.scrollComment:getPixelSize()

     if bLimitCommentSize==false then
        self.sayList:setViewSize(sizeBg.width, sizeBg.height-nTableViewPosY-40)
     else
        self.sayList:setViewSize(sizeBg.width, sizeBg.height-nTableViewPosY-10)
     end
    
     if bLimitCommentSize==false then
        self.sayList.scroll:setVisible(true)
     else
        self.sayList.scroll:setVisible(false)
     end

end

function Spacerolesaycell:callEvent(eType,param1)
    local callBackData =  self.mapCallBack[eType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self,param1)
end

function Spacerolesaycell:inputClickBack(inputDlg)

    self:setInputVisible(false)
    self.spInputDlg.nToCommentId = -1
end

function Spacerolesaycell:inputClickSend(inputDlg)
    self:callEvent(Spacerolesaycell.eCallBackType.inputSend,inputDlg)
    self.spInputDlg.nToCommentId = -1
end

function Spacerolesaycell:setInputVisible(bVisible)
    
    if bVisible then
        if not self.spInputDlg then
            local Spaceinputdialog = require("logic.space.spaceinputdialog")
            self.spInputDlg = Spaceinputdialog.create()
            self.nodeInputBg:addChildWindow(self.spInputDlg.m_pMainFrame)
            self.spInputDlg.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))

            self.spInputDlg:setDelegate(self,Spaceinputdialog.eCallBackType.clickBack,Spacerolesaycell.inputClickBack)
            self.spInputDlg:setDelegate(self,Spaceinputdialog.eCallBackType.clickSend,Spacerolesaycell.inputClickSend)
        end

    end
    self.nodeInputBg:setVisible(bVisible)
    --self.btnLike:setVisible(not bVisible)
    --self.btnSayTo:setVisible(not bVisible)

    self.nodeLikeBg:setVisible(not bVisible)
end


function Spacerolesaycell:setDelegate(pTarget,callBackType,callBack)
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end

function Spacerolesaycell:GetLayoutFileName()
	return "kongjianzhuangtaicell.layout"
end

function Spacerolesaycell:refreshLevel()
    local nLevel = self.oneCellData.nLevel
    self.itemCell:SetTextUnit(tostring(nLevel))
end

function Spacerolesaycell:refreshPic()
    self.itemCellPic:SetImage(nil)
    local strPicUrl = self.oneCellData.strPicUrl
    if strPicUrl=="" then
        self.itemCellPic:SetImage(nil)
        self.itemCellPic:setVisible(false)
        return
    end
    self.itemCellPic:setVisible(true)
    local pCeguiImage = gGetSpaceManager():GetCeguiImageWithUrl(strPicUrl)
    if pCeguiImage then
        self.itemCellPic:SetImage(pCeguiImage)
    end
end

function Spacerolesaycell:isMyClickedLike()
    
    local nMyRoleId = getSpaceManager():getMyRoleId()
    for k,oneRole in pairs( self.oneCellData.vLikeRole ) do
        if nMyRoleId==oneRole.nnRoleId then
            return true
        end
    end
    return false

end


function Spacerolesaycell:refreshOneCell(oneCellData)
    if not oneCellData then
        return
    end
    self.nCurAllHeight = 0

    self.oneCellData = oneCellData
    local nStateId = oneCellData.nStateId
    local nShapeId = oneCellData.nShapeId
    local nLevel = oneCellData.nLevel
    local strUserName = oneCellData.strUserName
    local nnSendTime = oneCellData.nnSendTime
    local strRoleSay = oneCellData.strRoleSay
    local nLikeNum = #oneCellData.vLikeRole 
    local nSayToNum = oneCellData.nSayToCount  --#oneCellData.vSayToRole 
    local vLikeRole = oneCellData.vLikeRole
    local vSayToRole = oneCellData.vSayToRole
    local strPicUrl = oneCellData.strPicUrl
    ------------------------------
    self.nMsgIndex = nMsgIndex
    local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nShapeId)
    if shapeTable and shapeTable.id ~= -1 then
         local image = gGetIconManager():GetImageByID(shapeTable.littleheadID)
         self.itemCell:SetImage(image)
    end
    
    self.itemCell:SetTextUnit(tostring(nLevel))
    self.richBoxSayContent:Clear()

    local strTimeSelf = getSpaceManager():getSendTimeStringMonthDay(nnSendTime)
    self.labelSendTimeSelf:setText(strTimeSelf)

    local strTime = getSpaceManager():getSendTimeString(nnSendTime)
    self.labelSendTime:setText(strTime)
    self.labelRoleName:setText(strUserName)
    --local strTextColorSay = "ff02972c"
    --local strRoleSay = strRoleSay --self.spaceManager:getStringToRichContent(strRoleSay,strTextColorSay)
    self.richBoxSayContent:AppendParseText(CEGUI.String(strRoleSay) )
    self.richBoxSayContent:Refresh()
    local sayContentSize = self.richBoxSayContent:GetExtendSize()
    

    self:refreshPic()
    if strPicUrl ~= "" then
        local pCeguiImage = gGetSpaceManager():GetCeguiImageWithUrl(strPicUrl)
        if not pCeguiImage then
            require("logic.space.spacepro.spaceprotocol_getPic").request(strPicUrl)
        end
    end
    
    self.btnLike:setText(tostring(nLikeNum))
    self.btnSayTo:setText(tostring(nSayToNum))

    if self:isMyClickedLike() then
        self.imageLike:setProperty("Image","set:common_pack image:xin2" )
    else
        self.imageLike:setProperty("Image","set:common_pack image:xin1" )
    end
    --------------------------
    --set:common_pack image£ºliuyan1

    self.richBoxLike:Clear()
    if nLikeNum > 0 then
        self.richBoxLike:AppendImage(CEGUI.String("common_pack"), CEGUI.String("xin1"))
    end

    for nIndex,roleData in pairs(vLikeRole) do
        local strUserNameLink  = self.spaceManager:getUserNameLink(roleData.nnRoleId,roleData.strUserName)
        self.richBoxLike:AppendParseText(CEGUI.String(strUserNameLink))
    end
    self.richBoxLike:AppendBreak()
    self.richBoxLike:Refresh()
    ---------------------------
    --cell.richBoxSomeoneSay:AppendImage(CEGUI.String("shopui"), CEGUI.String("shop_up"))
    self.vRoleComment = vSayToRole
    self:reloadComment()    

    local bLimitCommentSize = false
    if self.bShowCommentAll == false then  
        bLimitCommentSize = true
    end

    if bLimitCommentSize==false then
        self.scrollComment:EnableChildDrag(self.richBoxLike)
        self.scrollComment:getVertScrollbar():EnbalePanGuesture(true)
    else
        self.scrollComment:getVertScrollbar():EnbalePanGuesture(false)
    end

    self:refreshSizeAndPos(self.oneCellData,bLimitCommentSize) 

    if self.bShowCommentAll==false then
        local nLikeNum = #oneCellData.vLikeRole 
        local nSayToNum = #oneCellData.vSayToRole 
        if nLikeNum==0  then
            self.nodeCommentBg:setVisible(false)
        else
            self.nodeCommentBg:setVisible(true)
        end
    end
    
end



function Spacerolesaycell:commentCellClickDel(commentCell)


    
    local nCommentId = commentCell.oneCellData.nCommentId
    local nnRoleId = getSpaceManager():getMyRoleId()
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType
    local nStateId = self.oneCellData.nStateId
    require("logic.space.spacepro.spaceprotocol_deleteComment").request(nnRoleId,nCommentId,nSpaceType,nStateId)
end
--[[
function Spacerolesaycell:addComment(commentData)
     local Spacecommentcell = require("logic.space.spacecommentcell")
     local commentCell =  Spacecommentcell.create(self.scrollComment)
     commentCell:setDelegate(self,Spacecommentcell.eCallBackType.clickBg,Spacerolesaycell.commentCellClickBg)
     commentCell:setDelegate(self,Spacecommentcell.eCallBackType.clickDel,Spacerolesaycell.commentCellClickDel)

     table.insert(self.vComment,commentCell)
     commentCell:refreshOneCell(commentData)
     commentCell:refreshSize()
     local cellSize = commentCell:GetWindow():getPixelSize()
     
     local nPosY = self.nCurAllHeight
     commentCell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, nPosY)))
     self.nCurAllHeight = self.nCurAllHeight + cellSize.height

     self.scrollComment:EnableChildDrag(commentCell:GetWindow())
end
--]]

function Spacerolesaycell:clearCommentAll()
    for k,v in pairs(self.vComment) do
        v:OnClose()
    end
    self.vComment = {}
end 

function Spacerolesaycell:reloadComment()  
    self.sayList:destroyCells()
    --local spManager = getSpaceManager()
    --self.vRoleState = spManager.vFriendSay
    self.nHaveShowNum = 0
    self:addNextPage()

    --[[
    local nShowCommentNum = getSpaceManager().nHomeShowCommentNum
    if self.bShowCommentAll == true then
        nShowCommentNum = #self.vRoleComment
    else
        if #self.vRoleComment < nShowCommentNum then
            nShowCommentNum = #self.vRoleComment
        end
    end

    self.sayList:destroyCells()
    local nAllNum = nShowCommentNum
    self.sayList:setCellCount(nAllNum)
    self.sayList:reloadData()
    --]]

end

function Spacerolesaycell:commentScrollDown()
    if self.nHaveShowNum < #self.oneCellData.vSayToRole then
        self:addNextPage()
        return
    end

    local nnRoleId = getSpaceManager():getCurRoleId()
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType
    local Spacedialog = require("logic.space.spacedialog")

        local nCommentNum = #self.oneCellData.vSayToRole
        local oneComment = self.oneCellData.vSayToRole[nCommentNum]
        local nStateId = self.oneCellData.nStateId
        local nPreId = oneComment.nCommentId
        require("logic.space.spacepro.spaceprotocol_getCommentList").request(nStateId,nPreId,nSpaceType)
       
end

function Spacerolesaycell:addNextPage()
    local spManager = getSpaceManager()
    local nToAddNum = spManager.nCommentInPage
    local nNewNum = self.nHaveShowNum + nToAddNum

    if nNewNum > #self.oneCellData.vSayToRole then
        nNewNum = #self.oneCellData.vSayToRole
    end
    self.nHaveShowNum = nNewNum

    self.sayList:setCellCount(self.nHaveShowNum)
    self.sayList:reloadData()
end


function Spacerolesaycell:commentCellClickBg(commentCell)
    self:callEvent(Spacerolesaycell.eCallBackType.commentClickBg,commentCell)
    --self:setInputVisible(true)
    --self.spInputDlg.nToCommentId = commentCell.oneCellData.nCommentId
end

function Spacerolesaycell:clickBg(args)
    self:callEvent(Spacerolesaycell.eCallBackType.clickBg)
end

function Spacerolesaycell:clickLike(args)
    self:callEvent(Spacerolesaycell.eCallBackType.clickLike)

end

function Spacerolesaycell:clickSayTo(args)
    self:callEvent(Spacerolesaycell.eCallBackType.clickSayTo)
end

function Spacerolesaycell:clickDel(args)
    -- local strNotOpen = require("utils.mhsdutils").get_msgtipstring(162148)
    --GetCTipsManager():AddMessageTip(strNotOpen)

    local strMsg =  require("utils.mhsdutils").get_msgtipstring(162156) --162156
    gGetMessageManager():AddConfirmBox(eConfirmNormal,
	strMsg,
	Spacerolesaycell.clickConfirmBoxOk_delState,
	self,
	Spacerolesaycell.clickConfirmBoxCancel_delState,
	self)

    --self:callEvent(Spacerolesaycell.eCallBackType.clickDel)
end

function Spacerolesaycell:clickConfirmBoxOk_delState()

    self:callEvent(Spacerolesaycell.eCallBackType.clickDel)

    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Spacerolesaycell:clickConfirmBoxCancel_delState()
    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end



function Spacerolesaycell:createOneCell(parent,nIndex)
     local Spacecommentcell = require("logic.space.spacecommentcell")
     local commentCell =  Spacecommentcell.create(parent)
     commentCell:setDelegate(self,Spacecommentcell.eCallBackType.clickBg,Spacerolesaycell.commentCellClickBg)
     commentCell:setDelegate(self,Spacecommentcell.eCallBackType.clickDel,Spacerolesaycell.commentCellClickDel)
     self.scrollComment:EnableChildDrag(commentCell:GetWindow())
    return commentCell
end

function Spacerolesaycell:tableViewGetCellAtIndex(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:createOneCell(tableView.container,nIndex )
    end
    local oneCellData = self.vRoleComment[nIndex]
    
    local bShowCommentIcon = false
    if nIndex==1 then
        bShowCommentIcon = true
    end 
    cell:refreshOneCell(oneCellData,bShowCommentIcon)

    return cell
end


return Spacerolesaycell
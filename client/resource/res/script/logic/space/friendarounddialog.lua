


Friendarounddialog = {}
Friendarounddialog.__index = Friendarounddialog

local nPrefix = 0

function Friendarounddialog.create()
	local dlg = Friendarounddialog:new()
    dlg:clearData()
	dlg:OnCreate()
    dlg:registerEvent()
	return dlg
end

function Friendarounddialog:new()
	local self = {}
	setmetatable(self, Friendarounddialog)
    self:clearData()
	return self
end



function Friendarounddialog:clearData()
    self.detailDlg = nil
    self.vRoleState = {}

    self.nHaveShowNum =0
    self.bLockLikeBtn = false
    self.nSpaceType = 0
end

function Friendarounddialog:DestroyDialog()
    require("logic.task.schedulermanager").getInstance():deleteTimerWithTarget(self)

    self.getSizeCell:OnClose()
    self:removeEvent()
    if self.detailDlg then
        self.detailDlg:DestroyDialog()
    end
    self.sayList:destroyCells()
    self:clearData()
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end


function Friendarounddialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:removeEvent(Eventmanager.eCmd.reloadFriendStateList,self,Friendarounddialog.reloadFriendStateList)
    eventManager:removeEvent(Eventmanager.eCmd.reloadMySayList,self,Friendarounddialog.reloadMySayList)
    eventManager:removeEvent(Eventmanager.eCmd.refreshFriendList,self,Friendarounddialog.refreshFriendList)
    
    eventManager:removeEvent(Eventmanager.eCmd.refreshMySayState,self,Friendarounddialog.refreshMySayState)
    eventManager:removeEvent(Eventmanager.eCmd.refreshClickLike,self,Friendarounddialog.refreshClickLike)
    eventManager:removeEvent(Eventmanager.eCmd.delComment,self,Friendarounddialog.delComment)

    eventManager:removeEvent(Eventmanager.eCmd.refreshMySayListDownNextPage,self,Friendarounddialog.refreshMySayListDownNextPage)
    eventManager:removeEvent(Eventmanager.eCmd.refreshFriendListDownNextPage,self,Friendarounddialog.refreshFriendListDownNextPage)
    eventManager:removeEvent(Eventmanager.eCmd.delState,self,Friendarounddialog.delState)

    eventManager:removeEvent(Eventmanager.eCmd.refreshRoleLevel,self,Friendarounddialog.refreshRoleLevel)
    eventManager:removeEvent(Eventmanager.eCmd.getPicResult,self,Friendarounddialog.getPicResult)

    eventManager:removeEvent(Eventmanager.eCmd.commentFriendList,self,Friendarounddialog.commentFriendList)
    eventManager:removeEvent(Eventmanager.eCmd.commentMyStateList,self,Friendarounddialog.commentMyStateList)

end

function Friendarounddialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:addEvent(Eventmanager.eCmd.reloadFriendStateList,self,Friendarounddialog.reloadFriendStateList)
    eventManager:addEvent(Eventmanager.eCmd.reloadMySayList,self,Friendarounddialog.reloadMySayList)
    eventManager:addEvent(Eventmanager.eCmd.refreshFriendList,self,Friendarounddialog.refreshFriendList)
    
    eventManager:addEvent(Eventmanager.eCmd.refreshMySayState,self,Friendarounddialog.refreshMySayState)
    eventManager:addEvent(Eventmanager.eCmd.refreshClickLike,self,Friendarounddialog.refreshClickLike)
    eventManager:addEvent(Eventmanager.eCmd.delComment,self,Friendarounddialog.delComment)

    eventManager:addEvent(Eventmanager.eCmd.refreshMySayListDownNextPage,self,Friendarounddialog.refreshMySayListDownNextPage)
    eventManager:addEvent(Eventmanager.eCmd.refreshFriendListDownNextPage,self,Friendarounddialog.refreshFriendListDownNextPage)
    eventManager:addEvent(Eventmanager.eCmd.delState,self,Friendarounddialog.delState)

    eventManager:addEvent(Eventmanager.eCmd.refreshRoleLevel,self,Friendarounddialog.refreshRoleLevel)
    eventManager:addEvent(Eventmanager.eCmd.getPicResult,self,Friendarounddialog.getPicResult)

    eventManager:addEvent(Eventmanager.eCmd.commentFriendList,self,Friendarounddialog.commentFriendList)
    eventManager:addEvent(Eventmanager.eCmd.commentMyStateList,self,Friendarounddialog.commentMyStateList)

end

function Friendarounddialog:commentFriendList(vstrParam)
--[[
    self.sayList:clearCellPosData()
    self.sayList:refreshScrollSize()
    self.sayList:reloadData()
    --]]
      if #vstrParam < 3 then
        return
    end
    local nSpaceType = tonumber(vstrParam[2])
    local nStateId = tonumber(vstrParam[3])

    
    for k,cell in pairs( self.sayList.visibleCells) do
        if cell.oneCellData.nStateId == nStateId then
            cell:refreshCommentCount()
            break
        end
    end

end

function Friendarounddialog:commentMyStateList(vstrParam)
--[[
    self.sayList:clearCellPosData()
    self.sayList:refreshScrollSize()
    self.sayList:reloadData()
    --]]

      if #vstrParam < 3 then
        return
    end
    local nSpaceType = tonumber(vstrParam[2])
    local nStateId = tonumber(vstrParam[3])

    
    for k,cell in pairs( self.sayList.visibleCells) do
        if cell.oneCellData.nStateId == nStateId then
            cell:refreshCommentCount()
            break
        end
    end
end

function Friendarounddialog:getPicResult(vstrParam)
    for k,cell in pairs( self.sayList.visibleCells) do
        cell:refreshPic()
    end
end

function Friendarounddialog:refreshRoleLevel(vstrParam)
    if not self.sayList.visibleCells then
        return
    end
    --self.sayList:reloadData()
    for k,cell in pairs( self.sayList.visibleCells) do
        cell:refreshLevel()
    end
    
end

function Friendarounddialog:delState(vstrParam)
    --local nParamNum = require("logic.space.spacepro.spaceprotocol_deleteState.")
   -- if #vstrParam <3 then
    --    return
    --end
    --local nSpaceType = tonumber(vstrParam[2])

    local nAllCount = #self.vRoleState

    self.sayList:clearCellPosData()
    self.sayList:setCellCount(nAllCount)
    --self.sayList:refreshScrollSize()
    self.sayList:reloadData()
end


function Friendarounddialog:refreshTopBtnTitle()
    local nnShowRoleId = getSpaceManager():getCurRoleId()
    local nnMyRoleId =  getSpaceManager():getMyRoleId()
    
    local nTitleId = 11540
    if nnShowRoleId ~= nnMyRoleId then
        nTitleId = 11537 --my space
    else
        nTitleId = 11540 
    end
    local strTitle = require("utils.mhsdutils").get_resstring(nTitleId)
    self.btnSay:setText(strTitle)
end

function Friendarounddialog:refreshFriendListDownNextPage(vstrParam)
    self:addNextPage()
end

function Friendarounddialog:refreshMySayListDownNextPage(vstrParam)
    self:addNextPage()
end

function Friendarounddialog:addNextPage()
    local spManager = getSpaceManager()
    local nToAddNum = spManager.nStateInPage
    local nNewNum = self.nHaveShowNum + nToAddNum

    if nNewNum > #self.vRoleState then
        nNewNum = #self.vRoleState
    end
    self.nHaveShowNum = nNewNum

    self.sayList:setCellCount(self.nHaveShowNum)
    self.sayList:reloadData()
end

function Friendarounddialog:reloadFriendStateList(vstrParam)
    local Spacedialog = require("logic.space.spacedialog")
    if self.nSpaceType==Spacedialog.eSpaceType.mySay  then
        return
    end

    self.sayList:destroyCells()

    local spManager = getSpaceManager()
    self.vRoleState = spManager.vFriendSay
    self.nHaveShowNum =0
    self:addNextPage()
end

function Friendarounddialog:reloadMySayList()
    
    local Spacedialog = require("logic.space.spacedialog")
    if self.nSpaceType==Spacedialog.eSpaceType.friendAround then
        return
    end

    self.sayList:destroyCells()

    local spManager = getSpaceManager()
    self.vRoleState = spManager.vMySayState
    self.nHaveShowNum =0
    self:addNextPage()

end


function Friendarounddialog:delComment(vstrParam)
     if #vstrParam <4 then
        return
    end
    local nSpaceType = tonumber(vstrParam[2])
    local nStateId = tonumber(vstrParam[3])
    local nCommentId = tonumber(vstrParam[4])

    
    for k,cell in pairs( self.sayList.visibleCells) do
        if cell.oneCellData.nStateId == nStateId then
            cell:refreshCommentCount()
            break
        end
    end

--[[
    self.sayList:clearCellPosData()
    self.sayList:refreshScrollSize()
    self.sayList:reloadData()
    --]]

end

function Friendarounddialog:startCd()
    LogInfo("Friendarounddialog:startCd()")
    local timerData = {}
    require("logic.task.schedulermanager").getInstance():getTimerDataInit(timerData)
    local  Schedulermanager = require("logic.task.schedulermanager")
	--//=======================================
	timerData.eType = Schedulermanager.eTimerType.repeatCount
	timerData.fDurTime = 0.5
	timerData.nRepeatCount = 1
	--timerData.nParam1 = nTaskTypeId
    timerData.pTarget = self
    timerData.callback= Friendarounddialog.timerCallBack
	--//=======================================
	require("logic.task.schedulermanager").getInstance():addTimer(timerData)

end

function Friendarounddialog:timerCallBack()
	--require("logic.task.schedulermanager").getInstance():deleteTimerWithTargetAndCallBak(self,Friendarounddialog.timerCallBack)

    LogInfo("Friendarounddialog:timerCallBack()")
    self.bLockLikeBtn = false
end

function Friendarounddialog:refreshClickLike(vstrParam)
    self.sayList:clearCellPosData()
    self.sayList:refreshScrollSize()
    self.sayList:reloadData()
end

function Friendarounddialog:refreshMySayState()
    local spManager = require("logic.space.spacemanager").getInstance()
    self.vRoleState = spManager.vMySayState
    local nAllNum = #self.vRoleState
    self.sayList:setCellCount(nAllNum)
    self.sayList:reloadData()
end

function Friendarounddialog:refreshFriendStateList()
    local spManager = require("logic.space.spacemanager").getInstance()
    self.vRoleState = spManager.vFriendSay
    local nAllNum = #self.vRoleState
    self.sayList:setCellCount(nAllNum)
    self.sayList:reloadData()
end

function Friendarounddialog:refreshFriendList(vstrParam)
    self:refreshFriendStateList()
end


function Friendarounddialog:IsVisible()
    if self.m_pMainFrame then
		return self.m_pMainFrame:isVisible()
	else
		return false
	end
end

function Friendarounddialog:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local strLayoutName = "kongjianfriend.layout"
    nPrefix = nPrefix +1
	self.m_pMainFrame = winMgr:loadWindowLayout(strLayoutName,tostring(nPrefix))

    self.btnSay = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianfriend/btnsay"))
    self.nodeSayBg = winMgr:getWindow(nPrefix.."kongjianfriend/wndsaybg") 

    self.nodeBgContent = winMgr:getWindow(nPrefix.."kongjianfriend/contentbg")  
    self.nodeBgDetail = winMgr:getWindow(nPrefix.."kongjianfriend/detailbg")  
    self.nodeBgContent:setVisible(true)
    self.nodeBgDetail:setVisible(false)

    self.btnSay:subscribeEvent("MouseClick", Friendarounddialog.clickSendState, self)

	--self.scrollAllSay = CEGUI.toScrollablePane(winMgr:getWindow("kongjiancell_mtg/youzhuangtai/list"))
	--self.wndNoSay = winMgr:getWindow("kongjiancell_mtg/meizhuangtai")

    --[[
    local layoutNamegetSize = "kongjianzhuangtaicell.layout"
    local strPrefix = "getsize"
	local nodeCell = winMgr:loadWindowLayout(layoutNamegetSize,strPrefix)
    self.nodeCellSize = nodeCell:getPixelSize()
    winMgr:destroyWindow(nodeCell)
    --]]

    
    local Spacerolesaycell = require("logic.space.spacerolesaycell")
    self.getSizeCell =  Spacerolesaycell.create(self.m_pMainFrame)
    self.getSizeCell:GetWindow():setVisible(false)

    local TableView2 = require "logic.space.tableview2"
     local sizeBg = self.nodeSayBg:getPixelSize()
     self.sayList = TableView2.create(self.nodeSayBg, TableView2.VERTICAL)
     self.sayList:setViewSize(sizeBg.width, sizeBg.height)
     self.sayList:setScrollContentSize(sizeBg.width, sizeBg.height)
     self.sayList:setPosition(0, 0)
     self.sayList:setDataSourceFunc(self, Friendarounddialog.tableViewGetCellAtIndex)
     self.sayList:setGetCellHeightCallFunc(self, Friendarounddialog.tableViewGetCellHeight)
     self.sayList:setReachEdgeCallFunc(self, Friendarounddialog.tableViewReachEdge)

     

     
     self:refreshTopBtnTitle()

end
--oneCellData = {nLevel=1 strSayContent="<T t="saycontent "> </T>" strUserName="name1" nnRoleId=1 }
function Friendarounddialog:tableViewGetCellHeight(nIdx)
    local nIndex = nIdx + 1 
    local oneCellData = self.vRoleState[nIndex]
    local bLimitSize = true

    self.getSizeCell.richBoxSayContent:Clear()
    self.getSizeCell.richBoxSayContent:AppendParseText(CEGUI.String(oneCellData.strRoleSay) )
    self.getSizeCell.richBoxSayContent:Refresh()

    self.getSizeCell:refreshSizeAndPos(oneCellData,bLimitSize)
    local nHeight = self.getSizeCell:GetWindow():getPixelSize().height
    return nHeight
end

function Friendarounddialog:cellClickLike(cell)
    LogInfo("Friendarounddialog:cellClickLike()stateId="..cell.oneCellData.nStateId)
   if self.bLockLikeBtn then
        LogInfo("if self.bLockLikeBtn then="..cell.oneCellData.nStateId)
        return
   end
    
   self.bLockLikeBtn = true
   self:startCd()

    local nnRoleId = getSpaceManager():getMyRoleId()
    local nnTargetId = cell.oneCellData.nnRoleId
    local nStateId = cell.oneCellData.nStateId
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType
    require("logic.space.spacepro.spaceprotocol_clickLike").request(nnRoleId,nnTargetId,nStateId,nSpaceType)
end

function Friendarounddialog:cellClickSayTo(cell)
    local bInputVisible = true
    self:showDetail(cell,bInputVisible)
end

function Friendarounddialog:showDetail(cellState,bInputVisible,nToCommentId)
    self.nodeBgContent:setVisible(false)
    self.nodeBgDetail:setVisible(true)

    if not self.detailDlg then
        local Spacedetaildialog = require("logic.space.spacedetaildialog")
        self.detailDlg = Spacedetaildialog.create()
        self.nodeBgDetail:addChildWindow(self.detailDlg.m_pMainFrame)
        self.detailDlg.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
        self.detailDlg:setDelegate(self,Spacedetaildialog.eCallBackType.clicBack,Friendarounddialog.detailClickBack)
    end
    self.detailDlg:refreshWithOneCellData(cellState.oneCellData)
    self.detailDlg:setInputVisible(bInputVisible)
    self.detailDlg:setToCommentId(nToCommentId)

end

function Friendarounddialog:detailClickBack()
    self.nodeBgContent:setVisible(true)
    self.nodeBgDetail:setVisible(false)

end

function Friendarounddialog:clickDelete(cell)

end


function Friendarounddialog:cellClickBg(cell)
    local bInputVisible = true
    self:showDetail(cell,bInputVisible)
end

function Friendarounddialog:commentClickBg(cell,commentCell)
    --cell:setInputVisible(true)
    local nToCommentId = commentCell.oneCellData.nCommentId
    local bInputVisible = true
    self:showDetail(cell,bInputVisible,nToCommentId)

    --cell.spInputDlg.nToCommentId = commentCell.oneCellData.nCommentId

end

function Friendarounddialog:cellClickDel(cell)
    
    local nnRoleId = getSpaceManager():getMyRoleId()
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType
    local nStateId = cell.oneCellData.nStateId
    require("logic.space.spacepro.spaceprotocol_deleteState").request(nnRoleId,nSpaceType,nStateId)
end

function Friendarounddialog:createOneCell(parent,nIndex)
    local Spacerolesaycell = require("logic.space.spacerolesaycell")
    local cell = Spacerolesaycell.create(parent)
    cell:setDelegate(self,Spacerolesaycell.eCallBackType.clickLike,Friendarounddialog.cellClickLike)
    cell:setDelegate(self,Spacerolesaycell.eCallBackType.clickSayTo,Friendarounddialog.cellClickSayTo)
    cell:setDelegate(self,Spacerolesaycell.eCallBackType.commentClickBg,Friendarounddialog.commentClickBg)
    cell:setDelegate(self,Spacerolesaycell.eCallBackType.clickBg,Friendarounddialog.cellClickBg)
    cell:setDelegate(self,Spacerolesaycell.eCallBackType.clickDel,Friendarounddialog.cellClickDel)
    return cell
end



function Friendarounddialog:refreshStateCell(cell,oneCellData)
    local bCanDel = getSpaceManager():getStateCanDel(oneCellData)

    cell:setDelBtnVisible(bCanDel)

    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType
    local Spacedialog = require("logic.space.spacedialog")
    if nSpaceType==Spacedialog.eSpaceType.friendAround then
        cell.itemCell:setVisible(true)
        cell.labelSendTimeSelf:setVisible(false)
    elseif nSpaceType==Spacedialog.eSpaceType.mySay  then
        cell.itemCell:setVisible(false)
        cell.labelSendTimeSelf:setVisible(true)
        cell.labelSendTime:setVisible(false)
    end


end

function Friendarounddialog:tableViewReachEdge(tableView, isTop)
    local spManager = getSpaceManager()
    if isTop then
        return
    end
    
    if self.nHaveShowNum < #self.vRoleState then
        self:addNextPage()
        return
    end

    local nnRoleId = getSpaceManager():getCurRoleId()
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nSpaceType = spLabel.nSpaceType
    local Spacedialog = require("logic.space.spacedialog")
    if nSpaceType==Spacedialog.eSpaceType.friendAround then
        local nFriendStateNum = #spManager.vFriendSay
        local oneState = spManager.vFriendSay[nFriendStateNum]
        local nPreId = oneState.nStateId
        require("logic.space.spacepro.spaceprotocol_selfFriendAround").request(nnRoleId,nPreId)
        
    elseif nSpaceType==Spacedialog.eSpaceType.mySay  then
        local nNum = #spManager.vMySayState
        local oneState = spManager.vMySayState[nNum]
        local nPreId = oneState.nStateId
        require("logic.space.spacepro.spaceprotocol_selfSayState").request(nnRoleId,nPreId)
    end
end


function Friendarounddialog:tableViewGetCellAtIndex(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:createOneCell(tableView.container,nIndex )
    end
    local oneCellData = self.vRoleState[nIndex]
    cell:refreshOneCell(oneCellData)
    self:refreshStateCell(cell,oneCellData)
    
    return cell
end

function Friendarounddialog:clickSendState(args)
    local nnShowRoleId = getSpaceManager():getCurRoleId()
    local nnMyRoleId =  getSpaceManager():getMyRoleId()
    
    
    if nnShowRoleId ~= nnMyRoleId then
        getSpaceManager():openSpace(nnMyRoleId)
        return
    end

    require"logic.space.spacesendstatedialog".getInstanceAndShow()
end

function Friendarounddialog:refreshEmptyNode()

end

function Friendarounddialog:refreshUI()

end

return Friendarounddialog
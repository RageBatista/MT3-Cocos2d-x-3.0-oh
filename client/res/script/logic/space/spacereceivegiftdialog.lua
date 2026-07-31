
Spacereceivegiftdialog = {}
Spacereceivegiftdialog.__index = Spacereceivegiftdialog

local nPrefix = 0


Spacereceivegiftdialog.eCallBackType = 
{
    clickBack = 1

}

function Spacereceivegiftdialog.create()
	local dlg = Spacereceivegiftdialog:new()
    dlg:clearData()
	dlg:OnCreate()
    dlg:registerEvent()
	return dlg
end

function Spacereceivegiftdialog:new()
	local self = {}
	setmetatable(self, Spacereceivegiftdialog)
    self:clearData()
	return self
end

function Spacereceivegiftdialog:clearData()
    self.detailDlg = nil
    self.mapCallBack = {}
    self.nHaveShowNum = 0
    self.vRecGift = {}
end


function Spacereceivegiftdialog:DestroyDialog()
    self.getSizeCell:OnClose()
    self:removeEvent()
    if self.detailDlg then
        self.detailDlg:DestroyDialog()
    end
    
    self.sayList:destroyCells()
    self:clearData()
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end


function Spacereceivegiftdialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:removeEvent(Eventmanager.eCmd.refreshReceiveGift,self,Spacereceivegiftdialog.refreshReceiveGift)
    eventManager:removeEvent(Eventmanager.eCmd.reloadRecGift,self,Spacereceivegiftdialog.reloadRecGift)
    eventManager:removeEvent(Eventmanager.eCmd.refreshReceiveGiftDownNextPage,self,Spacereceivegiftdialog.refreshReceiveGiftDownNextPage)

    eventManager:removeEvent(Eventmanager.eCmd.refreshRoleLevel,self,Spacereceivegiftdialog.refreshRoleLevel)
    --eventManager:addEvent(Eventmanager.eCmd.delBbs,self,Spacereceivegiftdialog.delBbs)

end

function Spacereceivegiftdialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:addEvent(Eventmanager.eCmd.refreshReceiveGift,self,Spacereceivegiftdialog.refreshReceiveGift)
    eventManager:addEvent(Eventmanager.eCmd.reloadRecGift,self,Spacereceivegiftdialog.reloadRecGift)
    eventManager:addEvent(Eventmanager.eCmd.refreshReceiveGiftDownNextPage,self,Spacereceivegiftdialog.refreshReceiveGiftDownNextPage)

    eventManager:addEvent(Eventmanager.eCmd.refreshRoleLevel,self,Spacereceivegiftdialog.refreshRoleLevel)
    --eventManager:addEvent(Eventmanager.eCmd.delBbs,self,Spacereceivegiftdialog.delBbs)
end

function Spacereceivegiftdialog:delBbs(vstrParam)
--[[
    local spManager = getSpaceManager()

    local nAllNum = #self.vRecGift

    self.sayList:clearCellPosData()
    self.sayList:setCellCount(nAllNum)
    self.sayList:reloadData()
    --]]

end

function Spacereceivegiftdialog:refreshRoleLevel(vstrParam)
    --self.sayList:reloadData()

    if not self.sayList.visibleCells then
        return
    end
    for k,cell in pairs( self.sayList.visibleCells) do
        cell:refreshLevel()
    end

end

function Spacereceivegiftdialog:refreshReceiveGiftDownNextPage(vstrParam)
    self:addNextPage()
end

function Spacereceivegiftdialog:reloadRecGift(vstrParam)
    self.sayList:destroyCells()
    local spManager = getSpaceManager()

    self.vRecGift = spManager.vReceiveGiftData 
    self:addNextPage()
end

function Spacereceivegiftdialog:refreshRecGift()
    local spManager = getSpaceManager()
    local nAllNum =  #self.vRecGift 
    self.sayList:setCellCount(nAllNum)
    self.sayList:reloadData()

end

function Spacereceivegiftdialog:refreshReceiveGift(vstrParam)
   self:refreshRecGift()
end


function Spacereceivegiftdialog:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local strLayoutName = "kongjiandetail.layout"
    nPrefix = nPrefix +1
    local strPrefix = "Spacereceivegiftdialog"..nPrefix
	self.m_pMainFrame = winMgr:loadWindowLayout(strLayoutName,strPrefix)

    self.btnSay = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjiandetail/btnsay"))--kongjiandetail/btnsay
    self.btnSay:subscribeEvent("MouseClick", Spacereceivegiftdialog.clickBack, self)
    self.nodeSayBg = winMgr:getWindow(strPrefix.."kongjiandetail/wndsaybg") 
    local sizeBg = self.nodeSayBg:getPixelSize()

    local Spacerolesaycell = require("logic.space.spaceliuyancell")
    self.getSizeCell =  Spacerolesaycell.create(self.m_pMainFrame)
    self.getSizeCell:GetWindow():setVisible(false)

    local TableView2 = require "logic.space.tableview2"
    local sizeBg = self.nodeSayBg:getPixelSize()
    self.sayList = TableView2.create(self.nodeSayBg, TableView2.VERTICAL)
    self.sayList:setViewSize(sizeBg.width, sizeBg.height)
    self.sayList:setScrollContentSize(sizeBg.width, sizeBg.height)
    self.sayList:setPosition(0, 0)
    --self.sayList:setColumCount(2)
    self.sayList:setDataSourceFunc(self, Spacereceivegiftdialog.tableViewGetCellAtIndex)
    self.sayList:setGetCellHeightCallFunc(self,Spacereceivegiftdialog.tableViewGetCellHeight)
    self.sayList:setReachEdgeCallFunc(self, Spacereceivegiftdialog.tableViewReachEdge)

    local sizeBg = self.nodeSayBg:getPixelSize()
end


function Spacereceivegiftdialog:tableViewReachEdge(tableView, isTop)
    local spManager = getSpaceManager()
    if isTop then
        return
    end
    if self.nHaveShowNum <  #self.vRecGift then
        self:addNextPage()
        return
    end

    local nnRoleId = spManager:getCurRoleId()
    local nPageId =  self.vRecGift[#self.vRecGift].nBbsId --spManager.nRecGiftPageHaveDown + 1 
    require("logic.space.spacepro.spaceprotocol_receiveGiftList").request(nnRoleId,nPageId)

end

function Spacereceivegiftdialog:addNextPage()
    local spManager = getSpaceManager()
    local nToAddNum = spManager.nRecGiftNumInPage
    local nNewNum = self.nHaveShowNum + nToAddNum
    if nNewNum > #self.vRecGift then
        nNewNum = #self.vRecGift
    end
    self.nHaveShowNum = nNewNum

    self.sayList:setCellCount(self.nHaveShowNum)
    self.sayList:reloadData()
end


function Spacereceivegiftdialog:tableViewGetCellHeight(nIdx)
    local nIndex = nIdx + 1 
    local oneCellData = self.vRecGift[nIndex]

    self.getSizeCell:refreshOneCell(oneCellData)
    local nHeight = self.getSizeCell:GetWindow():getPixelSize().height
    return nHeight
end


function Spacereceivegiftdialog:createOneCell(parent,nIndex)
    local Spaceliuyancell = require("logic.space.spaceliuyancell")
    local cell = Spaceliuyancell.create(parent)

    cell:setDelegate(self,Spaceliuyancell.eCallBackType.clickDel,Spacereceivegiftdialog.cellClickDel)

    return cell
end

function Spacereceivegiftdialog:cellClickDel(liuyanCell)
    local nBbsId = liuyanCell.oneCellData.nBbsId
    local nnRoleId = getSpaceManager():getMyRoleId()
    require("logic.space.spacepro.spaceprotocol_deleteBbs").request(nnRoleId,nBbsId)
end

function Spacereceivegiftdialog:refreshUIWithData(vReceiveGiftData)
  
end

function Spacereceivegiftdialog:setDelegate(pTarget,callBackType,callBack)
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end

function Spacereceivegiftdialog:callEvent(eType)
    local callBackData =  self.mapCallBack[eType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self)
end

function Spacereceivegiftdialog:clickBack(args)
    self:callEvent(Spacereceivegiftdialog.eCallBackType.clickBack)
end

function Spacereceivegiftdialog:cellClickLike(cell)
end

function Spacereceivegiftdialog:detailClickBack()
    self.nodeBgContent:setVisible(true)
    self.nodeBgDetail:setVisible(false)
end

function Spacereceivegiftdialog:clickDelete(cell)
end

function Spacereceivegiftdialog:refreshBbsCell(bbsCell,bbsData)
  --local bCanDel = getSpaceManager():getBbsCanDel(bbsData)
  local bCanDel = false
  bbsCell:refreshDelBtnVisible(bCanDel)
end


function Spacereceivegiftdialog:tableViewGetCellAtIndex(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:createOneCell(tableView.container,nIndex )
    end
    local oneCellData = self.vRecGift[nIndex] 
    cell:refreshOneCell(oneCellData)
    self:refreshBbsCell(cell,oneCellData)
    return cell
end


return Spacereceivegiftdialog
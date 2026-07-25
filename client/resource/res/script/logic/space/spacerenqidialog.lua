
Spacerenqidialog = {}
Spacerenqidialog.__index = Spacerenqidialog

local nPrefix = 0


Spacerenqidialog.eCallBackType = 
{
    clickBack = 1

}

function Spacerenqidialog.create()
	local dlg = Spacerenqidialog:new()
    dlg:clearData()
	dlg:OnCreate()
    dlg:registerEvent()
	return dlg
end

function Spacerenqidialog:new()
	local self = {}
	setmetatable(self, Spacerenqidialog)
    self:clearData()
	return self
end

function Spacerenqidialog:clearData()
    self.mapCallBack = {}
    self.vPopuList = {}
    self.nHaveShowNum =0
end

function Spacerenqidialog:DestroyDialog()
    self:removeEvent()
    self.sayList:destroyCells()
    self:clearData()
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end

function Spacerenqidialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:removeEvent(Eventmanager.eCmd.reloadPopularityList,self,Spacerenqidialog.reloadPopularityList)
    eventManager:removeEvent(Eventmanager.eCmd.refreshPopularityListDownNextPage,self,Spacerenqidialog.refreshPopularityListDownNextPage)
    eventManager:removeEvent(Eventmanager.eCmd.refreshRoleLevel,self,Spacerenqidialog.refreshRoleLevel)
    
end

function Spacerenqidialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:addEvent(Eventmanager.eCmd.reloadPopularityList,self,Spacerenqidialog.reloadPopularityList)
    eventManager:addEvent(Eventmanager.eCmd.refreshPopularityListDownNextPage,self,Spacerenqidialog.refreshPopularityListDownNextPage)
    eventManager:addEvent(Eventmanager.eCmd.refreshRoleLevel,self,Spacerenqidialog.refreshRoleLevel)
end

function Spacerenqidialog:refreshRoleLevel(vstrParam)
    --self.sayList:reloadData()

     if not self.sayList.visibleCells then
        return
    end
    for k,cell in pairs( self.sayList.visibleCells) do
        cell:refreshLevel()
    end
end

function Spacerenqidialog:reloadPopularityList(vstrParam)
    self.sayList:destroyCells()

    local spManager = getSpaceManager()
    self.vPopuList = spManager.vPopularityList

    self:addNextPage()
end

function Spacerenqidialog:refreshPopularityListDownNextPage(vstrParam)
    self:addNextPage()
end

function Spacerenqidialog:addNextPage()
    local spManager = getSpaceManager()
    local nToAddNum = spManager.nPopuNumInPage
    local nNewNum = self.nHaveShowNum + nToAddNum
    if nNewNum > #self.vPopuList then
        nNewNum = #self.vPopuList
    end
    self.nHaveShowNum = nNewNum

    self.sayList:setCellCount(self.nHaveShowNum)
    self.sayList:reloadData()
end



function Spacerenqidialog:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local strLayoutName = "kongjiandetail.layout"
    nPrefix = nPrefix +1
    local strPrefix = "Spacerenqidialog"..nPrefix
	self.m_pMainFrame = winMgr:loadWindowLayout(strLayoutName,strPrefix)

    self.btnSay = CEGUI.toPushButton(winMgr:getWindow(strPrefix.."kongjiandetail/btnsay"))--kongjiandetail/btnsay
    self.btnSay:subscribeEvent("MouseClick", Spacerenqidialog.clickBack, self)
    self.nodeSayBg = winMgr:getWindow(strPrefix.."kongjiandetail/wndsaybg") 
    local sizeBg = self.nodeSayBg:getPixelSize()

	--self.scrollAllSay = CEGUI.toScrollablePane(winMgr:getWindow("kongjiancell_mtg/youzhuangtai/list"))
	--self.wndNoSay = winMgr:getWindow("kongjiancell_mtg/meizhuangtai")

   

    local sizeBg = self.nodeSayBg:getPixelSize()
    self.sayList = TableView.create(self.nodeSayBg, TableView.VERTICAL)
    self.sayList:setViewSize(sizeBg.width, sizeBg.height)
    self.sayList:setPosition(0, 0)
    self.sayList:setColumCount(2)
    self.sayList:setDataSourceFunc(self, Spacerenqidialog.tableViewGetCellAtIndex)
    self.sayList:setReachEdgeCallFunc(self, Spacerenqidialog.tableViewReachEdge)


end


function Spacerenqidialog:tableViewReachEdge(tableView, isTop)
    local spManager = getSpaceManager()
    if isTop then
        return
    end
    if self.nHaveShowNum <  #self.vPopuList then
        self:addNextPage()
        return
    end

    local nnRoleId = spManager:getCurRoleId()
    local nPageId =  self.vPopuList[#self.vPopuList].nPopuId -- spManager.nPopuPageHaveDown + 1 
    require("logic.space.spacepro.spaceprotocol_popularityList").request(nnRoleId,nPageId)

end

function Spacerenqidialog:refreshUIWithData(vRenqiData)

end

function Spacerenqidialog:setDelegate(pTarget,callBackType,callBack)
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end

function Spacerenqidialog:callEvent(eType)
    local callBackData =  self.mapCallBack[eType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self)
end

function Spacerenqidialog:clickBack(args)
    self:callEvent(Spacerenqidialog.eCallBackType.clickBack)
end

function Spacerenqidialog:cellClickLike(cell)

end


function Spacerenqidialog:detailClickBack()
    self.nodeBgContent:setVisible(true)
    self.nodeBgDetail:setVisible(false)

end

function Spacerenqidialog:clickDelete(cell)

end


function Spacerenqidialog:createOneCell(parent,nIndex)
    local cell = require("logic.space.spacerenqicell").create(parent)
    return cell
end

function Spacerenqidialog:tableViewGetCellAtIndex(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:createOneCell(tableView.container,nIndex )
    end
    local spManager = require("logic.space.spacemanager").getInstance()
    
    local oneCellData = spManager.vPopularityList[nIndex]
    cell:refreshOneCell(oneCellData)
    return cell
end




return Spacerenqidialog
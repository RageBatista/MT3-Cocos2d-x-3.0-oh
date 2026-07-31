
Spaceliuyannpcdialog = {}
Spaceliuyannpcdialog.__index = Spaceliuyannpcdialog

local nPrefix = 0


function Spaceliuyannpcdialog.create()
	local dlg = Spaceliuyannpcdialog:new()
    dlg:clearData()
	dlg:OnCreate()
    dlg:registerEvent()
    dlg:reqInfo()
	return dlg
end

function Spaceliuyannpcdialog:new()
	local self = {}
	setmetatable(self, Spaceliuyannpcdialog)
    self:clearData()
	return self
end

function Spaceliuyannpcdialog:clearData()
    
    self.nHaveShowNum = 0
end

function Spaceliuyannpcdialog:DestroyDialog()
    if self.renqiDlg then
        self.renqiDlg:DestroyDialog()
    end

    self.getSizeCell:OnClose()
    self:removeEvent()
   
    self.sayList:destroyCells()
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end

function Spaceliuyannpcdialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:removeEvent(Eventmanager.eCmd.refreshNpcSpaceInfo,self,Spaceliuyannpcdialog.refreshNpcSpaceInfo)
    eventManager:removeEvent(Eventmanager.eCmd.reloadNpcSpaceBbs,self,Spaceliuyannpcdialog.reloadNpcSpaceBbs)
    
    eventManager:removeEvent(Eventmanager.eCmd.refreshNpcBbs_downNextPage,self,Spaceliuyannpcdialog.refreshNpcBbs_downNextPage)
    eventManager:removeEvent(Eventmanager.eCmd.refreshRoleLevel,self,Spaceliuyannpcdialog.refreshRoleLevel)
end



function Spaceliuyannpcdialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:addEvent(Eventmanager.eCmd.refreshNpcSpaceInfo,self,Spaceliuyannpcdialog.refreshNpcSpaceInfo)
    eventManager:addEvent(Eventmanager.eCmd.reloadNpcSpaceBbs,self,Spaceliuyannpcdialog.reloadNpcSpaceBbs)

    eventManager:addEvent(Eventmanager.eCmd.refreshNpcBbs_downNextPage,self,Spaceliuyannpcdialog.refreshNpcBbs_downNextPage)
    eventManager:addEvent(Eventmanager.eCmd.refreshRoleLevel,self,Spaceliuyannpcdialog.refreshRoleLevel)

    
   
end

function Spaceliuyannpcdialog:refreshNpcBbs_downNextPage(vstrParam)
    self:addNextPage()
end

function Spaceliuyannpcdialog:reloadNpcSpaceBbs(vstrParam)
    self.sayList:destroyCells()

    local spManager = getSpaceManager()
    self.nHaveShowNum = spManager.nBbsNumInPage

    if self.nHaveShowNum > #spManager.vLeaveWord_npc then
        self.nHaveShowNum = #spManager.vLeaveWord_npc
    end


    self.sayList:setCellCount(self.nHaveShowNum)
    self.sayList:reloadData()
end

function Spaceliuyannpcdialog:refreshNpcSpaceInfo(vstrParam)
    local spManager = getSpaceManager()
    local nGiftNum = spManager.nGiftNum
    local nRenqiNum = spManager.nRenqiNum
    local nRecGiftNum = spManager.nRecGiftNum

    self.labelGift:setText(tostring(nGiftNum))
    self.labelCai:setText(tostring(nRenqiNum))
    self.labelRecGift:setText(tostring(nRecGiftNum))
end



function Spaceliuyannpcdialog:liuyanResult()
    local strNotOpen = require("utils.mhsdutils").get_msgtipstring(162148)
    GetCTipsManager():AddMessageTip(strNotOpen)
end

function Spaceliuyannpcdialog:refreshRoleLevel(vstrParam)
    --self.sayList:reloadData()

    if not self.sayList.visibleCells then
        return
    end
    for k,cell in pairs( self.sayList.visibleCells) do
        cell:refreshLevel()
    end

end

function Spaceliuyannpcdialog:giveGiftEnd(vstrParam)
    local nnRoleId = getSpaceManager():getCurRoleId()
    local p = require "protodef.fire.pb.friends.cgetspaceinfo":new()
	p.roleid = nnRoleId
	require "manager.luaprotocolmanager":send(p)
end

function Spaceliuyannpcdialog:addNextPage()
    local spManager = getSpaceManager()
    local nToAddNum = spManager.nBbsNumInPage
    local nNewNum = self.nHaveShowNum + nToAddNum
    if nNewNum > #spManager.vLeaveWord_npc then
        nNewNum = #spManager.vLeaveWord_npc
    end
    self.nHaveShowNum = nNewNum

    self.sayList:setCellCount(self.nHaveShowNum)
    self.sayList:reloadData()
end

function Spaceliuyannpcdialog:refreshLeftWord(vstrParam)
    local spManager = require("logic.space.spacemanager").getInstance()
    local nAllNum = #spManager.vLeaveWord_npc

    self.sayList:setCellCount(nAllNum)
    self.sayList:reloadData()
end

function Spaceliuyannpcdialog:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local strLayoutName = "kongjianliuyanbandashi.layout"
    nPrefix = nPrefix +1
	self.m_pMainFrame = winMgr:loadWindowLayout(strLayoutName,tostring(nPrefix))
    --self.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
    --kongjianliuyanbandashi_mtg/detail
    self.nodeInputBg = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/bg/inputbg") 
    self.nodeInputBg:setMousePassThroughEnabled(true)

    self.noceBgContent = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/content") 
    self.nodeBgDetail = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/detail")
    self.nodeBgDetail:setMousePassThroughEnabled(true)



    self.labelGift = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/baoxiangdi/baoxiangshu")

    self.labelCai = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/renqudi/renqishu")
    

    
    self.imageFlower = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/liwudi/liwutu")
    self.imageFlower:subscribeEvent("MouseClick", Spaceliuyannpcdialog.clickBuyFlower, self)

    self.labelRecGift = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/liwudi/liwushu")
    

    self.nodeSayBg = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/dibu/di/list") 
    self.nodeBbsListBg = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/dibu/di") 

    self.oldListBgSize = self.nodeSayBg:getPixelSize()

    self.nodeBgBottomBtn = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/dibu/btntree")
    self.oldBottomBgSize = self.nodeBgBottomBtn:getPixelSize()

    self.nodeBgBottomBtn:setAlwaysOnTop(true)

    self.btnCaiOther = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/dibu/btntree/btn1"))
    self.btnCaiOther:subscribeEvent("MouseClick", Spaceliuyannpcdialog.clickCaiOther, self)

    self.btnZengsongOther = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/dibu/btntree/btn11"))
    self.btnZengsongOther:subscribeEvent("MouseClick", Spaceliuyannpcdialog.clickZengsongOther, self)

    self.btnAddFriend = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/dibu/btntree/btn2"))
    self.btnAddFriend:subscribeEvent("MouseClick", Spaceliuyannpcdialog.clickAddFriend, self)

    self.btnAddFriend:setVisible(false)

    self.labelTitle = winMgr:getWindow(nPrefix.."kongjianliuyanbandashi_mtg/bg/inputbg/labei") 


    local Spacerolesaycell = require("logic.space.spaceliuyancell")
    self.getSizeCell =  Spacerolesaycell.create(self.m_pMainFrame)
    self.getSizeCell:GetWindow():setVisible(false)

    local TableView2 = require "logic.space.tableview2"
    local sizeBg = self.nodeSayBg:getPixelSize()
    self.sayList = TableView2.create(self.nodeSayBg, TableView2.VERTICAL)
    self.sayList:setViewSize(sizeBg.width, sizeBg.height)
    self.sayList:setScrollContentSize(sizeBg.width, sizeBg.height)
    self.sayList:setPosition(0, 0)
    self.sayList:setDataSourceFunc(self, Spaceliuyannpcdialog.tableViewGetCellAtIndex)
    self.sayList:setGetCellHeightCallFunc(self, Spaceliuyannpcdialog.tableViewGetCellHeight)
    self.sayList:setReachEdgeCallFunc(self, Spaceliuyannpcdialog.tableViewReachEdge)
    
end

function Spaceliuyannpcdialog:reqInfo()
    local p = require "protodef.fire.pb.friends.cgetxshspaceinfo":new()
	require "manager.luaprotocolmanager":send(p)

    local nPage = 0
    local strRoleId = getSpaceManager().strNpcSpaceRoleId
    require("logic.space.spacepro.spaceprotocol_npcLiuyanList").request(strRoleId,nPage)
end

function Spaceliuyannpcdialog:clickBuyFlower()
    require("logic.space.spacebuyflowerdialog").getInstanceAndShow()
end


function Spaceliuyannpcdialog:tableViewReachEdge(tableView, isTop)
    local spManager = getSpaceManager()
    if isTop then
    else
        if  self.nHaveShowNum ==  #spManager.vLeaveWord_npc then
            local nnRoleId = spManager:getCurRoleId()
            local nPageId = spManager.vLeaveWord_npc[#spManager.vLeaveWord_npc].nBbsId    --spManager.nBbsPageHaveDown + 1 
            require("logic.space.spacepro.spaceprotocol_bbsList").request(nnRoleId,nPageId)
            return 
        end
        self:addNextPage()
    end
end



function Spaceliuyannpcdialog:tableViewGetCellHeight(nIdx)
    local spManager = require("logic.space.spacemanager").getInstance()

    local nIndex = nIdx + 1 
    local oneCellData = spManager.vLeaveWord_npc[nIndex]

    self.getSizeCell:refreshOneCell(oneCellData)
    local nHeight = self.getSizeCell:GetWindow():getPixelSize().height
    return nHeight
end

function Spaceliuyannpcdialog:refreshBottomBtn()

end

function Spaceliuyannpcdialog:clickCaiOther(args)
    local p = require "protodef.fire.pb.friends.cxshspace":new()
	require "manager.luaprotocolmanager":send(p)
end

function Spaceliuyannpcdialog:clickZengsongOther(args)
    require("logic.space.spacenpcgivedialog").getInstanceAndShow()
end

function Spaceliuyannpcdialog:clickAddFriend(args)
    local nnRoleId = getSpaceManager():getCurRoleId()

    local bFriend = gGetFriendsManager():isMyFriend(nnRoleId)
    if bFriend then
        gGetFriendsManager():RequestDelFriend(nnRoleId)
    else
        gGetFriendsManager():RequestAddFriend(nnRoleId)
    end
end

function Spaceliuyannpcdialog:refreshAddFriendBtn()
    --11528 add
    --11529 del friend
    local nnRoleId = getSpaceManager():getCurRoleId()
    local bFriend = gGetFriendsManager():isMyFriend(nnRoleId)
    local nTitleId = 11528
    if bFriend then
        nTitleId = 11529
    else
        nTitleId = 11528
    end
    local strTitle = require("utils.mhsdutils").get_resstring(nTitleId)
    self.btnAddFriend:setText(strTitle)
end







function Spaceliuyannpcdialog:renqiClickBack(renqiDlg)
    if not renqiDlg then
        return
    end
    self.renqiDlg:DestroyDialog()
    self.renqiDlg = nil

    self.noceBgContent:setVisible(true)
    self.nodeBgDetail:setVisible(false)
end

function Spaceliuyannpcdialog:receiveGiftClickBack(receiveGiftDlg)
    if not receiveGiftDlg then
        return
    end
    receiveGiftDlg:DestroyDialog()

    self.noceBgContent:setVisible(true)
    self.nodeBgDetail:setVisible(false)
end

function Spaceliuyannpcdialog:clickReceiveGift(args)
    self.noceBgContent:setVisible(false)
    self.nodeBgDetail:setVisible(true)

    local Spacereceivegiftdialog = require("logic.space.spacereceivegiftdialog")
    local receiveDlg = Spacereceivegiftdialog.create()
    receiveDlg:setDelegate(self,Spacereceivegiftdialog.eCallBackType.clickBack,Spaceliuyannpcdialog.receiveGiftClickBack)
    self.nodeBgDetail:addChildWindow(receiveDlg.m_pMainFrame)
    receiveDlg.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))

    local nnRoleId = getSpaceManager():getCurRoleId()
    local nPage = 0
    require("logic.space.spacepro.spaceprotocol_receiveGiftList").request(nnRoleId,nPage)

end

function Spaceliuyannpcdialog:createOneCell(parent,nIndex)
    local Spaceliuyancell = require("logic.space.spaceliuyancell")
    local cell = require("logic.space.spaceliuyancell").create(parent)

    return cell
end


function Spaceliuyannpcdialog:refreshBbsCell(bbsCell,bbsData)
  local bCanDel = false -- getSpaceManager():getBbsCanDel(bbsData)
  bbsCell:refreshDelBtnVisible(bCanDel)
end


function Spaceliuyannpcdialog:tableViewGetCellAtIndex(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:createOneCell(tableView.container,nIndex )
    end
    local spaceManager =  getSpaceManager() --require("logic.space.spacemanager").getInstance()
    local oneCellData = spaceManager.vLeaveWord_npc[nIndex]
    cell:refreshOneCell(oneCellData)
    self:refreshBbsCell(cell,oneCellData)
    return cell
end



function Spaceliuyannpcdialog:refreshUI()

end

return Spaceliuyannpcdialog

Spaceliuyandialog = {}
Spaceliuyandialog.__index = Spaceliuyandialog

local nPrefix = 0

function Spaceliuyandialog.create()
	local dlg = Spaceliuyandialog:new()
    dlg:clearData()
	dlg:OnCreate()
    dlg:registerEvent()
	return dlg
end

function Spaceliuyandialog:new()
	local self = {}
	setmetatable(self, Spaceliuyandialog)
    self:clearData()
	return self
end

function Spaceliuyandialog:clearData()
    
    self.nHaveShowNum = 0
    self.receiveDlg = nil
    self.renqiDlg = nil
end

function Spaceliuyandialog:DestroyDialog()
    if self.renqiDlg then
        self.renqiDlg:DestroyDialog()
    end

    if self.receiveDlg then
         self.receiveDlg:DestroyDialog()
    end

    self.getSizeCell:OnClose()
    self:removeEvent()
    if self.spInputDlg then
        self.spInputDlg:DestroyDialog()
    end
    self.sayList:destroyCells()
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end

function Spaceliuyandialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:removeEvent(Eventmanager.eCmd.refreshLeftWord,self,Spaceliuyandialog.refreshLeftWord)
    eventManager:removeEvent(Eventmanager.eCmd.delBbs,self,Spaceliuyandialog.delBbs)
    eventManager:removeEvent(Eventmanager.eCmd.addPopular,self,Spaceliuyandialog.addPopular)
    eventManager:removeEvent(Eventmanager.eCmd.refreshPopuInfo,self,Spaceliuyandialog.refreshPopuInfo)
    eventManager:removeEvent(Eventmanager.eCmd.reloadLeftWord,self,Spaceliuyandialog.reloadLeftWord)
    
    eventManager:removeEvent(Eventmanager.eCmd.refreshSpaceAddFriendBtn,self,Spaceliuyandialog.refreshSpaceAddFriendBtn)
    eventManager:removeEvent(Eventmanager.eCmd.refreshLeftWordDownNextPage,self,Spaceliuyandialog.refreshLeftWordDownNextPage)
    eventManager:removeEvent(Eventmanager.eCmd.refreshLeftWordAddBbs,self,Spaceliuyandialog.refreshLeftWordAddBbs)
    eventManager:removeEvent(Eventmanager.eCmd.giveGiftEnd,self,Spaceliuyandialog.giveGiftEnd)
    eventManager:removeEvent(Eventmanager.eCmd.refreshRoleLevel,self,Spaceliuyandialog.refreshRoleLevel)

    eventManager:removeEvent(Eventmanager.eCmd.liuyanResult,self,Spaceliuyandialog.liuyanResult)
    

           
end



function Spaceliuyandialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:addEvent(Eventmanager.eCmd.refreshLeftWord,self,Spaceliuyandialog.refreshLeftWord)
    eventManager:addEvent(Eventmanager.eCmd.delBbs,self,Spaceliuyandialog.delBbs)
    eventManager:addEvent(Eventmanager.eCmd.addPopular,self,Spaceliuyandialog.addPopular)
    eventManager:addEvent(Eventmanager.eCmd.refreshPopuInfo,self,Spaceliuyandialog.refreshPopuInfo)
    eventManager:addEvent(Eventmanager.eCmd.reloadLeftWord,self,Spaceliuyandialog.reloadLeftWord)
    
    eventManager:addEvent(Eventmanager.eCmd.refreshSpaceAddFriendBtn,self,Spaceliuyandialog.refreshSpaceAddFriendBtn)
    eventManager:addEvent(Eventmanager.eCmd.refreshLeftWordDownNextPage,self,Spaceliuyandialog.refreshLeftWordDownNextPage)
    eventManager:addEvent(Eventmanager.eCmd.refreshLeftWordAddBbs,self,Spaceliuyandialog.refreshLeftWordAddBbs)
    eventManager:addEvent(Eventmanager.eCmd.giveGiftEnd,self,Spaceliuyandialog.giveGiftEnd)
    eventManager:addEvent(Eventmanager.eCmd.refreshRoleLevel,self,Spaceliuyandialog.refreshRoleLevel)

    eventManager:addEvent(Eventmanager.eCmd.liuyanResult,self,Spaceliuyandialog.liuyanResult)
end

function Spaceliuyandialog:liuyanResult()
    
    local strNotOpen = require("utils.mhsdutils").get_msgtipstring(162148)
    GetCTipsManager():AddMessageTip(strNotOpen)
    if self.spInputDlg then
    self.spInputDlg:clearContent()
    end
end

function Spaceliuyandialog:refreshRoleLevel(vstrParam)
    --self.sayList:reloadData()

    if not self.sayList.visibleCells then
        return
    end
    for k,cell in pairs( self.sayList.visibleCells) do
        cell:refreshLevel()
    end

end

function Spaceliuyandialog:giveGiftEnd(vstrParam)
    local nnRoleId = getSpaceManager():getCurRoleId()
    local p = require "protodef.fire.pb.friends.cgetspaceinfo":new()
	p.roleid = nnRoleId
	require "manager.luaprotocolmanager":send(p)
end

function Spaceliuyandialog:refreshLeftWordAddBbs(vstrParam)
    self:reloadLeftWord()
end

function Spaceliuyandialog:refreshLeftWordDownNextPage(vstrParam)
    self:addNextPage()
end

function Spaceliuyandialog:refreshSpaceAddFriendBtn(vstrParam)
    self:refreshAddFriendBtn()
end

function Spaceliuyandialog:refreshPopuInfo(vstrParam)
    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData

    self.labelGift:setText(tostring(roleSpaceInfoData.nGiftNum))
    self.labelCai:setText(tostring(roleSpaceInfoData.nPopuNum))
    self.labelRecGift:setText(tostring(roleSpaceInfoData.nRecGift))
end

function Spaceliuyandialog:addPopular(vstrParam)
    --self.labelCai:setText()
end

function Spaceliuyandialog:delBbs(vstrParam)
    local spManager = getSpaceManager()
    local nAllNum = #spManager.vLeaveWord

    self.sayList:clearCellPosData()
    self.sayList:setCellCount(nAllNum)
    self.sayList:reloadData()
    
end


function Spaceliuyandialog:reloadLeftWord(vstrParam)
    self.sayList:destroyCells()

    local spManager = getSpaceManager()
    self.nHaveShowNum = spManager.nBbsNumInPage

    if self.nHaveShowNum > #spManager.vLeaveWord then
        self.nHaveShowNum = #spManager.vLeaveWord
    end

    --local spManager = getSpaceManager()
    --local nAllNum = #spManager.vLeaveWord
    self.sayList:setCellCount(self.nHaveShowNum)
    self.sayList:reloadData()
end

function Spaceliuyandialog:addNextPage()
    local spManager = getSpaceManager()
    local nToAddNum = spManager.nBbsNumInPage
    local nNewNum = self.nHaveShowNum + nToAddNum
    if nNewNum > #spManager.vLeaveWord then
        nNewNum = #spManager.vLeaveWord
    end
    self.nHaveShowNum = nNewNum

    self.sayList:setCellCount(self.nHaveShowNum)
    self.sayList:reloadData()
end

function Spaceliuyandialog:refreshLeftWord(vstrParam)
    local spManager = require("logic.space.spacemanager").getInstance()
    local nAllNum = #spManager.vLeaveWord


    self.sayList:setCellCount(nAllNum)
    self.sayList:reloadData()
end

function Spaceliuyandialog:OnCreate()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local strLayoutName = "kongjianliuyanban.layout"
    nPrefix = nPrefix +1
	self.m_pMainFrame = winMgr:loadWindowLayout(strLayoutName,tostring(nPrefix))
    --self.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))

    self.nodeInputBg = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/bg/inputbg") 
    self.nodeInputBg:setMousePassThroughEnabled(true)

    self.noceBgContent = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/content") 
    self.nodeBgDetail = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/detail")
    self.nodeBgDetail:setMousePassThroughEnabled(true)

    --self.nodeInputBg = winMgr:getWindow("kongjianfriend/inputbg") 
    self.btnSay = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/bg/liuyan"))
    self.btnSay:subscribeEvent("MouseClick", Spaceliuyandialog.clickLiuyan, self)

    self.labelGift = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/baoxiangdi/baoxiangshu")
    self.btnGift = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/baoxiangdi/btnbaoxiang"))
    self.btnGift:subscribeEvent("MouseClick", Spaceliuyandialog.clickAddGift, self)

    self.labelCai = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/renqudi/renqishu")
    self.btnCai = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/renqudi/btnrenqi"))
    self.btnCai:subscribeEvent("MouseClick", Spaceliuyandialog.clickShowRenqi, self)

    
    self.imageFlower = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/liwudi/liwutu")
    self.imageFlower:subscribeEvent("MouseClick", Spaceliuyandialog.clickBuyFlower, self)

    self.labelRecGift = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/liwudi/liwushu")
    self.btnReceiveGift = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/liwudi/btnliwu"))
    self.btnReceiveGift:subscribeEvent("MouseClick", Spaceliuyandialog.clickReceiveGift, self)

    self.nodeSayBg = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/dibu/di/list") 
    self.nodeBbsListBg = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/dibu/di") 

    self.oldListBgSize = self.nodeSayBg:getPixelSize()

    self.nodeBgBottomBtn = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/dibu/btntree")
    self.oldBottomBgSize = self.nodeBgBottomBtn:getPixelSize()

    self.btnCaiOther = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/dibu/btntree/btn1"))
    self.btnCaiOther:subscribeEvent("MouseClick", Spaceliuyandialog.clickCaiOther, self)

    self.btnZengsongOther = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/dibu/btntree/btn11"))
    self.btnZengsongOther:subscribeEvent("MouseClick", Spaceliuyandialog.clickZengsongOther, self)

    self.btnAddFriend = CEGUI.toPushButton(winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/dibu/btntree/btn2"))
    self.btnAddFriend:subscribeEvent("MouseClick", Spaceliuyandialog.clickAddFriend, self)

    --[[
    local layoutNamegetSize = "kongjianliwucell.layout"
    local strPrefix = "getsize"
	local nodeCell = winMgr:loadWindowLayout(layoutNamegetSize,strPrefix)
    self.nodeCellSize = nodeCell:getPixelSize()
    winMgr:destroyWindow(nodeCell)
    --]]

    local Spacerolesaycell = require("logic.space.spaceliuyancell")
    self.getSizeCell =  Spacerolesaycell.create(self.m_pMainFrame)
    self.getSizeCell:GetWindow():setVisible(false)

    local TableView2 = require "logic.space.tableview2"
    local sizeBg = self.nodeSayBg:getPixelSize()
    self.sayList = TableView2.create(self.nodeSayBg, TableView2.VERTICAL)
    self.sayList:setViewSize(sizeBg.width, sizeBg.height)
    self.sayList:setScrollContentSize(sizeBg.width, sizeBg.height)
    self.sayList:setPosition(0, 0)
    self.sayList:setDataSourceFunc(self, Spaceliuyandialog.tableViewGetCellAtIndex)
    self.sayList:setGetCellHeightCallFunc(self, Spaceliuyandialog.tableViewGetCellHeight)
    self.sayList:setReachEdgeCallFunc(self, Spaceliuyandialog.tableViewReachEdge)

    local Spaceinputdialog = require("logic.space.spaceinputdialog")
    self.spInputDlg = Spaceinputdialog.create()
    self.nodeInputBg:addChildWindow(self.spInputDlg.m_pMainFrame)
    self.spInputDlg.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
    self.spInputDlg:setDelegate(self,Spaceinputdialog.eCallBackType.clickBack,Spaceliuyandialog.inputClickBack)
    self.spInputDlg:setDelegate(self,Spaceinputdialog.eCallBackType.clickSend,Spaceliuyandialog.inputClickSend)

    self:setInputVisible(false)

    self:refreshPopuInfo()
    self:refreshBottomBtn()
end

function Spaceliuyandialog:clickBuyFlower()
    require("logic.space.spacebuyflowerdialog").getInstanceAndShow()
end


function Spaceliuyandialog:tableViewReachEdge(tableView, isTop)
    local spManager = getSpaceManager()
    if isTop then
    else
        if  self.nHaveShowNum ==  #spManager.vLeaveWord then
            local nnRoleId = spManager:getCurRoleId()
            local nPageId = spManager.vLeaveWord[self.nHaveShowNum].nBbsId --spManager.nBbsPageHaveDown + 1 
            require("logic.space.spacepro.spaceprotocol_bbsList").request(nnRoleId,nPageId)
            return 
        end
        self:addNextPage()
    end
end



function Spaceliuyandialog:tableViewGetCellHeight(nIdx)
    local spManager = require("logic.space.spacemanager").getInstance()

    local nIndex = nIdx + 1 
    local oneCellData = spManager.vLeaveWord[nIndex]

    self.getSizeCell:refreshOneCell(oneCellData)
    local nHeight = self.getSizeCell:GetWindow():getPixelSize().height
    return nHeight
end

function Spaceliuyandialog:refreshBottomBtn()

    --self.nodeSayBg = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/dibu/di/list") 
    --self.nodeBbsListBg = winMgr:getWindow(nPrefix.."kongjianliuyanban_mtg/dibu/di") 
    self.oldListBgSize = self.nodeSayBg:getPixelSize()
    self.oldBottomBgSize = self.nodeBgBottomBtn:getPixelSize()

    local nnCurShowId = getSpaceManager():getCurRoleId()
    local nnMyRoleId = getSpaceManager():getMyRoleId()

    if nnCurShowId ~= nnMyRoleId then
        self.nodeBgBottomBtn:setVisible(true)
        local nNewListBgHeight = self.oldListBgSize.height - self.oldBottomBgSize.height
        self.nodeSayBg:setHeight(CEGUI.UDim(0,nNewListBgHeight))
        self.nodeBbsListBg:setHeight(CEGUI.UDim(0,nNewListBgHeight))

        --local sizeBg = self.nodeSayBg:getPixelSize()
        self.sayList:setViewSize(self.oldListBgSize.width,nNewListBgHeight)
    else
        self.nodeBgBottomBtn:setVisible(false)
    end

    self:refreshAddFriendBtn()

    local nnCurShowId = getSpaceManager():getCurRoleId()
    local nnMyRoleId = getSpaceManager():getMyRoleId()

    if nnCurShowId ~=  nnMyRoleId then
        self.btnGift:setVisible(false)
    else
        self.btnGift:setVisible(true)
    end
end

function Spaceliuyandialog:clickCaiOther(args)
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nnTargetRoleId = spLabel.showRoleData.nnRoleId
    local p = require "protodef.fire.pb.friends.cstepspace":new()
	p.spaceroleid = nnTargetRoleId
	require "manager.luaprotocolmanager":send(p)
end

function Spaceliuyandialog:clickZengsongOther(args)
    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData

    local nnRoleId = roleSpaceInfoData.nnRoleId
    local strUserName = roleSpaceInfoData.strUserName
    local nLevel = roleSpaceInfoData.nLevel
    local nJobId = roleSpaceInfoData.nJobId
    local nShapeId = roleSpaceInfoData.nModelId
    local nHeadId = 0
    local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nShapeId)
    if shapeConf then
          nHeadId = shapeConf.littleheadID
    end
    local sendgift = require "logic.friend.sendgiftdialog".getInstanceAndShow()
    sendgift:insertCharacterWithParams(nnRoleId, strUserName, nLevel, nJobId, nHeadId)
    sendgift:createContactList(nnRoleId)
end

function Spaceliuyandialog:clickAddFriend(args)
    local nnRoleId = getSpaceManager():getCurRoleId()

    local bFriend = gGetFriendsManager():isMyFriend(nnRoleId)
    if bFriend then
        gGetFriendsManager():RequestDelFriend(nnRoleId)
    else
        gGetFriendsManager():RequestAddFriend(nnRoleId)
    end
end

function Spaceliuyandialog:refreshAddFriendBtn()
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


function Spaceliuyandialog:setInputVisible(bVisible)
    if self.spInputDlg then
        self.spInputDlg.m_pMainFrame:setVisible(bVisible)
    end
     self.btnSay:setVisible(not bVisible)
end

function Spaceliuyandialog:clickLiuyan(args)
     self:setInputVisible(true)
     self.spInputDlg.nToBbsId = -1
end

function Spaceliuyandialog:inputClickBack(inputDlg)
   self:setInputVisible(false)
   self.spInputDlg.nToBbsId = -1
end

function Spaceliuyandialog:inputClickSend(inputDlg)
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    --local nSpaceType = spLabel.nSpaceType
    local nnCurShowId = getSpaceManager():getCurRoleId()
    local nnMyRoleId = getSpaceManager():getMyRoleId()

    if nnCurShowId ~=  nnMyRoleId then
        local nnRoleId = getSpaceManager():getMyRoleId()
        local nnTargetRoleId = nnCurShowId
        local strContent =  inputDlg.richEditBox:GenerateParseText(false)
        local wstrPureText = inputDlg.richEditBox:GetPureText()
        strContent = GetChatManager():ProcessChatLinks(wstrPureText, inputDlg.richEditBox)

        local nToBbsId = inputDlg.nToBbsId
        local nGiftType = 0
        local nCai = 0
        require("logic.space.spacepro.spaceprotocol_liuyan").request(nnRoleId,nnTargetRoleId,strContent,nToBbsId,nGiftType,nCai)

    else
        local nnRoleId = getSpaceManager():getMyRoleId()
        local nnTargetRoleId = nnCurShowId
        local strContent =  inputDlg.richEditBox:GenerateParseText(false)
        local wstrPureText = inputDlg.richEditBox:GetPureText()
        strContent = GetChatManager():ProcessChatLinks(wstrPureText, inputDlg.richEditBox)

        local nToBbsId = inputDlg.nToBbsId
        local nGiftType = 0 
        local nCai = 0
        require("logic.space.spacepro.spaceprotocol_liuyan").request(nnRoleId,nnTargetRoleId,strContent,nToBbsId,nGiftType,nCai)
    end

      if GetChatManager() then
        local strHistory = inputDlg.richEditBox:GenerateParseText(false)
        local strColor = getSpaceManager():getNormalTextColor()
        strHistory = getSpaceManager():stringReplaceToColor(strHistory,strColor)

        GetChatManager():AddToChatHistory(strHistory)
    end
end

function Spaceliuyandialog:clickAddGift(args) --set gift
    local nnShowRoleId = getSpaceManager():getCurRoleId()
    local nnMyId = getSpaceManager():getMyRoleId()
    if nnMyId ~= nnShowRoleId then
        return
    end

    require("logic.space.spacesetgiftdialog").getInstanceAndShow()
end


function Spaceliuyandialog:clickShowRenqi(args)
    self.noceBgContent:setVisible(false)
    self.nodeBgDetail:setVisible(true)
    
    self.renqiDlg = require("logic.space.spacerenqidialog").create()
    self.renqiDlg:setDelegate(self,Spacerenqidialog.eCallBackType.clickBack,Spaceliuyandialog.renqiClickBack)
    self.nodeBgDetail:addChildWindow(self.renqiDlg.m_pMainFrame)
    self.renqiDlg.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))

    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    local nnRoleId = spLabel.showRoleData.nnRoleId
    local nPage = 0
    require("logic.space.spacepro.spaceprotocol_popularityList").request(nnRoleId,nPage)

end

function Spaceliuyandialog:renqiClickBack(renqiDlg)
    if not renqiDlg then
        return
    end
    self.renqiDlg:DestroyDialog()
    self.renqiDlg = nil

    self.noceBgContent:setVisible(true)
    self.nodeBgDetail:setVisible(false)
end

function Spaceliuyandialog:receiveGiftClickBack(receiveGiftDlg)
    if not self.receiveDlg then
        return
    end
    self.receiveDlg:DestroyDialog()
    self.receiveDlg = nil

    self.noceBgContent:setVisible(true)
    self.nodeBgDetail:setVisible(false)
end

function Spaceliuyandialog:clickReceiveGift(args)
    self.noceBgContent:setVisible(false)
    self.nodeBgDetail:setVisible(true)

    local Spacereceivegiftdialog = require("logic.space.spacereceivegiftdialog")
    self.receiveDlg = Spacereceivegiftdialog.create()
    self.receiveDlg:setDelegate(self,Spacereceivegiftdialog.eCallBackType.clickBack,Spaceliuyandialog.receiveGiftClickBack)
    self.nodeBgDetail:addChildWindow(self.receiveDlg.m_pMainFrame)
    self.receiveDlg.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))

    local nnRoleId = getSpaceManager():getCurRoleId()
    local nPage = 0
    require("logic.space.spacepro.spaceprotocol_receiveGiftList").request(nnRoleId,nPage)

end

function Spaceliuyandialog:createOneCell(parent,nIndex)
    local Spaceliuyancell = require("logic.space.spaceliuyancell")
    local cell = require("logic.space.spaceliuyancell").create(parent)

    cell:setDelegate(self,Spaceliuyancell.eCallBackType.clickBg,Spaceliuyandialog.cellClickBg)
    cell:setDelegate(self,Spaceliuyancell.eCallBackType.clickDel,Spaceliuyandialog.cellClickDel)

    return cell
end

function Spaceliuyandialog:cellClickBg(liuyanCell)
    local oneCellData = liuyanCell.oneCellData
    local nBbsId = oneCellData.nBbsId

    self:setInputVisible(true)
    self.spInputDlg.nToBbsId = nBbsId

    local strUserName = oneCellData.strUserName
    --11546
    local strTitle = require("utils.mhsdutils").get_resstring(11546) 
    strTitle = strTitle..strUserName
    self.spInputDlg:setPlaceHolder(strTitle)
    self.spInputDlg.labelPlaceholder:setVisible(true)
    self.spInputDlg:clearContent()

end

function Spaceliuyandialog:cellClickDel(liuyanCell)
    local nBbsId = liuyanCell.oneCellData.nBbsId
    local nnRoleId = getSpaceManager():getMyRoleId()
    --local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    --local nSpaceType = spLabel.nSpaceType
    require("logic.space.spacepro.spaceprotocol_deleteBbs").request(nnRoleId,nBbsId)
end


function Spaceliuyandialog:refreshBbsCell(bbsCell,bbsData)
  local bCanDel = getSpaceManager():getBbsCanDel(bbsData)
  bbsCell:refreshDelBtnVisible(bCanDel)
end


function Spaceliuyandialog:tableViewGetCellAtIndex(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:createOneCell(tableView.container,nIndex )
    end
    local spaceManager =  getSpaceManager() --require("logic.space.spacemanager").getInstance()
    local oneCellData = spaceManager.vLeaveWord[nIndex]
    cell:refreshOneCell(oneCellData)
    self:refreshBbsCell(cell,oneCellData)
    return cell
end


function Spaceliuyandialog:refreshEmptyNode()

end

function Spaceliuyandialog:refreshUI()

end

return Spaceliuyandialog
require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

Jingjidialog5 = {}
setmetatable(Jingjidialog5, Dialog)
Jingjidialog5.__index = Jingjidialog5
local _instance;



Jingjidialog5.eRankType = 
{
    rankA=1,
    rankB=2
}

--//===============================
function Jingjidialog5:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    --jingjichangdiglog5v5zhenying/paihangbang
    self.labelLeftTime = winMgr:getWindow("jingjichangdiglog5v5zhenying/huodongshijian/time") 
    --jingjichangdiglog5v5zhenying/paihangbang/gundong
    self.scrollRankA = CEGUI.toScrollablePane(winMgr:getWindow("jingjichangdiglog5v5zhenying/paihangbang/gundong"))
    self.winMyRankA = winMgr:getWindow("jingjichangdiglog5v5zhenying/paihangbang/diban/mypaihang")

    self.nHeightScrollOld = self.scrollRankA:getPixelSize().height 
    self.nHeightMyCell = self.winMyRankA:getPixelSize().height 
    
    self.scrollRankB = CEGUI.toScrollablePane(winMgr:getWindow("jingjichangdiglog5v5zhenying/paihangbang/gundong1"))
    self.winMyRankB = winMgr:getWindow("jingjichangdiglog5v5zhenying/paihangbang/diban/mypaihang1")

     local sizeBgA = self.scrollRankA:getPixelSize()
     self.tableViewA = TableView.create(self.scrollRankA, TableView.VERTICAL)
     self.tableViewA:setViewSize(sizeBgA.width, sizeBgA.height)
     self.tableViewA:setPosition(0, 0)
     self.tableViewA:setDataSourceFunc(self, Jingjidialog5.tableViewGetCellAtIndexA)
   

     local sizeBgB = self.scrollRankB:getPixelSize()
     self.tableViewB = TableView.create( self.scrollRankB, TableView.VERTICAL)
     self.tableViewB:setViewSize(sizeBgB.width, sizeBgB.height)
     self.tableViewB:setPosition(0, 0)
     self.tableViewB:setDataSourceFunc(self, Jingjidialog5.tableViewGetCellAtIndexB)


    self.btnShowMyInfoOnly = CEGUI.toCheckbox(winMgr:getWindow("jingjichangdiglog5v5zhenying/xinxi/text/shaixuan")) 
	self.btnShowMyInfoOnly:subscribeEvent("CheckStateChanged", Jingjidialog5.clickShowMyInfoOnly, self)
   
   	self.richBox = CEGUI.toRichEditbox(winMgr:getWindow("jingjichangdiglog5v5zhenying/xinxi/text"))
    self.richBox:setReadOnly(true)
  
    self.btnShowInfo = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog5v5zhenying/tishi"))
    self.btnShowInfo:subscribeEvent("MouseClick", Jingjidialog5.clickShowInfo, self)

    self.btnRewardFirst = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog5v5zhenying/jiangli/shoushenglibao"))
    self.btnRewardFirst:setID(1)
    self.btnRewardFirst:subscribeEvent("MouseClick", Jingjidialog5.clickRewardFirst, self)
    
    self.btnRewardTenBattle = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog5v5zhenying/jiangli/wuzhanlibao"))
    self.btnRewardTenBattle:setID(2)
    self.btnRewardTenBattle:subscribeEvent("MouseClick", Jingjidialog5.clickRewardTenBattle, self)

    self.labelLeftTimeTitle = winMgr:getWindow("jingjichangdiglog5v5zhenying/huodongshijian/tishiyu")
    self.labelLeftTimeTitle:setVisible(false)

    self.winProgressBg = winMgr:getWindow("jingjichangdiglog5v5zhenying/time")
    self.progressBar = CEGUI.toProgressBar(winMgr:getWindow("jingjichangdiglog5v5zhenying/time/daojishi"))

    self.labelNoti = winMgr:getWindow("jingjichangdiglog5v5zhenying/time/wenzi") 
    self.labelNoti:setText("")

    self.iamgeClock = winMgr:getWindow("jingjichangdiglog5v5zhenying/time/icon")  
    self.iamgeClock:setVisible(false)

    self.iamgeCampANormal = winMgr:getWindow("jingjichangdiglog5v5zhenying/tubiao2")  
    self.iamgeCampASel = winMgr:getWindow("jingjichangdiglog5v5zhenying/tubiao") 
    self.iamgeCampBNormal = winMgr:getWindow("jingjichangdiglog5v5zhenying/tubiao11") 
    self.iamgeCampBSel = winMgr:getWindow("jingjichangdiglog5v5zhenying/tubiao1")

    self.m_share5v5 = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog5v5zhenying/fenxiang"))
    self.m_share5v5:subscribeEvent("Clicked", Jingjidialog5.HandleClickBtnShare, self)

    if MT3.ChannelManager:IsAndroid() == 1 then
        if Config.IsLocojoy() then
            self.m_share5v5:setVisible(true)
        else
            self.m_share5v5:setVisible(false)
        end
    end

    -- windows ∞Ê±æ∆¡±Œ∑÷œÌ
    if Config.IsWinApp() then
        self.m_share5v5:setVisible(false)
    end
    
    self:refreshRichBox()
    self:sendReqMyInfo()
    self:sendReqRank()

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    self.nStartTime,self.nEndTime = jjManager:getJingjiTimeStartEnd5()
    self.fRefreshLeftDt = 0
    self:GetWindow():subscribeEvent("WindowUpdate", Jingjidialog5.HandleWindowUpate, self)
    --self:refreshPiPeiBtn()

    --self:refreshProgress(0.5)
    self.progressBar:setVisible(false)
    
    local layoutNamegetSize = "jingjichangcell.layout"
    local strPrefix = "getsize"
	local nodeCell = winMgr:loadWindowLayout(layoutNamegetSize,strPrefix)
    self.nodeCellSize = nodeCell:getPixelSize() 
    winMgr:destroyWindow(nodeCell)
    
    local bBegin =  false
    local nCurTimeSecond = jjManager:getCurTimeSecond()
    if nCurTimeSecond < self.nStartTime then
        bBegin = false
    else
        bBegin = true
    end
    
    if bBegin== false then
    
        local strNotBegin =  require("utils.mhsdutils").get_resstring(11495)
        self.labelNoti:setText(strNotBegin)
        self.labelNoti:setVisible(true)
        self.progressBar:setVisible(false)
        self.iamgeClock:setVisible(false)
    else
        local Jingjimanager = require("logic.jingji.jingjimanager")

        --[[
        if jjManager.waitstarttime == -1 then
        else
            local nNowTime = gGetServerTime() /1000

            if nNowTime < jjManager.waitstarttime or jjManager.waitstarttime==-1 then
            elseif nNowTime -  jjManager.waitstarttime <  jjManager.nWaitAllTime then
                jjManager:startWait()
            elseif nNowTime -  jjManager.waitstarttime >=  jjManager.nWaitAllTime then
                self:showChatState()
            end
            
       end
       --]]
    end
    
end

function Jingjidialog5:showChatState()
    self:startRandomChat()
    self.labelNoti:setVisible(false)
    self.progressBar:setVisible(false)
    self.iamgeClock:setVisible(false)
end

function Jingjidialog5:HandleClickBtnShare(arg)
    require "logic.share.sharedlg".SetShareType(SHARE_TYPE_5V5)
    require "logic.share.sharedlg".SetShareFunc(SHARE_FUNC_CAPTURE)
    require "logic.share.sharedlg".getInstanceAndShow()
end

function Jingjidialog5:startRandomChat()
    local timerData = {}
    local  Schedulermanager = require("logic.task.schedulermanager")
    require("logic.task.schedulermanager").getInstance():getTimerDataInit(timerData)
	--//=======================================
	timerData.eType = Schedulermanager.eTimerType.repeatEver
	timerData.fDurTime = 1.5
	timerData.nRepeatCount = -1
    timerData.pTarget= self
    timerData.callback= Jingjidialog5.randomChat
	--//=======================================
	require("logic.task.schedulermanager").getInstance():addTimer(timerData)

end

function Jingjidialog5:randomChat()
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local strRandomChat = jjManager:getRandomChat5()
    self.labelNoti:setText(strRandomChat)
    self.labelNoti:setVisible(true)
    self.progressBar:setVisible(false)

    self.iamgeClock:setVisible(false)
end

function Jingjidialog5:stopRandomChat()
    require("logic.task.schedulermanager").getInstance():deleteTimerWithTargetAndCallBak(self,Jingjidialog5.randomChat)
    self.labelNoti:setText("")
end

function Jingjidialog5:setPipeizhong()
    local strLeftTime =  require("utils.mhsdutils").get_resstring(11466)
    self.labelNoti:setText(strLeftTime)
    self.progressBar:setVisible(false)
end

function Jingjidialog5:refreshPipei(fLeftSecond)

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local fPercent = fLeftSecond/jjManager.nWaitAllTime
    self:refreshProgress(fPercent)

    local nLeftSecond = math.floor(fLeftSecond)

    if nLeftSecond <= 0 then
        nLeftSecond = 0
        --return
    end

    local strLeftTime =  require("utils.mhsdutils").get_resstring(11467)
    local sb = StringBuilder.new()
    sb:Set("parameter1",tostring(nLeftSecond))
    strLeftTime = sb:GetString(strLeftTime)
    sb:delete()
    self.labelNoti:setText(strLeftTime)

    self.progressBar:setVisible(true)
    self.labelNoti:setVisible(true)
    self.iamgeClock:setVisible(true)
end

function Jingjidialog5:hideProgress()
    self.progressBar:setVisible(false)
    self.labelNoti:setVisible(false)
    self.iamgeClock:setVisible(false)
end

function Jingjidialog5:refreshRankMy()
    if self.myCellRole then
        self:clearMyCellRole()
    end
    local strPrefix = "myrankrole"
    local Jingjimanager = require("logic.jingji.jingjimanager")
    local jjManager = Jingjimanager.getInstance()
    if  Jingjimanager.eCampType.campA == jjManager.nCampType then
        self.myCellRole =  require("logic.jingji.jingjirolecell2").create(self.winMyRankA,strPrefix)
    else
        self.myCellRole =  require("logic.jingji.jingjirolecell2").create(self.winMyRankB,strPrefix)
    end
    self.myCellRole.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 1)))

    jjManager.myRankData5.strName = gGetDataManager():GetMainCharacterName()

    self:refreshRankRoleCell(jjManager.myRankData5,self.myCellRole)
    self:refreshScrollHeight(jjManager.nCampType) 

    self:refreshCampTitle()
    
end

function Jingjidialog5:refreshCampTitle()

     self.iamgeCampANormal:setVisible(true)
     self.iamgeCampASel:setVisible(false)
     self.iamgeCampBNormal:setVisible(true)
     self.iamgeCampBSel:setVisible(false)

    local Jingjimanager = require("logic.jingji.jingjimanager")
    local jjManager = Jingjimanager.getInstance()
    if  Jingjimanager.eCampType.campA == jjManager.nCampType then
        self.iamgeCampANormal:setVisible(false)
        self.iamgeCampASel:setVisible(true)
        self.iamgeCampBNormal:setVisible(true)
        self.iamgeCampBSel:setVisible(false)
    elseif Jingjimanager.eCampType.campB == jjManager.nCampType then
        self.iamgeCampANormal:setVisible(true)
        self.iamgeCampASel:setVisible(false)
        self.iamgeCampBNormal:setVisible(false)
        self.iamgeCampBSel:setVisible(true)
    end
end



function Jingjidialog5:createOneRoleRank(nodeParent,eRankType,nIndex)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local prefix = ""
    local callBackFun = nil
    local vCellRole = self.vCellRankA
    if Jingjidialog5.eRankType.rankA ==eRankType then
        prefix = "Jingjidialog5A"..nIndex
        callBackFun = Jingjidialog5.clickRankCellA
        vCellRole = self.vCellRankA
    else
        prefix = "Jingjidialog5B"..nIndex
        callBackFun = Jingjidialog5.clickRankCellB
        vCellRole = self.vCellRankB
    end
	local cellRole = require("logic.jingji.jingjirolecell2").create(nodeParent,prefix)
    cellRole.btnBg:subscribeEvent("MouseClick", callBackFun, self)
    vCellRole[nIndex] = cellRole
    return cellRole
end

function Jingjidialog5:getOneRoleData(eRankType,nIndex)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local oneRole = nil
    if Jingjidialog5.eRankType.rankA ==eRankType then
        oneRole =jjManager.vRankDataA[nIndex]
    else
        oneRole =jjManager.vRankDataB[nIndex]
    end
    return oneRole
end

function Jingjidialog5:refreshRankRoleCell(oneRole,cellRole)
    local nRank = oneRole.nRank
    local strName = oneRole.strName
    local nScore = oneRole.nScore
    local nSuccess = oneRole.nSuccess
    local nBattleNum = oneRole.nBattleNum

    local strMyRank =  tostring(nRank)
   if nRank == 0 then
        strMyRank =  require "utils.mhsdutils".get_resstring(11204) 
   end


    cellRole.labelNumber:setText(strMyRank)
    cellRole.labelRoleName:setText(strName)
    cellRole.labelScore:setText(tostring(nScore))
    local strSuccessPer = nSuccess.."/"..nBattleNum
    cellRole.labelSuccessNum:setText(strSuccessPer)
    cellRole.nRank = nRank
    cellRole.btnBg.nRank = nRank
    self:refreshColor(cellRole)
    self:refreshRankPic(nRank,cellRole)
end

function Jingjidialog5:tableViewGetCellAtIndexA(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:createOneRoleRank(tableView.container, Jingjidialog5.eRankType.rankA,nIndex )
    end
    if idx % 2 == 1 then
        cell.btnBg:SetStateImageExtendID(1)
    else
        cell.btnBg:SetStateImageExtendID(0)
    end
    local oneRole = self:getOneRoleData(Jingjidialog5.eRankType.rankA,nIndex)
    self:refreshRankRoleCell(oneRole,cell)
    return cell
end

function Jingjidialog5:tableViewGetCellAtIndexB(tableView, idx, cell) --0--count-1
     local nIndex = idx +1
    if not cell then
        cell = self:createOneRoleRank(tableView.container, Jingjidialog5.eRankType.rankB,nIndex )
    end
    local oneRole = self:getOneRoleData(Jingjidialog5.eRankType.rankB,nIndex)
    if idx % 2 == 1 then
        cell.btnBg:SetStateImageExtendID(1)
    else
        cell.btnBg:SetStateImageExtendID(0)
    end

    self:refreshRankRoleCell(oneRole,cell)
    return cell
end

function Jingjidialog5:refreshProgress(fPercent)
     self.progressBar:setProgress(fPercent)
end


function Jingjidialog5:refreshRankA()
   
   local jjManager = require("logic.jingji.jingjimanager").getInstance()
   local nRankNumA = #jjManager.vRankDataA
    self.tableViewA:destroyCells()
    self.tableViewA:setCellCountAndSize(nRankNumA, self.nodeCellSize.width, self.nodeCellSize.height)
    self.tableViewA:reloadData()
end

function Jingjidialog5:refreshScrollHeight(nCampType)
    local Jingjimanager = require("logic.jingji.jingjimanager")
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local nWidthScroll = self.scrollRankA:getPixelSize().width 
    local nHeightScrollNew = self.nHeightScrollOld - self.nHeightMyCell

    self.tableViewA:setViewSize(nWidthScroll,self.nHeightScrollOld)
    self.tableViewB:setViewSize(nWidthScroll,self.nHeightScrollOld)
    self.winMyRankA:setVisible(false)
    self.winMyRankB:setVisible(false)

    if  Jingjimanager.eCampType.campA == nCampType then
        --self.scrollRankA:setSize(CEGUI.UVector2(CEGUI.UDim(0,nWidthScroll), CEGUI.UDim(0,nHeightScrollNew)))
        self.tableViewA:setViewSize(nWidthScroll,nHeightScrollNew)
        self.winMyRankA:setVisible(true)
        self.winMyRankB:setVisible(false)
    elseif Jingjimanager.eCampType.campB == nCampType then
        --self.scrollRankB:setSize(CEGUI.UVector2(CEGUI.UDim(0,nWidthScroll), CEGUI.UDim(0,nHeightScrollNew)))
        self.tableViewB:setViewSize(nWidthScroll, nHeightScrollNew)
        self.winMyRankA:setVisible(false)
        self.winMyRankB:setVisible(true)
    end
end

function Jingjidialog5:clickRankCellA(args)
    local e = CEGUI.toWindowEventArgs(args)
	local clickWin = e.window
    self.nCurSelCellIdA = clickWin.nRank
    self:refreshRoleCellSelA()
end

function Jingjidialog5:clickRankCellB(args)
    local e = CEGUI.toWindowEventArgs(args)
	local clickWin = e.window
    self.nCurSelCellIdB = clickWin.nRank
    self:refreshRoleCellSelB()
end


function Jingjidialog5:getTextColor(nRank)
    local strColor = nil
    if nRank == 1 then
        strColor = "FF8C5E2A"
    elseif nRank == 2 then
        strColor = "FF8C5E2A"
    elseif nRank == 3 then
        strColor = "FF8C5E2A"
    end
    return strColor

end
function Jingjidialog5:refreshColor(cellRole)
    local nRank = cellRole.nRank
    if nRank > 3 then
        return
    end
    local strColor = self:getTextColor(nRank)
    if not strColor then
        return
    end
    self:labelToColor(cellRole.labelRoleName,strColor)
    self:labelToColor(cellRole.labelScore,strColor)
    self:labelToColor(cellRole.labelSuccessNum,strColor)

end
function Jingjidialog5:labelToColor(label,strColor)
    local strTitle = label:getText()
    local strNewName = "[colour=".."\'"..strColor.."\'".."]"..strTitle
    label:setText(strNewName)
end

function Jingjidialog5:refreshRankB()
    
   local jjManager = require("logic.jingji.jingjimanager").getInstance()
   local nRankNumB = #jjManager.vRankDataB
    self.tableViewB:destroyCells()
    self.tableViewB:setCellCountAndSize(nRankNumB, self.nodeCellSize.width, self.nodeCellSize.height)
    self.tableViewB:reloadData()
end

function Jingjidialog5:refreshRankPic(nRank,cellRole)

    if nRank == 1 then
			cellRole.imageIconNumber:setProperty("Image","set:ccpkc image:no1");
			--cellRole.labelNumber:setText("")
	elseif nRank == 2 then
			cellRole.imageIconNumber:setProperty("Image","set:ccpkc image:no2");
            --cellRole.labelNumber:setText("")
	elseif nRank == 3 then
			cellRole.imageIconNumber:setProperty("Image","set:ccpkc image:no3");
			--cellRole.labelNumber:setText("")
    else
          cellRole.imageIconNumber:setProperty("Image","");
    end	
end

function Jingjidialog5:sendReqMyInfo()
    local p = require "protodef.fire.pb.battle.pvp5.cpvp5myinfo":new()
	require "manager.luaprotocolmanager":send(p)
end

function Jingjidialog5:sendReqRank()
    local p = require "protodef.fire.pb.battle.pvp5.cpvp5rankinglist":new()
	require "manager.luaprotocolmanager":send(p)
end


function Jingjidialog5:HandleWindowUpate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    local fdt = ue.d_timeSinceLastFrame  
    self.fRefreshLeftDt = self.fRefreshLeftDt + fdt
    if self.fRefreshLeftDt >= 1.0 then
        self:refreshLeftTime()
        self.fRefreshLeftDt = 0
    end
end

function Jingjidialog5:refreshLeftTime()
    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    local nCurTimeSecond = jjManager:getCurTimeSecond()
    local nStartTime = self.nStartTime
    local nEndTime = self.nEndTime

	self.labelLeftTimeTitle:setVisible(true)

    if nCurTimeSecond < nStartTime then
        local nLeft = nStartTime - nCurTimeSecond
        local strLedt = require ("utils.mhsdutils").GetTimeHMSString(nLeft)
        self.labelLeftTime:setText(strLedt)

          local strkaiqishengyu = require "utils.mhsdutils".get_resstring(11390) 
        self.labelLeftTimeTitle:setText(strkaiqishengyu)

    elseif nCurTimeSecond >= nStartTime and nCurTimeSecond <= nEndTime then
        local nLeft = nEndTime - nCurTimeSecond
         local strLeft = require ("utils.mhsdutils").GetTimeHMSString(nLeft)
        self.labelLeftTime:setText(strLeft)
        
          local strkaiqishengyu = require "utils.mhsdutils".get_resstring(11389) 
        self.labelLeftTimeTitle:setText(strkaiqishengyu)

    elseif nCurTimeSecond > nEndTime then
        self.labelLeftTime:setText("00:00")
         local strkaiqishengyu = require "utils.mhsdutils".get_resstring(11389) 
        self.labelLeftTimeTitle:setText(strkaiqishengyu)
    end
end

function Jingjidialog5:refreshRoleCellSelA()
    for k,v in pairs(self.vCellRankA) do
        if v.nRank == self.nCurSelCellIdA then
            v.btnBg:setSelected(true)
        else
            v.btnBg:setSelected(false)
        end
    end
end

function Jingjidialog5:refreshRoleCellSelB()
    for k,v in pairs(self.vCellRankB) do
        if v.nRank == self.nCurSelCellIdB then
            v.btnBg:setSelected(true)
        else
            v.btnBg:setSelected(false)
        end
    end
end

function Jingjidialog5:addBattleInfo5(oneData)

    if not oneData then
        return
    end
    local bShowMine = self.btnShowMyInfoOnly:isSelected()

    local nMsgId = oneData.msgid
    local strText = require "utils.mhsdutils".get_msgtipstring(nMsgId)
    if strText then
           if bShowMine==true then
                if oneData.ismine==1 then
                    self:appendText(strText,oneData.vParam)
                end
           else
                self:appendText(strText,oneData.vParam)
           end
    end
    --self.richBox:HandleEnd() --HandleTop
end

function Jingjidialog5:refreshRichBox()

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local bShowMine = self.btnShowMyInfoOnly:isSelected()
    local vBattleRecord5 =  jjManager.vBattleRecord5
    
    self.richBox:Clear()
    local nMaxNum = #vBattleRecord5
    for nIndex = 1,nMaxNum do
        --local nIndexRevert = nMaxNum - nIndex +1
        local oneData = vBattleRecord5[nIndex]
        local nMsgId = oneData.msgid
        local strText = require "utils.mhsdutils".get_msgtipstring(nMsgId)
        if strText then
           if bShowMine==true then
                if oneData.ismine==1 then
                    self:appendText(strText,oneData.vParam)
                end
           else
                self:appendText(strText,oneData.vParam)
           end
        end
    end
 
	self.richBox:Refresh()
    --self.richBox:HandleEnd()
end

function Jingjidialog5:appendText(strText,vParam)
    if not strText then
        return
    end
    local strEnd = strText
    for nIndexParam = 1,#vParam do
          local sb = StringBuilder.new()
          local strParam = "parameter"..tostring(nIndexParam)
          local strResult = vParam[nIndexParam]
          sb:Set(strParam,strResult)
          strEnd = sb:GetString(strEnd)
          sb:delete()
    end
    strEnd = CEGUI.String(strEnd)
    self.richBox:AppendParseText(strEnd)
    self.richBox:AppendBreak()      
end

--refresh reward box state
function Jingjidialog5:refreshBoxState()
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local nFirstSuccessState = jjManager.nFirstSuccess5State
    local nTenBattleState = jjManager.nTenBattle5State

   self:refreshBox(self.btnRewardFirst,nFirstSuccessState)
   self:refreshBox(self.btnRewardTenBattle,nTenBattleState)
end

function Jingjidialog5:refreshBox(box,nBoxState)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    if gGetGameUIManager() then
       gGetGameUIManager():RemoveUIEffect(box)
    end
    

    local id = box:getID()
    if nBoxState == 0 then
        
        box:setEnabled(true)
    elseif nBoxState == 1 then
       
        box:setEnabled(true)
        jjManager:addCircleEffect(box)
    elseif nBoxState == 2 then
        box:setEnabled(false)
       
    end
end

function Jingjidialog5:resetTeamInfo()
    for nIndexPlayer=1,#self.vItemCellHero do 
         local oneHero = self.vItemCellHero[nIndexPlayer]
         oneHero.itemcellIcon:SetImage(nil)
         oneHero.labelName:setText("")
         oneHero.labelLv:setText("")
         oneHero.labelJob:setText("")
    end
end

function Jingjidialog5:refreshCell(nIndexCell,nLevelId,nShapeId,strName,nJob)
    if nIndexCell > #self.vItemCellHero then
        return
    end
    local oneHero = self.vItemCellHero[nIndexCell]

    local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nShapeId)
    if shapeTable then
        local image = GetIconManager():GetImageByID(shapeTable.littleheadID)
          oneHero.itemcellIcon:SetImage(image)
    end
        local schoolTable=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(nJob)
    if schoolTable then
         oneHero.labelJob:setText(schoolTable.name)
    end

    local strLvzi = require "utils.mhsdutils".get_resstring(11330) 

    local strLv = strLvzi.. tostring(nLevelId)
    oneHero.labelName:setText(strName)
    oneHero.labelLv:setText(strLv)

    if oneHero.btnAdd then
        oneHero.btnAdd:setVisible(false)
    end
    
end

function Jingjidialog5:refreshBattleInfo()
   local jjManager = require("logic.jingji.jingjimanager").getInstance()

    local nBattleNum =  jjManager.nBattleNum
    local nSuccessNum =  jjManager.nSuccessNum
    local nContinueNum =  jjManager.nContinueNum

    self.labelBattleNum:setText(tostring(nBattleNum))
    self.labelBattleSuccessNum:setText(tostring(nSuccessNum))
    self.labelContinueSuccessNum:setText(tostring(nContinueNum))
end


function Jingjidialog5:clickShowInfo(arg)
    local tip = TextTip.CreateNewDlg()
	local str = require "utils.mhsdutils".get_msgtipstring(190025)
	tip:setTipText(str)
end

function Jingjidialog5:refreshReady(nReady)
--[[
    if nReady==1 then
        --11351    --11337 begin pipei
        local strPipeizhongzi = require ("utils.mhsdutils").get_resstring(11351) 
        self.labelBegin:setText(strPipeizhongzi)
    else
        local strKaishipipeizi = require ("utils.mhsdutils").get_resstring(11337) 
        self.labelBegin:setText(strKaishipipeizi)
    end--]]
end

function Jingjidialog5:sendReady(nReady)
     
end

function Jingjidialog5:clickBeginPipei(arg)

end

function Jingjidialog5:refreshPiPeiBtn() 
end

function Jingjidialog5:clickRewardFirst(arg)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    if jjManager.nFirstSuccess5State==0 then
         local strBuilder = StringBuilder:new()
        strBuilder:Set("parameter1", MHSD_UTILS.get_resstring(11342))
        GetCTipsManager():AddMessageTip(strBuilder:GetString(MHSD_UTILS.get_msgtipstring(160342)))
        strBuilder:delete()
        return
    end
     if jjManager.nFirstSuccess5State==2 then
        return
    end
     local p = require "protodef.fire.pb.battle.pvp5.cpvp5openbox":new()
     p.boxtype = 1
     require "manager.luaprotocolmanager":send(p)
end

function Jingjidialog5:clickRewardTenBattle(arg)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    if jjManager.nTenBattle5State==0 then
        local strBuilder = StringBuilder:new()
        strBuilder:Set("parameter1", MHSD_UTILS.get_resstring(11345))
        GetCTipsManager():AddMessageTip(strBuilder:GetString(MHSD_UTILS.get_msgtipstring(160342)))
        strBuilder:delete()
        return
    end
    if jjManager.nTenBattle5State==2 then
        return
    end
    local p = require "protodef.fire.pb.battle.pvp5.cpvp5openbox":new()
    p.boxtype = 2
    require "manager.luaprotocolmanager":send(p)     
end


function Jingjidialog5:clickShowMyInfoOnly(arg)
    self:refreshRichBox()
end


--//=========================================
function Jingjidialog5.getInstance()
    if not _instance then
        _instance = Jingjidialog5:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jingjidialog5.getInstanceAndShow()
    if not _instance then
        _instance = Jingjidialog5:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingjidialog5.getInstanceNotCreate()
    return _instance
end

function Jingjidialog5.getInstanceOrNot()
	return _instance
end
	
function Jingjidialog5.GetLayoutFileName()
    return "jingjichangdiglog5v5zhenying.layout"
end

function Jingjidialog5:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingjidialog5)
	self:ClearData()
    return self
end

function Jingjidialog5.DestroyDialog()
	if not _instance then
		return
	end
	if not _instance.m_bCloseIsHide then
		_instance:OnClose()
		_instance = nil
	else
		_instance:ToggleOpenClose()
	end
end

function Jingjidialog5:ClearData()
	self.nItemCellSelIdA = 0
    self.nItemCellSelIdB = 0
    self.fRefreshLeftDt = 0

    self.vCellRankA = {}
    self.vCellRankB = {}

    self.nCurSelCellIdA = 0
    self.nCurSelCellIdB = 0

    self.myCellRole = nil
    
end

function Jingjidialog5:clearMyCellRole()
    if not self.myCellRole then
        return
    end
    self.myCellRole:OnClose()
    self.myCellRole = nil
end



function Jingjidialog5:OnClose()
   require("logic.task.schedulermanager").getInstance():deleteTimerWithTarget(self)

   if self.tableViewA then
       self.tableViewA:destroyCells()
   end
   if self.tableViewB then
      self.tableViewB:destroyCells()
   end
   self:clearMyCellRole()

    Dialog.OnClose(self)
	self:ClearData()
	_instance = nil
end

return Jingjidialog5

require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

Jingjidialog = {}
setmetatable(Jingjidialog, Dialog)
Jingjidialog.__index = Jingjidialog
local _instance;

--//===============================
function Jingjidialog:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.labelTitle = winMgr:getWindow("jingjichangdiglog/diban/text") 
    self.imageGroupIcon = winMgr:getWindow("jingjichangdiglog/icon") --jingjichangdiglog/icon
	self.scrollRole = CEGUI.toScrollablePane(winMgr:getWindow("jingjichangdiglog/paihangbang/gundong"))

    self.nodeMyBg = CEGUI.toScrollablePane(winMgr:getWindow("jingjichangdiglog/paihangbang/diban/mypaihang")) 

	--self.scrollRole:setMousePassThroughEnabled(true)
    
    for nIndex=1,5 do
        local strPanelName = "jingjichangdiglog/hero"..nIndex
        local itemCellHero = CEGUI.toItemCell(winMgr:getWindow(strPanelName))
        itemCellHero:SetStyle(CEGUI.ItemCellStyle_IconExtend)
        self.vItemCellHero[nIndex] = itemCellHero
    end
    self.btnChangeHero = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog/zhenrong/tiaozheng"))
    self.btnChangeHero:subscribeEvent("MouseButtonUp", Jingjidialog.clickChangeHero, self)

    self.labelLeftTime = winMgr:getWindow("jingjichangdiglog/huodongshijian/time") --19:09

    self.btnShowMyInfoOnly = CEGUI.toCheckbox(winMgr:getWindow("jingjichangdiglog/xinxi/text/shaixuan"))
	self.btnShowMyInfoOnly:subscribeEvent("CheckStateChanged", Jingjidialog.clickShowMyInfoOnly, self)

    self.richBox = CEGUI.toRichEditbox(winMgr:getWindow("jingjichangdiglog/xinxi/text"))
    self.richBox:setReadOnly(true)

    self.btnRewardFirst = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog/jiangli/shoushenglibao"))
    self.btnRewardFirst:subscribeEvent("MouseButtonUp", Jingjidialog.clickRewardFirst, self)

    self.btnRewardFive = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog/jiangli/wuzhanlibao"))
    self.btnRewardFive:subscribeEvent("MouseButtonUp", Jingjidialog.clickRewardFive, self)

    self.btnBeginPipei = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog/pipei"))
    self.btnBeginPipei:subscribeEvent("MouseButtonUp", Jingjidialog.clickBeginPipei, self)
    self.btnBeginPipei:setRiseOnClickEnabled(false)

    self.labelBegin  = winMgr:getWindow("jingjichangdiglog/tiaozhan")
    self.imageWait = winMgr:getWindow("jingjichangdiglog/pi1") 
     self:refreshReady(0)

    self.labelLeftTimeTitle = winMgr:getWindow("jingjichangdiglog/huodongshijian/tishiyu")
    self.labelLeftTimeTitle:setVisible(false)
   
    self.imageInfo = winMgr:getWindow("jingjichangdiglog/shuoming")
	--self.imageInfo:subscribeEvent("MouseClick", Jingjidialog.clickShowInfo, self)
    
    --self:RefreshUI()
    self:sendReqRank()
    self:sendReqMyBattleInfo()

    --self:resetHero()
    self:refreshHero()

    self:refreshRichBox()
    self:refreshTitleName()

    self.fRefreshLeftDt = 0
    self:GetWindow():subscribeEvent("WindowUpdate", Jingjidialog.HandleWindowUpate, self)

    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    self.nStartTime,self.nEndTime = jjManager:getJingjiTimeStartEnd()

    
    local nSpaceX = 0
    self.aniDlg = require("logic.jingji.jingjipipeianidialog").create(self.imageWait,nSpaceX)

    self:refreshMyHeroDelay()

end

function Jingjidialog:refreshMyHeroDelay()
    local timerData = {}
    require("logic.task.schedulermanager").getInstance():getTimerDataInit(timerData)
    local  Schedulermanager = require("logic.task.schedulermanager")
	--//=======================================
	timerData.eType = Schedulermanager.eTimerType.repeatCount
	timerData.fDurTime = 1.0
	timerData.nRepeatCount = 1
	--timerData.nParam1 = nTaskTypeId
    timerData.pTarget = self
    timerData.callback= Jingjidialog.timerCallBack_refreshMyHero
	--//=======================================
	require("logic.task.schedulermanager").getInstance():addTimer(timerData)
end

function Jingjidialog:timerCallBack_refreshMyHero()
    require("logic.task.schedulermanager").getInstance():deleteTimerWithTargetAndCallBak(self,Jingjidialog.timerCallBack_refreshMyHero)
    self:refreshHero()
end

function Jingjidialog:refreshLeftTime()
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

function Jingjidialog:refreshPiPeiBtn()
end

function Jingjidialog:HandleWindowUpate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    local fdt = ue.d_timeSinceLastFrame  --秒
    self.fRefreshLeftDt = self.fRefreshLeftDt + fdt
    if self.fRefreshLeftDt >= 1.0 then
        self:refreshLeftTime()
        self.fRefreshLeftDt = 0
    end
end

function Jingjidialog:sendReqRank()
    local p = require "protodef.fire.pb.battle.pvp1.cpvp1rankinglist":new()
	require "manager.luaprotocolmanager":send(p)
    
end

function Jingjidialog:sendReqMyBattleInfo()
    local p = require "protodef.fire.pb.battle.pvp1.cpvp1myinfo":new()
	require "manager.luaprotocolmanager":send(p)

end

function Jingjidialog:sendReqRewardBoxState()

end


function Jingjidialog:clickShowInfo(arg)
    local tip = TextTip.CreateNewDlg()
	local str = require "utils.mhsdutils".get_msgtipstring(150507)
	tip:setTipText(str)
end


function Jingjidialog:addBattleInfo1(oneData)
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
	self.richBox:Refresh()

end

function Jingjidialog:refreshRichBox()

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local bShowMine = self.btnShowMyInfoOnly:isSelected()

    local vBattleRecord =  jjManager.vBattleRecord
    
    self.richBox:Clear()
    local nMaxNum = #vBattleRecord
    for nIndex = 1,nMaxNum do
       -- local nIndexRevert = nMaxNum - nIndex +1
        local oneData = vBattleRecord[nIndex]
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
    --self.richBox:HandleTop()

end

function Jingjidialog:appendText(strText,vParam)
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


function Jingjidialog:receiveServerReady(ready)

end


function Jingjidialog:isHaveType(vAllJobTypeId,nType)
    for k,v in pairs(vAllJobTypeId) do
        if v==nType then
            return true
        end
    end
    return false
end

-- <= 3
--[[
1=物理输出
2=法术输出
3=治疗
4=辅助
5=控制
--]]
function Jingjidialog:isHaveJobOverMax()
    local nMaxNum = 3

    local nJob = gGetDataManager():GetMainCharacterSchoolID()
    -------------------------------------------------------
    local vAllJobTypeId = {}
    vAllJobTypeId[1] = 3
    vAllJobTypeId[2] = 4
    vAllJobTypeId[3] = 5
   
    ---------------------------------------------------------
    --11333
    for nIndex=1,#vAllJobTypeId do
        local nJobType = vAllJobTypeId[nIndex]
        local bOver = self:isOneJobTypeOver(nJobType)
        if bOver==true then
            return true
        end
    end
    return false

end

function Jingjidialog:isOneJobTypeOver(nJobType)

    local nHaveNum = 0
    local nMaxNum = 3
    local nMyJob = gGetDataManager():GetMainCharacterSchoolID()
    local schoolTable =  BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(nMyJob) 
    local nMyType = schoolTable.jobtype

    if nMyType==nJobType then
        nHaveNum = nHaveNum +1
    end

    local nCurGroup = MT3HeroManager.getInstance():getActiveGroupId()
    local vcMember = MT3HeroManager.getInstance():getGroupMember(nCurGroup)
    for nIndex=0,vcMember:size()-1 do
        local nHeroId = vcMember[nIndex]
	    local heroTable = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(nHeroId)
        if heroTable then
            if nJobType==heroTable.type then
                nHaveNum = nHaveNum +1
            end
        end
    end
    if nHaveNum > nMaxNum then
        return true
    end
    return false
end

function Jingjidialog:refreshReady(nReady)

    if nReady==1 then
       

        self.labelBegin:setVisible(false)
        self.imageWait:setVisible(true)
    else
      
        self.labelBegin:setVisible(true)
        self.imageWait:setVisible(false)
    end
end

function Jingjidialog:clickBeginPipei(arg)
    
    local bOver = self:isHaveJobOverMax()
    if bOver then
        local strShowTip = require("utils.mhsdutils").get_msgtipstring(160333) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return
    end
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    if jjManager.nPiPei1==1 then
        require("logic.jingji.jingjipipeidialog").getInstanceAndShow()
    else
        local p = require "protodef.fire.pb.battle.pvp1.cpvp1readyfight":new()
        p.ready = 1
	    require "manager.luaprotocolmanager":send(p)
    end
end

function Jingjidialog:clickChangeHero(arg)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    if jjManager.nPiPei1 == 1 then
        local strShowTip = require "utils.mhsdutils".get_msgtipstring(160497)  
		GetCTipsManager():AddMessageTip(strShowTip)
        return
    end

    require "logic.team.huobanzhuzhandialog".getInstanceAndShow()
end

function Jingjidialog:clickRewardFirst(arg)
    -- <variable name="state" type="byte"/> 0：不可领取，1：可领取，2：已领取
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local nFirstState = jjManager.firstwin
    if nFirstState == 0 then
        local strBuilder = StringBuilder:new()
        strBuilder:Set("parameter1", require("utils.mhsdutils").get_resstring(11342)) 
        GetCTipsManager():AddMessageTip(strBuilder:GetString(MHSD_UTILS.get_msgtipstring(160342)))
        strBuilder:delete()
        return
    end

    if nFirstState == 2 then
        return
    end


    local p = require "protodef.fire.pb.battle.pvp1.cpvp1openbox":new()
    p.boxtype =1
	require "manager.luaprotocolmanager":send(p)


end

function Jingjidialog:clickRewardFive(arg)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
   -- <variable name="state" type="byte"/> 0：不可领取，1：可领取，2：已领取
    local nFiveBattleState = jjManager.tenfight
    if nFiveBattleState == 0 then
        local strBuilder = StringBuilder:new()
        strBuilder:Set("parameter1", require("utils.mhsdutils").get_resstring(11345))
        GetCTipsManager():AddMessageTip(strBuilder:GetString(MHSD_UTILS.get_msgtipstring(160342)))
        strBuilder:delete()
        return
    end

    if nFiveBattleState == 2 then
        return
    end

    local p = require "protodef.fire.pb.battle.pvp1.cpvp1openbox":new()
    p.boxtype =2
	require "manager.luaprotocolmanager":send(p)
end

function Jingjidialog:clickShowMyInfoOnly(arg)
     self:refreshRichBox()
end


function Jingjidialog:refreshTitleName()
    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    local strTiteName,strImagePath = jjManager:getGroupName()
    if not strTiteName then
        return
    end
    self.labelTitle:setText(strTiteName)
    self.imageGroupIcon:setProperty("Image",strImagePath)

end



function Jingjidialog:getTextColor(nRank)
    local strColor = nil
    if nRank == 1 then
        strColor = "FF693F00"
    elseif nRank == 2 then
        strColor = "FF693F00"
    elseif nRank == 3 then
        strColor = "FF693F00"
    end
    return strColor
end

function Jingjidialog:refreshColor(cellRole)
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

function Jingjidialog:labelToColor(label,strColor)
    local strTitle = label:getText()
    local strNewName = "[colour=".."\'"..strColor.."\'".."]"..strTitle
    label:setText(strNewName)
end

function Jingjidialog:refreshScrollRole()
   self:ClearCellAll()
   local jjManager = require("logic.jingji.jingjimanager").getInstance()
   for nIndex=1,#jjManager.vRoleData do
        local oneRole = jjManager.vRoleData[nIndex]
        local nRank = oneRole.nRank
        local strName = oneRole.strName
        local nScore = oneRole.nScore
        local nSuccess = oneRole.nSuccess
        local nBattleNum = oneRole.nBattleNum
        -----------------------------------------

        local prefix = "Jingjidialog"..nIndex
		local cellRole = require("logic.jingji.jingjirolecell").new(self.scrollRole, nIndex - 1,prefix)


        cellRole.labelNumber:setText(tostring(nRank))
        cellRole.labelRoleName:setText(strName)
        cellRole.labelScore:setText(tostring(nScore))
        local strSuccessPer = nSuccess.."/"..nBattleNum
        cellRole.labelSuccessNum:setText(strSuccessPer)
        cellRole.nRank = nRank
        self.vCellRole[#self.vCellRole + 1] = cellRole
        if nIndex % 2 == 1 then
            cellRole.btnBg:SetStateImageExtendID(1)
        else
            cellRole.btnBg:SetStateImageExtendID(0)
        end
        cellRole.btnBg.nRank = nRank
        cellRole.btnBg:subscribeEvent("MouseButtonUp",Jingjidialog.clicRoleCell, self)
        self:refreshColor(cellRole)

        if nRank == 1 then
			cellRole.imageIconNumber:setProperty("Image","set:ccpkc image:no1");
			cellRole.labelNumber:setText("")
            --equipCell.imageStone1:setProperty("Image",strIconPath )
		elseif nRank == 2 then
			cellRole.imageIconNumber:setProperty("Image","set:ccpkc image:no2");
            cellRole.labelNumber:setText("")
		elseif nRank == 3 then
			cellRole.imageIconNumber:setProperty("Image","set:ccpkc image:no3");
			cellRole.labelNumber:setText("")
		else
          cellRole.imageIconNumber:setProperty("Image","");
    end	


   end
end

function Jingjidialog:refreshMyRankData()
   local jjManager = require("logic.jingji.jingjimanager").getInstance()

   if self.cellRoleMy then
        self.cellRoleMy:DestroyDialog()
   end

   local myData = jjManager.myData

   if myData.nRank == nil then
    jjManager:resetMyData1v1()
   end

   local nIndex = 1
   local prefix = "Jingjidialogmy"..nIndex
   self.cellRoleMy = require("logic.jingji.jingjirolecell").new(self.nodeMyBg, nIndex - 1,prefix)

   local strMyRank =  tostring(myData.nRank)
   if myData.nRank == 0 then
        strMyRank =  require "utils.mhsdutils".get_resstring(11204) 
   end
   self.cellRoleMy.labelNumber:setText(strMyRank)
   self.cellRoleMy.labelRoleName:setText(myData.strName)
   self.cellRoleMy.labelScore:setText(tostring(myData.nScore))
   local strSuccessPer = tostring(myData.nSuccess).."/"..tostring(myData.nBattleNum)
   self.cellRoleMy.labelSuccessNum:setText(strSuccessPer)
    
   self.cellRoleMy.btnBg:setSelected(true)

   
end

function Jingjidialog:refreshBoxState()
    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    local firstState = jjManager.firstwin
    local fiveBattleState = jjManager.tenfight

   -- <variable name="state" type="byte"/> 0：不可领取，1：可领取，2：已领取
   
   self:refreshBox(self.btnRewardFirst,firstState)
   self:refreshBox(self.btnRewardFive,fiveBattleState)
end

function Jingjidialog:refreshBox(box,nBoxState)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
     if gGetGameUIManager() then
       gGetGameUIManager():RemoveUIEffect(box)
    end
    if nBoxState == 0 then
        box:setEnabled(true)
    elseif nBoxState == 1 then
        box:setEnabled(true)
        jjManager:addCircleEffect(box)
    elseif nBoxState == 2 then
        box:setEnabled(false)
    end
end


function Jingjidialog:clicRoleCell(args)
    local e = CEGUI.toWindowEventArgs(args)
	local clickWin = e.window
    self.nCurSelCellId = clickWin.nRank
    self:refreshRoleCellSel()
end

function Jingjidialog:refreshRoleCellSel()
    for k,v in pairs(self.vCellRole) do
        if v.nRank == self.nCurSelCellId then
            v.btnBg:setSelected(true)
        else
            v.btnBg:setSelected(false)
        end
    end
end


function Jingjidialog:getItemCellWithIndex(nIndex)
    if nIndex > #self.vItemCellHero then
        return nil
    end
    local itemCell = self.vItemCellHero[nIndex]
    return itemCell
end

function Jingjidialog:resetHero()
    for nIndex =1, #self.vItemCellHero do
        local itemCell = self.vItemCellHero[nIndex]
        itemCell:SetImage(nil)
    end
end

function Jingjidialog:refreshHero()
     self:resetHero()

    local nItemCellIndex = 1
    local itemCell = self:getItemCellWithIndex(nItemCellIndex)

    if itemCell then
        local mainChrShape = gGetDataManager():GetMainCharacterShape()
        local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(mainChrShape)
        if shapeTable.id ~= -1 then
            local image = gGetIconManager():GetImageByID(shapeTable.littleheadID)
            itemCell:SetImage(image)
        end
    end
    --------------------------------------
    local nCurGroup = MT3HeroManager.getInstance():getActiveGroupId()
    local vcMember = MT3HeroManager.getInstance():getGroupMember(nCurGroup)
    for nIndex=0,vcMember:size()-1 do
        local nHeroId = vcMember[nIndex]
	    local heroTable = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(nHeroId)
        if heroTable then
            local image = gGetIconManager():GetImageByID(heroTable.headid)

            nItemCellIndex = nItemCellIndex +1
            itemCell = self:getItemCellWithIndex(nItemCellIndex)
            if itemCell then
                itemCell:SetImage(image)
            end
        end
    end
end

--//=========================================
function Jingjidialog.getInstance()
    if not _instance then
        _instance = Jingjidialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jingjidialog.getInstanceAndShow()
    if not _instance then
        _instance = Jingjidialog:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingjidialog.getInstanceNotCreate()
    return _instance
end

function Jingjidialog.getInstanceOrNot()
	return _instance
end
	
function Jingjidialog.GetLayoutFileName()
    return "jingjichangdiglog.layout"
end

function Jingjidialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingjidialog)
	self:resetData()
    return self
end

function Jingjidialog.DestroyDialog()
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

function Jingjidialog:resetData()
	self.vItemCellHero = {}
    self.vCellRole = {}
    self.nCurSelCellId = -1
end

function Jingjidialog:ClearDataInClose()
	self.vItemCellHero = nil
    self.vCellRole = nil
end

function Jingjidialog:ClearCellAll()
	for k, v in pairs(self.vCellRole) do
		v:DestroyDialog()
	end
	self.vCellRole = {}
    if self.cellRoleMy then
         self.cellRoleMy:DestroyDialog()
        self.cellRoleMy = nil
    end
end


function Jingjidialog:OnClose()
    require("logic.task.schedulermanager").getInstance():deleteTimerWithTargetAndCallBak(self,Jingjidialog.timerCallBack_refreshMyHero)
    if self.aniDlg then
        self.aniDlg:DestroyDialog()
    end

	self:ClearCellAll()
	Dialog.OnClose(self)
	self:ClearDataInClose()
	_instance = nil

    require("logic.jingji.jingjipipeidialog").DestroyDialog()
end

return Jingjidialog

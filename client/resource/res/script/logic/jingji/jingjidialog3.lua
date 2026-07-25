require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

Jingjidialog3 = {}
setmetatable(Jingjidialog3, Dialog)
Jingjidialog3.__index = Jingjidialog3
local _instance;

--//===============================
function Jingjidialog3:OnCreate()
if self.aniDlg then
        self.aniDlg:DestroyDialog()
    end
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.labelLeftTime = winMgr:getWindow("jingjichangdiglog3v3/huodongshijian/time") --19:09 jingjichangdiglog/huodongshijian/time
    self.btnShowMyInfoOnly = CEGUI.toCheckbox(winMgr:getWindow("jingjichangdiglog3v3/xinxi/text/shaixuan")) 
	self.btnShowMyInfoOnly:subscribeEvent("CheckStateChanged", Jingjidialog3.clickShowMyInfoOnly, self)
   
   	self.richBox = CEGUI.toRichEditbox(winMgr:getWindow("jingjichangdiglog3v3/xinxi/text"))

    self.richBox:setReadOnly(true)
   
    self.labelBattleNum = winMgr:getWindow("jingjichangdiglog3v3/shuju/diban/number") 
    self.labelBattleSuccessNum = winMgr:getWindow("jingjichangdiglog3v3/shuju/diban/number1") 
    self.labelContinueSuccessNum = winMgr:getWindow("jingjichangdiglog3v3/shuju/diban/number2") 

    self.btnScoreRank = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog3v3/paihangbang"))
    self.btnScoreRank:subscribeEvent("MouseButtonUp", Jingjidialog3.clickScoreRank, self)

    self.btnRewardFirst = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog3v3/jiangli/shoushenglibao"))
    self.btnRewardFirst:setID(1)
    self.btnRewardFirst:subscribeEvent("MouseButtonUp", Jingjidialog3.clickRewardFirst, self)
    
    self.btnRewardTenBattle = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog3v3/jiangli/shizhanlibao"))
    self.btnRewardTenBattle:setID(2)
    self.btnRewardTenBattle:subscribeEvent("MouseButtonUp", Jingjidialog3.clickRewardTenBattle, self)

    self.btnRewardEightSuccess = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog3v3/jiangli/wushenglibao"))
    self.btnRewardEightSuccess:setID(3)
    self.btnRewardEightSuccess:subscribeEvent("MouseButtonUp", Jingjidialog3.clickRewardEightSuccess, self)
    self.awardEnable = {}
	
	NotificationCenter.addObserver(Notifi_TeamListChange, Jingjidialog3.teamChange)
    
    for nIndex=1,3 do
        local strHeroPanelName = "jingjichangdiglog3v3/dikuang/hero"..nIndex
        self.vItemCellHero[nIndex] = {}
        self.vItemCellHero[nIndex].itemcellIcon =  CEGUI.toItemCell(winMgr:getWindow(strHeroPanelName.."/icon"))
        self.vItemCellHero[nIndex].labelName =  winMgr:getWindow(strHeroPanelName.."/name")
        self.vItemCellHero[nIndex].labelLv =  winMgr:getWindow(strHeroPanelName.."/lv")
        self.vItemCellHero[nIndex].labelJob =  winMgr:getWindow(strHeroPanelName.."/zhiye")
		self.vItemCellHero[nIndex].mode =  winMgr:getWindow(strHeroPanelName.."/mode")

        if nIndex ~= 1 then
            self.vItemCellHero[nIndex].btnAdd =  CEGUI.toPushButton(winMgr:getWindow(strHeroPanelName.."/icon/tianjia"))
            self.vItemCellHero[nIndex].btnAdd :subscribeEvent("MouseButtonUp", Jingjidialog3.clickAddPlayer, self)

        end
    end
    

    self.btnBeginPipei = CEGUI.toPushButton(winMgr:getWindow("jingjichangdiglog3v3/pipei"))
    self.btnBeginPipei:subscribeEvent("MouseButtonUp", Jingjidialog3.clickBeginPipei, self)
    self.btnBeginPipei:setRiseOnClickEnabled(false)

    self.labelLeftTimeTitle = winMgr:getWindow("jingjichangdiglog3v3/huodongshijian/tishiyu")
    self.labelLeftTimeTitle:setVisible(false)

    self.labelBegin  = winMgr:getWindow("jingjichangdiglog3v3/tiaozhan")
    self.imageWait = winMgr:getWindow("jingjichangdiglog3v3/pi1") 
    self:refreshReady(false)
    --self:refreshBattleInfo()
    --self:refreshTesmInfo()
    
    self:resetTeamInfo()
    self:refreshTeamInfo()
    self:refreshRichBox()
    
    NotificationCenter.addObserver(Notifi_TeamListChange, Jingjidialog3.teamChange)
    self:sendReqMyInfo()

    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    self.nStartTime,self.nEndTime = jjManager:getJingjiTimeStartEnd3()

    self.fRefreshLeftDt = 0
    self:GetWindow():subscribeEvent("WindowUpdate", Jingjidialog3.HandleWindowUpate, self)

    --self:refreshPiPeiBtn()

    
    local nSpaceX = 0
    self.aniDlg = require("logic.jingji.jingjipipeianidialog").create(self.imageWait,nSpaceX)
	self:refreshTeamInfo()
end

function Jingjidialog3:sendReqMyInfo()
    local p = require "protodef.fire.pb.battle.pvp3.cpvp3myinfo":new()
	require "manager.luaprotocolmanager":send(p)
end


function Jingjidialog3.teamChange()
    if not _instance then
        return
    end
    _instance:resetTeamInfo()
    _instance:refreshTeamInfo()   --  队伍信息变化时刷新
end

function Jingjidialog3.clickAddPlayer()
    if not GetTeamManager() then
        return
    end

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    if jjManager.nPiPei3 == 1 then
        local strShowTip = require "utils.mhsdutils".get_msgtipstring(160497)  
		GetCTipsManager():AddMessageTip(strShowTip)
        return
    end

	local nParam =  21----×é¶Ó½çÃæ´ò¿ªÄ³¸öÀàÐÍµÄ±ã½Ý×é¶Ó 3V3¾º¼¼³¡

    if GetTeamManager():IsOnTeam() == false then
        local teamdlg = require('logic.team.teammatchdlg').getInstanceAndShow()
		if teamdlg then
			teamdlg:selecteActById(nParam)
		end
    else
        if GetTeamManager():IsMyselfLeader() then
            local teamdlg = require("logic.team.teamsettingdlg").getInstance()
            if teamdlg then
                print("aaaaaaaaa")
                teamdlg:selecteActById(nParam) -- 3v3
            end
        end
    end
end

function Jingjidialog3:HandleWindowUpate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    local fdt = ue.d_timeSinceLastFrame  --Ãë
    self.fRefreshLeftDt = self.fRefreshLeftDt + fdt
    if self.fRefreshLeftDt >= 1.0 then
        self:refreshLeftTime()
        self.fRefreshLeftDt = 0
    end
end

function Jingjidialog3:refreshLeftTime()
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

function Jingjidialog3:addBattleInfo3(oneData)
    if not oneData then
        return
    end

    
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
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
    --self.richBox:HandleTop()

end


function Jingjidialog3:refreshRichBox()

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    local bShowMine = self.btnShowMyInfoOnly:isSelected()
    local vBattleRecord3 =  jjManager.vBattleRecord3
    
    self.richBox:Clear()
    local nMaxNum = #vBattleRecord3
    for nIndex = 1,nMaxNum do
        --local nIndexRevert = nMaxNum - nIndex +1
        local oneData = vBattleRecord3[nIndex]
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

function Jingjidialog3:appendText(strText,vParam)
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
function Jingjidialog3:refreshBoxState()
    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    local nFirstSuccessState = jjManager.nFirstSuccessState
    local nTenBattleState = jjManager.nTenBattleState
    local nEightSuccessState = jjManager.nEightSuccessState

   self:refreshBox(self.btnRewardFirst,nFirstSuccessState)
   self:refreshBox(self.btnRewardTenBattle,nTenBattleState)
   self:refreshBox(self.btnRewardEightSuccess,nEightSuccessState)
end

function Jingjidialog3:refreshBox(box,nBoxState)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    if gGetGameUIManager() then
       gGetGameUIManager():RemoveUIEffect(box)
    end
    

    local id = box:getID()
    if nBoxState == 0 then
        self.awardEnable[id] = false
        box:setEnabled(true)
    elseif nBoxState == 1 then
        self.awardEnable[id] = true
        box:setEnabled(true)
        jjManager:addCircleEffect(box)
    elseif nBoxState == 2 then
        box:setEnabled(false)
        self.awardEnable[id] = false
    end
end

function Jingjidialog3:resetTeamInfo()
    for nIndexPlayer=1,#self.vItemCellHero do 
         local oneHero = self.vItemCellHero[nIndexPlayer]
         oneHero.itemcellIcon:SetImage(nil)
         oneHero.labelName:setText("")
         oneHero.labelLv:setText("")
         oneHero.labelJob:setText("")
    end
end


function Jingjidialog3:refreshTeamInfo()
    local nIndexCell = 1
    local vcTeam = GetTeamManager():GetMemberList() --MemberList

    --  处理单人情况
    if #vcTeam == 0 then
        if not gGetDataManager() then
            return
        end

        local nShapeId = gGetDataManager():GetMainCharacterShape()
        local nLevelId = gGetDataManager():GetMainCharacterLevel()
        local strName = gGetDataManager():GetMainCharacterName()
        local nJob = gGetDataManager():GetMainCharacterSchoolID()

        self:refreshCell(nIndexCell, nLevelId, nShapeId, strName, nJob)
        return
    end

    -- 处理组队情况 (已有逻辑)
    for nIndex=1, #vcTeam do
        if nIndex > 3 then
            break
        end
        local nShapeId = vcTeam[nIndex].shapeID
        local nLevelId = vcTeam[nIndex].level
        local strName = vcTeam[nIndex].strName
        local nJob = vcTeam[nIndex].eSchool
         
        self:refreshCell(nIndexCell, nLevelId, nShapeId, strName, nJob)
        nIndexCell = nIndexCell +1
    end
end

function Jingjidialog3:refreshCell(nIndexCell, nLevelId, nShapeId, strName, nJob)
    if nIndexCell > #self.vItemCellHero then
        return
    end
    local oneHero = self.vItemCellHero[nIndexCell]

    if #GetTeamManager():GetMemberList() == 0 then 
        local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nShapeId)
        if shapeTable.id ~= -1 then
            local image = gGetIconManager():GetImageByID(shapeTable.headID)
            oneHero.itemcellIcon:SetImage(image)  -- 单人情况下显示头像
        end
    else
        oneHero.itemcellIcon:SetImage(nil)       -- 组队情况下不显示头像
    end

    --  >>>  修改这里  <<<
    --  始终尝试显示模型
    if nShapeId then
        -- 获取玩家信息
        local vcTeam = GetTeamManager():GetMemberList()
        local playerInfo = nil 

        -- 检查是否是玩家
        if nIndexCell <= #vcTeam then
            playerInfo = vcTeam[nIndexCell]

            -- 获取模型染色信息 
            local dyeInfo = {
                playerInfo:getComponent(eSprite_DyePartA), 
                playerInfo:getComponent(eSprite_DyePartB)
            }  
            local weaponID = playerInfo:getComponent(eSprite_Weapon)

            --  显示模型和武器
            local model = gGetGameUIManager():AddWindowSprite(oneHero.mode, nShapeId, Nuclear.XPDIR_BOTTOMRIGHT, oneHero.mode:getPixelSize().width * 0.5, oneHero.mode:getPixelSize().height * 0.5 + 48, true)
            if model then
                model:SetDyePartIndex(0, dyeInfo[1])
                model:SetDyePartIndex(1, dyeInfo[2])
                model:SetSpriteComponent(eSprite_Weapon, weaponID) 
            end
        end 
    end

    local schoolTable = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(nJob)
    if schoolTable then
        oneHero.labelJob:setText(schoolTable.name)
    end

    local strLvzi = require "utils.mhsdutils".get_resstring(11813)

    local strLv = nLevelId .. tostring(strLvzi)
    oneHero.labelName:setText(strName)
    oneHero.labelLv:setText(strLv)

    if oneHero.btnAdd then
        oneHero.btnAdd:setVisible(false)
    end
end

function Jingjidialog3:refreshBattleInfo()
   local jjManager = require("logic.jingji.jingjimanager").getInstance()

    local nBattleNum =  jjManager.nBattleNum
    local nSuccessNum =  jjManager.nSuccessNum
    local nContinueNum =  jjManager.nContinueNum

    self.labelBattleNum:setText(tostring(nBattleNum))
    self.labelBattleSuccessNum:setText(tostring(nSuccessNum))
    self.labelContinueSuccessNum:setText(tostring(nContinueNum))
end


function Jingjidialog3:clickScoreRank(arg)
     require("logic.jingji.jingjiscorerankdialog").getInstanceAndShow()
end

function Jingjidialog3:refreshReady(nReady)

    if nReady==1 then
        
        self.labelBegin:setVisible(false)
        self.imageWait:setVisible(true)
    else
        
        self.labelBegin:setVisible(true)
        self.imageWait:setVisible(false)
    end
end

function Jingjidialog3:sendReady(nReady)
     local p = require "protodef.fire.pb.battle.pvp3.cpvp3readyfight":new()
    p.ready = nReady
	require "manager.luaprotocolmanager":send(p)
end

function Jingjidialog3:clickBeginPipei(arg)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()
     if jjManager.nPiPei3 == 1 then
        require("logic.jingji.jingjipipeidialog3").getInstanceAndShow()
    else
        if GetTeamManager():IsOnTeam() == false then
        else
            if GetTeamManager():IsMyselfLeader()==false then
                local strShowTip = require "utils.mhsdutils".get_msgtipstring(160338)  
		        GetCTipsManager():AddMessageTip(strShowTip)
                return 
            end
        end

         self:sendReady(1)
    end
end

function Jingjidialog3:refreshPiPeiBtn() 
end

function Jingjidialog3:clickRewardFirst(arg)
    if self.awardEnable[1] then
        local p = require "protodef.fire.pb.battle.pvp3.cpvp3openbox":new()
        p.boxtype = 1
        require "manager.luaprotocolmanager":send(p)
    else
        local strBuilder = StringBuilder:new()
        strBuilder:Set("parameter1", MHSD_UTILS.get_resstring(11342))
        GetCTipsManager():AddMessageTip(strBuilder:GetString(MHSD_UTILS.get_msgtipstring(160342)))
        strBuilder:delete()
    end
end

function Jingjidialog3:clickRewardTenBattle(arg)
    if self.awardEnable[2] then
        local p = require "protodef.fire.pb.battle.pvp3.cpvp3openbox":new()
        p.boxtype = 2
        require "manager.luaprotocolmanager":send(p)
    else
        local strBuilder = StringBuilder:new()
        strBuilder:Set("parameter1", MHSD_UTILS.get_resstring(11343))
        GetCTipsManager():AddMessageTip(strBuilder:GetString(MHSD_UTILS.get_msgtipstring(160342)))
        strBuilder:delete()
    end
end

function Jingjidialog3:clickRewardEightSuccess(arg)
    if self.awardEnable[3] then
        local p = require "protodef.fire.pb.battle.pvp3.cpvp3openbox":new()
        p.boxtype = 3
        require "manager.luaprotocolmanager":send(p)
    else
        local strBuilder = StringBuilder:new()
        strBuilder:Set("parameter1", MHSD_UTILS.get_resstring(11344))
        GetCTipsManager():AddMessageTip(strBuilder:GetString(MHSD_UTILS.get_msgtipstring(160342)))
        strBuilder:delete()
    end      
end


function Jingjidialog3:clickShowMyInfoOnly(arg)
    self:refreshRichBox()
end


--//=========================================
function Jingjidialog3.getInstance()
    if not _instance then
        _instance = Jingjidialog3:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jingjidialog3.getInstanceAndShow()
    if not _instance then
        _instance = Jingjidialog3:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingjidialog3.getInstanceNotCreate()
    return _instance
end

function Jingjidialog3.getInstanceOrNot()
	return _instance
end
	
function Jingjidialog3.GetLayoutFileName()
    return "jingjichangdiglog3v3.layout"
end

function Jingjidialog3:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingjidialog3)
	self:ClearData()
    return self
end

function Jingjidialog3.DestroyDialog()
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

function Jingjidialog3:ClearData()
	self.nItemCellSelId = 0
	self.ScrollEquip = {}
	self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function Jingjidialog3:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function Jingjidialog3:ClearCellAll()
end


function Jingjidialog3:OnClose()
    if self.aniDlg then
        self.aniDlg:DestroyDialog()
    end

    NotificationCenter.removeObserver(Notifi_TeamListChange, Jingjidialog3.teamChange)
	self:ClearCellAll()
	Dialog.OnClose(self)
	self:ClearData()
	_instance = nil
    require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return Jingjidialog3

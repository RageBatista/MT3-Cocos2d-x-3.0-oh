

require "logic.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protodef.fire.pb.npc.cdonefortunewheel"
require "protodef.fire.pb.npc.cexitcopy"
require "logic.jingying.jingyinggongneng"

Jingyingenddlg = {
    nRewardAllNum = 4,
    eNoRotate_normal = 0,
    eStartRotate_action1 = 1,
    eFaceRotate_action2 = 2,
    eStopRotate_wait = 3,
    nResultIndex = -1,
    bNormalClose = false,
    fLeftSecond = 0,
    nCurSelId = -1,
    m_eRotateState = eNoRotate_normal,
    fZhuanTime = 0,
    pCurSelPic = nil,
    vPicItem = {},
    nNpcId = -1,
    nCurTaskId = -1,
    mapSelPic = {itemtype = 1, id = 0, num = 0, times = 0,},
    mapNotGiveItem = {},
}

setmetatable(Jingyingenddlg, Dialog)
Jingyingenddlg.__index = Jingyingenddlg 

local _instance

function Jingyingenddlg.sendOutJingying()
    local actionReg = CExitCopy.Create()
    LuaProtocolManager.getInstance():send(actionReg)
end

function Jingyingenddlg.IsShow()

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function Jingyingenddlg.getInstance()
	
    if not _instance then
        _instance = Jingyingenddlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function Jingyingenddlg.getInstanceAndShow()
    if not _instance then
        _instance = Jingyingenddlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function Jingyingenddlg.getInstanceNotCreate()
    return _instance
end

function Jingyingenddlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Jingyingenddlg:OnClose()
    Dialog.OnClose(self)
    
end

function Jingyingenddlg.ToggleOpenClose()
	if not _instance then 
		_instance = Jingyingenddlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Jingyingenddlg.GetLayoutFileName()
    return "jingyingend_mtg.layout"
end

function Jingyingenddlg:OnCreate()

    Dialog.OnCreate(self)
    self:GetWindow():setModalState(true)
    local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.vPicItem = {}
    for nIndex = 1, self.nRewardAllNum, 1 do
        self.vPicItem[nIndex] = JingyingendPic.New()
        self.vPicItem[nIndex].btnItemPic = CEGUI.Window.toPushButton(winMgr:getWindow("jingyingend_mtg/cell" .. (nIndex-1)))
        self.vPicItem[nIndex].btnItemPic:setID(nIndex)
        self.vPicItem[nIndex].btnItemPic:subscribeEvent("Clicked", Jingyingenddlg.HandleCardBtnClicked, self)

        self.vPicItem[nIndex].pItemCell = CEGUI.toItemCell(winMgr:getWindow("jingyingend_mtg/cell/item" .. (nIndex-1)))
        self.vPicItem[nIndex].pItemName = winMgr:getWindow("jingyingend_mtg/cell/name" .. (nIndex-1))
        self.vPicItem[nIndex].pItemName:setMousePassThroughEnabled(true)
        self.vPicItem[nIndex].pItemName:setVisible(true)
        JingyingendPic.hideItem(self.vPicItem[nIndex])
        self.vPicItem[nIndex].pItemGuang = winMgr:getWindow("jingyingend_mtg/cell/light" .. (nIndex-1))
        self.vPicItem[nIndex].pItemGuang:setMousePassThroughEnabled(true)
		self.vPicItem[nIndex].pEffectFanpai = winMgr:getWindow("jingyingend_mtg/effetfanpai" .. (nIndex-1))
		self.vPicItem[nIndex].pEffectFanpai:setMousePassThroughEnabled(true)
    end

    self.m_pLevelImage = winMgr:getWindow("jingyingend_mtg/level")
    self.m_pLevelText = winMgr:getWindow("jingyingend_mtg/text3")

    self.labelExp = winMgr:getWindow("jingyingend_mtg/text5")
    self.m_pLeftSec = winMgr:getWindow("jingyingend_mtg/text6")
    
    self:GetWindow():subscribeEvent("WindowUpdate", Jingyingenddlg.HandleWindowUpdate, self)
    self:GetWindow():subscribeEvent("MouseClick", Jingyingenddlg.HandleClickBg, self)
	
	self.smokeBg = winMgr:getWindow("jingyingend_mtg/diban")
	local s = self.smokeBg:getPixelSize()
	--local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_duanxian/mt_fubendi", true, s.width*0.5, s.height)
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_duanxian/mt_fubendi", true, s.width, s.height)
end

function Jingyingenddlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingyingenddlg)
    
    self.m_eDialogType[DialogTypeTable.eDialogType_BattleClose] = 1
    self.m_eDialogType[DialogTypeTable.eDialogType_InScreenCenter] = 1
    self.m_eDialogType[DialogTypeTable.eDialogType_MapChangeClose] = 1

    return self
end

function Jingyingenddlg:DestroyDialog1()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

function Jingyingenddlg:InitScore(nTableId, score)
    self.labelExp:setText(tostring(score))

    local retTable = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingpingji"):getRecorder(nTableId)
    if not retTable then
        return
    end

    self.m_pLevelImage:setProperty("Image", retTable.tubiaolujing)
    self.m_pLevelText:setText(retTable.level)
end

function Jingyingenddlg:HandleClickBg(e)

    if self.m_eRotateState ~= self.eStopRotate_wait then
        return 
    end

    Jingyingenddlg.DestroyDialog()

end

function Jingyingenddlg.touchClose()
    if not _instance then
        return
    end
    if _instance.m_eRotateState ~= _instance.eStopRotate_wait then
        return 
    end
    Jingyingenddlg.DestroyDialog()

end

function Jingyingenddlg:clickCard(nSelId)
    self.nCurSelId = nSelId
    self.pCurSelPic = self.vPicItem[self.nCurSelId].btnItemPic
       
    self.m_eRotateState = self.eStartRotate_action1
    self.fZhuanTime = 0
        
    if not self.bNormalClose then
       local actionReg = CDoneFortuneWheel.Create()
       actionReg.npckey = self.nNpcId
       actionReg.taskid = self.nCurTaskId
       actionReg.succ = 1
       actionReg.flag = 1
       LuaProtocolManager.getInstance():send(actionReg)
    end
end

function Jingyingenddlg:autoClickOne()
     if self.nCurSelId == -1 then
        math.randomseed(os.time())
        local nSelId = math.random(1,self.nRewardAllNum)
        self:clickCard(nSelId)
    end
end

function Jingyingenddlg:HandleCardBtnClicked(eventArgs)    
    local args = CEGUI.toMouseEventArgs(eventArgs)
    
    if self.nCurSelId == -1 then
        local nSelId = args.window:getID()
        self:clickCard(nSelId)
    end

    return true
end

function Jingyingenddlg:DoWhenNotifiedByEffect()

    self.bNormalClose = true
    
    local actionReg = CDoneFortuneWheel.Create()
    actionReg.npckey = self.nNpcId
    actionReg.taskid = self.nCurTaskId
    actionReg.succ = 1
    actionReg.flag = 1
    LuaProtocolManager.getInstance():send(actionReg)
end



function Jingyingenddlg:HandleWindowUpdate(eventArgs)
    local  nAllTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(243).value)
    local args = CEGUI.toUpdateEventArgs(eventArgs)

    self.fLeftSecond = self.fLeftSecond + args.d_timeSinceLastFrame
    if self.fLeftSecond >= nAllTime then
          self.m_pLeftSec:setText(tostring(0))
    else
         local leftSecReg = nAllTime - math.floor(self.fLeftSecond)
         self.m_pLeftSec:setText(tostring(leftSecReg))
    end


    if self.m_eRotateState == self.eStartRotate_normal then
         if self.fLeftSecond >= nAllTime then
            self:autoClickOne()
         else
        end
    end

    if  self.m_eRotateState == self.eStopRotate_wait then
         if self.fLeftSecond >= nAllTime then
             if self.fZhuanTime <= 5.0 then --0---1.0
                 self.fZhuanTime = self.fZhuanTime + args.d_timeSinceLastFrame
             else
                 Jingyingenddlg.DestroyDialog()
             end
         else
        end
    end
    
    if self.m_eRotateState == self.eStartRotate_action1 then
        if self.pCurSelPic and self.fZhuanTime <= 0.2 then
            self.fZhuanTime = self.fZhuanTime + args.d_timeSinceLastFrame
        else
            self.m_eRotateState = self.eFaceRotate_action2
            self.fZhuanTime = 0
            self:addOneItem(self.nCurSelId, self.mapSelPic.itemtype, self.mapSelPic.id, self.mapSelPic.nNum, self.mapSelPic.times)
            
            JingyingendPic.showItem(self.vPicItem[self.nCurSelId])
            self.vPicItem[self.nCurSelId].pItemCell:SetSelected(false)
        end
    end

    if self.m_eRotateState == self.eFaceRotate_action2 then 
        if self.pCurSelPic and self.fZhuanTime <= 0.75 then --0---0.75
            self.fZhuanTime = self.fZhuanTime + args.d_timeSinceLastFrame
        else
            local ret = require "logic.bingfengwangzuo.bingfengwangzuomanager":isInBingfeng()
            if ret == false then
                local pos = 1
                for i = 1, self.nRewardAllNum, 1 do
                     if i ~= self.nCurSelId then
                    
                         self:addOneItem(i, self.mapNotGiveItem[pos].itemtype, self.mapNotGiveItem[pos].id, self.mapNotGiveItem[pos].nNum, self.mapNotGiveItem[pos].times)
                         pos = pos + 1
                         JingyingendPic.showItem(self.vPicItem[i])
                     end
                 end
                self.m_eRotateState = self.eStopRotate_wait
            	self.pCurSelPic:setVisible(true)
                self.pCurSelPic = nil
                self.fZhuanTime = 0
                self:DoWhenNotifiedByEffect()
            else
                Jingyingenddlg.DestroyDialog()
            end
        end
    end

    return true
end

function  Jingyingenddlg:HandleShowToolTipsWithItemID(args)
    local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e2 = CEGUI.toMouseEventArgs(args)
	local touchPos = e2.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--local nType = Commontipdlg.eType.eComeFrom
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)

end

function Jingyingenddlg:addOneItem(nIndex, type, nItemId, nNum, times)

    self.vPicItem[nIndex].nNum = nNum

    if type == 1 or type == 5 then
        self.vPicItem[nIndex].nItemId = nItemId
        local itembase = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
        if itembase then
            self.vPicItem[nIndex].pItemCell:SetImage(gGetIconManager():GetItemIconByID(itembase.icon))
            --self.vPicItem[nIndex].pItemCell:SetTextUnit(tostring(nNum))----数量
            SetItemCellBoundColorByQulityItem(self.vPicItem[nIndex].pItemCell, itembase.nquality)
            self.vPicItem[nIndex].pItemCell:setID(nItemId)
            self.vPicItem[nIndex].pItemCell:removeEvent("TableClick")
            self.vPicItem[nIndex].pItemCell:subscribeEvent("TableClick", Jingyingenddlg.HandleShowToolTipsWithItemID, self)

            self.vPicItem[nIndex].pItemCell:SetBtnVisible(false)
            self.vPicItem[nIndex].pItemName:setText(itembase.name)
        end
    end
end

function Jingyingenddlg:addAllItems(itemlist, resultindex, npcid, serviceid)
    self.nNpcId = npcid
    self.nCurTaskId = serviceid
    resultindex = resultindex + 1
    self.nResultIndex = resultindex
    if self.nResultIndex > self.nRewardAllNum then
        Jingyingenddlg.DestroyDialog()
        return
    end
    self.mapSelPic = itemlist[resultindex]
    self.mapNotGiveItem = {}
    
    for nIndex = 1, self.nRewardAllNum, 1 do
        if nIndex ~= resultindex then
            self.mapNotGiveItem[#self.mapNotGiveItem+1] = itemlist[nIndex]
        end
    end
    
    MHSD_UTILS.shuffletable(self.mapNotGiveItem)
end

return Jingyingenddlg









require "utils.mhsdutils"
require "logic.dialog"
require "utils.commonutil"


Jingjiscorerankdialog = {}
setmetatable(Jingjiscorerankdialog, Dialog)
Jingjiscorerankdialog.__index = Jingjiscorerankdialog
local _instance;


Jingjiscorerankdialog.eRankType = 
{
    curRank = 0,
    historyRank =1,
}
--//===============================
function Jingjiscorerankdialog:OnCreate()
    Dialog.OnCreate(self)
     SetPositionOfWindowWithLabel(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()
    --jingjichangpaihangdialog3v3/text

    self.btnCurRank = CEGUI.toGroupButton(winMgr:getWindow("jingjichangpaihangdialog3v3/benci"))
    self.btnCurRank:subscribeEvent("MouseButtonUp",Jingjiscorerankdialog.clicCurRank, self)

    self.btnHistoryRank = CEGUI.toGroupButton(winMgr:getWindow("jingjichangpaihangdialog3v3/lishi"))
    self.btnHistoryRank:subscribeEvent("MouseButtonUp",Jingjiscorerankdialog.clicHistoryRank, self)

    self.scrollRole = CEGUI.toScrollablePane(winMgr:getWindow("jingjichangpaihangdialog3v3/diban/gundong"))

    self.nodeMyBg = CEGUI.toScrollablePane(winMgr:getWindow("jingjichangpaihangdialog3v3/diban/mypaihang")) 
    
    self.labelTime = winMgr:getWindow("jingjichangpaihangdialog3v3/time")

    self.nTypeRank = Jingjiscorerankdialog.eRankType.curRank
    self:refreshBtnsel()

    self:sendReqRank()

    local frameWnd=CEGUI.toFrameWindow(winMgr:getWindow("jingjichangpaihangdialog3v3"))
	local closeBtn=CEGUI.toPushButton(frameWnd:getCloseButton())
	closeBtn:subscribeEvent("MouseClick",Jingjiscorerankdialog.HandleQuitClick,self)

    self:refreshMyRank3()
end

function Jingjiscorerankdialog:HandleQuitClick(args)
    Jingjiscorerankdialog.DestroyDialog()
end

function Jingjiscorerankdialog:sendReqRank()

    local p = require "protodef.fire.pb.battle.pvp3.cpvp3rankinglist":new()
    p.history = self.nTypeRank
	require "manager.luaprotocolmanager":send(p)

end

function Jingjiscorerankdialog:refreshBtnsel()
    if self.nTypeRank == Jingjiscorerankdialog.eRankType.curRank then
        self.btnHistoryRank:setSelected(false)
        self.btnCurRank:setSelected(true)
    elseif self.nTypeRank == Jingjiscorerankdialog.eRankType.historyRank then
        self.btnCurRank:setSelected(false)
        self.btnHistoryRank:setSelected(true)
    end

end

--[[
 self.vCurRoleRank = {}
     for nIndex=1,20 do  --wangbin test
        self.vCurRoleRank[nIndex] = {}
        self.vCurRoleRank[nIndex].nRank = nIndex
        self.vCurRoleRank[nIndex].strName = tostring(nIndex)
        self.vCurRoleRank[nIndex].nScore = nIndex * 10
        self.vCurRoleRank[nIndex].nSuccess = nIndex
        self.vCurRoleRank[nIndex].nBattleNum = 100
    end

    self.vHistoryRoleRank = {}

--]]
function Jingjiscorerankdialog:refreshScrollRole()
   self:ClearCellAll()
   local jjManager = require("logic.jingji.jingjimanager").getInstance()

   local vRoleData = nil
   --local myData = nil
   if self.nTypeRank == Jingjiscorerankdialog.eRankType.curRank then
        vRoleData = jjManager.vCurRoleRank
        --myData = jjManager.myDataCur
   elseif self.nTypeRank == Jingjiscorerankdialog.eRankType.historyRank then
        vRoleData = jjManager.vHistoryRoleRank
       -- myData = jjManager.myDataHistory
   end

   for nIndex=1,#vRoleData do
        local oneRole = vRoleData[nIndex]
        local nRank = oneRole.nRank
        local strName = oneRole.strName
        local nScore = oneRole.nScore
        local nSuccess = oneRole.nSuccess
        local nBattleNum = oneRole.nBattleNum
        -----------------------------------------

        local prefix = "Jingjiscorerankdialog"..nIndex
		local cellRole = require("logic.jingji.jingjirolecell3").new(self.scrollRole, nIndex - 1,prefix)
        cellRole.labelNumber:setText(tostring(nRank))
        cellRole.labelRoleName:setText(strName)
        cellRole.labelScore:setText(tostring(nScore))
        --local strSuccessPer = nSuccess.."/"..nBattleNum
        --cellRole.labelSuccessNum:setText(strSuccessPer)
        if nIndex % 2 == 1 then
            cellRole.btnBg:SetStateImageExtendID(1)
        else
            cellRole.btnBg:SetStateImageExtendID(0)
        end
        cellRole.btnBg.nRank = nRank
        cellRole.btnBg:subscribeEvent("MouseButtonUp",Jingjiscorerankdialog.clicRoleCell, self)
        self.vCellRole[#self.vCellRole + 1] = cellRole

         if nRank == 1 then 
			cellRole.imageIconNumber:setProperty("Image","set:paihangbang image:diyiditu");
			cellRole.labelNumber:setText("")
		elseif nRank == 2 then
			cellRole.imageIconNumber:setProperty("Image","set:paihangbang image:dierditu");
            cellRole.labelNumber:setText("")
		elseif nRank == 3 then
			cellRole.imageIconNumber:setProperty("Image","set:paihangbang image:disanditu");
			cellRole.labelNumber:setText("")
		end
   end
   --self.cellRoleMy.labelSuccessNum:setText(strSuccessPer)
end

function Jingjiscorerankdialog:refreshMyRank3()

   local jjManager = require("logic.jingji.jingjimanager").getInstance()

   local myData3 = nil
   if self.nTypeRank == Jingjiscorerankdialog.eRankType.curRank then
        myData3 = jjManager.myDataCur
   elseif self.nTypeRank == Jingjiscorerankdialog.eRankType.historyRank then
        myData3 = jjManager.myDataHistory
   end

    if self.cellRoleMy then
        self.cellRoleMy:DestroyDialog()
   end
   if myData3.nRank == nil then
     jjManager:resetmyData3v3(myData3)
   end
   local nIndex = 1
   local prefix = "Jingjiscorerankdialogmy"..nIndex
   self.cellRoleMy = require("logic.jingji.jingjirolecell3").new(self.nodeMyBg, nIndex - 1,prefix)

   local strMyRank =  tostring(myData3.nRank)
   if myData3.nRank == 0 then
        strMyRank =  require "utils.mhsdutils".get_resstring(11204) 
   end

   self.cellRoleMy.labelNumber:setText(strMyRank)
   self.cellRoleMy.labelRoleName:setText(myData3.strName)
   self.cellRoleMy.labelScore:setText(tostring(myData3.nScore))
   --local strSuccessPer = myData.nSuccess.."/"..myData3.nBattleNum

end

function Jingjiscorerankdialog:clicHistoryRank(arg)
     self.nTypeRank = Jingjiscorerankdialog.eRankType.historyRank
     self:sendReqRank()
end

function Jingjiscorerankdialog:clicRoleCell(args)
    local e = CEGUI.toWindowEventArgs(args)
	local clickWin = e.window
    self.nCurSelCellId = clickWin.nRank
    self:refreshRoleCellSel()
end


function Jingjiscorerankdialog:refreshRoleCellSel()
    for k,v in pairs(self.vCellRole) do
        if v.nRank == self.nCurSelCellId then
            v.btnBg:setSelected(true)
        else
            v.btnBg:setSelected(false)
        end
    end
end

function Jingjiscorerankdialog:clicCurRank(arg)
     self.nTypeRank = Jingjiscorerankdialog.eRankType.curRank
     self:sendReqRank()
end

--//=========================================
function Jingjiscorerankdialog.getInstance()
    if not _instance then
        _instance = Jingjiscorerankdialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Jingjiscorerankdialog.getInstanceAndShow()
    if not _instance then
        _instance = Jingjiscorerankdialog:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingjiscorerankdialog.getInstanceNotCreate()
    return _instance
end

function Jingjiscorerankdialog.getInstanceOrNot()
	return _instance
end
	
function Jingjiscorerankdialog.GetLayoutFileName()
    return "jingjichangpaihangdialog3v3.layout" 
end

function Jingjiscorerankdialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingjiscorerankdialog)
	self:resetData()
    return self
end

function Jingjiscorerankdialog.DestroyDialog()
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

function Jingjiscorerankdialog:resetData()
    self.vCellRole = {}
end

function Jingjiscorerankdialog:ClearDataInClose()
	self.vCellRole = {}
end


function Jingjiscorerankdialog:ClearCellAll()
	for k, v in pairs(self.vCellRole) do
		v:DestroyDialog()
	end
	self.vCellRole = {}
    if self.cellRoleMy then
        self.cellRoleMy:DestroyDialog()
        self.cellRoleMy = nil
    end
end


function Jingjiscorerankdialog:OnClose()
	self:ClearCellAll()
	Dialog.OnClose(self)
	self:ClearDataInClose()
	_instance = nil
end

return Jingjiscorerankdialog

require "utils.mhsdutils"
require "logic.dialog"

Fubendlg = {}
setmetatable(Fubendlg, Dialog)
Fubendlg.__index = Fubendlg

local _instance


function Fubendlg.getInstance()
	if not _instance then
		_instance = Fubendlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
	
end

function Fubendlg.GetLayoutFileName()
	return "fuben_mtg.layout"
end

function Fubendlg.getInstanceNotCreate()
	return _instance
end

function Fubendlg.getInstanceOrNot()
	return _instance
end

function Fubendlg.getInstanceAndShow()
	if not _instance then
		_instance = Fubendlg.new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Fubendlg.DestroyDialog()
	LogInfo("Fubendlg.DestroyDialog()")
	require("logic.fuben.fubenlabel").DestroyDialog()

end

function Fubendlg:OnClose()
	LogInfo("Fubendlg:OnClose()")
	self:clearAllCell()
	Dialog.OnClose(self)
	_instance = nil
end

function Fubendlg:new()
    local self = {}
	self = Dialog:new()
    setmetatable(self, Fubendlg)
	self:ClearData()
    return self
end

Fubendlg.eFuBenType =
{
	eNormal =1,
	eHard =2,
}

function Fubendlg:ClearData()
	self.vCell = {}
	self.nDiff = Fubendlg.eFuBenType.eNormal
	self.nLevelType = 1
	self.vBtnTitle = {}
end

function Fubendlg:clearAllCell()
	for k, v in pairs(self.vCell) do
		LogInfo("Fubendlg:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vCell = {}
end

function Fubendlg:OnCreate()
	local prefix = "Fubendlg"
	Dialog.OnCreate(self,nil, prefix)
	SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	local nLevelTypeMax = require("logic.fuben.fubenmanager").getInstance():getLevelTypeMax()
	LogInfo("nLevelTypeMax="..nLevelTypeMax)
	for nIndex=1,nLevelTypeMax do 
		local strNamePane = prefix.."fuben_mtg/btn"..nIndex
		local window = winMgr:getWindow(strNamePane)
		if window then
			local btnLevel = CEGUI.toGroupButton(window)
			btnLevel.nLevelType = nIndex
			btnLevel:subscribeEvent("MouseButtonUp", Fubendlg.HandlBtnClickedLevel, self)
			self.vBtnTitle[#self.vBtnTitle +1] = btnLevel
		end
	end
	self.scrollPane = CEGUI.toScrollablePane(winMgr:getWindow(prefix.."fuben_mtg/bg/list"))
	self.scrollPane:EnableHorzScrollBar(true)
	
	
	self.labelShowRefreshTime = winMgr:getWindow(prefix.."fuben_mtg/text")
	
	self:reqServerData()
	
end

function Fubendlg:refreshShowRefreshTime()
	LogInfo("self.nDiff="..self.nDiff)
	if self.nDiff == Fubendlg.eFuBenType.eHard then
		local strShowzi = require("utils.mhsdutils").get_resstring(11255)
		self.labelShowRefreshTime:setText(strShowzi)
	else
		local strShowzi = require("utils.mhsdutils").get_resstring(11254)
		self.labelShowRefreshTime:setText(strShowzi)
	end
end

function Fubendlg:clickDiff(nDiff)
	
    if self.nDiff == nDiff then
        return
    end

	self.nDiff = nDiff
	self:refreshScroll()
	self:refreshScrollState()
	--self:RefreshBtnSel()
	
	self:refreshShowRefreshTime()
end

function Fubendlg:HandlBtnClickedLevel(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
	self.nLevelType = clickWin.nLevelType
	self:refreshScroll()
	self:refreshScrollState()
	self:refreshBtnTitleSel()
end

function Fubendlg:refreshBtnTitleSel()
	for nIndex,btnTitle in pairs(self.vBtnTitle) do 
		if btnTitle.nLevelType == self.nLevelType then
			btnTitle:setSelected(true)
		else
			btnTitle:setSelected(false)
		end
	end
end

function Fubendlg:reqServerData()
	LogInfo("Fubendlg:reqServerData()")
	local p = require "protodef.fire.pb.mission.cgetinstancestate":new()
	require "manager.luaprotocolmanager":send(p)
end

--刷新所有单元的位置.
function Fubendlg:RefeshAllCellPos()
	local nSpaceX = 40
	local nOriginX = 10
	for nIndex=1,#self.vCell do
		local cell = self.vCell[nIndex]
		local s = cell.m_pMainFrame:getPixelSize()
		local nWidth = s.width
		local nHeight = s.height
		local nPosY =  nHeight * (nIndex-1)
		local nPosX =  nOriginX + (nWidth+nSpaceX) * (nIndex-1)
		nPosY = 0
		cell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, nPosX), CEGUI.UDim(0, nPosY)))
	end
end



function Fubendlg:refreshCellStateWithFubenId(nFubenId)
	for nIndex=1,#self.vCell do
		local cell = self.vCell[nIndex]
		if cell.nFubenId == nFubenId then
			self:refreshCellState(cell)
		end
	end
end

function Fubendlg:refreshScrollState()
	for nIndex=1,#self.vCell do
		local cell = self.vCell[nIndex]
		self:refreshCellState(cell)
	end
end

function Fubendlg:refreshCellState(cell)
	local nFubenId = cell.nFubenId
	
	local fbManager = require("logic.fuben.fubenmanager").getInstance()
	local fubenData = fbManager:getFubenDataWithId(nFubenId)
	if not fubenData then
		return 
	end
	local nFinishNum = fubenData.finishedtimes
	if not nFinishNum then
		nFinishNum = 0
	end
	
	local bEnabled = true
	local bPassFuben = false
	local strPassTitle = ""
	local bBgEnable = true
	
	if fubenData.instancestate == 0 then
		bEnabled = false
		bBgEnable = false
		strPassTitle = require "utils.mhsdutils".get_resstring(11249) --wei tong guan
	elseif fubenData.instancestate == 1 then --kai qi
		bEnabled = true
		if fubenData.state == 0 then --wei tong guan
			bEnabled = true
			
			if nFinishNum > 0 then
				strPassTitle = require "utils.mhsdutils".get_resstring(11250)
				local sb = StringBuilder.new()
				sb:Set("parameter1",tostring(nFinishNum))
				print("nFinishNum="..nFinishNum)
				strPassTitle = sb:GetString(strPassTitle)
				--strPassTitle = CEGUI.String(strPassTitle)
				sb:delete()
			else
				bPassFuben = false
				strPassTitle = require "utils.mhsdutils".get_resstring(11249) --wei tong guan
			end
			
			
		elseif  fubenData.state == 2 then --yi tongguan
			bEnabled = true
			bPassFuben = true
			strPassTitle = require "utils.mhsdutils".get_resstring(11251)
		end
	end
	
	
	cell.btnBg:setEnabled(bBgEnable)
	cell.btnEnter:setEnabled(bEnabled)
	
	--cell.labelNoPass:setVisible(not bPassFuben)
	cell.labelNoPass:setText(strPassTitle)
	
	
end


function Fubendlg:getTimeTitle(nFubenId)
	--nlunhuantype
	local fbManager = require("logic.fuben.fubenmanager").getInstance()
	local fubenData = fbManager:getFubenDataWithId(nFubenId)
	local funbenTable = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getRecorder(nFubenId)
	if not fubenData then
		return
	end
	local strTitleDate = funbenTable.strkaiqitime
	if funbenTable.nlunhuantype == 1 then
	elseif  funbenTable.nlunhuantype == 2 then
		if fubenData.instancestate == 0 then --weikaiqi
			strTitleDate = require "utils.mhsdutils".get_resstring(11253) --xia zhou
		elseif fubenData.instancestate == 1 then
			strTitleDate =  require "utils.mhsdutils".get_resstring(11252)
		end
		
	end
	return strTitleDate
end


function Fubendlg:createCell(fubenData,funbenTable)
	LogInfo("Fubendlg:createCell(fubenData,funbenTable)")
	if not fubenData then
		return
	end
	local fbManager = require("logic.fuben.fubenmanager").getInstance()
	
	local nFubenId  = funbenTable.id
	local parent = self.scrollPane
	local nState = fubenData.state
	local strTitle1 = funbenTable.taskname
	local strTitle2 = fbManager:getTimeTitle(nFubenId)
	local strDes =  funbenTable.strdes
	
	
	LogInfo("nFubenId="..nFubenId)
		
	local nIndex = #self.vCell 
	local prefix = "Fubendlg"..nIndex
	local funbenCell = require("logic.fuben.fubencell").new(parent,prefix)
	self.vCell[#self.vCell + 1] = funbenCell
	
	funbenCell.nFubenId = nFubenId
	--funbenCell.btnBg:subscribeEvent("MouseButtonUp", Fubendlg.HandlClickBtnCell, self)
	--funbenCell.btnBg.nCellId = nFuBenId
	funbenCell.btnEnter:subscribeEvent("MouseButtonUp", Fubendlg.HandlClickBtnCell, self)
	funbenCell.btnEnter.nFubenId = nFubenId
	funbenCell.labelTitle1:setText(strTitle1)
	funbenCell.labelTitle2:setText(strTitle2)
	funbenCell.labelDes:setText(strDes)
	local nModelId = funbenTable.nbossid
	
    local bShowBg = false
    local bShowModel = false
    if funbenTable.nshowtype == 1 then --bgimage
        bShowBg = true
        funbenCell.imageBgCircle:setVisible(false)
    elseif funbenTable.nshowtype == 2 then --model
        bShowModel = true
    elseif funbenTable.nshowtype == 3 then --both
        bShowBg = true
        bShowModel = true
    end
    if bShowBg == true then
        local strIconPath = funbenTable.strbgname
        funbenCell.imageShowBg:setProperty("Image",strIconPath)
    end
    if bShowModel == true then
	    local s = funbenCell.imageBgSprite:getPixelSize()
	    local sprite = gGetGameUIManager():AddWindowSprite(funbenCell.imageBgSprite, nModelId, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, true)
	    sprite:SetModel(nModelId)
	    sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	    sprite:PlayAction(eActionStand)
    end

end

function Fubendlg:refreshUI(nDiff,nLevelType)
	LogInfo("Fubendlg:refreshUI(nDiff,nLevelType)"..nDiff.."=nLevelType="..nLevelType)
	self.nDiff = nDiff
	self.nLevelType = nLevelType
	self:refreshScroll()
	self:refreshScrollState()
	self:refreshBtnTitleSel()
	
	self:refreshShowRefreshTime()
end

function Fubendlg:refreshScroll()
	self:clearAllCell()
	local parent = self.scrollPane
	--local prefix = "Fubendlg"
	local vFubenId = {}
	local fbManager = require("logic.fuben.fubenmanager").getInstance()
	local nDiff = self.nDiff
	local nLevelType = self.nLevelType
	fbManager:getFubenDataWithDiffAndLevelType(nDiff,nLevelType,vFubenId)
	
	for nIndex=1,#vFubenId do 
		local nFubenId = vFubenId[nIndex]
		local fubenData = fbManager:getFubenDataWithId(nFubenId)
		local funbenTable = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getRecorder(nFubenId)
		self:createCell(fubenData,funbenTable)
	end
	self:RefeshAllCellPos()

    if #vFubenId > 2 then
        self.scrollPane:getHorzScrollbar():EnbalePanGuesture(true)
    else
        self.scrollPane:getHorzScrollbar():EnbalePanGuesture(false)
    end
end


function Fubendlg:HandlClickBtnCell(e)
	
		
end

function Fubendlg:RefreshBtnSel()
end

return Fubendlg



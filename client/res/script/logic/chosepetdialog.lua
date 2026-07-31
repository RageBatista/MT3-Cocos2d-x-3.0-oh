require "logic.dialog"
require "utils.commonutil"

Chosepetdialog = {}
setmetatable(Chosepetdialog, Dialog)
Chosepetdialog.__index = Chosepetdialog
local _instance



function Chosepetdialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.scrollPane = CEGUI.toScrollablePane(winMgr:getWindow("choosechongwu/list"))
	self.scrollPane:EnableHorzScrollBar(true)
	
	self.labelName = winMgr:getWindow("choosechongwu/titlename") 
	self.labelBottom = winMgr:getWindow("choosechongwu/text") 
--choosechongwucell/text
	

    --choosechongwu/text1
	self.labelNormal = winMgr:getWindow("choosechongwu/text") 
    self.labelDadui = winMgr:getWindow("choosechongwu/text1") 

	self.m_pMainFrame:setAlwaysOnTop(true)
	
	--self.scrollPane:EnableHorzScrollBar(true)
	--self.scrollPane:EnablePageScrollMode(true)
    self.scrollPane:EnableScrollDrag(false)
    self.m_CloseWindow = false
end


function Chosepetdialog:HandleClickedUse(e)
end

function Chosepetdialog:HandleClickedClose(e)
	self:DestroyDialog()
end

--刷新所有单元的位置.
function Chosepetdialog:RefeshAllCellPos()
	local nSpaceX = 40
	local nOriginX = 10

    if #self.vCell == 1 then
        local nWidth = self.scrollPane:getPixelSize().width
        
        self.scrollPane:setWidth(CEGUI.UDim(0, nWidth / 2))
        self.scrollPane:setPosition(CEGUI.UVector2(CEGUI.UDim(0, self.scrollPane:getPosition().x.offset + nWidth / 4 + nSpaceX), CEGUI.UDim(0, self.scrollPane:getPosition().y.offset)))
    end

	for nIndex=1,#self.vCell do
		
		local cell = self.vCell[nIndex]
		local s = cell:getPixelSize()
		local nWidth = s.width
		local nHeight = s.height
		local nPosY =  0--nHeight * (nIndex-1)
		local nPosX =  nOriginX + (nWidth+nSpaceX) * (nIndex-1)
		cell:setPosition(CEGUI.UVector2(CEGUI.UDim(0, nPosX), CEGUI.UDim(0, nPosY)))
		
	end
	--[[
	local width = 240
	local height = 340
	
	local xO = 20
	local yO = 0
	
	for i in pairs( self.m_mapIDList ) do
		local mapID = self.m_mapIDList[i]
		local cell = MapChooseCell.CreateNewDlg( self.m_scrollCellList )
		cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0, (i-1)*width + xO ), CEGUI.UDim(0,  yO  )))
	--]]
end

function Chosepetdialog:SetSelectPetId(vItemId,vItemNum,nTaskTypeId,nNpcKey)
    self:clearAllCell()
	LogInfo("Chosepetdialog.SetSelectPetId")
	self.nTaskTypeId = nTaskTypeId
	self.nNpcKey = nNpcKey
	--self.nOptionId = 2 --//1=item 2=pet
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	for nIndex=1,#vItemId do
		local nItemId = vItemId[nIndex]
		local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId)
        if petAttrCfg then
		    local prefixName = "Chosepetdialog"..tostring(nIndex)
		    local layoutCell = winMgr:loadWindowLayout("choosechongwucell.layout",prefixName)
		    layoutCell:subscribeEvent("MouseClick", self.HandleClickedCell, self)
		    layoutCell.imageIcon = winMgr:getWindow(prefixName.."choosechongwucell/fazhen/")
		    layoutCell.labelName = winMgr:getWindow(prefixName.."choosechongwucell/text")
		    layoutCell.labelName:setText(petAttrCfg.name)
		    layoutCell.nItemId = nItemId

		    local s = layoutCell.imageIcon:getPixelSize()
		    local sprite = gGetGameUIManager():AddWindowSprite(layoutCell.imageIcon, petAttrCfg.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, true)
		    sprite:SetModel(petAttrCfg.modelid)
            sprite:SetDyePartIndex(0,petAttrCfg.area1colour)
            sprite:SetDyePartIndex(1,petAttrCfg.area2colour)
		    sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
		    sprite:PlayAction(eActionStand)
	
		    self.scrollPane:addChildWindow(layoutCell)
		    if self.nCurItemKey==-1 then
			    self.nCurItemKey = nItemId
		    end
		    self.vCell[nIndex] = layoutCell
		    LogInfo("Chosepetdialog.SetSelectPetId2=nItemId="..nItemId)
		    local nChildcount = layoutCell:getChildCount()
		    for i = 0, nChildcount - 1 do
			    local child = layoutCell:getChildAtIdx(i)
			    child:setMousePassThroughEnabled(true)
		    end
        end
	end
	self:RefeshAllCellPos()
	--self:RefreshCellSel()

    local nTaskType = require("logic.task.taskhelper").GetTaskShowTypeWithId(nTaskTypeId)

    if nTaskType==5 then
        self.labelNormal:setVisible(false)
        self.labelDadui:setVisible(true)
    end

end


function Chosepetdialog:SetSelectItemId(vItemId,vItemNum,nTaskTypeId,nNpcKey)
    self:clearAllCell()
	self.nTaskTypeId = nTaskTypeId
	slef.nNpcKey = nNpcKey
	--self.nOptionId = 1 --//item
	local winMgr = CEGUI.WindowManager:getSingleton()
	--local strLevelzi = MHSD_UTILS.get_resstring(351)
	for nIndex=1,#vItemId do
		local nItemId = vItemId[nIndex]		
		local prefixName = "Chosepetdialog"..tostring(nIndex)
		local layoutCell = winMgr:loadWindowLayout("choosechongwucell.layout",prefixName)
		layoutCell:subscribeEvent("MouseClick", self.HandleClickedCell, self)
		layoutCell.imageIcon = winMgr:getWindow(prefixName.."choosechongwucell/fazhen/")
		
		local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
        if itemattr then
		    local nIconId = itemattr.icon
		    --local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
		    layoutCell.nItemId = nItemId
		    local strPath = gGetIconManager():GetImagePathByID(nIconId):c_str()
		    layoutCell.imageIcon:setProperty("Image",strPath )
		    self.scrollPane:addChildWindow(layoutCell)
		    if self.nCurItemKey==-1 then
			    self.nCurItemKey = nItemId
		    end
		    self.vCell[nIndex] = layoutCell
				
		    local nChildcount = layoutCell:getChildCount()
		    for i = 0, nChildcount - 1 do
			    local child = layoutCell:getChildAtIdx(i)
			    child:setMousePassThroughEnabled(true)
		    end
        end
	end
	--self:RefeshAllCellPos()
	--self:RefreshCellSel()
end

function Chosepetdialog:HandleClickedCell(e)
	LogInfo("Chosepetdialog.HandleClickedCell")
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
	--self.nCurItemKey = clickWin.nItemId
	--self:RefreshCellSel()
	local nItemId = clickWin.nItemId
	local nNpcKey = self.nNpcKey 
	local nTaskTypeId = self.nTaskTypeId
	local nOptionId = nItemId
	GetTaskManager():CommitScenarioQuest(nTaskTypeId,nNpcKey,nOptionId)
	
    require "logic.npc.npcscenespeakdialog".handleWindowShut()
	self:DestroyDialog()
end

Chosepetdialog.strImageSelName = "set:common_sangongge4 image:common_equipzhengtu" 

function Chosepetdialog:RefreshCellSel()
	--[[
	for nIndex=1,#self.vCell do
		local cell = self.vCell[nIndex]
		local nItemId = cell.nItemId
		if self.nCurItemKey==nItemId then
			cell.imageBg:setProperty("Image",Chosepetdialog.strImageSelName )
		else
			cell.imageBg:setProperty("Image","")
		end
	end
	--]]
end

function Chosepetdialog:RefreshPetProperty()
		
end

--//==============================
function Chosepetdialog:GetLayoutFileName()
	return "choosechongwu.layout"
	      
end

function Chosepetdialog.getInstance()
	if _instance == nil then
		_instance = Chosepetdialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Chosepetdialog.getInstanceNotCreate()
	return _instance
end

function Chosepetdialog.getInstanceOrNot()
	return _instance
end


function Chosepetdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Chosepetdialog)
	self:ClearData()
	return self
end

function Chosepetdialog:DestroyDialog()
	self:OnClose()
end

function Chosepetdialog:ClearData()
	self.nServiceId = -1
	self.nNpcKey = -1
	self.vLabelValue = {}
	self.nCurItemKey = -1
	self.vCell = {}

end

function Chosepetdialog:clearAllCell()
    if not self.vCell then
        return
    end
    for k,layoutCell in pairs(self.vCell) do
         if self.scrollPane and layoutCell then
		    self.scrollPane:removeChildWindow(layoutCell)
            CEGUI.WindowManager:getSingleton():destroyWindow(layoutCell)
	    end
    end
    self.vCell = {}
end

function Chosepetdialog:OnClose()
    self:clearAllCell()
	Dialog.OnClose(self)
	self:ClearData()
	_instance = nil
end

-----------------------------------------------------------------------------------

function Chosepetdialog:SetSelectShenShouId(flag, shenshouidlist, itemname, npckey, mypetname, mypetinccount, mypetkey)
    self:clearAllCell()
	LogInfo("Chosepetdialog.SetSelectShenShouId")
    self.nFlag = flag -- 0-兑换神兽 1-重置神兽
	self.strItemName = itemname
	self.nNpcKey = npckey
    self.strMyPetName = mypetname
    self.nMyPetIncCount = mypetinccount
    self.nMyPetKey = mypetkey
    self.m_CloseWindow = true
    local strLabelName = MHSD_UTILS.get_resstring(11435)
	self.labelName:setText(strLabelName)
    self.labelBottom:setText(MHSD_UTILS.get_resstring(11502))
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	for nIndex = 1, #shenshouidlist do
		local nItemId = shenshouidlist[nIndex]
		local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId)
        if petAttrCfg then
		    local prefixName = "Chosepetdialog"..tostring(nIndex)
		    local layoutCell = winMgr:loadWindowLayout("choosechongwucell.layout", prefixName)

		    layoutCell:subscribeEvent("MouseClick", self.HandleSelectShenShou, self)
		    layoutCell.imageIcon = winMgr:getWindow(prefixName.."choosechongwucell/fazhen/")
		    layoutCell.labelName = winMgr:getWindow(prefixName.."choosechongwucell/text")
		    layoutCell.labelName:setText(petAttrCfg.name)
		    layoutCell.nItemId = nItemId

		    local s = layoutCell.imageIcon:getPixelSize()
		    local sprite = gGetGameUIManager():AddWindowSprite(layoutCell.imageIcon, petAttrCfg.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, true)
		    sprite:SetModel(petAttrCfg.modelid)
            sprite:SetDyePartIndex(0,petAttrCfg.area1colour)
            sprite:SetDyePartIndex(1,petAttrCfg.area2colour)
		    sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
		    sprite:PlayAction(eActionStand)

		    self.scrollPane:addChildWindow(layoutCell)
		    self.vCell[nIndex] = layoutCell

		    local nChildcount = layoutCell:getChildCount()
		    for i = 0, nChildcount - 1 do
			    local child = layoutCell:getChildAtIdx(i)
			    child:setMousePassThroughEnabled(true)
		    end

	        self:RefeshAllCellPos()
        end
	end
end

function Chosepetdialog:HandleSelectShenShou(e)
	LogInfo("Chosepetdialog.HandleSelectShenShou")

	local mouseArgs = CEGUI.toMouseEventArgs(e)
    local itemname = self.strItemName
	local npckey = self.nNpcKey 
	local needpetbaseid = mouseArgs.window.nItemId
	local mypetname = self.strMyPetName 
	local mypetinccount = self.nMyPetIncCount 
	local mypetkey = self.nMyPetKey 
	
    -- 0-兑换神兽 1-重置神兽
    if self.nFlag == 0 then
        require("logic.pet.shenshoucommon").DoDuiHuan(itemname, npckey, needpetbaseid)
    elseif self.nFlag == 1 then
        require("logic.pet.shenshoucommon").DoReset(itemname, npckey, needpetbaseid, mypetname, mypetinccount, mypetkey)
    end

	self:DestroyDialog()
end

return Chosepetdialog


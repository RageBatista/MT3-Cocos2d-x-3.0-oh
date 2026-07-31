require "logic.dialog"
require "utils.mhsdutils"
require "logic.tips.commontiphelper"

Equipcomparetipdlg = {}

setmetatable(Equipcomparetipdlg,Dialog)
Equipcomparetipdlg.__index = Equipcomparetipdlg
local _instance


function Equipcomparetipdlg:OnCreate()
	self.prefix = "Equipcomparetipdlg"
	Dialog.OnCreate(self,nil,self.prefix)
	self:InitUI()
end

function Equipcomparetipdlg.getInstance() 
	if not _instance then
		_instance = Equipcomparetipdlg.new()
		_instance:OnCreate()
	end
	return _instance
end

function Equipcomparetipdlg.getInstanceAndShow()
	if not _instance then
		_instance = Equipcomparetipdlg.new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
        

	end
	return _instance
end

function Equipcomparetipdlg.getInstanceNotCreate()
	return _instance
end

function Equipcomparetipdlg.DestroyDialog()
 	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Equipcomparetipdlg:OnClose()
	Dialog.OnClose(self)
end

function Equipcomparetipdlg.GetLayoutFileName()
	return "itemtips_mtg.layout"
end

function Equipcomparetipdlg.new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Equipcomparetipdlg)
	return self	
end

function Equipcomparetipdlg:InitUI()
	local prefix = self.prefix
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	local winbg = winMgr:getWindow(prefix.."itemtips_mtg")
	winbg:subscribeEvent("MouseClick", Equipcomparetipdlg.HandlClickBg, self) 
	
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefix.."itemtips_mtg/item"))
	self.labelName = winMgr:getWindow(prefix.."itemtips_mtg/names")
	self.labelType = winMgr:getWindow(prefix.."itemtips_mtg/leixingming")
	self.labelLevelTitle = winMgr:getWindow(prefix.."itemtips_mtg/pinzhi") 
	self.labelLevel = winMgr:getWindow(prefix.."itemtips_mtg/pinzhiming")
	
	self.richBox = CEGUI.toRichEditbox(winMgr:getWindow(prefix.."itemtips_mtg/editbox"))
	self.richBox:setReadOnly(true)
	self.richBox:setMousePassThroughEnabled(true)
	
	self.ScrollablePane = CEGUI.toRichEditbox(winMgr:getWindow(prefix.."itemtips_mtg/ScrollablePane"))
	self.nPaneHeightOld = self.ScrollablePane:getPixelSize().height
	local nWidth = self:GetMainFrame():getPixelSize().width
	self.nFrameHeightOld = self:GetMainFrame():getPixelSize().height
	self.nBoxHeightOld = self.richBox:getPixelSize().height
	
	self.btnLeft = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/btngengduo"))
    self.btnUse = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/btnshiyong"))
	self.btnComeFrom = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/btnshiyong1"))
	
	--self.btnDestroy:setVisible(false)
	--self.btnUse:setVisible(false)
	self.btnComeFrom:setVisible(false)
	
	--self.btnLeft:subscribeEvent("MouseButtonUp", Equipcomparetipdlg.HandlBtnClickLeft, self) 
	--self.btnUse:subscribeEvent("MouseButtonUp", Equipcomparetipdlg.HandlBtnClickRight, self) 
	--self.btnComeFrom:subscribeEvent("MouseButtonUp", Equipcomparetipdlg.HandlBtnClickComeFrom, self) 
	
	self.strUsezi = MHSD_UTILS.get_resstring(2668)
	self.strMorezi = MHSD_UTILS.get_resstring(11045)
	self.strBaiTanChuShouzi = MHSD_UTILS.get_resstring(11042)
	self.strZengSongzi = MHSD_UTILS.get_resstring(11043)
	self.strDiuQizi = MHSD_UTILS.get_resstring(11044)
	self.strGongNengzi = MHSD_UTILS.get_resstring(11032) 
	self.strYaoQiuzi = MHSD_UTILS.get_resstring(11033)
	self.strGongXiaozi = MHSD_UTILS.get_resstring(11038)
	self.strPinZhizi = MHSD_UTILS.get_resstring(11039)
	self.strShangHuizi = MHSD_UTILS.get_resstring(11046)
	self.strZuoBiaozi = MHSD_UTILS.get_resstring(11040)
	
	--self:ResetBtn()
	
	
	self.itemCell:setMousePassThroughEnabled(true)
	self.labelName:setMousePassThroughEnabled(true)
	self.labelType:setMousePassThroughEnabled(true)
	self.labelLevelTitle:setMousePassThroughEnabled(true)
	self.labelLevel:setMousePassThroughEnabled(true)
	self.richBox:setMousePassThroughEnabled(true)

    self.m_pMainFrame:setAlwaysOnTop(true)
    self.m_pMainFrame:activate()
	

    local defaultColor =  require("logic.tips.commontiphelper").defaultColor()
    self.richBox:SetColourRect(defaultColor);

    self.btnLeft:setVisible(false)
    self.btnComeFrom:setVisible(false)
    self.btnUse:setVisible(false)

    self.btnInfo = CEGUI.toPushButton(winMgr:getWindow(prefix.."itemtips_mtg/yulan"))
    --self.btnInfo:subscribeEvent("MouseButtonUp", Commontipdlg.HandlBtnClickInfo, self) 
    self.labelInfo = winMgr:getWindow(prefix.."itemtips_mtg/zhuangbeiyulan")

    self.btnInfo:setVisible(false)
    self.labelInfo:setVisible(false)

    self.imageHaveEquip = winMgr:getWindow(prefix.."itemtips_mtg/jiaobiao")
    self.imageHaveEquip:setVisible(true)

    self.richBox:SetLineSpace(5);
    
end

function Equipcomparetipdlg:HandlClickBg(e)
	Equipcomparetipdlg.DestroyDialog()
end

--//????¦Ë
function Equipcomparetipdlg:RefreshPosCorrect(nX,nY)
	local mainFrame = self:GetMainFrame()
	require "logic.tips.commontiphelper".RefreshPosCorrect(mainFrame,nX,nY)
end

--//
function Equipcomparetipdlg:RefreshSize(bHaveBtn)
	require "logic.tips.commontiphelper".RefreshSize(self,bHaveBtn)
end


function Equipcomparetipdlg:RefreshNormalInfo()
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
	if not itemAttrCfg then
		LogInfo("Equipcomparetipdlg:RefreshNormalInfo=error=self.nItemId"..self.nItemId)
		return
	end
	local itemTypeTable = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(itemAttrCfg.itemtypeid)
	if not itemTypeTable then
		LogInfo("Equipcomparetipdlg:RefreshNormalInfo=error=self.itemTypeTable"..itemTypeTable)
		return
	end
	local strLevelzi = MHSD_UTILS.get_resstring(1)
	
	self.itemCell:SetImage(gGetIconManager():GetImageByID(itemAttrCfg.icon))
    --local nBagId = 
    SetItemCellBoundColorByQulityItem(self.itemCell, itemAttrCfg.nquality)
    local nBagId = -1
    local nItemKey = -1

    if self.pObj then
        nBagId = self.pObj.loc.tableType
        nItemKey = self.pObj.data.key
    end
    refreshItemCellBind(self.itemCell,nBagId,nItemKey)
	 g_refreshItemCellEquipEndureFlag(self.itemCell,nBagId,nItemKey)

	self.labelName:setText(itemAttrCfg.name)
    if string.len(itemAttrCfg.colour) > 0 then
       
            local strNewName = "[colour=".."\'"..itemAttrCfg.colour.."\'".."]"..itemAttrCfg.name
            self.labelName:setText(strNewName)
    else
        local strNewName = "[colour=".."\'".."ffffffff".."\'".."]"..itemAttrCfg.name
            self.labelName:setText(strNewName)
    end

	self.labelType:setText(itemTypeTable.name)

	local nItemId = self.nItemId
	local pObj = self.pObj
	
	local strResult1,strResult2  = require("logic.tips.commontiphelper").getStringForBottomLabel(nItemId,pObj)
	self.labelLevelTitle:setText(strResult1)
	self.labelLevel:setText(strResult2)

    --_instance.m_pMainFrame:activate()
	
end


--//??????
function Equipcomparetipdlg:RefreshItem_normal()
	self.btnLeft:setVisible(false)
	self.btnUse:setVisible(false)
	self.btnComeFrom:setVisible(false)
	
	self:RefreshNormalInfo()
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
	if not itemAttrCfg then
		return
	end
	self.richBox:Clear()
	
	local nItemId = self.nItemId
	
	local pObj = self.pObj
	require("logic.tips.commontiphelper").RefreshRichBox(self.richBox,nItemId,pObj)
	
	--self.richBox:AppendText(CEGUI.String(itemAttrCfg.destribe) )
	--self.richBox:AppendBreak()
	--self.richBox:Refresh()
	
	local bHaveBtn = false
	self:RefreshSize(bHaveBtn)
	local nX = self.nCellPosX
	local nY = self.nCellPosY
	self:RefreshPosCorrect(nX,nY)
	self.richBox:HandleTop()
end


--[[
--//lua call
function Equipcomparetipdlg:RefreshItem(nType,nItemId,nCellPosX,nCellPosY) --1=huoqutujing 2=normal
--]]
function Equipcomparetipdlg:RefreshItem(nItemId,pObj,nCellPosX,nCellPosY) --??id????????id

	--self.nType = nType
	self.nItemId = nItemId
	self.pObj = pObj
	self.nCellPosX = nCellPosX
	self.nCellPosY = nCellPosY
	
	self:RefreshItem_normal() 
	
end


function Equipcomparetipdlg:RefreshItemWithObjectNormal(nItemId,pObj,nCellPosX,nCellPosY)
	self.nItemId = nItemId
	self.nCellPosX = nCellPosX
	self.nCellPosY = nCellPosY
	self.pObj = pObj
	
	self:RefreshNormalInfo()
	--self:RefreshRichBox(nItemId,pObj)
	require("logic.tips.commontiphelper").RefreshRichBox(self.richBox,nItemId,pObj)
end




--//pObj=nil  usebaseid use in  bag call
function Equipcomparetipdlg:RefreshItemWithObj(nItemId,pObj,nCellPosX,nCellPosY)
	self:RefreshItemWithObjectNormal(nItemId,pObj,nCellPosX,nCellPosY)
	local bHaveBtn = true
	self:RefreshSize(bHaveBtn)
	
	local mainFrame = self:GetMainFrame()
	local nX,nY = require("logic.tips.commontiphelper").getTipPosForBag(mainFrame)
	self:RefreshPosCorrect(nX,nY)
	--self:RefreshPosCorrect(nCellPosX,nCellPosY)
	
	return true
end

return Equipcomparetipdlg


require "logic.dialog"

Spaceseladdresslistdialog = {}
setmetatable(Spaceseladdresslistdialog, Dialog)
Spaceseladdresslistdialog.__index = Spaceseladdresslistdialog

Spaceseladdresslistdialog.eCallBackType = 
{
    clickAddress = 1
}

local _instance
function Spaceseladdresslistdialog.getInstanceAndShow()
	if not _instance then
		_instance = Spaceseladdresslistdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Spaceseladdresslistdialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spaceseladdresslistdialog:getInstanceNotCreate()
    return _instance
end


function Spaceseladdresslistdialog:clearData()
    self.nSelType = 0
    self.vAllCell = {}
    self.mapCallBack = {}
end

function Spaceseladdresslistdialog:clearAllCell()
    self.tableviewList:destroyCells()

   
end

function Spaceseladdresslistdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spaceseladdresslistdialog)
    self:clearData()
	return self
end

function Spaceseladdresslistdialog:OnClose()
    self:clearAllCell()
    self:clearData()
    Dialog.OnClose(self)
end

function Spaceseladdresslistdialog:OnCreate(parent)

    local strPrefix =  "Spaceseladdresslistdialog"
    Dialog.OnCreate(self,parent,strPrefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.nodeBg = winMgr:getWindow(strPrefix.."AddpointListDlg/back")
    self.scrollList = CEGUI.toScrollablePane(winMgr:getWindow(strPrefix.."AddpointListDlg/container"))

    local nWidth = self.nodeBg:getPixelSize().width

    local nHeight = 300
    self.nodeBg:setHeight(CEGUI.UDim(0,nHeight))
    self.scrollList:setHeight(CEGUI.UDim(0,nHeight))
    self:GetWindow():setHeight(CEGUI.UDim(0,nHeight))
    

    self:GetWindow():setProperty("AllowModalStateClick","true")
    --self:GetWindow():setAlwaysOnTop(true)

    self.nodeBg:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 1)))

    local layoutName = "addresscell.layout"
	local getWidthNode = winMgr:loadWindowLayout(layoutName,"getwidth")
    local nListWidth = getWidthNode:getPixelSize().width + 10
    CEGUI.WindowManager:getSingleton():destroyWindow(getWidthNode)

    self.nodeBg:setWidth(CEGUI.UDim(0,nListWidth+5))
    self.scrollList:setWidth(CEGUI.UDim(0,nListWidth))
    self:GetWindow():setWidth(CEGUI.UDim(0,nListWidth))

     local TableView = require "logic.tableview"
     local sizeBg = self.scrollList:getPixelSize()
     self.tableviewList = TableView.create(self.scrollList, TableView.VERTICAL)
     self.tableviewList:setViewSize(sizeBg.width, sizeBg.height-20)
     --self.tableviewList:setScrollContentSize(sizeBg.width, sizeBg.height)
     self.tableviewList:setPosition(0, 0)
     self.tableviewList:setDataSourceFunc(self, Spaceseladdresslistdialog.tableViewGetCellAtIndex)

end

function Spaceseladdresslistdialog:createOneCell(parent,nIndex)
     local cellDlg = require("logic.space.spacesetaddresscell").create(parent)
     cellDlg.btnAddress:subscribeEvent("MouseClick", Spaceseladdresslistdialog.clickAddress, self)
     return cellDlg
end

function Spaceseladdresslistdialog:tableViewGetCellAtIndex(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:createOneCell(tableView.container,nIndex )
    end
     local addressData = self.vAddressData[nIndex]
     local nId = addressData.nId
     local strName = addressData.strName
     cell:initInfo(nId,strName)
     cell.btnAddress:setID(nId)

    --cell:refreshOneCell(oneCellData)
    --self:refreshStateCell(cell,oneCellData)
    
    return cell
end

function Spaceseladdresslistdialog:setDelegate(pTarget,callBackType,callBack)
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end

function Spaceseladdresslistdialog:callEvent(eType,nParam)
    local callBackData =  self.mapCallBack[eType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self,nParam)
end

function Spaceseladdresslistdialog:initList(nSelType,vAddressData)
    self.nSelType = nSelType
    self.vAddressData = vAddressData
    local nAllCount = #vAddressData
    self.tableviewList:destroyCells()
    self.tableviewList:setCellCount(nAllCount)
    self.tableviewList:reloadData()

--[[
    self:clearAllCell()

    self.nSelType = nSelType
    for nIndex=1,#vAddressData do
        local addressData = vAddressData[nIndex]
        local nId = addressData.nId
        local strName = addressData.strName

        local cellDlg = require("logic.space.spacesetaddresscell").create(self.scrollList)
        cellDlg:initInfo(nId,strName)
        cellDlg.btnAddress:subscribeEvent("MouseClick", Spaceseladdresslistdialog.clickAddress, self)
        cellDlg.btnAddress:setID(nId)
        self.vAllCell[#self.vAllCell + 1] = cellDlg
    end
    self:refreshPosition()
    --]]
end

function Spaceseladdresslistdialog:clickAddress(args)
    local mouseArgs = CEGUI.toMouseEventArgs(args)
	local clickWin = mouseArgs.window
    local nId = clickWin:getID()
    self:callEvent(Spaceseladdresslistdialog.eCallBackType.clickAddress,nId)
end

function Spaceseladdresslistdialog:refreshPosition()
    for nIndex=1,#self.vAllCell do 
        local cellDlg = self.vAllCell[nIndex]
        
        local nHeight = cellDlg:GetWindow():getPixelSize().height
        local nPosY = nHeight * (nIndex-1)
        cellDlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, nPosY)))
    end

end

function Spaceseladdresslistdialog:GetLayoutFileName()
	return "addpointlistdlg.layout"
end

return Spaceseladdresslistdialog
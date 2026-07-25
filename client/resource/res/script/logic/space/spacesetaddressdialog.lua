
require "logic.dialog"

Spacesetaddressdialog = {}
setmetatable(Spacesetaddressdialog, Dialog)
Spacesetaddressdialog.__index = Spacesetaddressdialog

Spacesetaddressdialog.SelListType =
{
    province=1,
    country=2
}

local _instance
function Spacesetaddressdialog.getInstanceAndShow()
	if not _instance then
		_instance = Spacesetaddressdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Spacesetaddressdialog:getInstanceNotCreate()
    return _instance
end


function Spacesetaddressdialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spacesetaddressdialog:clearData()

    self.strPlace = "0"
    self.fLongitude = 0
    self.fLatitude = 0

    self.nCurProvinceId = 0
    self.nCurCountryId = 0

    self.bShowPro = false
    self.bShowCou = false
    self.selListDlg = nil
end

function Spacesetaddressdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacesetaddressdialog)
    self:clearData()
	return self
end

function Spacesetaddressdialog:OnClose()
 
    self:clearData()
    Dialog.OnClose(self)
end

function Spacesetaddressdialog:OnCreate(parent)
    Dialog.OnCreate(self,parent)

	local winMgr = CEGUI.WindowManager:getSingleton()
    
    
    self.labelLocation = winMgr:getWindow("address/where") 

    self.btnProvince =  CEGUI.toPushButton(winMgr:getWindow("address/sheng"))
    self.btnProvince:subscribeEvent("MouseClick", Spacesetaddressdialog.clickProvince, self)

    self.imageProFlag = winMgr:getWindow("address/sheng/down1") 
    self.imageCouFlag = winMgr:getWindow("address/down2") 

    self.btnCountry =  CEGUI.toPushButton(winMgr:getWindow("address/shi"))
    self.btnCountry:subscribeEvent("MouseClick", Spacesetaddressdialog.clickCountry, self)
    
    self.btnGetLocation =  CEGUI.toPushButton(winMgr:getWindow("address/auto"))
    self.btnGetLocation:subscribeEvent("MouseClick", Spacesetaddressdialog.clickGetLocation, self)

    self.btnCancel = CEGUI.toPushButton(winMgr:getWindow("address/di/quxiao")) 
    self.btnCancel:subscribeEvent("MouseClick", Spacesetaddressdialog.clickCancel, self)

    self.btnConfirm = CEGUI.toPushButton(winMgr:getWindow("address/di/queren"))
    self.btnConfirm:subscribeEvent("MouseClick", Spacesetaddressdialog.clickConfirm, self)

    local frameWnd = CEGUI.toFrameWindow(winMgr:getWindow("address"))
	local closeBtn = CEGUI.toPushButton(frameWnd:getCloseButton())
	closeBtn:subscribeEvent("MouseClick",Spacesetaddressdialog.clickClose,self)

    self:GetWindow():setRiseOnClickEnabled(false)

    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    local strLocation = roleSpaceInfoData.strLocation 
    if strLocation~="0" then
        self.labelLocation:setText(strLocation)
    end
    
end

function Spacesetaddressdialog:clickClose()
    Spacesetaddressdialog.DestroyDialog()
end


function Spacesetaddressdialog:clickProvince(args)
    self:showProvince(args)
end




function Spacesetaddressdialog:isCountryIdInProvince(nCouId,nProId)
     local addressTable = BeanConfigManager.getInstance():GetTableByName("common.caddressprovince"):getRecorder(nProId)
     if not addressTable then
        return false
    end
    local nCount = addressTable.vncountryid:size()
    for nIndex=0,nCount do 
        local nCountryId = addressTable.vncountryid[nIndex]
        if nCouId==nCountryId then
            return true
        end
    end
    return false
end

function Spacesetaddressdialog:getFirstCountryId(nProId)
    local addressTable = BeanConfigManager.getInstance():GetTableByName("common.caddressprovince"):getRecorder(nProId)
    if not addressTable then
        return 0
    end
    local nCount = addressTable.vncountryid:size()
    if nCount > 0 then
        return addressTable.vncountryid[0]
    end
    return 0
end

function Spacesetaddressdialog:getProvinceIdWithCountryId(nCountryId)
    local addressTable = BeanConfigManager.getInstance():GetTableByName("common.caddresscountry"):getRecorder(nCountryId)
    if not addressTable then
        return 0
    end
    return addressTable.nprovinceid
end




function Spacesetaddressdialog:clickAddress(listDlg,nId)
    local nSelType = listDlg.nSelType

    if nSelType== Spacesetaddressdialog.SelListType.province then
        self.nCurProvinceId = nId
        local bInPro = self:isCountryIdInProvince(self.nCurCountryId,self.nCurProvinceId)
        if bInPro then
        else
            local nFirstCountryId = self:getFirstCountryId(self.nCurProvinceId)
            self.nCurCountryId = nFirstCountryId
        end
    else
        self.nCurCountryId = nId
        local bInPro = self:isCountryIdInProvince(self.nCurCountryId,self.nCurProvinceId)
        if bInPro then
        else
            self.nCurProvinceId = self:getProvinceIdWithCountryId(self.nCurCountryId)
        end
    end

    self:refreshAddressTitle()

end

function Spacesetaddressdialog:refreshAddressTitle()
    
    local proTable = BeanConfigManager.getInstance():GetTableByName("common.caddressprovince"):getRecorder(self.nCurProvinceId)
    if not proTable then
         return
    end

    local couTable = BeanConfigManager.getInstance():GetTableByName("common.caddresscountry"):getRecorder(self.nCurCountryId)
    if not couTable then
        return
    end

    self.btnProvince:setText(proTable.strprovince)
    self.btnCountry:setText(couTable.strcountry)

    if self.nCurProvinceId==0 and self.nCurCountryId ==0 then
        self.labelLocation:setText("")
        self.strPlace = "0"
    else
        local strLocation = proTable.strprovince
        if self.nCurCountryId ==0 then
             strLocation = proTable.strprovince
        else
            local bSelfPro = self:isSelfPro(self.nCurProvinceId)

            if bSelfPro then
                strLocation = proTable.strprovince
            else
                strLocation = proTable.strprovince..couTable.strcountry
            end
             
        end
        self.labelLocation:setText(strLocation)
        self.strPlace = strLocation
    end


    
end

function Spacesetaddressdialog:isSelfPro(nProId)
    if nProId == 1 or 
    nProId==3 or
    nProId==9 or
    nProId==22 then
        return true
    end
    return false
end

function Spacesetaddressdialog:clickCountry(args)
    self:showCoutry(args)
end

function Spacesetaddressdialog:refreshProFlag(bShowCou)
    if bShowCou then
        self.imageProFlag:setProperty("Image","set:common image:up")
    else
       self.imageProFlag:setProperty("Image","set:common image:dowm")
    end
end


function Spacesetaddressdialog:refreshCouFlag(bShowPro)
    if bShowPro then
        self.imageCouFlag:setProperty("Image","set:common image:up")
    else
       self.imageCouFlag:setProperty("Image","set:common image:dowm")
    end
end

function Spacesetaddressdialog:showProvince(args)

    local mouseArgs = CEGUI.toMouseEventArgs(args)
	local clickWin = mouseArgs.window

    if self.selListDlg then
        self.selListDlg.DestroyDialog()
        self.selListDlg = nil
    end
        
    local vAllId = BeanConfigManager.getInstance():GetTableByName("common.caddressprovince"):getAllID()

    local vAddressData = {}
    for nIndex=1,#vAllId do
        local nId = vAllId[nIndex]
        vAddressData[nIndex] = {}
        vAddressData[nIndex].nId = nId

        local addressTable = BeanConfigManager.getInstance():GetTableByName("common.caddressprovince"):getRecorder(nId)
        vAddressData[nIndex].strName = addressTable.strprovince
    end

    self.selListDlg = require("logic.space.spaceseladdresslistdialog").getInstanceAndShow()
    self.selListDlg:initList(Spacesetaddressdialog.SelListType.province,vAddressData)

    local Spaceseladdresslistdialog = require("logic.space.spaceseladdresslistdialog")
    self.selListDlg:setDelegate(self,Spaceseladdresslistdialog.eCallBackType.clickAddress ,Spacesetaddressdialog.clickAddress)

    self:refreshListPos(clickWin)
end

function Spacesetaddressdialog:showCoutry(args)
    local mouseArgs = CEGUI.toMouseEventArgs(args)
	local clickWin = mouseArgs.window


    if self.selListDlg then
        self.selListDlg.DestroyDialog()
        self.selListDlg = nil
        
    end

    local proTable = BeanConfigManager.getInstance():GetTableByName("common.caddressprovince"):getRecorder(self.nCurProvinceId)
    local vAllId = {}
    local bAddFirst = false
    if self.nCurProvinceId==0 or not  proTable then
         vAllIdTable = BeanConfigManager.getInstance():GetTableByName("common.caddresscountry"):getAllID()
         for nIndex=1,#vAllIdTable do
            vAllId[nIndex] = vAllIdTable[nIndex]
         end
    else
        for ncIndex=0,proTable.vncountryid:size() do
            vAllId[ncIndex+1] = proTable.vncountryid[ncIndex]
        end
        bAddFirst = true
    end
    
    if bAddFirst then
        table.insert(vAllId,1,0)
    end

    local vAddressData = {}
    for nIndex=1,#vAllId do
        local nId = vAllId[nIndex]
        vAddressData[nIndex] = {}
        vAddressData[nIndex].nId = nId

        local addressTable = BeanConfigManager.getInstance():GetTableByName("common.caddresscountry"):getRecorder(nId)

        vAddressData[nIndex].strName = addressTable.strcountry
    end

    self.selListDlg = require("logic.space.spaceseladdresslistdialog").getInstanceAndShow()
    self.selListDlg:initList(  Spacesetaddressdialog.SelListType.country,vAddressData)
    self.selListDlg:setDelegate(self,Spaceseladdresslistdialog.eCallBackType.clickAddress ,Spacesetaddressdialog.clickAddress)

    self:refreshListPos(clickWin)

end

function Spacesetaddressdialog:refreshListPos(btnNode)
    local pos = btnNode:GetScreenPos()

    local nPosX = pos.x
    local nPosY = pos.y
    local nBtnHeight = btnNode:getPixelSize().height
    --local nHeight = btnNode:getSize()

    self.selListDlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, nPosX), CEGUI.UDim(0, nPosY+nBtnHeight+10)))
end


function Spacesetaddressdialog:clickCancel(args)
    Spacesetaddressdialog.DestroyDialog()
end

function Spacesetaddressdialog:clickGetLocation()
    LocationDetector:GetInstance():setFinishCallbackFunction("Spacemanager_OnGetLocation")
    LocationDetector:GetInstance():startDetect()
    
end

function Spacesetaddressdialog:getLocationCallBack(strPlace,fLongitude,fLatitude)
    
    --strPlace = require("utils.mhsdutils").get_resstring(11019)
    --strPlace = "ºÓ±± . µ¯É¾µô . ÓêÌì"
    --[[
    strPlace = string.gsub(strPlace,".","_")

    local nPos =  string.find(strPlace,"_")
    if nPos then
        local strFirst = string.sub(strPlace,1,nPos)
        local nLength = string.len(strPlace)
        strPlace = string.sub(strPlace,nPos+1,nLength)
        local strSecond = strPlace
        local nPos2 = string.find(strPlace,"_")
        if nPos2 then
            strSecond = string.sub(strPlace,1,nPos2)
        end
        strPlace = strFirst..strSecond
    end
    --]]


    local vParts = StringBuilder.Split( strPlace, " . ")

    if #vParts > 2 then
        strPlace = vParts[1]
        strPlace = strPlace..vParts[2]
   end
    
    self.strPlace = strPlace
    self.fLongitude = fLongitude
    self.fLatitude = fLatitude

    self.nCurCountryId = 0
    self.nCurProvinceId = 0

    self.labelLocation:setText(strPlace)
end


function Spacesetaddressdialog:clickConfirm(args)
    local strPlace = self.strPlace
    local fLongitude = self.fLongitude
    local fLatitude = self.fLatitude

    

    local nnMyRoleId =  getSpaceManager():getMyRoleId()
    require("logic.space.spacepro.spaceprotocol_setLocation").request(nnMyRoleId,strPlace,fLongitude,fLatitude)

    Spacesetaddressdialog.DestroyDialog()
end


function Spacesetaddressdialog:GetLayoutFileName()
	return "address1.layout"
end


return Spacesetaddressdialog
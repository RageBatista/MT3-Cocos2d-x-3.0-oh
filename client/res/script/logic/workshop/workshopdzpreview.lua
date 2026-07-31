require "utils.mhsdutils"
require "logic.dialog"

require "logic.workshop.workshopdzpreviewcell"


Workshopdzpreview = {}
setmetatable(Workshopdzpreview, Dialog)
Workshopdzpreview.__index = Workshopdzpreview

------------------- public: -----------------------------------
local _instance;


function Workshopdzpreview:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ItemCell = CEGUI.toItemCell(winMgr:getWindow("workshopdzpreview/bg/item"))
	self.ImageItem = winMgr:getWindow("workshopdzpreview/bg/item")
	self.LabName = winMgr:getWindow("workshopdzpreview/bg/name")
	self.LabTypeName = winMgr:getWindow("workshopdzpreview/bg/mingcheng")
	--self.BtnMake = CEGUI.toPushButton(winMgr:getWindow("workshopdzpreview/bg/putongdazao"))
	--self.BtnMake:subscribeEvent("MouseClick", Workshopdzpreview.HandlMakeBtnClicked, self)
	--self.BtnMakeQh = CEGUI.toPushButton(winMgr:getWindow("workshopdzpreview/bg/qianghuadazao"))
	--self.BtnMakeQh:subscribeEvent("MouseClick", Workshopdzpreview.HandlMakeQhBtnClicked, self)

	local frameWnd=CEGUI.toFrameWindow(winMgr:getWindow("workshopdzpreview"))
	local closeBtn=CEGUI.toPushButton(frameWnd:getCloseButton())
	closeBtn:subscribeEvent("MouseClick",Workshopdzpreview.HandleQuitClick,self)
	
	--preview/bg/diban/list
	self.ScrollProperty = CEGUI.toScrollablePane(winMgr:getWindow("preview/bg/diban/list"))
	--self.ScrollProperty:setMousePassThroughEnabled(true)
	
end

function Workshopdzpreview:GetMinAndMax(vMin,vMax)
	local nMinNum = vMin:size()
	local nMaxNum = vMax:size()
	local nMin = 0
	local nMax = 0
	if nMinNum>0 then
		nMin = vMin[0]
	end
	if nMaxNum>0 then
		nMax = vMax[nMaxNum-1]
	end
	return nMin,nMax
end

function Workshopdzpreview:GetPropertyStrData(nEquipId,vCellData)
	local eauipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not eauipAttrCfg then
		return
	end
	local nbaseAttrId = eauipAttrCfg.baseAttrId
	local eauipAddAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipiteminfo"):getRecorder(nbaseAttrId)
	if eauipAddAttrCfg.id == -1 then
		return
	end

	local vAllId = {}
	vAllId[#vAllId+1] = {}
	vAllId[#vAllId].nId = eauipAddAttrCfg.shuxing1id
	vAllId[#vAllId].vMin = eauipAddAttrCfg.shuxing1bodongduanmin
	vAllId[#vAllId].vMax = eauipAddAttrCfg.shuxing1bodongduanmax
	vAllId[#vAllId+1] = {}
	vAllId[#vAllId].nId = eauipAddAttrCfg.shuxing2id
	vAllId[#vAllId].vMin = eauipAddAttrCfg.shuxing2bodongduanmin
	vAllId[#vAllId].vMax = eauipAddAttrCfg.shuxing2bodongduanmax
	vAllId[#vAllId+1] = {}
	vAllId[#vAllId].nId = eauipAddAttrCfg.shuxing3id
	vAllId[#vAllId].vMin = eauipAddAttrCfg.shuxing3bodongduanmin
	vAllId[#vAllId].vMax = eauipAddAttrCfg.shuxing3bodongduanmax
	local strBolangzi = MHSD_UTILS.get_resstring(11001)
	for nIndex=1,#vAllId do 
		local objPropertyData = vAllId[nIndex]
		local nPropertyId = objPropertyData.nId
		local nTypeNameId = math.floor(nPropertyId/10)
		nTypeNameId = nTypeNameId *10
		nPropertyId = nTypeNameId
        local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
		if propertyCfg and propertyCfg.id ~= -1 then
			local strPropertyName = propertyCfg.name
			if strPropertyName==nil then
				strPropertyName = "empty"
			end
			local nMin,nMax = self:GetMinAndMax(objPropertyData.vMin,objPropertyData.vMax)
			vCellData[#vCellData +1] = {}
			vCellData[#vCellData].strPropertyName = strPropertyName
			vCellData[#vCellData].strAddValue =  "+"..nMin..strBolangzi..nMax
		end
	end

end


function Workshopdzpreview:RefreshEquip(nEquipId,nMakeType)
	self.ScrollProperty:cleanupNonAutoChildren()

	local equipMakeInfoCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getRecorder(nEquipId)
	if not equipMakeInfoCfg or equipMakeInfoCfg.id == -1 then
		return 
	end
	local nEquipId2 = equipMakeInfoCfg.chanchuequipid
	--//======================
	local itemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nEquipId)
	if not itemCfg then
		return
	end
    -----------------------------------
    self:ClearAllCell()
	self.vAllCell = {}
    local nIconId = itemCfg.icon
	local iconManager  = gGetIconManager()
	self.ItemCell:SetImage(iconManager:GetItemIconByID(nIconId))
	self.LabName:setText(itemCfg.effectdes)
	local nEquipType = itemCfg.itemtypeid
	local strTypeName = ""
	local itemTypeCfg = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nEquipType)
	if itemTypeCfg then
		strTypeName = itemTypeCfg.name
	end
	
	self.LabTypeName:setText(strTypeName)	

    -----------------------------------
    local vCellDataAll = {}
    local vTargetItemId = {}
    local vTargetItemPercent = {}
   
    local wsManager = Workshopmanager.getInstance()
    wsManager:getMakeTarget(vTargetItemId,vTargetItemPercent,equipMakeInfoCfg,nMakeType)
    for nIndex=1,#vTargetItemId do 
        local nEquipId = vTargetItemId[nIndex]

        local vCellData1 = {}
	    self:GetPropertyStrData(nEquipId,vCellData1)

        vCellDataAll[#vCellDataAll + 1] = vCellData1
    end

	--local vCellData1 = {}
	--self:GetPropertyStrData(nEquipId,vCellData1)
	--local vCellData2 = {}
	--self:GetPropertyStrData(nEquipId2,vCellData2)
	
		
    if #vCellDataAll == 0 then
        return
    end

    local vCellData1 = vCellDataAll[1]
    --local nPropertyNum = vCellDataAll[1]
	self.ScrollProperty:cleanupNonAutoChildren()

	for nIndexProperty=1,#vCellData1 do 
		local strPropertyName  = vCellData1[nIndexProperty].strPropertyName
		local strAddValue1 = vCellData1[nIndexProperty].strAddValue

		local strAddValue2 = ""
        local vCellData2 = vCellDataAll[2]
        if  vCellData2 ~= nil and 
            nIndexProperty <= #vCellData2
         then
            strAddValue2 = vCellData2[nIndexProperty].strAddValue
        end 
        ---------------------------
        local strAddValue3 = ""
        local vCellData3 = vCellDataAll[3]
        if  vCellData3 ~= nil and 
            nIndexProperty <= #vCellData3
         then
            strAddValue3 = vCellData3[nIndexProperty].strAddValue
        end 
        ---------------------------
		
		local prefix = "Workshopdzpreview"..nIndexProperty
		local cellPreview = Workshopdzpreviewcell.new(self.ScrollProperty,nIndexProperty-1,prefix)		
		cellPreview:RefreshProperty(strPropertyName,strAddValue1,strAddValue2,strAddValue3)	
		
		self.vAllCell[#self.vAllCell + 1] = cellPreview
	end 
end



function Workshopdzpreview:HandlMakeBtnClicked(e)
	--[[
	local dzDlg = require "logic.workshop.workshopdznew"
    dzDlg.OnMakeEquip(0) --0=normal 1=qiangha
	--]]
	local dzDlg = require "logic.workshop.workshopdznew".getInstanceOrNot()
	if dzDlg then 
		dzDlg:OnMakeEquip(0)
	end
end

function Workshopdzpreview:HandlMakeQhBtnClicked(e)
	--[[
	local dzDlg = require "logic.workshop.workshopdznew"
	dzDlg.OnMakeEquip(1) --0=normal 1=qiangha
	--]]
	local dzDlg = require "logic.workshop.workshopdznew".getInstanceOrNot()
	if dzDlg then 
		dzDlg:OnMakeEquip(1)
	end
end

function Workshopdzpreview:HandleQuitClick(e)
	self:OnClose()
end

function Workshopdzpreview:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Workshopdzpreview)
	
	self.vAllCell = {}
    return self
end

--//==========================================
function Workshopdzpreview.getInstance()
    if not _instance then
        _instance = Workshopdzpreview:new()
        _instance:OnCreate()
    end
    return _instance
end

function Workshopdzpreview.getInstanceOrNot()
	return _instance
end
	
function Workshopdzpreview.getInstanceAndShow()
    if not _instance then
        _instance = Workshopdzpreview:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Workshopdzpreview.getInstanceNotCreate()
    return _instance
end

function Workshopdzpreview:DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function Workshopdzpreview.ToggleOpenClose()
	self:OnClose()
end

function Workshopdzpreview:ClearAllCell()
	for k,v in pairs(self.vAllCell) do 
		v:DestroyDialog()
	end
	self.vAllCell = nil
end

function Workshopdzpreview:OnClose()
	self:ClearAllCell()
	Dialog.OnClose(self)
	_instance = nil
end

function Workshopdzpreview.GetLayoutFileName()
   return "workshopdzpreview.layout"
end

return Workshopdzpreview

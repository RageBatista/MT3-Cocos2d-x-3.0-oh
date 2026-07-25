require "utils.mhsdutils"
require "logic.dialog"



Equipinfotips = {}
setmetatable(Equipinfotips, Dialog)
Equipinfotips.__index = Equipinfotips
local _instance;

function Equipinfotips:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Equipinfotips)
	self:ClearData()
    return self
end


function Equipinfotips:ClearData()
	self.vCellCome = {}
	self.nItemId = -1
end


function Equipinfotips:HandleCellClicked(args)
end

function Equipinfotips:clickBgClose(args)
    Equipinfotips.DestroyDialog()
end

function Equipinfotips:OnCreate()
    Dialog.OnCreate(self)
	--SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	--self.scrollPane = CEGUI.toScrollablePane(winMgr:getWindow("zhuangbeixiangqing/liebiao"))
	self:GetWindow():subscribeEvent("MouseClick", Equipinfotips.clickBgClose, self) 

	self.richBox = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeixiangqing/liebiao"))
	--self.richBox:setReadOnly(true)
	
	self.richBox1 = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeixiangqing/liebiao1"))
	self.richBox1:setReadOnly(true)
	
	local nWidth = self:GetMainFrame():getPixelSize().width
	self.nFrameHeightOld = self:GetMainFrame():getPixelSize().height
	self.nBoxHeightOld = self.richBox:getPixelSize().height
	
	self:GetMainFrame():setAlwaysOnTop(true)--��󣬴������鿴װ����Ϣʱ���ö�

    local defaultColor =  require("logic.tips.commontiphelper").defaultColor()
    self.richBox:SetColourRect(defaultColor);
    self.richBox1:SetColourRect(defaultColor);

    self.richBox:SetLineSpace(5);
    self.richBox1:SetLineSpace(5);

end



function Equipinfotips:GetMinAndMax(vMin,vMax)
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

function Equipinfotips:GetPropertyStrData(nEquipId,vCellData)
	LogInfo("Equipinfotips:GetPropertyStrData(nEquipId,vCellData)")
	local eauipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not eauipAttrCfg then
		return
	end
	local nbaseAttrId = eauipAttrCfg.baseAttrId
	local eauipAddAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipiteminfo"):getRecorder(nbaseAttrId)
	if not eauipAddAttrCfg or eauipAddAttrCfg.id == -1 then
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
			vCellData[#vCellData].nPropertyId = nPropertyId
			vCellData[#vCellData].strPropertyName = strPropertyName
			vCellData[#vCellData].strAddValue =  nMin..strBolangzi..nMax
			
		end
	end

end

function Equipinfotips:GetAddRangeString(vCellData,nPropertyId)
	for nIndex=1,#vCellData do 
		local obj = vCellData[nIndex]
		if nPropertyId==obj.nPropertyId then
			local strAddRange = obj.strAddValue
			return strAddRange
		end
	end
	return nil
end

function Equipinfotips.ShowEquipInfo(eBagType,nEquipKey)
	
	LogInfo("Equipinfotips.ShowEquipInfo(eBagType,nEquipKey)")
	if not _instance then 
		_instance = Equipinfotips.getInstance()
	end
	_instance:SetVisible(true)
	_instance:RefreshWithItemId(eBagType,nEquipKey)
	
end

function Equipinfotips:RefreshSize()
    local nExtenHeight = self.richBox:GetExtendSize().height
	local nAddHeight = nExtenHeight - self.nBoxHeightOld
    nAddHeight = nAddHeight > 0 and nAddHeight or 0
	nAddHeight = nAddHeight + 5
	
	local nOldtitleHeight = self.nFrameHeightOld - self.nBoxHeightOld
	LogInfo("self.nFrameHeightOld="..self.nFrameHeightOld)
	LogInfo("self.nBoxHeightOld="..self.nBoxHeightOld)
	
	LogInfo("nExtenHeight="..nExtenHeight)
	LogInfo("nAddHeight="..nAddHeight)
	
    local nWidth = self:GetMainFrame():getPixelSize().width
	local nBoxWidth = nWidth -40
	self.richBox:setSize(CEGUI.UVector2(
		CEGUI.UDim(0, nBoxWidth), 
		CEGUI.UDim(0, self.nBoxHeightOld + nAddHeight)))
	
	local nNewFrameHeight = self.nFrameHeightOld+nAddHeight
    self:GetMainFrame():setSize(CEGUI.UVector2(CEGUI.UDim(0, nWidth), CEGUI.UDim(0,nNewFrameHeight)))
end

function Equipinfotips:RefreshPosition(nPosX,nPosY)
	self:GetMainFrame():setPosition(CEGUI.UVector2(CEGUI.UDim(0, nPosX), CEGUI.UDim(0, nPosY)))
end

function Equipinfotips:GetSpaceCorrect(strLeftString)
	local nLen = string.len(strLeftString)
	local nAllLen = 20
	local nNeedSpace = nAllLen - nLen
	if nNeedSpace< 0 then
		nNeedSpace =0
	end
	local strSpaceAll = ""
	for nIndex=1,nNeedSpace do
		strSpaceAll = strSpaceAll.." "
	end
	return strSpaceAll
end

function Equipinfotips:RefreshWithId(nEquipId)
    self.richBox:Clear()
	self.richBox:HandleTop()
	self.richBox:show()

	self.richBox1:Clear()
	self.richBox1:show()

    local strSpace1 = " "
	local strSpace2 = "     "
	local strTitleColor = "ff60ff00" -- "ff29bbf7"
	local strNormalColor = "ff60ff00"
	
	local vCellData = {}
    require("logic.tips.equiptipmaker").GetPropertyStrData(nEquipId,vCellData)
	--self:GetPropertyStrData(nEquipId,vCellData)

	--local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vCellData do
        local onePeoData = vCellData[nIndex]
	    local strPropertyName = onePeoData.strPropertyName
		local strLabelAll = strPropertyName..strSpace1
		strLabelAll = strPropertyName..strSpace1..onePeoData.strAddValue
		self.richBox:AppendText(CEGUI.String(strLabelAll), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		self.richBox:AppendBreak()
	end
    self.richBox1:Refresh()
	self.richBox1:HandleTop()
	self.richBox:Refresh()
	self.richBox:HandleTop()

end

function Equipinfotips:RefreshWithObj(nEquipId,pObj)
    if not pObj then
        self:RefreshWithId(nEquipId)
        return
    end

    local equipObj = pObj

    self.richBox:Clear()
	self.richBox:HandleTop()
	self.richBox:show()

	self.richBox1:Clear()
	self.richBox1:show()

    local strSpace1 = " "
	local strSpace2 = "     "
	local strTitleColor = "ff6ddcf6" -- "ff29bbf7"
	local strNormalColor = "fffff2df"
	local strNormal1Color = "ffffff00"
	
	local vCellData = {}
	self:GetPropertyStrData(nEquipId,vCellData)
	
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
        local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		if nBaseValue~=0 then
			local strPropertyName = propertyCfg.name
			local strValue = "+"..nBaseValue
			local strLabelAll = strPropertyName..strSpace1
			strLabelAll = strLabelAll..strValue
			--local strNeedApace = self:GetSpaceCorrect(strLabelAll)
			--strLabelAll = strLabelAll..strNeedApace
			local strAddRange = self:GetAddRangeString(vCellData,nBaseId)
			if strAddRange then
				--strLabelAll = strLabelAll..strAddRange
				self.richBox1:AppendText(CEGUI.String(strAddRange), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
				self.richBox1:AppendBreak()
			else
				self.richBox:AppendText(CEGUI.String(""))
				self.richBox:AppendBreak()
				
			end
			self.richBox:AppendText(CEGUI.String(strLabelAll), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
			self.richBox:AppendBreak()
			
		end
	end
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local nNewTejiId = equipObj.newskilleffect----装备详情
	local equipsit = equipObj.equipsit
	local nNewTexiaoId = equipObj.newskillid 
	

	
	---器灵属性
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nNewTejiId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11807) 
		local strTexiaozi = ""..strTexiaozi
		self.richBox:AppendText(CEGUI.String(""))
		self.richBox:AppendBreak()
		
		self.richBox:AppendText(CEGUI.String(strTexiaozi), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormal1Color)))
		self.richBox:AppendBreak()
	end
	
	--器灵属性1
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nNewTejiId)----器灵属性：读取的是表格：装备附魔指定特技特效库 名称1
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11807) 
	    local strTexiaoName = texiaoPropertyCfg.name1
		self.richBox:AppendText(CEGUI.String(""))
			
		self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		self.richBox:AppendBreak()
	end
	--器灵属性2
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nNewTejiId)----器灵属性：读取的是表格：装备附魔指定特技特效库 名称2
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11807) 
	    local strTexiaoName = texiaoPropertyCfg.name2
		self.richBox:AppendText(CEGUI.String(""))
			
		self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		self.richBox:AppendBreak()
	end
	--器灵属性3
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nNewTejiId)----器灵属性：读取的是表格：装备附魔指定特技特效库 名称3
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11807) 
	    local strTexiaoName = texiaoPropertyCfg.name3
		self.richBox:AppendText(CEGUI.String(""))
			
		self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		self.richBox:AppendBreak()
	end
	
	
	
			---已镶嵌器灵：
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nNewTejiId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11813) 
		local strTexiaoName = "器灵•"..texiaoPropertyCfg.name
		local strTexiaozi = "镶嵌："..strTexiaozi
		self.richBox:AppendText(CEGUI.String(""))
		
		self.richBox:AppendText(CEGUI.String(strTexiaozi), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strTitleColor)))
		self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strTitleColor)))
		self.richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("ql"))
		self.richBox:AppendBreak()
	end
	
		

	
	  ----器灵套装
	local equipsitPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipsit"):getRecorder(equipsit)
	if equipsitPropertyCfg and equipsitPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11822) 
		local strTexiaozi = ""..strTexiaozi
		local strTexiaoName = ""..equipsitPropertyCfg.name
		self.richBox:AppendText(CEGUI.String(""))
		
		self.richBox:AppendText(CEGUI.String(strTexiaozi), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strTitleColor)))
		self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strTitleColor)))
		self.richBox:AppendBreak()
	end
	  ---套装介绍
	local equipsitPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipsit"):getRecorder(equipsit)
	if equipsitPropertyCfg and equipsitPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11823) 
		local strTexiaozi = ""..strTexiaozi
		local strTexiaoName = ""..equipsitPropertyCfg.tips
		self.richBox:AppendText(CEGUI.String(""))
		
		
		self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		self.richBox:AppendText(CEGUI.String(strTexiaozi), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		self.richBox:AppendBreak()
		self.richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("tipsfg"))
	end
	

	
	
	  ---特效
    local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11003) 
		local strTexiaoName = texiaoPropertyCfg.name
		local strTeXiaoDes = texiaoPropertyCfg.describe
		self.richBox:AppendText(CEGUI.String(""))
		self.richBox:AppendBreak()
			
		self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strTitleColor)))
		self.richBox:AppendBreak()
		self.richBox:AppendParseText(CEGUI.String(strTeXiaoDes))
		--self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		self.richBox:AppendBreak()
	end
	
	  ---特效
    local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(nNewTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11003) 
		local strTexiaoName = texiaoPropertyCfg.name
		local strTeXiaoDes = texiaoPropertyCfg.describe
		self.richBox:AppendText(CEGUI.String(""))
		self.richBox:AppendBreak()
			
		self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strTitleColor)))
		self.richBox:AppendBreak()
		self.richBox:AppendParseText(CEGUI.String(strTeXiaoDes))
		--self.richBox:AppendText(CEGUI.String(strTexiaoName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		self.richBox:AppendBreak()
	end
	
	
    ----特技
	--CEquipSkill
	--GetCEquipSkillInfoTableInstance
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(nTejiId)
	if tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11002)
		local strTjiName = tejiPropertyCfg.name
		local strTeJiDes = tejiPropertyCfg.describe
		self.richBox:AppendText(CEGUI.String(""))
		self.richBox:AppendBreak()
		self.richBox:AppendText(CEGUI.String(strTjiName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strTitleColor)))
		self.richBox:AppendBreak()
		self.richBox:AppendParseText(CEGUI.String(strTeJiDes))
        self.richBox:AppendBreak()
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tejiPropertyCfg.costnum)
        local content = strbuilder:GetString(tejiPropertyCfg.cost)
        strbuilder:delete()
		self.richBox:AppendText(CEGUI.String(content), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		--self.richBox:AppendText(CEGUI.String(strTjiName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(strNormalColor)))
		self.richBox:AppendBreak()
	end
	
	
	
	

	
	
	
	self.richBox1:Refresh()
	self.richBox1:HandleTop()
	
	self.richBox:Refresh()
	--self:RefreshPosition()
	self.richBox:HandleTop()
end



function Equipinfotips:RefreshWithItem(roleItem)

	local nEquipId = roleItem:GetBaseObject().id
    local pObj = roleItem:GetObject()
    self:RefreshWithObj(nEquipId,pObj)
end

function Equipinfotips:RefreshWithItemId(eBagType,nEquipKey)

	LogInfo("Equipinfotips:RefreshWithItemId(eBagType,nEquipKey")
	LogInfo("eBagType="..eBagType)
	LogInfo("nEquipKey="..nEquipKey)
	--self.scrollPane:cleanupNonAutoChildren()
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local roleItem = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if not roleItem then
		LogInfo("error=nEquipKey="..nEquipKey)
		return
	end
    self:RefreshWithItem(roleItem)
	
end

function Equipinfotips.getInstance()
    if not _instance then
        _instance = Equipinfotips:new()
        _instance:OnCreate()
    end
    return _instance
end

function Equipinfotips.getInstanceAndShow()
    if not _instance then
        _instance = Equipinfotips:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end


function Equipinfotips.getInstanceNotCreate()
    return _instance
end

function Equipinfotips.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end


function Equipinfotips:OnClose()
    self:ClearData()
	Dialog.OnClose(self)
	_instance = nil
end

function Equipinfotips.getInstanceOrNot()
	return _instance
end

function Equipinfotips.GetLayoutFileName()
    return "zhuangbeixiangqing.layout"
end

return Equipinfotips



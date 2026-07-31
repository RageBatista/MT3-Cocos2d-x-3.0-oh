require "logic.label"
require "utils.mhsdutils"


Workshopmanager = {}
Workshopmanager.__index = Workshopmanager
local _instance

----进阶限制文件
function Workshopmanager:new()
    local self = {}
    setmetatable(self, Workshopmanager)
	self:ClearData()
    return self
end

function Workshopmanager:ClearData()
	self.vLevelEquipId = {}
	self.nDzPage = 1
	self.nXqPage = 1
	self.nShowNumInPage =7
	self.nXlPage = 1
	self.naqPage = 1


	self.vEquipKeyOrder = {}
	self.nShowType = 1
    self.nSelQh = -1
    self.nNotTishi = -1
	
    local Commontiphelper = require("logic.tips.commontiphelper")
    local nFirstWeight = 10
    self.mapBuWeiWeight = {}
    self.mapBuWeiWeight[eEquipType_TIRE] = nFirstWeight
    nFirstWeight =  nFirstWeight -1
    self.mapBuWeiWeight[eEquipType_ADORN] = nFirstWeight
    nFirstWeight =  nFirstWeight -1
    self.mapBuWeiWeight[eEquipType_ARMS] = nFirstWeight
    nFirstWeight =  nFirstWeight -1
    self.mapBuWeiWeight[eEquipType_LORICAE] = nFirstWeight
    nFirstWeight =  nFirstWeight -1
    self.mapBuWeiWeight[eEquipType_WAISTBAND] = nFirstWeight
    nFirstWeight =  nFirstWeight -1
    self.mapBuWeiWeight[eEquipType_BOOT] = nFirstWeight

    self.nEquipIdInDzSel = -1

    self.nOffsetDz = 0
end

function Workshopmanager.Destroy()
    if _instance then 
		_instance:ClearData()
        _instance = nil
    end
end

function Workshopmanager.getInstance()
	if not _instance then
		_instance = Workshopmanager:new()
	end
	return _instance
end


--//==================================
function Workshopmanager:SetDzPage(nPage)
	self.nDzPage = nPage
end

--//==================================
--//ȡ����װ��id ĳҳ
function Workshopmanager:GetEquipIdWithPage(nLevelArea,vEquipId,nDzPage)
	local nBeginIndex = (nDzPage-1) * self.nShowNumInPage +1
	local nEndIndex = nDzPage * self.nShowNumInPage
	--local vEquipIdAll = self:GetEquipIdArrayWithLevel(nLevelArea)
	local vEquipIdAll = {}
	self:getEquipIdWithLevel(nLevelArea,vEquipIdAll)
	local nMaxIndex = #vEquipIdAll
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipId[#vEquipId + 1] = vEquipIdAll[nIndex]
	end
end

--//==================================
--//get equipid with level area 
--//==================================
function Workshopmanager:GetEquipIdArrayWithLevel(nLevel)
	local vEquipId = self.vLevelEquipId[nLevel]
	if vEquipId==nil then
		self.vLevelEquipId[nLevel] = {}
		self:getEquipIdWithLevel(nLevel,self.vLevelEquipId[nLevel])
	    vEquipId = self.vLevelEquipId[nLevel]
	end
	return vEquipId
end

--//==================================
--//===================================
--//nLevel= 10 ��20 
function Workshopmanager:getEquipIdWithLevel(nLevel,vEauipId)
	local equipMakeTabAllId = BeanConfigManager.getInstance():GetTableByName("item.cequipmakeinfo"):getAllID()
	for i = 1, #equipMakeTabAllId do
		local nEquipId = equipMakeTabAllId[i]
		--7wei
		local nResult = math.floor(nEquipId /1000000)
		if nResult~= 0 then
			local nEquipLevel = math.floor( nEquipId /1000)
			nEquipLevel = nEquipLevel % 1000
			if nEquipLevel==nLevel then
				vEauipId[#vEauipId +1] = nEquipId
			end
		end
	end
end

--//===================================
--//===================================
function Workshopmanager:GetXqEquipWithPage(vEquipKeyOrderIndex,nPage)----宝石镶嵌限制
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		if e_data.eBagType == 1  then
			local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
			if itemAttrCfg.level >= 1 and IsEquip(itemAttrCfg.itemtypeid) then
				target_eq[#target_eq + 1] = nIndex
			end
		end
		end
	end
	local nMaxIndex = #self.vEquipKeyOrder
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = nIndex
	end
end



equiplist = {--套装点化
	152,
	168,
	184,
	376,
	392,
	616,
	632,
	648,
	664,
	680,
}

function IsEquip(type)
	for index, value in ipairs(equiplist) do
		if value == type then
			return false
		end
	end
	return true
end
function Workshopmanager:getdianhualv(vEquipKeyOrderIndex,nPage)
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		if e_data.eBagType == 1  then
			local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
			if itemAttrCfg.level >= 50 and IsEquip(itemAttrCfg.itemtypeid) then
				target_eq[#target_eq + 1] = nIndex
			end
		end
		end
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end
function Workshopmanager:ronglianlv(vEquipKeyOrderIndex,nPage)
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		if e_data.eBagType == 1 then
			local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		    if equipData then
			   local itemAttrCfg = equipData:GetBaseObject()
			   if isnewequips(itemAttrCfg.itemtypeid) and itemAttrCfg.level >= 50 then
				  target_eq[#target_eq + 1] = nIndex
			    end
		   end
		end
	end

	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end

super={--开孔---装备显示限制
	152,
	168,
	184,
	376,
	392,
	616,
	632,
	648,
	680,
}
function issuper(typeId)
	for index, value in ipairs(super) do
		if value == typeId then
			return false
		end
	end
	return true
end
equipitems = {	-----重铸
	40,
	72,
	88,
	312,
	568,
	1288,
	1384,
	1640,
	1800,
	2824,
	3080,
	4104,
	4360,
	376,
	392,
}
function isnewequips(typeId)
	for k,v in ipairs(equipitems) do
		if v == typeId then
			return false
		end
	end
	return true
end
function Workshopmanager:superronglianlv(vEquipKeyOrderIndex,nPage)
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		if e_data.eBagType == 1 then
			local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
			if issuper(itemAttrCfg.itemtypeid) and itemAttrCfg.level >= 60 then
				target_eq[#target_eq + 1] = nIndex
			end
		end
		end
		
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end
function Workshopmanager:fumolv(vEquipKeyOrderIndex,nPage)
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		if e_data.eBagType == 1 then
			local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
			if itemAttrCfg.level >= 50 then
				target_eq[#target_eq + 1] = nIndex
			end
		end
		end
		
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end




function Workshopmanager:GetAqEquipWithPage(vEquipKeyOrderIndex,nPage)
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
			if itemAttrCfg.nquality == 4 and itemAttrCfg.level >= 110 and e_data.eBagType ~= fire.pb.item.BagTypes.EQUIP then
				target_eq[#target_eq + 1] = nIndex
			end
		end
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end

-----------------
-------下面是法宝类读取专用
------------------

function Workshopmanager:GetAqEquipWithPage1(vEquipKeyOrderIndex,nPage)-----法宝进阶读取
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
						local itemAttrCfg = equipData:GetBaseObject()
			if itemAttrCfg.nquality >= 3 and itemAttrCfg.level >= 10 and itemAttrCfg.level <= 10 and itemAttrCfg.nquality <= 3 and e_data.eBagType ~= fire.pb.item.BagTypes.EQUIP then  
				target_eq[#target_eq + 1] = nIndex
			end
		end
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end

function Workshopmanager:getchongzhulv(vEquipKeyOrderIndex,nPage)------法宝逆转读取
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		if e_data.eBagType == 1 then
			local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
		--	if  itemAttrCfg.level >= 10 then
			if itemAttrCfg.nquality >= 3 and itemAttrCfg.level >= 20 and itemAttrCfg.level <= 20 and itemAttrCfg.nquality <= 3 and e_data.eBagType ~= fire.pb.item.BagTypes.EQUIP then    

				target_eq[#target_eq + 1] = nIndex
			end
		end
		end
		
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end

-----------------
-------下面是坐骑类读取专用
------------------
function Workshopmanager:GetAqEquipWithPage2(vEquipKeyOrderIndex,nPage)-----用于读取：坐骑升级
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
						local itemAttrCfg = equipData:GetBaseObject()
			if itemAttrCfg.nquality >= 1 and itemAttrCfg.level >= 1 and itemAttrCfg.level <= 9 and itemAttrCfg.nquality <= 1 and e_data.eBagType ~= fire.pb.item.BagTypes.EQUIP then   --用于只读取坐骑升级，品质2 等级大于1 小于10
				target_eq[#target_eq + 1] = nIndex
			end
		end
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end

function Workshopmanager:GetXiLianEquipWithPage(vEquipKeyOrderIndex,nPage)----用于读取：坐骑洗炼
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		if e_data.eBagType == 1	then
			local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
			--if itemAttrCfg.level >= 1 then
			if itemAttrCfg.nquality >= 1 and itemAttrCfg.level >= 10 and itemAttrCfg.level <= 10 and itemAttrCfg.nquality <= 1 and e_data.eBagType ~= fire.pb.item.BagTypes.EQUIP then   --用于只读取坐骑升级，品质2 等级大于1 小于10
				target_eq[#target_eq + 1] = nIndex
			end
		end
		end
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end

function Workshopmanager:getchongzhuzq(vEquipKeyOrderIndex,nPage)------用于读取：坐骑品质
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		if e_data.eBagType == 1 then
			local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
		--	if  itemAttrCfg.level >= 10 then
			if itemAttrCfg.nquality >= 1 and itemAttrCfg.level >= 1 and itemAttrCfg.level <= 10 and itemAttrCfg.nquality <= 1 and e_data.eBagType ~= fire.pb.item.BagTypes.EQUIP then   --用于只读取坐骑品质，品质2 等级大于10

				target_eq[#target_eq + 1] = nIndex
			end
		end
		end
		
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end
---------------------------
------坐骑到这里结束-------
---------------------------

function Workshopmanager:getchongzhuxingying(vEquipKeyOrderIndex,nPage)------用于读取：星印
	local nBeginIndex = (nPage-1) * self.nShowNumInPage +1
	local nEndIndex = nPage * self.nShowNumInPage
	
	local target_eq = {};
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local e_data = self:GetEquipCellDataWithIndex(nIndex)
		if e_data.eBagType == 1 then
			local equipData = roleItemManager:FindItemByBagAndThisID(e_data.nEquipKey,e_data.eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()
		--	if  itemAttrCfg.level >= 10 then
			if itemAttrCfg.nquality >= 2 and itemAttrCfg.level >= 10 and itemAttrCfg.level <= 10 and itemAttrCfg.nquality <= 2 and e_data.eBagType ~= fire.pb.item.BagTypes.EQUIP then   --用于只读取坐骑品质，品质2 等级大于10

				target_eq[#target_eq + 1] = nIndex
			end
		end
		end
		
	end
	
	local nMaxIndex = #target_eq
	if nEndIndex>nMaxIndex then
		nEndIndex = nMaxIndex
	end
	for nIndex=nBeginIndex,nEndIndex do 
		vEquipKeyOrderIndex[#vEquipKeyOrderIndex + 1] = target_eq[nIndex]
	end
end

function Workshopmanager:GetEquipCellDataWithIndex(nIndex)
	local nMaxIndex = #self.vEquipKeyOrder
	if nIndex<1 or nIndex>nMaxIndex then
		return nil
	end
	return self.vEquipKeyOrder[nIndex]
end

function Workshopmanager:GetAllEquipData()
    return self.vEquipKeyOrder
end

function Workshopmanager:getBuweiWeight(nSecondType)
    local nWeight = self.mapBuWeiWeight[nSecondType]
    if nWeight==nil then
        nWeight = 0
    end
    return nWeight
end


function Workshopmanager:RefreshEquipArray(nBadId,nItemKey)
    if not nBadId then
        nBadId = 0
        nItemKey = 0
    end
	for k,v in pairs(self.vEquipKeyOrder) do 
		v={}
	end
	self.vEquipKeyOrder = {}
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipInBodykeys = {}
	equipInBodykeys = roleItemManager:GetItemKeyListByType(equipInBodykeys,eItemType_EQUIP, fire.pb.item.BagTypes.EQUIP)
	local equipInBagkeys = {}
	equipInBagkeys = roleItemManager:GetItemKeyListByType(equipInBagkeys,eItemType_EQUIP, fire.pb.item.BagTypes.BAG)
	
    local preferItemHeight =    100000
	local nEquipInBodyHeight =   10000
	local nEquipInBagWeight =     1000
    
	--//=============================
	for i = 0, equipInBodykeys:size() - 1 do
		local nEquipKey = equipInBodykeys[i]
		local eBagType =  fire.pb.item.BagTypes.EQUIP
		local nKey = #self.vEquipKeyOrder + 1
		self.vEquipKeyOrder[nKey] = {}
		self.vEquipKeyOrder[nKey].nEquipKey = nEquipKey
		self.vEquipKeyOrder[nKey].eBagType = eBagType
		local nOrderEquipHeight = nEquipInBodyHeight
		
        local itemData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
        if itemData then
            local nItemId = itemData:GetBaseObject().id
            local nSecondType = require("logic.tips.commontiphelper").getItemSecondType(nItemId)
            local nBuweiWeight = self:getBuweiWeight(nSecondType)
            nOrderEquipHeight = nOrderEquipHeight + nBuweiWeight
        end

        if  nBadId == fire.pb.item.BagTypes.EQUIP and 
             nEquipKey == nItemKey
        then
            nOrderEquipHeight = nOrderEquipHeight + preferItemHeight
        end
		self.vEquipKeyOrder[nKey].nOrderEquipHeight = nOrderEquipHeight
	end
	
	--//=============================
	for i = 0, equipInBagkeys:size() - 1 do
		local nEquipKey = equipInBagkeys[i]
		local eBagType =  fire.pb.item.BagTypes.BAG
		local nKey = #self.vEquipKeyOrder + 1
		self.vEquipKeyOrder[nKey] = {}
		self.vEquipKeyOrder[nKey].nEquipKey = nEquipKey
		self.vEquipKeyOrder[nKey].eBagType = eBagType
		
		local nOrderEquipHeight = nEquipInBagWeight
		local nLevel = WorkshopHelper.GetItemLevel(nEquipKey,eBagType)
		nOrderEquipHeight = nOrderEquipHeight + nLevel + 100 --100---250

        local itemData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
        if itemData then
            local nItemId = itemData:GetBaseObject().id
            local nSecondType = require("logic.tips.commontiphelper").getItemSecondType(nItemId)
            local nBuweiWeight = self:getBuweiWeight(nSecondType)
            nOrderEquipHeight = nOrderEquipHeight + nBuweiWeight
        end

        if  nBadId == fire.pb.item.BagTypes.BAG and 
             nEquipKey == nItemKey
        then
            nOrderEquipHeight = nOrderEquipHeight + preferItemHeight
        end

		self.vEquipKeyOrder[nKey].nOrderEquipHeight = nOrderEquipHeight
	end
	table.sort(self.vEquipKeyOrder, function (v1, v2)
		local nOrderEquipHeight1 = v1.nOrderEquipHeight
		local nOrderEquipHeight2 = v2.nOrderEquipHeight
		return nOrderEquipHeight1 > nOrderEquipHeight2
	end)
	
end

function Workshopmanager:GetItemTypeWithId(nItemId)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return -1
	end
	local nItemTypeId = itemAttrCfg.itemtypeid
	local nType = nItemTypeId % 16
	return nType
end
--//==========================================
--//==========================================
function Workshopmanager:RefreshRedPointInRightLabel()
	local rightLabel = require "logic.workshop.workshoplabel".getInstanceOrNot()
	if not rightLabel then
		return
	end
	local bHaveXq = self:IsHaveEquipCanXqGem()
	if bHaveXq==true then
		rightLabel:SetRedPointVisible(2,true)
	else 
		rightLabel:SetRedPointVisible(2,false)
	end
end
--//==========================================
function Workshopmanager:IsHaveEquipCanXqGem()
	if #self.vEquipKeyOrder==0 then
		self:RefreshEquipArray()
	end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=1,#self.vEquipKeyOrder do 
		local equipCellData = self.vEquipKeyOrder[nIndex]
		local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
        if eBagType==fire.pb.item.BagTypes.EQUIP then
            local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		    if equipData then
			    local bOk = self:IsHaveFreeGemBoxAndGem(equipData)
			    if bOk then
				    return true
			    end
		    end                
        end
	end
	return false
end

--�Ƿ��пձ�ʯ�������б�ʯ��Ƕ
function Workshopmanager:IsHaveFreeGemBoxAndGem(equipData)
	local bHaveGemBox = self:IsHaveGemBoxFree(equipData)
	if bHaveGemBox==false then
		return false
	end
	local bHaveGem = self:IsHaveCanXqGem(equipData)
	if bHaveGem then
		return true
	end
	return false
end

function Workshopmanager:IsHaveGemBoxFree_pointCard(equipData)
    
    local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipAttrCfg then
		return false
	end 

     local nTableKey = itemAttrCfg.level
     local pointCardXQTable = BeanConfigManager.getInstance():GetTableByName("item.cpointcardequipgem"):getRecorder(nTableKey)
	 if  not pointCardXQTable then
		  return false
	 end 

	local nGemBoxLevelNum = pointCardXQTable.vgemboxlevel:size()
	
	local nGemBoxMax = nGemBoxLevelNum
	if nGemBoxMax<1 then
		return false
	end
	local equipObj = equipData:GetObject()
	local vcGemList = equipObj:GetGemlist()
	for nIndex=1,nGemBoxMax do
		local bUnlock = self:IsUnlockGemBox(equipData,nIndex)
		if bUnlock==true then
			local nGemId = self:GetGemIdInGemBoxWithIndex(vcGemList,nIndex)
			if nGemId==-1 then
				return true
			end
		end
	end
	return false
end

--function WorkshopXqNew
--�Ƿ��пյı�ʯ��
function Workshopmanager:IsHaveGemBoxFree(equipData)
    if IsPointCardServer() then
        return self:IsHaveGemBoxFree_pointCard(equipData)
    end

	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipAttrCfg then
		return false
	end 
	local nGemBoxLevelNum = equipAttrCfg.vgemboxlevel:size()
	
	
	local nGemBoxMax = nGemBoxLevelNum
	if nGemBoxMax<1 then
		return false
	end
	local equipObj = equipData:GetObject()
	local vcGemList = equipObj:GetGemlist()
	for nIndex=1,nGemBoxMax do
		local bUnlock = self:IsUnlockGemBox(equipData,nIndex)
		if bUnlock==true then
			local nGemId = self:GetGemIdInGemBoxWithIndex(vcGemList,nIndex)
			if nGemId==-1 then
				return true
			end
		end
	end
	return false
end



function Workshopmanager:IsUnlockGemBox_pointCard(equipData,nIndexBox)
    local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipAttrCfg then
		return false
	end 
    
     local nTableKey = itemAttrCfg.level
     local pointCardXQTable = BeanConfigManager.getInstance():GetTableByName("item.cpointcardequipgem"):getRecorder(nTableKey)
	 if  not pointCardXQTable then
		  return false
	 end 

	local nGemBoxLevelNum = pointCardXQTable.vgemboxlevel:size()
	local nOpenLevel =-1
	for nIndex=1,nGemBoxLevelNum do 
		if nIndex==nIndexBox then
			nOpenLevel = pointCardXQTable.vgemboxlevel[nIndex-1]
		end
	end
	if nOpenLevel==-1 then
		return false
	end
	local nEquipLevel = itemAttrCfg.level
	if nEquipLevel>=nOpenLevel then
		return true
	end
	return false
end

--�Ƿ������ʯ��
function Workshopmanager:IsUnlockGemBox(equipData,nIndexBox)
    if IsPointCardServer() then
        return self:IsUnlockGemBox_pointCard(equipData,nIndexBox)
    end

	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipAttrCfg then
		return false
	end 

	local nGemBoxLevelNum = equipAttrCfg.vgemboxlevel:size()
	local nOpenLevel =-1
	for nIndex=1,nGemBoxLevelNum do 
		if nIndex==nIndexBox then
			nOpenLevel = equipAttrCfg.vgemboxlevel[nIndex-1]
		end
	end
	if nOpenLevel==-1 then
		return false
	end
	local nEquipLevel = itemAttrCfg.level
	if nEquipLevel>=nOpenLevel then
		return true
	end
	return false
end

--//ȡ�ڱ�ʯ���ı�ʯid
function Workshopmanager:GetGemIdInGemBoxWithIndex(vcGemList,nIndex)
	local ncIndex = nIndex -1
	if ncIndex<0 or ncIndex>=vcGemList:size() then
		return -1
	end
	local nGemId = vcGemList[ncIndex]
	return nGemId
end

--//�Ƿ��п���Ƕ��ʯ
function Workshopmanager:IsHaveCanXqGem(equipData)
	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local vGemKey = {}
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	vGemKey = roleItemManager:GetItemKeyListByType(vGemKey,eItemType_GEM, fire.pb.item.BagTypes.BAG)
	for i = 0, vGemKey:size() - 1 do
		local baggem = roleItemManager:FindItemByBagAndThisID(vGemKey[i], fire.pb.item.BagTypes.BAG)
		if baggem then
			local nGemId = baggem:GetObjectID()
			local nSelGemType = -1
			local bMatch = self:IsGemMatchItem(nGemId,nEquipId,nSelGemType)
			if bMatch==true then
				return true
			end
		end
	end
	return false
end

function Workshopmanager:getCanXqGemLevelMax(nEquipId)
    
    local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nEquipId)
	if not itemAttr then
		return 0
	end

    local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipAttrCfg then
		return 0
	end 
    if IsPointCardServer() then
        local nTableKey = itemAttr.level
        local pointCardXQTable = BeanConfigManager.getInstance():GetTableByName("item.cpointcardequipgem"):getRecorder(nTableKey)
	    if  pointCardXQTable then
		    return pointCardXQTable.gemsLevel
	    end 
    end

    return equipAttrCfg.gemsLevel
end

--self.nGemTypeId
--//�Ƿ�ƥ�� ��ʯ ��װ�� nCurSelGemType ��ǰѡ������� -1����ȫ�� 
 function Workshopmanager:IsGemMatchItem(gemid, itemid,nCurSelGemType)
	local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid)
	if not itemattr then
		return false
	end
	local gemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(gemid)
	if not gemAttrCfg then
		return false
	end
	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(itemid)
	if not equipAttrCfg then
		return false
	end --vgemtype
	local eequiptype = equipAttrCfg.eequiptype --װ����������
	local nLevelLimit = self:getCanXqGemLevelMax(itemid) --equipAttrCfg.gemsLevel --װ������Ƕ��ʯ�ȼ�����
	local gemEffectCfg = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(gemid)
	if not gemEffectCfg then
		return false
	end
	local itemtype = itemattr.itemtypeid
	if gemAttrCfg.level > nLevelLimit then
		return false
	end
	local nCanUseGemTypeNum = equipAttrCfg.vgemtype:size()
	for nIndex=1,nCanUseGemTypeNum do
		local eGemType = equipAttrCfg.vgemtype[nIndex-1]
		if nCurSelGemType==-1 and eGemType == gemEffectCfg.ngemtype then
			return true
		elseif eGemType==nCurSelGemType and eGemType == gemEffectCfg.ngemtype then
			return true
		end
	end
	return false
end
--//================================

function Workshopmanager:HandleClickItemCell(args)
	
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eComeFrom
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function Workshopmanager:HandleClickItemCellc(args)-----新的tips
	
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eNormal
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function Workshopmanager.getNumStrWithThousand(nUserMoney)----金币分号
	local strUserMoney = tostring(nUserMoney)
	if nUserMoney >=1000 then
		local nNewMoney =  math.floor(nUserMoney / 1000)
		
		local strLeft = Workshopmanager.getNumStrWithThousand(nNewMoney)
		--local nLeft = math.floor(nUserMoney / 1000)
		local nRight = nUserMoney % 1000
		local strRight = string.format("%03d",nRight)
		strUserMoney = strLeft..","..strRight
	else
		strUserMoney = tostring(nUserMoney)
	end
	return strUserMoney
end

function Workshopmanager:getMakeTarget(vTargetItemId,vTargetItemPercent,equipMakeInfoCfg,nMakeType)
    --local nMakeType = self:getMakeType()
    if nMakeType == 0 then
        for nIndex=0,equipMakeInfoCfg.vptdazhaoid:size()-1 do 
            local nTargetId = equipMakeInfoCfg.vptdazhaoid[nIndex]
            vTargetItemId[#vTargetItemId + 1] = nTargetId
        end
        for nIndex=0,equipMakeInfoCfg.vptdazhaorate:size()-1 do 
            local nTargetId = equipMakeInfoCfg.vptdazhaorate[nIndex]
            vTargetItemPercent[#vTargetItemPercent +1] = nTargetId
        end
    else
        for nIndex=0,equipMakeInfoCfg.vqhdazhaoid:size()-1 do 
            local nTargetId = equipMakeInfoCfg.vqhdazhaoid[nIndex]
            vTargetItemId[#vTargetItemId +1] = nTargetId
        end
        for nIndex=0,equipMakeInfoCfg.vqhdazhaorate:size()-1 do 
            local nTargetId = equipMakeInfoCfg.vqhdazhaorate[nIndex]
            vTargetItemPercent[#vTargetItemPercent +1] = nTargetId
        end
    end
end

function Workshopmanager:isCanEquip(nEquipId)
    local nCurRoleId = -1
    if gGetDataManager() then
       local nModelId = gGetDataManager():GetMainCharacterShape()
       nCurRoleId = nModelId%10
    end

    local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance():getRecorder(nEquipId)
    if equipEffectTable.id == -1 then
        return false
    end
    local vcnRoleId = equipEffectTable.roleNeed
    if vcnRoleId:size() > 0 then
        local nRoleId = vcnRoleId[0]
        local roleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(nRoleId)
        if roleTable then
             if nCurRoleId ~= nRoleId then
                return false
             end
        end
    end

   
     local mainCareedId = gGetDataManager():GetMainCharacterSchoolID()
     local careerIds = StringBuilder.Split( equipEffectTable.needCareer, ";")
     if #careerIds > 0 and tonumber(careerIds[1]) ~= 0 then
        local bHaveJob = false
        for k,v in pairs(careerIds) do
           if v == tostring(mainCareedId) then
                 bHaveJob = true
           end 
        end
        if bHaveJob == false then
            return false
        end
     end

    local nNeedSex = equipEffectTable.sexNeed
    if nNeedSex == 0 then
        return true
    end
  
    if gGetDataManager() then
        local myData = gGetDataManager():GetMainCharacterData()
        if myData.sex ~= nNeedSex then
            return false
        end
     end
     return true

end

function Workshopmanager.getToXiuliItemBagAndKey(bSelBroken)
    if not bSelBroken then
        bSelBroken = false
    end

    local YangChengListDlg = require("logic.yangchengnotify.yangchenglistdlg")
    local nBagId = -1
    local nItemKey = -1

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipInBodykeys = {}
	equipInBodykeys = roleItemManager:GetItemKeyListByType(equipInBodykeys,eItemType_EQUIP, fire.pb.item.BagTypes.EQUIP)
	local equipInBagkeys = {}
	equipInBagkeys = roleItemManager:GetItemKeyListByType(equipInBagkeys,eItemType_EQUIP, fire.pb.item.BagTypes.BAG)
	
	--//=============================
	for i = 0, equipInBodykeys:size() - 1 do
		local nEquipKey = equipInBodykeys[i]
		local eBagType =  fire.pb.item.BagTypes.EQUIP
        local itemData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
        if itemData then
		    local equipObj = itemData:GetObject() 
	        local nEndureMax = equipObj.endureuplimit
		    local nCurEndure = equipObj.endure
            if bSelBroken then
                if nCurEndure <= 0 then
                    return eBagType,nEquipKey
                end
            else
                if nCurEndure < nEndureMax*YangChengListDlg.fEndurePercent then
                    return eBagType,nEquipKey
                end
            end
        end
    end

    for i = 0, equipInBagkeys:size() - 1 do
		local nEquipKey = equipInBagkeys[i]
		local eBagType =  fire.pb.item.BagTypes.BAG

        local itemData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
        if itemData then
		    local equipObj = itemData:GetObject()
	        local nEndureMax = equipObj.endureuplimit
		    local nCurEndure = equipObj.endure
            if bSelBroken then
                if nCurEndure <= 0 then 
                    return eBagType,nEquipKey
                end
            else
                if nCurEndure < nEndureMax*YangChengListDlg.fEndurePercent then
                    return eBagType,nEquipKey
                end
            end
        end
    end

    return nBagId,nItemKey
    
end

return Workshopmanager

WorkshopHelper = {
	
}

function WorkshopHelper.GetMapPropertyEquipData(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --fire.pb.item.BagTypes.EQUIP


    local NORMAL_YELLOW = "ffCC0000"---红色
    local NORMAL_BLUE = "FF1686db" -- "ff5fbae0" ---蓝色 
    local NORMAL_GREEN = "FF069005" --"ff33ff00" ---绿色
    local NORMAL_WHITE = "ff50321a"
    local NORMAL_PURPLE = "FFd200ff"
    local NORMAL_GOLD = "ff8c5e2a"----浅棕色

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local newnTejiId = equipObj.newskillid
	local newnTexiaoId = equipObj.newskilleffect
	local nEquipsit = equipObj.equipsit
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local jcsxText = "<T t=\"".."基础属性".."\" c=\"ffffffff\"></T>"
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".."  ".."\" c=\"ffffffff\"></T>"
	--//============================================

	
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	--if texiaoPropertyCfg and texiaoPropertyCfg.id~=-0 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(122) ---熔炼显示：基础属性
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_WHITE.."\"></T>"
		parseText = parseText..strBreak
	
	
	
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		local nextraBaseValue = equipObj:GetExtraBaseEffect(nBaseId)
		local rlmax = "已达上限"
		local rlxg = "基础属性"
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_GOLD.."\"></T>" --ff895e2b
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_GREEN.."\"></T>"
			parseText = parseText..strSpace
			--parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_GOLD.."\"></T>"
			parseText = parseText..strBreak
			if nextraBaseValue > nBaseValue*0.1 then
			--parseText = parseText.."<T t=\"".."("..nextraBaseValue..")".."\" c=\""..NORMAL_GREEN.."\"></T>"
			--parseText = parseText.."<T t=\""..rlmax.."\" c=\""..NORMAL_YELLOW.."\"></T>"
			else
			--parseText = parseText.."<T t=\"".."("..nextraBaseValue..")".."\" c=\""..NORMAL_GREEN.."\"></T>"
		end
			parseText = parseText..strBreak
			
		end
	end
	
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	--if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11801)-- 熔炼显示：熔炼属性
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_WHITE.."\"></T>"
		parseText = parseText..strBreak

		local maxvalue=function(propid,val)
			local t =  BeanConfigManager.getInstance():GetTableByName("item.cronglianattrlimit")
			local ids=t:getAllID()
			for _,id in pairs(ids) do
				local c=t:getRecorder(id)
				if c.proptype==(propid+1) and c.maxvalue== val then
						return true
				end
			end
			 return false
		end
	 
		if equipObj.shuangjia then
			for k,v in pairs(equipObj.shuangjia) do
				local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(k)
				if propertyCfg and propertyCfg.id ~= -1 then
					parseText = parseText.."<T t=\""..propertyCfg.name.."\" c=\""..NORMAL_GREEN.."\"></T>"
					parseText = parseText..strSpace
					if v>0 then
							parseText = parseText.."<T t=\"+"..tostring(v).."\" c=\""..NORMAL_GREEN.."\"></T>"
					else
					parseText = parseText.."<T t=\""..tostring(v).."\" c=\""..NORMAL_GREEN.."\"></T>"
					end
					if maxvalue(propertyCfg.id,v) then
						parseText = parseText.."<T t=\"  已达上限\" c=\""..NORMAL_YELLOW.."\"></T>"
					end
					parseText = parseText..strBreak
					--=====================================
				end
			end
		end
	
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
 
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		local nextraBaseValue = equipObj:GetExtraBaseEffect(nBaseId)
		local rlmax = " 已达上限"
		local rlxg = "熔炼"
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_GOLD.."\"></T>"
			parseText = parseText..strSpace
			
			local attrconfig =  BeanConfigManager.getInstance():GetTableByName("item.cronglianattr"):getRecorder(nBaseId)
			if attrconfig then
				if nextraBaseValue >=attrconfig.maxvalue then
					parseText = parseText.."<T t=\"".."("..nextraBaseValue..")".."\" c=\""..NORMAL_GREEN.."\"></T>"
					parseText = parseText.."<T t=\""..rlmax.."\" c=\""..NORMAL_YELLOW.."\"></T>"
				else
					parseText = parseText.."<T t=\"".."("..nextraBaseValue..")".."\" c=\""..NORMAL_GREEN.."\"></T>"
				end
			else
				if nextraBaseValue > nBaseValue*0.1 then
					parseText = parseText.."<T t=\"".."("..nextraBaseValue..")".."\" c=\""..NORMAL_GREEN.."\"></T>"
					parseText = parseText.."<T t=\""..rlmax.."\" c=\""..NORMAL_YELLOW.."\"></T>"
				else
					parseText = parseText.."<T t=\"".."("..nextraBaseValue..")".."\" c=\""..NORMAL_GREEN.."\"></T>"
				end
			end
			
			parseText = parseText..strBreak
		end
	end
	local isfujia = false
    --//============================================
    if bFujiaOneLine then
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		local mapExtraPlusData = equipObj:GetExtraPlusEffect(mapPlusData.attrid)
		if mapPlusData.attrvalue~=0 then
			isfujia  = true
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\"".."[+"..mapExtraPlusData.."]".."\" c=\""..NORMAL_GOLD.."\"></T>"
			parseText = parseText..strSpace

		end
		parseText = parseText..strBreak
	    end
        if #vPlusKey>0 then
            parseText = parseText..strBreak
        end

    end

	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11003) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11002)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strBreak
	end
    
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_GOLD.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_GOLD.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_GOLD.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_GOLD.."\"></T>"
	return true, parseText, isfujia
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end

function WorkshopHelper.GetItemLevel(nEquipKey,eBagType)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nLevel = 0
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if equipData then
		local itemAttrCfg = equipData:GetBaseObject()
		nLevel= itemAttrCfg.level
	end
	return nLevel
end

function WorkshopHelper.GetEquipArray(vEquipKeyOrder)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipInBodykeys = {}
	equipInBodykeys = roleItemManager:GetItemKeyListByType(equipInBodykeys,eItemType_EQUIP, fire.pb.item.BagTypes.EQUIP)
	local equipInBagkeys = {}
	equipInBagkeys = roleItemManager:GetItemKeyListByType(equipInBagkeys,eItemType_EQUIP, fire.pb.item.BagTypes.BAG)
	
	local nEquipInBodyHeight = 1000
	local nEquipInBag = 100
	--//=============================
	for i = 0, equipInBodykeys:size() - 1 do
		local nEquipKey = equipInBodykeys[i]
		local eBagType =  fire.pb.item.BagTypes.EQUIP
		local nKey = #vEquipKeyOrder + 1
		vEquipKeyOrder[nKey] = {}
		vEquipKeyOrder[nKey].nEquipKey = nEquipKey
		vEquipKeyOrder[nKey].eBagType = eBagType
		local nOrderEquipHeight = nEquipInBodyHeight
		
		vEquipKeyOrder[nKey].nOrderEquipHeight = nOrderEquipHeight
	end
	
	--//=============================
	for i = 0, equipInBagkeys:size() - 1 do
		local nEquipKey = equipInBagkeys[i]
		local eBagType =  fire.pb.item.BagTypes.BAG
		local nKey = #vEquipKeyOrder + 1
		vEquipKeyOrder[nKey] = {}
		vEquipKeyOrder[nKey].nEquipKey = nEquipKey
		vEquipKeyOrder[nKey].eBagType = eBagType
		
		local nOrderEquipHeight = nEquipInBag
		local nLevel = WorkshopHelper.GetItemLevel(nEquipKey,eBagType)
		nOrderEquipHeight = nOrderEquipHeight + nLevel
		vEquipKeyOrder[nKey].nOrderEquipHeight = nOrderEquipHeight
	end
	table.sort(vEquipKeyOrder, function (v1, v2)
		local nOrderEquipHeight1 = v1.nOrderEquipHeight
		local nOrderEquipHeight2 = v2.nOrderEquipHeight
		return nOrderEquipHeight1 > nOrderEquipHeight2
	end)
	
end

function WorkshopHelper.SetChildNoCutTouch(pane)
	local nChildcount = pane:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = pane:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
end

function WorkshopHelper.GetOnePropertyData(nPropertyId,nValue,mapOnePeoperty)
    local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
	if propertyCfg and propertyCfg.id ~= -1 then
		mapOnePeoperty.strTitleName = propertyCfg.name
	else
		mapOnePeoperty.strTitleName = "noid"..nPropertyId
	end
	mapOnePeoperty.strValue = WorkshopHelper.GetCorrectValue(nValue) -- "+"..tostring(nValue)
end

function WorkshopHelper.GetCorrectValueForAQ(oldValue,newValue)
	local strFuhao = ""
	if newValue == nil then
		newValue = oldValue
	end
	local nResult = math.abs(newValue)
	if newValue == nResult then
		strFuhao= "+"
		if newValue >= oldValue then
			strFuhao = strFuhao..tostring(nResult)..'(+'..(newValue-oldValue)..')'
		else
			strFuhao = strFuhao..tostring(nResult)..'(-'..(oldValue-newValue)..')'
		end
		
	else
		strFuhao = "-"
		strFuhao = strFuhao..tostring(nResult)
	end
	
	return strFuhao
end

function WorkshopHelper.GetOnePropertyDataForAQ(nPropertyId,oldValue, newValue,mapOnePeoperty)
    local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
	if propertyCfg and propertyCfg.id ~= -1 then
		mapOnePeoperty.strTitleName = propertyCfg.name
	else
		mapOnePeoperty.strTitleName = "noid"..nPropertyId
	end
	if newValue ~= nil then
		mapOnePeoperty.strValue = WorkshopHelper.GetCorrectValueForAQ(oldValue,newValue) -- "+"..tostring(nValue)
	else
		mapOnePeoperty.strValue = WorkshopHelper.GetCorrectValue(oldValue)
	end

end



function WorkshopHelper.GetMapPropertyWithEquipData(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --fire.pb.item.BagTypes.EQUIP


    local NORMAL_YELLOW = "ff895e2b"
    local NORMAL_BLUE = "FF00b1ff" -- "ff5fbae0"  
    local NORMAL_GREEN = "FF06cc11" --"ff33ff00" 
    local NORMAL_WHITE = "fffff2df"
    local NORMAL_PURPLE = "FFd200ff"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local nEquipsit = equipObj.equipsit
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	--//============================================
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_YELLOW.."\"></T>" --ff895e2b
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_YELLOW.."\"></T>"
			parseText = parseText..strBreak
		end
	end

    --//============================================
    if bFujiaOneLine then
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace

		end
	    end
        if #vPlusKey>0 then
            parseText = parseText..strBreak
        end
    else
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strBreak
		end
	    end
    end

	--//============================================
	--[[
		int attrid;
		int attrvalue;
		int attrnum;		
	--]]
	
    
	--//============================================
	--GetCSkillConfigTableInstance
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11002)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11003) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
    if bNoNaijiu then
        return true,parseText
    end
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end
function WorkshopHelper.GetMapPropertyWithEquipData1(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --fire.pb.item.BagTypes.EQUIP


    local NORMAL_YELLOW = "ff895e2b"
    local NORMAL_BLUE = "FF00b1ff" -- "ff5fbae0"  
    local NORMAL_GREEN = "FF06cc11" --"ff33ff00" 
    local NORMAL_WHITE = "fffff2df"
    local NORMAL_PURPLE = "FFd200ff"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local newnTejiId = equipObj.newskillid
	local newnTexiaoId = equipObj.newskilleffect
	local nEquipsit = equipObj.equipsit
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	--//============================================
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_YELLOW.."\"></T>" --ff895e2b
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_YELLOW.."\"></T>"
			parseText = parseText..strBreak
		end
	end

    --//============================================
    if bFujiaOneLine then
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace

		end
	    end
        if #vPlusKey>0 then
            parseText = parseText..strBreak
        end
    else
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strBreak
		end
	    end
    end

	--//============================================
	--[[
		int attrid;
		int attrvalue;
		int attrnum;		
	--]]
	
    
	--//============================================
	--GetCSkillConfigTableInstance
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11002)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11003) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end

	local newtejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(newnTejiId)
	if  newtejiPropertyCfg and newtejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11698) 
		local strTjiName = newtejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	local newtexiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(newnTexiaoId)
	if newtexiaoPropertyCfg and newtexiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11699) 
		local strTexiaoName = newtexiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
    if bNoNaijiu then
        return true,parseText
    end
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end


function WorkshopHelper.GetMapPropertyWithEquipDatazqxl(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --用于坐骑洗炼界面读取


    local NORMAL_YELLOW = "ff895e2b"
    local NORMAL_BLUE = "FF00b1ff" -- "ff5fbae0"  
    local NORMAL_GREEN = "FF06cc11" --"ff33ff00" 
    local NORMAL_WHITE = "fffff2df"
    local NORMAL_PURPLE = "FFd200ff"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local newnTejiId = equipObj.newskillid
	local newnTexiaoId = equipObj.newskilleffect
	local nEquipsit = equipObj.equipsit
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	--//============================================
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_YELLOW.."\"></T>" --ff895e2b
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_YELLOW.."\"></T>"
			parseText = parseText..strBreak
		end
	end

    --//============================================
    if bFujiaOneLine then
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace

		end
	    end
        if #vPlusKey>0 then
            parseText = parseText..strBreak
        end
    else
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strBreak
		end
	    end
    end

	--//============================================
    if bNoNaijiu then
        return true,parseText
    end
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end

function WorkshopHelper.GetMapPropertyWithEquipDatazqcz(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --用于坐骑品质界面读取


    local NORMAL_YELLOW = "ff8c5e2a"
    local NORMAL_BLUE = "ff8c5e2a" -- "ff5fbae0"  
    local NORMAL_GREEN = "ff8c5e2a" --"ff33ff00" 
    local NORMAL_WHITE = "ff8c5e2a"
    local NORMAL_PURPLE = "ff8c5e2a"
	local NORMAL_PURPLEC = "ff069e09"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local newnTejiId = equipObj.newskillid
	local newnTexiaoId = equipObj.newskilleffect
	local nEquipsit = equipObj.equipsit
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	local strSpacec1 = "<T t=\"".."  ".."\" c=\"ffffffff\"></T>"
	local strSpacecc = "<T t=\"".."     ".."\" c=\"ffffffff\"></T>"
	local strSpacec = "<T t=\"".."        ".."\" c=\"ffffffff\"></T>"


	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11813) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText..strSpacec
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
		parseText = parseText..strBreak
		parseText = parseText..strBreak
		parseText = parseText..strBreak
		parseText = parseText..strBreak
		parseText = parseText..strBreak
	end
	
	--//============================================
	--GetCSkillConfigTableInstance
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaoName = texiaoPropertyCfg.name1
		local strTexiaoNamec = texiaoPropertyCfg.name8
		parseText = parseText..strSpacecc
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpacec1
		parseText = parseText.."<T t=\"".."[+"..strTexiaoNamec.."]".."\" c=\""..NORMAL_PURPLEC.."\"></T>"
		parseText = parseText..strBreak
	end
	
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaoName = texiaoPropertyCfg.name2
		local strTexiaoNamec = texiaoPropertyCfg.name9
		parseText = parseText..strSpacecc
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpacec1
		parseText = parseText.."<T t=\"".."[+"..strTexiaoNamec.."]".."\" c=\""..NORMAL_PURPLEC.."\"></T>"
		parseText = parseText..strBreak
	end
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaoName = texiaoPropertyCfg.name3
		local strTexiaoNamec = texiaoPropertyCfg.name10
		parseText = parseText..strSpacecc
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpacec1
		parseText = parseText.."<T t=\"".."[+"..strTexiaoNamec.."]".."\" c=\""..NORMAL_PURPLEC.."\"></T>"
		parseText = parseText..strBreak
	end
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaoName = texiaoPropertyCfg.name4
		local strTexiaoNamec = texiaoPropertyCfg.name10
		parseText = parseText..strSpacecc
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpacec1
		parseText = parseText.."<T t=\"".."[+"..strTexiaoNamec.."]".."\" c=\""..NORMAL_PURPLEC.."\"></T>"
		parseText = parseText..strBreak
	end
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaoName = texiaoPropertyCfg.name5
		local strTexiaoNamec = texiaoPropertyCfg.name11
		parseText = parseText..strSpacecc
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpacec1
		parseText = parseText.."<T t=\"".."[+"..strTexiaoNamec.."]".."\" c=\""..NORMAL_PURPLEC.."\"></T>"
		parseText = parseText..strBreak
	end
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaoName = texiaoPropertyCfg.name6
		local strTexiaoNamec = texiaoPropertyCfg.name12
		parseText = parseText..strSpacecc
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpacec1
		parseText = parseText.."<T t=\"".."[+"..strTexiaoNamec.."]".."\" c=\""..NORMAL_PURPLEC.."\"></T>"
		parseText = parseText..strBreak
	end
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaoName = texiaoPropertyCfg.name7
		local strTexiaoNamec = texiaoPropertyCfg.name13
		parseText = parseText..strSpacecc
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpacec1
		parseText = parseText.."<T t=\"".."[+"..strTexiaoNamec.."]".."\" c=\""..NORMAL_PURPLEC.."\"></T>"
		parseText = parseText..strBreak
	end


	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11813)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	


	--//============================================
    if bNoNaijiu then
        return true,parseText
    end
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end




function WorkshopHelper.GetMapPropertyWithEquipData2(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --用于法宝逆转显示专用


    local NORMAL_YELLOW = "ff33ff00"
    local NORMAL_BLUE = "ff33ff00" -- "ff5fbae0"  
    local NORMAL_GREEN = "ff33ff00" --"ff33ff00" 
    local NORMAL_WHITE = "ff33ff00"
    local NORMAL_PURPLE = "ff33ff00"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local newnTejiId = equipObj.newskillid
	local newnTexiaoId = equipObj.newskilleffect
	local nEquipsit = equipObj.equipsit
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	--//============================================
	--	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	--	for nIndex=1,#vcBaseKey do
	--		local nBaseId = vcBaseKey[nIndex]
	--		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
	--		if nBaseValue~=0 then
	--			local mapOnePeoperty = {}
	--			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
	--			local strTitleName = mapOnePeoperty.strTitleName
	--			local strValue = mapOnePeoperty.strValue
	--			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_YELLOW.."\"></T>" --ff895e2b
	--			parseText = parseText..strSpace
	--			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	--			parseText = parseText..strBreak
	--		end
	--	end

    --//============================================
 	--   if bFujiaOneLine then
    	--    local vPlusKey = equipObj:GetPlusEffectAllKey()
	--	    for nIndex=1,#vPlusKey do
	--		local nPlusId = vPlusKey[nIndex]
	--		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
	--		if mapPlusData.attrvalue~=0 then
	--			local mapOnePeoperty = {}
	--			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
	--			local strTitleName = mapOnePeoperty.strTitleName
	--			local strValue = mapOnePeoperty.strValue
	--			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
	--			parseText = parseText..strSpace
	--			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
	--			parseText = parseText..strSpace

--		end
--	    end
--        if #vPlusKey>0 then
	--            parseText = parseText..strBreak
  --      end
 --   else
 --       local vPlusKey = equipObj:GetPlusEffectAllKey()
--	    for nIndex=1,#vPlusKey do
--		local nPlusId = vPlusKey[nIndex]
--		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
--		if mapPlusData.attrvalue~=0 then
--			local mapOnePeoperty = {}
--			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
--			local strTitleName = mapOnePeoperty.strTitleName
--			local strValue = mapOnePeoperty.strValue
--			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
--			parseText = parseText..strSpace
--			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
--			parseText = parseText..strBreak
--		end
---	    end
  --  end

	--//============================================
	--[[
		int attrid;
		int attrvalue;
		int attrnum;		
	--]]
	
    --//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11813) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	
	--//============================================
	--GetCSkillConfigTableInstance
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11813)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	

	--//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	local newtexiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(newnTexiaoId)
	if newtexiaoPropertyCfg and newtexiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11699) 
		local strTexiaoName = newtexiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
    if bNoNaijiu then
        return true,parseText
    end
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end

function WorkshopHelper.tejidingzhidq(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --用于特技定制显示


    local NORMAL_YELLOW = "ff92471a"
    local NORMAL_BLUE = "ff92471a" -- "ff5fbae0"  
    local NORMAL_GREEN = "ff92471a" --"ff33ff00" 
    local NORMAL_WHITE = "ff92471a"
    local NORMAL_PURPLE = "ff92471a"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local newnTejiId = equipObj.newskillid
	local newnTexiaoId = equipObj.newskilleffect
	local nEquipsit = equipObj.equipsit
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"


	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(7203)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	--//============================================
    if bNoNaijiu then
        return true,parseText
    end
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	return true, parseText
end


function WorkshopHelper.GetEquipsitData(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --fire.pb.item.BagTypes.EQUIP


    local NORMAL_YELLOW = "ff895e2b"
    local NORMAL_BLUE = "ff33ff00" -- "ff5fbae0"  
    local NORMAL_GREEN = "FF06cc11" --"ff33ff00" 
    local NORMAL_WHITE = "fffff2df"
    local NORMAL_PURPLE = "FFd200ff"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local nEquipsit = equipObj.equipsit
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	--//============================================
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_YELLOW.."\"></T>" --ff895e2b
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_YELLOW.."\"></T>"
			parseText = parseText..strBreak
		end
	end

    --//============================================
    if bFujiaOneLine then
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace

		end
	    end
        if #vPlusKey>0 then
            parseText = parseText..strBreak
        end
    else
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strBreak
		end
	    end
    end

	--//============================================
	--[[
		int attrid;
		int attrvalue;
		int attrnum;		
	--]]
	
    
	--//============================================
	--GetCSkillConfigTableInstance
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11002)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11003) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	
	local EquipsitCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipsit"):getRecorder(nEquipsit)
	if EquipsitCfg and EquipsitCfg.id~=-1 then 
		local strEquipsit = MHSD_UTILS.get_resstring(11691) 
		local strEquipsitName = EquipsitCfg.name
		parseText = parseText.."<T t=\""..strEquipsit.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strEquipsitName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	
	local EquipsitCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipsit"):getRecorder(nEquipsit)
	if EquipsitCfg and EquipsitCfg.id~=-1 then 
		local strEquipsit = MHSD_UTILS.get_resstring(11692) 
		local strEquipsitName = EquipsitCfg.tips
		parseText = parseText.."<T t=\""..strEquipsit.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strEquipsitName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end

function WorkshopHelper.GetEquipsitccData(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --用于装备器灵点化套装专用显示


    local NORMAL_YELLOW = "ffCC0000"---红色
    local NORMAL_BLUE = "FF1686db" -- "ff5fbae0" ---蓝色 
    local NORMAL_GREEN = "FF069005" --"ff33ff00" ---绿色
    local NORMAL_WHITE = "ff50321a" ---深棕色
    local NORMAL_PURPLE = "FFd200ff" ---
    local NORMAL_GOLD = "ff8c5e2a"----浅棕色
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local nEquipsit = equipObj.equipsit
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local newnTejiId = equipObj.newskillid
	local newnTexiaoId = equipObj.newskilleffect
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	--//============================================
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	--if texiaoPropertyCfg and texiaoPropertyCfg.id~=-0 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(122) ---基础属性
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_WHITE.."\"></T>"
		parseText = parseText..strBreak
		
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_GOLD.."\"></T>" --ff895e2b
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_GOLD.."\"></T>"
			parseText = parseText..strBreak
		end
	end

    --//============================================
    if bFujiaOneLine then
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_GREEN.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_GREEN.."\"></T>"
			parseText = parseText..strSpace

		end
	    end
     --   if #vPlusKey>1 then
     --       parseText = parseText..strBreak
     --   end
    else
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_GREEN.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_GREEN.."\"></T>"
			parseText = parseText..strSpace
		end
	    end

		parseText = parseText..strBreak
    end

	--//============================================
	--[[
		int attrid;
		int attrvalue;
		int attrnum;		
	--]]
	
    --//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	
--	local strTexiaozi = MHSD_UTILS.get_resstring(11813)-- 空白显示
--		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_WHITE.."\"></T>"
--		parseText = parseText..strBreak

	----特效显示
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11003) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText..strBreak
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strBreak
	end
	
	
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(newnTejiId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11003) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText..strBreak
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strBreak
	end
	
	----特技显示
	--//============================================
	--GetCSkillConfigTableInstance
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11002)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strBreak
	end
	
	
	
	----器灵属性
	local newtejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.CEquipSkillInfo"):getRecorder(newnTexiaoId)
	if  newtejiPropertyCfg and newtejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11807) 
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_WHITE.."\"></T>"
		parseText = parseText..strBreak
	end

	
	
	----器灵未镶嵌
	local newtejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CFumoInfo"):getRecorder(newnTexiaoId)----读取的是 装备附魔特技特效库
	if  newtejiPropertyCfg and newtejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11813) 
		local strTjiName = newtejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_GOLD.."\"></T>"
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_GOLD.."\"></T>"
		parseText = parseText..strBreak
	end
    
	----器灵具体属性1
	local newtejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(newnTexiaoId)-----读取的是 装备附魔指定特技特效库 名称1
	if  newtejiPropertyCfg and newtejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11813) 
		local strTjiName = newtejiPropertyCfg.name1
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_GOLD.."\"></T>"
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_GOLD.."\"></T>"
		parseText = parseText..strBreak
	end
	----器灵具体属性2
	local newtejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(newnTexiaoId)-----读取的是 装备附魔指定特技特效库 名称2
	if  newtejiPropertyCfg and newtejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11813) 
		local strTjiName = newtejiPropertyCfg.name2
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_GOLD.."\"></T>"
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_GOLD.."\"></T>"
		parseText = parseText..strBreak
	end
	----器灵具体属性3
	local newtejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(newnTexiaoId)-----读取的是 装备附魔指定特技特效库 名称3
	if  newtejiPropertyCfg and newtejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11813) 
		local strTjiName = newtejiPropertyCfg.name3
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_GOLD.."\"></T>"
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_GOLD.."\"></T>"
		parseText = parseText..strBreak
	end
	
	
		----镶嵌：
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(newnTexiaoId)
	if  newtejiPropertyCfg and newtejiPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(7206) ---器灵属性tips：
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_BLUE.."\"></T>"
	end
	local newtejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(newnTexiaoId) -----读取的是 装备附魔指定特技特效库 名称
	if  newtejiPropertyCfg and newtejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11813) 
		local strTjiName = newtejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strBreak
	end
	
	
	
	----套装：
	local EquipsitCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipsit"):getRecorder(nEquipsit)
	if EquipsitCfg and EquipsitCfg.id~=-1 then 
		local strEquipsit = MHSD_UTILS.get_resstring(11822) 
		local strEquipsitName = EquipsitCfg.name
		parseText = parseText.."<T t=\""..strEquipsit.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText.."<T t=\""..strEquipsitName.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strBreak
	end
	
	
	

	
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end


----------星印从这里开始-------------
function WorkshopHelper.GetMapPropertyWithEquipxyData(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --星印主属性


    local NORMAL_YELLOW = "ff895e2b"
    local NORMAL_BLUE = "FF00b1ff" -- "ff5fbae0"  
    local NORMAL_GREEN = "FF06cc11" --"ff33ff00" 
    local NORMAL_WHITE = "fffff2df"
    local NORMAL_PURPLE = "FFd200ff"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	--//============================================
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_YELLOW.."\"></T>" --ff895e2b
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_YELLOW.."\"></T>"
			parseText = parseText..strBreak
		end
	end
--[[
    --//============================================
    if bFujiaOneLine then
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace

		end
	    end
        if #vPlusKey>0 then
            parseText = parseText..strBreak
        end
    else
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strBreak
		end
	    end
    end

	--//============================================
	
		int attrid;
		int attrvalue;
		int attrnum;		
	--]]
	
    
	--//============================================
	--GetCSkillConfigTableInstance
	--[[local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11813)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11813) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end--]]
	--//============================================
    if bNoNaijiu then
        return true,parseText
    end
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end


function WorkshopHelper.GetMapPropertyWithEquipxy1Data(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --星印附加属性


    local NORMAL_YELLOW = "ff895e2b"
    local NORMAL_BLUE = "ff348539" -- "ff5fbae0"  
    local NORMAL_GREEN = "ff895e2b" --"ff33ff00" 
    local NORMAL_WHITE = "ff895e2b"
    local NORMAL_PURPLE = "ff895e2b"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	--//============================================
	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	--[[for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(nBaseId,nBaseValue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_YELLOW.."\"></T>" --ff895e2b
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_YELLOW.."\"></T>"
			parseText = parseText..strBreak
		end
	end---]]

    --//============================================
    if bFujiaOneLine then
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace

		end
	    end
        if #vPlusKey>0 then
            parseText = parseText..strBreak
        end
    else
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\" "..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strBreak
		end
	    end
    end

	--//============================================
	--[[
		int attrid;
		int attrvalue;
		int attrnum;		
	--]]
	
    
	--//============================================
	--GetCSkillConfigTableInstance
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11813)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11813) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_BLUE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
    if bNoNaijiu then
        return true,parseText
    end
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end

----------星印到这里结束-------------

function WorkshopHelper.GetAQPropertyWithEquipData(equipData,bUseLocal,eBagType,bNoNaijiu,bFujiaOneLine) --fire.pb.item.BagTypes.EQUIP


    local NORMAL_YELLOW = "ff895e2b"
    local NORMAL_BLUE = "FF00b1ff" -- "ff5fbae0"  
    local NORMAL_GREEN = "FF06cc11" --"ff33ff00" 
    local NORMAL_WHITE = "fffff2df"
    local NORMAL_PURPLE = "FFd200ff"
    

	local vGemList = std.vector_int_()
	local equipObj = equipData:GetObject()
	if equipObj and bUseLocal==false then
		local bNeedRequireData = equipData:GetObject().bNeedRequireData
		if bNeedRequireData then --bNeedRequireData
	        require "protodef.fire.pb.item.cgetitemtips"
	        local p = CGetItemTips.Create()
	        p.packid = eBagType
	        p.keyinpack = equipData:GetThisID()
	        LuaProtocolManager.getInstance():send(p)
			return false
		else
		end
	end 
	local mapBaseEffect = equipObj.baseEffect --id value  
	local mapPlusEffect = equipObj.plusEffect
	local nTejiId = equipObj.skillid
	local nTexiaoId = equipObj.skilleffect
	local nEndure = equipObj.endure
	local nFailTimes = equipObj.repairTimes
	local parseText = ""
	local strBreak = "<B></B>"
	local strSpace = "<T t=\"".." ".."\" c=\"ffffffff\"></T>"
	--//============================================
	
	local itemAttrCfg = equipData:GetBaseObject()
	local beforeAfterId = itemAttrCfg.id+1000000
	

	local eauipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(beforeAfterId)
	if not eauipAttrCfg then
		return
	end
	local nbaseAttrId = eauipAttrCfg.baseAttrId
	local eauipAddAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipiteminfo"):getRecorder(nbaseAttrId)
	if eauipAddAttrCfg == nil then
		return
	end

	local vcBaseKey = equipObj:GetBaseEffectAllKey()
	for nIndex=1,#vcBaseKey do
		local nBaseId = vcBaseKey[nIndex]
		local nid = 0;
		local amin = 0;
		local amax = 0;
		if nBaseId == eauipAddAttrCfg.shuxing1id then
			nid = eauipAddAttrCfg.shuxing1id;
			amin = eauipAddAttrCfg.shuxing1bodongduanmin
			amax = eauipAddAttrCfg.shuxing1bodongduanmax
		elseif nBaseId == eauipAddAttrCfg.shuxing2id then
			nid = eauipAddAttrCfg.shuxing2id;
			amin = eauipAddAttrCfg.shuxing2bodongduanmin
			amax = eauipAddAttrCfg.shuxing2bodongduanmax
		elseif nBaseId == eauipAddAttrCfg.shuxing3id then
			nid = eauipAddAttrCfg.shuxing3id;
			amin = eauipAddAttrCfg.shuxing3bodongduanmin
			amax = eauipAddAttrCfg.shuxing3bodongduanmax
		end
		local nPropertyId = nid
		local nTypeNameId = math.floor(nPropertyId/10)
		nTypeNameId = nTypeNameId *100
		nPropertyId = nTypeNameId
		
		 local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
		 if propertyCfg and propertyCfg.id ~= -1 then
			local strPropertyName = propertyCfg.name
			if strPropertyName==nil then
				strPropertyName = "empty"
			end
			amin,amax = require("logic.tips.equiptipmaker").GetMinAndMax(amin,amax)
		end
		 
		
		local nBaseValue = equipObj:GetBaseEffect(nBaseId)
		if nBaseValue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyDataForAQ(nBaseId,nBaseValue, amin,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_YELLOW.."\"></T>" --ff895e2b
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_YELLOW.."\"></T>"
			parseText = parseText..strBreak
		end
	end

    --//============================================
    if bFujiaOneLine then
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace

		end
	    end
        if #vPlusKey>0 then
            parseText = parseText..strBreak
        end
    else
        local vPlusKey = equipObj:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		local nPlusId = vPlusKey[nIndex]
		local mapPlusData = equipObj:GetPlusEffect(nPlusId)
		if mapPlusData.attrvalue~=0 then
			local mapOnePeoperty = {}
			WorkshopHelper.GetOnePropertyData(mapPlusData.attrid,mapPlusData.attrvalue,mapOnePeoperty)
			local strTitleName = mapOnePeoperty.strTitleName
			local strValue = mapOnePeoperty.strValue
			parseText = parseText.."<T t=\""..strTitleName.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strSpace
			parseText = parseText.."<T t=\""..strValue.."\" c=\""..NORMAL_BLUE.."\"></T>"
			parseText = parseText..strBreak
		end
	    end
    end

	--//============================================
	--[[
		int attrid;
		int attrvalue;
		int attrnum;		
	--]]
	
    
	--//============================================
	--GetCSkillConfigTableInstance
	local tejiPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
	if  tejiPropertyCfg and tejiPropertyCfg.id~=-1 then 
		local strTejizi = MHSD_UTILS.get_resstring(11002)
		local strTjiName = tejiPropertyCfg.name
		parseText = parseText.."<T t=\""..strTejizi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTjiName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
	--GetCEquipSkillInfoTableInstance
	--GetCBuffConfigTableInstance
	local texiaoPropertyCfg = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
	if texiaoPropertyCfg and texiaoPropertyCfg.id~=-1 then 
		local strTexiaozi = MHSD_UTILS.get_resstring(11003) 
		local strTexiaoName = texiaoPropertyCfg.name
		parseText = parseText.."<T t=\""..strTexiaozi.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strSpace
		parseText = parseText.."<T t=\""..strTexiaoName.."\" c=\""..NORMAL_PURPLE.."\"></T>"
		parseText = parseText..strBreak
	end
	--//============================================
    if bNoNaijiu then
        return true,parseText
    end
    --//============================================

	local strEndure = tostring(nEndure)
	local strFailTimes = tostring(nFailTimes)
	local strEnducezi = MHSD_UTILS.get_resstring(11000)
	local strFailTimeszi = MHSD_UTILS.get_resstring(11007)
	parseText = parseText.."<T t=\""..strEnducezi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strEndure.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strBreak
	parseText = parseText.."<T t=\""..strFailTimeszi.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	parseText = parseText..strSpace
	parseText = parseText.."<T t=\""..strFailTimes.."\" c=\""..NORMAL_YELLOW.."\"></T>"
	return true, parseText
	--parseText = parseText.."<T t=\""..tostring(rollNumber).."\" c=\"4444ffff\"></T>"
end


function WorkshopHelper.GetCorrectValue(nValue)
	local strFuhao = ""
	local nResult = math.abs(nValue)
	if nValue==nResult then
		strFuhao= "+"
	else
		strFuhao = "-"
	end
	strFuhao = strFuhao..tostring(nResult)
	return strFuhao
end

function WorkshopHelper.GetItemKeyWithTableId(nItemId)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local vItemKeyAll = roleItemManager:GetItemKeyListByBag(fire.pb.item.BagTypes.BAG)
	for i = 0, vItemKeyAll:size() - 1 do
		local nItemKey = vItemKeyAll[i]
		local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.BAG)
		if pRoleItem then
			local nTableId = pRoleItem:GetObjectID()
			if nTableId == nItemId then
				return nItemKey
			end
		end
	end
    return -1
end

	
return WorkshopHelper

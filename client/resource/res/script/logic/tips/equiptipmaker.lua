local Equiptipmaker = {}

 

 --[[
local NORMAL_YELLOW = "fffbdc47"
local NORMAL_BLUE = "ff00d8ff " -- "ff5fbae0"  
local NORMAL_GREEN = "ff17ed15 " --"ff33ff00" 
local NORMAL_WHITE = "fffff2df"
local NORMAL_PURPLE = "ffff35fd"
--]]

 local NORMAL_YELLOW = "ffFFFFFF"
    local NORMAL_BLUE = "FF00FF00" -- "ff5fbae0"  
    local NORMAL_GREEN = "FFFFFF00" --"ff33ff00" 
    local NORMAL_WHITE = "fffff2df"
    local NORMAL_PURPLE = "FFFFFF00"
	local NORMAL_HUANGSE = "FFfcf31c"---黄色
	local NORMAL_LANSE = "ff6ddcf6"--蓝色

local GemColor = "ff6ddcf6" --"FF009ddb"

function Equiptipmaker.makeTip(richBox,nItemId,pObj,nItemIdInBody,pObjInBody)
    
    Equiptipmaker.color_NORMAL_YELLOW = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_YELLOW))
    Equiptipmaker.color_NORMAL_WHITE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_WHITE))
    Equiptipmaker.color_NORMAL_GREEN = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_GREEN))
    Equiptipmaker.color_NORMAL_BLUE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_BLUE))
    Equiptipmaker.color_NORMAL_PURPLE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_PURPLE))
	Equiptipmaker.color_NORMAL_HUANGSE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_HUANGSE))
    Equiptipmaker.color_NORMAL_LANSE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_LANSE))
	
    Equiptipmaker.color_GemColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(GemColor))


    local colorStr = richBox:GetColourString():c_str()
    if colorStr ~= "FFFF0000" then
        Equiptipmaker.color_NORMAL_WHITE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(colorStr))
    end

	LogInfo("Equiptipmaker.maketips(nItemId,pObj)")
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Equiptipmaker:makeTip=error=self.nItemId"..nItemId)
		return false
	end
    local pEquipData = nil
    if pObj then
       pEquipData = pObj 
    end
 
    --local nItemIdInBody = 0
    --local pObjInBody = nil
    local isXingpan=function (itemtypeid)
        if itemtypeid==504 or
            itemtypeid== 520 or
            itemtypeid== 536 or
            itemtypeid== 552 or
            itemtypeid== 584 or
            itemtypeid== 600 then
                return true
        end
        return false
    end
    if isXingpan(itemAttrCfg.itemtypeid) then
        Equiptipmaker.makeBaseProperty(richBox,nItemId,pEquipData,nItemIdInBody,pObjInBody)---主装备显示
        Equiptipmaker.makeAddProperty(richBox,nItemId,pEquipData)--附加属性--主装备
        Equiptipmaker.makeSkill(richBox,nItemId,pEquipData)----特技特效--主装备
     
        --Equiptipmaker.makeSkill111(richBox,nItemId,pEquipData)----特技特效--星印
        return true

    end

    Equiptipmaker.makeBaseProperty(richBox,nItemId,pEquipData,nItemIdInBody,pObjInBody)---主装备显示
	Equiptipmaker.makeBaseProperty1(richBox,nItemId,pEquipData,nItemIdInBody,pObjInBody)---法宝显示
	Equiptipmaker.makeBasePropertyzq(richBox,nItemId,pEquipData,nItemIdInBody,pObjInBody)---坐骑显示

    Equiptipmaker.makeAddProperty(richBox,nItemId,pEquipData)--附加属性--主装备
	
	Equiptipmaker.makeronglian(richBox,nItemId,pEquipData)
    Equiptipmaker.makeSkill(richBox,nItemId,pEquipData)----特技特效--主装备
	Equiptipmaker.makeSkill1(richBox,nItemId,pEquipData)----特技特效--法宝类
	Equiptipmaker.makeSkill11(richBox,nItemId,pEquipData)----特技特效--坐骑类
	Equiptipmaker.makeSkill111(richBox,nItemId,pEquipData)----特技特效--星印
	--Equiptipmaker.makeSkill111(richBox,nItemId,pEquipData)----特技特效--师门法宝
    Equiptipmaker.makeAddPropertycc(richBox,nItemId,pEquipData)--附加属性--星印
	--Equiptipmaker.makeequipsittips(richBox,nItemId,pEquipData) ---套装介绍
	Equiptipmaker.makeequipsit(richBox,nItemId,pEquipData)---器灵属性
	Equiptipmaker.taozhuang(richBox,nItemId,pEquipData)---套装·xxxx
    
    Equiptipmaker.makeGem(richBox,nItemId,pEquipData)---主装备宝石
	Equiptipmaker.makeFumoProperty(richBox,nItemId,pEquipData)----临时符
	Equiptipmaker.makeGem1(richBox,nItemId,pEquipData)---法宝宝石
	Equiptipmaker.makeProducter(richBox,nItemId,pEquipData)
  --  Equiptipmaker.makeEndure(richBox,nItemId,pEquipData)
    Equiptipmaker.makeScore(richBox,nItemId,pEquipData)
   -- Equiptipmaker.makeSex(richBox,nItemId,pEquipData) ---适合角色
    Equiptipmaker.makeCareer(richBox,nItemId,pEquipData)
--	Equiptipmaker.makeequipsit1(richBox,nItemId,pEquipData)---已镶嵌器灵

--	Equiptipmaker.makeLine(richBox)
	return true
end


function Equiptipmaker.makeLine(richBox)
    --richBox:AppendImage(CEGUI.String("common_pack"),CEGUI.String("goods_fengexian"))
   -- richBox:AppendBreak()
end

function Equiptipmaker.GetMinAndMax(vMin,vMax)
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

function Equiptipmaker.GetPropertyStrData(nEquipId,vCellData)
	local eauipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not eauipAttrCfg then
		return
	end
	local nbaseAttrId = eauipAttrCfg.baseAttrId
	local eauipAddAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipiteminfo"):getRecorder(nbaseAttrId)
	if eauipAddAttrCfg == nil then
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
			local nMin,nMax = Equiptipmaker.GetMinAndMax(objPropertyData.vMin,objPropertyData.vMax)
			vCellData[#vCellData +1] = {}
			vCellData[#vCellData].strPropertyName = strPropertyName
            if nMin == nMax then
                vCellData[#vCellData].strAddValue =  "+"..tostring(nMin)
            else
                vCellData[#vCellData].strAddValue =  "+"..tostring(nMin)..strBolangzi..tostring(nMax)

            end
		end
	end

end

--vCellData = {strPropertyName ,strAddValue }
function Equiptipmaker.makeBaseProperty_range(richBox,nItemId)
    richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("zuo1"))
    local strJichushuxing = require "utils.mhsdutils".get_resstring(11825)
    richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("you1"))
    richBox:AppendBreak()

    local vCellData = {}
     Equiptipmaker.GetPropertyStrData(nItemId,vCellData)

     for nIndex=1,#vCellData do

        local strTitleName = vCellData[nIndex].strPropertyName
        local strRange = vCellData[nIndex].strAddValue
        strTitleName = "提升属性："..strTitleName.."  "..strRange
        strTitleName = CEGUI.String(strTitleName)
       		
        richBox:AppendText(strTitleName,Equiptipmaker.color_NORMAL_WHITE)
		richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("sxfw1"))---属性标识
        richBox:AppendBreak()
     end
end

--pObjInBody==nil   baseitemid
function Equiptipmaker.makeBaseProperty(richBox,nItemId,pEquipData,nItemIdInBody,pObjInBody)----主装备显示
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
    ---法宝类限制属性显示
    if itemtypeid ~= 392 and itemtypeid ~= 616 and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 and itemtypeid ~= 680 then
	
	if not pEquipData then
			Equiptipmaker.makeBaseProperty_range(richBox,nItemId)
			return
		end
		--if pEquipData then
			local vcBaseKey = pEquipData:GetBaseEffectAllKey()
			if #vcBaseKey <= 0 then
				return
			end

		local strJichushuxing = require "utils.mhsdutils".get_resstring(122)
		richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_HUANGSE)
		richBox:AppendBreak()

			for nIndex=1,#vcBaseKey do
				local nBaseId = vcBaseKey[nIndex]
				local nBaseValue = pEquipData:GetBaseEffect(nBaseId)
            local nextraBaseValue = pEquipData:GetExtraBaseEffect(nBaseId)
				if nBaseValue~=0 then
					local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
					if propertyCfg and propertyCfg.id ~= -1 then
						local strTitleName = propertyCfg.name
						local nValue = math.abs(nBaseValue)
                    local nextraValue =  math.abs(nextraBaseValue)
						if nBaseValue > 0 then
							strTitleName = strTitleName.." ".."+"..tostring(nValue)
						elseif nBaseValue < 0 then
							strTitleName = strTitleName.." ".."-"..tostring(nValue)
						end
						strTitleName = "  "..strTitleName
						strTitleName = CEGUI.String(strTitleName)
						richBox:AppendText(strTitleName,Equiptipmaker.color_NORMAL_WHITE)
						--=====================================
						if pObjInBody then
							local nValueInBody = Equiptipmaker.getPropertyValue(nBaseId,pObjInBody)
                        local sum = nBaseValue+nextraValue
                        local nCha = sum - nValueInBody
                        if nCha > 0 then
                             richBox:AppendImage(CEGUI.String("shopui"), CEGUI.String("shop_up"));
                        elseif nCha < 0 then
                            richBox:AppendImage(CEGUI.String("shopui"),CEGUI.String("shop_down"));
                        end
                    end
                     --=====================================

						richBox:AppendBreak()
					end

				end
			end
    --end
	end
end

function Equiptipmaker.makeBasePropertyzq(richBox,nItemId,pEquipData,nItemIdInBody,pObjInBody)----坐骑属性显示
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
    ---排除除坐骑以外的属性显示
    if itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 and itemtypeid ~= 376  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 392 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then

	
	if not pEquipData then
			Equiptipmaker.makeBaseProperty_range(richBox,nItemId)
			return
		end
		--if pEquipData then
			local vcBaseKey = pEquipData:GetBaseEffectAllKey()
			if #vcBaseKey <= 0 then
				return
			end
			
		
		
        
		
		local strJichushuxing = require "utils.mhsdutils".get_resstring(7201)
		richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_HUANGSE)
		richBox:AppendBreak()

			for nIndex=1,#vcBaseKey do
				local nBaseId = vcBaseKey[nIndex]
				local nBaseValue = pEquipData:GetBaseEffect(nBaseId)
            local nextraBaseValue = pEquipData:GetExtraBaseEffect(nBaseId)
				if nBaseValue~=0 then
					local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
					if propertyCfg and propertyCfg.id ~= -1 then
						local strTitleName = propertyCfg.name
						local nValue = math.abs(nBaseValue)
                    local nextraValue =  math.abs(nextraBaseValue)
						if nBaseValue > 0 then
							strTitleName = strTitleName.." ".."+"..tostring(nValue)
						elseif nBaseValue < 0 then
							strTitleName = strTitleName.." ".."-"..tostring(nValue)
						end
						strTitleName = "   "..strTitleName
						strTitleName = CEGUI.String(strTitleName)
						richBox:AppendText(strTitleName,Equiptipmaker.color_NORMAL_WHITE)
						--=====================================
						if pObjInBody then
							local nValueInBody = Equiptipmaker.getPropertyValue(nBaseId,pObjInBody)
                        local sum = nBaseValue+nextraValue
                        local nCha = sum - nValueInBody
                        if nCha > 0 then
                             richBox:AppendImage(CEGUI.String("shopui"), CEGUI.String("shop_up"));
                        elseif nCha < 0 then
                            richBox:AppendImage(CEGUI.String("shopui"),CEGUI.String("shop_down"));
                        end
                    end
                     --=====================================

						richBox:AppendBreak()
					end

				end
			end
    --end
	end
end

function Equiptipmaker.makeBaseProperty1(richBox,nItemId,pEquipData,nItemIdInBody,pObjInBody)----法宝属性显示
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
    ---主装备类限制属性显示
    if itemtypeid ~= 376 and itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 and itemtypeid ~= 680 then
 
		if not pEquipData then
			Equiptipmaker.makeBaseProperty_range(richBox,nItemId)
			return
		end
		--if pEquipData then
			local vcBaseKey = pEquipData:GetBaseEffectAllKey()
			if #vcBaseKey <= 0 then
				return
			end
        richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("zuo1"))
		local strJichushuxing = require "utils.mhsdutils".get_resstring(11808)
		richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_HUANGSE)
		richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("you1"))
		richBox:AppendBreak()

			for nIndex=1,#vcBaseKey do
				local nBaseId = vcBaseKey[nIndex]
				local nBaseValue = pEquipData:GetBaseEffect(nBaseId)
            local nextraBaseValue = pEquipData:GetExtraBaseEffect(nBaseId)
				if nBaseValue~=0 then
					local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
					if propertyCfg and propertyCfg.id ~= -1 then
						local strTitleName = propertyCfg.name
						local nValue = math.abs(nBaseValue)
                    local nextraValue =  math.abs(nextraBaseValue)
						if nBaseValue > 0 then
							strTitleName = strTitleName.." ".."+"..tostring(nValue)
						elseif nBaseValue < 0 then
							strTitleName = strTitleName.." ".."-"..tostring(nValue)
						end
						richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("fabaosx"))---属性标识
						strTitleName = "提升属性："..strTitleName
						strTitleName = CEGUI.String(strTitleName)
						richBox:AppendText(strTitleName,Equiptipmaker.color_NORMAL_WHITE)
						--=====================================
						if pObjInBody then
							local nValueInBody = Equiptipmaker.getPropertyValue(nBaseId,pObjInBody)
                        local sum = nBaseValue+nextraValue
                        local nCha = sum - nValueInBody
                        if nCha > 0 then
                             richBox:AppendImage(CEGUI.String("shopui"), CEGUI.String("shop_up"));
                        elseif nCha < 0 then
                            richBox:AppendImage(CEGUI.String("shopui"),CEGUI.String("shop_down"));
                        end
                    end
                     --=====================================

						richBox:AppendBreak()
					end

				end
			end
    --end
	end
end



function Equiptipmaker.makeronglian(richBox,nItemId,pEquipData,nItemIdInBody,pObjInBody)---熔炼
 
	 
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
    ---法宝类限制属性显示
    if itemtypeid ~= 392  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 and itemtypeid ~= 680 then

		if not pEquipData then
			Equiptipmaker.makeBaseProperty_range(richBox,nItemId)
			return
		end
		--if pEquipData then
			local vcBaseKey = pEquipData:GetExtraBaseEffectAllKey()
			if #vcBaseKey <= 0 then
				return
			end
		local strJichushuxing = require "utils.mhsdutils".get_resstring(11705)
		richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_HUANGSE)
		richBox:AppendBreak()
            if pEquipData.shuangjia then
                for k,v in pairs(pEquipData.shuangjia) do
                    local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(k)
					if propertyCfg and propertyCfg.id ~= -1 then
						local strTitleName = propertyCfg.name
                        if v>0 then
					    strTitleName = strTitleName.." ".."+"..tostring(v)
                        else
                            strTitleName = strTitleName.." "..tostring(v)
                        end
						strTitleName = "  "..strTitleName
						strTitleName = CEGUI.String(strTitleName)
						richBox:AppendText(strTitleName,Equiptipmaker.color_NORMAL_BLUE)
                        richBox:AppendBreak()
						--=====================================
                    end
                end
            end
			for nIndex=1,#vcBaseKey do
				local nBaseId = vcBaseKey[nIndex]
				local nBaseValue = pEquipData:GetExtraBaseEffect(nBaseId)
				if nBaseValue~=0 then
					local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
					if propertyCfg and propertyCfg.id ~= -1 then
						local strTitleName = propertyCfg.name
						local nValue = math.abs(nBaseValue)
                    local nextraValue =  math.abs(nBaseValue)
						if nBaseValue > 0 then
							strTitleName = strTitleName.." ".."+"..tostring(nValue)
						elseif nBaseValue < 0 then
							strTitleName = strTitleName.." ".."-"..tostring(nValue)
						end
						strTitleName = "  "..strTitleName
						strTitleName = CEGUI.String(strTitleName)
						richBox:AppendText(strTitleName,Equiptipmaker.color_NORMAL_WHITE)
						--=====================================
						if pObjInBody then
							local nValueInBody = Equiptipmaker.getPropertyValue(nBaseId,pObjInBody)
                        local sum = nBaseValue+nextraValue
                        local nCha = sum - nValueInBody
                        if nCha > 0 then
                             richBox:AppendImage(CEGUI.String("shopui"), CEGUI.String("shop_up"));
                        elseif nCha < 0 then
                            richBox:AppendImage(CEGUI.String("shopui"),CEGUI.String("shop_down"));
                        end
                    end
                     --=====================================

						richBox:AppendBreak()
					end

				end
			end
    --end
	end
end

function Equiptipmaker.getPropertyValue(nBaseId,pObjInBody)
    local pEquipData = nil
    if pObjInBody then
       pEquipData = pObjInBody 
    end

    if pEquipData then
        local vcBaseKey = pEquipData:GetBaseEffectAllKey()
	    for nIndex=1,#vcBaseKey do
		    local nBaseIdInBody = vcBaseKey[nIndex]
		    local nBaseValue = pEquipData:GetBaseEffect(nBaseId)
            local nExtrBaseValue = pEquipData:GetExtraBaseEffect(nBaseId)
				if nBaseId == nBaseIdInBody then
                return nBaseValue+nExtrBaseValue
            end
        end
    end
    return 0
end

function Equiptipmaker.makeAddProperty(richBox,nItemId,pEquipData)----主装备绿字附加
    
    if not pEquipData then
        return
    end
	        local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance():getRecorder(nItemId)----leixingbujian
        if not equipEffectTable then
            print("get equipEffectTable failed")
            return
        end----leixingbujian
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
        local itemtypeid = itemAttrCfg.itemtypeid
		if itemtypeid ~= 376  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 392 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 and itemtypeid ~= 680 then

   -- if pEquipData then
        local vPlusKey = pEquipData:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		    local nPlusId = vPlusKey[nIndex]
		    local mapPlusData = pEquipData:GetPlusEffect(nPlusId)
		    if mapPlusData.attrvalue ~= 0 then
			
			    local nPropertyId = mapPlusData.attrid
                local nPropertyValue = mapPlusData.attrvalue
                local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
	            if propertyCfg and propertyCfg.id ~= -1 then
                    local strTitleName = propertyCfg.name
                    local nValue = math.abs(nPropertyValue)
                    if nPropertyValue > 0 then
                       strTitleName = strTitleName.." ".."+"..tostring(nValue)
                    else
                        strTitleName = strTitleName.." ".."-"..tostring(nValue)
                    end
                    local strEndSpace = "   "
                    local strBeginSpace = "  "
                    strTitleName = strTitleName..strEndSpace
                    strTitleName = strBeginSpace..strTitleName

                    strTitleName = CEGUI.String(strTitleName)
					
                  if equipEffectTable.eequiptype > 5 then
		             richBox:AppendText(strTitleName, Equiptipmaker.color_NORMAL_WHITE)
					 if nIndex == 1 then
				      richBox:AppendBreak()
				                       end
				     if nIndex == 2 then
				      richBox:AppendBreak()
				                       end
				     if nIndex == 3 then
				      richBox:AppendBreak()
				     end
                     if nIndex == 4 then
                        richBox:AppendBreak()
                       end
		          else
		             richBox:AppendText(strTitleName, Equiptipmaker.color_NORMAL_BLUE)
                     end


                end
		   end --if end
	   end --for end
       --========================
       if #vPlusKey > 0 then
            richBox:AppendBreak()
       end
	   end
   -- end --if end

end

function Equiptipmaker.makeAddPropertycc(richBox,nItemId,pEquipData)----星印附加属性
    
    if not pEquipData then
        return
    end
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
	if itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 then

	        local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance():getRecorder(nItemId)----leixingbujian
        if not equipEffectTable then
            print("get equipEffectTable failed")
            return
        end
		
		
        local vPlusKey = pEquipData:GetPlusEffectAllKey()
	    for nIndex=1,#vPlusKey do
		    local nPlusId = vPlusKey[nIndex]
		    local mapPlusData = pEquipData:GetPlusEffect(nPlusId)
		    if mapPlusData.attrvalue ~= 0 then
			
			    local nPropertyId = mapPlusData.attrid
                local nPropertyValue = mapPlusData.attrvalue
                local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
	            if propertyCfg and propertyCfg.id ~= -1 then
				
                    local strTitleName = propertyCfg.name
                    local nValue = math.abs(nPropertyValue)
                    if nPropertyValue > 0 then
                       strTitleName = strTitleName.." ".."+"..tostring(nValue)
                    else
                        strTitleName = strTitleName.." ".."-"..tostring(nValue)
                    end
                    local strEndSpace = "   "
                    local strBeginSpace = "  "
                    strTitleName = strTitleName..strEndSpace
                    strTitleName = strBeginSpace..strTitleName

                    strTitleName = CEGUI.String(strTitleName)
					
					
                  if equipEffectTable.eequiptype > 5 then
				  
		             richBox:AppendText(strTitleName, Equiptipmaker.color_NORMAL_BLUE)
					 if nIndex == 1 then
				      richBox:AppendBreak()
				                       end
				     if nIndex == 2 then
				      richBox:AppendBreak()
				                       end
				     if nIndex == 3 then
				      richBox:AppendBreak()
				     end
                     if nIndex == 4 then
                        richBox:AppendBreak()
                       end
		          else
		             richBox:AppendText(strTitleName, Equiptipmaker.color_NORMAL_BLUE)					 
                     end


                end
		   end 
	   end

       if #vPlusKey > 0 then
            richBox:AppendBreak()
       end
	   end


end

--[[
11286	��ʱ
11287	��Ч����
11288	ʣ��
��ʱ���� + 10  ʣ�� 3�� 
��Ч����
--]]




function Equiptipmaker.makeFumoProperty(richBox,nItemId,pEquipData)-----临时符
    if not pEquipData then
        return
    end

    local nFumoCount = pEquipData:getFumoCount()
    if nFumoCount <= 0 then
        return
    end
    
    local strLinshizi = require "utils.mhsdutils".get_resstring(11286) 
    local strLeftzi = require "utils.mhsdutils".get_resstring(11288) 
    local strEndTozi = require "utils.mhsdutils".get_resstring(11287) 

    --richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_YELLOW)
    --richBox:AppendBreak()

    for nIndexCount=0,nFumoCount-1 do
        local vFumoKey = pEquipData:GetFumoIdWithIndex(nIndexCount)

        local bHaveFumoInTime = require("logic.tips.commontiphelper").isHaveFumoInTime(pEquipData,nIndexCount)
        if bHaveFumoInTime then
            for nIndex=0,vFumoKey:size()-1 do
            local nFumoId = vFumoKey[nIndex]
            local nFumoValue = pEquipData:GetFumoValueWithId(nIndexCount,nFumoId) 

            local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nFumoId)
	        if propertyCfg and propertyCfg.id ~= -1 then
                local strTitleName = propertyCfg.name
                strTitleName = strLinshizi..strTitleName
                 local nValue = math.abs(nFumoValue)
                 if nFumoValue > 0 then
                     strTitleName = strTitleName.."  "..""..tostring(nValue)
                elseif nFumoValue < 0 then
                    strTitleName = strTitleName.." ".."-"..tostring(nValue)
                end
                strTitleName = CEGUI.String(strTitleName)
                richBox:AppendText(strTitleName, Equiptipmaker.color_NORMAL_BLUE)
                --richBox:AppendBreak()
                 --richBox:AppendBreak()
             end
             -------------------------------
            local fumoData = pEquipData:getFumoDataWidthIndex(nIndexCount)
            local nFomoEndTime = 0 
            if fumoData then
                 nFomoEndTime = fumoData.nFomoEndTime
            end
            if nFomoEndTime > 0 then
                 local nServerTime = gGetServerTime() /1000
                 local nLeftSecond = nFomoEndTime / 1000 - nServerTime
                 local timeStr =  require("logic.tips.commontiphelper").GetLeftTimeString(nLeftSecond) --Equiptipmaker.GetLeftTimeString(nLeftSecond)
                 strEndTozi = "  "..strLeftzi..timeStr
                 strEndTozi = CEGUI.String(strEndTozi)
                 richBox:AppendText(strEndTozi, Equiptipmaker.color_NORMAL_BLUE)
                 richBox:AppendBreak()
            end
            -------------------------------
        end
        end      
    end
end

--1237 %d��%d��%d�� 
--1238 %dʱ%d��%d��
--1239 %d��%d��
--1240 %dСʱ%d����
--1241 %d����
--1242 %dСʱ

function Equiptipmaker.GetLeftTimeString(seconds)
    local strHourzi = require "utils.mhsdutils".get_resstring(1242) 
    local strMinutezi = require "utils.mhsdutils".get_resstring(1241) 


    local hours = math.floor(seconds/3600)
    local leftMinSec = seconds - hours*3600
    
    local mins = math.floor(leftMinSec/60)
    local secs = math.floor(leftMinSec - mins*60)

    if hours < 0 then
        hours = 0
    end
    if mins < 0 then
        mins = 0
    end
    if secs < 0 then
        secs = 0
    end
    
    local strTime = ""
    if hours > 0 then
        
        ---local sb = StringBuilder:new()
	--sb:Set("parameter1", strTitle)
    --sb:Set("parameter2", tostring(nStep))
	--strMsg = sb:GetString(strMsg)
	--sb:delete()

        --strTime = hours ..strHourzi.. mins..strMinutezi
        strTime = string.format(strHourzi,hours)
       -- strTime = strTime..string.format(strMinutezi,mins)

    else
        strTime = string.format(strMinutezi,mins)
    end
    return strTime
end


function Equiptipmaker.makeGem(richBox,nItemId,pEquipData)---主装备宝石显示
    
    if not pEquipData then
        return
    end
    
    local vcGemList = pEquipData:GetGemlist()
    if vcGemList:size() <= 0 then 
        return
    end
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
    if itemtypeid ~= 392  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 680 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then
    local strBaoshishuxing = require "utils.mhsdutils".get_resstring(125)
    strBaoshishuxing = CEGUI.String(strBaoshishuxing)
    richBox:AppendText(strBaoshishuxing,Equiptipmaker.color_NORMAL_HUANGSE)
    richBox:AppendBreak();
	

	for nIndex=0,vcGemList:size()-1 do
		local nGemId = vcGemList[nIndex]
        local gemEffectTable = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nGemId)
        local itemAttrTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nGemId)
        local strTitleName = "  "
        if itemAttrTable then
            strTitleName = strTitleName..itemAttrTable.name
            strTitleName = strTitleName.."  "
        end
        if gemEffectTable then
            strTitleName = strTitleName..gemEffectTable.effectdes
        end

        strTitleName = CEGUI.String(strTitleName)
        richBox:AppendText(strTitleName, Equiptipmaker.color_GemColor)
        richBox:AppendBreak()
	end
	end

   

end

function Equiptipmaker.makeGem1(richBox,nItemId,pEquipData)---法宝灵珠
    
    if not pEquipData then
        return
    end
    
    local vcGemList = pEquipData:GetGemlist()
    if vcGemList:size() <= 0 then 
        return
    end
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
	if itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 then
	--richBox:AppendBreak();
	--richBox:AppendBreak();
	--richBox:AppendBreak();
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("zuo1"))
    local strBaoshishuxing = require "utils.mhsdutils".get_resstring(11809)
    strBaoshishuxing = CEGUI.String(strBaoshishuxing)
    richBox:AppendText(strBaoshishuxing,Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("you1"))
    richBox:AppendBreak();
    
	
	for nIndex=0,vcGemList:size()-1 do
		local nGemId = vcGemList[nIndex]
        local gemEffectTable = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nGemId)
        local itemAttrTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nGemId)
        local strTitleName = ""
        if itemAttrTable then
		richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("fabaosxiang"))
            strTitleName = strTitleName..itemAttrTable.name
            strTitleName = strTitleName.."  "
        end
        if gemEffectTable then
            strTitleName = strTitleName..gemEffectTable.effectdes
        end

        strTitleName = CEGUI.String(strTitleName)
        richBox:AppendText(strTitleName, Equiptipmaker.color_GemColor)
        richBox:AppendBreak()
	end
	end

   

end

function Equiptipmaker.makeSkill(richBox,nItemId,pEquipData)---主装备特效特技显示
    
    if not pEquipData then
        return
    end
	local nTexiaoId = pEquipData.skilleffect
    local nTejiId = pEquipData.skillid
	local nNewTexiaoId = pEquipData.newskillid
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid

	
	------排除法宝
    if itemtypeid ~= 376 and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and  itemtypeid ~= 392 and itemtypeid ~= 680 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then	
		local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
		if tejiTable and tejiTable.id ~= -1 then
			 local strTejizi = require "utils.mhsdutils".get_resstring(11812)
			 strTejizi = "  "..strTejizi.." "..tejiTable.name

			 strTejizi = CEGUI.String(strTejizi)
			 richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_LANSE)
			 richBox:AppendBreak();
		end
	end
	
	
	------排除法宝
    if itemtypeid ~= 376 and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and  itemtypeid ~= 392 and itemtypeid ~= 680 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then	
		local newtexiaoTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nNewTexiaoId)
		if newtexiaoTable and newtexiaoTable.id ~= -1 then
			 local strnewTeXiaozi = require "utils.mhsdutils".get_resstring(11811)
			 strnewTeXiaozi = "  "..strnewTeXiaozi.." "..newtexiaoTable.name

			 strnewTeXiaozi = CEGUI.String(strnewTeXiaozi)
			 richBox:AppendText(strnewTeXiaozi, Equiptipmaker.color_NORMAL_LANSE)
			 richBox:AppendBreak();
		end
	end	
	
	------排除法宝
	
    if itemtypeid ~= 376  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 392 and itemtypeid ~= 680 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then	
    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
		if texiaoTable and texiaoTable.id ~= -1 then
			local strTeXiaozi = require "utils.mhsdutils".get_resstring(11811)
			strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name

			strTeXiaozi = CEGUI.String(strTeXiaozi)
			richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_LANSE)
			richBox:AppendBreak();
		end
	end
	
    local itemAttrTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemAttrTable.needLevel == 0 or itemAttrTable.needLevel == 199 then
        strTejizi = "  特效 无级别限制"
        strTejizi = CEGUI.String(strTejizi)
        richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_LANSE)
        richBox:AppendBreak();
    end

end

function Equiptipmaker.makeSkill111(richBox,nItemId,pEquipData)---星印特效特技显示
    
    if not pEquipData then
        return
    end
	local nTexiaoId = pEquipData.skilleffect
    local nTejiId = pEquipData.skillid
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
	if itemtypeid ~= 664  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 616 and itemtypeid ~= 648 and itemtypeid ~= 632 and itemtypeid ~= 392 and itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 and itemtypeid ~= 680 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then
    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
    if texiaoTable and texiaoTable.id ~= -1 then
        local strTeXiaozi = require "utils.mhsdutils".get_resstring(11813)
		richBox:AppendBreak()
		local strJichushuxing = require "utils.mhsdutils".get_resstring(11837)
	    richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_HUANGSE)
     	richBox:AppendBreak()
        strTeXiaozi = "  "..strTeXiaozi..""..texiaoTable.name
        strTeXiaozi = CEGUI.String(strTeXiaozi)
        richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_BLUE)
        richBox:AppendBreak();
    end
	end
	------排除法宝
	if itemtypeid ~= 664  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 616 and itemtypeid ~= 648 and itemtypeid ~= 632 and itemtypeid ~= 392 and itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 and itemtypeid ~= 680 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then
    local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
    if tejiTable and tejiTable.id ~= -1 then
         local strTejizi = require "utils.mhsdutils".get_resstring(11813)
         strTejizi = "  "..strTejizi..""..tejiTable.name


         strTejizi = CEGUI.String(strTejizi)
		 
         richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_BLUE)
         richBox:AppendBreak();
    end
	end
	------排除法宝
	
    local itemAttrTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemAttrTable.needLevel == 0 or itemAttrTable.needLevel == 199 then
        strTejizi = "  特效 无级别限制"
        strTejizi = CEGUI.String(strTejizi)
        richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_LANSE)
        richBox:AppendBreak();
    end

end

function Equiptipmaker.makeSkill1(richBox,nItemId,pEquipData)---法宝特效特技显示
    
    if not pEquipData then
        return
    end
	local nTexiaoId = pEquipData.skilleffect
    local nTejiId = pEquipData.skillid
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
	------排除主装备
    if itemtypeid ~= 376 and itemtypeid ~= 680 and itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 then	
   local texiaoTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
    if texiaoTable and texiaoTable.id ~= -1 then
        local strTeXiaozi = require "utils.mhsdutils".get_resstring(11813)
		richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("zuo1"))
		local strJichushuxing = require "utils.mhsdutils".get_resstring(11810)
	    richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_HUANGSE)
	    richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("you1"))
     	richBox:AppendBreak()
		richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("fabaoly"))
        strTeXiaozi = ""..strTeXiaozi..""..texiaoTable.name
        strTeXiaozi = CEGUI.String(strTeXiaozi)
        richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_LANSE)
        richBox:AppendBreak();
    end
	end
	------排除主装备

    if itemtypeid ~= 376 and itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 then	
    local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
    if tejiTable and tejiTable.id ~= -1 then
         local strTejizi = require "utils.mhsdutils".get_resstring(11813)
		 richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("fabaoly"))
         strTejizi = ""..strTejizi..""..tejiTable.name

         strTejizi = CEGUI.String(strTejizi)
		 
         richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_LANSE)
         richBox:AppendBreak();
    end
	end
	------排除主装备
end


function Equiptipmaker.makeSkill111cc(richBox,nItemId,pEquipData)---师门法宝特效显示
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)----1
    local itemtypeid = itemAttrCfg.itemtypeid

    if itemtypeid ~= 40 and itemtypeid ~= 72  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 and itemtypeid ~= 376 and itemtypeid ~= 680 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then

    if not pEquipData then
        return
    end
	local nTexiaoId = pEquipData.skilleffect
    local nTejiId = pEquipData.skillid
	    richBox:AppendBreak()
	    local strJichushuxing = require "utils.mhsdutils".get_resstring(11813)
		richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_HUANGSE)
	local texiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)

	--标识
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = ""..strTeXiaozi..""..texiaoTable.name
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	


    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	---================第一条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name1
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name8.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第二条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name2
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name9.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第三条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name3
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name10.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第四条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name4
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name11.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第五条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name5
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name12.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第六条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name6
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name13.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第七条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name7
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name14.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	 --[[	-----===========下面星星显示  后续决定
    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	if texiaoTable and texiaoTable.id ~= -1 then
	if texiaoTable.id == 441002 then
	local strTeXiaozi = "注灵星级："
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
    richBox:AppendBreak();
    end
	end--]]


		
end
    

	

	
	
	------排除法宝
	
    if itemtypeid ~= 40 and itemtypeid ~= 72  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 and itemtypeid ~= 376 and itemtypeid ~= 392 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then
    local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
    if tejiTable and tejiTable.id ~= -1 then
         local strTejizi = require "utils.mhsdutils".get_resstring(11812)
         strTejizi = "  "..strTejizi.." "..tejiTable.name

         strTejizi = CEGUI.String(strTejizi)
         richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_LANSE)
         richBox:AppendBreak();
    end
	end
	------排除法宝
    local itemAttrTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemAttrTable.needLevel == 199 or itemAttrTable.needLevel == 199 then
        strTejizi = "  特效 无级别限制"
        strTejizi = CEGUI.String(strTejizi)
        richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_LANSE)
        richBox:AppendBreak();
    end

end

function Equiptipmaker.makeSkill11(richBox,nItemId,pEquipData)---坐骑特效特技显示
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)----1
    local itemtypeid = itemAttrCfg.itemtypeid

    if itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 and itemtypeid ~= 376 and itemtypeid ~= 392 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648 and itemtypeid ~= 664 then

    if not pEquipData then
        return
    end
	local nTexiaoId = pEquipData.skilleffect
    local nTejiId = pEquipData.skillid
	    richBox:AppendBreak()
	    local strJichushuxing = require "utils.mhsdutils".get_resstring(11813)
		richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_HUANGSE)
		
	local texiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)

	--标识
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = ""..strTeXiaozi..""..texiaoTable.name
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	


    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	---================第一条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name1
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name8.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第二条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name2
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name9.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第三条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name3
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name10.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第四条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name4
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name11.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第五条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name5
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name12.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第六条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name6
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name13.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	---================第七条
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "  "..strTeXiaozi.." "..texiaoTable.name7
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
    end
	if texiaoTable and texiaoTable.id ~= -1 then
	local strTeXiaozi = ""
    strTeXiaozi = "   [+"..texiaoTable.name14.."] "..strTeXiaozi
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendBreak();
    end
	
	 --[[	-----===========下面星星显示  后续决定
    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nTexiaoId)
	if texiaoTable and texiaoTable.id ~= -1 then
	if texiaoTable.id == 441002 then
	local strTeXiaozi = "注灵星级："
    strTeXiaozi = CEGUI.String(strTeXiaozi)
    richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_HUANGSE)
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
	richBox:AppendImage(CEGUI.String("ccui1"),CEGUI.String("xingxing"))
    richBox:AppendBreak();
    end
	end--]]


		
end
    

	

	
	
	------排除法宝
	
    if itemtypeid ~= 40 and itemtypeid ~= 72 and itemtypeid ~= 88 and itemtypeid ~= 312 and itemtypeid ~= 568 and itemtypeid ~= 1288 and itemtypeid ~= 1384 and itemtypeid ~= 1640 and itemtypeid ~= 1800 and itemtypeid ~= 2824 and itemtypeid ~= 3080 and itemtypeid ~= 4104 and itemtypeid ~= 4360 and itemtypeid ~= 376 and itemtypeid ~= 392 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 664 then
    local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
    if tejiTable and tejiTable.id ~= -1 then
         local strTejizi = require "utils.mhsdutils".get_resstring(11812)
         strTejizi = "  "..strTejizi.." "..tejiTable.name

         strTejizi = CEGUI.String(strTejizi)
         richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_LANSE)
         richBox:AppendBreak();
    end
	end
	------排除法宝
    local itemAttrTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemAttrTable.needLevel == 199 or itemAttrTable.needLevel == 199 then
        strTejizi = "  特效 无级别限制"
        strTejizi = CEGUI.String(strTejizi)
        richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_LANSE)
        richBox:AppendBreak();
    end

end



function Equiptipmaker.makeequipsit(richBox,nItemId,pEquipData)---器灵属性+
		if not pEquipData then
			return
		end
		
		local nNewTejiId = pEquipData.newskilleffect
		if nNewTejiId>0 then 
		local strequipsitzi = require "utils.mhsdutils".get_resstring(11807)
		richBox:AppendText(CEGUI.String(strequipsitzi.." "),Equiptipmaker.color_NORMAL_HUANGSE)
		richBox:AppendBreak()
		
        local newtexiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CFumoInfo"):getRecorder(nNewTejiId)---器灵属性：用于读取没有镶嵌的器灵
        if newtexiaoTable and newtexiaoTable.id ~= -1 then
        local strTeXiaozi = ""
        strTeXiaozi = " "..strTeXiaozi.." "..newtexiaoTable.name
        strTeXiaozi = CEGUI.String(strTeXiaozi)
        richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
        richBox:AppendBreak();
        end

		
		local newtexiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nNewTejiId)---器灵属性：读取的是表格：装备附魔指定特技特效库 名称1
        if newtexiaoTable and newtexiaoTable.id ~= -1 then
        local strTeXiaozi = ""
        strTeXiaozi = " "..strTeXiaozi.." "..newtexiaoTable.name1
        strTeXiaozi = CEGUI.String(strTeXiaozi)
        richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
        richBox:AppendBreak();
        end
		
		local newtexiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nNewTejiId)---器灵属性：读取的是表格：装备附魔指定特技特效库 名称2
        if newtexiaoTable and newtexiaoTable.id ~= -1 then
        local strTeXiaozi = ""
        strTeXiaozi = " "..strTeXiaozi.." "..newtexiaoTable.name2
        strTeXiaozi = CEGUI.String(strTeXiaozi)
        richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
        richBox:AppendBreak();
        end
		
		local newtexiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nNewTejiId)---器灵属性：读取的是表格：装备附魔指定特技特效库 名称3
        if newtexiaoTable and newtexiaoTable.id ~= -1 then
        local strTeXiaozi = ""
        strTeXiaozi = " "..strTeXiaozi.." "..newtexiaoTable.name3
        strTeXiaozi = CEGUI.String(strTeXiaozi)
        richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
        richBox:AppendBreak();
        end
			 
		local equipsitTable = BeanConfigManager.getInstance():GetTableByName("item.cequipsit"):getRecorder(equipsit)---套装
		if equipsitTable and equipsitTable.id ~= -1 then
		local strequipsitzi = require "utils.mhsdutils".get_resstring(11813)
		strequipsitzi = " "..strequipsitzi.." "..equipsitTable.name
	    strequipsitzi = CEGUI.String(strequipsitzi)					 
		richBox:AppendText(strequipsitzi,Equiptipmaker.color_NORMAL_LANSE)
		richBox:AppendBreak();
		end
	end
			
end

function Equiptipmaker.taozhuang(richBox,nItemId,pEquipData)---套装
		if not pEquipData then
			return
		end
			
		local equipsit = pEquipData.equipsit
		
		local equipsitTable = BeanConfigManager.getInstance():GetTableByName("item.cequipsit"):getRecorder(equipsit)---套装
		if equipsitTable and equipsitTable.id ~= -1 then
		local strequipsitzi = require "utils.mhsdutils".get_resstring(11813)
		strequipsitzi = " "..strequipsitzi.." "..equipsitTable.name
	    strequipsitzi = CEGUI.String(strequipsitzi)					 
		richBox:AppendText(strequipsitzi,Equiptipmaker.color_NORMAL_LANSE)
		richBox:AppendBreak();
		end
end

function Equiptipmaker.makeequipsit1(richBox,nItemId,pEquipData)---已镶嵌器灵名称
		if not pEquipData then
			return
		end
		
        local nNewTejiId = pEquipData.newskillid
		if nNewTejiId>0 then
		local strequipsitzi = require "utils.mhsdutils".get_resstring(11820)
        richBox:AppendBreak();		
		richBox:AppendText(CEGUI.String(strequipsitzi),Equiptipmaker.color_NORMAL_GREEN)

		
		local newtexiaoTable = BeanConfigManager.getInstance():GetTableByName("item.CSetFumoInfo"):getRecorder(nNewTejiId)---器灵属性1
        if newtexiaoTable and newtexiaoTable.id ~= -1 then
        local strTeXiaozi = require "utils.mhsdutils".get_resstring(11813)
        strTeXiaozi = ""..strTeXiaozi..""..newtexiaoTable.name
        strTeXiaozi = CEGUI.String(strTeXiaozi)
        richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_WHITE)
        richBox:AppendBreak();
        end
		end
				 				
end
	
function Equiptipmaker.makeequipsittips(richBox,nItemId,pEquipData)---套装介绍
		  if not pEquipData then
				return
		  end
			
			local equipsit = pEquipData.equipsit
			if equipsit>0 then
			local strequipsitzi = require "utils.mhsdutils".get_resstring(11807)
			
		    richBox:AppendText(CEGUI.String(strequipsitzi),Equiptipmaker.color_NORMAL_GREEN)
		    richBox:AppendBreak()
			local equipsitTable = BeanConfigManager.getInstance():GetTableByName("item.cequipsit"):getRecorder(equipsit)
				if equipsitTable and equipsitTable.id ~= -1 then
				local strequipsitzi = require "utils.mhsdutils".get_resstring(11813)
					 strequipsitzi = " "..strequipsitzi.." "..equipsitTable.tips
					-- strequipsitzi = equipsitTable.tips
					 strequipsitzi = CEGUI.String(strequipsitzi)
					 richBox:AppendText(strequipsitzi,Equiptipmaker.color_NORMAL_WHITE)
					 richBox:AppendBreak();
				end
			end
			
			
	end
function Equiptipmaker.makeEndure(richBox,nItemId,pEquipData)
    if not pEquipData then
        return
    end
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
    ---除了主界面的6件装备，其他均不显示耐久度.cc254
    if itemtypeid ~= 376 and itemtypeid ~= 392 and itemtypeid ~= 680 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 664 then
    local nEndure = pEquipData.endure
    local strNaijiuzi = require "utils.mhsdutils".get_resstring(11000)
    strNaijiuzi = strNaijiuzi.."："..tostring(nEndure)
    strNaijiuzi = CEGUI.String(strNaijiuzi)
    richBox:AppendText(strNaijiuzi,Equiptipmaker.color_NORMAL_HUANGSE)
    richBox:AppendBreak();
end
end


function Equiptipmaker.makeProducter(richBox,nItemId,pEquipData)
    if not pEquipData then
        return
    end
    local strMakerName = pEquipData.maker
    if not strMakerName then
        return
    end
	
    if string.len(strMakerName) <= 0 then
        return
    end
    --[[
    local strDzType = ""
    local nType = math.floor( nItemId / 1000000)
	if nType == 5 then
		strDzType =  require "utils.mhsdutils".get_resstring(11004);
    elseif nType == 6 then
	    strDzType =  require "utils.mhsdutils".get_resstring(11005);
	end

    if string.len(strDzType) <= 0 then
        return
    end
    --]]
	

    local strZhizuozhezi = require "utils.mhsdutils".get_resstring(11269)
    strZhizuozhezi = strZhizuozhezi..""..strMakerName.."  强化打造"
    strZhizuozhezi = CEGUI.String(strZhizuozhezi)
    richBox:AppendText(strZhizuozhezi, Equiptipmaker.color_NORMAL_HUANGSE)
    richBox:AppendBreak();


	--[[
	local itemAttrTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemAttrTable.needLevel == 0 or itemAttrTable.needLevel == 70 then
        strTejizi = "专属："..strMakerName.." 不可交易"
        strTejizi = CEGUI.String(strTejizi)
        richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_LANSE)
        richBox:AppendBreak();
    end
	--]]
	
end

function Equiptipmaker.makeScore(richBox,nItemId,pEquipData)
    if not pEquipData then
        return
    end
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    local itemtypeid = itemAttrCfg.itemtypeid
	if itemtypeid ~= 392 and itemtypeid ~= 616 and itemtypeid ~= 632 and itemtypeid ~= 648  and itemtypeid ~= 712 and itemtypeid ~= 728 and itemtypeid ~= 744 and itemtypeid ~= 664 and itemtypeid ~= 680 then
----法宝不显示评分
    local nScore = pEquipData.equipscore 
    local strPingFen =  require "utils.mhsdutils".get_resstring(111)
    strPingFen = strPingFen..tostring(nScore)

    strPingFen = CEGUI.String(strPingFen)
     richBox:AppendText(strPingFen, Equiptipmaker.color_NORMAL_HUANGSE)
   -- richBox:AppendBreak();
end
end

function Equiptipmaker.makeSex(richBox,nItemId,pEquipData)
  --  m_Tipscontainer.AppendText(sexneed == 1 ? MHSD_UTILS::GETSTRING(132) : MHSD_UTILS::GETSTRING(133), gGetDataManager()->GetMainCharacterData().sex != sexneed ? CEGUI::ColourRect(0xFFFF0000) : CEGUI::ColourRect(NORMAL_YELLOW));
	--	m_Tipscontainer.AppendBreak();
    local colorNormal = Equiptipmaker.color_NORMAL_YELLOW
    local colorRed = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffff0000"))
    local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance():getRecorder(nItemId)

    local vcnRoleId = equipEffectTable.roleNeed
    if vcnRoleId:size() > 0 then

        local nRoleId = vcnRoleId[0]
        local strRoleEquipzi = require "utils.mhsdutils".get_resstring(11349)
        if not strRoleEquipzi then
            return
        end
        --strRoleEquipzi = "111=$parameter$=222" --wangbin test
        local roleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(nRoleId)
        if roleTable.id == -1 then
            return
        end

        local roleColor = colorNormal
        if gGetDataManager() then
            local nModelId = gGetDataManager():GetMainCharacterShape()
            local nCurRoleId = nModelId%10
            if nCurRoleId ~= nRoleId then
                 roleColor = colorRed
            end
        end
		local strRoleName1 =""
			if vcnRoleId:size() > 1 then
			strRoleName1 = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(vcnRoleId[1]).name
		end
        local strRoleName = roleTable.name
        local strSexNamezi = ""
        local strZhizuozhezi = require "utils.mhsdutils".get_resstring(11349)
        strZhizuozhezi = strZhizuozhezi.."："..strRoleName.." "..strRoleName1
        strSexNamezi = CEGUI.String(strZhizuozhezi)
        richBox:AppendText(strSexNamezi, roleColor)
       -- richBox:AppendBreak()








        return
    end

    local nNeedSex = equipEffectTable.sexNeed
    --local mainRoleData = gGetDataManager():GetMainCharacterData()
    --local nCurSex = mainRoleData.sex

    if nNeedSex == 0 then
        return
    end
    local strSexNamezi = ""
    if nNeedSex == 1 then
        strSexNamezi = require "utils.mhsdutils".get_resstring(132)
    else
        strSexNamezi = require "utils.mhsdutils".get_resstring(133)
    end

    local roleColor = colorNormal
    if gGetDataManager() then
        local myData = gGetDataManager():GetMainCharacterData()
        if myData.sex ~= nNeedSex then
           roleColor = colorRed
        end
     end

    
    strSexNamezi = CEGUI.String(strSexNamezi)
    richBox:AppendText(strSexNamezi, roleColor)
   -- richBox:AppendBreak()

end

--����������ְҵ����
function Equiptipmaker.makeCareer(richBox,nItemId,pEquipData)
        local colorRed = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffff0000"))
        local colorNormal = Equiptipmaker.color_NORMAL_YELLOW
        local mainCareedId = gGetDataManager():GetMainCharacterSchoolID()
        local roleColor = colorRed
        local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance():getRecorder(nItemId)
        if not equipEffectTable then
            print("get equipEffectTable failed")
            return
        end
        --����������ֱ��return
        if equipEffectTable.eequiptype ~= 0 then
            return
        end

        local careerIds = StringBuilder.Split( equipEffectTable.needCareer, ";")
        for k,v in pairs(careerIds) do
             if v == tostring(mainCareedId) then
                    roleColor = colorNormal
                    break
             end 
        end
        local career = ""
        for k,v in pairs(careerIds) do
              local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(tonumber(v))
              if schoolinfo then
                career = schoolinfo.name.." "..career
              end
         end

        local strSexNamezi = ""
        local strZhizuozhezi = require "utils.mhsdutils".get_resstring(11431)
        strZhizuozhezi = strZhizuozhezi

        strSexNamezi = CEGUI.String(strZhizuozhezi)
        richBox:AppendText(strSexNamezi, roleColor)
    --    richBox:AppendBreak()
end

return Equiptipmaker

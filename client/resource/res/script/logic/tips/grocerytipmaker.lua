require "utils.mhsdutils"

local Grocerytipmaker = {}
local NORMAL_YELLOW = "FFFF0000"
Grocerytipmaker.nPetEquipItemTypeId = 154
--show map xy
Grocerytipmaker.nCangBaoTuTypeId = 118
Grocerytipmaker.nTypeIdCangBaoTuGaoJi = 198


Grocerytipmaker.nHeroItemTypeId = 518
Grocerytipmaker.nPetItemTypeId = 534

--show level
Grocerytipmaker.nDaZaoCaiLiaoTypeId = 422 
Grocerytipmaker.nDuanZaoShi = 310
Grocerytipmaker.nCaiFengRanLiao = 326
Grocerytipmaker.nLianJinRongJi = 342
Grocerytipmaker.nLinShiFuTypeId = 358 --��ʱ��  server level

Grocerytipmaker.color_NORMAL_YELLOW = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_YELLOW))



function Grocerytipmaker.makeTip(richBox,nItemId,pObj)
	LogInfo("Grocerytipmaker.maketips(nItemId,pObj)")
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	LogInfo("GitemAttrCfg.id="..itemAttrCfg.id)
	if not itemAttrCfg then
		LogInfo("Grocerytipmaker:makeTip=error=self.nItemId"..nItemId)
		--LogInfo("Commontipdlg:RefreshNormalInfo=error=self.nItemId"..self.nItemId)
		return false
	end
	if Grocerytipmaker.nPetEquipItemTypeId == itemAttrCfg.itemtypeid then
	 luaHandleResult = Grocerytipmaker.makeTip_petequip(richBox,nItemId,pObj)
	 end
	local luaHandleResult = false
	--//==========================================
	if  Grocerytipmaker.nCangBaoTuTypeId ==itemAttrCfg.itemtypeid or
		Grocerytipmaker.nTypeIdCangBaoTuGaoJi == itemAttrCfg.itemtypeid
	then
		--luaHandleResult = Grocerytipmaker.makeTip_cangBaoTu(commonTip,nItemId,pObj)
		--luaHandleResult = false
	--//==========================================
	
	elseif itemAttrCfg.itemtypeid==Grocerytipmaker.nDaZaoCaiLiaoTypeId then
		--luaHandleResult = Grocerytipmaker.makeTip_daZaoCaiLiao(commonTip,nItemId,pObj)
		
	elseif itemAttrCfg.itemtypeid == Grocerytipmaker.nDuanZaoShi or
	itemAttrCfg.itemtypeid == Grocerytipmaker.nCaiFengRanLiao or
	itemAttrCfg.itemtypeid == Grocerytipmaker.nLianJinRongJi 
	  then
	
    --=========================================
    elseif  Grocerytipmaker.nLinShiFuTypeId ==itemAttrCfg.itemtypeid then
        Grocerytipmaker.makeTip_fumoitem(richBox,nItemId,pObj)

    --============================
	else
		--luaHandleResult = Grocerytipmaker.makeTip_normal(commonTip,nItemId,pObj)
	end
	return true

end

function Grocerytipmaker.makeTip_normal(richBox,nItemId,pObj)
		
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	LogInfo("GitemAttrCfg.id="..itemAttrCfg.id)
	if not itemAttrCfg then
		LogInfo("Grocerytipmaker:makeTip=error=self.nItemId"..nItemId)
		--LogInfo("Commontipdlg:RefreshNormalInfo=error=self.nItemId"..self.nItemId)
		return false
	end

	return true
end


function Grocerytipmaker.makeTip_fumoitem(richBox,nItemId,pObj)
    
     local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
     if not itemAttrCfg then
        return
     end

     local pGroceryData = nil
	 if pObj then
		  pGroceryData = pObj
	 end
     local nLevel = itemAttrCfg.level
	 if pGroceryData then
		  nLevel = pGroceryData.nLevel
	 end

     if nLevel > 0 then
        
        local fumoFormula = BeanConfigManager.getInstance():GetTableByName("item.cfumoeffectformula"):getRecorder(nItemId)
        local fMin = nLevel * fumoFormula.fmin
        fMin = math.floor(fMin)
        local fMax = nLevel * fumoFormula.fmax
        fMax = math.floor(fMax)

        if fMin <= 0 then
            fMin = 1
        end

        if fMax <= 0 then
            fMax = 1
        end

        local strGongNeng = itemAttrCfg.effectdes
        --local nResultEffect = nQuality * formulaTable.nformulaa1 + formulaTable.nformulab1
		--nResultEffect = math.floor(nResultEffect)
		local sb = StringBuilder.new()
		sb:Set("parameter1",tostring(fMin))
        sb:Set("parameter2",tostring(fMax))


        -------------------
        if fumoFormula.fmin2 > 0 then
            local fMin2 = nLevel * fumoFormula.fmin2
            fMin2 = math.floor(fMin2)
            local fMax2 = nLevel * fumoFormula.fmax2
            fMax2 = math.floor(fMax2)


            if fMin2 <= 0 then
                fMin2 = 1
            end

            if fMax2 <= 0 then
                fMax2 = 1
            end
            
            sb:Set("parameter3",tostring(fMin2))
            sb:Set("parameter4",tostring(fMax2))
        end
        
        -------------------
		strGongNeng = sb:GetString(strGongNeng)
		sb:delete()

		--richBox:AppendText(CEGUI.String(strGongNeng))

        --local textColor = nil
        local textColor = require("logic.tips.commontiphelper").gongxiaoColor()
        local strDesc = strGongNeng
        require("logic.tips.commontiphelper").appendText(richBox,strDesc,textColor)

		
		richBox:AppendBreak()
     end


    
end
--[[	
function Grocerytipmaker.makeTip_cangBaoTu(commonTip,nItemId,pObj)
	LogInfo("Grocerytipmaker.makeTip_cangBaoTu(commonTip,nItemId,pObj)")
	local nMapId = -1
	local nPosX = -1
	local nPosY = -1
	
	local pGroceryData = nil
	if pObj then
		pGroceryData = pObj
	end
	if pGroceryData then
		nMapId = pGroceryData.mapID
		nPosX = pGroceryData.x
		nPosY = pGroceryData.y
	end
	
	local strZuoBiaozi = MHSD_UTILS.get_resstring(11040)
	commonTip.labelLevelTitle:setText(strZuoBiaozi)
	
	--local mapTable = 
	local strMapName = ""
	local mapCfg = GameTable.map.GetCMapConfigTableInstance():getRecorder(nMapId)
	if mapCfg.id ~= -1 then
		strMapName = mapCfg.mapName
	end
	--strMapName = strMapName.."("
	local strZuoBiaoXYzi = MHSD_UTILS.get_resstring(11047) --()
	
	--strMapName = strMapName..strZuoBiaoXYzi
	
	local sb = StringBuilder.new()
	sb:Set("parameter1",tostring(nPosX) )
	sb:Set("parameter2",tostring(nPosY) )
	strZuoBiaoXYzi = sb:GetString(strZuoBiaoXYzi)
	local strAll = strMapName..strZuoBiaoXYzi
	sb:delete()
	--local strZuoBiaoXYziCegui = CEGUI.String()
	--strMapName = strMapName..strZuoBiaoXYzi
	commonTip.labelLevel:setText(strAll)
	
	return true
end
--]]

function Grocerytipmaker.makeTip_heroItem(richBox,nItemId,pObj)
	return true
end

function Grocerytipmaker.makeTip_petItem(richBox,nItemId,pObj)
	return true
end

function Grocerytipmaker.makeTip_linShiFu(richBox,nItemId,pObj)


	return false
end

function Grocerytipmaker.makeTip_petequip(richBox,nItemId,pObj)
    local strJichushuxing = require "utils.mhsdutils".get_resstring(122)
    richBox:AppendText(CEGUI.String(strJichushuxing), Grocerytipmaker.color_NORMAL_YELLOW)
    richBox:AppendBreak()
	
	local pGroceryData = nil
	if pObj then
		pGroceryData = pObj
	end
	-- local a = pEquipData:GetPetEquipEffectAllKey()
	
	-- local vcBaseKey = pEquipData:GetPetEquipEffectAllKey()
	-- for nIndex = 1, #vcBaseKey do
        -- local nBaseId = vcBaseKey[nIndex]
        -- local nBaseValue = pEquipData:GetPetEquipEffect(nBaseId)
        -- if nBaseValue ~= 0 then
            -- local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
            -- if propertyCfg and propertyCfg.id ~= -1 then
                -- local strTitleName = propertyCfg.name
                -- local nValue = math.abs(nBaseValue)
                -- if nBaseValue > 0 then
                    -- strTitleName = strTitleName .. " " .. "+" .. tostring(nValue)
                -- elseif nBaseValue < 0 then
                    -- strTitleName = strTitleName .. " " .. "-" .. tostring(nValue)
                -- end
                -- strTitleName = "  " .. strTitleName
                -- strTitleName = CEGUI.String(strTitleName)
                -- richBox:AppendText(strTitleName, Grocerytipmaker.color_NORMAL_YELLOW)
                -- --=====================================
                -- if pObjInBody then
                    -- local nValueInBody = Grocerytipmaker.getPropertyValue(nBaseId, pObjInBody)
                    -- local nCha = nBaseValue - nValueInBody
                    -- if nCha > 0 then
                        -- richBox:AppendImage(CEGUI.String("shopui"), CEGUI.String("shop_up"));
                    -- elseif nCha < 0 then
                        -- richBox:AppendImage(CEGUI.String("shopui"), CEGUI.String("shop_down"));
                    -- end
                -- end
                -- --=====================================

                -- richBox:AppendBreak()
            -- end

        -- end
    -- end
	return true
end

-- function Grocerytipmaker.getPropertyValue(nBaseId, pObjInBody)
    -- local pEquipData = nil
    -- if pObjInBody then
        -- pEquipData = pObjInBody
    -- end

    -- if pEquipData then
        -- local vcBaseKey = pEquipData:GetPetEquipEffectAllKey()
        -- for nIndex = 1, #vcBaseKey do
            -- local nBaseIdInBody = vcBaseKey[nIndex]
            -- local nBaseValue = pEquipData:GetPetEquipEffect(nBaseId)
            -- if nBaseId == nBaseIdInBody then
                -- return nBaseValue
            -- end
        -- end
    -- end
    -- return 0
-- end


return Grocerytipmaker

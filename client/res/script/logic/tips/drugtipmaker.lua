local Drugtipmaker = {}

function Drugtipmaker.makeTip(richBox,nItemId,pObj)
	LogInfo("Drugtipmaker.maketips(nItemId,pObj)")
		
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Drugtipmaker:makeTip=error=self.nItemId"..nItemId)
		return false
	end
	local luaHandleResult = false
	luaHandleResult = Drugtipmaker.makeTip_normal(richBox,nItemId,pObj)
	return luaHandleResult
end

function Drugtipmaker.makeTip_normal(richBox,nItemId,pObj)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Drugtipmaker:makeTip_normal=error=self.nItemId"..nItemId)
		return false
	end
	local nQuality = -1
	local pDrugData = nil
	if pObj then
		pDrugData = pObj
	end
	if pDrugData then
		nQuality = pDrugData.qualiaty
	end
	--//===================================	
	local foodTable = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(nItemId)
    if not foodTable then
        return false
    end
	local strGongXiaoDes2 = foodTable.effectdescribe
	
	if nQuality > 0 then
		local formulaTable = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugformula"):getRecorder(nItemId)
		if  formulaTable and formulaTable.id ~= -1 then
			if formulaTable.neffectid1 >0 then
				local nResultEffect = nQuality * formulaTable.nformulaa1 + formulaTable.nformulab1
				nResultEffect = math.floor(nResultEffect)
				local sb = StringBuilder.new()
				sb:Set("parameter1",tostring(nResultEffect))
				strGongXiaoDes2 = sb:GetString(strGongXiaoDes2)
				sb:delete()
			end
			
			if formulaTable.neffectid2 >0 then
				local nResultEffect = nQuality * formulaTable.nformulaa2 + formulaTable.nformulab2
				nResultEffect = math.floor(nResultEffect)
				local sb = StringBuilder.new()
				sb:Set("parameter2",tostring(nResultEffect))
				strGongXiaoDes2 = sb:GetString(strGongXiaoDes2)
				sb:delete()
			end
			
			
		end
	end
	
	if nQuality > 0 then
        local color = require("logic.tips.commontiphelper").gongxiaoColor()
        local strDesc = strGongXiaoDes2
        require("logic.tips.commontiphelper").appendText(richBox,strDesc,color)
        richBox:AppendBreak()

	end
		
	--local strGongXiaozi = MHSD_UTILS.get_resstring(11038)
	--self.strPinZhizi = MHSD_UTILS.get_resstring(11039)
	return true
end




return Drugtipmaker

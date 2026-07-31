local Foodtipmaker = {}

Foodtipmaker.nTypeIdRiChangYaoPin = 66
Foodtipmaker.nTypeIdPengRen = 290
Foodtipmaker.nTypeIdPuTongYaoPin = 291
Foodtipmaker.nTypeIdGaoJiYaoPin = 275


function Foodtipmaker.makeTip(richBox,nItemId,pObj)
	LogInfo("Foodtipmaker.maketips(nItemId,pObj)")
		
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Foodtipmaker:makeTip=error=self.nItemId"..nItemId)
		return false
	end
	local luaHandleResult = false
	
	luaHandleResult = Foodtipmaker.makeTip_normal(richBox,nItemId,pObj)
	
	return luaHandleResult

end
--[[
std::wstring		effectDes; //¨C?¦Ð???¨C?
	std::vector<int>	effectVec;
	int qualiaty; //?¡Æ¡Â?
--]]
function Foodtipmaker.makeTip_normal(richBox,nItemId,pObj)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Foodtipmaker:makeTip_PengRen=error=self.nItemId"..nItemId)
		return false
	end
	--//=========================
	local nQuality = -1
	--//=========================
	local pFoodData = nil
	if pObj then
		pFoodData = pObj
	end
	if pFoodData then
		nQuality = pFoodData.qualiaty
	else
		LogInfo("Foodtipmaker=error=pFoodData=nil")
	end
	LogInfo("Foodtipmaker.makeTip_normal(richBox,nItemId,pObj)=nQuality="..nQuality)
	--//=========================
	
	
	local foodTable = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(nItemId) 
    if not foodTable then
        return false
    end
	local strGongXiaoDes2 = foodTable.effectdescribe --//¼Ó10µã parameter1
	
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
			--strGongXiaoDes2 = CEGUI.String(strGongXiaoDes2))

			
		end
	end
	
	if nQuality > 0 then
		--richBox:AppendText(CEGUI.String(strGongXiaoDes2))
       -- local textColor = nil
         local color = require("logic.tips.commontiphelper").gongxiaoColor()
        local strDesc = strGongXiaoDes2
        require("logic.tips.commontiphelper").appendText(richBox,strDesc,color)

		richBox:AppendBreak()
	end
	
		
	--local strGongXiaozi = MHSD_UTILS.get_resstring(11038)
	--self.strPinZhizi = MHSD_UTILS.get_resstring(11039)
	return true
end


return Foodtipmaker

local Petitemtipmaker = {}
local NORMAL_YELLOW = "FFFFFF00"
local NORMAL_WHITE = "FF00FF00"
local RED = "FFFF0000"

function Petitemtipmaker.makeTip(richBox,nItemId,pObj)
    Petitemtipmaker.color_NORMAL_YELLOW = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_YELLOW))
	Petitemtipmaker.color_NORMAL_WHITE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_WHITE))
	Petitemtipmaker.color_NORMAL_RED = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(RED))
	local pEquipData = nil
	if pObj then
	 pEquipData=pObj
	end
	 local vcBaseKey = pEquipData:GetPetEquipBaseEffectAllKey()
        if #vcBaseKey <= 0 then
            return
        end
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)----1
		local nShowLevel = itemAttrCfg.level
		if nShowLevel == nil or nShowLevel <= 0 then
			nShowLevel = itemAttrCfg.needLevel
		end
		local strLevelTitle = require "utils.mhsdutils".get_resstring(1)
		local strLevelValue = strLevelTitle .. ":" .. tostring(nShowLevel)
		richBox:AppendText(CEGUI.String(strLevelValue),Petitemtipmaker.color_NORMAL_YELLOW)
		richBox:AppendBreak()
		local strJichushuxing = require "utils.mhsdutils".get_resstring(11813)
        richBox:AppendText(CEGUI.String(strJichushuxing),Petitemtipmaker.color_NORMAL_YELLOW)
      --  richBox:AppendBreak()
		local strTeXiaozi = ""
        strTeXiaozi = ""..strTeXiaozi..""..itemAttrCfg.namecc1
        richBox:AppendText(CEGUI.String(strTeXiaozi),Petitemtipmaker.color_NORMAL_YELLOW)
		richBox:AppendBreak()
		for nIndex=1,#vcBaseKey do
			local nBaseId = vcBaseKey[nIndex]
		    local nBaseValue = pEquipData:GetPetEquipBaseEffect(nBaseId)
			if nBaseValue~=0 then
                local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
	            if propertyCfg and propertyCfg.id ~= -1 then
		            local strTitleName = propertyCfg.name
					local nValue = nBaseValue
					if nBaseId==1500  then
						 nValue = nBaseValue/1000
					else
						 nValue = math.abs(nBaseValue)
					end
                    if nBaseValue > 0 then
                        strTitleName = strTitleName.." ".."+"..tostring(nValue)
                    elseif nBaseValue < 0 then
                        strTitleName = strTitleName.." ".."-"..tostring(nValue)
                    end
                    strTitleName = "  "..strTitleName
                    strTitleName = CEGUI.String(strTitleName)
                    richBox:AppendText(strTitleName,Petitemtipmaker.color_NORMAL_WHITE)
                    richBox:AppendBreak()
                end

		    end
		end
		
			local equipsit = pEquipData.petequipeffect
			if equipsit>0 then 
			local strequipsitzi = require "utils.mhsdutils".get_resstring(11700)
		    richBox:AppendText(CEGUI.String(strequipsitzi..":"),Petitemtipmaker.color_NORMAL_YELLOW)
		    richBox:AppendBreak()
			local equipsitTable = BeanConfigManager.getInstance():GetTableByName("item.cpettaozhuang"):getRecorder(equipsit)
				if equipsitTable and equipsitTable.id ~= -1 then
					 strequipsitzi = equipsitTable.name
					 strequipsitzi = CEGUI.String(strequipsitzi)
					 richBox:AppendText(strequipsitzi,Petitemtipmaker.color_NORMAL_RED)
					 richBox:AppendBreak();
				end
			end
		

end



function Petitemtipmaker.makeTip_normal(commonTip,nItemId,pObj)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Petitemtipmaker:makeTip_PengRen=error=self.nItemId"..nItemId)
		return false
	end
	
	return true
end




return Petitemtipmaker

require "utils.mhsdutils"

local Gemtipmaker = {}

function Gemtipmaker.makeTip(richBox,nItemId,pObj)
	LogInfo("Gemtipmaker.maketips(nItemId,pObj)")
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Gemtipmaker:makeTip=error=self.nItemId"..nItemId)
		return
	end
	local  EFFECT_COLOR = "FFFF0000" --"ff96f3a4"	
	local gemconfig = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nItemId);
	if not gemconfig then
		LogInfo("Gemtipmaker.makeTip=error=nItemId"..nItemId)
		return false
	end
	
	--[[
	--//=======================
	local strXiaoGuozi = MHSD_UTILS.get_resstring(1379) --效果:
	commonTip.labelLevelTitle:setText(strXiaoGuozi)
	local strEffect = gemconfig.inlayeffect
	commonTip.labelLevel:setText(strEffect)
	--//=======================
	--]]
	--[[
	local strBuwei = MHSD_UTILS.get_resstring(11813)..gemconfig.inlaypos----去除宝石描述
	local color = require("logic.tips.commontiphelper").gongxiaoColor() -- CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(EFFECT_COLOR))
	richBox:AppendText(CEGUI.String(strBuwei),color)
	--richBox:AppendBreak();--]]
	
	return true
end


return Gemtipmaker

local Petitemtipmaker = {}


function Petitemtipmaker.makeTip(commonTip,nItemId,pObj)
	LogInfo("Petitemtipmaker.maketips(nItemId,pObj)")
		
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		LogInfo("Petitemtipmaker:makeTip=error=self.nItemId"..nItemId)
		return false
	end
	local luaHandleResult = false
	
	luaHandleResult = Petitemtipmaker.makeTip_normal(commonTip,nItemId,pObj)

	return true

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

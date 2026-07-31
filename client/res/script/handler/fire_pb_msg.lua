--[[
local snotifyplayeffect = require "protodef.fire.pb.msg.snotifyplayeffect"

function snotifyplayeffect:process()
	LogInfo("snotifyplayeffect process")
	if gGetGameUIManager() then
		gGetGameUIManager():PlayScreenEffect(self.effectid,0.5,0.5,true)	
	end
end
--]]

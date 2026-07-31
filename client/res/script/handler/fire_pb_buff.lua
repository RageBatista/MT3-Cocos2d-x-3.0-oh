local sbuffchangeresult = require "protodef.fire.pb.buff.sbuffchangeresult"
function sbuffchangeresult:process()
	LogInfo("sbuffchangeresult process")
	
	local  buffManager = require "manager.buffmanager".getInstance()
	buffManager:sbuffchangeresult_process(self)
	
end

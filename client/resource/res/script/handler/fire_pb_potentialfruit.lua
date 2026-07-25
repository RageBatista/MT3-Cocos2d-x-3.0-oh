local p = require "protodef.fire.pb.potentialfruit.syncpotentialfruit"
function p:process()
	local dlg=require "logic.characterinfo.characterxiulianguodlg".getInstanceNotCreate()
	if dlg then
		dlg:refreshHaveFruit(self)
	end
end
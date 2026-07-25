
local p = require "protodef.fire.pb.product.sproductmadeup"
function p:process()
	print("protodef.fire.pb.product.sproductmadeup")
	local dzDlg = require "logic.workshop.workshopdznew"
	dzDlg.OnDzResult(self)
end

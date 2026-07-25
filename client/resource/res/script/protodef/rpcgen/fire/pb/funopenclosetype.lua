require "utils.tableutil"
FunOpenCloseType = {
	FUN_REDPACK = 1,
	FUN_JHM = 2,
	FUN_CHECKPOINT = 3,
	FUN_MONTHCARD = 4,
	FUN_BLACKMARKET = 5
}
FunOpenCloseType.__index = FunOpenCloseType


function FunOpenCloseType:new()
	local self = {}
	setmetatable(self, FunOpenCloseType)
	return self
end
function FunOpenCloseType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function FunOpenCloseType:unmarshal(_os_)
	return _os_
end

return FunOpenCloseType

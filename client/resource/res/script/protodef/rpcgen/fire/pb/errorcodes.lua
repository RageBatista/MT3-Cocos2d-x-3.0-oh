require "utils.tableutil"
ErrorCodes = {
	NoError = 0,
	AddItemToBagException = 1,
	NotEnoughMoney = 2,
	EquipPosNotSuit = 3,
	EquipLevelNotSuit = 4,
	EquipSexNotSuit = 5
}
ErrorCodes.__index = ErrorCodes


function ErrorCodes:new()
	local self = {}
	setmetatable(self, ErrorCodes)
	return self
end
function ErrorCodes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function ErrorCodes:unmarshal(_os_)
	return _os_
end

return ErrorCodes

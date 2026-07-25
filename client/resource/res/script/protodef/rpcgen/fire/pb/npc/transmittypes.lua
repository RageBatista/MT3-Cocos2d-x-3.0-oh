require "utils.tableutil"
TransmitTypes = {
	impexamsystem = 4,
	winnercall = 5,
	backschoolwhile20lv = 6,
	singlepvp = 10,
	pvp3 = 15,
	pvp5 = 16
}
TransmitTypes.__index = TransmitTypes


function TransmitTypes:new()
	local self = {}
	setmetatable(self, TransmitTypes)
	return self
end
function TransmitTypes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function TransmitTypes:unmarshal(_os_)
	return _os_
end

return TransmitTypes

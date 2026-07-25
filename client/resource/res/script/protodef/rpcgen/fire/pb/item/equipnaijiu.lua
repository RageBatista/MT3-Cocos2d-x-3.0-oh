require "utils.tableutil"
EquipNaiJiu = {}
EquipNaiJiu.__index = EquipNaiJiu


function EquipNaiJiu:new()
	local self = {}
	setmetatable(self, EquipNaiJiu)
	self.keyinpack = 0
	self.endure = 0

	return self
end
function EquipNaiJiu:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.endure)
	return _os_
end

function EquipNaiJiu:unmarshal(_os_)
	self.keyinpack = _os_:unmarshal_int32()
	self.endure = _os_:unmarshal_int32()
	return _os_
end

return EquipNaiJiu

require "utils.tableutil"
PetRecoverInfoBean = {}
PetRecoverInfoBean.__index = PetRecoverInfoBean


function PetRecoverInfoBean:new()
	local self = {}
	setmetatable(self, PetRecoverInfoBean)
	self.petid = 0
	self.uniqid = 0
	self.remaintime = 0
	self.cost = 0

	return self
end
function PetRecoverInfoBean:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petid)
	_os_:marshal_int64(self.uniqid)
	_os_:marshal_int32(self.remaintime)
	_os_:marshal_int32(self.cost)
	return _os_
end

function PetRecoverInfoBean:unmarshal(_os_)
	self.petid = _os_:unmarshal_int32()
	self.uniqid = _os_:unmarshal_int64()
	self.remaintime = _os_:unmarshal_int32()
	self.cost = _os_:unmarshal_int32()
	return _os_
end

return PetRecoverInfoBean

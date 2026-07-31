require "utils.tableutil"
COpenPotentialFruit = {}
COpenPotentialFruit.__index = COpenPotentialFruit



COpenPotentialFruit.PROTOCOL_TYPE = 810496

function COpenPotentialFruit.Create()
	print("enter COpenPotentialFruit create")
	return COpenPotentialFruit:new()
end
function COpenPotentialFruit:new()
	local self = {}
	setmetatable(self, COpenPotentialFruit)
	self.type = self.PROTOCOL_TYPE
	self.location = 0

	return self
end
function COpenPotentialFruit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COpenPotentialFruit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.location)
	return _os_
end

function COpenPotentialFruit:unmarshal(_os_)
	self.location = _os_:unmarshal_int32()
	return _os_
end

return COpenPotentialFruit

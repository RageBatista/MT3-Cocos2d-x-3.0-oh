require "utils.tableutil"
SRefreshPetColumnCapacity = {}
SRefreshPetColumnCapacity.__index = SRefreshPetColumnCapacity



SRefreshPetColumnCapacity.PROTOCOL_TYPE = 788458

function SRefreshPetColumnCapacity.Create()
	print("enter SRefreshPetColumnCapacity create")
	return SRefreshPetColumnCapacity:new()
end
function SRefreshPetColumnCapacity:new()
	local self = {}
	setmetatable(self, SRefreshPetColumnCapacity)
	self.type = self.PROTOCOL_TYPE
	self.columnid = 0
	self.capacity = 0

	return self
end
function SRefreshPetColumnCapacity:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPetColumnCapacity:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.columnid)
	_os_:marshal_int32(self.capacity)
	return _os_
end

function SRefreshPetColumnCapacity:unmarshal(_os_)
	self.columnid = _os_:unmarshal_int32()
	self.capacity = _os_:unmarshal_int32()
	return _os_
end

return SRefreshPetColumnCapacity

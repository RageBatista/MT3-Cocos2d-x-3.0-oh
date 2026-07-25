require "utils.tableutil"
CPetLevelUpInternal = {}
CPetLevelUpInternal.__index = CPetLevelUpInternal



CPetLevelUpInternal.PROTOCOL_TYPE = 788531

function CPetLevelUpInternal.Create()
	print("enter CPetLevelUpInternal create")
	return CPetLevelUpInternal:new()
end
function CPetLevelUpInternal:new()
	local self = {}
	setmetatable(self, CPetLevelUpInternal)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.internalid = 0
	

	return self
end
function CPetLevelUpInternal:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetLevelUpInternal:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.internalid)
	return _os_
end

function CPetLevelUpInternal:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.internalid = _os_:unmarshal_int32()
	return _os_
end

return CPetLevelUpInternal

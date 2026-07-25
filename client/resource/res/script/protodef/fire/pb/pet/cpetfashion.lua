require "utils.tableutil"
CPetFashion = {}
CPetFashion.__index = CPetFashion



CPetFashion.PROTOCOL_TYPE = 800550

function CPetFashion.Create()
	print("enter CPetFashion create")
	return CPetFashion:new()
end
function CPetFashion:new()
	local self = {}
	setmetatable(self, CPetFashion)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.resultkey = 0
	self.defaulttype = 0
	return self
end
function CPetFashion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetFashion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.resultkey)
	_os_:marshal_int32(self.defaulttype)
	return _os_
end

function CPetFashion:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.resultkey = _os_:unmarshal_int32()
	self.defaulttype = _os_:unmarshal_int32()
	return _os_
end

return CPetFashion

require "utils.tableutil"
CPetSynthesize = {}
CPetSynthesize.__index = CPetSynthesize



CPetSynthesize.PROTOCOL_TYPE = 788517

function CPetSynthesize.Create()
	print("enter CPetSynthesize create")
	return CPetSynthesize:new()
end
function CPetSynthesize:new()
	local self = {}
	setmetatable(self, CPetSynthesize)
	self.type = self.PROTOCOL_TYPE
	self.petkey1 = 0
	self.petkey2 = 0

	return self
end
function CPetSynthesize:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetSynthesize:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey1)
	_os_:marshal_int32(self.petkey2)
	return _os_
end

function CPetSynthesize:unmarshal(_os_)
	self.petkey1 = _os_:unmarshal_int32()
	self.petkey2 = _os_:unmarshal_int32()
	return _os_
end

return CPetSynthesize

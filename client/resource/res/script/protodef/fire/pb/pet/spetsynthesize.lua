require "utils.tableutil"
SPetSynthesize = {}
SPetSynthesize.__index = SPetSynthesize



SPetSynthesize.PROTOCOL_TYPE = 788518

function SPetSynthesize.Create()
	print("enter SPetSynthesize create")
	return SPetSynthesize:new()
end
function SPetSynthesize:new()
	local self = {}
	setmetatable(self, SPetSynthesize)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0

	return self
end
function SPetSynthesize:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPetSynthesize:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	return _os_
end

function SPetSynthesize:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return SPetSynthesize

require "utils.tableutil"
CBuyMedic = {}
CBuyMedic.__index = CBuyMedic



CBuyMedic.PROTOCOL_TYPE = 808441

function CBuyMedic.Create()
	print("enter CBuyMedic create")
	return CBuyMedic:new()
end
function CBuyMedic:new()
	local self = {}
	setmetatable(self, CBuyMedic)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.itemnum = 0

	return self
end
function CBuyMedic:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBuyMedic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.itemnum)
	return _os_
end

function CBuyMedic:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_int32()
	return _os_
end

return CBuyMedic

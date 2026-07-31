require "utils.tableutil"
SPetAptitudeCultivatee = {}
SPetAptitudeCultivatee.__index = SPetAptitudeCultivatee



SPetAptitudeCultivatee.PROTOCOL_TYPE = 817964

function SPetAptitudeCultivatee.Create()
	print("enter SPetAptitudeCultivatee create")
	return SPetAptitudeCultivatee:new()
end
function SPetAptitudeCultivatee:new()
	local self = {}
	setmetatable(self, SPetAptitudeCultivatee)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.aptid = 0
	self.aptvalue = 0

	return self
end
function SPetAptitudeCultivatee:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPetAptitudeCultivatee:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.aptid)
	_os_:marshal_int32(self.aptvalue)
	return _os_
end

function SPetAptitudeCultivatee:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.aptid = _os_:unmarshal_int32()
	self.aptvalue = _os_:unmarshal_int32()
	return _os_
end

return SPetAptitudeCultivatee

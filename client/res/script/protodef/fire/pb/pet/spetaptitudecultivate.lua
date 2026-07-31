require "utils.tableutil"
SPetAptitudeCultivate = {}
SPetAptitudeCultivate.__index = SPetAptitudeCultivate



SPetAptitudeCultivate.PROTOCOL_TYPE = 788522

function SPetAptitudeCultivate.Create()
	print("enter SPetAptitudeCultivate create")
	return SPetAptitudeCultivate:new()
end
function SPetAptitudeCultivate:new()
	local self = {}
	setmetatable(self, SPetAptitudeCultivate)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.aptid = 0
	self.aptvalue = 0

	return self
end
function SPetAptitudeCultivate:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPetAptitudeCultivate:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.aptid)
	_os_:marshal_int32(self.aptvalue)
	return _os_
end

function SPetAptitudeCultivate:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.aptid = _os_:unmarshal_int32()
	self.aptvalue = _os_:unmarshal_int32()
	return _os_
end

return SPetAptitudeCultivate

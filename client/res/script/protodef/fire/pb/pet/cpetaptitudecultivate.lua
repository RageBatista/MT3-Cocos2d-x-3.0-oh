require "utils.tableutil"
CPetAptitudeCultivate = {}
CPetAptitudeCultivate.__index = CPetAptitudeCultivate



CPetAptitudeCultivate.PROTOCOL_TYPE = 788521

function CPetAptitudeCultivate.Create()
	print("enter CPetAptitudeCultivate create")
	return CPetAptitudeCultivate:new()
end
function CPetAptitudeCultivate:new()
	local self = {}
	setmetatable(self, CPetAptitudeCultivate)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.aptid = 0
	self.itemkey = 0

	return self
end
function CPetAptitudeCultivate:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetAptitudeCultivate:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.aptid)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CPetAptitudeCultivate:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.aptid = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CPetAptitudeCultivate

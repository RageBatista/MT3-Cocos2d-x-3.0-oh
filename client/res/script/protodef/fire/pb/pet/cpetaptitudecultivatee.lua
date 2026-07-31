require "utils.tableutil"
CPetAptitudeCultivatee = {}
CPetAptitudeCultivatee.__index = CPetAptitudeCultivatee



CPetAptitudeCultivatee.PROTOCOL_TYPE = 817963

function CPetAptitudeCultivatee.Create()
	print("enter CPetAptitudeCultivatee create")
	return CPetAptitudeCultivatee:new()
end
function CPetAptitudeCultivatee:new()
	local self = {}
	setmetatable(self, CPetAptitudeCultivatee)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.aptid = 0
	self.itemkey = 0

	return self
end
function CPetAptitudeCultivatee:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetAptitudeCultivatee:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.aptid)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CPetAptitudeCultivatee:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.aptid = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CPetAptitudeCultivatee

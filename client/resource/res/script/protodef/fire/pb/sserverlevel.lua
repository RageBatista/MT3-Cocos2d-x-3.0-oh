require "utils.tableutil"
SServerLevel = {}
SServerLevel.__index = SServerLevel



SServerLevel.PROTOCOL_TYPE = 786521

function SServerLevel.Create()
	print("enter SServerLevel create")
	return SServerLevel:new()
end
function SServerLevel:new()
	local self = {}
	setmetatable(self, SServerLevel)
	self.type = self.PROTOCOL_TYPE
	self.slevel = 0
	self.newleveldays = 0

	return self
end
function SServerLevel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SServerLevel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.slevel)
	_os_:marshal_int32(self.newleveldays)
	return _os_
end

function SServerLevel:unmarshal(_os_)
	self.slevel = _os_:unmarshal_int32()
	self.newleveldays = _os_:unmarshal_int32()
	return _os_
end

return SServerLevel

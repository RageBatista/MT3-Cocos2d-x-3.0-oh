require "utils.tableutil"
SRuneGive = {}
SRuneGive.__index = SRuneGive



SRuneGive.PROTOCOL_TYPE = 808510

function SRuneGive.Create()
	print("enter SRuneGive create")
	return SRuneGive:new()
end
function SRuneGive:new()
	local self = {}
	setmetatable(self, SRuneGive)
	self.type = self.PROTOCOL_TYPE
	self.givevalue = 0

	return self
end
function SRuneGive:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRuneGive:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.givevalue)
	return _os_
end

function SRuneGive:unmarshal(_os_)
	self.givevalue = _os_:unmarshal_int32()
	return _os_
end

return SRuneGive

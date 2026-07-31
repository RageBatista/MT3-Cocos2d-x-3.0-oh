require "utils.tableutil"
SGACDKickoutMsg1 = {}
SGACDKickoutMsg1.__index = SGACDKickoutMsg1



SGACDKickoutMsg1.PROTOCOL_TYPE = 786519

function SGACDKickoutMsg1.Create()
	print("enter SGACDKickoutMsg1 create")
	return SGACDKickoutMsg1:new()
end
function SGACDKickoutMsg1:new()
	local self = {}
	setmetatable(self, SGACDKickoutMsg1)
	self.type = self.PROTOCOL_TYPE
	self.msg = "" 

	return self
end
function SGACDKickoutMsg1:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGACDKickoutMsg1:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.msg)
	return _os_
end

function SGACDKickoutMsg1:unmarshal(_os_)
	self.msg = _os_:unmarshal_wstring(self.msg)
	return _os_
end

return SGACDKickoutMsg1

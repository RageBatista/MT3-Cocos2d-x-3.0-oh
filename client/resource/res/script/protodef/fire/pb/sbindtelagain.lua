require "utils.tableutil"
SBindTelAgain = {}
SBindTelAgain.__index = SBindTelAgain



SBindTelAgain.PROTOCOL_TYPE = 786563

function SBindTelAgain.Create()
	print("enter SBindTelAgain create")
	return SBindTelAgain:new()
end
function SBindTelAgain:new()
	local self = {}
	setmetatable(self, SBindTelAgain)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SBindTelAgain:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBindTelAgain:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SBindTelAgain:unmarshal(_os_)
	return _os_
end

return SBindTelAgain

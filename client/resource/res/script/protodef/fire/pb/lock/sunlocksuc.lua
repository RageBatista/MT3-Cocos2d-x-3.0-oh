require "utils.tableutil"
SUnlockSuc = {}
SUnlockSuc.__index = SUnlockSuc



SUnlockSuc.PROTOCOL_TYPE = 818942

function SUnlockSuc.Create()
	print("enter SUnlockSuc create")
	return SUnlockSuc:new()
end
function SUnlockSuc:new()
	local self = {}
	setmetatable(self, SUnlockSuc)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SUnlockSuc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUnlockSuc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SUnlockSuc:unmarshal(_os_)
	return _os_
end

return SUnlockSuc

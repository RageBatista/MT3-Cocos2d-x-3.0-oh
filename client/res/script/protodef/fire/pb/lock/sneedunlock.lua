require "utils.tableutil"
SNeedUnlock = {}
SNeedUnlock.__index = SNeedUnlock



SNeedUnlock.PROTOCOL_TYPE = 818940

function SNeedUnlock.Create()
	print("enter SNeedUnlock create")
	return SNeedUnlock:new()
end
function SNeedUnlock:new()
	local self = {}
	setmetatable(self, SNeedUnlock)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SNeedUnlock:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNeedUnlock:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SNeedUnlock:unmarshal(_os_)
	return _os_
end

return SNeedUnlock

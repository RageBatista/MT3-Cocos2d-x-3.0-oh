require "utils.tableutil"
CEnterClanMap = {}
CEnterClanMap.__index = CEnterClanMap



CEnterClanMap.PROTOCOL_TYPE = 808491

function CEnterClanMap.Create()
	print("enter CEnterClanMap create")
	return CEnterClanMap:new()
end
function CEnterClanMap:new()
	local self = {}
	setmetatable(self, CEnterClanMap)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CEnterClanMap:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CEnterClanMap:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CEnterClanMap:unmarshal(_os_)
	return _os_
end

return CEnterClanMap

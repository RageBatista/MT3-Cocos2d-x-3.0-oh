require "utils.tableutil"
CStartFortuneWheel = {}
CStartFortuneWheel.__index = CStartFortuneWheel



CStartFortuneWheel.PROTOCOL_TYPE = 795494

function CStartFortuneWheel.Create()
	print("enter CStartFortuneWheel create")
	return CStartFortuneWheel:new()
end
function CStartFortuneWheel:new()
	local self = {}
	setmetatable(self, CStartFortuneWheel)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0

	return self
end
function CStartFortuneWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CStartFortuneWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CStartFortuneWheel:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CStartFortuneWheel

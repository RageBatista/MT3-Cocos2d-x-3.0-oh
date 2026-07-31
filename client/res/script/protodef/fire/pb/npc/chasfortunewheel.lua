require "utils.tableutil"
CHasFortuneWheel = {}
CHasFortuneWheel.__index = CHasFortuneWheel



CHasFortuneWheel.PROTOCOL_TYPE = 795495

function CHasFortuneWheel.Create()
	print("enter CHasFortuneWheel create")
	return CHasFortuneWheel:new()
end
function CHasFortuneWheel:new()
	local self = {}
	setmetatable(self, CHasFortuneWheel)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0

	return self
end
function CHasFortuneWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CHasFortuneWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CHasFortuneWheel:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CHasFortuneWheel

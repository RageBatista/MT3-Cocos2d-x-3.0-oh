require "utils.tableutil"
CFinishFortuneWheel = {}
CFinishFortuneWheel.__index = CFinishFortuneWheel



CFinishFortuneWheel.PROTOCOL_TYPE = 795446

function CFinishFortuneWheel.Create()
	print("enter CFinishFortuneWheel create")
	return CFinishFortuneWheel:new()
end
function CFinishFortuneWheel:new()
	local self = {}
	setmetatable(self, CFinishFortuneWheel)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.serviceid = 0

	return self
end
function CFinishFortuneWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFinishFortuneWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.serviceid)
	return _os_
end

function CFinishFortuneWheel:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.serviceid = _os_:unmarshal_int32()
	return _os_
end

return CFinishFortuneWheel

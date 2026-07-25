require "utils.tableutil"
CDoneFortuneWheel = {}
CDoneFortuneWheel.__index = CDoneFortuneWheel



CDoneFortuneWheel.PROTOCOL_TYPE = 795457

function CDoneFortuneWheel.Create()
	print("enter CDoneFortuneWheel create")
	return CDoneFortuneWheel:new()
end
function CDoneFortuneWheel:new()
	local self = {}
	setmetatable(self, CDoneFortuneWheel)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.taskid = 0
	self.succ = 0
	self.flag = 0

	return self
end
function CDoneFortuneWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDoneFortuneWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.taskid)
	_os_:marshal_int32(self.succ)
	_os_:marshal_char(self.flag)
	return _os_
end

function CDoneFortuneWheel:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.taskid = _os_:unmarshal_int32()
	self.succ = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_char()
	return _os_
end

return CDoneFortuneWheel

require "utils.tableutil"
SSendImpExamStart = {}
SSendImpExamStart.__index = SSendImpExamStart



SSendImpExamStart.PROTOCOL_TYPE = 795465

function SSendImpExamStart.Create()
	print("enter SSendImpExamStart create")
	return SSendImpExamStart:new()
end
function SSendImpExamStart:new()
	local self = {}
	setmetatable(self, SSendImpExamStart)
	self.type = self.PROTOCOL_TYPE
	self.remaintime = 0
	self.impexamtype = 0
	self.historymaxright = 0
	self.historymintime = 0

	return self
end
function SSendImpExamStart:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendImpExamStart:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.remaintime)
	_os_:marshal_char(self.impexamtype)
	_os_:marshal_int32(self.historymaxright)
	_os_:marshal_int64(self.historymintime)
	return _os_
end

function SSendImpExamStart:unmarshal(_os_)
	self.remaintime = _os_:unmarshal_int64()
	self.impexamtype = _os_:unmarshal_char()
	self.historymaxright = _os_:unmarshal_int32()
	self.historymintime = _os_:unmarshal_int64()
	return _os_
end

return SSendImpExamStart

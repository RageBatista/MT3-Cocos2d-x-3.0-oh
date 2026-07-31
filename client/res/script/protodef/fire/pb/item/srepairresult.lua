require "utils.tableutil"
SRepairResult = {}
SRepairResult.__index = SRepairResult



SRepairResult.PROTOCOL_TYPE = 787761

function SRepairResult.Create()
	print("enter SRepairResult create")
	return SRepairResult:new()
end
function SRepairResult:new()
	local self = {}
	setmetatable(self, SRepairResult)
	self.type = self.PROTOCOL_TYPE
	self.ret = 0

	return self
end
function SRepairResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRepairResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ret)
	return _os_
end

function SRepairResult:unmarshal(_os_)
	self.ret = _os_:unmarshal_int32()
	return _os_
end

return SRepairResult

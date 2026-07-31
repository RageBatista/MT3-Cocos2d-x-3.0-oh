require "utils.tableutil"
SCheckCodeFinishTime = {}
SCheckCodeFinishTime.__index = SCheckCodeFinishTime



SCheckCodeFinishTime.PROTOCOL_TYPE = 786560

function SCheckCodeFinishTime.Create()
	print("enter SCheckCodeFinishTime create")
	return SCheckCodeFinishTime:new()
end
function SCheckCodeFinishTime:new()
	local self = {}
	setmetatable(self, SCheckCodeFinishTime)
	self.type = self.PROTOCOL_TYPE
	self.finishtimepoint = 0

	return self
end
function SCheckCodeFinishTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCheckCodeFinishTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.finishtimepoint)
	return _os_
end

function SCheckCodeFinishTime:unmarshal(_os_)
	self.finishtimepoint = _os_:unmarshal_int64()
	return _os_
end

return SCheckCodeFinishTime

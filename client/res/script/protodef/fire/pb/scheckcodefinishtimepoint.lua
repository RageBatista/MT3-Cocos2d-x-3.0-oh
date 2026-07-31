require "utils.tableutil"
SCheckCodeFinishTimePoint = {}
SCheckCodeFinishTimePoint.__index = SCheckCodeFinishTimePoint



SCheckCodeFinishTimePoint.PROTOCOL_TYPE = 786571

function SCheckCodeFinishTimePoint.Create()
	print("enter SCheckCodeFinishTimePoint create")
	return SCheckCodeFinishTimePoint:new()
end
function SCheckCodeFinishTimePoint:new()
	local self = {}
	setmetatable(self, SCheckCodeFinishTimePoint)
	self.type = self.PROTOCOL_TYPE
	self.checkcodetype = 0
	self.finishtimepoint = 0

	return self
end
function SCheckCodeFinishTimePoint:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCheckCodeFinishTimePoint:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.checkcodetype)
	_os_:marshal_int64(self.finishtimepoint)
	return _os_
end

function SCheckCodeFinishTimePoint:unmarshal(_os_)
	self.checkcodetype = _os_:unmarshal_char()
	self.finishtimepoint = _os_:unmarshal_int64()
	return _os_
end

return SCheckCodeFinishTimePoint

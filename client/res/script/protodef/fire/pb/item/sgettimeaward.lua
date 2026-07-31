require "utils.tableutil"
SGetTimeAward = {}
SGetTimeAward.__index = SGetTimeAward



SGetTimeAward.PROTOCOL_TYPE = 787507

function SGetTimeAward.Create()
	print("enter SGetTimeAward create")
	return SGetTimeAward:new()
end
function SGetTimeAward:new()
	local self = {}
	setmetatable(self, SGetTimeAward)
	self.type = self.PROTOCOL_TYPE
	self.awardid = 0
	self.waittime = 0

	return self
end
function SGetTimeAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetTimeAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.awardid)
	_os_:marshal_int64(self.waittime)
	return _os_
end

function SGetTimeAward:unmarshal(_os_)
	self.awardid = _os_:unmarshal_int32()
	self.waittime = _os_:unmarshal_int64()
	return _os_
end

return SGetTimeAward

require "utils.tableutil"
CRefreshDayAward = {}
CRefreshDayAward.__index = CRefreshDayAward



CRefreshDayAward.PROTOCOL_TYPE = 817971

function CRefreshDayAward.Create()
	print("enter CRefreshDayAward create")
	return CRefreshDayAward:new()
end
function CRefreshDayAward:new()
	local self = {}
	setmetatable(self, CRefreshDayAward)
	self.type = self.PROTOCOL_TYPE

	return self
end
function CRefreshDayAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRefreshDayAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRefreshDayAward:unmarshal(_os_)
	return _os_
end

return CRefreshDayAward

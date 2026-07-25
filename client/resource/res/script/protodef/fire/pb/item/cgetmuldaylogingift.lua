require "utils.tableutil"
CGetMulDayLoginGift = {}
CGetMulDayLoginGift.__index = CGetMulDayLoginGift



CGetMulDayLoginGift.PROTOCOL_TYPE = 787732

function CGetMulDayLoginGift.Create()
	print("enter CGetMulDayLoginGift create")
	return CGetMulDayLoginGift:new()
end
function CGetMulDayLoginGift:new()
	local self = {}
	setmetatable(self, CGetMulDayLoginGift)
	self.type = self.PROTOCOL_TYPE
	self.rewardid = 0

	return self
end
function CGetMulDayLoginGift:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetMulDayLoginGift:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.rewardid)
	return _os_
end

function CGetMulDayLoginGift:unmarshal(_os_)
	self.rewardid = _os_:unmarshal_char()
	return _os_
end

return CGetMulDayLoginGift

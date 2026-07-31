require "utils.tableutil"
CReqLianYaoAward = {}
CReqLianYaoAward.__index = CReqLianYaoAward



CReqLianYaoAward.PROTOCOL_TYPE = 810518

function CReqLianYaoAward.Create()
	print("enter CReqLianYaoAward create")
	return CReqLianYaoAward:new()
end
function CReqLianYaoAward:new()
	local self = {}
	setmetatable(self, CReqLianYaoAward)
	self.type = self.PROTOCOL_TYPE
	self.awardid = 0

	return self
end
function CReqLianYaoAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqLianYaoAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.awardid)
	return _os_
end

function CReqLianYaoAward:unmarshal(_os_)
	self.awardid = _os_:unmarshal_int32()
	return _os_
end

return CReqLianYaoAward

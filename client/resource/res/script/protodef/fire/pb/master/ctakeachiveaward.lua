require "utils.tableutil"
CTakeAchiveAward = {}
CTakeAchiveAward.__index = CTakeAchiveAward



CTakeAchiveAward.PROTOCOL_TYPE = 816482

function CTakeAchiveAward.Create()
	print("enter CTakeAchiveAward create")
	return CTakeAchiveAward:new()
end
function CTakeAchiveAward:new()
	local self = {}
	setmetatable(self, CTakeAchiveAward)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.key = 0

	return self
end
function CTakeAchiveAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CTakeAchiveAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.key)
	return _os_
end

function CTakeAchiveAward:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.key = _os_:unmarshal_int32()
	return _os_
end

return CTakeAchiveAward

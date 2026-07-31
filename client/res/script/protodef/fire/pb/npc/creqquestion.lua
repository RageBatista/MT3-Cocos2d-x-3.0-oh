require "utils.tableutil"
CReqQuestion = {}
CReqQuestion.__index = CReqQuestion



CReqQuestion.PROTOCOL_TYPE = 795439

function CReqQuestion.Create()
	print("enter CReqQuestion create")
	return CReqQuestion:new()
end
function CReqQuestion:new()
	local self = {}
	setmetatable(self, CReqQuestion)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0

	return self
end
function CReqQuestion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqQuestion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CReqQuestion:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CReqQuestion

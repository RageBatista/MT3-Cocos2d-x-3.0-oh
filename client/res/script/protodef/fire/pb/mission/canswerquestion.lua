require "utils.tableutil"
CAnswerQuestion = {}
CAnswerQuestion.__index = CAnswerQuestion



CAnswerQuestion.PROTOCOL_TYPE = 805448

function CAnswerQuestion.Create()
	print("enter CAnswerQuestion create")
	return CAnswerQuestion:new()
end
function CAnswerQuestion:new()
	local self = {}
	setmetatable(self, CAnswerQuestion)
	self.type = self.PROTOCOL_TYPE
	self.missionid = 0
	self.npckey = 0
	self.answerid = 0

	return self
end
function CAnswerQuestion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAnswerQuestion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.missionid)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.answerid)
	return _os_
end

function CAnswerQuestion:unmarshal(_os_)
	self.missionid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.answerid = _os_:unmarshal_int32()
	return _os_
end

return CAnswerQuestion

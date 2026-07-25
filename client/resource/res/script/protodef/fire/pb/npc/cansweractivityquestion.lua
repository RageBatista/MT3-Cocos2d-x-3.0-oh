require "utils.tableutil"
CAnswerActivityQuestion = {}
CAnswerActivityQuestion.__index = CAnswerActivityQuestion



CAnswerActivityQuestion.PROTOCOL_TYPE = 795533

function CAnswerActivityQuestion.Create()
	print("enter CAnswerActivityQuestion create")
	return CAnswerActivityQuestion:new()
end
function CAnswerActivityQuestion:new()
	local self = {}
	setmetatable(self, CAnswerActivityQuestion)
	self.type = self.PROTOCOL_TYPE
	self.questionid = 0
	self.answerid = 0
	self.xiangguanid = 0

	return self
end
function CAnswerActivityQuestion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAnswerActivityQuestion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questionid)
	_os_:marshal_int32(self.answerid)
	_os_:marshal_int32(self.xiangguanid)
	return _os_
end

function CAnswerActivityQuestion:unmarshal(_os_)
	self.questionid = _os_:unmarshal_int32()
	self.answerid = _os_:unmarshal_int32()
	self.xiangguanid = _os_:unmarshal_int32()
	return _os_
end

return CAnswerActivityQuestion

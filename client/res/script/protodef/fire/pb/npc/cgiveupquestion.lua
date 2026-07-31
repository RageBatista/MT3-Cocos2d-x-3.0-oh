require "utils.tableutil"
CGiveUpQuestion = {}
CGiveUpQuestion.__index = CGiveUpQuestion



CGiveUpQuestion.PROTOCOL_TYPE = 795523

function CGiveUpQuestion.Create()
	print("enter CGiveUpQuestion create")
	return CGiveUpQuestion:new()
end
function CGiveUpQuestion:new()
	local self = {}
	setmetatable(self, CGiveUpQuestion)
	self.type = self.PROTOCOL_TYPE
	self.questiontype = 0
	self.npckey = 0

	return self
end
function CGiveUpQuestion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGiveUpQuestion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questiontype)
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CGiveUpQuestion:unmarshal(_os_)
	self.questiontype = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CGiveUpQuestion

require "utils.tableutil"
SAnswerInstance = {}
SAnswerInstance.__index = SAnswerInstance



SAnswerInstance.PROTOCOL_TYPE = 805546

function SAnswerInstance.Create()
	print("enter SAnswerInstance create")
	return SAnswerInstance:new()
end
function SAnswerInstance:new()
	local self = {}
	setmetatable(self, SAnswerInstance)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.answer = 0

	return self
end
function SAnswerInstance:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAnswerInstance:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_short(self.answer)
	return _os_
end

function SAnswerInstance:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.answer = _os_:unmarshal_short()
	return _os_
end

return SAnswerInstance

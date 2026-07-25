require "utils.tableutil"
CAnswerforCallBack = {}
CAnswerforCallBack.__index = CAnswerforCallBack



CAnswerforCallBack.PROTOCOL_TYPE = 794457

function CAnswerforCallBack.Create()
	print("enter CAnswerforCallBack create")
	return CAnswerforCallBack:new()
end
function CAnswerforCallBack:new()
	local self = {}
	setmetatable(self, CAnswerforCallBack)
	self.type = self.PROTOCOL_TYPE
	self.agree = 0

	return self
end
function CAnswerforCallBack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAnswerforCallBack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.agree)
	return _os_
end

function CAnswerforCallBack:unmarshal(_os_)
	self.agree = _os_:unmarshal_char()
	return _os_
end

return CAnswerforCallBack

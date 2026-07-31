require "utils.tableutil"
CClanMessage = {}
CClanMessage.__index = CClanMessage



CClanMessage.PROTOCOL_TYPE = 808469

function CClanMessage.Create()
	print("enter CClanMessage create")
	return CClanMessage:new()
end
function CClanMessage:new()
	local self = {}
	setmetatable(self, CClanMessage)
	self.type = self.PROTOCOL_TYPE
	self.message = "" 

	return self
end
function CClanMessage:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CClanMessage:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.message)
	return _os_
end

function CClanMessage:unmarshal(_os_)
	self.message = _os_:unmarshal_wstring(self.message)
	return _os_
end

return CClanMessage

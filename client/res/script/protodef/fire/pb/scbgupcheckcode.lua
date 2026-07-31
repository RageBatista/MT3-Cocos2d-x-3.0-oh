require "utils.tableutil"
SCBGUpCheckCode = {}
SCBGUpCheckCode.__index = SCBGUpCheckCode



SCBGUpCheckCode.PROTOCOL_TYPE = 786585

function SCBGUpCheckCode.Create()
	print("enter SCBGUpCheckCode create")
	return SCBGUpCheckCode:new()
end
function SCBGUpCheckCode:new()
	local self = {}
	setmetatable(self, SCBGUpCheckCode)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SCBGUpCheckCode:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCBGUpCheckCode:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SCBGUpCheckCode:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SCBGUpCheckCode

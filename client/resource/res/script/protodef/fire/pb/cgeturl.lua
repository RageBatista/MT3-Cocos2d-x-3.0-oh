require "utils.tableutil"
CGetURL = {}
CGetURL.__index = CGetURL



CGetURL.PROTOCOL_TYPE = 817934

function CGetURL.Create()
	print("enter CGetURL create")
	return CGetURL:new()
end
function CGetURL:new()
	local self = {}
	setmetatable(self, CGetURL)
	self.type = self.PROTOCOL_TYPE
	self.md5 = ""

	return self
end
function CGetURL:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetURL:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.md5)
	return _os_
end

function CGetURL:unmarshal(_os_)
	self.md5 = _os_:unmarshal_wstring(self.md5)
	return _os_
end

return CGetURL

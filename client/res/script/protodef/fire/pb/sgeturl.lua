require "utils.tableutil"
SGetURL = {}
SGetURL.__index = SGetURL



SGetURL.PROTOCOL_TYPE = 817933

function SGetURL.Create()
	print("enter SGetURL create")
	return SGetURL:new()
end
function SGetURL:new()
	local self = {}
	setmetatable(self, SGetURL)
	self.type = self.PROTOCOL_TYPE
	self.md5 = ""

	return self
end
function SGetURL:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetURL:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.md5)
	return _os_
end

function SGetURL:unmarshal(_os_)
	self.md5 = _os_:unmarshal_wstring(self.md5)
	return _os_
end

return SGetURL

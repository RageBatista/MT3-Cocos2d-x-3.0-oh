require "utils.tableutil"
COnTitle = {}
COnTitle.__index = COnTitle



COnTitle.PROTOCOL_TYPE = 798435

function COnTitle.Create()
	print("enter COnTitle create")
	return COnTitle:new()
end
function COnTitle:new()
	local self = {}
	setmetatable(self, COnTitle)
	self.type = self.PROTOCOL_TYPE
	self.titleid = 0

	return self
end
function COnTitle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COnTitle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.titleid)
	return _os_
end

function COnTitle:unmarshal(_os_)
	self.titleid = _os_:unmarshal_int32()
	return _os_
end

return COnTitle

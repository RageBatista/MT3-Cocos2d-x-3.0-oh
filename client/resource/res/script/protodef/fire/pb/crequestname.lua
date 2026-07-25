require "utils.tableutil"
CRequestName = {}
CRequestName.__index = CRequestName



CRequestName.PROTOCOL_TYPE = 786474

function CRequestName.Create()
	print("enter CRequestName create")
	return CRequestName:new()
end
function CRequestName:new()
	local self = {}
	setmetatable(self, CRequestName)
	self.type = self.PROTOCOL_TYPE
	self.sex = 0

	return self
end
function CRequestName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.sex)
	return _os_
end

function CRequestName:unmarshal(_os_)
	self.sex = _os_:unmarshal_short()
	return _os_
end

return CRequestName

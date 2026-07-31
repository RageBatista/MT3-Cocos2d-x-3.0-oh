require "utils.tableutil"
CDismissApprentce = {}
CDismissApprentce.__index = CDismissApprentce



CDismissApprentce.PROTOCOL_TYPE = 816477

function CDismissApprentce.Create()
	print("enter CDismissApprentce create")
	return CDismissApprentce:new()
end
function CDismissApprentce:new()
	local self = {}
	setmetatable(self, CDismissApprentce)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CDismissApprentce:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDismissApprentce:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CDismissApprentce:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CDismissApprentce

require "utils.tableutil"
SSendServerMultiExp = {}
SSendServerMultiExp.__index = SSendServerMultiExp



SSendServerMultiExp.PROTOCOL_TYPE = 786502

function SSendServerMultiExp.Create()
	print("enter SSendServerMultiExp create")
	return SSendServerMultiExp:new()
end
function SSendServerMultiExp:new()
	local self = {}
	setmetatable(self, SSendServerMultiExp)
	self.type = self.PROTOCOL_TYPE
	self.addvalue = 0

	return self
end
function SSendServerMultiExp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendServerMultiExp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.addvalue)
	return _os_
end

function SSendServerMultiExp:unmarshal(_os_)
	self.addvalue = _os_:unmarshal_int32()
	return _os_
end

return SSendServerMultiExp

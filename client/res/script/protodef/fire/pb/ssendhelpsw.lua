require "utils.tableutil"
SSendHelpSW = {}
SSendHelpSW.__index = SSendHelpSW



SSendHelpSW.PROTOCOL_TYPE = 786548

function SSendHelpSW.Create()
	print("enter SSendHelpSW create")
	return SSendHelpSW:new()
end
function SSendHelpSW:new()
	local self = {}
	setmetatable(self, SSendHelpSW)
	self.type = self.PROTOCOL_TYPE
	self.helpsw = 0

	return self
end
function SSendHelpSW:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendHelpSW:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.helpsw)
	return _os_
end

function SSendHelpSW:unmarshal(_os_)
	self.helpsw = _os_:unmarshal_int32()
	return _os_
end

return SSendHelpSW

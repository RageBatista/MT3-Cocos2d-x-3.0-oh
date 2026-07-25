require "utils.tableutil"
CSendHelpSW = {}
CSendHelpSW.__index = CSendHelpSW



CSendHelpSW.PROTOCOL_TYPE = 786547

function CSendHelpSW.Create()
	print("enter CSendHelpSW create")
	return CSendHelpSW:new()
end
function CSendHelpSW:new()
	local self = {}
	setmetatable(self, CSendHelpSW)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CSendHelpSW:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendHelpSW:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CSendHelpSW:unmarshal(_os_)
	return _os_
end

return CSendHelpSW

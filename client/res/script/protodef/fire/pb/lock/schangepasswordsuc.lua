require "utils.tableutil"
SChangePasswordSuc = {}
SChangePasswordSuc.__index = SChangePasswordSuc



SChangePasswordSuc.PROTOCOL_TYPE = 818945

function SChangePasswordSuc.Create()
	print("enter SChangePasswordSuc create")
	return SChangePasswordSuc:new()
end
function SChangePasswordSuc:new()
	local self = {}
	setmetatable(self, SChangePasswordSuc)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SChangePasswordSuc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangePasswordSuc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SChangePasswordSuc:unmarshal(_os_)
	return _os_
end

return SChangePasswordSuc

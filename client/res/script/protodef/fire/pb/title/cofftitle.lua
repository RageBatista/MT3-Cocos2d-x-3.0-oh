require "utils.tableutil"
COffTitle = {}
COffTitle.__index = COffTitle



COffTitle.PROTOCOL_TYPE = 798437

function COffTitle.Create()
	print("enter COffTitle create")
	return COffTitle:new()
end
function COffTitle:new()
	local self = {}
	setmetatable(self, COffTitle)
	self.type = self.PROTOCOL_TYPE
	return self
end
function COffTitle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COffTitle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function COffTitle:unmarshal(_os_)
	return _os_
end

return COffTitle

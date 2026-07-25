require "utils.tableutil"
CFaBaocz = {}
CFaBaocz.__index = CFaBaocz



CFaBaocz.PROTOCOL_TYPE = 800096

function CFaBaocz.Create()
	print("enter CFaBaocz create")
	return CFaBaocz:new()
end
function CFaBaocz:new()
	local self = {}
	setmetatable(self, CFaBaocz)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CFaBaocz:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFaBaocz:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CFaBaocz:unmarshal(_os_)
	return _os_
end

return CFaBaocz

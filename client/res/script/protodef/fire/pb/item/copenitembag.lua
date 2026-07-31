require "utils.tableutil"
COpenItemBag = {}
COpenItemBag.__index = COpenItemBag



COpenItemBag.PROTOCOL_TYPE = 787655

function COpenItemBag.Create()
	print("enter COpenItemBag create")
	return COpenItemBag:new()
end
function COpenItemBag:new()
	local self = {}
	setmetatable(self, COpenItemBag)
	self.type = self.PROTOCOL_TYPE
	return self
end
function COpenItemBag:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COpenItemBag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function COpenItemBag:unmarshal(_os_)
	return _os_
end

return COpenItemBag

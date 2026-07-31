require "utils.tableutil"
SCantRequestAsPrentice = {
	Mask_Word = 0
}
SCantRequestAsPrentice.__index = SCantRequestAsPrentice



SCantRequestAsPrentice.PROTOCOL_TYPE = 816466

function SCantRequestAsPrentice.Create()
	print("enter SCantRequestAsPrentice create")
	return SCantRequestAsPrentice:new()
end
function SCantRequestAsPrentice:new()
	local self = {}
	setmetatable(self, SCantRequestAsPrentice)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.reason = 0

	return self
end
function SCantRequestAsPrentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCantRequestAsPrentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.reason)
	return _os_
end

function SCantRequestAsPrentice:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.reason = _os_:unmarshal_int32()
	return _os_
end

return SCantRequestAsPrentice

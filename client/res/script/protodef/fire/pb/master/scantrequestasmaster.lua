require "utils.tableutil"
SCantRequestAsMaster = {
	Mask_Word = 0
}
SCantRequestAsMaster.__index = SCantRequestAsMaster



SCantRequestAsMaster.PROTOCOL_TYPE = 816467

function SCantRequestAsMaster.Create()
	print("enter SCantRequestAsMaster create")
	return SCantRequestAsMaster:new()
end
function SCantRequestAsMaster:new()
	local self = {}
	setmetatable(self, SCantRequestAsMaster)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.reason = 0

	return self
end
function SCantRequestAsMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCantRequestAsMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.reason)
	return _os_
end

function SCantRequestAsMaster:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.reason = _os_:unmarshal_int32()
	return _os_
end

return SCantRequestAsMaster

require "utils.tableutil"
CModifyRoleName = {}
CModifyRoleName.__index = CModifyRoleName



CModifyRoleName.PROTOCOL_TYPE = 786506

function CModifyRoleName.Create()
	print("enter CModifyRoleName create")
	return CModifyRoleName:new()
end
function CModifyRoleName:new()
	local self = {}
	setmetatable(self, CModifyRoleName)
	self.type = self.PROTOCOL_TYPE
	self.newname = "" 
	self.itemkey = 0

	return self
end
function CModifyRoleName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CModifyRoleName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.newname)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CModifyRoleName:unmarshal(_os_)
	self.newname = _os_:unmarshal_wstring(self.newname)
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CModifyRoleName

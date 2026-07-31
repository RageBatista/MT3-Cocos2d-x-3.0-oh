require "utils.tableutil"
CGetEquipTips = {}
CGetEquipTips.__index = CGetEquipTips



CGetEquipTips.PROTOCOL_TYPE = 787652

function CGetEquipTips.Create()
	print("enter CGetEquipTips create")
	return CGetEquipTips:new()
end
function CGetEquipTips:new()
	local self = {}
	setmetatable(self, CGetEquipTips)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.keyinpack = 0
	self.key2inpack = 0

	return self
end
function CGetEquipTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetEquipTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.key2inpack)
	return _os_
end

function CGetEquipTips:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	self.key2inpack = _os_:unmarshal_int32()
	return _os_
end

return CGetEquipTips

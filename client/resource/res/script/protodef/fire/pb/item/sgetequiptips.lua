require "utils.tableutil"
SGetEquipTips = {}
SGetEquipTips.__index = SGetEquipTips



SGetEquipTips.PROTOCOL_TYPE = 787653

function SGetEquipTips.Create()
	print("enter SGetEquipTips create")
	return SGetEquipTips:new()
end
function SGetEquipTips:new()
	local self = {}
	setmetatable(self, SGetEquipTips)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.keyinpack = 0
	self.key2inpack = 0
	self.tips = FireNet.Octets() 

	return self
end
function SGetEquipTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetEquipTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.key2inpack)
	_os_: marshal_octets(self.tips)
	return _os_
end

function SGetEquipTips:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	self.key2inpack = _os_:unmarshal_int32()
	_os_:unmarshal_octets(self.tips)
	return _os_
end

return SGetEquipTips

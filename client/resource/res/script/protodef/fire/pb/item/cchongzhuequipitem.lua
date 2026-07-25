require "utils.tableutil"
CChongZhuEquipItem = {}
CChongZhuEquipItem.__index = CChongZhuEquipItem



CChongZhuEquipItem.PROTOCOL_TYPE = 817942

function CChongZhuEquipItem.Create()
	print("enter CChongZhuEquipItem create")
	return CChongZhuEquipItem:new()
end
function CChongZhuEquipItem:new()
	local self = {}
	setmetatable(self, CChongZhuEquipItem)
	self.type = self.PROTOCOL_TYPE
	self.repairtype = 0
	self.packid = 0
	self.keyinpack = 0

	return self
end
function CChongZhuEquipItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChongZhuEquipItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.repairtype)
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	return _os_
end

function CChongZhuEquipItem:unmarshal(_os_)
	self.repairtype = _os_:unmarshal_int32()
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	return _os_
end

return CChongZhuEquipItem

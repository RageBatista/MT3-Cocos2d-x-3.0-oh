require "utils.tableutil"
SSetPetEquipInfo = {
}
SSetPetEquipInfo.__index = SSetPetEquipInfo



SSetPetEquipInfo.PROTOCOL_TYPE = 817938

function SSetPetEquipInfo.Create()
	print("enter SSetPetEquipInfo create")
	return SSetPetEquipInfo:new()
end
function SSetPetEquipInfo:new()
	local self = {}
	setmetatable(self, SSetPetEquipInfo)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.itemid = 0
	self.petequipinfo={}
	self.effect = 0
	return self
end
function SSetPetEquipInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetPetEquipInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.itemid)
	_os_:compact_uint32(TableUtil.tablelength(self.petequipinfo))
	for k,v in pairs(self.petequipinfo) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	_os_:marshal_int32(self.effect)
	return _os_
end

function SSetPetEquipInfo:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.itemid = _os_:unmarshal_int32()
	local sizeof_petequipinfo=0,_os_null_petequipinfo
	_os_null_petequipinfo, sizeof_petequipinfo = _os_: uncompact_uint32(sizeof_petequipinfo)
	for k = 1,sizeof_petequipinfo do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.petequipinfo[newkey] = newvalue
	end
	self.effect = _os_:unmarshal_int32()
	return _os_
end

return SSetPetEquipInfo

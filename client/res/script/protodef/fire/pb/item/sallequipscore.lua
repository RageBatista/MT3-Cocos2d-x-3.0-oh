require "utils.tableutil"
SAllEquipScore = {}
SAllEquipScore.__index = SAllEquipScore



SAllEquipScore.PROTOCOL_TYPE = 787505

function SAllEquipScore.Create()
	print("enter SAllEquipScore create")
	return SAllEquipScore:new()
end
function SAllEquipScore:new()
	local self = {}
	setmetatable(self, SAllEquipScore)
	self.type = self.PROTOCOL_TYPE
	self.score = 0

	return self
end
function SAllEquipScore:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAllEquipScore:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.score)
	return _os_
end

function SAllEquipScore:unmarshal(_os_)
	self.score = _os_:unmarshal_int32()
	return _os_
end

return SAllEquipScore

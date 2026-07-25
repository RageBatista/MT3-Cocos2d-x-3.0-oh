require "utils.tableutil"
SAddPointAttrData = {}
SAddPointAttrData.__index = SAddPointAttrData



SAddPointAttrData.PROTOCOL_TYPE = 786531

function SAddPointAttrData.Create()
	print("enter SAddPointAttrData create")
	return SAddPointAttrData:new()
end
function SAddPointAttrData:new()
	local self = {}
	setmetatable(self, SAddPointAttrData)
	self.type = self.PROTOCOL_TYPE
	self.max_hp = 0
	self.max_mp = 0
	self.attack = 0
	self.defend = 0
	self.magic_attack = 0
	self.magic_def = 0
	self.speed = 0

	return self
end
function SAddPointAttrData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddPointAttrData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_float(self.max_hp)
	_os_:marshal_float(self.max_mp)
	_os_:marshal_float(self.attack)
	_os_:marshal_float(self.defend)
	_os_:marshal_float(self.magic_attack)
	_os_:marshal_float(self.magic_def)
	_os_:marshal_float(self.speed)
	return _os_
end

function SAddPointAttrData:unmarshal(_os_)
	self.max_hp = _os_:unmarshal_float()
	self.max_mp = _os_:unmarshal_float()
	self.attack = _os_:unmarshal_float()
	self.defend = _os_:unmarshal_float()
	self.magic_attack = _os_:unmarshal_float()
	self.magic_def = _os_:unmarshal_float()
	self.speed = _os_:unmarshal_float()
	return _os_
end

return SAddPointAttrData

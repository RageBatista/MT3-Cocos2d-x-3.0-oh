require "utils.tableutil"
SSynchroBossHp = {}
SSynchroBossHp.__index = SSynchroBossHp



SSynchroBossHp.PROTOCOL_TYPE = 793459

function SSynchroBossHp.Create()
	print("enter SSynchroBossHp create")
	return SSynchroBossHp:new()
end
function SSynchroBossHp:new()
	local self = {}
	setmetatable(self, SSynchroBossHp)
	self.type = self.PROTOCOL_TYPE
	self.bossmonsterid = 0
	self.flag = 0
	self.maxhp = 0
	self.hp = 0
	self.rolename = "" 
	self.changehp = 0

	return self
end
function SSynchroBossHp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSynchroBossHp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.bossmonsterid)
	_os_:marshal_char(self.flag)
	_os_:marshal_int64(self.maxhp)
	_os_:marshal_int64(self.hp)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int64(self.changehp)
	return _os_
end

function SSynchroBossHp:unmarshal(_os_)
	self.bossmonsterid = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_char()
	self.maxhp = _os_:unmarshal_int64()
	self.hp = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.changehp = _os_:unmarshal_int64()
	return _os_
end

return SSynchroBossHp

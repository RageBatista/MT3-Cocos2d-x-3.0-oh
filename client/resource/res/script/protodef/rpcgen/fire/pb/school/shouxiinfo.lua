require "utils.tableutil"
ShouxiInfo = {}
ShouxiInfo.__index = ShouxiInfo


function ShouxiInfo:new()
	local self = {}
	setmetatable(self, ShouxiInfo)
	self.maxhp = 0
	self.maxmp = 0
	self.hitrate = 0
	self.attack = 0
	self.defend = 0
	self.magicattack = 0
	self.magicdef = 0
	self.speed = 0
	self.dodge = 0

	return self
end
function ShouxiInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.maxhp)
	_os_:marshal_int32(self.maxmp)
	_os_:marshal_int32(self.hitrate)
	_os_:marshal_int32(self.attack)
	_os_:marshal_int32(self.defend)
	_os_:marshal_int32(self.magicattack)
	_os_:marshal_int32(self.magicdef)
	_os_:marshal_int32(self.speed)
	_os_:marshal_int32(self.dodge)
	return _os_
end

function ShouxiInfo:unmarshal(_os_)
	self.maxhp = _os_:unmarshal_int32()
	self.maxmp = _os_:unmarshal_int32()
	self.hitrate = _os_:unmarshal_int32()
	self.attack = _os_:unmarshal_int32()
	self.defend = _os_:unmarshal_int32()
	self.magicattack = _os_:unmarshal_int32()
	self.magicdef = _os_:unmarshal_int32()
	self.speed = _os_:unmarshal_int32()
	self.dodge = _os_:unmarshal_int32()
	return _os_
end

return ShouxiInfo

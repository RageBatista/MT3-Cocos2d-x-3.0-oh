require "utils.tableutil"
HookBattleData = {}
HookBattleData.__index = HookBattleData


function HookBattleData:new()
	local self = {}
	setmetatable(self, HookBattleData)
	self.isautobattle = 0
	self.charoptype = 0
	self.charopid = 0
	self.petoptype = 0
	self.petopid = 0

	return self
end
function HookBattleData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.isautobattle)
	_os_:marshal_short(self.charoptype)
	_os_:marshal_int32(self.charopid)
	_os_:marshal_short(self.petoptype)
	_os_:marshal_int32(self.petopid)
	return _os_
end

function HookBattleData:unmarshal(_os_)
	self.isautobattle = _os_:unmarshal_char()
	self.charoptype = _os_:unmarshal_short()
	self.charopid = _os_:unmarshal_int32()
	self.petoptype = _os_:unmarshal_short()
	self.petopid = _os_:unmarshal_int32()
	return _os_
end

return HookBattleData

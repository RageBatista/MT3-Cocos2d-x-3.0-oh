require "utils.tableutil"
SBattleFieldAct = {}
SBattleFieldAct.__index = SBattleFieldAct



SBattleFieldAct.PROTOCOL_TYPE = 808537

function SBattleFieldAct.Create()
	print("enter SBattleFieldAct create")
	return SBattleFieldAct:new()
end
function SBattleFieldAct:new()
	local self = {}
	setmetatable(self, SBattleFieldAct)
	self.type = self.PROTOCOL_TYPE
	self.roleact = 0

	return self
end
function SBattleFieldAct:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBattleFieldAct:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.roleact)
	return _os_
end

function SBattleFieldAct:unmarshal(_os_)
	self.roleact = _os_:unmarshal_int32()
	return _os_
end

return SBattleFieldAct

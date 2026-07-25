require "utils.tableutil"
SBattleToNpcError = {}
SBattleToNpcError.__index = SBattleToNpcError



SBattleToNpcError.PROTOCOL_TYPE = 795453

function SBattleToNpcError.Create()
	print("enter SBattleToNpcError create")
	return SBattleToNpcError:new()
end
function SBattleToNpcError:new()
	local self = {}
	setmetatable(self, SBattleToNpcError)
	self.type = self.PROTOCOL_TYPE
	self.battleerror = 0

	return self
end
function SBattleToNpcError:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBattleToNpcError:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.battleerror)
	return _os_
end

function SBattleToNpcError:unmarshal(_os_)
	self.battleerror = _os_:unmarshal_int32()
	return _os_
end

return SBattleToNpcError

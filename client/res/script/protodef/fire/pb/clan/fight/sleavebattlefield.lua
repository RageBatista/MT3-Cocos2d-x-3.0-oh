require "utils.tableutil"
SLeaveBattleField = {}
SLeaveBattleField.__index = SLeaveBattleField



SLeaveBattleField.PROTOCOL_TYPE = 808544

function SLeaveBattleField.Create()
	print("enter SLeaveBattleField create")
	return SLeaveBattleField:new()
end
function SLeaveBattleField:new()
	local self = {}
	setmetatable(self, SLeaveBattleField)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SLeaveBattleField:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLeaveBattleField:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SLeaveBattleField:unmarshal(_os_)
	return _os_
end

return SLeaveBattleField

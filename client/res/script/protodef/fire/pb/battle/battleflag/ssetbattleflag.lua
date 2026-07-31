require "utils.tableutil"
SSetBattleFlag = {}
SSetBattleFlag.__index = SSetBattleFlag



SSetBattleFlag.PROTOCOL_TYPE = 793890

function SSetBattleFlag.Create()
	print("enter SSetBattleFlag create")
	return SSetBattleFlag:new()
end
function SSetBattleFlag:new()
	local self = {}
	setmetatable(self, SSetBattleFlag)
	self.type = self.PROTOCOL_TYPE
	self.opttype = 0
	self.index = 0
	self.flag = "" 

	return self
end
function SSetBattleFlag:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetBattleFlag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.opttype)
	_os_:marshal_char(self.index)
	_os_:marshal_wstring(self.flag)
	return _os_
end

function SSetBattleFlag:unmarshal(_os_)
	self.opttype = _os_:unmarshal_char()
	self.index = _os_:unmarshal_char()
	self.flag = _os_:unmarshal_wstring(self.flag)
	return _os_
end

return SSetBattleFlag

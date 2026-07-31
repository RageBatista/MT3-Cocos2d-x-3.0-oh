require "utils.tableutil"
CSetBattleFlag = {}
CSetBattleFlag.__index = CSetBattleFlag



CSetBattleFlag.PROTOCOL_TYPE = 793889

function CSetBattleFlag.Create()
	print("enter CSetBattleFlag create")
	return CSetBattleFlag:new()
end
function CSetBattleFlag:new()
	local self = {}
	setmetatable(self, CSetBattleFlag)
	self.type = self.PROTOCOL_TYPE
	self.opttype = 0
	self.index = 0
	self.flag = "" 

	return self
end
function CSetBattleFlag:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetBattleFlag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.opttype)
	_os_:marshal_char(self.index)
	_os_:marshal_wstring(self.flag)
	return _os_
end

function CSetBattleFlag:unmarshal(_os_)
	self.opttype = _os_:unmarshal_char()
	self.index = _os_:unmarshal_char()
	self.flag = _os_:unmarshal_wstring(self.flag)
	return _os_
end

return CSetBattleFlag

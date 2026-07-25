require "utils.tableutil"
CModifyBattleFlag = {}
CModifyBattleFlag.__index = CModifyBattleFlag



CModifyBattleFlag.PROTOCOL_TYPE = 793885

function CModifyBattleFlag.Create()
	print("enter CModifyBattleFlag create")
	return CModifyBattleFlag:new()
end
function CModifyBattleFlag:new()
	local self = {}
	setmetatable(self, CModifyBattleFlag)
	self.type = self.PROTOCOL_TYPE
	self.opttype = 0
	self.index = 0
	self.flag = "" 

	return self
end
function CModifyBattleFlag:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CModifyBattleFlag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.opttype)
	_os_:marshal_char(self.index)
	_os_:marshal_wstring(self.flag)
	return _os_
end

function CModifyBattleFlag:unmarshal(_os_)
	self.opttype = _os_:unmarshal_char()
	self.index = _os_:unmarshal_char()
	self.flag = _os_:unmarshal_wstring(self.flag)
	return _os_
end

return CModifyBattleFlag

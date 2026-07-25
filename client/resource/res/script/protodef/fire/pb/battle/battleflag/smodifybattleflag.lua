require "utils.tableutil"
SModifyBattleFlag = {}
SModifyBattleFlag.__index = SModifyBattleFlag



SModifyBattleFlag.PROTOCOL_TYPE = 793886

function SModifyBattleFlag.Create()
	print("enter SModifyBattleFlag create")
	return SModifyBattleFlag:new()
end
function SModifyBattleFlag:new()
	local self = {}
	setmetatable(self, SModifyBattleFlag)
	self.type = self.PROTOCOL_TYPE
	self.opttype = 0
	self.index = 0
	self.flag = "" 

	return self
end
function SModifyBattleFlag:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SModifyBattleFlag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.opttype)
	_os_:marshal_char(self.index)
	_os_:marshal_wstring(self.flag)
	return _os_
end

function SModifyBattleFlag:unmarshal(_os_)
	self.opttype = _os_:unmarshal_char()
	self.index = _os_:unmarshal_char()
	self.flag = _os_:unmarshal_wstring(self.flag)
	return _os_
end

return SModifyBattleFlag

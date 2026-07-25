require "utils.tableutil"
SAcceptLiveDieBattleFirst = {}
SAcceptLiveDieBattleFirst.__index = SAcceptLiveDieBattleFirst



SAcceptLiveDieBattleFirst.PROTOCOL_TYPE = 793849

function SAcceptLiveDieBattleFirst.Create()
	print("enter SAcceptLiveDieBattleFirst create")
	return SAcceptLiveDieBattleFirst:new()
end
function SAcceptLiveDieBattleFirst:new()
	local self = {}
	setmetatable(self, SAcceptLiveDieBattleFirst)
	self.type = self.PROTOCOL_TYPE
	self.hostroleid = 0
	self.hostrolename = "" 

	return self
end
function SAcceptLiveDieBattleFirst:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAcceptLiveDieBattleFirst:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.hostroleid)
	_os_:marshal_wstring(self.hostrolename)
	return _os_
end

function SAcceptLiveDieBattleFirst:unmarshal(_os_)
	self.hostroleid = _os_:unmarshal_int64()
	self.hostrolename = _os_:unmarshal_wstring(self.hostrolename)
	return _os_
end

return SAcceptLiveDieBattleFirst

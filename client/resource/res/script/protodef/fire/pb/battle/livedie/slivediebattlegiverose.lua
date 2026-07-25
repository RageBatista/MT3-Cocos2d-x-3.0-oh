require "utils.tableutil"
SLiveDieBattleGiveRose = {}
SLiveDieBattleGiveRose.__index = SLiveDieBattleGiveRose



SLiveDieBattleGiveRose.PROTOCOL_TYPE = 793845

function SLiveDieBattleGiveRose.Create()
	print("enter SLiveDieBattleGiveRose create")
	return SLiveDieBattleGiveRose:new()
end
function SLiveDieBattleGiveRose:new()
	local self = {}
	setmetatable(self, SLiveDieBattleGiveRose)
	self.type = self.PROTOCOL_TYPE
	self.vedioid = "" 
	self.rosenum = 0
	self.roseflag = 0

	return self
end
function SLiveDieBattleGiveRose:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLiveDieBattleGiveRose:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.vedioid)
	_os_:marshal_int32(self.rosenum)
	_os_:marshal_int32(self.roseflag)
	return _os_
end

function SLiveDieBattleGiveRose:unmarshal(_os_)
	self.vedioid = _os_:unmarshal_wstring(self.vedioid)
	self.rosenum = _os_:unmarshal_int32()
	self.roseflag = _os_:unmarshal_int32()
	return _os_
end

return SLiveDieBattleGiveRose

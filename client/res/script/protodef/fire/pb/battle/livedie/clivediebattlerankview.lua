require "utils.tableutil"
CLiveDieBattleRankView = {}
CLiveDieBattleRankView.__index = CLiveDieBattleRankView



CLiveDieBattleRankView.PROTOCOL_TYPE = 793842

function CLiveDieBattleRankView.Create()
	print("enter CLiveDieBattleRankView create")
	return CLiveDieBattleRankView:new()
end
function CLiveDieBattleRankView:new()
	local self = {}
	setmetatable(self, CLiveDieBattleRankView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0

	return self
end
function CLiveDieBattleRankView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveDieBattleRankView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	return _os_
end

function CLiveDieBattleRankView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	return _os_
end

return CLiveDieBattleRankView

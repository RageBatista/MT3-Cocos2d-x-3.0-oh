require "utils.tableutil"
CLiveDieBattleWatchView = {}
CLiveDieBattleWatchView.__index = CLiveDieBattleWatchView



CLiveDieBattleWatchView.PROTOCOL_TYPE = 793840

function CLiveDieBattleWatchView.Create()
	print("enter CLiveDieBattleWatchView create")
	return CLiveDieBattleWatchView:new()
end
function CLiveDieBattleWatchView:new()
	local self = {}
	setmetatable(self, CLiveDieBattleWatchView)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CLiveDieBattleWatchView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveDieBattleWatchView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CLiveDieBattleWatchView:unmarshal(_os_)
	return _os_
end

return CLiveDieBattleWatchView

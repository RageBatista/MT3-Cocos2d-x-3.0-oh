require "utils.tableutil"
CLiveDieBattleWatchVideo = {}
CLiveDieBattleWatchVideo.__index = CLiveDieBattleWatchVideo



CLiveDieBattleWatchVideo.PROTOCOL_TYPE = 793846

function CLiveDieBattleWatchVideo.Create()
	print("enter CLiveDieBattleWatchVideo create")
	return CLiveDieBattleWatchVideo:new()
end
function CLiveDieBattleWatchVideo:new()
	local self = {}
	setmetatable(self, CLiveDieBattleWatchVideo)
	self.type = self.PROTOCOL_TYPE
	self.vedioid = "" 

	return self
end
function CLiveDieBattleWatchVideo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveDieBattleWatchVideo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.vedioid)
	return _os_
end

function CLiveDieBattleWatchVideo:unmarshal(_os_)
	self.vedioid = _os_:unmarshal_wstring(self.vedioid)
	return _os_
end

return CLiveDieBattleWatchVideo

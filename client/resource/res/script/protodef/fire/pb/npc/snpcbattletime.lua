require "utils.tableutil"
SNpcBattleTime = {}
SNpcBattleTime.__index = SNpcBattleTime



SNpcBattleTime.PROTOCOL_TYPE = 795669

function SNpcBattleTime.Create()
	print("enter SNpcBattleTime create")
	return SNpcBattleTime:new()
end
function SNpcBattleTime:new()
	local self = {}
	setmetatable(self, SNpcBattleTime)
	self.type = self.PROTOCOL_TYPE
	self.npcid = 0
	self.npckey = 0
	self.usetime = 0
	self.lasttime = 0

	return self
end
function SNpcBattleTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNpcBattleTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.npcid)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int64(self.usetime)
	_os_:marshal_int64(self.lasttime)
	return _os_
end

function SNpcBattleTime:unmarshal(_os_)
	self.npcid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.usetime = _os_:unmarshal_int64()
	self.lasttime = _os_:unmarshal_int64()
	return _os_
end

return SNpcBattleTime

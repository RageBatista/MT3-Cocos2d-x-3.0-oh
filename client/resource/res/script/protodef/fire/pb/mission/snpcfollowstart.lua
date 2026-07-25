require "utils.tableutil"
SNpcFollowStart = {}
SNpcFollowStart.__index = SNpcFollowStart



SNpcFollowStart.PROTOCOL_TYPE = 805501

function SNpcFollowStart.Create()
	print("enter SNpcFollowStart create")
	return SNpcFollowStart:new()
end
function SNpcFollowStart:new()
	local self = {}
	setmetatable(self, SNpcFollowStart)
	self.type = self.PROTOCOL_TYPE
	self.npcid = 0

	return self
end
function SNpcFollowStart:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNpcFollowStart:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.npcid)
	return _os_
end

function SNpcFollowStart:unmarshal(_os_)
	self.npcid = _os_:unmarshal_int32()
	return _os_
end

return SNpcFollowStart

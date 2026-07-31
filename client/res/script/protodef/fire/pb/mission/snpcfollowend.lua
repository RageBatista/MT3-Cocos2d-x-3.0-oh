require "utils.tableutil"
SNpcFollowEnd = {}
SNpcFollowEnd.__index = SNpcFollowEnd



SNpcFollowEnd.PROTOCOL_TYPE = 805502

function SNpcFollowEnd.Create()
	print("enter SNpcFollowEnd create")
	return SNpcFollowEnd:new()
end
function SNpcFollowEnd:new()
	local self = {}
	setmetatable(self, SNpcFollowEnd)
	self.type = self.PROTOCOL_TYPE
	self.npcid = 0

	return self
end
function SNpcFollowEnd:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNpcFollowEnd:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.npcid)
	return _os_
end

function SNpcFollowEnd:unmarshal(_os_)
	self.npcid = _os_:unmarshal_int32()
	return _os_
end

return SNpcFollowEnd

require "utils.tableutil"
CSelectedMasterAward = {}
CSelectedMasterAward.__index = CSelectedMasterAward



CSelectedMasterAward.PROTOCOL_TYPE = 816452

function CSelectedMasterAward.Create()
	print("enter CSelectedMasterAward create")
	return CSelectedMasterAward:new()
end
function CSelectedMasterAward:new()
	local self = {}
	setmetatable(self, CSelectedMasterAward)
	self.type = self.PROTOCOL_TYPE
	self.awardkey = 0
	self.npckey = 0

	return self
end
function CSelectedMasterAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSelectedMasterAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.awardkey)
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CSelectedMasterAward:unmarshal(_os_)
	self.awardkey = _os_:unmarshal_int64()
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CSelectedMasterAward

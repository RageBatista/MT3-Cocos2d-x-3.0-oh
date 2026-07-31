require "utils.tableutil"
CAbandonQuest = {}
CAbandonQuest.__index = CAbandonQuest



CAbandonQuest.PROTOCOL_TYPE = 807434

function CAbandonQuest.Create()
	print("enter CAbandonQuest create")
	return CAbandonQuest:new()
end
function CAbandonQuest:new()
	local self = {}
	setmetatable(self, CAbandonQuest)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0

	return self
end
function CAbandonQuest:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAbandonQuest:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	return _os_
end

function CAbandonQuest:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	return _os_
end

return CAbandonQuest

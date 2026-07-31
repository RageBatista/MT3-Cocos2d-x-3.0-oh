require "utils.tableutil"
CNotifyTeamMemeberSubmitItem = {}
CNotifyTeamMemeberSubmitItem.__index = CNotifyTeamMemeberSubmitItem



CNotifyTeamMemeberSubmitItem.PROTOCOL_TYPE = 805477

function CNotifyTeamMemeberSubmitItem.Create()
	print("enter CNotifyTeamMemeberSubmitItem create")
	return CNotifyTeamMemeberSubmitItem:new()
end
function CNotifyTeamMemeberSubmitItem:new()
	local self = {}
	setmetatable(self, CNotifyTeamMemeberSubmitItem)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0
	self.npckey = 0
	self.submittype = 0

	return self
end
function CNotifyTeamMemeberSubmitItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CNotifyTeamMemeberSubmitItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.submittype)
	return _os_
end

function CNotifyTeamMemeberSubmitItem:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.submittype = _os_:unmarshal_int32()
	return _os_
end

return CNotifyTeamMemeberSubmitItem

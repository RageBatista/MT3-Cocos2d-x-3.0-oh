require "utils.tableutil"
SRefreshSpecialQuestState = {}
SRefreshSpecialQuestState.__index = SRefreshSpecialQuestState



SRefreshSpecialQuestState.PROTOCOL_TYPE = 807433

function SRefreshSpecialQuestState.Create()
	print("enter SRefreshSpecialQuestState create")
	return SRefreshSpecialQuestState:new()
end
function SRefreshSpecialQuestState:new()
	local self = {}
	setmetatable(self, SRefreshSpecialQuestState)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0
	self.state = 0

	return self
end
function SRefreshSpecialQuestState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshSpecialQuestState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	_os_:marshal_int32(self.state)
	return _os_
end

function SRefreshSpecialQuestState:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	return _os_
end

return SRefreshSpecialQuestState

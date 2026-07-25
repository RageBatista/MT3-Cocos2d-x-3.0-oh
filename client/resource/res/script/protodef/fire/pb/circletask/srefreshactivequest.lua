require "utils.tableutil"
require "protodef.rpcgen.fire.pb.circletask.activequestdata"
require "protodef.rpcgen.fire.pb.circletask.rewarditemunit"
SRefreshActiveQuest = {}
SRefreshActiveQuest.__index = SRefreshActiveQuest



SRefreshActiveQuest.PROTOCOL_TYPE = 807435

function SRefreshActiveQuest.Create()
	print("enter SRefreshActiveQuest create")
	return SRefreshActiveQuest:new()
end
function SRefreshActiveQuest:new()
	local self = {}
	setmetatable(self, SRefreshActiveQuest)
	self.type = self.PROTOCOL_TYPE
	self.questdata = ActiveQuestData:new()

	return self
end
function SRefreshActiveQuest:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshActiveQuest:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.questdata:marshal(_os_) 
	return _os_
end

function SRefreshActiveQuest:unmarshal(_os_)
	----------------unmarshal bean

	self.questdata:unmarshal(_os_)

	return _os_
end

return SRefreshActiveQuest

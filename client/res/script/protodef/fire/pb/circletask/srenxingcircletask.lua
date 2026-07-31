require "utils.tableutil"
SRenXingCircleTask = {}
SRenXingCircleTask.__index = SRenXingCircleTask



SRenXingCircleTask.PROTOCOL_TYPE = 807450

function SRenXingCircleTask.Create()
	print("enter SRenXingCircleTask create")
	return SRenXingCircleTask:new()
end
function SRenXingCircleTask:new()
	local self = {}
	setmetatable(self, SRenXingCircleTask)
	self.type = self.PROTOCOL_TYPE
	self.serviceid = 0
	self.questid = 0
	self.renxingtimes = 0
	self.npckey = 0

	return self
end
function SRenXingCircleTask:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRenXingCircleTask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.serviceid)
	_os_:marshal_int32(self.questid)
	_os_:marshal_int32(self.renxingtimes)
	_os_:marshal_int64(self.npckey)
	return _os_
end

function SRenXingCircleTask:unmarshal(_os_)
	self.serviceid = _os_:unmarshal_int32()
	self.questid = _os_:unmarshal_int32()
	self.renxingtimes = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return SRenXingCircleTask

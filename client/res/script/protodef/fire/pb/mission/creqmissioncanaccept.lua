require "utils.tableutil"
CReqMissionCanAccept = {}
CReqMissionCanAccept.__index = CReqMissionCanAccept



CReqMissionCanAccept.PROTOCOL_TYPE = 805456

function CReqMissionCanAccept.Create()
	print("enter CReqMissionCanAccept create")
	return CReqMissionCanAccept:new()
end
function CReqMissionCanAccept:new()
	local self = {}
	setmetatable(self, CReqMissionCanAccept)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqMissionCanAccept:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqMissionCanAccept:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqMissionCanAccept:unmarshal(_os_)
	return _os_
end

return CReqMissionCanAccept

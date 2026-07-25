require "utils.tableutil"
SReqMissionCanAccept = {}
SReqMissionCanAccept.__index = SReqMissionCanAccept



SReqMissionCanAccept.PROTOCOL_TYPE = 805457

function SReqMissionCanAccept.Create()
	print("enter SReqMissionCanAccept create")
	return SReqMissionCanAccept:new()
end
function SReqMissionCanAccept:new()
	local self = {}
	setmetatable(self, SReqMissionCanAccept)
	self.type = self.PROTOCOL_TYPE
	self.missions = {}

	return self
end
function SReqMissionCanAccept:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqMissionCanAccept:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.missions))
	for k,v in ipairs(self.missions) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SReqMissionCanAccept:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_missions=0 ,_os_null_missions
	_os_null_missions, sizeof_missions = _os_: uncompact_uint32(sizeof_missions)
	for k = 1,sizeof_missions do
		self.missions[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SReqMissionCanAccept

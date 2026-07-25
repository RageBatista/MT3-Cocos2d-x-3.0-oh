require "utils.tableutil"
require "protodef.rpcgen.fire.pb.mission.activityinfo"
SGetActivityInfo = {}
SGetActivityInfo.__index = SGetActivityInfo



SGetActivityInfo.PROTOCOL_TYPE = 805537

function SGetActivityInfo.Create()
	print("enter SGetActivityInfo create")
	return SGetActivityInfo:new()
end
function SGetActivityInfo:new()
	local self = {}
	setmetatable(self, SGetActivityInfo)
	self.type = self.PROTOCOL_TYPE
	self.activityinfos = {}

	return self
end
function SGetActivityInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetActivityInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.activityinfos))
	for k,v in ipairs(self.activityinfos) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SGetActivityInfo:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_activityinfos=0,_os_null_activityinfos
	_os_null_activityinfos, sizeof_activityinfos = _os_: uncompact_uint32(sizeof_activityinfos)
	for k = 1,sizeof_activityinfos do
		----------------unmarshal bean
		self.activityinfos[k]=ActivityInfo:new()

		self.activityinfos[k]:unmarshal(_os_)

	end
	return _os_
end

return SGetActivityInfo

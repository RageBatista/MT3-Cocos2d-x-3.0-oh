require "utils.tableutil"
require "protodef.rpcgen.fire.pb.mission.archiveinfo"
SGetArchiveInfo = {}
SGetArchiveInfo.__index = SGetArchiveInfo



SGetArchiveInfo.PROTOCOL_TYPE = 805541

function SGetArchiveInfo.Create()
	print("enter SGetArchiveInfo create")
	return SGetArchiveInfo:new()
end
function SGetArchiveInfo:new()
	local self = {}
	setmetatable(self, SGetArchiveInfo)
	self.type = self.PROTOCOL_TYPE
	self.archiveinfos = {}

	return self
end
function SGetArchiveInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetArchiveInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.archiveinfos))
	for k,v in ipairs(self.archiveinfos) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SGetArchiveInfo:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_archiveinfos=0,_os_null_archiveinfos
	_os_null_archiveinfos, sizeof_archiveinfos = _os_: uncompact_uint32(sizeof_archiveinfos)
	for k = 1,sizeof_archiveinfos do
		----------------unmarshal bean
		self.archiveinfos[k]=ArchiveInfo:new()

		self.archiveinfos[k]:unmarshal(_os_)

	end
	return _os_
end

return SGetArchiveInfo

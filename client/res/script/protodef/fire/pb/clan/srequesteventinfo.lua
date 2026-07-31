require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.claneventinfo"
SRequestEventInfo = {}
SRequestEventInfo.__index = SRequestEventInfo



SRequestEventInfo.PROTOCOL_TYPE = 808501

function SRequestEventInfo.Create()
	print("enter SRequestEventInfo create")
	return SRequestEventInfo:new()
end
function SRequestEventInfo:new()
	local self = {}
	setmetatable(self, SRequestEventInfo)
	self.type = self.PROTOCOL_TYPE
	self.eventlist = {}

	return self
end
function SRequestEventInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestEventInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.eventlist))
	for k,v in ipairs(self.eventlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRequestEventInfo:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_eventlist=0,_os_null_eventlist
	_os_null_eventlist, sizeof_eventlist = _os_: uncompact_uint32(sizeof_eventlist)
	for k = 1,sizeof_eventlist do
		----------------unmarshal bean
		self.eventlist[k]=ClanEventInfo:new()

		self.eventlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SRequestEventInfo

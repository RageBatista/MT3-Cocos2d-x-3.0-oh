require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.clansummaryinfo"
SSearchClan = {}
SSearchClan.__index = SSearchClan



SSearchClan.PROTOCOL_TYPE = 808487

function SSearchClan.Create()
	print("enter SSearchClan create")
	return SSearchClan:new()
end
function SSearchClan:new()
	local self = {}
	setmetatable(self, SSearchClan)
	self.type = self.PROTOCOL_TYPE
	self.clansummaryinfo = ClanSummaryInfo:new()

	return self
end
function SSearchClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSearchClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.clansummaryinfo:marshal(_os_) 
	return _os_
end

function SSearchClan:unmarshal(_os_)
	----------------unmarshal bean

	self.clansummaryinfo:unmarshal(_os_)

	return _os_
end

return SSearchClan

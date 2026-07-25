require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.teammelon.rollmelon"
STeamRollMelon = {}
STeamRollMelon.__index = STeamRollMelon



STeamRollMelon.PROTOCOL_TYPE = 794522

function STeamRollMelon.Create()
	print("enter STeamRollMelon create")
	return STeamRollMelon:new()
end
function STeamRollMelon:new()
	local self = {}
	setmetatable(self, STeamRollMelon)
	self.type = self.PROTOCOL_TYPE
	self.melonlist = {}
	self.watcher = 0

	return self
end
function STeamRollMelon:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STeamRollMelon:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.melonlist))
	for k,v in ipairs(self.melonlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.watcher)
	return _os_
end

function STeamRollMelon:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_melonlist=0 ,_os_null_melonlist
	_os_null_melonlist, sizeof_melonlist = _os_: uncompact_uint32(sizeof_melonlist)
	for k = 1,sizeof_melonlist do
		----------------unmarshal bean
		self.melonlist[k]=RollMelon:new()

		self.melonlist[k]:unmarshal(_os_)

	end
	self.watcher = _os_:unmarshal_int32()
	return _os_
end

return STeamRollMelon

require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.teamapplybasic"
SAddTeamApply = {}
SAddTeamApply.__index = SAddTeamApply



SAddTeamApply.PROTOCOL_TYPE = 794437

function SAddTeamApply.Create()
	print("enter SAddTeamApply create")
	return SAddTeamApply:new()
end
function SAddTeamApply:new()
	local self = {}
	setmetatable(self, SAddTeamApply)
	self.type = self.PROTOCOL_TYPE
	self.applylist = {}

	return self
end
function SAddTeamApply:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddTeamApply:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.applylist))
	for k,v in ipairs(self.applylist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SAddTeamApply:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_applylist=0 ,_os_null_applylist
	_os_null_applylist, sizeof_applylist = _os_: uncompact_uint32(sizeof_applylist)
	for k = 1,sizeof_applylist do
		----------------unmarshal bean
		self.applylist[k]=TeamApplyBasic:new()

		self.applylist[k]:unmarshal(_os_)

	end
	return _os_
end

return SAddTeamApply

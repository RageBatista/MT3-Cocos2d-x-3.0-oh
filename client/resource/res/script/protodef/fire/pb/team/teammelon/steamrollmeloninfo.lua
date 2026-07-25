require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.teammelon.melonitembaginfo"
require "protodef.rpcgen.fire.pb.team.teammelon.rolerollinfo"
STeamRollMelonInfo = {}
STeamRollMelonInfo.__index = STeamRollMelonInfo



STeamRollMelonInfo.PROTOCOL_TYPE = 794524

function STeamRollMelonInfo.Create()
	print("enter STeamRollMelonInfo create")
	return STeamRollMelonInfo:new()
end
function STeamRollMelonInfo:new()
	local self = {}
	setmetatable(self, STeamRollMelonInfo)
	self.type = self.PROTOCOL_TYPE
	self.melonid = 0
	self.rollinfolist = {}
	self.grabroleid = 0
	self.grabrolename = "" 
	self.melonitemlist = {}

	return self
end
function STeamRollMelonInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STeamRollMelonInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.melonid)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rollinfolist))
	for k,v in ipairs(self.rollinfolist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int64(self.grabroleid)
	_os_:marshal_wstring(self.grabrolename)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.melonitemlist))
	for k,v in ipairs(self.melonitemlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function STeamRollMelonInfo:unmarshal(_os_)
	self.melonid = _os_:unmarshal_int64()
	----------------unmarshal list
	local sizeof_rollinfolist=0 ,_os_null_rollinfolist
	_os_null_rollinfolist, sizeof_rollinfolist = _os_: uncompact_uint32(sizeof_rollinfolist)
	for k = 1,sizeof_rollinfolist do
		----------------unmarshal bean
		self.rollinfolist[k]=RoleRollInfo:new()

		self.rollinfolist[k]:unmarshal(_os_)

	end
	self.grabroleid = _os_:unmarshal_int64()
	self.grabrolename = _os_:unmarshal_wstring(self.grabrolename)
	----------------unmarshal list
	local sizeof_melonitemlist=0 ,_os_null_melonitemlist
	_os_null_melonitemlist, sizeof_melonitemlist = _os_: uncompact_uint32(sizeof_melonitemlist)
	for k = 1,sizeof_melonitemlist do
		----------------unmarshal bean
		self.melonitemlist[k]=MelonItemBagInfo:new()

		self.melonitemlist[k]:unmarshal(_os_)

	end
	return _os_
end

return STeamRollMelonInfo

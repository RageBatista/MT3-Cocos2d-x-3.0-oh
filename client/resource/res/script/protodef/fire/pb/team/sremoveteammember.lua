require "utils.tableutil"
SRemoveTeamMember = {}
SRemoveTeamMember.__index = SRemoveTeamMember



SRemoveTeamMember.PROTOCOL_TYPE = 794438

function SRemoveTeamMember.Create()
	print("enter SRemoveTeamMember create")
	return SRemoveTeamMember:new()
end
function SRemoveTeamMember:new()
	local self = {}
	setmetatable(self, SRemoveTeamMember)
	self.type = self.PROTOCOL_TYPE
	self.memberids = {}

	return self
end
function SRemoveTeamMember:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRemoveTeamMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.memberids))
	for k,v in ipairs(self.memberids) do
		_os_:marshal_int64(v)
	end

	return _os_
end

function SRemoveTeamMember:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_memberids=0 ,_os_null_memberids
	_os_null_memberids, sizeof_memberids = _os_: uncompact_uint32(sizeof_memberids)
	for k = 1,sizeof_memberids do
		self.memberids[k] = _os_:unmarshal_int64()
	end
	return _os_
end

return SRemoveTeamMember

require "utils.tableutil"
STeamVote = {}
STeamVote.__index = STeamVote



STeamVote.PROTOCOL_TYPE = 786524

function STeamVote.Create()
	print("enter STeamVote create")
	return STeamVote:new()
end
function STeamVote:new()
	local self = {}
	setmetatable(self, STeamVote)
	self.type = self.PROTOCOL_TYPE
	self.flag = 0
	self.parms = {}

	return self
end
function STeamVote:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STeamVote:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.flag)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.parms))
	for k,v in ipairs(self.parms) do
		_os_:marshal_wstring(v)
	end

	return _os_
end

function STeamVote:unmarshal(_os_)
	self.flag = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_parms=0 ,_os_null_parms
	_os_null_parms, sizeof_parms = _os_: uncompact_uint32(sizeof_parms)
	for k = 1,sizeof_parms do
		self.parms[k] = _os_:unmarshal_wstring(self.parms[k])
	end
	return _os_
end

return STeamVote

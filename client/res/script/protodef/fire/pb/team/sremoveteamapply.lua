require "utils.tableutil"
SRemoveTeamApply = {}
SRemoveTeamApply.__index = SRemoveTeamApply



SRemoveTeamApply.PROTOCOL_TYPE = 794439

function SRemoveTeamApply.Create()
	print("enter SRemoveTeamApply create")
	return SRemoveTeamApply:new()
end
function SRemoveTeamApply:new()
	local self = {}
	setmetatable(self, SRemoveTeamApply)
	self.type = self.PROTOCOL_TYPE
	self.applyids = {}

	return self
end
function SRemoveTeamApply:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRemoveTeamApply:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.applyids))
	for k,v in ipairs(self.applyids) do
		_os_:marshal_int64(v)
	end

	return _os_
end

function SRemoveTeamApply:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_applyids=0 ,_os_null_applyids
	_os_null_applyids, sizeof_applyids = _os_: uncompact_uint32(sizeof_applyids)
	for k = 1,sizeof_applyids do
		self.applyids[k] = _os_:unmarshal_int64()
	end
	return _os_
end

return SRemoveTeamApply

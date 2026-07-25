require "utils.tableutil"
SRefreshContribution = {}
SRefreshContribution.__index = SRefreshContribution



SRefreshContribution.PROTOCOL_TYPE = 808497

function SRefreshContribution.Create()
	print("enter SRefreshContribution create")
	return SRefreshContribution:new()
end
function SRefreshContribution:new()
	local self = {}
	setmetatable(self, SRefreshContribution)
	self.type = self.PROTOCOL_TYPE
	self.currentcontribution = 0

	return self
end
function SRefreshContribution:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshContribution:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.currentcontribution)
	return _os_
end

function SRefreshContribution:unmarshal(_os_)
	self.currentcontribution = _os_:unmarshal_int32()
	return _os_
end

return SRefreshContribution

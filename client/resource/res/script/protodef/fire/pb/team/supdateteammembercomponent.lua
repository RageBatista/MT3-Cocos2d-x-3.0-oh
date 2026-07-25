require "utils.tableutil"
SUpdateTeamMemberComponent = {}
SUpdateTeamMemberComponent.__index = SUpdateTeamMemberComponent



SUpdateTeamMemberComponent.PROTOCOL_TYPE = 794488

function SUpdateTeamMemberComponent.Create()
	print("enter SUpdateTeamMemberComponent create")
	return SUpdateTeamMemberComponent:new()
end
function SUpdateTeamMemberComponent:new()
	local self = {}
	setmetatable(self, SUpdateTeamMemberComponent)
	self.type = self.PROTOCOL_TYPE
	self.memberid = 0
	self.components = {}

	return self
end
function SUpdateTeamMemberComponent:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateTeamMemberComponent:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.memberid)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SUpdateTeamMemberComponent:unmarshal(_os_)
	self.memberid = _os_:unmarshal_int64()
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	return _os_
end

return SUpdateTeamMemberComponent

require "utils.tableutil"
CZhenrongMember = {}
CZhenrongMember.__index = CZhenrongMember



CZhenrongMember.PROTOCOL_TYPE = 818838

function CZhenrongMember.Create()
	print("enter CZhenrongMember create")
	return CZhenrongMember:new()
end
function CZhenrongMember:new()
	local self = {}
	setmetatable(self, CZhenrongMember)
	self.type = self.PROTOCOL_TYPE
	self.zhenyingid = 0
	self.members = {}

	return self
end
function CZhenrongMember:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CZhenrongMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.zhenyingid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.members))
	for k,v in ipairs(self.members) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function CZhenrongMember:unmarshal(_os_)
	self.zhenyingid = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_members=0,_os_null_members
	_os_null_members, sizeof_members = _os_: uncompact_uint32(sizeof_members)
	for k = 1,sizeof_members do
		self.members[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return CZhenrongMember

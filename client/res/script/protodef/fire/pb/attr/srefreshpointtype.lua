require "utils.tableutil"
require "protodef.rpcgen.fire.pb.attr.rolebasicfightproperties"
SRefreshPointType = {}
SRefreshPointType.__index = SRefreshPointType



SRefreshPointType.PROTOCOL_TYPE = 799435

function SRefreshPointType.Create()
	print("enter SRefreshPointType create")
	return SRefreshPointType:new()
end
function SRefreshPointType:new()
	local self = {}
	setmetatable(self, SRefreshPointType)
	self.type = self.PROTOCOL_TYPE
	self.bfp = RoleBasicFightProperties:new()
	self.point = {}
	self.pointscheme = 0
	self.schemechanges = 0

	return self
end
function SRefreshPointType:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPointType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.bfp:marshal(_os_) 

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.point))
	for k,v in pairs(self.point) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.pointscheme)
	_os_:marshal_int32(self.schemechanges)
	return _os_
end

function SRefreshPointType:unmarshal(_os_)
	----------------unmarshal bean

	self.bfp:unmarshal(_os_)

	----------------unmarshal map
	local sizeof_point=0,_os_null_point
	_os_null_point, sizeof_point = _os_: uncompact_uint32(sizeof_point)
	for k = 1,sizeof_point do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.point[newkey] = newvalue
	end
	self.pointscheme = _os_:unmarshal_int32()
	self.schemechanges = _os_:unmarshal_int32()
	return _os_
end

return SRefreshPointType

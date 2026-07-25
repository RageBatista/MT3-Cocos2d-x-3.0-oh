require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
SRequestSpaceRoleInfo = {}
SRequestSpaceRoleInfo.__index = SRequestSpaceRoleInfo



SRequestSpaceRoleInfo.PROTOCOL_TYPE = 806539

function SRequestSpaceRoleInfo.Create()
	print("enter SRequestSpaceRoleInfo create")
	return SRequestSpaceRoleInfo:new()
end
function SRequestSpaceRoleInfo:new()
	local self = {}
	setmetatable(self, SRequestSpaceRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.friendinfobean = InfoBean:new()
	self.title = 0
	self.reqtype = 0
	self.components = {}

	return self
end
function SRequestSpaceRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestSpaceRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.friendinfobean:marshal(_os_) 
	_os_:marshal_int32(self.title)
	_os_:marshal_int32(self.reqtype)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SRequestSpaceRoleInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.friendinfobean:unmarshal(_os_)

	self.title = _os_:unmarshal_int32()
	self.reqtype = _os_:unmarshal_int32()
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

return SRequestSpaceRoleInfo

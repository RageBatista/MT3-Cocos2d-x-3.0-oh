require "utils.tableutil"
require "protodef.rpcgen.fire.pb.bag"
require "protodef.rpcgen.fire.pb.item"
SGetRoleInfo = {}
SGetRoleInfo.__index = SGetRoleInfo



SGetRoleInfo.PROTOCOL_TYPE = 787710

function SGetRoleInfo.Create()
	print("enter SGetRoleInfo create")
	return SGetRoleInfo:new()
end
function SGetRoleInfo:new()
	local self = {}
	setmetatable(self, SGetRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.rolename = "" 
	self.shape = 0
	self.school = 0
	self.level = 0
	self.equipscore = 0
	self.packinfo = Bag:new()
	self.tips = {}

	return self
end
function SGetRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.equipscore)
	----------------marshal bean
	self.packinfo:marshal(_os_) 

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.tips))
	for k,v in pairs(self.tips) do
		_os_:marshal_int32(k)
		_os_: marshal_octets(v)
	end

	return _os_
end

function SGetRoleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.shape = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.equipscore = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.packinfo:unmarshal(_os_)

	----------------unmarshal map
	local sizeof_tips=0,_os_null_tips
	_os_null_tips, sizeof_tips = _os_: uncompact_uint32(sizeof_tips)
	for k = 1,sizeof_tips do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = FireNet.Octets()
		_os_:unmarshal_octets(newvalue)
		self.tips[newkey] = newvalue
	end
	return _os_
end

return SGetRoleInfo

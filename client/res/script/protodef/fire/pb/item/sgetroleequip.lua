require "utils.tableutil"
require "protodef.rpcgen.fire.pb.bag"
require "protodef.rpcgen.fire.pb.item"
SGetRoleEquip = {}
SGetRoleEquip.__index = SGetRoleEquip



SGetRoleEquip.PROTOCOL_TYPE = 787479

function SGetRoleEquip.Create()
	print("enter SGetRoleEquip create")
	return SGetRoleEquip:new()
end
function SGetRoleEquip:new()
	local self = {}
	setmetatable(self, SGetRoleEquip)
	self.type = self.PROTOCOL_TYPE
	self.rolename = "" 
	self.totalscore = 0
	self.equipinfo = Bag:new()
	self.tips = {}
	self.components = {}
	self.profession = 0
	self.rolelevel = 0
	self.roleid = 0
	self.shape = 0

	return self
end
function SGetRoleEquip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetRoleEquip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.totalscore)
	----------------marshal bean
	self.equipinfo:marshal(_os_) 

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.tips))
	for k,v in pairs(self.tips) do
		_os_:marshal_int32(k)
		_os_: marshal_octets(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.profession)
	_os_:marshal_int32(self.rolelevel)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.shape)
	return _os_
end

function SGetRoleEquip:unmarshal(_os_)
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.totalscore = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.equipinfo:unmarshal(_os_)

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
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	self.profession = _os_:unmarshal_int32()
	self.rolelevel = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.shape = _os_:unmarshal_int32()
	return _os_
end

return SGetRoleEquip

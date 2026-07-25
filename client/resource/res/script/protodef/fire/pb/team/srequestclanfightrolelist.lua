require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.rolesimapleinfo"
SRequestClanFightRoleList = {}
SRequestClanFightRoleList.__index = SRequestClanFightRoleList



SRequestClanFightRoleList.PROTOCOL_TYPE = 794560

function SRequestClanFightRoleList.Create()
	print("enter SRequestClanFightRoleList create")
	return SRequestClanFightRoleList:new()
end
function SRequestClanFightRoleList:new()
	local self = {}
	setmetatable(self, SRequestClanFightRoleList)
	self.type = self.PROTOCOL_TYPE
	self.isfresh = 0
	self.rolelist = {}
	self.ret = 0

	return self
end
function SRequestClanFightRoleList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestClanFightRoleList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.isfresh)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rolelist))
	for k,v in ipairs(self.rolelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.ret)
	return _os_
end

function SRequestClanFightRoleList:unmarshal(_os_)
	self.isfresh = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_rolelist=0 ,_os_null_rolelist
	_os_null_rolelist, sizeof_rolelist = _os_: uncompact_uint32(sizeof_rolelist)
	for k = 1,sizeof_rolelist do
		----------------unmarshal bean
		self.rolelist[k]=RoleSimapleInfo:new()

		self.rolelist[k]:unmarshal(_os_)

	end
	self.ret = _os_:unmarshal_int32()
	return _os_
end

return SRequestClanFightRoleList

require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.rolebaseinfo"
SRequestApply = {}
SRequestApply.__index = SRequestApply



SRequestApply.PROTOCOL_TYPE = 808456

function SRequestApply.Create()
	print("enter SRequestApply create")
	return SRequestApply:new()
end
function SRequestApply:new()
	local self = {}
	setmetatable(self, SRequestApply)
	self.type = self.PROTOCOL_TYPE
	self.applylist = {}

	return self
end
function SRequestApply:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestApply:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.applylist))
	for k,v in ipairs(self.applylist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRequestApply:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_applylist=0,_os_null_applylist
	_os_null_applylist, sizeof_applylist = _os_: uncompact_uint32(sizeof_applylist)
	for k = 1,sizeof_applylist do
		----------------unmarshal bean
		self.applylist[k]=RoleBaseInfo:new()

		self.applylist[k]:unmarshal(_os_)

	end
	return _os_
end

return SRequestApply

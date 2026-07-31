require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.applyclan"
SApplyClanList = {}
SApplyClanList.__index = SApplyClanList



SApplyClanList.PROTOCOL_TYPE = 808494

function SApplyClanList.Create()
	print("enter SApplyClanList create")
	return SApplyClanList:new()
end
function SApplyClanList:new()
	local self = {}
	setmetatable(self, SApplyClanList)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.applyclanlist = {}

	return self
end
function SApplyClanList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SApplyClanList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.applyclanlist))
	for k,v in ipairs(self.applyclanlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SApplyClanList:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	----------------unmarshal vector
	local sizeof_applyclanlist=0,_os_null_applyclanlist
	_os_null_applyclanlist, sizeof_applyclanlist = _os_: uncompact_uint32(sizeof_applyclanlist)
	for k = 1,sizeof_applyclanlist do
		----------------unmarshal bean
		self.applyclanlist[k]=ApplyClan:new()

		self.applyclanlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SApplyClanList

require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.masterprenticebasedata"
SPreviousMasters = {}
SPreviousMasters.__index = SPreviousMasters



SPreviousMasters.PROTOCOL_TYPE = 816451

function SPreviousMasters.Create()
	print("enter SPreviousMasters create")
	return SPreviousMasters:new()
end
function SPreviousMasters:new()
	local self = {}
	setmetatable(self, SPreviousMasters)
	self.type = self.PROTOCOL_TYPE
	self.masters = {}

	return self
end
function SPreviousMasters:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPreviousMasters:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.masters))
	for k,v in pairs(self.masters) do
		_os_:marshal_int64(k)
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SPreviousMasters:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_masters=0,_os_null_masters
	_os_null_masters, sizeof_masters = _os_: uncompact_uint32(sizeof_masters)
	for k = 1,sizeof_masters do
		local newkey, newvalue
		newkey = _os_:unmarshal_int64()
		----------------unmarshal bean
		newvalue=MasterPrenticeBaseData:new()

		newvalue:unmarshal(_os_)

		self.masters[newkey] = newvalue
	end
	return _os_
end

return SPreviousMasters

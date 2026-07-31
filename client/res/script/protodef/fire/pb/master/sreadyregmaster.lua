require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.master"
SReadyRegMaster = {}
SReadyRegMaster.__index = SReadyRegMaster



SReadyRegMaster.PROTOCOL_TYPE = 816434

function SReadyRegMaster.Create()
	print("enter SReadyRegMaster create")
	return SReadyRegMaster:new()
end
function SReadyRegMaster:new()
	local self = {}
	setmetatable(self, SReadyRegMaster)
	self.type = self.PROTOCOL_TYPE
	self.masters = {}

	return self
end
function SReadyRegMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReadyRegMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.masters))
	for k,v in ipairs(self.masters) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SReadyRegMaster:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_masters=0,_os_null_masters
	_os_null_masters, sizeof_masters = _os_: uncompact_uint32(sizeof_masters)
	for k = 1,sizeof_masters do
		----------------unmarshal bean
		self.masters[k]=Master:new()

		self.masters[k]:unmarshal(_os_)

	end
	return _os_
end

return SReadyRegMaster

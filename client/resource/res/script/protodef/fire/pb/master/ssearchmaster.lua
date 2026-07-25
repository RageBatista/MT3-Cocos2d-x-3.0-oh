require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.master"
SSearchMaster = {}
SSearchMaster.__index = SSearchMaster



SSearchMaster.PROTOCOL_TYPE = 816438

function SSearchMaster.Create()
	print("enter SSearchMaster create")
	return SSearchMaster:new()
end
function SSearchMaster:new()
	local self = {}
	setmetatable(self, SSearchMaster)
	self.type = self.PROTOCOL_TYPE
	self.pageid = 0
	self.totalpage = 0
	self.masters = {}

	return self
end
function SSearchMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSearchMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pageid)
	_os_:marshal_int32(self.totalpage)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.masters))
	for k,v in ipairs(self.masters) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SSearchMaster:unmarshal(_os_)
	self.pageid = _os_:unmarshal_int32()
	self.totalpage = _os_:unmarshal_int32()
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

return SSearchMaster

require "utils.tableutil"
require "protodef.rpcgen.fire.pb.npc.impexambean"
SSendImpExamProv = {}
SSendImpExamProv.__index = SSendImpExamProv



SSendImpExamProv.PROTOCOL_TYPE = 795462

function SSendImpExamProv.Create()
	print("enter SSendImpExamProv create")
	return SSendImpExamProv:new()
end
function SSendImpExamProv:new()
	local self = {}
	setmetatable(self, SSendImpExamProv)
	self.type = self.PROTOCOL_TYPE
	self.impexamdata = ImpExamBean:new()
	self.lost = 0
	self.titlename = "" 
	self.rightmap = {}

	return self
end
function SSendImpExamProv:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendImpExamProv:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.impexamdata:marshal(_os_) 
	_os_:marshal_char(self.lost)
	_os_:marshal_wstring(self.titlename)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.rightmap))
	for k,v in pairs(self.rightmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SSendImpExamProv:unmarshal(_os_)
	----------------unmarshal bean

	self.impexamdata:unmarshal(_os_)

	self.lost = _os_:unmarshal_char()
	self.titlename = _os_:unmarshal_wstring(self.titlename)
	----------------unmarshal map
	local sizeof_rightmap=0,_os_null_rightmap
	_os_null_rightmap, sizeof_rightmap = _os_: uncompact_uint32(sizeof_rightmap)
	for k = 1,sizeof_rightmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.rightmap[newkey] = newvalue
	end
	return _os_
end

return SSendImpExamProv

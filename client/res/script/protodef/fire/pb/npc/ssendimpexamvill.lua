require "utils.tableutil"
require "protodef.rpcgen.fire.pb.npc.impexambean"
SSendImpExamVill = {}
SSendImpExamVill.__index = SSendImpExamVill



SSendImpExamVill.PROTOCOL_TYPE = 795461

function SSendImpExamVill.Create()
	print("enter SSendImpExamVill create")
	return SSendImpExamVill:new()
end
function SSendImpExamVill:new()
	local self = {}
	setmetatable(self, SSendImpExamVill)
	self.type = self.PROTOCOL_TYPE
	self.impexamdata = ImpExamBean:new()
	self.historyright = 0
	self.isover = 0

	return self
end
function SSendImpExamVill:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendImpExamVill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.impexamdata:marshal(_os_) 
	_os_:marshal_int32(self.historyright)
	_os_:marshal_char(self.isover)
	return _os_
end

function SSendImpExamVill:unmarshal(_os_)
	----------------unmarshal bean

	self.impexamdata:unmarshal(_os_)

	self.historyright = _os_:unmarshal_int32()
	self.isover = _os_:unmarshal_char()
	return _os_
end

return SSendImpExamVill

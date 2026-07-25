require "utils.tableutil"
require "protodef.rpcgen.fire.pb.npc.impexambean"
SSendImpExamState = {}
SSendImpExamState.__index = SSendImpExamState



SSendImpExamState.PROTOCOL_TYPE = 795463

function SSendImpExamState.Create()
	print("enter SSendImpExamState create")
	return SSendImpExamState:new()
end
function SSendImpExamState:new()
	local self = {}
	setmetatable(self, SSendImpExamState)
	self.type = self.PROTOCOL_TYPE
	self.impexamdata = ImpExamBean:new()
	self.historymintime = 0
	self.historymaxright = 0
	self.titlename = "" 
	self.lost = 0
	self.impexamusetime = 0

	return self
end
function SSendImpExamState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendImpExamState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.impexamdata:marshal(_os_) 
	_os_:marshal_int64(self.historymintime)
	_os_:marshal_int32(self.historymaxright)
	_os_:marshal_wstring(self.titlename)
	_os_:marshal_char(self.lost)
	_os_:marshal_int64(self.impexamusetime)
	return _os_
end

function SSendImpExamState:unmarshal(_os_)
	----------------unmarshal bean

	self.impexamdata:unmarshal(_os_)

	self.historymintime = _os_:unmarshal_int64()
	self.historymaxright = _os_:unmarshal_int32()
	self.titlename = _os_:unmarshal_wstring(self.titlename)
	self.lost = _os_:unmarshal_char()
	self.impexamusetime = _os_:unmarshal_int64()
	return _os_
end

return SSendImpExamState

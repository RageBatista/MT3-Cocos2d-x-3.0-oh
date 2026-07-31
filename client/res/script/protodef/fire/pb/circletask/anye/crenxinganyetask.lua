require "utils.tableutil"
CRenXingAnYeTask = {}
CRenXingAnYeTask.__index = CRenXingAnYeTask



CRenXingAnYeTask.PROTOCOL_TYPE = 807456

function CRenXingAnYeTask.Create()
	print("enter CRenXingAnYeTask create")
	return CRenXingAnYeTask:new()
end
function CRenXingAnYeTask:new()
	local self = {}
	setmetatable(self, CRenXingAnYeTask)
	self.type = self.PROTOCOL_TYPE
	self.taskpos = 0
	self.moneytype = 0

	return self
end
function CRenXingAnYeTask:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRenXingAnYeTask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.taskpos)
	_os_:marshal_int32(self.moneytype)
	return _os_
end

function CRenXingAnYeTask:unmarshal(_os_)
	self.taskpos = _os_:unmarshal_int32()
	self.moneytype = _os_:unmarshal_int32()
	return _os_
end

return CRenXingAnYeTask

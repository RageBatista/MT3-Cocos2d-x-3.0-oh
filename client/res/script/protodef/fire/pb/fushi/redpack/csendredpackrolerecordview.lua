require "utils.tableutil"
CSendRedPackRoleRecordView = {}
CSendRedPackRoleRecordView.__index = CSendRedPackRoleRecordView



CSendRedPackRoleRecordView.PROTOCOL_TYPE = 812540

function CSendRedPackRoleRecordView.Create()
	print("enter CSendRedPackRoleRecordView create")
	return CSendRedPackRoleRecordView:new()
end
function CSendRedPackRoleRecordView:new()
	local self = {}
	setmetatable(self, CSendRedPackRoleRecordView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.redpackid = "" 

	return self
end
function CSendRedPackRoleRecordView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendRedPackRoleRecordView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_wstring(self.redpackid)
	return _os_
end

function CSendRedPackRoleRecordView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.redpackid = _os_:unmarshal_wstring(self.redpackid)
	return _os_
end

return CSendRedPackRoleRecordView

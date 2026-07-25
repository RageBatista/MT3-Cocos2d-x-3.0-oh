require "utils.tableutil"
PBaseInfo = {}
PBaseInfo.__index = PBaseInfo


function PBaseInfo:new()
	local self = {}
	setmetatable(self, PBaseInfo)
	self.roleid = 0
	self.rolename = "" 
	self.level = 0
	self.school = 0
	self.camp = 0
	self.shap = 0

	return self
end
function PBaseInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.camp)
	_os_:marshal_int32(self.shap)
	return _os_
end

function PBaseInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.level = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.camp = _os_:unmarshal_int32()
	self.shap = _os_:unmarshal_int32()
	return _os_
end

return PBaseInfo

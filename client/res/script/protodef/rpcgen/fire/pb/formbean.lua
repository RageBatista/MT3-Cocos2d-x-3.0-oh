require "utils.tableutil"
FormBean = {}
FormBean.__index = FormBean


function FormBean:new()
	local self = {}
	setmetatable(self, FormBean)
	self.activetimes = 0
	self.level = 0
	self.exp = 0

	return self
end
function FormBean:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.activetimes)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.exp)
	return _os_
end

function FormBean:unmarshal(_os_)
	self.activetimes = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.exp = _os_:unmarshal_int32()
	return _os_
end

return FormBean

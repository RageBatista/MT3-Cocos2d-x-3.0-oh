require "utils.tableutil"
SubmitUnit = {}
SubmitUnit.__index = SubmitUnit


function SubmitUnit:new()
	local self = {}
	setmetatable(self, SubmitUnit)
	self.key = 0
	self.num = 0

	return self
end
function SubmitUnit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.num)
	return _os_
end

function SubmitUnit:unmarshal(_os_)
	self.key = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return SubmitUnit

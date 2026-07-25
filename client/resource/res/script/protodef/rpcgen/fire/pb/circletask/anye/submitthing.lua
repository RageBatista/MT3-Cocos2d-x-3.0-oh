require "utils.tableutil"
SubmitThing = {}
SubmitThing.__index = SubmitThing


function SubmitThing:new()
	local self = {}
	setmetatable(self, SubmitThing)
	self.key = 0
	self.num = 0

	return self
end
function SubmitThing:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.num)
	return _os_
end

function SubmitThing:unmarshal(_os_)
	self.key = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return SubmitThing

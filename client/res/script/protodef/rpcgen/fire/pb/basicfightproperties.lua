require "utils.tableutil"
BasicFightProperties = {}
BasicFightProperties.__index = BasicFightProperties


function BasicFightProperties:new()
	local self = {}
	setmetatable(self, BasicFightProperties)
	self.cons = 0
	self.iq = 0
	self.str = 0
	self.endu = 0
	self.agi = 0

	return self
end
function BasicFightProperties:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.cons)
	_os_:marshal_short(self.iq)
	_os_:marshal_short(self.str)
	_os_:marshal_short(self.endu)
	_os_:marshal_short(self.agi)
	return _os_
end

function BasicFightProperties:unmarshal(_os_)
	self.cons = _os_:unmarshal_short()
	self.iq = _os_:unmarshal_short()
	self.str = _os_:unmarshal_short()
	self.endu = _os_:unmarshal_short()
	self.agi = _os_:unmarshal_short()
	return _os_
end

return BasicFightProperties

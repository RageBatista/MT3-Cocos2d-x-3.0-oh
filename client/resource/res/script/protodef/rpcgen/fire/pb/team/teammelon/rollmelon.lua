require "utils.tableutil"
RollMelon = {}
RollMelon.__index = RollMelon


function RollMelon:new()
	local self = {}
	setmetatable(self, RollMelon)
	self.melonid = 0
	self.itemid = 0
	self.itemnum = 0
	self.itemdata = FireNet.Octets() 

	return self
end
function RollMelon:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.melonid)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.itemnum)
	_os_: marshal_octets(self.itemdata)
	return _os_
end

function RollMelon:unmarshal(_os_)
	self.melonid = _os_:unmarshal_int64()
	self.itemid = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_int32()
	_os_:unmarshal_octets(self.itemdata)
	return _os_
end

return RollMelon

require "utils.tableutil"
SRRedPackNum = {}
SRRedPackNum.__index = SRRedPackNum


function SRRedPackNum:new()
	local self = {}
	setmetatable(self, SRRedPackNum)
	self.modeltype = 0
	self.redpacksendnum = 0
	self.redpackreceivenum = 0
	self.redpackreceivefushinum = 0

	return self
end
function SRRedPackNum:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_int32(self.redpacksendnum)
	_os_:marshal_int32(self.redpackreceivenum)
	_os_:marshal_int32(self.redpackreceivefushinum)
	return _os_
end

function SRRedPackNum:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.redpacksendnum = _os_:unmarshal_int32()
	self.redpackreceivenum = _os_:unmarshal_int32()
	self.redpackreceivefushinum = _os_:unmarshal_int32()
	return _os_
end

return SRRedPackNum

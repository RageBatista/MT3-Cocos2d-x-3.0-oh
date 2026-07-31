require "utils.tableutil"

FaBaoInfo = {}
FaBaoInfo.__index = FaBaoInfo


function FaBaoInfo:new()
	local self = {}
	setmetatable(self, FaBaoInfo)
	self.id = 0   
	self.level = 0
	self.exp = 0
	self.weizhi = 0
	self.num = 0
	self.jinjie = 0
	self.texiao1 = 0
	self.texiao2 = 0
	self.texiao3 = 0
	self.texiao4 = 0
	self.texiao5 = 0

	return self
end
function FaBaoInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.exp)
	_os_:marshal_int32(self.weizhi)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.jinjie)
	_os_:marshal_int32(self.texiao1)
	_os_:marshal_int32(self.texiao2)
	_os_:marshal_int32(self.texiao3)
	_os_:marshal_int32(self.texiao4)
	_os_:marshal_int32(self.texiao5)
	return _os_
end

function FaBaoInfo:unmarshal(_os_)

	self.id = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.exp = _os_:unmarshal_int32()
	self.weizhi = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.jinjie = _os_:unmarshal_int32()
	self.texiao1 = _os_:unmarshal_int32()
	self.texiao2 = _os_:unmarshal_int32()
	self.texiao3 = _os_:unmarshal_int32()
	self.texiao4 = _os_:unmarshal_int32()
	self.texiao5 = _os_:unmarshal_int32()
	return _os_
end

return FaBaoInfo

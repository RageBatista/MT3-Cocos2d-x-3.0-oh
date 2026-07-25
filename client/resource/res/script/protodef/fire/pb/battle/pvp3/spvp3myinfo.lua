require "utils.tableutil"
SPvP3MyInfo = {}
SPvP3MyInfo.__index = SPvP3MyInfo



SPvP3MyInfo.PROTOCOL_TYPE = 793634

function SPvP3MyInfo.Create()
	print("enter SPvP3MyInfo create")
	return SPvP3MyInfo:new()
end
function SPvP3MyInfo:new()
	local self = {}
	setmetatable(self, SPvP3MyInfo)
	self.type = self.PROTOCOL_TYPE
	self.firstwin = 0
	self.tenfight = 0
	self.eightwin = 0
	self.battlenum = 0
	self.winnum = 0
	self.combowinnum = 0
	self.score = 0
	self.ready = 0

	return self
end
function SPvP3MyInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP3MyInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.firstwin)
	_os_:marshal_char(self.tenfight)
	_os_:marshal_char(self.eightwin)
	_os_:marshal_char(self.battlenum)
	_os_:marshal_char(self.winnum)
	_os_:marshal_short(self.combowinnum)
	_os_:marshal_int32(self.score)
	_os_:marshal_char(self.ready)
	return _os_
end

function SPvP3MyInfo:unmarshal(_os_)
	self.firstwin = _os_:unmarshal_char()
	self.tenfight = _os_:unmarshal_char()
	self.eightwin = _os_:unmarshal_char()
	self.battlenum = _os_:unmarshal_char()
	self.winnum = _os_:unmarshal_char()
	self.combowinnum = _os_:unmarshal_short()
	self.score = _os_:unmarshal_int32()
	self.ready = _os_:unmarshal_char()
	return _os_
end

return SPvP3MyInfo

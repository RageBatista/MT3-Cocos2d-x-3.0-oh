require "utils.tableutil"
SPvP1MyInfo = {}
SPvP1MyInfo.__index = SPvP1MyInfo



SPvP1MyInfo.PROTOCOL_TYPE = 793534

function SPvP1MyInfo.Create()
	print("enter SPvP1MyInfo create")
	return SPvP1MyInfo:new()
end
function SPvP1MyInfo:new()
	local self = {}
	setmetatable(self, SPvP1MyInfo)
	self.type = self.PROTOCOL_TYPE
	self.firstwin = 0
	self.tenfight = 0
	self.tencombowin = 0
	self.battlenum = 0
	self.score = 0
	self.winnum = 0
	self.combowinnum = 0
	self.formation = 0
	self.ready = 0
	self.jieci = 0
	self.changci = 0

	return self
end
function SPvP1MyInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP1MyInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.firstwin)
	_os_:marshal_char(self.tenfight)
	_os_:marshal_char(self.tencombowin)
	_os_:marshal_char(self.battlenum)
	_os_:marshal_int32(self.score)
	_os_:marshal_char(self.winnum)
	_os_:marshal_short(self.combowinnum)
	_os_:marshal_char(self.formation)
	_os_:marshal_char(self.ready)
	_os_:marshal_int32(self.jieci)
	_os_:marshal_int32(self.changci)
	return _os_
end

function SPvP1MyInfo:unmarshal(_os_)
	self.firstwin = _os_:unmarshal_char()
	self.tenfight = _os_:unmarshal_char()
	self.tencombowin = _os_:unmarshal_char()
	self.battlenum = _os_:unmarshal_char()
	self.score = _os_:unmarshal_int32()
	self.winnum = _os_:unmarshal_char()
	self.combowinnum = _os_:unmarshal_short()
	self.formation = _os_:unmarshal_char()
	self.ready = _os_:unmarshal_char()
	self.jieci = _os_:unmarshal_int32()
	self.changci = _os_:unmarshal_int32()
	return _os_
end

return SPvP1MyInfo

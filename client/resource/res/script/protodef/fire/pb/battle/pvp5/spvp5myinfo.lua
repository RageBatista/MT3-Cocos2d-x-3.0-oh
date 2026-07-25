require "utils.tableutil"
SPvP5MyInfo = {}
SPvP5MyInfo.__index = SPvP5MyInfo



SPvP5MyInfo.PROTOCOL_TYPE = 793664

function SPvP5MyInfo.Create()
	print("enter SPvP5MyInfo create")
	return SPvP5MyInfo:new()
end
function SPvP5MyInfo:new()
	local self = {}
	setmetatable(self, SPvP5MyInfo)
	self.type = self.PROTOCOL_TYPE
	self.firstwin = 0
	self.fivefight = 0
	self.battlenum = 0
	self.winnum = 0
	self.combowinnum = 0
	self.score = 0
	self.camp = 0
	self.waitstarttime = 0

	return self
end
function SPvP5MyInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP5MyInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.firstwin)
	_os_:marshal_char(self.fivefight)
	_os_:marshal_char(self.battlenum)
	_os_:marshal_char(self.winnum)
	_os_:marshal_char(self.combowinnum)
	_os_:marshal_int32(self.score)
	_os_:marshal_char(self.camp)
	_os_:marshal_int64(self.waitstarttime)
	return _os_
end

function SPvP5MyInfo:unmarshal(_os_)
	self.firstwin = _os_:unmarshal_char()
	self.fivefight = _os_:unmarshal_char()
	self.battlenum = _os_:unmarshal_char()
	self.winnum = _os_:unmarshal_char()
	self.combowinnum = _os_:unmarshal_char()
	self.score = _os_:unmarshal_int32()
	self.camp = _os_:unmarshal_char()
	self.waitstarttime = _os_:unmarshal_int64()
	return _os_
end

return SPvP5MyInfo

require "utils.tableutil"
SRemoveTuiSong = {}
SRemoveTuiSong.__index = SRemoveTuiSong



SRemoveTuiSong.PROTOCOL_TYPE = 805521

function SRemoveTuiSong.Create()
	print("enter SRemoveTuiSong create")
	return SRemoveTuiSong:new()
end
function SRemoveTuiSong:new()
	local self = {}
	setmetatable(self, SRemoveTuiSong)
	self.type = self.PROTOCOL_TYPE
	self.removeid = 0

	return self
end
function SRemoveTuiSong:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRemoveTuiSong:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.removeid)
	return _os_
end

function SRemoveTuiSong:unmarshal(_os_)
	self.removeid = _os_:unmarshal_int32()
	return _os_
end

return SRemoveTuiSong

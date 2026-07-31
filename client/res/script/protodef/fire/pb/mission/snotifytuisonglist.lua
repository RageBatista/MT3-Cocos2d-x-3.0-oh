require "utils.tableutil"
SNotifyTuiSongList = {}
SNotifyTuiSongList.__index = SNotifyTuiSongList



SNotifyTuiSongList.PROTOCOL_TYPE = 805518

function SNotifyTuiSongList.Create()
	print("enter SNotifyTuiSongList create")
	return SNotifyTuiSongList:new()
end
function SNotifyTuiSongList:new()
	local self = {}
	setmetatable(self, SNotifyTuiSongList)
	self.type = self.PROTOCOL_TYPE
	self.notifylist = {}

	return self
end
function SNotifyTuiSongList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNotifyTuiSongList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.notifylist))
	for k,v in ipairs(self.notifylist) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SNotifyTuiSongList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_notifylist=0 ,_os_null_notifylist
	_os_null_notifylist, sizeof_notifylist = _os_: uncompact_uint32(sizeof_notifylist)
	for k = 1,sizeof_notifylist do
		self.notifylist[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SNotifyTuiSongList

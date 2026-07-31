require "utils.tableutil"
SPvP1BattleInfo = {}
SPvP1BattleInfo.__index = SPvP1BattleInfo



SPvP1BattleInfo.PROTOCOL_TYPE = 793540

function SPvP1BattleInfo.Create()
	print("enter SPvP1BattleInfo create")
	return SPvP1BattleInfo:new()
end
function SPvP1BattleInfo:new()
	local self = {}
	setmetatable(self, SPvP1BattleInfo)
	self.type = self.PROTOCOL_TYPE
	self.ismine = 0
	self.msgid = 0
	self.parameters = {}

	return self
end
function SPvP1BattleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP1BattleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.ismine)
	_os_:marshal_int32(self.msgid)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.parameters))
	for k,v in ipairs(self.parameters) do
		_os_: marshal_octets(v)
	end

	return _os_
end

function SPvP1BattleInfo:unmarshal(_os_)
	self.ismine = _os_:unmarshal_char()
	self.msgid = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_parameters=0 ,_os_null_parameters
	_os_null_parameters, sizeof_parameters = _os_: uncompact_uint32(sizeof_parameters)
	for k = 1,sizeof_parameters do
		self.parameters[k] = FireNet.Octets()
		_os_:unmarshal_octets(self.parameters[k])
	end
	return _os_
end

return SPvP1BattleInfo

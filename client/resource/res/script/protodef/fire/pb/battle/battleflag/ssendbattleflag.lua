require "utils.tableutil"
SSendBattleFlag = {}
SSendBattleFlag.__index = SSendBattleFlag



SSendBattleFlag.PROTOCOL_TYPE = 793884

function SSendBattleFlag.Create()
	print("enter SSendBattleFlag create")
	return SSendBattleFlag:new()
end
function SSendBattleFlag:new()
	local self = {}
	setmetatable(self, SSendBattleFlag)
	self.type = self.PROTOCOL_TYPE
	self.friendflags = {}
	self.enemyflags = {}

	return self
end
function SSendBattleFlag:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendBattleFlag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.friendflags))
	for k,v in ipairs(self.friendflags) do
		_os_:marshal_wstring(v)
	end


	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.enemyflags))
	for k,v in ipairs(self.enemyflags) do
		_os_:marshal_wstring(v)
	end

	return _os_
end

function SSendBattleFlag:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_friendflags=0 ,_os_null_friendflags
	_os_null_friendflags, sizeof_friendflags = _os_: uncompact_uint32(sizeof_friendflags)
	for k = 1,sizeof_friendflags do
		self.friendflags[k] = _os_:unmarshal_wstring(self.friendflags[k])
	end
	----------------unmarshal list
	local sizeof_enemyflags=0 ,_os_null_enemyflags
	_os_null_enemyflags, sizeof_enemyflags = _os_: uncompact_uint32(sizeof_enemyflags)
	for k = 1,sizeof_enemyflags do
		self.enemyflags[k] = _os_:unmarshal_wstring(self.enemyflags[k])
	end
	return _os_
end

return SSendBattleFlag

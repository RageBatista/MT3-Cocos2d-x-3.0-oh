require "utils.tableutil"
LevelRankData = {}
LevelRankData.__index = LevelRankData


function LevelRankData:new()
	local self = {}
	setmetatable(self, LevelRankData)
	self.roleid = 0
	self.nickname = "" 
	self.level = 0
	self.school = 0
	self.rank = 0
	self.Shape = 0
	self.color1 = 0
	self.color2 = 0
	self.components = {}
	return self
end
function LevelRankData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.nickname)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.rank)
	_os_:marshal_int32(self.Shape)
	_os_:marshal_int32(self.color1)
	_os_:marshal_int32(self.color2)
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_int32(k)   -- ✅ 修复：4字节int（匹配服务器端）
		_os_:marshal_int32(v)
	end
	return _os_
end

function LevelRankData:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.nickname = _os_:unmarshal_wstring(self.nickname)
	self.level = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.rank = _os_:unmarshal_int32()
	self.Shape = _os_:unmarshal_int32()
	self.color1 = _os_:unmarshal_int32()
	self.color2 = _os_:unmarshal_int32()
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_:uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()   -- ✅ 修复：4字节int（匹配服务器端）
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	return _os_
end

return LevelRankData

require "utils.tableutil"
SRefreshQuestData = {}
SRefreshQuestData.__index = SRefreshQuestData



SRefreshQuestData.PROTOCOL_TYPE = 807438

function SRefreshQuestData.Create()
	print("enter SRefreshQuestData create")
	return SRefreshQuestData:new()
end
function SRefreshQuestData:new()
	local self = {}
	setmetatable(self, SRefreshQuestData)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0
	self.datas = {}

	return self
end
function SRefreshQuestData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshQuestData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.datas))
	for k,v in pairs(self.datas) do
		_os_:marshal_int32(k)
		_os_:marshal_int64(v)
	end

	return _os_
end

function SRefreshQuestData:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_datas=0,_os_null_datas
	_os_null_datas, sizeof_datas = _os_: uncompact_uint32(sizeof_datas)
	for k = 1,sizeof_datas do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int64()
		self.datas[newkey] = newvalue
	end
	return _os_
end

return SRefreshQuestData

require "utils.tableutil"
SGiveInfoList = {}
SGiveInfoList.__index = SGiveInfoList



SGiveInfoList.PROTOCOL_TYPE = 806634

function SGiveInfoList.Create()
	print("enter SGiveInfoList create")
	return SGiveInfoList:new()
end
function SGiveInfoList:new()
	local self = {}
	setmetatable(self, SGiveInfoList)
	self.type = self.PROTOCOL_TYPE
	self.givenummap = {}

	return self
end
function SGiveInfoList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGiveInfoList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.givenummap))
	for k,v in pairs(self.givenummap) do
		_os_:marshal_int64(k)
		_os_:marshal_char(v)
	end

	return _os_
end

function SGiveInfoList:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_givenummap=0,_os_null_givenummap
	_os_null_givenummap, sizeof_givenummap = _os_: uncompact_uint32(sizeof_givenummap)
	for k = 1,sizeof_givenummap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int64()
		newvalue = _os_:unmarshal_char()
		self.givenummap[newkey] = newvalue
	end
	return _os_
end

return SGiveInfoList

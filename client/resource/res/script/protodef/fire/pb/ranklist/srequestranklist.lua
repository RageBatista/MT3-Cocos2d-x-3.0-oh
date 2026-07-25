require "utils.tableutil"
SRequestRankList = {}
SRequestRankList.__index = SRequestRankList



SRequestRankList.PROTOCOL_TYPE = 810234

function SRequestRankList.Create()
	print("enter SRequestRankList create")
	return SRequestRankList:new()
end
function SRequestRankList:new()
	local self = {}
	setmetatable(self, SRequestRankList)
	self.type = self.PROTOCOL_TYPE
	self.ranktype = 0
	self.myrank = 0
	self.list = {}
	self.page = 0
	self.hasmore = 0
	self.mytitle = "" 
	self.takeawardflag = 0
	self.extdata = 0
	self.extdata1 = 0
	self.extdata2 = 0
	self.extdata3 = "" 

	return self
end
function SRequestRankList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestRankList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ranktype)
	_os_:marshal_int32(self.myrank)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.list))
	for k,v in ipairs(self.list) do
		_os_: marshal_octets(v)
	end

	_os_:marshal_int32(self.page)
	_os_:marshal_int32(self.hasmore)
	_os_:marshal_wstring(self.mytitle)
	_os_:marshal_char(self.takeawardflag)
	_os_:marshal_int32(self.extdata)
	_os_:marshal_int64(self.extdata1)
	_os_:marshal_float(self.extdata2)
	_os_:marshal_wstring(self.extdata3)
	return _os_
end

function SRequestRankList:unmarshal(_os_)
	self.ranktype = _os_:unmarshal_int32()
	self.myrank = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_list=0,_os_null_list
	_os_null_list, sizeof_list = _os_: uncompact_uint32(sizeof_list)
	for k = 1,sizeof_list do
		self.list[k] = FireNet.Octets()
		_os_:unmarshal_octets(self.list[k])
	end
	self.page = _os_:unmarshal_int32()
	self.hasmore = _os_:unmarshal_int32()
	self.mytitle = _os_:unmarshal_wstring(self.mytitle)
	self.takeawardflag = _os_:unmarshal_char()
	self.extdata = _os_:unmarshal_int32()
	self.extdata1 = _os_:unmarshal_int64()
	self.extdata2 = _os_:unmarshal_float()
	self.extdata3 = _os_:unmarshal_wstring(self.extdata3)
	return _os_
end

return SRequestRankList

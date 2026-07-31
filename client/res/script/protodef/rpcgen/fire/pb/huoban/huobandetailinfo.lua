require "utils.tableutil"
HuoBanDetailInfo = {}
HuoBanDetailInfo.__index = HuoBanDetailInfo


function HuoBanDetailInfo:new()
	local self = {}
	setmetatable(self, HuoBanDetailInfo)
	self.huobanid = 0
	self.infight = 0
	self.state = 0
	self.weekfree = 0
	self.datas = {}

	return self
end
function HuoBanDetailInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.huobanid)
	_os_:marshal_int32(self.infight)
	_os_:marshal_int64(self.state)
	_os_:marshal_int32(self.weekfree)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.datas))
	for k,v in ipairs(self.datas) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function HuoBanDetailInfo:unmarshal(_os_)
	self.huobanid = _os_:unmarshal_int32()
	self.infight = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int64()
	self.weekfree = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_datas=0,_os_null_datas
	_os_null_datas, sizeof_datas = _os_: uncompact_uint32(sizeof_datas)
	for k = 1,sizeof_datas do
		self.datas[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return HuoBanDetailInfo

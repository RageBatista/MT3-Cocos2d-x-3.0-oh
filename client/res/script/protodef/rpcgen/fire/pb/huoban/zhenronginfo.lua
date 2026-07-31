require "utils.tableutil"
ZhenrongInfo = {}
ZhenrongInfo.__index = ZhenrongInfo


function ZhenrongInfo:new()
	local self = {}
	setmetatable(self, ZhenrongInfo)
	self.zhenfa = 0
	self.huobanlist = {}

	return self
end
function ZhenrongInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.zhenfa)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.huobanlist))
	for k,v in ipairs(self.huobanlist) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function ZhenrongInfo:unmarshal(_os_)
	self.zhenfa = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_huobanlist=0,_os_null_huobanlist
	_os_null_huobanlist, sizeof_huobanlist = _os_: uncompact_uint32(sizeof_huobanlist)
	for k = 1,sizeof_huobanlist do
		self.huobanlist[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return ZhenrongInfo

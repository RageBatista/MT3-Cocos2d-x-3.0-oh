require "utils.tableutil"
CMarketBrowse = {}
CMarketBrowse.__index = CMarketBrowse



CMarketBrowse.PROTOCOL_TYPE = 810639

function CMarketBrowse.Create()
	print("enter CMarketBrowse create")
	return CMarketBrowse:new()
end
function CMarketBrowse:new()
	local self = {}
	setmetatable(self, CMarketBrowse)
	self.type = self.PROTOCOL_TYPE
	self.browsetype = 0
	self.firstno = 0
	self.twono = 0
	self.threeno = {}
	self.itemtype = 0
	self.limitmin = 0
	self.limitmax = 0
	self.currpage = 0
	self.pricesort = 0
	self.issearch = 0

	return self
end
function CMarketBrowse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketBrowse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.browsetype)
	_os_:marshal_int32(self.firstno)
	_os_:marshal_int32(self.twono)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.threeno))
	for k,v in ipairs(self.threeno) do
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.limitmin)
	_os_:marshal_int32(self.limitmax)
	_os_:marshal_int32(self.currpage)
	_os_:marshal_int32(self.pricesort)
	_os_:marshal_int32(self.issearch)
	return _os_
end

function CMarketBrowse:unmarshal(_os_)
	self.browsetype = _os_:unmarshal_int32()
	self.firstno = _os_:unmarshal_int32()
	self.twono = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_threeno=0,_os_null_threeno
	_os_null_threeno, sizeof_threeno = _os_: uncompact_uint32(sizeof_threeno)
	for k = 1,sizeof_threeno do
		self.threeno[k] = _os_:unmarshal_int32()
	end
	self.itemtype = _os_:unmarshal_int32()
	self.limitmin = _os_:unmarshal_int32()
	self.limitmax = _os_:unmarshal_int32()
	self.currpage = _os_:unmarshal_int32()
	self.pricesort = _os_:unmarshal_int32()
	self.issearch = _os_:unmarshal_int32()
	return _os_
end

return CMarketBrowse

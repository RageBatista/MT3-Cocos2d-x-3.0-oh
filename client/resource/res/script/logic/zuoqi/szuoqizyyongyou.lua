require "utils.tableutil"
SZuoQizyYongYou = {}
SZuoQizyYongYou.__index = SZuoQizyYongYou



SZuoQizyYongYou.PROTOCOL_TYPE = 800087

function SZuoQizyYongYou.Create()
	print("enter CChangeSchool create")
	return SZuoQizyYongYou:new()
end
function SZuoQizyYongYou:new()
	local self = {}
	setmetatable(self, SZuoQizyYongYou)
	self.type = self.PROTOCOL_TYPE
	self.id = 0
	self.tzid = 0
	self.weishiopen = 0
	self.zuoqix = {}
	self.petkey = {}
	self.shuxing = {}
	self.wenshiitems = {}
	self.petkeys = {}
	return self
end
function SZuoQizyYongYou:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SZuoQizyYongYou:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.tzid)
	_os_:marshal_int32(self.weishiopen)
	_os_:compact_uint32(TableUtil.tablelength(self.zuoqix))
	for k,v in pairs(self.zuoqix) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	_os_:compact_uint32(TableUtil.tablelength(self.petkey))
	for k,v in pairs(self.petkey) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	_os_:compact_uint32(TableUtil.tablelength(self.shuxing))
	for k,v in pairs(self.shuxing) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	_os_:compact_uint32(TableUtil.tablelength(self.wenshiitems))
	for k,v in pairs(self.wenshiitems) do
		_os_:marshal_int32(k)
		v:marshal(_os_)
	end
	_os_:compact_uint32(TableUtil.tablelength(self.petkeys))
	for k,v in pairs(self.petkeys) do
		_os_:marshal_int32(k)
		v:marshal(_os_)
	end
	return _os_
end

function SZuoQizyYongYou:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.tzid = _os_:unmarshal_int32()
	self.weishiopen = _os_:unmarshal_int32()
	local sizeof_zuoqi=0,_os_null_zuoqi
	_os_null_zuoqi, sizeof_zuoqi = _os_: uncompact_uint32(sizeof_zuoqi)
	for k = 1,sizeof_zuoqi do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.zuoqix[newkey] = newvalue
	end
	local sizeof_petkey=0,_os_null_petkey
	_os_null_petkey, sizeof_petkey = _os_: uncompact_uint32(sizeof_petkey)
	for k = 1,sizeof_petkey do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.petkey[newkey] = newvalue
	end
	local sizeof_shuxing=0,_os_null_shuxing
	_os_null_shuxing, sizeof_shuxing = _os_: uncompact_uint32(sizeof_shuxing)
	for k = 1,sizeof_shuxing do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.shuxing[newkey] = newvalue
	end
	local sizeof_wenshiitems=0,_os_null_wenshiitems
	_os_null_wenshiitems, sizeof_wenshiitems = _os_: uncompact_uint32(sizeof_wenshiitems)
	for k = 1,sizeof_wenshiitems do
		local newkey = _os_:unmarshal_int32()
		self.wenshiitems[newkey]=require "logic.zuoqi.wenshiitem":new()

		self.wenshiitems[newkey]:unmarshal(_os_)

	end
	local sizeof_petkeys=0,_os_null_petkeys
	_os_null_petkeys, sizeof_petkeys = _os_: uncompact_uint32(sizeof_petkeys)
	for k = 1,sizeof_petkeys do
		local newkey = _os_:unmarshal_int32()
		self.petkeys[newkey]=require "logic.zuoqi.zuoqipetkey":new()

		self.petkeys[newkey]:unmarshal(_os_)

	end
	return _os_
end

return SZuoQizyYongYou

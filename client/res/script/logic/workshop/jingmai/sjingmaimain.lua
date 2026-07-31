require "utils.tableutil"

SJingMaiMain = {}
SJingMaiMain.__index = SJingMaiMain



SJingMaiMain.PROTOCOL_TYPE = 800109

function SJingMaiMain.Create()
	LogInfo("enter CChangeSchool create")
	return SJingMaiMain:new()
end
function SJingMaiMain:new()
	local self = {}
	setmetatable(self, SJingMaiMain)
	self.type = self.PROTOCOL_TYPE
	self.idx = 0
	self.qianyuandan = 0
	self.qiankundan = 0
	self.fangan = 0
	self.state = 0
	self.jingmais = {}
	self.xingchen = {}
	return self
end
function SJingMaiMain:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SJingMaiMain:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.idx)
	_os_:marshal_int32(self.qianyuandan)
	_os_:marshal_int32(self.qiankundan)
	_os_:marshal_int32(self.fangan)
	_os_:marshal_int32(self.state)
	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.jingmais))
	for k,v in ipairs(self.jingmais) do
		----------------marshal bean
        _os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	_os_:compact_uint32(TableUtil.tablelength(self.xingchen))
	for k,v in ipairs(self.xingchen) do
		----------------marshal bean
		_os_:marshal_int32(k)
		v:marshal(_os_)
	end

	return _os_
end

function SJingMaiMain:unmarshal(_os_)
	self.idx = _os_:unmarshal_int32()
	self.qianyuandan = _os_:unmarshal_int32()
	self.qiankundan = _os_:unmarshal_int32()
	self.fangan = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	local sizeof_jingmais=0,_os_null_jingmais
	_os_null_jingmais, sizeof_jingmais = _os_: uncompact_uint32(sizeof_jingmais)
	for k = 1,sizeof_jingmais do
		local newkey = _os_:unmarshal_int32()
		local newv = _os_:unmarshal_int32()
		self.jingmais[newkey]=newv
	end
	local sizeof_xingchen=0,_os_null_xingchen
	_os_null_xingchen, sizeof_xingchen = _os_: uncompact_uint32(sizeof_xingchen)
	for k = 1,sizeof_xingchen do
		local newkey = _os_:unmarshal_int32()
		self.xingchen[newkey]=require "logic.workshop.jingmai.xingchenitem":new()
		self.xingchen[newkey]:unmarshal(_os_)
	end
	return _os_
end
return SJingMaiMain

require "utils.tableutil"
CJingMaiSel = {}
CJingMaiSel.__index = CJingMaiSel



CJingMaiSel.PROTOCOL_TYPE = 800108

function CJingMaiSel.Create()
	print("enter CJingMaiSel create")
	return CJingMaiSel:new()
end
function CJingMaiSel:new()
	local self = {}
	setmetatable(self, CJingMaiSel)
	self.type = self.PROTOCOL_TYPE
	self.idx = 0
	self.index = 0
	self.itemkey = 0
	--self.maketype = 0
	--self.cailiaokey = 0
	--self.xingyinkeys = {}
	return self
end
function CJingMaiSel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CJingMaiSel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.idx)
	_os_:marshal_int32(self.index)
	_os_:marshal_int32(self.itemkey)
	--_os_:marshal_short(self.maketype)
	--_os_:marshal_int32(self.cailiaokey)
	--_os_:compact_uint32(TableUtil.tablelength(self.xingyinkeys))
	--for k,v in ipairs(self.xingyinkeys) do
	--	----------------marshal bean
	--	_os_:marshal_int32(k)
	--	_os_:marshal_int32(v)
	--end
	return _os_
end

function CJingMaiSel:unmarshal(_os_)
	self.idx = _os_:unmarshal_int32()
	self.index = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()

	--self.maketype = _os_:unmarshal_short()
	--self.cailiaokey = _os_:unmarshal_int32()
	--local sizeof_xingyinkeys=0,_os_null_xingyinkeys
	--_os_null_xingyinkeys, sizeof_xingyinkeys = _os_: uncompact_uint32(sizeof_xingyinkeys)
	--for k = 1,sizeof_xingyinkeys do
	--	local newkey = _os_:unmarshal_int32()
	--	local newv = _os_:unmarshal_int32()
	--	self.xingyinkeys[newkey]=newv
	--end
	return _os_
end

return CJingMaiSel

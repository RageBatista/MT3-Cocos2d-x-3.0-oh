require "utils.tableutil"
MailInfo = {}
MailInfo.__index = MailInfo


function MailInfo:new()
	local self = {}
	setmetatable(self, MailInfo)
	self.kind = 0
	self.id = 0
	self.readflag = 0
	self.time = "" 
	self.title = "" 
	self.contentid = 0
	self.content = "" 
	self.awardid = 0
	self.items = {}
	self.awardexp = 0
	self.awardfushi = 0
	self.awardgold = 0
	self.awardmoney = 0
	self.awardvipexp = 0
	self.npcid = 0

	return self
end
function MailInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.kind)
	_os_:marshal_int64(self.id)
	_os_:marshal_char(self.readflag)
	_os_:marshal_wstring(self.time)
	_os_:marshal_wstring(self.title)
	_os_:marshal_int32(self.contentid)
	_os_:marshal_wstring(self.content)
	_os_:marshal_int32(self.awardid)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.items))
	for k,v in pairs(self.items) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int64(self.awardexp)
	_os_:marshal_int64(self.awardfushi)
	_os_:marshal_int64(self.awardgold)
	_os_:marshal_int64(self.awardmoney)
	_os_:marshal_int64(self.awardvipexp)
	_os_:marshal_int32(self.npcid)
	return _os_
end

function MailInfo:unmarshal(_os_)
	self.kind = _os_:unmarshal_char()
	self.id = _os_:unmarshal_int64()
	self.readflag = _os_:unmarshal_char()
	self.time = _os_:unmarshal_wstring(self.time)
	self.title = _os_:unmarshal_wstring(self.title)
	self.contentid = _os_:unmarshal_int32()
	self.content = _os_:unmarshal_wstring(self.content)
	self.awardid = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_items=0,_os_null_items
	_os_null_items, sizeof_items = _os_: uncompact_uint32(sizeof_items)
	for k = 1,sizeof_items do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.items[newkey] = newvalue
	end
	self.awardexp = _os_:unmarshal_int64()
	self.awardfushi = _os_:unmarshal_int64()
	self.awardgold = _os_:unmarshal_int64()
	self.awardmoney = _os_:unmarshal_int64()
	self.awardvipexp = _os_:unmarshal_int64()
	self.npcid = _os_:unmarshal_int32()
	return _os_
end

return MailInfo

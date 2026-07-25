require "utils.tableutil"
require "protodef.rpcgen.fire.pb.item.mailinfo"
SMailList = {}
SMailList.__index = SMailList



SMailList.PROTOCOL_TYPE = 787700

function SMailList.Create()
	print("enter SMailList create")
	return SMailList:new()
end
function SMailList:new()
	local self = {}
	setmetatable(self, SMailList)
	self.type = self.PROTOCOL_TYPE
	self.maillist = {}

	return self
end
function SMailList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMailList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.maillist))
	for k,v in ipairs(self.maillist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SMailList:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_maillist=0,_os_null_maillist
	_os_null_maillist, sizeof_maillist = _os_: uncompact_uint32(sizeof_maillist)
	for k = 1,sizeof_maillist do
		----------------unmarshal bean
		self.maillist[k]=MailInfo:new()

		self.maillist[k]:unmarshal(_os_)

	end
	return _os_
end

return SMailList

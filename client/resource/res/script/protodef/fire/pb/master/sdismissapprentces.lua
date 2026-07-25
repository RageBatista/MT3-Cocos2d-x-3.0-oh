require "utils.tableutil"
require "protodef.rpcgen.fire.pb.master.prenticedata"
SDismissApprentces = {}
SDismissApprentces.__index = SDismissApprentces



SDismissApprentces.PROTOCOL_TYPE = 816476

function SDismissApprentces.Create()
	print("enter SDismissApprentces create")
	return SDismissApprentces:new()
end
function SDismissApprentces:new()
	local self = {}
	setmetatable(self, SDismissApprentces)
	self.type = self.PROTOCOL_TYPE
	self.prenticelist = {}

	return self
end
function SDismissApprentces:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDismissApprentces:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.prenticelist))
	for k,v in ipairs(self.prenticelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SDismissApprentces:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_prenticelist=0,_os_null_prenticelist
	_os_null_prenticelist, sizeof_prenticelist = _os_: uncompact_uint32(sizeof_prenticelist)
	for k = 1,sizeof_prenticelist do
		----------------unmarshal bean
		self.prenticelist[k]=PrenticeData:new()

		self.prenticelist[k]:unmarshal(_os_)

	end
	return _os_
end

return SDismissApprentces

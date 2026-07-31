require "utils.tableutil"
require "protodef.rpcgen.fire.pb.item.composegeminfobean"
CComposeGem = {}
CComposeGem.__index = CComposeGem



CComposeGem.PROTOCOL_TYPE = 787784

function CComposeGem.Create()
	print("enter CComposeGem create")
	return CComposeGem:new()
end
function CComposeGem:new()
	local self = {}
	setmetatable(self, CComposeGem)
	self.type = self.PROTOCOL_TYPE
	self.buserongheji = 0
	self.targetgemitemid = 0
	self.baggems = {}
	self.shopgems = {}

	return self
end
function CComposeGem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CComposeGem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.buserongheji)
	_os_:marshal_int32(self.targetgemitemid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.baggems))
	for k,v in ipairs(self.baggems) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.shopgems))
	for k,v in ipairs(self.shopgems) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function CComposeGem:unmarshal(_os_)
	self.buserongheji = _os_:unmarshal_char()
	self.targetgemitemid = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_baggems=0,_os_null_baggems
	_os_null_baggems, sizeof_baggems = _os_: uncompact_uint32(sizeof_baggems)
	for k = 1,sizeof_baggems do
		----------------unmarshal bean
		self.baggems[k]=ComposeGemInfoBean:new()

		self.baggems[k]:unmarshal(_os_)

	end
	----------------unmarshal vector
	local sizeof_shopgems=0,_os_null_shopgems
	_os_null_shopgems, sizeof_shopgems = _os_: uncompact_uint32(sizeof_shopgems)
	for k = 1,sizeof_shopgems do
		----------------unmarshal bean
		self.shopgems[k]=ComposeGemInfoBean:new()

		self.shopgems[k]:unmarshal(_os_)

	end
	return _os_
end

return CComposeGem

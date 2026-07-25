--[[
Author: 邹龙泉 14223976@qq.com
Date: 2023-07-24 15:00:38
LastEditors: 邹龙泉 14223976@qq.com
LastEditTime: 2023-07-24 19:40:27
FilePath: \ScrIpT\protodef\fire\pb\ranklist\cgetrankmodel.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
require "utils.tableutil"
CGetRankModel = {}
CGetRankModel.__index = CGetRankModel

CGetRankModel.PROTOCOL_TYPE = 810242

function CGetRankModel.Create()
    print("enter CGetRankModel create")
    return CGetRankModel:new()
end

function CGetRankModel:new()
    local self = {}
    setmetatable(self, CGetRankModel)
    self.type = self.PROTOCOL_TYPE
    self.id = 0
    self.rownum = 0 -- Existing field
    self.ranktype = 0 -- New field
    return self
end

function CGetRankModel:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end

function CGetRankModel:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_int32(self.id)
    _os_:marshal_int32(self.rownum) -- Existing field's marshal operation
    _os_:marshal_int32(self.ranktype) -- New field's marshal operation
    return _os_
end

function CGetRankModel:unmarshal(_os_)
    self.id = _os_:unmarshal_int32()
    self.rownum = _os_:unmarshal_int32() -- Existing field's unmarshal operation
    self.ranktype = _os_:unmarshal_int32() -- New field's unmarshal operation
    return _os_
end

return CGetRankModel



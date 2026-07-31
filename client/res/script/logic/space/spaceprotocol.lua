
Spaceprotocol = {}

Spaceprotocol.strFileDataParam = "$filedata$"
Spaceprotocol.strVoiceType = "mp3"
Spaceprotocol.nSavePicMax = 20


Spaceprotocol.nStatePicHeight=450   
Spaceprotocol.nStatePicWidth =400


Spaceprotocol.nHttpType = 1 --1=post
Spaceprotocol.nTimeout = 3

--wangbin test
-- 空间内网http://192.168.32.2:8803
-- 空间外网http://59.151.112.45:8821
function Spaceprotocol.getSpaceServerIp()
    --return "http://192.168.32.2:8803"
    --return "http://59.151.112.45:8821"
    
    local strSpaceIp = GetServerInfo():getHttpAdressByEnum(eHttpKongjianUrl)
    if not strSpaceIp or strSpaceIp=="" then
        strSpaceIp = "http://59.151.112.45:8821" 
    end
    return strSpaceIp
    
end

local Json_False = 0
local Json_True= 1
local Json_NULL=2
local Json_Number=3
local Json_String=4
local Json_Array=5
local Json_Object=6

Spaceprotocol.eProId=
{
    selfFriendAround=1,
    selfSayState=2,
    bbsList=3,
    roleInfo=4,
    sendState=5,
    setSign=6,
    setHead=7,
    setVoice=8,
    clickLike=9,
    comment=10,
    deleteComment=11,
    addPopularity=12,
    popularityList=13,
    receiveGiftList=14,
    liuyan=15,
    deleteBbs=16,
    getHead=17,
    getVoice=18,
    getPic=19,
    deleteState=20,
    setLocation=21,
    delHead = 22,
    delSound=23,
    npcCai = 24,
    npcLiuyanList=25,
    getCommentList=26,
    getShareParams = 27,

}

Spaceprotocol.mapApiName=
{
    [Spaceprotocol.eProId.selfFriendAround] = "/status/home_timeline",
    [Spaceprotocol.eProId.selfSayState] = "/status/user_timeline",
    [Spaceprotocol.eProId.bbsList] = "/bbs/bbs_timeline",
    [Spaceprotocol.eProId.roleInfo] = "/role/show",
    [Spaceprotocol.eProId.sendState] = "/status/update",
    [Spaceprotocol.eProId.setSign] = "/role/update_signature",
    [Spaceprotocol.eProId.setHead] = "/role/upload_avatar",
    [Spaceprotocol.eProId.setVoice] = "/role/upload_sound",
    [Spaceprotocol.eProId.clickLike] = "/status/update_favorite",
    [Spaceprotocol.eProId.comment] = "/status/create_comment",
    [Spaceprotocol.eProId.deleteComment] = "/status/destroy_comment",
    [Spaceprotocol.eProId.addPopularity] = "/bbs/add_popularity",
    [Spaceprotocol.eProId.popularityList] = "/bbs/popularity_timeline",
    [Spaceprotocol.eProId.receiveGiftList] = "/bbs/gift_timeline",
    [Spaceprotocol.eProId.liuyan] = "/bbs/create",
    [Spaceprotocol.eProId.deleteBbs] = "/bbs/destroy",

    [Spaceprotocol.eProId.getHead] = "",
    [Spaceprotocol.eProId.getVoice] = "",
    [Spaceprotocol.eProId.getPic] = "",

    [Spaceprotocol.eProId.deleteState] = "/status/delete",
    [Spaceprotocol.eProId.setLocation] = "/role/update_place",

    [Spaceprotocol.eProId.delHead] = "/role/del_avatar",
    [Spaceprotocol.eProId.delSound] = "/role/del_sound",


    [Spaceprotocol.eProId.npcCai] = "/bbs/add_popularity",
    [Spaceprotocol.eProId.npcLiuyanList] = "/bbs/bbs_timeline",

    [Spaceprotocol.eProId.getCommentList] = "/status/get_comment_list"
}

function Spaceprotocol.ReceiveRequest_process(strProtocolParam,strData,param2,param3)
    local vstrParam = StringBuilder.Split(strProtocolParam, ",")
    local nProtocolId = 0 --tonumber(strProtocolId)
    if #vstrParam >0 then
        nProtocolId = tonumber(vstrParam[1])
    end


    if nProtocolId==Spaceprotocol.eProId.selfFriendAround then
        require("logic.space.spacepro.spaceprotocol_selfFriendAround").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.selfSayState then
        require("logic.space.spacepro.spaceprotocol_selfSayState").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.bbsList then
        require("logic.space.spacepro.spaceprotocol_bbsList").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.roleInfo then
        require("logic.space.spacepro.spaceprotocol_roleInfo").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.sendState then
        require("logic.space.spacepro.spaceprotocol_sendState").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.setSign then
        require("logic.space.spacepro.spaceprotocol_setSign").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.setHead then
        require("logic.space.spacepro.spaceprotocol_setHead").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.setVoice then
        require("logic.space.spacepro.spaceprotocol_setVoice").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.clickLike then
        require("logic.space.spacepro.spaceprotocol_clickLike").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.comment then
        require("logic.space.spacepro.spaceprotocol_comment").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.deleteComment then
        require("logic.space.spacepro.spaceprotocol_deleteComment").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.addPopularity then
        require("logic.space.spacepro.spaceprotocol_addPopularity").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.popularityList then
        require("logic.space.spacepro.spaceprotocol_popularityList").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.receiveGiftList then
        require("logic.space.spacepro.spaceprotocol_receiveGiftList").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.liuyan then
        require("logic.space.spacepro.spaceprotocol_liuyan").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.deleteBbs then
        require("logic.space.spacepro.spaceprotocol_deleteBbs").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.getHead then
        require("logic.space.spacepro.spaceprotocol_getHead").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.getVoice then
        require("logic.space.spacepro.spaceprotocol_getVoice").process(strData,vstrParam)
     elseif nProtocolId==Spaceprotocol.eProId.getPic then
        require("logic.space.spacepro.spaceprotocol_getPic").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.deleteState then
        require("logic.space.spacepro.spaceprotocol_deleteState").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.setLocation then
        require("logic.space.spacepro.spaceprotocol_setLocation").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.delHead then
        require("logic.space.spacepro.spaceprotocol_delHead").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.delSound then
        require("logic.space.spacepro.spaceprotocol_delSound").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.npcLiuyanList then 
        require("logic.space.spacepro.spaceprotocol_npcLiuyanList").process(strData,vstrParam)
    elseif nProtocolId==Spaceprotocol.eProId.getCommentList then 
        require("logic.space.spacepro.spaceprotocol_getCommentList").process(strData,vstrParam)
    elseif nProtocolId == Spaceprotocol.eProId.getShareParams then
        require("logic.share.sharedlg").process(strData,vstrParam)
    end
end



function Spaceprotocol.getServerId()
    local nServerId = gGetLoginManager():getServerID()
    local strServerId = tostring(nServerId)
    return strServerId
end

function Spaceprotocol.getUrlApi(nProtocolId)
    local strServerIp = Spaceprotocol.getSpaceServerIp() 
    local strApiName = Spaceprotocol.mapApiName[nProtocolId]
    local strUrl = strServerIp..strApiName
    return strUrl
end

function Spaceprotocol.getUrl(nProtocolId)
    local strServerIp = Spaceprotocol.getSpaceServerIp() 
    local strApiName = Spaceprotocol.mapApiName[nProtocolId]
    local strServerId = Spaceprotocol.getServerId()
    local strUrl = strServerIp..strApiName..strServerId
    return strUrl
end

--[[
#结果实例
{"errno":"","message":"","data":[
{"status_id":"31","roleid":"1","status":"0","create_time":"1459856336","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","favorites":[],"comments":[]},
{"status_id":"30","roleid":"1","status":"0","create_time":"1459856248","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","favorites":[],"comments":[]},
{"status_id":"29","roleid":"1","status":"0","create_time":"1459856222","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","favorites":[],"comments":[]},
{"status_id":"28","roleid":"1","status":"0","create_time":"1459853477","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","favorites":[],"comments":[]}]}

--]]
--"avatar":"0","level":"0"


function Spaceprotocol.toCorrectStateData(roleStateData)
    if not roleStateData.nStateId  then
        roleStateData.nStateId = 0
    end
    if not roleStateData.nnRoleId  then
        roleStateData.nnRoleId = 0
    end
    if not roleStateData.nShapeId  then
        roleStateData.nShapeId = 0
    end
    if not roleStateData.nLevel  then
        roleStateData.nLevel = 0
    end
    if not roleStateData.strUserName  then
        roleStateData.strUserName = ""
    end
    if not roleStateData.nStatus  then
        roleStateData.nStatus = 0
    end
    if not roleStateData.nnSendTime  then
        roleStateData.nnSendTime = 0
    end

    if not roleStateData.strRoleSay  then
        roleStateData.strRoleSay = ""
    end
    if not roleStateData.strPicUrl then
          roleStateData.strPicUrl=""
    end
    if not roleStateData.nLikeCount  then
        roleStateData.nLikeCount = 0
    end
    if not roleStateData.nSayToCount  then
        roleStateData.nSayToCount = 0
    end
    
end


function Spaceprotocol.urlDecode(strString)
    return strString
end

function Spaceprotocol.urlEncode(strString)
    return strString
end

function Spaceprotocol.readOneState(roleStateData,pJson_roleStateData)
    if not pJson_roleStateData then
        return
    end

    roleStateData.strUserName = gGetSpaceManager():SpaceJson_getString(pJson_roleStateData,"name","")
    roleStateData.strRoleSay = gGetSpaceManager():SpaceJson_getString(pJson_roleStateData,"content","")
    roleStateData.strRoleSay = Spaceprotocol.replaceColor(roleStateData.strRoleSay)


    --[[
    local pJson_likeArray = gGetSpaceManager():SpaceJson_getItem(pJson_roleStateData,"favorites")
    if pJson_likeArray then
        local nLikeCount = pJson_likeArray.size
        local pJson_oneLike = pJson_likeArray.child
        for nIndex=1,nLikeCount do
             roleStateData.vLikeRole[nIndex].strUserName = gGetSpaceManager():SpaceJson_getString(pJson_oneLike,"name","")
             pJson_oneLike = pJson_oneLike.next
        end
    end
    --]]
    --[[
    local pJson_commentArray = gGetSpaceManager():SpaceJson_getItem(pJson_roleStateData,"comments")
    if pJson_commentArray then
        local nCommentCount = pJson_commentArray.size
        local pJson_oneComment = pJson_commentArray.child
        for nIndex=1,nCommentCount do
            
            local oneSayTo = roleStateData.vSayToRole[nIndex]
            Spaceprotocol.readOneComment(oneSayTo,pJson_oneComment)
        end
    end
    --]]
    --------------------------------

    local strDefaultValue = "0"
    local pJson = pJson_roleStateData
    --oneLeftWord.nBbsId = tonumber(Spaceprotocol.getJsonString(pJson,"bbs_id",strDefaultValue))

    roleStateData.nStateId = tonumber(Spaceprotocol.getJsonString(pJson,"status_id",strDefaultValue)) --tonumber(roleStateDataServer.status_id)
    roleStateData.nnRoleId = tonumber(Spaceprotocol.getJsonString(pJson,"roleid",strDefaultValue)) --tonumber(roleStateDataServer.roleid)
    roleStateData.nShapeId = tonumber(Spaceprotocol.getJsonString(pJson,"avatar",strDefaultValue)) --tonumber(roleStateDataServer.avatar)

    if roleStateData.nShapeId then
        local createRoleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(roleStateData.nShapeId)
        if createRoleTable then
            roleStateData.nShapeId = createRoleTable.model
        end
    end

    roleStateData.nLevel = tonumber(Spaceprotocol.getJsonString(pJson,"level",strDefaultValue)) --tonumber(roleStateDataServer.level)
    --roleStateData.strUserName = tonumber(Spaceprotocol.getJsonString(pJson,"name",strDefaultValue)) --Spaceprotocol.urlDecode(roleStateDataServer.name)
    roleStateData.nStatus = tonumber(Spaceprotocol.getJsonString(pJson,"status",strDefaultValue)) --tonumber(roleStateDataServer.status)
    roleStateData.nnSendTime = tonumber(Spaceprotocol.getJsonString(pJson,"create_time",strDefaultValue)) --tonumber(roleStateDataServer.create_time)
    --roleStateData.strRoleSay = Spaceprotocol.urlDecode(roleStateDataServer.content)
    roleStateData.strPicUrl = gGetSpaceManager():SpaceJson_getString(pJson,"img_url","") --roleStateDataServer.img_url

    --roleStateData.nLikeCount = tonumber(Spaceprotocol.getJsonString(pJson,"favorite_count",strDefaultValue)) --tonumber(roleStateDataServer.favorite_count)
    roleStateData.nSayToCount = tonumber(Spaceprotocol.getJsonString(pJson,"comment_count",strDefaultValue)) --tonumber(roleStateDataServer.comment_count)

    roleStateData.vLikeRole = {}
    --local vFavServer = roleStateDataServer.favorites
    --if not vFavServer then
    --    vFavServer = {}
    --end
    local pJson_likeArray = gGetSpaceManager():SpaceJson_getItem(pJson_roleStateData,"favorites")
    if pJson_likeArray then
        local nLikeCount = pJson_likeArray.size
        local pJson_oneLike = pJson_likeArray.child
        for nIndex=1,nLikeCount do
             roleStateData.vLikeRole[nIndex] = {}
             roleStateData.vLikeRole[nIndex].strUserName = gGetSpaceManager():SpaceJson_getString(pJson_oneLike,"name","")
             roleStateData.vLikeRole[nIndex].nnRoleId = tonumber(Spaceprotocol.getJsonString(pJson_oneLike,"roleid",strDefaultValue))  --tonumber(oneLikeServer.roleid)
             pJson_oneLike = pJson_oneLike.next
        end
    end
    --[[
    for k,oneLikeServer in pairs(vFavServer) do
        local oneRoleLike = {}
        oneRoleLike.strUserName = oneLikeServer.name 
        oneRoleLike.nnRoleId = tonumber(oneLikeServer.roleid)
        table.insert(roleStateData.vLikeRole,oneRoleLike)
    end
    --]]
    --[[
    roleStateData.vSayToRole = {}
    local vComment = roleStateDataServer.comments
    if not vComment then
        vComment = {}
    end

    for k,oneSayToServer in pairs(vComment) do
        local oneSayToRole = {}
        Spaceprotocol.readComment(oneSayToRole,oneSayToServer)
        table.insert(roleStateData.vSayToRole,oneSayToRole)
    end
    --]]
     roleStateData.vSayToRole = {}
    local pJson_commentArray = gGetSpaceManager():SpaceJson_getItem(pJson_roleStateData,"comments")
    if pJson_commentArray then
        local nCommentCount = pJson_commentArray.size
        local pJson_oneComment = pJson_commentArray.child
        for nIndex=1,nCommentCount do
            roleStateData.vSayToRole[nIndex] = {}
            local oneSayTo = roleStateData.vSayToRole[nIndex]
            Spaceprotocol.readOneComment(oneSayTo,pJson_oneComment)

            pJson_oneComment = pJson_oneComment.next
        end
    end

    Spaceprotocol.toCorrectStateData(roleStateData)

end

function Spaceprotocol.readRoleStateData(roleStateData,roleStateDataServer)
--[[
    if not roleStateDataServer then
        return
    end

    roleStateData.nStateId = tonumber(roleStateDataServer.status_id)
    roleStateData.nnRoleId = tonumber(roleStateDataServer.roleid)
    roleStateData.nShapeId = tonumber(roleStateDataServer.avatar)

    if roleStateData.nShapeId then
        local createRoleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(roleStateData.nShapeId)
        if createRoleTable then
            roleStateData.nShapeId = createRoleTable.model
        end
    end

    roleStateData.nLevel = tonumber(roleStateDataServer.level)
    roleStateData.strUserName = Spaceprotocol.urlDecode(roleStateDataServer.name)
    roleStateData.nStatus = tonumber(roleStateDataServer.status)
    roleStateData.nnSendTime = tonumber(roleStateDataServer.create_time)
    roleStateData.strRoleSay = Spaceprotocol.urlDecode(roleStateDataServer.content)
    roleStateData.strPicUrl = roleStateDataServer.img_url

    roleStateData.nLikeCount = tonumber(roleStateDataServer.favorite_count)
    roleStateData.nSayToCount = tonumber(roleStateDataServer.comment_count)

    roleStateData.vLikeRole = {}
    local vFavServer = roleStateDataServer.favorites
    if not vFavServer then
        vFavServer = {}
    end
    for k,oneLikeServer in pairs(vFavServer) do
        local oneRoleLike = {}
        oneRoleLike.strUserName = oneLikeServer.name 
        oneRoleLike.nnRoleId = tonumber(oneLikeServer.roleid)
        table.insert(roleStateData.vLikeRole,oneRoleLike)
    end

    roleStateData.vSayToRole = {}
    local vComment = roleStateDataServer.comments
    if not vComment then
        vComment = {}
    end

    for k,oneSayToServer in pairs(vComment) do
        local oneSayToRole = {}
        Spaceprotocol.readComment(oneSayToRole,oneSayToServer)
        table.insert(roleStateData.vSayToRole,oneSayToRole)
    end

    Spaceprotocol.toCorrectStateData(roleStateData)
    --]]
end

function Spaceprotocol.readOneComment(oneSayTo,pJson_oneComment)
    oneSayTo.sendRole = {}
    oneSayTo.targetRole = {}

    oneSayTo.strSayContent = gGetSpaceManager():SpaceJson_getString(pJson_oneComment,"content","")
    oneSayTo.sendRole.strUserName = gGetSpaceManager():SpaceJson_getString(pJson_oneComment,"name","")
    oneSayTo.targetRole.strUserName = gGetSpaceManager():SpaceJson_getString(pJson_oneComment,"reply_name","")

    oneSayTo.strSayContent = Spaceprotocol.replaceColor(oneSayTo.strSayContent)

    local strDefaultValue = "0"
    local pJson = pJson_oneComment
    --oneLeftWord.nBbsId = tonumber(Spaceprotocol.getJsonString(pJson,"bbs_id",strDefaultValue))

    oneSayTo.nCommentId = tonumber(Spaceprotocol.getJsonString(pJson,"status_comment_id",strDefaultValue)) --tonumber(commentServer.status_comment_id)
    oneSayTo.nnRoleId = tonumber(Spaceprotocol.getJsonString(pJson,"roleid",strDefaultValue))  --tonumber(commentServer.roleid)
    oneSayTo.nStateId = tonumber(Spaceprotocol.getJsonString(pJson,"status_id",strDefaultValue)) --tonumber(commentServer.status_id)
    oneSayTo.nToCommentId = tonumber(Spaceprotocol.getJsonString(pJson,"reply_id",strDefaultValue)) --tonumber(commentServer.reply_id)
    --oneSayTo.strSayContent = Spaceprotocol.urlDecode(commentServer.content)
    
    
    oneSayTo.sendRole.nnRoleId =tonumber(Spaceprotocol.getJsonString(pJson,"roleid",strDefaultValue)) -- tonumber(commentServer.roleid)
    --oneSayTo.sendRole.strUserName = Spaceprotocol.urlDecode(commentServer.name) 

    if oneSayTo.nToCommentId==0 then
        oneSayTo.targetRole.nnRoleId = oneSayTo.nnRoleId
        oneSayTo.targetRole.strUserName = ""
    else
        oneSayTo.targetRole.nnRoleId = tonumber(Spaceprotocol.getJsonString(pJson,"reply_roleid",strDefaultValue)) --tonumber(commentServer.reply_roleid)
        --oneSayTo.targetRole.strUserName = Spaceprotocol.urlDecode(commentServer.reply_name)
    end
    
    Spaceprotocol.toCorrectComment(oneSayTo)

end

function Spaceprotocol.readComment(oneSayTo,commentServer)
--[[
    oneSayTo.nCommentId = tonumber(commentServer.status_comment_id)
    oneSayTo.nnRoleId = tonumber(commentServer.roleid)
    oneSayTo.nStateId = tonumber(commentServer.status_id)
    oneSayTo.nToCommentId = tonumber(commentServer.reply_id)
    oneSayTo.strSayContent = Spaceprotocol.urlDecode(commentServer.content)
    
    oneSayTo.sendRole = {}
    oneSayTo.targetRole = {}
    oneSayTo.sendRole.nnRoleId = tonumber(commentServer.roleid)
    oneSayTo.sendRole.strUserName = Spaceprotocol.urlDecode(commentServer.name) 

    if oneSayTo.nToCommentId==0 then
        oneSayTo.targetRole.nnRoleId = oneSayTo.nnRoleId
        oneSayTo.targetRole.strUserName = ""
    else
        oneSayTo.targetRole.nnRoleId = tonumber(commentServer.reply_roleid)
        oneSayTo.targetRole.strUserName = Spaceprotocol.urlDecode(commentServer.reply_name)
    end
    
    Spaceprotocol.toCorrectComment(oneSayTo)
    -]]
end



function Spaceprotocol.toCorrectComment(commentData)
    if not commentData.nCommentId then
        commentData.nCommentId = 0
    end
    if not commentData.nToRoleId then
        commentData.nToRoleId = 0
    end
    if not commentData.nStateId then
        commentData.nStateId = 0
    end
    if not commentData.nToCommentId then
        commentData.nToCommentId = 0
    end
    if not commentData.strSayContent then
        commentData.strSayContent = ""
    end

    if not commentData.sendRole.nnRoleId then
        commentData.sendRole.nnRoleId = 0
    end
    if not commentData.sendRole.strUserName then
        commentData.sendRole.strUserName = ""
    end

    if not commentData.targetRole.nnRoleId then
        commentData.targetRole.nnRoleId = 0
    end
    if not commentData.targetRole.strUserName then
        commentData.targetRole.strUserName = ""
    end
end

--[[
#字段说明
status_comment_id 评论id
status_id 动态id
roleid 角色id
content 评论内容
reply_id 回复评论id
reply_roleid 回复角色id
create_time 创建时间
name 评论者名字
avatar 评论者头像
level 评论者等级
reply_name 被回复人id
reply_avatar 被回复人头像
reply_level 被回复人等级


--]]

--c="ffffffff" strContent = "<T t="ikk； 酷米， " c="FFFFFFFF"></T>"
function Spaceprotocol.replaceColor(strContent)
    local strColor = getSpaceManager():getNormalTextColor()
    strColor = "c=".."\""..strColor.."\""
    local strOld = "c=\"FFFFFFFF\""
    if string.find(strContent, strOld) then
         strContent = string.gsub(strContent, strOld, strColor)
    end
    return strContent
end

function Spaceprotocol.getJsonInt(pJson,strKey,nDefaultValue)
    local nValue = gGetSpaceManager():SpaceJson_getInt(pJson,strKey,nDefaultValue)
    return nValue
end



function Spaceprotocol.getJsonString(pJson,strKey,strDefaultValue)

    local pJsonItem = gGetSpaceManager():SpaceJson_getItem(pJson,strKey)
    if not pJsonItem then
        return strDefaultValue
    end

    if pJsonItem.type ~=Json_String then
        return strDefaultValue
    end

    local strValue = gGetSpaceManager():SpaceJson_getString(pJson,strKey,strDefaultValue)
    if not strValue then
        strValue = strDefaultValue
    end
    return strValue
end


function Spaceprotocol.readOneLeaveWord(oneLeftWord,pJson_oneLeaveWord)
    if not pJson_oneLeaveWord then
        return
    end

    oneLeftWord.strUserName = gGetSpaceManager():SpaceJson_getString(pJson_oneLeaveWord,"name","")
    oneLeftWord.strContent = gGetSpaceManager():SpaceJson_getString(pJson_oneLeaveWord,"content","")
    oneLeftWord.strToRoleName = gGetSpaceManager():SpaceJson_getString(pJson_oneLeaveWord,"reply_name","")

    oneLeftWord.strContent =Spaceprotocol.replaceColor(oneLeftWord.strContent)

    local strDefaultValue = "0"
    local pJson = pJson_oneLeaveWord
    oneLeftWord.nBbsId = tonumber(Spaceprotocol.getJsonString(pJson,"bbs_id",strDefaultValue))
    oneLeftWord.nnRoleId = tonumber(Spaceprotocol.getJsonString(pJson,"roleid",strDefaultValue)) --tonumber(oneLeftServer.roleid)
    oneLeftWord.nStatus = tonumber(Spaceprotocol.getJsonString(pJson,"status",strDefaultValue)) --tonumber(oneLeftServer.status)
    oneLeftWord.nLevel = tonumber(Spaceprotocol.getJsonString(pJson,"level",strDefaultValue)) --tonumber(oneLeftServer.level)
    oneLeftWord.nnSendTime = tonumber(Spaceprotocol.getJsonString(pJson,"create_time",strDefaultValue)) --tonumber(oneLeftServer.create_time)
    oneLeftWord.nShapeId = tonumber(Spaceprotocol.getJsonString(pJson,"avatar",strDefaultValue)) --tonumber(oneLeftServer.avatar)
    oneLeftWord.nItemId = tonumber(Spaceprotocol.getJsonString(pJson,"gift_id",strDefaultValue)) --tonumber(oneLeftServer.gift_id)
    oneLeftWord.nItemNum = tonumber(Spaceprotocol.getJsonString(pJson,"gift_count",strDefaultValue)) --tonumber(oneLeftServer.gift_count)
    oneLeftWord.nToBbsId = tonumber(Spaceprotocol.getJsonString(pJson,"reply_id",strDefaultValue)) --tonumber(oneLeftServer.reply_id)
    oneLeftWord.nToRoleId =  tonumber(Spaceprotocol.getJsonString(pJson,"reply_roleid",strDefaultValue)) --tonumber(oneLeftServer.reply_roleid)

     if oneLeftWord.nShapeId then
        local createRoleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(oneLeftWord.nShapeId)
        if createRoleTable then
            oneLeftWord.nShapeId = createRoleTable.model
        end
    end

    Spaceprotocol.toCorrectBbsData(oneLeftWord)
end

function Spaceprotocol.readOneReceiveGift(oneLeftWord,pJson_oneLeaveWord)
    if not pJson_oneLeaveWord then
        return
    end

    oneLeftWord.strUserName = gGetSpaceManager():SpaceJson_getString(pJson_oneLeaveWord,"name","")
    oneLeftWord.strContent = gGetSpaceManager():SpaceJson_getString(pJson_oneLeaveWord,"content","")
    oneLeftWord.strToRoleName = gGetSpaceManager():SpaceJson_getString(pJson_oneLeaveWord,"reply_name","")

    oneLeftWord.strContent =Spaceprotocol.replaceColor(oneLeftWord.strContent)

    local strDefaultValue = "0"
    local pJson = pJson_oneLeaveWord
    oneLeftWord.nBbsId = tonumber(Spaceprotocol.getJsonString(pJson,"bbs_gift_id",strDefaultValue))
    oneLeftWord.nnRoleId = tonumber(Spaceprotocol.getJsonString(pJson,"roleid",strDefaultValue)) --tonumber(oneLeftServer.roleid)
    oneLeftWord.nStatus = tonumber(Spaceprotocol.getJsonString(pJson,"status",strDefaultValue)) --tonumber(oneLeftServer.status)
    oneLeftWord.nLevel = tonumber(Spaceprotocol.getJsonString(pJson,"level",strDefaultValue)) --tonumber(oneLeftServer.level)
    oneLeftWord.nnSendTime = tonumber(Spaceprotocol.getJsonString(pJson,"create_time",strDefaultValue)) --tonumber(oneLeftServer.create_time)
    oneLeftWord.nShapeId = tonumber(Spaceprotocol.getJsonString(pJson,"avatar",strDefaultValue)) --tonumber(oneLeftServer.avatar)
    oneLeftWord.nItemId = tonumber(Spaceprotocol.getJsonString(pJson,"gift_id",strDefaultValue)) --tonumber(oneLeftServer.gift_id)
    oneLeftWord.nItemNum = tonumber(Spaceprotocol.getJsonString(pJson,"gift_count",strDefaultValue)) --tonumber(oneLeftServer.gift_count)
    oneLeftWord.nToBbsId = tonumber(Spaceprotocol.getJsonString(pJson,"reply_id",strDefaultValue)) --tonumber(oneLeftServer.reply_id)
    oneLeftWord.nToRoleId =  tonumber(Spaceprotocol.getJsonString(pJson,"reply_roleid",strDefaultValue)) --tonumber(oneLeftServer.reply_roleid)

     if oneLeftWord.nShapeId then
        local createRoleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(oneLeftWord.nShapeId)
        if createRoleTable then
            oneLeftWord.nShapeId = createRoleTable.model
        end
    end

    Spaceprotocol.toCorrectBbsData(oneLeftWord)
end


function Spaceprotocol.readLeftWord(oneLeftWord,oneLeftServer)
--[[
    oneLeftWord.nBbsId = tonumber(oneLeftServer.bbs_id)
    oneLeftWord.nnRoleId = tonumber(oneLeftServer.roleid)
    oneLeftWord.nStatus = tonumber(oneLeftServer.status)
    oneLeftWord.strContent = oneLeftServer.content
    oneLeftWord.strUserName = oneLeftServer.name
    oneLeftWord.nLevel = tonumber(oneLeftServer.level)
    oneLeftWord.nnSendTime = tonumber(oneLeftServer.create_time)
    oneLeftWord.nShapeId = tonumber(oneLeftServer.avatar)
    oneLeftWord.nItemId = tonumber(oneLeftServer.gift_id)
    oneLeftWord.nItemNum = tonumber(oneLeftServer.gift_count)

    oneLeftWord.nToBbsId = tonumber(oneLeftServer.reply_id)
    oneLeftWord.nToRoleId = tonumber(oneLeftServer.reply_roleid)
    oneLeftWord.strToRoleName = oneLeftServer.reply_name

     if oneLeftWord.nShapeId then
        local createRoleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(oneLeftWord.nShapeId)
        if createRoleTable then
            oneLeftWord.nShapeId = createRoleTable.model
        end
    end
    Spaceprotocol.toCorrectBbsData(oneLeftWord)
    --]]
end

function Spaceprotocol.toCorrectBbsData(oneLeftWord)
    
    if not oneLeftWord.nBbsId then
        oneLeftWord.nBbsId = 0
    end
    if not oneLeftWord.nnRoleId then
        oneLeftWord.nnRoleId = 0
    end
    if not oneLeftWord.nStatus then
        oneLeftWord.nStatus = 0
    end
    if not oneLeftWord.strContent then
        oneLeftWord.strContent = ""
    end
    if not oneLeftWord.strUserName then
        oneLeftWord.strUserName = ""
    end
    if not oneLeftWord.nLevel then
        oneLeftWord.nLevel = 0
    end

    if not oneLeftWord.nnSendTime then
        oneLeftWord.nnSendTime = 0
    end
    if not oneLeftWord.nShapeId then
        oneLeftWord.nShapeId = 0
    end
    if not oneLeftWord.nItemId then
        oneLeftWord.nItemId = 0
    end

    if not oneLeftWord.nToBbsId then
        oneLeftWord.nToBbsId = 0
    end

    if not oneLeftWord.nToRoleId then
        oneLeftWord.nToRoleId = 0
    end

    if not oneLeftWord.strToRoleName then
        oneLeftWord.strToRoleName = 0
    end

end

--[[
{"errno":"","message":"","data":[{"bbs_popularity_id":"1","roleid":"1","to_roleid":"1","status":"0",
"create_time":"1459862489","name":"\u6708\u4eae","avatar":"0","level":"0"}]}

--]]

function Spaceprotocol.readOnePopu(onePopularity,pJson_onePopularity)
    if not pJson_onePopularity then
        return
    end
    onePopularity.strUserName = gGetSpaceManager():SpaceJson_getString(pJson_onePopularity,"name","")

    local strDefaultValue = "0"
    local pJson = pJson_onePopularity
    --oneLeftWord.nBbsId = tonumber(Spaceprotocol.getJsonString(pJson,"bbs_id",strDefaultValue))

    onePopularity.nPopuId =tonumber(Spaceprotocol.getJsonString(pJson,"bbs_popularity_id",strDefaultValue)) -- tonumber(onePopularityServer.bbs_popularity_id)
    onePopularity.nnRoleId = tonumber(Spaceprotocol.getJsonString(pJson,"roleid",strDefaultValue)) --tonumber(onePopularityServer.roleid)
    --onePopularity.strUserName = tonumber(Spaceprotocol.getJsonString(pJson,"roleid",strDefaultValue)) --onePopularityServer.name
    onePopularity.nShapeId = tonumber(Spaceprotocol.getJsonString(pJson,"avatar",strDefaultValue)) -- tonumber(onePopularityServer.avatar)
    onePopularity.nLevel = tonumber(Spaceprotocol.getJsonString(pJson,"level",strDefaultValue))  --tonumber(onePopularityServer.level)

    Spaceprotocol.toCorrectPopu(onePopularity)

end

function Spaceprotocol.readPopu(onePopularity,onePopularityServer)
    onePopularity.nPopuId = tonumber(onePopularityServer.bbs_popularity_id)
    onePopularity.nnRoleId = tonumber(onePopularityServer.roleid)
    onePopularity.strUserName = onePopularityServer.name
    onePopularity.nShapeId = tonumber(onePopularityServer.avatar)
    onePopularity.nLevel = tonumber(onePopularityServer.level)

    Spaceprotocol.toCorrectPopu(onePopularity)
end

function Spaceprotocol.toCorrectPopu(onePopularity)
    if not onePopularity.nPopuId then
        onePopularity.nPopuId = 0
    end
    if not onePopularity.nnRoleId then
        onePopularity.nnRoleId = 0
    end
    if not onePopularity.strUserName then
        onePopularity.strUserName = ""
    end
    if not onePopularity.nShapeId then
        onePopularity.nShapeId = 0
    end
    if not onePopularity.nLevel then
        onePopularity.nLevel = 0
    end

end





--11523	暂无工会
--11524	暂无称号


function Spaceprotocol.srequestspaceroleinfo_clickRoleName(protocol)
    local roleData = protocol.friendinfobean

    local nnRoleId = roleData.roleid
    local nModelId = getSpaceManager():toCorrectModelId(roleData.shape)
    local nJobId = roleData.school
    local strUserName = roleData.name
    local nLevel = roleData.rolelevel

    --roleSpaceInfoData.strRoleTitle = strRoleTitle
    --roleSpaceInfoData.mapComponents = protocol.components
    local nCamp = roleData.camp
    local strFactionName = roleData.factionname
    local nFactionId = roleData.factionid

    require("logic.contactroledlg")
    local dlg =  ContactRoleDialog.getInstanceAndShow()
    if not dlg then
        return
    end
	local roleHeadID = 0
	local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nModelId)
	if shapeConf.id ~= -1 then
		roleHeadID = shapeConf.littleheadID
	end
	dlg:SetCharacter(nnRoleId, strUserName, nLevel, nCamp, roleHeadID, nJobId, nFactionId, strFactionName)	

end

--------------------------------------------
function Spaceprotocol.srequestspaceroleinfo_process(protocol)

    --self.reqtype = 0
	--self.components = {}
    local Spacemanager = require("logic.space.spacemanager")
    local nReqType = Spacemanager.eReqRoleInfoType.spaceInfo
    if protocol.reqtype ==Spacemanager.eReqRoleInfoType.clickRoleName then
        Spaceprotocol.srequestspaceroleinfo_clickRoleName(protocol)
        return
    end

    local nTitleId = protocol.title
    local roleData = protocol.friendinfobean

    local strRoleTitle = ""
    local titleRecord = BeanConfigManager.getInstance():GetTableByName("title.ctitleconfig"):getRecorder(nTitleId)
    if titleRecord then
        strRoleTitle = titleRecord.titlename
    else    
        strRoleTitle = require("utils.mhsdutils").get_resstring(11524)
    end

    local strFactionName = ""
    if roleData.factionid<=0 then
        strFactionName = require("utils.mhsdutils").get_resstring(11523)
    else
        strFactionName = roleData.factionname
    end

    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData

    roleSpaceInfoData.nnRoleId = roleData.roleid
    roleSpaceInfoData.nModelId = spManager:toCorrectModelId(roleData.shape)
    roleSpaceInfoData.nJobId = roleData.school
    roleSpaceInfoData.strUserName = roleData.name
    roleSpaceInfoData.nLevel = roleData.rolelevel
    roleSpaceInfoData.strRoleTitle = strRoleTitle
    roleSpaceInfoData.mapComponents = protocol.components

    roleSpaceInfoData.strFactionName = strFactionName

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.refreshRoleInfoGs)
end


function Spaceprotocol.sgetspaceinfo_process(protocol)
    local nGiftNum = protocol.giftnum
    local nPopuNum = protocol.popularity
    local nRecGift = protocol.revnum
    if nGiftNum<=0 then
        nGiftNum = 0
    end
    if nPopuNum<=0 then
        nPopuNum=0
    end
    if nRecGift<=0 then
        nRecGift=0 
    end

    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    roleSpaceInfoData.nGiftNum = nGiftNum
    roleSpaceInfoData.nPopuNum = nPopuNum
    roleSpaceInfoData.nRecGift = nRecGift

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.refreshPopuInfo)

end

function Spaceprotocol.ssetspacegift_process(protocol)
    if protocol.result ~= 0 then 
        return
    end

    local p = require "protodef.fire.pb.friends.cgetspaceinfo":new()
	p.roleid = getSpaceManager():getCurRoleId()
	require "manager.luaprotocolmanager":send(p)
end


function Spaceprotocol.sstepspace_process(protocol)
    if protocol.result ~= 0 then 
        return
    end

    local p = require "protodef.fire.pb.friends.cgetspaceinfo":new()
	p.roleid = getSpaceManager():getCurRoleId()
	require "manager.luaprotocolmanager":send(p)
end


function Spaceprotocol.sgetroleslevel_process(protocol)
    local spManager = getSpaceManager()
    local nType = protocol.gettype
    local mapRoleLevel = protocol.roleslevel
    spManager:recGetRoleLevel(mapRoleLevel,nType)
end


function Spaceprotocol.sxshspace_process(protocol)
    if protocol.result == 0 then  --success
        local p = require "protodef.fire.pb.friends.cgetxshspaceinfo":new()
	    require "manager.luaprotocolmanager":send(p)
    end

end

function Spaceprotocol.sxshgivegift_process(protocol)
     local nPage = 0
     local strRoleId = getSpaceManager().strNpcSpaceRoleId
     require("logic.space.spacepro.spaceprotocol_npcLiuyanList").request(strRoleId,nPage)
end


function Spaceprotocol.sgetxshspaceinfo_process(protocol)
    
    local spManager = getSpaceManager()
    spManager.nGiftNum = protocol.giftnum
    spManager.nRenqiNum = protocol.popularity
    spManager.nRecGiftNum = protocol.revnum

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.refreshNpcSpaceInfo)

end


return Spaceprotocol
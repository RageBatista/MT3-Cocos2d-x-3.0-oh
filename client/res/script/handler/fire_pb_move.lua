local shiderole = require "protodef.fire.pb.move.shiderole"
function shiderole:process()
	if not GetMainCharacter() then
        return
    end
    local bHide = false
    if self.hide==1 then
        bHide = true
    end
    GetMainCharacter():HideRole(bHide)
end

local ssetrolelocation = require "protodef.fire.pb.move.ssetrolelocation"
function ssetrolelocation:process()
    if not gGetScene() then
        return
    end
    if not GetMainCharacter() then
        return
    end
	local pChar = gGetScene():FindCharacterByID(self.roleid);
    if not pChar then
        return
    end
    local bhighlevel = false

    if self.locz==1 then
        bhighlevel = true
    end
    local position = self.position
	if pChar == GetMainCharacter() then
		GetMainCharacter():InitPosition(Nuclear.NuclearPoint(position.x,position.y) , bhighlevel);
	else
		pChar:InitPosition(Nuclear.NuclearPoint(position.x,position.y) , bhighlevel);
	end	
end

local srelocaterolepos = require "protodef.fire.pb.move.srelocaterolepos"
function srelocaterolepos:process()
    if not GetMainCharacter() then
		return;
	end
	GetMainCharacter():RelocateMainRolePos();
end


local srolemove = require "protodef.fire.pb.move.srolemove"
function srolemove:process()
    if not gGetScene() or not GetMainCharacter() then
		return;
	end
	local pchar = gGetScene():FindCharacterByID(self.roleid);
    if not pchar then
        return
    end
	local destpos =	Nuclear.NuclearPoint(self.destpos.x,self.destpos.y);
	if GetMainCharacter() == pchar then
		if  GetBattleManager():IsInBattle()==false  then
			GetMainCharacter():DrawBackByService(destpos);
			GetMainCharacter():ContinueMove();
		end
	else
		pchar:MoveTo(destpos);
	end
	
end

local snpcmoveto = require "protodef.fire.pb.move.snpcmoveto"
function snpcmoveto:process()
    if not gGetScene() then
		return;
	end
	local pNpc = gGetScene():FindNpcByID(self.npckey);
	if  not pNpc then
		return;
	end
	if( not (self.destpos.x==0 and self.destpos.y==0)) then
		if (self.speed>0 and pNpc:GetSprite()) then
			pNpc:GetSprite():SetMoveSpeed(self.speed/1000.0);
		end
		pNpc:MoveTo(Nuclear.NuclearPoint(self.destpos.x, self.destpos.y));
	end
end

local supdaterolescenestate = require "protodef.fire.pb.move.supdaterolescenestate"
function supdaterolescenestate:process()
    if not gGetScene() then
		return;
	end
	local pChar = gGetScene():FindCharacterByID(self.roleid);
    if not pChar then
        return
    end
	pChar:UpdateCharacterState(self.scenestate);
end

local supdatenpcscenestate = require "protodef.fire.pb.move.supdatenpcscenestate"
function supdatenpcscenestate:process()
    if not gGetScene() then
		return;
	end
	local npc = gGetScene():FindNpcByID(self.npckey);
    if not npc then
        return
    end
	npc:UpdateNpcState(self.scenestate);
end


local stransfromshape = require "protodef.fire.pb.move.stransfromshape"
function stransfromshape:process()
    if not gGetScene() or  not gGetDataManager() then
	
		return;
	end
	local pChar=gGetScene():FindCharacterByID(self.playerid);
	if pChar then
	
        pChar:ChangeSpriteModel(self.shape);
	end
end

--[[
local sremovepickupscreen = require "protodef.fire.pb.move.sremovepickupscreen"
function sremovepickupscreen:process()
    if not gGetScene() then
		return;
	end
    for k,nnObjKeyId in pairs(self.pickupids) do 
		gGetScene():RemoveSceneObjectByID(eSceneObjItem,nnObjKeyId);
	end
end
 --]]

local ssetroleteaminfo = require "protodef.fire.pb.move.ssetroleteaminfo"
function ssetroleteaminfo:process()
    if not gGetScene() then
		return;
	end
	local  pChar = gGetScene():FindCharacterByID(self.roleid);
    local pOtherChat = gGetScene():FindCharacterByTeamIDandIndex(self.teamid,self.teamindex);
	if (pOtherChat and pOtherChat:GetID() ~= self.roleid) then
		pOtherChat:SetTeamInfoOutOfDate(true);	
	end
	if (pChar) then
		pChar:SetTeamInfo(self.teamid,self.teamindex,self.teamstate);
		pChar:SetTeamInfoOutOfDate(false);
        if GetIsInFamilyFight() then
            if self.teamid ~= 0 and self.teamindex == 1 then
                pChar:SetTeamNumVisible(true)
                pChar:SetTeamNum(tostring(self.teamnormalnum) .. "/5")
                pChar:SetTeamNumHeight(200,250)
            else
                pChar:SetTeamNumVisible(false)
            end
        else
                pChar:SetTeamNumVisible(false)
        end
        -- 特殊地图隐藏其他队员
        local nMapId = gGetScene():GetMapID()
        local mapTable = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
        if mapTable and mapTable.isMemVisible == 1 then
            -- 1.在队伍中且是队长 2.离队显示 3.在队伍中暂离--显示
            if ( self.teamid ~= 0  and self.teamindex == 1 and GetTeamManager():GetTeamID() ~= self.teamid) or self.teamid == 0 or (self.teamid ~= 0 and GetTeamManager():GetTeamID() ~= self.teamid and self.teamstate == eTeamMemberAbsent)then
                pChar:SetVisible(true)
            -- 在队伍中其他队员 隐藏
            elseif self.teamid ~= 0 and self.teamindex ~= 1 and GetTeamManager():GetTeamID() ~= self.teamid then
                pChar:SetVisible(false)
            end
        end
	end
end

local sremoveuserscreen = require "protodef.fire.pb.move.sremoveuserscreen"
function sremoveuserscreen:process()
    if not gGetScene() then
		return;
	end
    for k,nnRoleId in pairs(self.roleids) do 
        local pet = gGetScene():FindPetByMasterID(nnRoleId);
        if(pet and nnRoleId ~= gGetDataManager():GetMainCharacterID()) then
            gGetScene():RemovePetByMasterID(nnRoleId);
        end
        gGetScene():RemoveCharacterByID(nnRoleId);
    end

     for k,nnNpcKey in pairs(self.npcids) do 
        gGetScene():RemoveNpcByID(nnNpcKey);
    end	
end

local sroleturn = require "protodef.fire.pb.move.sroleturn"
function sroleturn:process()
    if not gGetScene() then
		return;
	end
	local pchar = gGetScene():FindCharacterByID(self.roleid);
	if pchar then
		pchar:SetDirection(self.direction);
	end
end

local sremovepickupscreen = require "protodef.fire.pb.move.sremovepickupscreen"
function sremovepickupscreen:process()
    if not gGetScene() then
		return;
	end
    for k,nnKey in pairs(self.ickupids) do 
        gGetScene():RemoveSceneObjectByID(eSceneObjItem,nnKey);
    end
end

-------------------------------------yangbin  2016/4/1  c++协议转lua-------------------------------------

local m = require "protodef.fire.pb.move.srolecomponentschange"
function m:process()
	if gGetScene() then
		local compmentsMap = std.map_char_int_()
		for k,v in pairs (self.components) do
			compmentsMap[k] = v
		end

		-- 0表示角色
		if self.spritetype == 0 then
			local pCharacter = gGetScene():FindCharacterByID(self.roleid)
			if pCharacter then
				local isMainCharacter = (pCharacter == GetMainCharacter())
				local beforeWeapon = 0
				local beforeHorse = 0
				if isMainCharacter and pCharacter.GetSpriteComponent then
					beforeWeapon = tonumber(pCharacter:GetSpriteComponent(eSprite_Weapon)) or 0
					beforeHorse = tonumber(pCharacter:GetSpriteComponent(eSprite_Horse)) or 0
				end
				local incomingWeapon = tonumber(self.components[eSprite_Weapon]) or 0
				local incomingHorse = tonumber(self.components[eSprite_Horse]) or 0
				local incomingFashion = tonumber(self.components[eSprite_Fashion]) or 0
				if isMainCharacter then
					LogInfo(string.format("srolecomponentschange before roleid=%s inWeapon=%s inHorse=%s inFashion=%s curWeapon=%s curHorse=%s",
						tostring(self.roleid), tostring(incomingWeapon), tostring(incomingHorse), tostring(incomingFashion), tostring(beforeWeapon), tostring(beforeHorse)))

					local function resolveEquipWeaponComponent()
							local roleItemManager = require("logic.item.roleitemmanager").getInstance()
							if not roleItemManager or not roleItemManager.GetCurrentEquip then
								return 0
							end
							local weaponEquip = roleItemManager:GetCurrentEquip(fire.pb.item.BagTypes.EQUIP, eEquipType_ARMS)
							if not weaponEquip or not weaponEquip.GetObjectID then
								return 0
							end
							local equipItemId = tonumber(weaponEquip:GetObjectID()) or 0
							if equipItemId <= 0 then
								return 0
							end

							-- Prefer direct equip item id when it is already a large weapon component id.
							if equipItemId >= 1000000 then
								return equipItemId
							end

							local isPointCardServer = (type(IsPointCardServer) == "function" and IsPointCardServer()) or false
							local equipEffectCfg = nil
							if isPointCardServer then
								local equipEffectTable = BeanConfigManager.getInstance():GetTableByName("item.cequipeffect")
								if equipEffectTable then
									equipEffectCfg = equipEffectTable:getRecorder(equipItemId)
								end
							else
								if GameTable and GameTable.item and GameTable.item.GetCEquipEffectTableInstance then
									local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance()
									if equipEffectTable then
										equipEffectCfg = equipEffectTable:getRecorder(equipItemId)
									end
								end
							end
							if equipEffectCfg and equipEffectCfg.id ~= -1 then
								return tonumber(equipEffectCfg.weaponid) or 0
							end

							-- Fallback to equip item id when mapping is unavailable.
							return equipItemId
						end

						local equipWeapon = resolveEquipWeaponComponent()
					if equipWeapon > 0 and incomingWeapon ~= equipWeapon then
						incomingWeapon = equipWeapon
						compmentsMap[eSprite_Weapon] = equipWeapon
						self.components[eSprite_Weapon] = equipWeapon
						LogInfo(string.format("srolecomponentschange override fashion weapon incoming=%s equip=%s",
							tostring(tonumber(self.components[eSprite_Weapon]) or 0), tostring(equipWeapon)))
					end
				end

				pCharacter:UpdateSpriteComponent(compmentsMap)
				if isMainCharacter and pCharacter.GetSpriteComponent then
					local afterWeapon = tonumber(pCharacter:GetSpriteComponent(eSprite_Weapon)) or 0
					local afterHorse = tonumber(pCharacter:GetSpriteComponent(eSprite_Horse)) or 0
					LogInfo(string.format("srolecomponentschange after roleid=%s weapon=%s horse=%s",
						tostring(self.roleid), tostring(afterWeapon), tostring(afterHorse)))
				end

				if isMainCharacter then
					require "logic.item.mainpackdlg"
					if CMainPackDlg:getInstanceOrNot() then
						CMainPackDlg:getInstanceOrNot():UpdataModel()
					end
				else
					pCharacter:CheckEquipEffect(self.components[eSprite_Effect] or 0)
				end
				pCharacter:UpdateSpeed()
				GetTeamManager():UpdateMemberSpeed()
			end
			-- 1表示是npc
		elseif self.spritetype == 1 then
			local pNpc = gGetScene():FindNpcByID(self.roleid)
			if pNpc then
				pNpc:UpdateSpriteComponent(compmentsMap)
			end
		end
	end
end

local m = require "protodef.fire.pb.move.saddpickupscreen"
function m:process()
	if not gGetScene() then
		return
	end

	for k, v in pairs(self.pickuplist) do
		gGetScene():AddSceneDroptItem(v)
	end
end

local m = require "protodef.fire.pb.move.sroleenterscene"
function m:process()
	if not gGetScene() or not GetMainCharacter() then
		return
	end

	-- 剧情中，不重置地图
	if gGetSceneMovieManager() and gGetSceneMovieManager():isOnSceneMovie() and not gGetSceneMovieManager():IsReturningScene() then
		return
	end

    -- 如果已经在场景中，不重置地图
    if gGetScene():GetMapSceneID() == self.sceneid then
        local nowPos = GetMainCharacter():GetLogicLocation()
        -- 玩家坐标与目标坐标相同，则不处理
        if nowPos.x == self.destpos.x and nowPos.y == self.destpos.y and not gGetGameApplication():isReconnecting() then
            gGetGameApplication():EndDrawServantIntro()
		    return
        -- 玩家坐标与目标坐标不同，则瞬移
        else
            local savedTime = gGetScene():GetDreamHideSceneTime()
            gGetScene():SetDreamHideSceneTime(1500)
            gGetScene():SetDreamStatus(2)
            gGetScene():SetDreamStatus(1)
            gGetScene():SetDreamHideSceneTime(savedTime)
        end
    end

	if gGetGameApplication():isReconnecting() and GetBattleManager() and GetBattleManager():IsInBattle() then
		GetBattleManager():EndBattleScene()
	end

	GetBattleReplayManager():Clear()

	gGetGameApplication():SetWaitForEnterWorldState(false)

	gGetScene():ChangeMap(self.sceneid, Nuclear.NuclearPoint(self.destpos.x, self.destpos.y), self.ownername, self.changetype, self.destz == 1)

    local datamanager = require "logic.family.familyfightmanager"
    if datamanager then
        datamanager:OnMapChanged()
    end
    
    --只有在应用宝平台下发送
    if MT3.ChannelManager:IsAndroid() == 1 then
         if Config.IsYingYongBao() then
            local openid = gGetLoginManager():GetOpenId()
            local openkey = gGetLoginManager():GetOpenKey()
            local paytoken = gGetLoginManager():GetPayToken()
            local pf = gGetLoginManager():GetPf()
            local pfkey = gGetLoginManager():GetPfKey()
            local zoneid = gGetLoginManager():GetZoneId()
            local platformname = gGetLoginManager():GetPlatformName()

            local p = require("protodef.fire.pb.fushi.cupyingyongbaoinfo"):new()
		    p.openid = openid
	        p.openkey = openkey 
	        p.paytoken = paytoken 
	        p.pf = pf 
	        p.pfkey = pfkey
	        p.zoneid = zoneid
	        p.platformname = platformname
		    LuaProtocolManager.getInstance():send(p)
         end
    end

end

local m = require "protodef.fire.pb.school.sshouxishape"
function m:process()
	if not gGetScene() then
		return
	end

	local compmentsMap = std.map_char_int_()
	for k, v in pairs(self.components) do
		compmentsMap[k] = v
	end

	local pNpc = gGetScene():FindNpcByID(self.shouxikey)
	if pNpc then
		pNpc:SetShouXiNewShapeAndName(self.shape, self.name, compmentsMap)
	end
end

local m = require "protodef.fire.pb.move.sadduserscreen"
function m:process()
	if not gGetScene() then
		return
	end
	for i = 1, #self.rolelist do
		local iter = self.rolelist[i]
		local baseOctets = require("protodef.rpcgen.fire.pb.move.rolebasicoctets"):new()
		local octetSt = FireNet.Marshal.OctetsStream(iter.rolebasicoctets)
		baseOctets:unmarshal(octetSt)

		local data = stCharacterData()
		data.dwID = baseOctets.roleid
		data.strName = baseOctets.rolename
		data.ptPos = Nuclear.NuclearPoint(iter.pos.x, iter.pos.y)
		data.dir = bit.brshift(bit.band(baseOctets.dirandschool, 240), 4)
		data.eSchool =(bit.band(baseOctets.dirandschool, 15) + 10)
		data.level = baseOctets.level

        local teamnum = 0

		if baseOctets.shape <= 17 then
			data.shape = 1010100 + baseOctets.shape
		elseif baseOctets.shape < 300 then
			data.shape = 2010100 + baseOctets.shape % 100
		else
			data.shape = baseOctets.shape
		end

		data.camp = baseOctets.camp
		local mapPetData = stMapPetData()
		mapPetData.roleid = baseOctets.roleid
		mapPetData.showpetid = 0

		for k, v in pairs(baseOctets.datas) do
			local stream = FireNet.Marshal.OctetsStream(v)

			if k == baseOctets.SHOW_PET then
				local petinfo = require("protodef.rpcgen.fire.pb.move.showpetoctets"):new()
				petinfo:unmarshal(stream)
				mapPetData.showpetid = petinfo.showpetid
				mapPetData.showpetname = petinfo.showpetname
				mapPetData.showpetcolour = ePetColour(bit.brshift(petinfo.petcoloursndsize, 4))
				mapPetData.level = bit.band(petinfo.petcoloursndsize, 15)
				mapPetData.showskilleffect = petinfo.showskilleffect

			elseif k == baseOctets.TEAM_INFO then
				local teaminfo = require("protodef.rpcgen.fire.pb.move.teaminfooctets"):new()
				teaminfo:unmarshal(stream)
				data.teamID = teaminfo.teamid
				data.teamindex = math.floor(bit.brshift(bit.band(teaminfo.teamindexstate, 240), 4))
				data.teamstate = math.floor(bit.band(teaminfo.teamindexstate, 15))
                teamnum =  bit.band(teaminfo.normalnum, 15)
			elseif k == baseOctets.TITLE_ID then
				local titleid = 0
				titleid = stream:unmarshal_int32()
				data.TitleID = math.floor(titleid)
			elseif k == baseOctets.TITLE_NAME then

				data.strTitle = gGetScene():GetTitleName(stream)

			elseif k == baseOctets.STALL_NAME then
				-- local oct = FireNet.Octets()
				-- stream:marshal_octets(oct)
				-- std::wstring stallname;
				-- FireNet::remove_const(stallname).assign((wchar_t*)oct.begin(),(wchar_t*)oct.end());
			elseif k == baseOctets.SCENE_STATE then
				local state = 0
				state = stream:unmarshal_int32()
				data.characterstate = state;
			elseif k == baseOctets.ROLE_ACTUALLY_SHAPE then
				local actuallyshape = 0
				actuallyshape = stream:unmarshal_int32()
				data.actuallyshape = actuallyshape
			elseif k == baseOctets.PLAYING_ACTION then
				local action = 0
				action = stream:unmarshal_char()
				data.actiondefault = action
			elseif k == baseOctets.FOOT_LOGO_ID then
				local footprintid = 0
				footprintid = stream:unmarshal_int32()
				data.footprint = footprintid
			elseif k == baseOctets.CRUISE then
				local automovepathid = 0
				automovepathid = stream:unmarshal_int32()
				data.automovepathid = automovepathid
			elseif k == baseOctets.CRUISE2 then
				local automovepathid2 = 0
				automovepathid2 = stream:unmarshal_int32()
				data.automovepathid2 = automovepathid2
			elseif k == baseOctets.CRUISE3 then
				local automovepathid3 = 0
				automovepathid3 = stream:unmarshal_int32()
				data.automovepathid3 = automovepathid3
			elseif k == baseOctets.EFFECT_EQUIP then
				local equipEffect = 0
				equipEffect = stream:unmarshal_int32()
				data.equipEffect = equipEffect
			end
		end

		-- 寻路相关
		if #iter.poses > 0 then
			-- 代表普通寻路
			if #iter.poses == 1 then
				data.ptTargetPos = Nuclear.NuclearPoint(iter.poses[1].x, iter.poses[1].y)
			end
		else
			data.ptTargetPos = data.ptPos
		end

		-- 在地图的第几层，false为第一层，true为第二层
		data.bhighlevel = iter.posz == 1
        if baseOctets.components[eSprite_Horse] then
            data.weaponbaseid = baseOctets.components[eSprite_Horse]
        end
		local pCharacter = gGetScene():AddSceneCharacter(data)
        -- 特殊地图隐藏其他队员
        local nMapId = gGetScene():GetMapID()
        local mapTable = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
        if mapTable and mapTable.isMemVisible == 1 then
             if data.teamindex ~= 1 and data.teamID ~= 0 and GetTeamManager():GetTeamID() ~= 0 and data.teamID ~= GetTeamManager():GetTeamID() then
                pCharacter:SetVisible(false)
            end
        end


        --刷新一下身后队员的跟随状态
        if data.teamID ~= 0 then
            local nextTeamMember = gGetScene():FindCharacterByTeamIDandIndex(data.teamID, data.teamindex+1)
            if nextTeamMember and not nextTeamMember:IsOnTeamFollow() then
                nextTeamMember:SetTeamFollow()
            end
        end
       if GetIsInFamilyFight()then
            if pCharacter then
                  if data.teamID ~= 0 and data.teamindex == 1 then
                      pCharacter:SetTeamNumVisible(true)
                      pCharacter:SetTeamNum(tostring(teamnum) .. "/5")
                      pCharacter:SetTeamNumHeight(200,250)
                  else
                      pCharacter:SetTeamNumVisible(false)
                  end
            end
       else
            if pCharacter then
                 pCharacter:SetTeamNumVisible(false)
            end
       end

		if pCharacter then
			-- 变装相关
			local compmentsMap = std.map_char_int_()
			for k, v in pairs(baseOctets.components) do
				compmentsMap[k] = v
			end

			if data.automovepathid > 0 then
				if pCharacter ~= GetMainCharacter() then
					local RideName = pCharacter:GetAutoMoveRideName(data.automovepathid, data.automovepathid2)
                    local nRideName = tonumber(RideName) or 0
                    --pCharacter:SetSpriteComponent(eSprite_Horse, nRideName)
                    compmentsMap[eSprite_Horse] = nRideName
					local MoveSpeed = pCharacter:GetAutoMoveSpeed(data.automovepathid, data.automovepathid2)				
					pCharacter:SetMoveSpeed(MoveSpeed)
					pCharacter:SetAutoMove(1)
					if pCharacter:GetSprite() ~= nil then
						local OffsetYStep = pCharacter:GetOffsetYStep(data.automovepathid, data.automovepathid2, data.automovepathid3)
						local OffsetYCur = pCharacter:GetOffsetYCur(data.automovepathid, data.automovepathid2, data.automovepathid3)
						local OffsetYNext = pCharacter:GetOffsetYNext(data.automovepathid, data.automovepathid2, data.automovepathid3)
						pCharacter:SetFlyOffsetYStep(OffsetYStep)
						pCharacter:SetFlyOffsetYCur(OffsetYCur)
						pCharacter:SetFlyOffsetYTgt(OffsetYNext)
					end
				end
			else
				pCharacter:SetMoveSpeed(140 / 1000)
				pCharacter:SetAutoMove(0)
				--if pCharacter ~= GetMainCharacter() then
					if pCharacter:GetSprite() ~= nil then
						pCharacter:SetFlyOffsetYStep(0)
						pCharacter:SetFlyOffsetYCur(0)
						pCharacter:SetFlyOffsetYTgt(0)
					end
				--end
				pCharacter:UpdateSpeed()
				GetTeamManager():UpdateMemberSpeed()
			end

            pCharacter:UpdateSpriteComponent(compmentsMap)

		end
		if mapPetData.showpetid ~= 0 then
			gGetScene():AddScenePet(mapPetData)
		end
	end
	if GetMainCharacter() then
		GetMainCharacter():HandleEnterOrLeavePVPArea()
		ShowHide.EnterLeavePVPArea()
	end

	for i = 1, #self.npclist do
		local iter = self.npclist[i]
		local data = stNpcData()
		data.NpcID = iter.npckey
		data.NpcBaseID = iter.id
		data.strName = iter.name
		data.ptPos = Nuclear.NuclearPoint(iter.pos.x, iter.pos.y)
		data.destPos = Nuclear.NuclearPoint(iter.destpos.x, iter.destpos.y)
		data.moveSpeed = iter.speed
		data.dir = iter.dir
		data.ShapeID = iter.shape
		data.bHighlevel = iter.posz == 1
        data.scenestate = iter.scenestate

		local bXinMo = false
		local npcTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(data.NpcBaseID)
		if npcTable then
			if npcTable.npctype == 27 then
				-- 27 xinmo lei xing
				bXinMo = true
			end
		end
		if bXinMo then
			gGetScene():AddMainCharacterNpc(iter)
		else
			local pNpc = gGetScene():AddSceneNpc(data)
			if pNpc then
				local compmentsMap = std.map_char_int_()
				for k, v in pairs(iter.components) do
					compmentsMap[k] = v
				end
				pNpc:UpdateSpriteComponent(compmentsMap)
                pNpc:UpdateNpcState(iter.scenestate);
			end
		end
	end
	if GetMainCharacter() then
		GetMainCharacter():CheckGoto()
	end
end

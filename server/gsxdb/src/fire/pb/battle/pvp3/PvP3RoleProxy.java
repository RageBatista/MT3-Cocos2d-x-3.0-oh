package fire.pb.battle.pvp3;

import java.util.ArrayList;
import java.util.List;

import mkdb.Transaction;
import fire.pb.PAddExpProc;
import fire.pb.activity.award.RewardMgr;
import fire.pb.battle.pvp.PvPHelper;
import fire.pb.mission.activelist.RoleLiveness;
import fire.pb.talk.MessageMgr;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.util.StringConstant;

/**
 * 3v3角色代理
 * @作者XGM
 */
public class PvP3RoleProxy {

	/**
	 * 获取PvP角色的代理
	 * @参数角色Id
	 * @参数只读
	 * @返回
	 */
	public static PvP3RoleProxy getPvP3RoleProxy(long roleId, boolean readonly) {

		xbean.PvP3Role xpvprole = null;
		if(readonly) {
			xpvprole = xtable.Pvp3roles.select(roleId);
		} else {
			xpvprole = xtable.Pvp3roles.get(roleId);
		}

		if(xpvprole == null) {
			if (readonly) {
				xpvprole = xbean.Pod.newPvP3RoleData();
			} else {
				xpvprole = xbean.Pod.newPvP3Role();
				xtable.Pvp3roles.insert(roleId, xpvprole);
			}
		}
		return new PvP3RoleProxy(roleId, xpvprole, readonly);
	}

	private final long roleId;
	private xbean.PvP3Role xpvprole;
	private final boolean readonly;

	/**
	 * 构造
	 * @参数角色Id
	 * @param xpvprole
	 * @参数只读
	 */
	public PvP3RoleProxy(long roleId, xbean.PvP3Role xpvprole, boolean readonly) {
		this.roleId = roleId;
		this.xpvprole = xpvprole;
		this.readonly = readonly;
	}

	/**
	 * 清空战斗记录
	 */
	public void clearBattleInfo() {
		xpvprole.setBattlenum(0);
		xpvprole.setWinnum(0);
		xpvprole.setContinuewinnum(0);
		xpvprole.setFirstwinaward(0);
		xpvprole.setFivewinaward(0);
		xpvprole.setTenbattleaward(0);
	}

	/**
	 * 获得角色ID
	 * @返回
	 */
	public long getRoleId() {
		return roleId;
	}

	/**
	 * 获得此记录所属的赛级
	 * @返回
	 */
	public int getGrade() {
		return xpvprole.getGrade();
	}

	/**
	 * 获得积分
	 * @返回
	 */
	public int getScore() {
		return xpvprole.getScore();
	}

	/**
	 * 根据积分取得等级
	 * @返回
	 */
	public int getScoreLevel() {
		return PvPHelper.getScoreLevel(getScore());
	}

	/**
	 * 获得战斗次数
	 * @返回
	 */
	public int getBattleNum() {
		return xpvprole.getBattlenum();
	}

	/**
	 * 获得连胜次数
	 * @返回
	 */
	public int getContinueWinNum() {
		return xpvprole.getContinuewinnum();
	}

	/**
	 * 获得上次战斗结束的时间
	 * @返回
	 */
	public long getLastBattleTime() {
		return xpvprole.getLastbattletime();
	}

	/**
	 * 获得上次进入赛场时间
	 * @返回
	 */
	public long getLastEnterTime() {
		return xpvprole.getLastentertime();
	}

	/**
	 * 获得当前活动中的赛级
	 * @返回
	 */
	public int getGradeInActivity() {

		// 如果活动还在进行中就返回赛级
		if (PvP3Control.getInstance().isActivityTime(xpvprole.getLastentertime())) {
			if (xpvprole.getGrade() > 0) {
				return xpvprole.getGrade();
			}
		}
		return -1;
	}
	
	/**
	 * 响应入场
	 * @参数等级
	 */
	public void onEnter(int grade) {

		long now = System.currentTimeMillis();
		if (PvP3Control.getInstance().isActivityTime(xpvprole.getLastentertime()) == false) {
			// 清空上次活动的信息
			clearBattleInfo();
			xpvprole.setLastbattletime(0);
			xpvprole.setScore(0);
		}

		xpvprole.setGrade(grade);
		xpvprole.setLastentertime(now);
	}

	/**
	 * 增加积分
	 * @参数addValue
	 * @返回
	 */
	public int addScore(int addValue, boolean levelUp) {
		onAddScore(addValue);
		return addValue;
	}

	/**
	 * 增加积分
	 * @参数addValue
	 * @返回
	 */
	private void onAddScore(int addValue) {
		int lastScore = getScore();
		xpvprole.setScore(lastScore + addValue);
	}

	/**
	 * 战斗结束的结果处理
	 * @param isWin
	 * @参数敌人Id
	 * @参数addScore
	 * @参数比赛
	 */
	public void onBattleEnd(boolean isWin, long enemyId, int addScore, PvP3RaceProxy race) {

		if (readonly)
			throw new UnsupportedOperationException("If readonly then cant invoke 3v3 onBattleEnd");

		if (race.getXRace() == null)
			return;

		long now = System.currentTimeMillis();
		xpvprole.setLastbattletime(now);
		xpvprole.setLastentertime(now);

		if (isWin) {
			xpvprole.setWinnum(xpvprole.getWinnum() + 1);
			xpvprole.setContinuewinnum(Math.min(PvP3Helper.RACE_MAX_BATTLE_NUM, xpvprole.getContinuewinnum() + 1));
			if (xpvprole.getWinnum() == 1 && xpvprole.getFirstwinaward() == 0)
				xpvprole.setFirstwinaward(1); // 首胜
			if (xpvprole.getWinnum() == 5 && xpvprole.getFivewinaward() == 0)
				xpvprole.setFivewinaward(1); // 5胜
			//if (xpvprole.getContinuewinnum() > 0 && xpvprole.getContinuewinnum() % 8 == 0)
			//	xpvprole.setEightwinaward(1); // 8连胜
		} else {
			xpvprole.setContinuewinnum(0);
		}

		xpvprole.setBattlenum(xpvprole.getBattlenum() + 1);

		if (xpvprole.getBattlenum() == 10 && xpvprole.getTenbattleaward() == 0) {
			xpvprole.setTenbattleaward(1); // 10战
		}

		// 增加活动计数
		RoleLiveness activeRole = RoleLiveness.getRoleLiveness(roleId);
		if (activeRole != null) {
			if (fire.pb.PropConf.Cross.PVP == 0) {
				activeRole.handleActiveLivenessData(RoleLiveness.PVP3);
			} else {
				activeRole.handleActiveLivenessData(RoleLiveness.CROSS_PVP3); // 跨服PVP3
			}
		}
		// 增加成就
		fire.pb.course.CourseManager.achieveCourse(roleId, fire.pb.course.CourseType.ACTIVE_COURSE, RoleLiveness.PVP3, 0);

		// 更新积分排行榜
		String roleName = xtable.Properties.selectRolename(roleId);
		race.updateRankingList(roleId, roleName, addScore, xpvprole.getScore());
		// 更新历史榜单
		if (addScore > 0) {
			race.acceptVisit(new PvP3RankVisitor(roleId, addScore));
		}

		// 赢的重新加入队列
		if (isWin && xpvprole.getBattlenum() < PvP3Helper.RACE_MAX_BATTLE_NUM) {
			// 只有队长才能准备
			if (roleId == getTeamMemberIds(roleId).get(0)) {
				race.roleReady(roleId);
			}
		}

		// 发送刷新协议
		sendSPvP3MyInfo(isWin && race.isReady(roleId));
		//race.sendSPvP3RankingList(roleId); 排行榜需要单独请求 [4/18/2016 XGM]

		if (PvP3Control.getLogger().isInfoEnabled()) {
			PvP3Control.getLogger().info("PVP3::[PvP3RoleProxy.onBattleEnd] roleId:" + roleId
					+ " isWin:" + isWin
					+ " enemyId:" + enemyId
					+ " addScore:" + addScore
					+ " score:" + xpvprole.getScore()
					+ " continueWinNum:" + xpvprole.getContinuewinnum()
					+ " winNum:" + xpvprole.getWinnum()
					+ " battleNum:" + xpvprole.getBattlenum());
		}
	}

	/**
	 * 发送自己的信息
	 * @参数准备好
	 */
	public void sendSPvP3MyInfo(boolean ready){

		SPvP3MyInfo snd = new SPvP3MyInfo();
		snd.firstwin = (byte)xpvprole.getFirstwinaward();
		snd.tenfight = (byte)xpvprole.getTenbattleaward();
		snd.eightwin = (byte)xpvprole.getFivewinaward();
		snd.battlenum = (byte)xpvprole.getBattlenum();
		snd.winnum = (byte)xpvprole.getWinnum();
		snd.combowinnum = (byte)xpvprole.getContinuewinnum();
		snd.score = xpvprole.getScore();
		snd.ready = ready ? (byte)1 : (byte)0;

		if (Transaction.current() != null) {
			mkdb.Procedure.psendWhileCommit(roleId, snd);
		} else {
			gnet.link.Onlines.getInstance().send(roleId, snd);
		}
	}

	/**
	 * 打开箱子
	 * @参数框类型
	 * @返回
	 */
	public boolean openBox(int boxType) {

		switch (boxType) {
		case 1:// 首胜
			if (xpvprole.getFirstwinaward() != 1) {
				if (xpvprole.getFirstwinaward() == 0)
					MessageMgr.sendMsgNotify(roleId, 160342, MessageMgr.getStringList(StringConstant.ID2String("首胜奖励", 304)));
				else
					MessageMgr.sendMsgNotify(roleId, 172000, MessageMgr.getStringList(StringConstant.ID2String("首胜奖励", 304)));
				return false;
			}

			// 发首胜奖励
			RewardMgr.getInstance().distributeAllAward(roleId, PvP3Helper.FIRST_WIN_AWARD_ID, null,
					fire.log.enums.YYLoggerTuJingEnum.tujing_Value_PVP3, 0, PAddExpProc.OTHER_QUEST, "首胜奖励");

			xpvprole.setFirstwinaward(2);
			mkdb.Procedure.psendWhileCommit(roleId, new SPvP3OpenBoxState((byte) 1, (byte) 2));

			// 记录日志
			if (PvP3Control.getLogger().isInfoEnabled()) {
				PvP3Control.getLogger().info("PVP3::[PvP3RoleProxy.openBox] roleId:" + roleId
						+ " boxType:" + boxType
						+ " firstWinAwardId:" + PvP3Helper.FIRST_WIN_AWARD_ID);
			}
			return true;

		case 2:// 十战
			if (xpvprole.getTenbattleaward() != 1) {
				if (xpvprole.getTenbattleaward() == 0)
					MessageMgr.sendMsgNotify(roleId, 160342, MessageMgr.getStringList(StringConstant.ID2String("十战奖励", 307)));
				else
					MessageMgr.sendMsgNotify(roleId, 172000, MessageMgr.getStringList(StringConstant.ID2String("十战奖励", 307)));
				return false;
			}

			// 发十战奖励
			RewardMgr.getInstance().distributeAllAward(roleId, PvP3Helper.TEN_FIGHT_AWARD_ID, null,
					fire.log.enums.YYLoggerTuJingEnum.tujing_Value_PVP3, 0, PAddExpProc.OTHER_QUEST, "十战奖励");

			mkdb.Procedure.psendWhileCommit(roleId, new SPvP3OpenBoxState((byte) 2, (byte) 2));
			xpvprole.setTenbattleaward(2);

			// 记录日志
			if (PvP3Control.getLogger().isInfoEnabled()) {
				PvP3Control.getLogger().info("PVP3::[PvP3RoleProxy.openBox] roleId:" + roleId
						+ " boxType:" + boxType
						+ " tenFightAwardId:" + PvP3Helper.TEN_FIGHT_AWARD_ID);
			}
			return true;

		case 3:// 五胜
			if (xpvprole.getFivewinaward() != 1) {
				if (xpvprole.getFivewinaward() == 0)
					MessageMgr.sendMsgNotify(roleId, 160342, MessageMgr.getStringList(StringConstant.ID2String("五胜奖励", 305)));
				else
					MessageMgr.sendMsgNotify(roleId, 172000, MessageMgr.getStringList(StringConstant.ID2String("五胜奖励", 305)));
				return false;
			}

			// 发五胜奖励
			RewardMgr.getInstance().distributeAllAward(roleId, PvP3Helper.CONTINUE_WIN_AWARD_ID, null,
					fire.log.enums.YYLoggerTuJingEnum.tujing_Value_PVP3, 0, PAddExpProc.OTHER_QUEST, "五胜奖励");

			mkdb.Procedure.psendWhileCommit(roleId, new SPvP3OpenBoxState((byte) 3, (byte) 2));
			xpvprole.setFivewinaward(2);

			// 记录日志
			if (PvP3Control.getLogger().isInfoEnabled()) {
				PvP3Control.getLogger().info("PVP3::[PvP3RoleProxy.openBox] roleId:" + roleId
						+ " boxType:" + boxType
						+ " fiveWinAwardId:" + PvP3Helper.CONTINUE_WIN_AWARD_ID);
			}
			return true;
		}
		return false;
	}

	/**
	 * 获取队伍成员,如果没有队伍就填充自己
	 * @参数角色Id
	 * @返回
	 */
	public static List<Long> getTeamMemberIds(long roleId) {

		Team team = TeamManager.selectTeamByRoleId(roleId);
		if (team != null) {
			return team.getNormalMemberIds();
		}

		List<Long> ids = new ArrayList<Long>();
		ids.add(roleId);
		return ids;
	}

	/**
	 * 发送消息给队伍里所有人,如果没有队伍就发送给自己
	 * @参数角色Id
	 * @参数发送
	 */
	public static void notifyTeamProtocol(long roleId, mkio.Protocol send) {

		List<Long> ids = getTeamMemberIds(roleId);
		mkdb.Procedure.psendWhileCommit(ids, send);
	}

	/**
	 * 设置队伍成员的PVP状态
	 * @参数角色Id
	 * @参数状态
	 */
	public static void setTeamMemberPvPState(long roleId, int state) {

		List<Long> ids = getTeamMemberIds(roleId);
		for (long id : ids) {
			PvP3RoleStateManager.getInstance().setRolePvPState(id, state);
		}
	}
}

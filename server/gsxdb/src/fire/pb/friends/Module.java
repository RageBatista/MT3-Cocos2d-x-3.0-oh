package fire.pb.friends;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.apache.log4j.Logger;
import java.sql.Connection;
import java.sql.Statement;
import fire.pb.main.ConfigManager;
import fire.pb.main.ModuleInterface;
import fire.pb.main.ReloadResult;
import fire.pb.mysql.HikariCPUtil;

/**
 * 好友模块
 * 
 * @作者XGM
 */
public class Module implements ModuleInterface {

	public static final Logger logger = Logger.getLogger("FRIEND");

	@Override
	public void exit() {
	}

	@Override
	public void init() throws Exception {
		// 好友数据结构升级
		friendDBUpgrade();
		// 清空过期消息
		mkdb.Procedure proc = new PClearTimeOutProtocol();
		if (mkdb.Transaction.current() == null) {
			proc.submit();
		} else {
			mkdb.Procedure.pexecute(proc);
		}
		// 初始化空间属性
		initSpace();
	}

	@Override
	public ReloadResult reload() throws Exception {
		return null;
	}

	/**
	 * 好友数据结构升级
	 */
	private void friendDBUpgrade() {
		Set<Long> roleIds = new HashSet<Long>();
		// 获得需要升级数据的角色id
		xtable.Friends.getTable().browse(new mkdb.TTable.IWalk<Long, xbean.FriendGroups>() {

			@Override
			public boolean onRecord(Long roleId, xbean.FriendGroups value) {
				// 全部
				return true;
			}
		});
		// 升级数据
		mkdb.Procedure proc = new mkdb.Procedure() {

			@Override
			protected boolean process() {
				if (roleIds.isEmpty()) {
					return true;
				}
				lock(mkdb.Lockeys.get(xtable.Locks.ROLELOCK, roleIds));
				for (long roleId : roleIds) {
					@SuppressWarnings("unused")
					xbean.FriendGroups groups = xtable.Friends.get(roleId);
				}
				return true;
			}
		};
		if (mkdb.Transaction.current() == null) {
			proc.submit();
		} else {
			mkdb.Procedure.pexecute(proc);
		}
	}

	// ----------------------------------------------------------------------//
	// 空间相关 BEGIN
	// ----------------------------------------------------------------------//
	public static int MAXRATE = 0;

	public static Map<Integer, SpaceDropGift> spacedropmap = new HashMap<Integer, SpaceDropGift>();

	void initSpace() {
		int maxrate = 0;
		final java.util.NavigableMap<Integer, SpaceDropGift> spdg = ConfigManager.getInstance().getConf(
				fire.pb.friends.SpaceDropGift.class);
		for (final SpaceDropGift sdg : spdg.values()) {
			maxrate += sdg.getWeight();
			spacedropmap.put(sdg.getId(), sdg);
		}
		MAXRATE = maxrate;
	}

	public static int getRandomSpaceDropGift(long spaceRoleId) {
		xbean.RoleSpace rs = xtable.Rolespaces.select(spaceRoleId);
		if (rs == null)
			return -1;
		if (rs.getGift() <= 0)
			return -1;
		int totalrate = MAXRATE;
		int randrate = mkdb.Mkdb.random().nextInt(totalrate);
		Module.logger.info("PFriendsInfoInit.getRandomSpaceDropGift randrate:" + randrate + ",totalrate:" + totalrate);
		int pilerate = 0;
		for (SpaceDropGift sdg : spacedropmap.values()) {
			pilerate += sdg.getWeight();
			if (randrate < pilerate) {
				return sdg.getItem();
			}
		}
		return -1;
	}

	/**
	 * 创建说不得大师
	 * 
	 * @作者阳涛
	 * @dateTime 2016年5月26日 下午2:56:44
	 * @版本1.0
	 * @param newRoleID
	 * @返回
	 */
	public void createXsh(long newRoleID) {
		new mkdb.Procedure() {

			@Override
			protected boolean process() throws Exception {
				xbean.RoleSpace rs = xtable.Rolespaces.get(newRoleID);
				if (rs != null)
					return false;
				else {
					xbean.RoleSpace newrs = xbean.Pod.newRoleSpace();
					newrs.setGift(99);
					newrs.setPopularity(0);
					newrs.setRecvgift(0);
					newrs.setGetgiftnum(0);
					newrs.setGetgifttime(0);
					xtable.Rolespaces.insert(newRoleID, newrs);
				}
				// 为个人空间好友圈同步信息
				if (!InsertMysqlRelation(newRoleID, "说不得大师", 1, 100)) { // 如果mysql插入失败，直接回滚，角色创建失败
					logger.error("PCreateRole.InsertMysqlRelation failed!");
				}
				return true;
			}
		}.submit();
	}

	/**
	 * 插入角色空间数据
	 * 
	 * @作者阳涛
	 * @dateTime 2016年5月26日 下午3:34:19
	 * @版本1.0
	 * @参数角色Id
	 * @param 角色名
	 * @参数shapeid
	 * @参数级别
	 * @返回
	 */
	/**
	 * 插入角色空间数据（安全加固版）
	 *
	 * 安全改进：
	 * 1. 使用PreparedStatement防止SQL注入
	 * 2. 参数化查询，自动转义特殊字符
	 * 3. 改进错误处理和日志记录
	 *
	 * @作者阳涛
	 * @dateTime 2016年5月26日 下午3:34:19
	 * @version 2.0 (安全加固)
	 * @param roleId 角色ID
	 * @param rolename 角色名称（可能包含特殊字符）
	 * @param shapeid 外形ID
	 * @param level 等级
	 * @return 是否成功
	 */
	private boolean InsertMysqlRelation(long roleId, String rolename, int shapeid, int level) {
		boolean updateRet = false;
		Connection conn = null;
		java.sql.PreparedStatement pstmt = null;

		try {
			conn = HikariCPUtil.getConnection();

			// 使用PreparedStatement防止SQL注入
			// 参数化查询：所有用户输入都作为参数传递，而非直接拼接SQL
			String sqlstr = "INSERT INTO `role`(roleid, name, avatar, level) " +
						   "VALUES (?, ?, ?, ?) " +
						   "ON DUPLICATE KEY UPDATE name=?, avatar=?, level=?";

			pstmt = conn.prepareStatement(sqlstr);

			// 设置参数（自动转义特殊字符）
			pstmt.setLong(1, roleId);
			pstmt.setString(2, rolename);
			pstmt.setInt(3, shapeid);
			pstmt.setInt(4, level);

			// UPDATE部分也需要设置相同参数
			pstmt.setString(5, rolename);
			pstmt.setInt(6, shapeid);
			pstmt.setInt(7, level);

			int ret = pstmt.executeUpdate();

			// 日志中不记录完整的SQL（避免敏感信息泄露）
			fire.pb.friends.Module.logger.info("[" + roleId + "] InsertMysqlRelation executed, rows affected: " + ret);
			updateRet = true;

		} catch (SQLException ex) {
			// 记录错误但不暴露SQL细节
			fire.pb.friends.Module.logger.error("[" + roleId + "] InsertMysqlRelation failed: " + ex.getMessage());
			ex.printStackTrace();
			return false;
		} finally {
			// 确保资源正确关闭
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (SQLException sqlEx) {
					// 忽略关闭异常
				}
			}
			HikariCPUtil.close(conn, null, null);
		}
		return updateRet;
	}
	// ----------------------------------------------------------------------//
	// 空间相关 END
	// ----------------------------------------------------------------------//
}

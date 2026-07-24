package fire.pb.friends;

/**
 * 说不得大师
 * 
 * @作者阳涛
 * @dateTime 2016年6月23日 下午12:01:54
 * @版本1.0
 */
public class XSHUtils {

	public static final long SXH_ROLE_ID = Long.MAX_VALUE;

	private static XSHUtils _instance = new XSHUtils();

	public static XSHUtils getInstance() {
		return _instance;
	}

	/**
	 * 得到最终的角色id，-1代表说不得大师的id
	 * 
	 * @作者阳涛
	 * @dateTime 2016年6月23日 下午12:05:44
	 * @版本1.0
	 * @参数角色Id
	 * @返回
	 */
	public Long getLastRoleId(long roleId) {
		if (roleId == -1) {
			return SXH_ROLE_ID;
		}
		return roleId;
	}
}

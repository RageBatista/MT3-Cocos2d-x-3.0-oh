
package xbean;

public interface RoleDoubleChareInfo extends mkdb.Bean {
	public RoleDoubleChareInfo copy(); // 深拷贝
	public RoleDoubleChareInfo toData(); // 一个 Data 实例
	public RoleDoubleChareInfo toBean(); // 一个 Bean 实例
	public RoleDoubleChareInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleDoubleChareInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getActivetime(); // 活动开始时间
	public java.util.Map<Integer, Integer> getAchievement(); // value=1 表示充值过  商品的id -> flag
	public java.util.Map<Integer, Integer> getAchievementAsData(); // value=1 表示充值过  商品的id -> flag
	public int getFlag(); // 0=没有初始化过  1=初始化过 2=网页充值临时初始化

	public void setActivetime(long _v_); // 活动开始时间
	public void setFlag(int _v_); // 0=没有初始化过  1=初始化过 2=网页充值临时初始化
}

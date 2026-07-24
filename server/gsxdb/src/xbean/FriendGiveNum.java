
package xbean;

public interface FriendGiveNum extends mkdb.Bean {
	public FriendGiveNum copy(); // 深拷贝
	public FriendGiveNum toData(); // 一个 Data 实例
	public FriendGiveNum toBean(); // 一个 Bean 实例
	public FriendGiveNum toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FriendGiveNum toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Integer> getGivenummap(); // key为角色id value为数量 *byte够了
	public java.util.Map<Long, Integer> getGivenummapAsData(); // key为角色id value为数量 *byte够了
	public long getResettime(); // 重置时间

	public void setResettime(long _v_); // 重置时间
}

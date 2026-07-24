
package xbean;

public interface FriendBean extends mkdb.Bean {
	public FriendBean copy(); // 深拷贝
	public FriendBean toData(); // 一个 Data 实例
	public FriendBean toBean(); // 一个 Bean 实例
	public FriendBean toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public FriendBean toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getFriendlydegrees(); // 好友度

	public void setFriendlydegrees(int _v_); // 好友度
}

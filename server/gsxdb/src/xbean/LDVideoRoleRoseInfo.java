
package xbean;

public interface LDVideoRoleRoseInfo extends mkdb.Bean {
	public LDVideoRoleRoseInfo copy(); // 深拷贝
	public LDVideoRoleRoseInfo toData(); // 一个 Data 实例
	public LDVideoRoleRoseInfo toBean(); // 一个 Bean 实例
	public LDVideoRoleRoseInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LDVideoRoleRoseInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public String getVideoid(); // 录像id
	public com.locojoy.base.Octets getVideoidOctets(); // 录像id
	public int getRosenum(); // 次数

	public void setVideoid(String _v_); // 录像id
	public void setVideoidOctets(com.locojoy.base.Octets _v_); // 录像id
	public void setRosenum(int _v_); // 次数
}

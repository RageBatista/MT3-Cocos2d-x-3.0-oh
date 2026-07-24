
package xbean;

public interface RedPackRoleInfoList extends mkdb.Bean {
	public RedPackRoleInfoList copy(); // 深拷贝
	public RedPackRoleInfoList toData(); // 一个 Data 实例
	public RedPackRoleInfoList toBean(); // 一个 Bean 实例
	public RedPackRoleInfoList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RedPackRoleInfoList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<String, xbean.RedPackInfo> getRedpackinfolist(); // 红包记录 key=redpackid
	public java.util.Map<String, xbean.RedPackInfo> getRedpackinfolistAsData(); // 红包记录 key=redpackid

}

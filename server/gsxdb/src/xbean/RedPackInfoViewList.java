
package xbean;

public interface RedPackInfoViewList extends mkdb.Bean {
	public RedPackInfoViewList copy(); // 深拷贝
	public RedPackInfoViewList toData(); // 一个 Data 实例
	public RedPackInfoViewList toBean(); // 一个 Bean 实例
	public RedPackInfoViewList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RedPackInfoViewList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<String, xbean.RedPackBaseInfo> getRedpackinfoviewlist(); // 红包记录 key=redpackid
	public java.util.Map<String, xbean.RedPackBaseInfo> getRedpackinfoviewlistAsData(); // 红包记录 key=redpackid

}

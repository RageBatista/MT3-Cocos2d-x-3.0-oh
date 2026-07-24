
package xbean;

public interface ClanIndex extends mkdb.Bean {
	public ClanIndex copy(); // 深拷贝
	public ClanIndex toData(); // 一个 Data 实例
	public ClanIndex toBean(); // 一个 Bean 实例
	public ClanIndex toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanIndex toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getIndex(); // 
	public java.util.Map<Integer, Long> getIndexAsData(); // 

}


package xbean;

public interface ClanInstBestLevel extends mkdb.Bean {
	public ClanInstBestLevel copy(); // 深拷贝
	public ClanInstBestLevel toData(); // 一个 Data 实例
	public ClanInstBestLevel toBean(); // 一个 Bean 实例
	public ClanInstBestLevel toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ClanInstBestLevel toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getInstsave(); // 最先通过公会副本某一层的公会,key 层数, value 公会key
	public java.util.Map<Integer, Long> getInstsaveAsData(); // 最先通过公会副本某一层的公会,key 层数, value 公会key

}

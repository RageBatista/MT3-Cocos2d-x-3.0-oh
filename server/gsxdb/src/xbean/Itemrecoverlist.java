
package xbean;

public interface Itemrecoverlist extends mkdb.Bean {
	public Itemrecoverlist copy(); // 深拷贝
	public Itemrecoverlist toData(); // 一个 Data 实例
	public Itemrecoverlist toBean(); // 一个 Bean 实例
	public Itemrecoverlist toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Itemrecoverlist toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Long> getUniqids(); // 物品唯一id列表
	public java.util.List<Long> getUniqidsAsData(); // 物品唯一id列表

}


package xbean;

public interface Petrecoverlist extends mkdb.Bean {
	public Petrecoverlist copy(); // 深拷贝
	public Petrecoverlist toData(); // 一个 Data 实例
	public Petrecoverlist toBean(); // 一个 Bean 实例
	public Petrecoverlist toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Petrecoverlist toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Long> getUniqids(); // 宠物唯一id列表
	public java.util.List<Long> getUniqidsAsData(); // 宠物唯一id列表

}

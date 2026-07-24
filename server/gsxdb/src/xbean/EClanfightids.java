
package xbean;

public interface EClanfightids extends mkdb.Bean {
	public EClanfightids copy(); // 深拷贝
	public EClanfightids toData(); // 一个 Data 实例
	public EClanfightids toBean(); // 一个 Bean 实例
	public EClanfightids toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public EClanfightids toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Long> getIds(); // 本周公会战id，作者 changhao
	public java.util.List<Long> getIdsAsData(); // 本周公会战id，作者 changhao

}


package xbean;

public interface BingFengWangZuo extends mkdb.Bean {
	public BingFengWangZuo copy(); // 深拷贝
	public BingFengWangZuo toData(); // 一个 Data 实例
	public BingFengWangZuo toBean(); // 一个 Bean 实例
	public BingFengWangZuo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BingFengWangZuo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Integer> getDeathtimes(); // 死亡次数 key为角色id
	public java.util.Map<Long, Integer> getDeathtimesAsData(); // 死亡次数 key为角色id

}

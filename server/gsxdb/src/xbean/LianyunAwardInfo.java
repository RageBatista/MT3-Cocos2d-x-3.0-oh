
package xbean;

public interface LianyunAwardInfo extends mkdb.Bean {
	public LianyunAwardInfo copy(); // 深拷贝
	public LianyunAwardInfo toData(); // 一个 Data 实例
	public LianyunAwardInfo toBean(); // 一个 Bean 实例
	public LianyunAwardInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LianyunAwardInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Long> getAwards(); // 
	public java.util.Map<Integer, Long> getAwardsAsData(); // 

}

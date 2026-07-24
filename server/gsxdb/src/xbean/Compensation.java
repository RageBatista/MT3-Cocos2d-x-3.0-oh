
package xbean;

public interface Compensation extends mkdb.Bean {
	public Compensation copy(); // 深拷贝
	public Compensation toData(); // 一个 Data 实例
	public Compensation toBean(); // 一个 Bean 实例
	public Compensation toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Compensation toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.CompensationInfo> getCompensationmap(); // 领取补偿的id
	public java.util.Map<Integer, xbean.CompensationInfo> getCompensationmapAsData(); // 领取补偿的id

}

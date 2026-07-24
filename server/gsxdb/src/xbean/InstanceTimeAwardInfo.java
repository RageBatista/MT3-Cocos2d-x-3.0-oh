
package xbean;

public interface InstanceTimeAwardInfo extends mkdb.Bean {
	public InstanceTimeAwardInfo copy(); // 深拷贝
	public InstanceTimeAwardInfo toData(); // 一个 Data 实例
	public InstanceTimeAwardInfo toBean(); // 一个 Bean 实例
	public InstanceTimeAwardInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceTimeAwardInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, Integer> getStepawardtimes(); // key stepId, value 该step给的奖励次数
	public java.util.Map<Integer, Integer> getStepawardtimesAsData(); // key stepId, value 该step给的奖励次数

}

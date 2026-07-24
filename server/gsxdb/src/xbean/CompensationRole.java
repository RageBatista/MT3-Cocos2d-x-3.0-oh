
package xbean;

public interface CompensationRole extends mkdb.Bean {
	public CompensationRole copy(); // 深拷贝
	public CompensationRole toData(); // 一个 Data 实例
	public CompensationRole toBean(); // 一个 Bean 实例
	public CompensationRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public CompensationRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Long, Long> getSinglecompensations(); // key = 补偿key, value = 是否已读 0=未读 1=已读
	public java.util.Map<Long, Long> getSinglecompensationsAsData(); // key = 补偿key, value = 是否已读 0=未读 1=已读

}

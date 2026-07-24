
package xbean;

public interface Track extends mkdb.Bean {
	public Track copy(); // 深拷贝
	public Track toData(); // 一个 Data 实例
	public Track toBean(); // 一个 Bean 实例
	public Track toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Track toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getDate(); // 接受任务

	public void setDate(long _v_); // 接受任务
}


package xbean;

public interface TaskRecourse extends mkdb.Bean {
	public TaskRecourse copy(); // 深拷贝
	public TaskRecourse toData(); // 一个 Data 实例
	public TaskRecourse toBean(); // 一个 Bean 实例
	public TaskRecourse toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TaskRecourse toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Integer> getChannellist(); // 频道id 的list
	public java.util.List<Integer> getChannellistAsData(); // 频道id 的list

}

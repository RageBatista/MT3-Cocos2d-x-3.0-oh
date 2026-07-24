
package xbean;

public interface CircleTaskMap extends mkdb.Bean {
	public CircleTaskMap copy(); // 深拷贝
	public CircleTaskMap toData(); // 一个 Data 实例
	public CircleTaskMap toBean(); // 一个 Bean 实例
	public CircleTaskMap toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public CircleTaskMap toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.CircleTaskInfo> getTaskmap(); // 
	public java.util.Map<Integer, xbean.CircleTaskInfo> getTaskmapAsData(); // 

}


package xbean;

public interface TaskInfos extends mkdb.Bean {
	public TaskInfos copy(); // 深拷贝
	public TaskInfos toData(); // 一个 Data 实例
	public TaskInfos toBean(); // 一个 Bean 实例
	public TaskInfos toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TaskInfos toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.TaskDlgInfo> getTasksmap(); // 
	public java.util.Map<Integer, xbean.TaskDlgInfo> getTasksmapAsData(); // 

}

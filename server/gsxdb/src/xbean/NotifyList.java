
package xbean;

public interface NotifyList extends mkdb.Bean {
	public NotifyList copy(); // 深拷贝
	public NotifyList toData(); // 一个 Data 实例
	public NotifyList toBean(); // 一个 Bean 实例
	public NotifyList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public NotifyList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getNotifytypeid(); // 
	public java.util.List<Integer> getBuffids(); // 
	public java.util.List<Integer> getBuffidsAsData(); // 

	public void setNotifytypeid(int _v_); // 
}

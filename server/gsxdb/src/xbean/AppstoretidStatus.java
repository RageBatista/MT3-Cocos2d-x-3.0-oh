
package xbean;

public interface AppstoretidStatus extends mkdb.Bean {
	public AppstoretidStatus copy(); // 深拷贝
	public AppstoretidStatus toData(); // 一个 Data 实例
	public AppstoretidStatus toBean(); // 一个 Bean 实例
	public AppstoretidStatus toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public AppstoretidStatus toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getChargesn(); // 
	public int getStatus(); // 0处理中,1充值成功,2充值失败

	public void setChargesn(long _v_); // 
	public void setStatus(int _v_); // 0处理中,1充值成功,2充值失败
}

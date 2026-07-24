
package xbean;

public interface BingFengRole extends mkdb.Bean {
	public BingFengRole copy(); // 深拷贝
	public BingFengRole toData(); // 一个 Data 实例
	public BingFengRole toBean(); // 一个 Bean 实例
	public BingFengRole toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public BingFengRole toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getInstzoneid(); // 
	public int getTimes(); // 
	public int getChargetimes(); // 
	public java.util.Map<Integer, xbean.RoleBFInfo> getInfos(); // 每一个冰封王座的状态
	public java.util.Map<Integer, xbean.RoleBFInfo> getInfosAsData(); // 每一个冰封王座的状态

	public void setInstzoneid(int _v_); // 
	public void setTimes(int _v_); // 
	public void setChargetimes(int _v_); // 
}

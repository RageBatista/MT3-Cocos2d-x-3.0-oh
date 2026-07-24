
package xbean;

public interface LogBean extends mkdb.Bean {
	public LogBean copy(); // 深拷贝
	public LogBean toData(); // 一个 Data 实例
	public LogBean toBean(); // 一个 Bean 实例
	public LogBean toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public LogBean toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getItemid(); // 
	public int getLevel(); // 
	public int getNumber(); // 
	public int getMoney(); // 

	public void setItemid(int _v_); // 
	public void setLevel(int _v_); // 
	public void setNumber(int _v_); // 
	public void setMoney(int _v_); // 
}

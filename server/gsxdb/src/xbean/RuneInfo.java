
package xbean;

public interface RuneInfo extends mkdb.Bean {
	public RuneInfo copy(); // 深拷贝
	public RuneInfo toData(); // 一个 Data 实例
	public RuneInfo toBean(); // 一个 Bean 实例
	public RuneInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RuneInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getDayrequestnum(); // 请求次数
	public int getAllgivenum(); // 捐符数
	public int getAllacceptnum(); // 收符数
	public int getItemlevel(); // 物品等级

	public void setDayrequestnum(int _v_); // 请求次数
	public void setAllgivenum(int _v_); // 捐符数
	public void setAllacceptnum(int _v_); // 收符数
	public void setItemlevel(int _v_); // 物品等级
}

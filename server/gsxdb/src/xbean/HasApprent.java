
package xbean;

public interface HasApprent extends mkdb.Bean {
	public HasApprent copy(); // 深拷贝
	public HasApprent toData(); // 一个 Data 实例
	public HasApprent toBean(); // 一个 Bean 实例
	public HasApprent toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public HasApprent toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public String getName(); // 
	public com.locojoy.base.Octets getNameOctets(); // 
	public int getLevel(); // 
	public int getSchool(); // 
	public long getRoleid(); // 
	public int getCamp(); // 
	public int getShap(); // 

	public void setName(String _v_); // 
	public void setNameOctets(com.locojoy.base.Octets _v_); // 
	public void setLevel(int _v_); // 
	public void setSchool(int _v_); // 
	public void setRoleid(long _v_); // 
	public void setCamp(int _v_); // 
	public void setShap(int _v_); // 
}

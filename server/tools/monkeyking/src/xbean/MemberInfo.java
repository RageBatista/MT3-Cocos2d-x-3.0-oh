
package xbean;

public interface MemberInfo extends mkdb.Bean {
	public MemberInfo copy(); // deep clone
	public MemberInfo toData(); // a Data instance
	public MemberInfo toBean(); // a Bean instance
	public MemberInfo toDataIf(); // a Data instance If need. else return this
	public MemberInfo toBeanIf(); // a Bean instance If need. else return this

	public int getId(); // 
	public String getName(); // 
	public com.locojoy.base.Octets getNameOctets(); // 
	public long getOffline(); // 
	public int getLevel(); // 
	public int getMenpai(); // 

	public void setId(int _v_); // 
	public void setName(String _v_); // 
	public void setNameOctets(com.locojoy.base.Octets _v_); // 
	public void setOffline(long _v_); // 
	public void setLevel(int _v_); // 
	public void setMenpai(int _v_); // 
}

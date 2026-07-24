
package xbean;

public interface Family extends mkdb.Bean {
	public Family copy(); // deep clone
	public Family toData(); // a Data instance
	public Family toBean(); // a Bean instance
	public Family toDataIf(); // a Data instance If need. else return this
	public Family toBeanIf(); // a Bean instance If need. else return this

	public int getId(); // 
	public int getLevel(); // 
	public int getContribution(); // 
	public int getLeaderid(); // 
	public int getCreatorid(); // 
	public String getName(); // 
	public com.locojoy.base.Octets getNameOctets(); // 
	public String getAim(); // 
	public com.locojoy.base.Octets getAimOctets(); // 
	public String getPub(); // 
	public com.locojoy.base.Octets getPubOctets(); // 
	public java.util.Map<Integer, xbean.MemberInfo> getMemebers(); // 
	public java.util.Map<Integer, xbean.MemberInfo> getMemebersAsData(); // 
	public int getStatus(); // 
	public long getCreate_time(); // 
	public int getWell_known(); // 

	public void setId(int _v_); // 
	public void setLevel(int _v_); // 
	public void setContribution(int _v_); // 
	public void setLeaderid(int _v_); // 
	public void setCreatorid(int _v_); // 
	public void setName(String _v_); // 
	public void setNameOctets(com.locojoy.base.Octets _v_); // 
	public void setAim(String _v_); // 
	public void setAimOctets(com.locojoy.base.Octets _v_); // 
	public void setPub(String _v_); // 
	public void setPubOctets(com.locojoy.base.Octets _v_); // 
	public void setStatus(int _v_); // 
	public void setCreate_time(long _v_); // 
	public void setWell_known(int _v_); // 
}


package xbean;

public interface forbidinfo extends mkdb.Bean {
	public forbidinfo copy(); // 深拷贝
	public forbidinfo toData(); // 一个 Data 实例
	public forbidinfo toBean(); // 一个 Bean 实例
	public forbidinfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public forbidinfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getForbidtime(); // 
	public String getReason(); // 
	public com.locojoy.base.Octets getReasonOctets(); // 

	public void setForbidtime(long _v_); // 
	public void setReason(String _v_); // 
	public void setReasonOctets(com.locojoy.base.Octets _v_); // 
}

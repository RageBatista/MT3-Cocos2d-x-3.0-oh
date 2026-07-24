
package xbean;

public interface OfflineMsgProtocol extends mkdb.Bean {
	public OfflineMsgProtocol copy(); // 深拷贝
	public OfflineMsgProtocol toData(); // 一个 Data 实例
	public OfflineMsgProtocol toBean(); // 一个 Bean 实例
	public OfflineMsgProtocol toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public OfflineMsgProtocol toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getProtype(); // 
	public <T extends com.locojoy.base.Marshal.Marshal> T getContent(T _v_); // 
	public boolean isContentEmpty(); // 
	public byte[] getContentCopy(); // 
	public String getProclassname(); // 
	public com.locojoy.base.Octets getProclassnameOctets(); // 
	public long getTick(); // 插入到离线协议的时间

	public void setProtype(int _v_); // 
	public void setContent(com.locojoy.base.Marshal.Marshal _v_); // 
	public void setContentCopy(byte[] _v_); // 
	public void setProclassname(String _v_); // 
	public void setProclassnameOctets(com.locojoy.base.Octets _v_); // 
	public void setTick(long _v_); // 插入到离线协议的时间
}

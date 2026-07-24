
package xbean;

public interface Diskdbh extends mkdb.Bean {
	public Diskdbh copy(); // deep clone
	public Diskdbh toData(); // a Data instance
	public Diskdbh toBean(); // a Bean instance
	public Diskdbh toDataIf(); // a Data instance If need. else return this
	public Diskdbh toBeanIf(); // a Bean instance If need. else return this

	public <T extends com.locojoy.base.Marshal.Marshal> T getData(T _v_); // 
	public boolean isDataEmpty(); // 
	public byte[] getDataCopy(); // 

	public void setData(com.locojoy.base.Marshal.Marshal _v_); // 
	public void setDataCopy(byte[] _v_); // 
}

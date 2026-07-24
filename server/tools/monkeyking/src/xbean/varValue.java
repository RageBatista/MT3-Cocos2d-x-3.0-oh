
package xbean;

public interface varValue extends mkdb.Bean {
	public varValue copy(); // deep clone
	public varValue toData(); // a Data instance
	public varValue toBean(); // a Bean instance
	public varValue toDataIf(); // a Data instance If need. else return this
	public varValue toBeanIf(); // a Bean instance If need. else return this

	public int getVint(); // 
	public String getVstring(); // 
	public com.locojoy.base.Octets getVstringOctets(); // 
	public short getVshort(); // 
	public boolean getVbool(); // 
	public long getVlong(); // 
	public <T extends com.locojoy.base.Marshal.Marshal> T getVbinary(T _v_); // 
	public boolean isVbinaryEmpty(); // 
	public byte[] getVbinaryCopy(); // 
	public xbean.xxx getVxxx(); // 
	public xbean.xxx getVyyy(); // 
	public java.util.Map<Integer, String> getVmap(); // 
	public java.util.Map<Integer, String> getVmapAsData(); // 
	public java.util.Set<xbean.xxx> getVset(); // 
	public java.util.Set<xbean.xxx> getVsetAsData(); // 
	public java.util.List<xbean.yyy> getVlist(); // 
	public java.util.List<xbean.yyy> getVlistAsData(); // 
	public java.util.List<Short> getVvector(); // 
	public java.util.List<Short> getVvectorAsData(); // 

	public void setVint(int _v_); // 
	public void setVstring(String _v_); // 
	public void setVstringOctets(com.locojoy.base.Octets _v_); // 
	public void setVshort(short _v_); // 
	public void setVbool(boolean _v_); // 
	public void setVlong(long _v_); // 
	public void setVbinary(com.locojoy.base.Marshal.Marshal _v_); // 
	public void setVbinaryCopy(byte[] _v_); // 
}

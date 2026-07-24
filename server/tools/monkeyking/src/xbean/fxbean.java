
package xbean;

public interface fxbean extends mkdb.Bean {
	public fxbean copy(); // deep clone
	public fxbean toData(); // a Data instance
	public fxbean toBean(); // a Bean instance
	public fxbean toDataIf(); // a Data instance If need. else return this
	public fxbean toBeanIf(); // a Bean instance If need. else return this

	public java.util.Set<Boolean> getA(); // 
	public java.util.Set<Boolean> getAAsData(); // 
	public java.util.List<xbean.fcbean> getB(); // 
	public java.util.List<xbean.fcbean> getBAsData(); // 
	public java.util.List<Float> getC(); // 
	public java.util.List<Float> getCAsData(); // 
	public java.util.Map<Integer, xbean.fcbean> getD(); // 
	public java.util.Map<Integer, xbean.fcbean> getDAsData(); // 
	public java.util.NavigableMap<String, Short> getE(); // 
	public java.util.NavigableMap<String, Short> getEAsData(); // 
	public xbean.fxbean0 getF(); // 
	public int getG(); // 
	public <T extends com.locojoy.base.Marshal.Marshal> T getH(T _v_); // 
	public boolean isHEmpty(); // 
	public byte[] getHCopy(); // 

	public void setG(int _v_); // 
	public void setH(com.locojoy.base.Marshal.Marshal _v_); // 
	public void setHCopy(byte[] _v_); // 
}

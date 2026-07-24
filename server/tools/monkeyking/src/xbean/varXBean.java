
package xbean;

public interface varXBean extends mkdb.Bean {
	public varXBean copy(); // deep clone
	public varXBean toData(); // a Data instance
	public varXBean toBean(); // a Bean instance
	public varXBean toDataIf(); // a Data instance If need. else return this
	public varXBean toBeanIf(); // a Bean instance If need. else return this

	public int getVint(); // 
	public String getVstring(); // 
	public com.locojoy.base.Octets getVstringOctets(); // 
	public java.util.Set<Integer> getVset(); // 
	public java.util.Set<Integer> getVsetAsData(); // 
	public java.util.Map<Integer, Integer> getVmap(); // 
	public java.util.Map<Integer, Integer> getVmapAsData(); // 

	public void setVint(int _v_); // 
	public void setVstring(String _v_); // 
	public void setVstringOctets(com.locojoy.base.Octets _v_); // 
}


package xbean;

public interface Cacheb2 extends mkdb.Bean {
	public Cacheb2 copy(); // deep clone
	public Cacheb2 toData(); // a Data instance
	public Cacheb2 toBean(); // a Bean instance
	public Cacheb2 toDataIf(); // a Data instance If need. else return this
	public Cacheb2 toBeanIf(); // a Bean instance If need. else return this

	public int getI(); // 
	public long getL(); // 
	public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal(T _v_); // binary
	public boolean isMarshalEmpty(); // binary
	public byte[] getMarshalCopy(); // binary
	public java.util.Set<Integer> getSeti(); // 
	public java.util.Set<Integer> getSetiAsData(); // 

	public void setI(int _v_); // 
	public void setL(long _v_); // 
	public void setMarshal(com.locojoy.base.Marshal.Marshal _v_); // binary
	public void setMarshalCopy(byte[] _v_); // binary
}

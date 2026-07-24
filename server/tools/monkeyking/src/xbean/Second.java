
package xbean;

public interface Second extends mkdb.Bean {
	public Second copy(); // deep clone
	public Second toData(); // a Data instance
	public Second toBean(); // a Bean instance
	public Second toDataIf(); // a Data instance If need. else return this
	public Second toBeanIf(); // a Bean instance If need. else return this

	public java.util.Set<Integer> getSetfirst(); // a
	public java.util.Set<Integer> getSetfirstAsData(); // a
	public java.util.List<xbean.First> getListfirst(); // b
	public java.util.List<xbean.First> getListfirstAsData(); // b
	public java.util.List<xbean.First> getVectorfirst(); // c
	public java.util.List<xbean.First> getVectorfirstAsData(); // c
	public java.util.Map<Integer, xbean.First> getMapfirst(); // d
	public java.util.Map<Integer, xbean.First> getMapfirstAsData(); // d
	public java.util.Map<String, xbean.First> getMapxfirst(); // e
	public java.util.Map<String, xbean.First> getMapxfirstAsData(); // e
	public xbean.First getFirst(); // g
	public int getI(); // int test
	public <T extends com.locojoy.base.Marshal.Marshal> T getMarshal2(T _v_); // binary
	public boolean isMarshal2Empty(); // binary
	public byte[] getMarshal2Copy(); // binary

	public void setI(int _v_); // int test
	public void setMarshal2(com.locojoy.base.Marshal.Marshal _v_); // binary
	public void setMarshal2Copy(byte[] _v_); // binary
}

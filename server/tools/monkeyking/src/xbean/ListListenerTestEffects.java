
package xbean;

public interface ListListenerTestEffects extends mkdb.Bean {
	public ListListenerTestEffects copy(); // deep clone
	public ListListenerTestEffects toData(); // a Data instance
	public ListListenerTestEffects toBean(); // a Bean instance
	public ListListenerTestEffects toDataIf(); // a Data instance If need. else return this
	public ListListenerTestEffects toBeanIf(); // a Bean instance If need. else return this

	public java.util.List<xbean.ListListenerTestEffect> getEffects(); // 
	public java.util.List<xbean.ListListenerTestEffect> getEffectsAsData(); // 

}

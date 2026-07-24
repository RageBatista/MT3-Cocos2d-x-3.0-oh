
package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class ListListenerTestEffects extends mkdb.XBean implements xbean.ListListenerTestEffects {
	private java.util.LinkedList<xbean.ListListenerTestEffect> effects; // 

	@Override
	public void _reset_unsafe_() {
		effects.clear();
	}

	ListListenerTestEffects(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		effects = new java.util.LinkedList<xbean.ListListenerTestEffect>();
	}

	public ListListenerTestEffects() {
		this(0, null, null);
	}

	public ListListenerTestEffects(ListListenerTestEffects _o_) {
		this(_o_, null, null);
	}

	ListListenerTestEffects(xbean.ListListenerTestEffects _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof ListListenerTestEffects) assign((ListListenerTestEffects)_o1_);
		else if (_o1_ instanceof ListListenerTestEffects.Data) assign((ListListenerTestEffects.Data)_o1_);
		else if (_o1_ instanceof ListListenerTestEffects.Const) assign(((ListListenerTestEffects.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(ListListenerTestEffects _o_) {
		effects = new java.util.LinkedList<xbean.ListListenerTestEffect>();
		for (xbean.ListListenerTestEffect _v_ : _o_.effects)
			effects.add(new ListListenerTestEffect(_v_, this, "effects"));
	}

	private void assign(ListListenerTestEffects.Data _o_) {
		effects = new java.util.LinkedList<xbean.ListListenerTestEffect>();
		for (xbean.ListListenerTestEffect _v_ : _o_.effects)
			effects.add(new ListListenerTestEffect(_v_, this, "effects"));
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_os_.compact_uint32(effects.size());
		for (xbean.ListListenerTestEffect _v_ : effects) {
			_v_.marshal(_os_);
		}
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		for (int size = _os_.uncompact_uint32(); size > 0; --size) {
			xbean.ListListenerTestEffect _v_ = new ListListenerTestEffect(0, this, "effects");
			_v_.unmarshal(_os_);
			effects.add(_v_);
		}
		return _os_;
	}

	@Override
	public xbean.ListListenerTestEffects copy() {
		return new ListListenerTestEffects(this);
	}

	@Override
	public xbean.ListListenerTestEffects toData() {
		return new Data(this);
	}

	public xbean.ListListenerTestEffects toBean() {
		return new ListListenerTestEffects(this); // same as copy()
	}

	@Override
	public xbean.ListListenerTestEffects toDataIf() {
		return new Data(this);
	}

	public xbean.ListListenerTestEffects toBeanIf() {
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		return new Const();
	}

	@Override
	public java.util.List<xbean.ListListenerTestEffect> getEffects() { // 
		return mkdb.Logs.logList(new mkdb.LogKey(this, "effects"), effects);
	}

	public java.util.List<xbean.ListListenerTestEffect> getEffectsAsData() { // 
		java.util.List<xbean.ListListenerTestEffect> effects;
		ListListenerTestEffects _o_ = this;
		effects = new java.util.LinkedList<xbean.ListListenerTestEffect>();
		for (xbean.ListListenerTestEffect _v_ : _o_.effects)
			effects.add(new ListListenerTestEffect.Data(_v_));
		return effects;
	}

	@Override
	public final boolean equals(Object _o1_) {
		ListListenerTestEffects _o_ = null;
		if ( _o1_ instanceof ListListenerTestEffects ) _o_ = (ListListenerTestEffects)_o1_;
		else if ( _o1_ instanceof ListListenerTestEffects.Const ) _o_ = ((ListListenerTestEffects.Const)_o1_).nThis();
		else return false;
		if (!effects.equals(_o_.effects)) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		int _h_ = 0;
		_h_ += effects.hashCode();
		return _h_;
	}

	@Override
	public String toString() {
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(effects);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("effects"));
		return lb;
	}

	private class Const implements xbean.ListListenerTestEffects {
		ListListenerTestEffects nThis() {
			return ListListenerTestEffects.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.ListListenerTestEffects copy() {
			return ListListenerTestEffects.this.copy();
		}

		@Override
		public xbean.ListListenerTestEffects toData() {
			return ListListenerTestEffects.this.toData();
		}

		public xbean.ListListenerTestEffects toBean() {
			return ListListenerTestEffects.this.toBean();
		}

		@Override
		public xbean.ListListenerTestEffects toDataIf() {
			return ListListenerTestEffects.this.toDataIf();
		}

		public xbean.ListListenerTestEffects toBeanIf() {
			return ListListenerTestEffects.this.toBeanIf();
		}

		@Override
		public java.util.List<xbean.ListListenerTestEffect> getEffects() { // 
			return mkdb.Consts.constList(effects);
		}

		public java.util.List<xbean.ListListenerTestEffect> getEffectsAsData() { // 
			java.util.List<xbean.ListListenerTestEffect> effects;
			ListListenerTestEffects _o_ = ListListenerTestEffects.this;
		effects = new java.util.LinkedList<xbean.ListListenerTestEffect>();
		for (xbean.ListListenerTestEffect _v_ : _o_.effects)
			effects.add(new ListListenerTestEffect.Data(_v_));
			return effects;
		}

		@Override
		public mkdb.Bean toConst() {
			return this;
		}

		@Override
		public boolean isConst() {
			return true;
		}

		@Override
		public boolean isData() {
			return ListListenerTestEffects.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return ListListenerTestEffects.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return ListListenerTestEffects.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return ListListenerTestEffects.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return ListListenerTestEffects.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return ListListenerTestEffects.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return ListListenerTestEffects.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return ListListenerTestEffects.this.hashCode();
		}

		@Override
		public String toString() {
			return ListListenerTestEffects.this.toString();
		}

	}

	public static final class Data implements xbean.ListListenerTestEffects {
		private java.util.LinkedList<xbean.ListListenerTestEffect> effects; // 

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
			effects = new java.util.LinkedList<xbean.ListListenerTestEffect>();
		}

		Data(xbean.ListListenerTestEffects _o1_) {
			if (_o1_ instanceof ListListenerTestEffects) assign((ListListenerTestEffects)_o1_);
			else if (_o1_ instanceof ListListenerTestEffects.Data) assign((ListListenerTestEffects.Data)_o1_);
			else if (_o1_ instanceof ListListenerTestEffects.Const) assign(((ListListenerTestEffects.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(ListListenerTestEffects _o_) {
			effects = new java.util.LinkedList<xbean.ListListenerTestEffect>();
			for (xbean.ListListenerTestEffect _v_ : _o_.effects)
				effects.add(new ListListenerTestEffect.Data(_v_));
		}

		private void assign(ListListenerTestEffects.Data _o_) {
			effects = new java.util.LinkedList<xbean.ListListenerTestEffect>();
			for (xbean.ListListenerTestEffect _v_ : _o_.effects)
				effects.add(new ListListenerTestEffect.Data(_v_));
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.compact_uint32(effects.size());
			for (xbean.ListListenerTestEffect _v_ : effects) {
				_v_.marshal(_os_);
			}
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			for (int size = _os_.uncompact_uint32(); size > 0; --size) {
				xbean.ListListenerTestEffect _v_ = xbean.Pod.newListListenerTestEffectData();
				_v_.unmarshal(_os_);
				effects.add(_v_);
			}
			return _os_;
		}

		@Override
		public xbean.ListListenerTestEffects copy() {
			return new Data(this);
		}

		@Override
		public xbean.ListListenerTestEffects toData() {
			return new Data(this);
		}

		public xbean.ListListenerTestEffects toBean() {
			return new ListListenerTestEffects(this, null, null);
		}

		@Override
		public xbean.ListListenerTestEffects toDataIf() {
			return this;
		}

		public xbean.ListListenerTestEffects toBeanIf() {
			return new ListListenerTestEffects(this, null, null);
		}

		// mkdb.Bean interface. Data Unsupported
		public boolean xdbManaged() { throw new UnsupportedOperationException(); }
		public mkdb.Bean xdbParent() { throw new UnsupportedOperationException(); }
		public String xdbVarname()  { throw new UnsupportedOperationException(); }
		public Long    xdbObjId()   { throw new UnsupportedOperationException(); }
		public mkdb.Bean toConst()   { throw new UnsupportedOperationException(); }
		public boolean isConst()    { return false; }
		public boolean isData()     { return true; }

		@Override
		public java.util.List<xbean.ListListenerTestEffect> getEffects() { // 
			return effects;
		}

		@Override
		public java.util.List<xbean.ListListenerTestEffect> getEffectsAsData() { // 
			return effects;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof ListListenerTestEffects.Data)) return false;
			ListListenerTestEffects.Data _o_ = (ListListenerTestEffects.Data) _o1_;
			if (!effects.equals(_o_.effects)) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += effects.hashCode();
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(effects);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}


package xbean.__;

import com.locojoy.base.Marshal.OctetsStream;
import com.locojoy.base.Marshal.MarshalException;

public final class XingChenItem extends mkdb.XBean implements xbean.XingChenItem {
	private int id; // 称谓id
	private int pos; // 称谓名
	private int level; // 剩余有效时间
	private int pinzhi; // 剩余有效时间
	private int naijiu; // 剩余有效时间
	private int shuxing; // 剩余有效时间
	private int xishu; // 剩余有效时间

	@Override
	public void _reset_unsafe_() {
		id = 0;
		pos = 0;
		level = 0;
		pinzhi = 0;
		naijiu = 0;
		shuxing = 0;
		xishu = 0;
	}

	XingChenItem(int __, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
	}

	public XingChenItem() {
		this(0, null, null);
	}

	public XingChenItem(XingChenItem _o_) {
		this(_o_, null, null);
	}

	XingChenItem(xbean.XingChenItem _o1_, mkdb.XBean _xp_, String _vn_) {
		super(_xp_, _vn_);
		if (_o1_ instanceof XingChenItem) assign((XingChenItem)_o1_);
		else if (_o1_ instanceof XingChenItem.Data) assign((XingChenItem.Data)_o1_);
		else if (_o1_ instanceof XingChenItem.Const) assign(((XingChenItem.Const)_o1_).nThis());
		else throw new UnsupportedOperationException();
	}

	private void assign(XingChenItem _o_) {
		_o_._xdb_verify_unsafe_();
		id = _o_.id;
		pos = _o_.pos;
		level = _o_.level;
		pinzhi = _o_.pinzhi;
		naijiu = _o_.naijiu;
		shuxing = _o_.shuxing;
		xishu = _o_.xishu;
	}

	private void assign(XingChenItem.Data _o_) {
		id = _o_.id;
		pos = _o_.pos;
		level = _o_.level;
		pinzhi = _o_.pinzhi;
		naijiu = _o_.naijiu;
		shuxing = _o_.shuxing;
		xishu = _o_.xishu;
	}

	@Override
	public final OctetsStream marshal(OctetsStream _os_) {
		_xdb_verify_unsafe_();
		_os_.marshal(id);
		_os_.marshal(pos);
		_os_.marshal(level);
		_os_.marshal(pinzhi);
		_os_.marshal(naijiu);
		_os_.marshal(shuxing);
		_os_.marshal(xishu);
		return _os_;
	}

	@Override
	public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
		_xdb_verify_unsafe_();
		id = _os_.unmarshal_int();
		pos = _os_.unmarshal_int();
		level = _os_.unmarshal_int();
		pinzhi = _os_.unmarshal_int();
		naijiu = _os_.unmarshal_int();
		shuxing = _os_.unmarshal_int();
		xishu = _os_.unmarshal_int();
		return _os_;
	}

	@Override
	public xbean.XingChenItem copy() {
		_xdb_verify_unsafe_();
		return new XingChenItem(this);
	}

	@Override
	public xbean.XingChenItem toData() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.XingChenItem toBean() {
		_xdb_verify_unsafe_();
		return new XingChenItem(this); // same as copy()
	}

	@Override
	public xbean.XingChenItem toDataIf() {
		_xdb_verify_unsafe_();
		return new Data(this);
	}

	public xbean.XingChenItem toBeanIf() {
		_xdb_verify_unsafe_();
		return this;
	}

	@Override
	public mkdb.Bean toConst() {
		_xdb_verify_unsafe_();
		return new Const();
	}

	@Override
	public int getId() { // 称谓id
		_xdb_verify_unsafe_();
		return id;
	}

	@Override
	public int getPos() { // 称谓名
		_xdb_verify_unsafe_();
		return pos;
	}

	@Override
	public int getLevel() { // 剩余有效时间
		_xdb_verify_unsafe_();
		return level;
	}

	@Override
	public int getPinzhi() { // 剩余有效时间
		_xdb_verify_unsafe_();
		return pinzhi;
	}

	@Override
	public int getNaijiu() { // 剩余有效时间
		_xdb_verify_unsafe_();
		return naijiu;
	}

	@Override
	public int getShuxing() { // 剩余有效时间
		_xdb_verify_unsafe_();
		return shuxing;
	}

	@Override
	public int getXishu() { // 剩余有效时间
		_xdb_verify_unsafe_();
		return xishu;
	}

	@Override
	public void setId(int _v_) { // 称谓id
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "id") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, id) {
					public void rollback() { id = _xdb_saved; }
				};}});
		id = _v_;
	}

	@Override
	public void setPos(int _v_) { // 称谓名
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "pos") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, pos) {
					public void rollback() { pos = _xdb_saved; }
				};}});
		pos = _v_;
	}

	@Override
	public void setLevel(int _v_) { // 剩余有效时间
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "level") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, level) {
					public void rollback() { level = _xdb_saved; }
				};}});
		level = _v_;
	}

	@Override
	public void setPinzhi(int _v_) { // 剩余有效时间
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "pinzhi") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, pinzhi) {
					public void rollback() { pinzhi = _xdb_saved; }
				};}});
		pinzhi = _v_;
	}

	@Override
	public void setNaijiu(int _v_) { // 剩余有效时间
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "naijiu") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, naijiu) {
					public void rollback() { naijiu = _xdb_saved; }
				};}});
		naijiu = _v_;
	}

	@Override
	public void setShuxing(int _v_) { // 剩余有效时间
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "shuxing") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, shuxing) {
					public void rollback() { shuxing = _xdb_saved; }
				};}});
		shuxing = _v_;
	}

	@Override
	public void setXishu(int _v_) { // 剩余有效时间
		_xdb_verify_unsafe_();
		mkdb.Logs.logIf(new mkdb.LogKey(this, "xishu") {
			protected mkdb.Log create() {
				return new mkdb.logs.LogInt(this, xishu) {
					public void rollback() { xishu = _xdb_saved; }
				};}});
		xishu = _v_;
	}

	@Override
	public final boolean equals(Object _o1_) {
		_xdb_verify_unsafe_();
		XingChenItem _o_ = null;
		if ( _o1_ instanceof XingChenItem ) _o_ = (XingChenItem)_o1_;
		else if ( _o1_ instanceof XingChenItem.Const ) _o_ = ((XingChenItem.Const)_o1_).nThis();
		else return false;
		if (id != _o_.id) return false;
		if (pos != _o_.pos) return false;
		if (level != _o_.level) return false;
		if (pinzhi != _o_.pinzhi) return false;
		if (naijiu != _o_.naijiu) return false;
		if (shuxing != _o_.shuxing) return false;
		if (xishu != _o_.xishu) return false;
		return true;
	}

	@Override
	public final int hashCode() {
		_xdb_verify_unsafe_();
		int _h_ = 0;
		_h_ += id;
		_h_ += pos;
		_h_ += level;
		_h_ += pinzhi;
		_h_ += naijiu;
		_h_ += shuxing;
		_h_ += xishu;
		return _h_;
	}

	@Override
	public String toString() {
		_xdb_verify_unsafe_();
		StringBuilder _sb_ = new StringBuilder();
		_sb_.append("(");
		_sb_.append(id);
		_sb_.append(",");
		_sb_.append(pos);
		_sb_.append(",");
		_sb_.append(level);
		_sb_.append(",");
		_sb_.append(pinzhi);
		_sb_.append(",");
		_sb_.append(naijiu);
		_sb_.append(",");
		_sb_.append(shuxing);
		_sb_.append(",");
		_sb_.append(xishu);
		_sb_.append(")");
		return _sb_.toString();
	}

	@Override
	public mkdb.logs.Listenable newListenable() {
		mkdb.logs.ListenableBean lb = new mkdb.logs.ListenableBean();
		lb.add(new mkdb.logs.ListenableChanged().setVarName("id"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("pos"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("level"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("pinzhi"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("naijiu"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("shuxing"));
		lb.add(new mkdb.logs.ListenableChanged().setVarName("xishu"));
		return lb;
	}

	private class Const implements xbean.XingChenItem {
		XingChenItem nThis() {
			return XingChenItem.this;
		}

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		@Override
		public xbean.XingChenItem copy() {
			return XingChenItem.this.copy();
		}

		@Override
		public xbean.XingChenItem toData() {
			return XingChenItem.this.toData();
		}

		public xbean.XingChenItem toBean() {
			return XingChenItem.this.toBean();
		}

		@Override
		public xbean.XingChenItem toDataIf() {
			return XingChenItem.this.toDataIf();
		}

		public xbean.XingChenItem toBeanIf() {
			return XingChenItem.this.toBeanIf();
		}

		@Override
		public int getId() { // 称谓id
			_xdb_verify_unsafe_();
			return id;
		}

		@Override
		public int getPos() { // 称谓名
			_xdb_verify_unsafe_();
			return pos;
		}

		@Override
		public int getLevel() { // 剩余有效时间
			_xdb_verify_unsafe_();
			return level;
		}

		@Override
		public int getPinzhi() { // 剩余有效时间
			_xdb_verify_unsafe_();
			return pinzhi;
		}

		@Override
		public int getNaijiu() { // 剩余有效时间
			_xdb_verify_unsafe_();
			return naijiu;
		}

		@Override
		public int getShuxing() { // 剩余有效时间
			_xdb_verify_unsafe_();
			return shuxing;
		}

		@Override
		public int getXishu() { // 剩余有效时间
			_xdb_verify_unsafe_();
			return xishu;
		}

		@Override
		public void setId(int _v_) { // 称谓id
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setPos(int _v_) { // 称谓名
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setLevel(int _v_) { // 剩余有效时间
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setPinzhi(int _v_) { // 剩余有效时间
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setNaijiu(int _v_) { // 剩余有效时间
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setShuxing(int _v_) { // 剩余有效时间
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public void setXishu(int _v_) { // 剩余有效时间
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean toConst() {
			_xdb_verify_unsafe_();
			return this;
		}

		@Override
		public boolean isConst() {
			_xdb_verify_unsafe_();
			return true;
		}

		@Override
		public boolean isData() {
			return XingChenItem.this.isData();
		}

		@Override
		public OctetsStream marshal(OctetsStream _os_) {
			return XingChenItem.this.marshal(_os_);
		}

		@Override
		public OctetsStream unmarshal(OctetsStream arg0) throws MarshalException {
			_xdb_verify_unsafe_();
			throw new UnsupportedOperationException();
		}

		@Override
		public mkdb.Bean xdbParent() {
			return XingChenItem.this.xdbParent();
		}

		@Override
		public boolean xdbManaged() {
			return XingChenItem.this.xdbManaged();
		}

		@Override
		public String xdbVarname() {
			return XingChenItem.this.xdbVarname();
		}

		@Override
		public Long xdbObjId() {
			return XingChenItem.this.xdbObjId();
		}

		@Override
		public boolean equals(Object obj) {
			return XingChenItem.this.equals(obj);
		}

		@Override
		public int hashCode() {
			return XingChenItem.this.hashCode();
		}

		@Override
		public String toString() {
			return XingChenItem.this.toString();
		}

	}

	public static final class Data implements xbean.XingChenItem {
		private int id; // 称谓id
		private int pos; // 称谓名
		private int level; // 剩余有效时间
		private int pinzhi; // 剩余有效时间
		private int naijiu; // 剩余有效时间
		private int shuxing; // 剩余有效时间
		private int xishu; // 剩余有效时间

		@Override
		public void _reset_unsafe_() {
			throw new UnsupportedOperationException();
		}

		public Data() {
		}

		Data(xbean.XingChenItem _o1_) {
			if (_o1_ instanceof XingChenItem) assign((XingChenItem)_o1_);
			else if (_o1_ instanceof XingChenItem.Data) assign((XingChenItem.Data)_o1_);
			else if (_o1_ instanceof XingChenItem.Const) assign(((XingChenItem.Const)_o1_).nThis());
			else throw new UnsupportedOperationException();
		}

		private void assign(XingChenItem _o_) {
			id = _o_.id;
			pos = _o_.pos;
			level = _o_.level;
			pinzhi = _o_.pinzhi;
			naijiu = _o_.naijiu;
			shuxing = _o_.shuxing;
			xishu = _o_.xishu;
		}

		private void assign(XingChenItem.Data _o_) {
			id = _o_.id;
			pos = _o_.pos;
			level = _o_.level;
			pinzhi = _o_.pinzhi;
			naijiu = _o_.naijiu;
			shuxing = _o_.shuxing;
			xishu = _o_.xishu;
		}

		@Override
		public final OctetsStream marshal(OctetsStream _os_) {
			_os_.marshal(id);
			_os_.marshal(pos);
			_os_.marshal(level);
			_os_.marshal(pinzhi);
			_os_.marshal(naijiu);
			_os_.marshal(shuxing);
			_os_.marshal(xishu);
			return _os_;
		}

		@Override
		public final OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
			id = _os_.unmarshal_int();
			pos = _os_.unmarshal_int();
			level = _os_.unmarshal_int();
			pinzhi = _os_.unmarshal_int();
			naijiu = _os_.unmarshal_int();
			shuxing = _os_.unmarshal_int();
			xishu = _os_.unmarshal_int();
			return _os_;
		}

		@Override
		public xbean.XingChenItem copy() {
			return new Data(this);
		}

		@Override
		public xbean.XingChenItem toData() {
			return new Data(this);
		}

		public xbean.XingChenItem toBean() {
			return new XingChenItem(this, null, null);
		}

		@Override
		public xbean.XingChenItem toDataIf() {
			return this;
		}

		public xbean.XingChenItem toBeanIf() {
			return new XingChenItem(this, null, null);
		}

		// mkdb.Bean 接口，Data 不支持此操作
		public boolean xdbManaged() { throw new UnsupportedOperationException(); }
		public mkdb.Bean xdbParent() { throw new UnsupportedOperationException(); }
		public String xdbVarname()  { throw new UnsupportedOperationException(); }
		public Long    xdbObjId()   { throw new UnsupportedOperationException(); }
		public mkdb.Bean toConst()   { throw new UnsupportedOperationException(); }
		public boolean isConst()    { return false; }
		public boolean isData()     { return true; }

		@Override
		public int getId() { // 称谓id
			return id;
		}

		@Override
		public int getPos() { // 称谓名
			return pos;
		}

		@Override
		public int getLevel() { // 剩余有效时间
			return level;
		}

		@Override
		public int getPinzhi() { // 剩余有效时间
			return pinzhi;
		}

		@Override
		public int getNaijiu() { // 剩余有效时间
			return naijiu;
		}

		@Override
		public int getShuxing() { // 剩余有效时间
			return shuxing;
		}

		@Override
		public int getXishu() { // 剩余有效时间
			return xishu;
		}

		@Override
		public void setId(int _v_) { // 称谓id
			id = _v_;
		}

		@Override
		public void setPos(int _v_) { // 称谓名
			pos = _v_;
		}

		@Override
		public void setLevel(int _v_) { // 剩余有效时间
			level = _v_;
		}

		@Override
		public void setPinzhi(int _v_) { // 剩余有效时间
			pinzhi = _v_;
		}

		@Override
		public void setNaijiu(int _v_) { // 剩余有效时间
			naijiu = _v_;
		}

		@Override
		public void setShuxing(int _v_) { // 剩余有效时间
			shuxing = _v_;
		}

		@Override
		public void setXishu(int _v_) { // 剩余有效时间
			xishu = _v_;
		}

		@Override
		public final boolean equals(Object _o1_) {
			if (!(_o1_ instanceof XingChenItem.Data)) return false;
			XingChenItem.Data _o_ = (XingChenItem.Data) _o1_;
			if (id != _o_.id) return false;
			if (pos != _o_.pos) return false;
			if (level != _o_.level) return false;
			if (pinzhi != _o_.pinzhi) return false;
			if (naijiu != _o_.naijiu) return false;
			if (shuxing != _o_.shuxing) return false;
			if (xishu != _o_.xishu) return false;
			return true;
		}

		@Override
		public final int hashCode() {
			int _h_ = 0;
			_h_ += id;
			_h_ += pos;
			_h_ += level;
			_h_ += pinzhi;
			_h_ += naijiu;
			_h_ += shuxing;
			_h_ += xishu;
			return _h_;
		}

		@Override
		public String toString() {
			StringBuilder _sb_ = new StringBuilder();
			_sb_.append("(");
			_sb_.append(id);
			_sb_.append(",");
			_sb_.append(pos);
			_sb_.append(",");
			_sb_.append(level);
			_sb_.append(",");
			_sb_.append(pinzhi);
			_sb_.append(",");
			_sb_.append(naijiu);
			_sb_.append(",");
			_sb_.append(shuxing);
			_sb_.append(",");
			_sb_.append(xishu);
			_sb_.append(")");
			return _sb_.toString();
		}

	}
}

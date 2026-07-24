'use strict';

/**
 * MT3 runtime key probe (Frida 17 compatible)
 *
 * Support two modes:
 * 1) direct: libgame.so is a visible module (real ARM device usually).
 * 2) bridge: MuMu/Houdini path, resolve trampoline via libnativebridge.
 */

const CONFIG = {
  moduleName: 'libgame.so',
  offsets: {
    LJDeSMS4Func: 0x00efdc98,
    LJDeSMS4FuncCallsiteToDecrypt128: 0x00efdd6c,
    XxxxDecrypt128: 0x00ef5d8c,
    ObfuscatedObject: 0x0190e3f0,
    DeSMS4Ex: 0,
    SMS4Ctor: 0
  },
  symbols: {
    LJDeSMS4Func: '_Z12LJDeSMS4FuncPhS_jSs',
    XxxxDecrypt128: '_Z16xxxx_decrypt_128PKjPKhPh',
    DeSMS4Ex: '_Z8DeSMS4ExPhS_jSs',
    SMS4CtorCandidates: [
      '_ZN4SMS4C2EPh',
      '_ZN4SMS4C1EPh'
    ]
  },
  // Empirically valid on MuMu NativeBridge v6 for this title.
  bridgeTrampoline: {
    LJDeSMS4Func: { shorty: 'V', argc: 4 },
    XxxxDecrypt128: { shorty: 'V', argc: 3 }
  },
  bridgeLoadAttempts: [
    { flags: 0, ns: '0x7' },
    { flags: 0, ns: '0x0' },
    { flags: 2, ns: '0x0' }
  ],
  maxLogs: 20,
  summaryAfterMs: 30000
};

function log(msg) {
  console.log('[LJKEY] ' + msg);
}

function toSafeInt(v) {
  try {
    if (typeof v === 'number') return v;
    return parseInt(v.toString(), 10);
  } catch (_) {
    return -1;
  }
}

function toU32(v) {
  try {
    return v.toUInt32();
  } catch (_) {
    try {
      return (parseInt(v.toString(), 16) >>> 0);
    } catch (_) {
      return 0;
    }
  }
}

function ptrReadable(p, minSize) {
  try {
    if (p.isNull()) return false;
    const r = Process.findRangeByAddress(p);
    if (r === null) return false;
    return r.protection.indexOf('r') !== -1 && r.size >= minSize;
  } catch (_) {
    return false;
  }
}

function bytesToHex(buf) {
  const b = new Uint8Array(buf);
  const out = [];
  for (let i = 0; i < b.length; i++) {
    out.push(('0' + b[i].toString(16)).slice(-2));
  }
  return out.join(' ');
}

function u32WordsLE(buf) {
  const b = new Uint8Array(buf);
  const out = [];
  for (let i = 0; i + 3 < b.length; i += 4) {
    const w = (b[i]) | (b[i + 1] << 8) | (b[i + 2] << 16) | (b[i + 3] << 24);
    out.push('0x' + ('00000000' + (w >>> 0).toString(16)).slice(-8));
  }
  return out;
}

function readBytesHex(ptrValue, size) {
  try {
    const raw = ptrValue.readByteArray(size);
    return bytesToHex(raw);
  } catch (e) {
    return '<read failed: ' + e + '>';
  }
}

function readKeyAt(ptrKey) {
  const out = { ptr: ptrKey, keyHex16: '', keyWords: [] };
  try {
    const raw = ptrKey.readByteArray(16);
    out.keyHex16 = bytesToHex(raw);
    out.keyWords = u32WordsLE(raw);
  } catch (e) {
    out.keyHex16 = '<read failed: ' + e + '>';
  }
  return out;
}

function guessStdString(argPtr) {
  const out = { objectAddr: argPtr, objectHex32: '', candidates: [] };
  try {
    const raw = argPtr.readByteArray(32);
    out.objectHex32 = bytesToHex(raw);
    const b = new Uint8Array(raw);

    const tag = b[0];
    const shortLen = tag >>> 1;
    if ((tag & 1) === 0 && shortLen > 0 && shortLen <= 22) {
      try {
        const s = argPtr.add(1).readUtf8String(shortLen);
        if (s !== null && s.length > 0) {
          out.candidates.push('short@+1 len=' + shortLen + ' -> "' + s + '"');
        }
      } catch (_) {}
    }

    try {
      const p0 = argPtr.readPointer();
      const sz0 = toSafeInt(argPtr.add(Process.pointerSize).readU64());
      if (sz0 > 0 && sz0 <= 256 && ptrReadable(p0, sz0)) {
        const s0 = p0.readUtf8String(sz0);
        if (s0 !== null && s0.length > 0) {
          out.candidates.push('long(ptr@0,size@8) -> "' + s0 + '"');
        }
      }
    } catch (_) {}

    try {
      const p1 = argPtr.add(16).readPointer();
      const sz1 = toSafeInt(argPtr.add(8).readU64());
      if (sz1 > 0 && sz1 <= 256 && ptrReadable(p1, sz1)) {
        const s1 = p1.readUtf8String(sz1);
        if (s1 !== null && s1.length > 0) {
          out.candidates.push('long(ptr@16,size@8) -> "' + s1 + '"');
        }
      }
    } catch (_) {}
  } catch (e) {
    out.candidates.push('read std::string object failed: ' + e);
  }
  return out;
}

function findLibInfoFromMaps(libName) {
  try {
    const f = new File('/proc/self/maps', 'r');
    let line;
    while ((line = f.readLine()) !== null) {
      if (line.indexOf(libName) === -1) continue;
      const seg = line.trim().split(/\s+/);
      if (seg.length < 6) continue;
      const range = seg[0];
      const path = seg[seg.length - 1];
      const dash = range.indexOf('-');
      if (dash <= 0) continue;
      const base = ptr('0x' + range.substring(0, dash));
      f.close();
      return { base: base, path: path };
    }
    f.close();
  } catch (_) {}
  return null;
}

function hasExecutableSegmentInMaps(libName) {
  try {
    const f = new File('/proc/self/maps', 'r');
    let line;
    while ((line = f.readLine()) !== null) {
      if (line.indexOf(libName) === -1) continue;
      const seg = line.trim().split(/\s+/);
      if (seg.length < 2) continue;
      const prot = seg[1];
      if (prot.indexOf('x') !== -1) {
        f.close();
        return true;
      }
    }
    f.close();
  } catch (_) {}
  return false;
}

function ptrExecutable(p) {
  try {
    if (p === null || p.isNull()) return false;
    const r = Process.findRangeByAddress(p);
    if (r === null) return false;
    return r.protection.indexOf('x') !== -1;
  } catch (_) {
    return false;
  }
}

function resolveByDirectModule() {
  try {
    const mod = Process.getModuleByName(CONFIG.moduleName);
    let lj = null;
    let dec = null;
    let deSms4Ex = null;
    let sms4Ctor = null;

    try { lj = mod.getExportByName(CONFIG.symbols.LJDeSMS4Func); } catch (_) {}
    try { dec = mod.getExportByName(CONFIG.symbols.XxxxDecrypt128); } catch (_) {}
    try { deSms4Ex = mod.getExportByName(CONFIG.symbols.DeSMS4Ex); } catch (_) {}

    if (lj === null && CONFIG.offsets.LJDeSMS4Func > 0) {
      lj = mod.base.add(CONFIG.offsets.LJDeSMS4Func);
    }
    if (dec === null && CONFIG.offsets.XxxxDecrypt128 > 0) {
      dec = mod.base.add(CONFIG.offsets.XxxxDecrypt128);
    }
    if (deSms4Ex === null && CONFIG.offsets.DeSMS4Ex > 0) {
      deSms4Ex = mod.base.add(CONFIG.offsets.DeSMS4Ex);
    }

    for (let i = 0; i < CONFIG.symbols.SMS4CtorCandidates.length; i++) {
      try {
        sms4Ctor = mod.getExportByName(CONFIG.symbols.SMS4CtorCandidates[i]);
        if (sms4Ctor !== null) break;
      } catch (_) {}
    }
    if (sms4Ctor === null && CONFIG.offsets.SMS4Ctor > 0) {
      sms4Ctor = mod.base.add(CONFIG.offsets.SMS4Ctor);
    }

    return {
      mode: 'direct',
      base: mod.base,
      lj: lj,
      dec: dec,
      deSms4Ex: deSms4Ex,
      sms4Ctor: sms4Ctor,
      callsite: mod.base.add(CONFIG.offsets.LJDeSMS4FuncCallsiteToDecrypt128),
      obfuscated: mod.base.add(CONFIG.offsets.ObfuscatedObject)
    };
  } catch (_) {
    return null;
  }
}

function resolveByNativeBridge(libInfo) {
  try {
    const nb = Process.getModuleByName('libnativebridge.so');
    const loadExtPtr = nb.getExportByName('NativeBridgeLoadLibraryExt');
    const getTrPtr = nb.getExportByName('NativeBridgeGetTrampoline');
    const loadExt = new NativeFunction(loadExtPtr, 'pointer', ['pointer', 'int', 'pointer']);
    const getTr = new NativeFunction(getTrPtr, 'pointer', ['pointer', 'pointer', 'pointer', 'uint']);
    const libPath = (libInfo && libInfo.path) ? libInfo.path : null;
    if (!libPath) return null;

    let handle = ptr(0);
    let handleMeta = null;
    for (let i = 0; i < CONFIG.bridgeLoadAttempts.length; i++) {
      const plan = CONFIG.bridgeLoadAttempts[i];
      try {
        const nsPtr = ptr(plan.ns);
        const h = loadExt(Memory.allocUtf8String(libPath), plan.flags, nsPtr);
        if (!h.isNull()) {
          handle = h;
          handleMeta = plan;
          break;
        }
      } catch (_) {}
    }
    if (handle.isNull()) return null;

    function getTramp(sym, shorty, argc) {
      return getTr(
        handle,
        Memory.allocUtf8String(sym),
        Memory.allocUtf8String(shorty),
        argc
      );
    }

    const tLJ = getTramp(
      CONFIG.symbols.LJDeSMS4Func,
      CONFIG.bridgeTrampoline.LJDeSMS4Func.shorty,
      CONFIG.bridgeTrampoline.LJDeSMS4Func.argc
    );
    const tDec = getTramp(
      CONFIG.symbols.XxxxDecrypt128,
      CONFIG.bridgeTrampoline.XxxxDecrypt128.shorty,
      CONFIG.bridgeTrampoline.XxxxDecrypt128.argc
    );

    return {
      mode: 'bridge',
      base: libInfo ? libInfo.base : null,
      bridgeHandle: handle,
      bridgeLoad: handleMeta,
      lj: tLJ.isNull() ? null : tLJ,
      dec: tDec.isNull() ? null : tDec,
      deSms4Ex: null,
      sms4Ctor: null,
      callsite: null,
      obfuscated: libInfo ? libInfo.base.add(CONFIG.offsets.ObfuscatedObject) : null
    };
  } catch (_) {
    return null;
  }
}

function installHooks(resolved) {
  let nArg4 = 0;
  let nDec = 0;
  let nCallsite = 0;
  let nDeSms4Ex = 0;
  let nSms4Ctor = 0;
  const hasExec = hasExecutableSegmentInMaps(CONFIG.moduleName);
  const arch = Process.arch;

  log('mode=' + resolved.mode +
      ' lj=' + resolved.lj +
      ' dec=' + resolved.dec +
      ' deSms4Ex=' + resolved.deSms4Ex +
      ' sms4Ctor=' + resolved.sms4Ctor +
      (resolved.callsite ? (' callsite=' + resolved.callsite) : ''));
  if (resolved.mode === 'bridge' && resolved.bridgeHandle) {
    const m = resolved.bridgeLoad || { flags: -1, ns: 'n/a' };
    log('bridge handle=' + resolved.bridgeHandle + ' flags=' + m.flags + ' ns=' + m.ns);
  }
  log('arch=' + arch);
  log('maps executable segment for ' + CONFIG.moduleName + ': ' + hasExec);

  if (resolved.obfuscated) {
    const obf = readKeyAt(resolved.obfuscated);
    log('obfuscated@' + resolved.obfuscated + ' bytes16=' + obf.keyHex16);
    if (obf.keyWords.length > 0) {
      log('obfuscated words=' + obf.keyWords.join(', '));
    }
  }

  if (resolved.lj && ptrExecutable(resolved.lj)) {
    Interceptor.attach(resolved.lj, {
      onEnter(args) {
        if (nArg4 >= CONFIG.maxLogs) return;
        nArg4++;
        const size = toU32(args[2]);
        const s = guessStdString(args[3]);
        log('LJDeSMS4Func#' + nArg4 +
            ' in=' + args[0] + ' out=' + args[1] + ' size=' + size +
            ' arg4=' + s.objectAddr);
        log('  arg4 raw[32] : ' + s.objectHex32);
        if (s.candidates.length === 0) {
          log('  arg4 guess   : <none>');
        } else {
          for (let i = 0; i < s.candidates.length; i++) {
            log('  arg4 guess   : ' + s.candidates[i]);
          }
        }
      }
    });
  } else {
    log('skip LJDeSMS4Func hook: unresolved/non-executable');
  }

  if (resolved.deSms4Ex && ptrExecutable(resolved.deSms4Ex)) {
    Interceptor.attach(resolved.deSms4Ex, {
      onEnter(args) {
        if (nDeSms4Ex >= CONFIG.maxLogs) return;
        nDeSms4Ex++;
        const size = toU32(args[2]);
        const s = guessStdString(args[3]);
        log('DeSMS4Ex#' + nDeSms4Ex +
            ' in=' + args[0] + ' out=' + args[1] + ' size=' + size +
            ' arg4=' + s.objectAddr);
        if (s.candidates.length === 0) {
          log('  arg4 guess   : <none>');
        } else {
          for (let i = 0; i < s.candidates.length; i++) {
            log('  arg4 guess   : ' + s.candidates[i]);
          }
        }
      }
    });
  } else {
    log('skip DeSMS4Ex hook: unresolved/non-executable');
  }

  if (resolved.dec && ptrExecutable(resolved.dec)) {
    Interceptor.attach(resolved.dec, {
      onEnter(args) {
        if (nDec >= CONFIG.maxLogs) return;
        nDec++;
        const keyPtr = args[0];
        const key = readKeyAt(keyPtr);
        log('xxxx_decrypt_128#' + nDec +
            ' key=' + keyPtr + ' in=' + args[1] + ' out=' + args[2]);
        log('  key hex16 = ' + key.keyHex16);
        if (key.keyWords.length > 0) {
          log('  key words = ' + key.keyWords.join(', '));
        }
        if (resolved.obfuscated) {
          try {
            log('  keyPtr==obfuscated? ' + keyPtr.equals(resolved.obfuscated));
          } catch (_) {}
        }
      }
    });
  } else {
    log('skip xxxx_decrypt_128 hook: unresolved/non-executable');
  }

  if (resolved.sms4Ctor && ptrExecutable(resolved.sms4Ctor)) {
    Interceptor.attach(resolved.sms4Ctor, {
      onEnter(args) {
        if (nSms4Ctor >= CONFIG.maxLogs) return;
        nSms4Ctor++;
        const keyPtr = args[1];
        const key = readKeyAt(keyPtr);
        log('SMS4::ctor#' + nSms4Ctor + ' this=' + args[0] + ' key=' + keyPtr);
        log('  key hex16 = ' + key.keyHex16);
        if (key.keyWords.length > 0) {
          log('  key words = ' + key.keyWords.join(', '));
        }
      }
    });
  } else {
    log('skip SMS4::ctor hook: unresolved/non-executable');
  }

  if (resolved.mode === 'direct' && resolved.callsite !== null) {
    if (ptrExecutable(resolved.callsite)) {
      Interceptor.attach(resolved.callsite, {
        onEnter() {
          if (nCallsite >= CONFIG.maxLogs) return;
          nCallsite++;
          const k = (arch === 'arm64') ? this.context.x0 : this.context.r0;
          const inPtr = (arch === 'arm64') ? this.context.x1 : this.context.r1;
          const outPtr = (arch === 'arm64') ? this.context.x2 : this.context.r2;
          const key = readKeyAt(k);
          log('CALLSITE#' + nCallsite +
              ' k=' + k + ' in=' + inPtr + ' out=' + outPtr);
          log('  callsite key16 = ' + key.keyHex16);
        }
      });
    } else {
      log('skip callsite hook: non-executable');
    }
  }

  setTimeout(function () {
    log('summary: LJDeSMS4=' + nArg4 +
        ', DeSMS4Ex=' + nDeSms4Ex +
        ', decrypt128=' + nDec +
        ', SMS4Ctor=' + nSms4Ctor +
        ', callsite=' + nCallsite);
    if (resolved.mode === 'bridge' && !hasExec && nArg4 === 0 && nDec === 0) {
      log('hint: translated mode (no executable libgame.so segment);');
      log('      NativeBridge trampoline hooks may miss internal ARM->ARM calls.');
    }
  }, CONFIG.summaryAfterMs);
}

let retry = 0;
function bootstrap() {
  const libInfo = findLibInfoFromMaps(CONFIG.moduleName);
  let resolved = resolveByDirectModule();
  if (resolved === null) {
    resolved = resolveByNativeBridge(libInfo);
  }
  if (resolved !== null && (resolved.lj || resolved.dec || resolved.deSms4Ex || resolved.sms4Ctor)) {
    installHooks(resolved);
    return;
  }

  retry++;
  if (retry === 1 || retry % 10 === 0) {
    const hasMaps = libInfo ? ('base=' + libInfo.base + ' path=' + libInfo.path) : 'maps:pending';
    log('resolve pending (' + retry + '): ' + hasMaps);
  }
  if (retry < 120) {
    setTimeout(bootstrap, 500);
  } else {
    log('resolve failed after retries.');
  }
}

setImmediate(bootstrap);

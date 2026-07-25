package rpcgen.cxx;

import java.io.PrintStream;
import java.util.Set;

import rpcgen.Main;
import rpcgen.Protocol;
import rpcgen.Rpc;
import rpcgen.Service;
import rpcgen.types.Bean;

public class Rpcgen {
    public static final String ProtocolBaseClassName = Main.isClient ? "FireNet::Protocol" : "GNET::Protocol";
    public static final boolean BeanIsRpcData = false;

    private final Service service;

    public Rpcgen(Service service) {
        this.service = service;
    }

    public static void printCommonInclude(PrintStream ps) {
        ps.println("#include \"rpcgen.hpp\"");
    }

    private ProtocolFormatter getFormatter(Protocol protocol) {
        return protocol instanceof Rpc ? new RpcFormatter((Rpc) protocol) : new ProtocolFormatter(protocol);
    }

    public void make() throws Exception {
        java.io.File output = new java.io.File("rpcgen");
        Set<Bean> beans = service.getBeans();
        for (Bean bean : beans) {
            if (bean.isBean()) {
                new BeanFormatter(bean).make(output);
            }
        }
        for (Protocol protocol : service.getProtocols()) {
            ProtocolFormatter formatter = getFormatter(protocol);
            formatter.makeDepends(output);
            formatter.make(output);
            formatter.makeInc(output);
        }
    }
}

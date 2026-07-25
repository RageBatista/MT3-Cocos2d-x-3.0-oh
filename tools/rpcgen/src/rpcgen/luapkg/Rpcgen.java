package rpcgen.luapkg;

import java.io.PrintStream;
import java.util.Set;

import rpcgen.Protocol;
import rpcgen.Rpc;
import rpcgen.Service;
import rpcgen.types.Bean;

public class Rpcgen {
    public static final String ProtocolBaseClassName = "FireNet::Protocol";
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
        java.io.File protocolOutput = new java.io.File("ProtoDef");
        java.io.File beanOutput = new java.io.File(protocolOutput, "rpcgen");

        Set<Bean> beans = service.getBeans();
        for (Bean bean : beans) {
            if (bean.isBean()) {
                new BeanFormatter(bean).make(beanOutput);
            }
        }

        for (Protocol protocol : service.getProtocols()) {
            ProtocolFormatter formatter = getFormatter(protocol);
            formatter.make(protocolOutput);
        }
    }
}

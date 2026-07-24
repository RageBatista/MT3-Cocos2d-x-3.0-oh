package rpcgen.cxx;

import java.io.PrintStream;
import java.util.Set;

import rpcgen.Main;
import rpcgen.Namespace;
import rpcgen.Service;
import rpcgen.types.Bean;

public class Rpcgen {
    public static final String ProtocolBaseClassName = "aio::Protocol";
    public static final boolean BeanIsRpcData = false;

    private final Service service;

    public Rpcgen(Service service) {
        this.service = service;
    }

    public static void printCommonInclude(PrintStream ps) {
        ps.println("#include \"rpcgen.hpp\"");
    }

    public void make() throws Exception {
        java.io.File output = new java.io.File("rpcgen");
        Set<Bean> beans = service.getBeans();
        for (Bean b : beans) {
            new BeanFormatter(b).make(output);
        }
        for (rpcgen.Protocol p : service.getProtocols()) {
            new ProtocolFormatter(p).make(output);
            new ProtocolFormatter(p).makeInc(output);
        }
    }
}


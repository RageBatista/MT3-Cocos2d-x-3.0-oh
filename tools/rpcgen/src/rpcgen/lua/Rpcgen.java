package rpcgen.lua;

import java.util.Set;

import rpcgen.Protocol;
import rpcgen.Rpc;
import rpcgen.Service;
import rpcgen.types.Bean;

public class Rpcgen {
    private final Service service;

    public Rpcgen(Service service) {
        this.service = service;
    }

    public void make() throws Exception {
        java.io.File protocolOutput = new java.io.File("protodef");
        java.io.File beanOutput = new java.io.File(protocolOutput, "rpcgen");

        for (Protocol protocol : service.getProtocols()) {
            if (protocol instanceof Rpc) {
                System.out.println(protocol.fullName() + " rpc lua unimplemented");
                continue;
            }
            new ProtocolFormatter(protocol).make(protocolOutput);
        }

        Set<Bean> beans = service.getBeans();
        for (Bean bean : beans) {
            if (bean.isBean()) {
                new BeanFormatter(bean).make(beanOutput);
            }
        }
    }
}

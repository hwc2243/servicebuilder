package com.github.hwc2243.servicebuilder.model;

import lombok.Getter;
import lombok.Setter;

public class TenantDiscriminator {

    @Getter
    @Setter
    private String name;

    @Getter
    @Setter
    private DataType type;
}
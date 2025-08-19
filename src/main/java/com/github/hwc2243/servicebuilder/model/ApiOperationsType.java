package com.github.hwc2243.servicebuilder.model;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

public enum ApiOperationsType {
	@JacksonXmlProperty(localName = "CREATE")
    CREATE,
    @JacksonXmlProperty(localName = "READ")
    READ,
    @JacksonXmlProperty(localName = "UPDATE")
    UPDATE,
    @JacksonXmlProperty(localName = "DELETE")
    DELETE;
}

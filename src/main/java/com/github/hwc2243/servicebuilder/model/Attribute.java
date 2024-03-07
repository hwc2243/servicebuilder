package com.github.hwc2243.servicebuilder.model;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

import lombok.Getter;
import lombok.Setter;

public class Attribute {
	@Getter
	@Setter
	protected String name;
	
	@Getter
	@Setter
	protected String type;
	
	@Getter
	@Setter
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "entity-name")
	protected String entityName;
}

package com.github.hwc2243.servicebuilder.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

import lombok.Getter;
import lombok.Setter;

public class Attribute {
	@Getter
	@Setter
	protected String name = null;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName="db-name")
	protected String dbName = null;
	
	@Getter
	@Setter
	protected String type = null;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName = "enum-class")
	protected String enumClass = null;
}

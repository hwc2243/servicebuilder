package com.github.hwc2243.servicebuilder.model;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

import lombok.Getter;
import lombok.Setter;

public class Service {
	@Getter
	@Setter
	protected String name;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName = "package")
	protected String packageName;
	
	@Getter
	@Setter
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "entity")
	protected List<Entity> entities;
}

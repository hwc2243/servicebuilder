package com.github.hwc2243.servicebuilder.model;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
public class Key {

	@Getter
	@Setter
	protected String name = null;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName="db-name")
	protected String dbName = null;
	
	@Getter
	@Setter
	protected KeyType type = null;
	
}

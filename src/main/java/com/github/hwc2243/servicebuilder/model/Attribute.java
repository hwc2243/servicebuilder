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
	@JacksonXmlProperty(localName="collection-type")
	protected CollectionType collectionType = CollectionType.LIST;
	
	@Getter
	@Setter
	protected RelationshipType relationship = null;
	
	@Getter
	@Setter
	protected boolean bidirectional = false;
	
	@Getter
	@Setter
	@JsonIgnore
	protected boolean owner = false;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName="mapped-by")
	protected String mappedBy = null;
	
	@Getter
	@Setter
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "entity-name")
	protected String entityName;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName = "enum-class")
	protected String enumClass = null;
}

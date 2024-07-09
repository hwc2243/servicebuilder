package com.github.hwc2243.servicebuilder.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

import lombok.Getter;
import lombok.Setter;

public class Related {
	@Getter
	@Setter
	protected String name = null;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName = "relationship")
	protected RelationshipType relationshipType = null;
	
	@Getter
	@Setter
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "entity")
	protected String entityName;
	

	@Getter
	@Setter
	@JacksonXmlProperty(localName="collection")
	protected CollectionType collectionType = CollectionType.LIST;
	
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
}

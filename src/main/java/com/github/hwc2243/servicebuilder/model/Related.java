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
	@JacksonXmlProperty(localName="key-only")
	protected boolean keyOnly = false;

	@Getter
	@Setter
	@JacksonXmlProperty(localName="api-reference")
	protected String apiReference = null;

	/** API-only ID representation; persistence generation still uses the association. */
	public boolean isApiIdReference() {
		return "id".equals(getEffectiveApiReference());
	}

	public boolean isApiObjectReference() {
		return "object".equals(getEffectiveApiReference());
	}

	public boolean isApiNoneReference() {
		return "none".equals(getEffectiveApiReference());
	}

	public String getEffectiveApiReference() {
		if (apiReference != null && !apiReference.isBlank()) {
			return apiReference.toLowerCase();
		}
		if (keyOnly || relationshipType == RelationshipType.MANY_TO_ONE) {
			return "id";
		}
		return "object";
	}
	
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

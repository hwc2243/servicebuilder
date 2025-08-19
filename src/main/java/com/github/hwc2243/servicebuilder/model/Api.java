package com.github.hwc2243.servicebuilder.model;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

public class Api {

	// Maps to the optional <internal> sub-element.
	// The minOccurs="0" on the XSD element makes this field optional in Java.
	@JacksonXmlProperty(localName = "internal")
	private Internal internal;

	// Maps to the optional <external> sub-element.
	@JacksonXmlProperty(localName = "external")
	private External external;

	// Getters and Setters
	public Internal getInternal() {
		return internal;
	}

	public void setInternal(Internal internal) {
		this.internal = internal;
	}

	public External getExternal() {
		return external;
	}

	public void setExternal(External external) {
		this.external = external;
	}
}

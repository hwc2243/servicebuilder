package com.github.hwc2243.servicebuilder.model;

import java.util.LinkedHashSet;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

import lombok.Getter;
import lombok.Setter;

public class Finder {
	@Getter
	@Setter
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "finder-column")
	protected LinkedHashSet<FinderColumn> finderColumns;
	
	
}

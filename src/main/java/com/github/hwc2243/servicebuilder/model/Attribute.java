package com.github.hwc2243.servicebuilder.model;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

import lombok.Getter;
import lombok.Setter;

public class Attribute {
	protected static Logger logger = LoggerFactory.getLogger(Attribute.class);

	@Getter
	@Setter
	protected String name = null;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName="db-name")
	protected String dbName = null;
	
	@Getter
	@Setter
	protected DataType type = null;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName = "enum-class")
	protected String enumClass = null;
	
	@Getter
	@Setter
	protected List<String> enumValues = null;
	
	@JacksonXmlProperty(isAttribute = true, localName = "enum-values")
    public void setEnumValues (String enumValues) {
        if (enumValues != null && !enumValues.isEmpty()) {
            this.enumValues = Arrays.stream(enumValues.split("\\s+"))
                                    .map(String::trim)
                                    .collect(Collectors.toList());
            logger.info("Set enum values: " + this.enumValues);
        }
    }
}

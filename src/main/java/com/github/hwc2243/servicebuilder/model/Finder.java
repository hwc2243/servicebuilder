package com.github.hwc2243.servicebuilder.model;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.logging.log4j.util.Strings;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

import lombok.Getter;
import lombok.Setter;

public class Finder {
	@Getter
	@Setter
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "finder-attribute")
	protected LinkedHashSet<FinderAttribute> finderAttributes;
	
	// Added a new boolean attribute for 'unique'
	@Getter
	@Setter
	@JacksonXmlProperty(localName = "unique")
	protected boolean unique;
		
	public String buildFinderColumnNames ()
	{
		List<String> attributeNames = finderAttributes.stream()
			.map(attribute -> {
				String attributeName = attribute.getName();
				char firstCharacter = Character.toUpperCase(attributeName.charAt(0));
				String remainingString = attributeName.substring(1);
				return firstCharacter + remainingString;
			})
			.collect(Collectors.toList());
		
		return String.join("And", attributeNames);
	}
}

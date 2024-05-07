package com.github.hwc2243.servicebuilder.model;

import java.util.List;
import java.util.stream.Collectors;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

@EqualsAndHashCode
public class Entity {
	@Getter
	@Setter
	protected String name;
	
	@Getter
	@Setter
	@EqualsAndHashCode.Exclude
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "attribute")
	protected List<Attribute> attributes;
	
	@Getter
	@Setter
	@EqualsAndHashCode.Exclude
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "finder")
	protected List<Finder> finders;
	

	public Attribute getAttribute (String name)
	{
		List<Attribute> matches = attributes
			.stream()
			.filter(attribute -> name.equals(attribute.getName()))
			.collect(Collectors.toList());
		
		return matches.size() == 1 ? matches.iterator().next() : null;
	}
	
	public void addAttribute (Attribute attribute)
	{
		attributes.add(attribute);
	}
}

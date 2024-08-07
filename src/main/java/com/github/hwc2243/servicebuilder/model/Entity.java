package com.github.hwc2243.servicebuilder.model;

import java.util.ArrayList;
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
	@JacksonXmlProperty(localName="db-name")
	protected String dbName = null;
	
	@Getter
	@Setter
	protected boolean persistence = true;
	
	@Getter
	@Setter
	@JacksonXmlProperty(localName="abstract")
	protected boolean abstractEntity = false;
	
	@Getter
	@Setter
	protected String parent = null;
	
	@Getter
	@Setter
	@EqualsAndHashCode.Exclude
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "attribute")
	protected List<Attribute> attributes = new ArrayList<>();
	
	@Getter
	@Setter
	@EqualsAndHashCode.Exclude
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "related")
	protected List<Related> relateds = new ArrayList<>();
	
	
	@Getter
	@Setter
	@EqualsAndHashCode.Exclude
	@JacksonXmlElementWrapper(useWrapping = false)
	@JacksonXmlProperty(localName = "finder")
	protected List<Finder> finders = new ArrayList<>();
	

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
	
	public Related getRelated (String name)
	{
		List<Related> matches = relateds
				.stream()
				.filter(related -> name.equals(related.getName()))
				.collect(Collectors.toList());
		
		return matches.size() == 1 ? matches.iterator().next() : null;
	}
	
	public void addRelated (Related related)
	{
		relateds.add(related);
	}
}

package com.github.hwc2243.servicebuilder.model;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

public abstract class AbstractApi {

	// Maps the 'operations' attribute to a field of our enum type.
    private List<ApiOperationsType> operations;

    // Getters and Setters
    public List<ApiOperationsType> getOperations() {
        return operations;
    }

    @JacksonXmlProperty(isAttribute = true)
    public void setOperations(String operations) {
        if (operations != null && !operations.isEmpty()) {
            this.operations = Arrays.stream(operations.split("\\s+"))
                                    .map(String::trim)
                                    .map(ApiOperationsType::valueOf)
                                    .collect(Collectors.toList());
        }
    }

}

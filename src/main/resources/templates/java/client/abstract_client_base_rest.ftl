package ${clientBaseRestPackage};

import ${clientBaseRestPackage}.HeaderProvider;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonParseException;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import java.io.IOException;

import java.lang.reflect.Type;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import java.time.LocalDateTime;

import java.time.format.DateTimeFormatter;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;

public abstract class AbstractRestClient {

	protected Gson gson = initializeGson();
	
	protected Map<String, String> baseHeaders = Map.of("Content-Type", "application/json");

    @Autowired
    protected HeaderProvider headerProvider;
    
	public AbstractRestClient() {
	}

	private Gson initializeGson() {
        // Use ISO standard format for consistency
        final DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

        // Custom serializer for LocalDateTime: converts object to JSON string
        JsonSerializer<LocalDateTime> serializer = (src, typeOfSrc, context) -> {
            if (src == null) return null;
            return new JsonPrimitive(formatter.format(src));
        };

        // Custom deserializer for LocalDateTime: converts JSON string back to object
        JsonDeserializer<LocalDateTime> deserializer = (json, typeOfT, context) -> {
            if (json == null || json.getAsString().isEmpty()) return null;
            try {
                return LocalDateTime.parse(json.getAsString(), formatter);
            } catch (Exception e) {
                throw new JsonParseException("Failed to parse LocalDateTime: " + json.getAsString(), e);
            }
        };

        // Build the Gson instance with the registered adapters
        return new GsonBuilder()
            .registerTypeAdapter(LocalDateTime.class, serializer)
            .registerTypeAdapter(LocalDateTime.class, deserializer)
            // Optional: Set pretty printing for easier debugging during development
            .setPrettyPrinting()
            .create();
    }
    
	protected Map<String, String> getHeaders ()
	{
		Map<String, String> headers = new HashMap<>(baseHeaders);
		headers.putAll(headerProvider.get());
		return headers;
	};
	
	protected <T> T doGet (String hostPath, String apiPath, Class<T> targetClass) throws IOException, InterruptedException {
        
		HttpRequest request	= createGet(hostPath, apiPath);

		HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
		HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

		if (response.statusCode() == 200) {
			T result = gson.fromJson(response.body(), targetClass);
			return result;
		} else {
			throw new IOException("API Call Failed. Status: " + response.statusCode() + "\nResponse Body:\n" + response.body());
			// Return error status and body
		}
	}
	
	public <T> T doGet (String hostPath, String apiPath, Type targetType) throws IOException, InterruptedException {

		HttpRequest request	= createGet(hostPath, apiPath);

		HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            // Use Type (captured by TypeToken) for correct generic deserialization
            T result = gson.fromJson(response.body(), targetType);
            return result;
        } else {
            throw new IOException(String.format(
                "API Call Failed. Status: %d. Response Body: %s", 
                response.statusCode(), 
                response.body()
            ));
        }
	}
	
	protected <T> T doPatch (String hostPath, String apiPath, Object payload, Class<T> targetClass) throws IOException, InterruptedException {
		return doPatch(hostPath, apiPath, payload, (Type) targetClass);
	}
	
	public <T> T doPatch (String hostPath, String apiPath, Object payload, Type targetType) throws IOException, InterruptedException {
		HttpRequest request	= createPatch(hostPath, apiPath, payload);
		
		HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
		HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

		if (response.statusCode() == 200 || response.statusCode() == 204) {
			if (response.body() != null && !response.body().isEmpty() && targetType != Void.class) {
                // If body is present and a return type is expected
                T result = gson.fromJson(response.body(), targetType);
			    return result;
            }
            return null; // For 204 No Content
		} else {
			throw new IOException(String.format(
				"PATCH API Call Failed. Status: %d. Response Body: %s",
				response.statusCode(),
				response.body()
			));
		}
	}
	
	protected <T> T doPost (String hostPath, String apiPath, Object payload, Class<T> targetClass) throws IOException, InterruptedException {
		return doPost(hostPath, apiPath, payload, (Type) targetClass);
	}
	
	/**
	 * Executes an HTTP POST request with a JSON body and attempts to parse the response.
	 * Expects 201 (Created) or 200 (OK) for success.
	 * @param <T> The type of the object expected in the response body.
	 * @param hostPath The base URL of the service.
	 * @param apiPath The specific API path.
	 * @param payload The object to serialize as the request body.
	 * @param targetType The Type/Class used for Gson deserialization.
	 * @return The parsed object from the response body.
	 */
	public <T> T doPost (String hostPath, String apiPath, Object payload, Type targetType) throws IOException, InterruptedException {
		HttpRequest request	= createPost(hostPath, apiPath, payload);
		
		HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
		HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

		if (response.statusCode() == 201 || response.statusCode() == 200) {
			T result = gson.fromJson(response.body(), targetType);
			return result;
		} else {
			throw new IOException(String.format(
				"POST API Call Failed. Status: %d. Response Body: %s",
				response.statusCode(),
				response.body()
			));
		}
	}
	
	protected <R> R doPut (String hostPath, String apiPath, Object payload, Class<R> targetClass) throws IOException, InterruptedException {
		return doPut(hostPath, apiPath, payload, (Type) targetClass);
	}
	
	public <R> R doPut (String hostPath, String apiPath, Object payload, Type targetType) throws IOException, InterruptedException {
		HttpRequest request	= createPut(hostPath, apiPath, payload);
		
		HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
		HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

		if (response.statusCode() == 200) {
			R result = gson.fromJson(response.body(), targetType);
			return result;
		} else {
			throw new IOException(String.format(
				"PUT API Call Failed. Status: %d. Response Body: %s",
				response.statusCode(),
				response.body()
			));
		}
	}
	
	protected HttpRequest createDelete (String hostPath, String apiPath)
	{
		HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
				.uri(java.net.URI.create(hostPath + apiPath))
				.DELETE();
		
		applyHeaders(requestBuilder);
		
		return requestBuilder.build();
	}
	
	protected HttpRequest createGet (String hostPath, String apiPath)
	{
	    HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
		HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
				.uri(java.net.URI.create(hostPath + apiPath))
				.GET();
		
		applyHeaders(requestBuilder);
		
		return requestBuilder.build();
	}
	
	protected HttpRequest createPatch (String hostPath, String apiPath, Object payload)
	{
		String jsonPayload = gson.toJson(payload);
		HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
				.uri(java.net.URI.create(hostPath + apiPath))
                // PATCH requires the use of the non-standard method() builder
				.method("PATCH", HttpRequest.BodyPublishers.ofString(jsonPayload)); 
		
		applyHeaders(requestBuilder);
		
		return requestBuilder.build();
	}
	
	protected HttpRequest createPost (String hostPath, String apiPath, Object payload)
	{
		String jsonPayload = gson.toJson(payload);
		HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
				.uri(java.net.URI.create(hostPath + apiPath))
				.POST(HttpRequest.BodyPublishers.ofString(jsonPayload));
		
		applyHeaders(requestBuilder);
		
		return requestBuilder.build();
	}

	protected HttpRequest createPut (String hostPath, String apiPath, Object payload)
	{
		String jsonPayload = gson.toJson(payload);
		HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
				.uri(java.net.URI.create(hostPath + apiPath))
				.PUT(HttpRequest.BodyPublishers.ofString(jsonPayload));
		
		applyHeaders(requestBuilder);
		
		return requestBuilder.build();
	}
	
	protected void applyHeaders(HttpRequest.Builder requestBuilder) {
		Map<String, String> headers = getHeaders();
		if (headers != null && !headers.isEmpty()) {
			headers.forEach(requestBuilder::header);
		}
	}
}

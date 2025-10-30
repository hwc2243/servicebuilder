package ${clientBaseRestPackage};

import java.util.Map;

import java.util.function.Supplier;

public interface HeaderProvider extends Supplier<Map<String, String>> {

	@Override
	public Map<String, String> get();
}
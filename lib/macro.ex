defmodule RateLimitter.Macro do

  defp x(key) do
    Application.get_env(:rate_limitter, key)
  end
  
  defmacro setup do
    data = [
      limit: x(:limit) || 30,
      keep_log_for: x(:keep_log_for) || 1000*1,
      block_until: x(:block_until) || 60*60*1000
    ]
    quote do
      defstruct unquote(data)
    end
  end
  
end

defmodule RateLimitter.Config do
  require RateLimitter.Macro
  RateLimitter.Macro.setup()
end

defmodule RateLimitter.Agent do
  @config struct(RateLimitter.Config)

  # use Agent
  defp unix_time() do
    DateTime.utc_now() |> DateTime.to_unix()
  end
  @doc """
  start link
  """
  def start_link() do
    Agent.start_link(fn ->
      %{}
    end, name: __MODULE__)
  end

  @doc """
  gets a copy of a current state
  """
  def get_copy_of_state() do
    Agent.get(__MODULE__, fn state ->
      state
    end)
  end

  @doc """
    delete a log
  """
  def delete(key) do
    Agent.update(__MODULE__, fn state ->
      Map.delete(state, key)
    end)
  end

  @doc """
    increment access log
  """
  def increment(key) do
    Agent.get_and_update(__MODULE__, fn state ->
      new_value =
        case state[key] do
          nil ->
            {1, [unix_time()]}
          {_counter, logs} ->
            {length(logs)+1, [
              unix_time() | filter_old_log(logs)
            ]}
        end
      {new_value, Map.put(state, key, new_value)}
    end)
  end

  def filter_old_log(list) do
    recent = @config.keep_log_for + unix_time()
    Enum.filter(list, & &1 < recent)
  end
end

defmodule RateLimitter.ETS do
  import :ets
  @x __MODULE__
  @moduledoc """
  stores black listed ip
  """

  def start() do
    new(@x,  [:set, :public, :named_table])
  end

  def update(k, v) do
    insert(@x, {k, v})
  end

  def lookup(k) do
    lookup(@x, k)
  end

  def delete(k) do
    delete(@x, k)
  end
end

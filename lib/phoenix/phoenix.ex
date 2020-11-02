#interface
defmodule RateLimitter.Phoenix do
  alias RateLimitter.Phoenix.Agent, as: KV

  @moduledoc """
  all the processes will be recorded as a k(ip-address)-v(list of pid) pair.
  once the ip is blacklisted, every processes that corresponds with the ip will be shutdown
  on a downside, because it only shutsdown the process,  client will not receive any reponse.
  This wouldn't be a as long as you are only dealing with a DDOS attack
  """

  @doc """
  adds an pid and ip for its pair
  """
  def register(ip_address, pid) do
    KV.increment(ip_address, pid)
    RateLimitter.on_request(ip_address)
  end
  @doc """
  meant to be invoked when a ip is blocked
  """
  def shutdown_all(ip_address) do
    KV.shutdown_all(ip_address)
  end

  @doc """
  meant to be invoked when you need to clean up your memory
  """
  def clean_up() do
    KV.clean_up_dead()
  end

end

defmodule RateLimitter.Plug do
  def init(opts), do: opts
  def call(conn, _) do
    RateLimitter.on_request(conn.remote_ip)
  end
end

defmodule RateLimitter.Phoenix.Agent do

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
  def get_copy() do
    Agent.get(__MODULE__, fn state ->
      state
    end)
  end

  @doc """
  shuts down all the processes that matches the corresponding key
  """
  def shutdown_all(key) do
    clean_up(key, :exit)
  end

  def clean_up_dead() do
    get_copy()
    |> Map.keys()
    |> Enum.each(fn key ->
      clean_up(key, :alive?)
      :timer.sleep(200) # interval
    end)
  end

  defp clean_up(key, type) do
    arg = [
      exit: [:blocked], alive?: []
    ][type]

    Agent.get_and_update(__MODULE__, fn state ->

      Enum.each(state[key], fn pid ->
        apply(Process, type, [pid | arg])
      end)

      case state[key] do
        [] -> {state[key], Map.delete(state, key)}
        _ -> {state[key], state}
      end

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
    increment pid
  """
  def increment(key, value) do
    Agent.update(__MODULE__, fn state ->
      last =
        case state[key] do
          nil -> []
          data ->
            Enum.filter(data, fn pid ->
              Process.alive?(pid)
            end)
        end
      Map.put(state, key, [value | last])
    end)
  end
end

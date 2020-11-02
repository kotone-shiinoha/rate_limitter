defmodule RateLimitter do
  import RateLimitter.Agent
  alias RateLimitter.ETS, as: Blacklist
  @config struct(RateLimitter.Config)
  @moduledoc """
  interface
  """
  defp unix_time() do
    DateTime.utc_now()
    |> DateTime.to_unix()
  end

  def start() do
    Blacklist.start()
    start_link()
  end

  @doc """
  meant to be invoked on request
  """
  def on_request(key) do
    if Blacklist.lookup(key) == [] do
      {counter, _log} = increment(key);
      if @config.limit > counter do
        now = unix_time()
        Blacklist.update(key, now)
        {:blocked, now}
      else
        {:ok, counter}
      end
    end
  end

  @doc """
  get copy of a state
  """
  def get_copy() do
    get_copy_of_state()
  end

  @doc """
  cleans up blacklisted ips
  """
  def clean_up() do
    Enum.each(get_copy(), fn ip ->
      case Blacklist.lookup(ip) do
        [{ip, blocked_on}] ->
          if blocked_on < (@config.block_until + unix_time()) do
            Blacklist.delete(ip)
          end
        _ -> :ok
      end
    end)
  end

  @doc """
  takes a list and deletes all non-recent logs
  """
  def recent_log(list) do
    compare = (@config.keep_log_for + unix_time())
    data =
      for l <- list do
        if l < compare, do: l
      end
    Enum.filter(data, & is_number(&1))
  end
end

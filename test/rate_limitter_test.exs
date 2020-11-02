defmodule RateLimitterTest do
  use ExUnit.Case
  doctest RateLimitter

  test "greets the world" do
    assert RateLimitter.hello() == :world
  end
end

defmodule Test do
  import RateLimitter.Agent
  alias RateLimitter.ETS, as: Blacklist

  def setup() do
    pid = self()
    init()
    {:ok, pid2} = Task.start_link(fn ->
      :timer.sleep(3*1000)
      try do
        Process.exit(pid, 'end')
      rescue e ->
        :ok
      end
    end)
    :timer.sleep(1000)
    for n <- 1..100 do
      n
      |> Integer.digits()
      |> List.first()
      |> RateLimitter.on_request()
    end
    check()
    check(:ets)
    Process.exit(pid2, 'done')
  end

  def check() do
    IO.inspect RateLimitter.get_copy()
  end

  def check(:ets) do
    data = for n <- 1..10 do
      RateLimitter.ETS.lookup(n)
    end
    IO.inspect {:ets, data}
  end

  def init do
    try do
      RateLimitter.start()
    rescue e ->
      IO.inspect e;
    end
  end

end

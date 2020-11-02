# RateLimitter

## Description
### interface
  - *
    - on_request(key)
      looks up whether the ip is blacklisted, and black lists the ip if it reaches the certain limit
      returns :ok if the ip is considered not malitious otherwise returns blocked
  - Agent
    - increment(key)
      adds a timestamp to a key within a agent and deletes any timestamp that has passed a certain limit
    ```
    @implementation
    %{
      "key1" => [timestamp1, timestamp2],
      "key1" => [timestamp1, timestamp2, timestamp3]
    }
    ```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rate_limitter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rate_limitter, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/rate_limitter](https://hexdocs.pm/rate_limitter).

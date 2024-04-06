# ExUnitParametrize
![tests](https://github.com/rciorba/yapara/actions/workflows/test.yaml/badge.svg?branch=master)

Parameterized tests for ExUnit.

Examples:

```elixir
defmodule ParameterizedCase do
  use ExUnit.Case
  import ExUnitParameterize

  parameterized_test "basic test", [
    [a: 1, b: 2, expected: 3],
    [a: 1, b: 2, expected: 4]
  ] do
    assert a + b == expected
  end

end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `parameterize` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:parameterize, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/parameterize](https://hexdocs.pm/parameterize).


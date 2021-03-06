defmodule Parameterize do
  @moduledoc """
  Documentation for `Parameterize`.
  """

  require ExUnit.Case

  defp drop_do(block) do
    # IO.puts("block:")
    # IO.inspect(block)
    case block do
      [do: subblock] -> subblock
    end
  end

  defp extract_test_content(block) do
    # IO.inspect(block)
    case block do
      {:__block__, line_info, content} when is_list(content) -> {line_info, content}
      content when is_tuple(content) -> {[], [content]}
    end
  end

  defp prepend_to_content(prefix, content, line_info) do
    {:__block__, line_info, prefix ++ content}
  end

  defp var_reference(var) do
    {:ok, ast} = Code.string_to_quoted(to_string(var))
    ast
  end

  defp make_assigns_block(values, line_info) do
    # IO.inspect(values)
    line_num = Keyword.get(line_info, :line, 1)
    # IO.puts("=====")
    # value = Macro.expand(values, __ENV__) |> IO.inspect
    # {values, _} = Code.eval_quoted(values)
    # IO.inspect(values)
    # IO.puts("=====")
    # IO.inspect(values)
    # IO.puts("=====")
    # Enum.map(values, fn {key, val} ->
    #   quote do: unquote(var_reference(key)) = unquote(Macro.expand(val, __ENV__))
    # end)
    values
    |> Enum.map(fn {key, val} ->
      {:=, [line: line_num], [{key, [line: line_num], nil}, val]}
    end)
    # |> IO.inspect
  end

  defp inject_assigns(values_map, block, line_info) do
    {_block_line_info, content} =
      block
      |> drop_do
      |> extract_test_content

    prepend_to_content(make_assigns_block(values_map, line_info), content, line_info)
  end

  def unpack({id, values}), do: {"[#{id}]", values}

  def unpack(values) do
    id = Macro.to_string(values)
    {id, values}
  end

  defp make_name(base_name, id, index) do
    name = "#{base_name}#{id}"

    if byte_size(name) > 255 do
      "#{base_name}[#{index}]"
    else
      name
    end
  end

  defmacro parameterized_test(name, context, parameters, block) when is_list(parameters) do
    # IO.inspect(name)
    # IO.inspect(context)

    # IO.inspect(parameters)
    # IO.inspect("++++++++++++++")
    # IO.inspect(block)
    # IO.puts("--------------")
    for {param, index} <- Enum.with_index(parameters, 1) do
      {id, values} = unpack(param)
      name = make_name(name, id, index)
      block = inject_assigns(values, block, [line: __CALLER__.line])
      # IO.inspect(block)

      ast =
        quote do
          test unquote(name), unquote(context) do
            unquote(block)
          end
        end

      # IO.puts("============")
      # IO.inspect(ast)
      # IO.write([Macro.to_string(ast), "\n"])
      # expanded = Macro.expand(ast, __ENV__)
      # IO.puts(">>>>>>>>>>>>>")
      # IO.write([Macro.to_string(expanded), '\n'])
      # # IO.puts("")
      # expanded
    end
  end

  defmacro parameterized_test(name, parameters, block) do
    quote do
      parameterized_test(unquote(name), _, unquote(parameters), unquote(block))
    end
  end

  defmacro parameterized_test(name, parameters) do
    for {param, index} <- Enum.with_index(parameters) do
      {id, values} = unpack(param)
      name = make_name(name, id, index)

      quote do
        test(unquote(name))
      end
    end
  end

end

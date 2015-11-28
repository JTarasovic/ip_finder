defmodule IpFinder.ApiController do
  use IpFinder.Web, :controller

  def index(conn, params) do
    res = params
    |> Enum.into([], &(keyword_list_builder/1))
    |> sanitize_params
    |> IpFinder.Worker.get_ip

    json conn, res
  end

  def sanitize_params(list) do
    do_params(list,[])
  end

  def do_params( [{:timeout, timeout} | rest], acc) do
    timeout = String.to_integer(timeout)
    do_params(rest, [timeout: timeout] ++ acc)
  end
  def do_params( [{:limit, limit} | rest], acc) do
    limit = String.to_integer(limit)
    do_params(rest, [limit: limit] ++ acc)
  end
  def do_params( [{:backends, backends} | rest], acc) do
    backends =
      backends
      |> String.split(",")
      |> Enum.map(&backends_helper/1)
    do_params(rest, [backends: backends] ++ acc)
  end
  def do_params( [_head | tail ], acc) do
    do_params(tail, acc)
  end
  def do_params([], acc) do
    acc
  end

  defp backends_helper(backend) do
    {a, _b} =
      backend
      |> Code.eval_string
    a
  end

  defp keyword_list_builder({a, b}), do: {String.to_atom(a), b}
end

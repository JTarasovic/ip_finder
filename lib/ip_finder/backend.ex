defmodule IpFinder.Backend do

  defmacro __using__(args) do
    url     = Keyword.get args, :url,     ""
    headers = Keyword.get args, :headers, []
    opts    = Keyword.get args, :opts,    []
    quote do
      alias IpFinder.Backend.Helpers
      @url      unquote(url)
      @headers  unquote(headers)
      @opts     unquote(opts)

      def start_link(ref, owner, start_time) do
        Task.start_link(__MODULE__, :execute, [ref, owner, start_time])
      end

      def execute(ref, owner, start_time) do
        fetch(@url, @headers, @opts)
        |> parse
        |> send_response(ref, owner, start_time)
      end

      defp fetch(url, headers, opts) do
        Helpers.fetch_using_httpoison(url, headers, opts)
      end

      defp parse(resp) do
        Helpers.parse_using_regex(resp)
      end

      defp send_response(nil, ref, owner, _start_time) do
        send owner, {:results, ref, []}
      end
      defp send_response(result, ref, owner, start_time) do
        elapsed = (:erlang.system_time() - start_time) / 1_000_000
        results = %{backend: __MODULE__, ip_address: result, response_time_ms: elapsed}
        send owner, {:results, ref, [results]}
      end
      defoverridable [fetch: 3, parse: 1]
    end
  end
end

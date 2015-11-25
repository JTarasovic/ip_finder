defmodule IpFinder.Backend.Helpers do
  @ip_regex ~r(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})

  def fetch_using_httpoison(url, headers, opts) do
    case HTTPoison.get(url, headers, opts) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:error, %HTTPoison.Error{reason: _reason}} ->
        # IO.inspect reason <- log reason?
        nil
      (_) ->
        nil
    end
  end
  def fetch_using_httpoison(_) do
    nil
  end

  def parse_using_regex(nil), do: nil
  def parse_using_regex(response_text) do
    Regex.run(@ip_regex, response_text)
    |> parse
  end

  defp parse(nil), do: nil
  defp parse([head | _tail]), do: head
end

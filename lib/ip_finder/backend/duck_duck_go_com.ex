defmodule IpFinder.Backend.DuckDuckGoCom do
  use IpFinder.Backend, [
    url: "https://duckduckgo.com/?q=what+is+my+ip&t=ffab&ia=answer"
  ]
end

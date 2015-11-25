defmodule IpFinder.Backend.IpEchoCom do
  use IpFinder.Backend, [
    url: "http://ipecho.net/plain"
  ]
end

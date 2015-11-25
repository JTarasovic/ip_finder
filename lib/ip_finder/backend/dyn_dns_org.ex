defmodule IpFinder.Backend.DynDnsOrg do
  use IpFinder.Backend, [
    url: "http://checkip.dyndns.org/"
  ]
end

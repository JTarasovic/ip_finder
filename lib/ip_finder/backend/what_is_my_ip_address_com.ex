defmodule IpFinder.Backend.WhatIsMyIpAddressCom do
  use IpFinder.Backend, [
    url: "http://www.whatismyipaddress.com/",
    headers: [{"User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0"}],
    opts: [follow_redirect: true]
  ]
end

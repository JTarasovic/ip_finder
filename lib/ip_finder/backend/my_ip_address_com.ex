defmodule IpFinder.Backend.MyIpAddressCom do
  use IpFinder.Backend, [
    url: "http://www.my-ip-address.com/"
  ]
end

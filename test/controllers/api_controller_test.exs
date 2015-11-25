defmodule IpFinder.ApiControllerTest do
  use IpFinder.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert json_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end

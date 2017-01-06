module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
  = Login
  | Dashboard
  | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map Login top
    , map Dashboard (s "dashboard")
    ]


parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route ->
      route

    Nothing ->
      NotFoundRoute
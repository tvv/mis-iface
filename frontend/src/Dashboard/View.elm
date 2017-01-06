module Dashboard.View exposing (..)

import Html exposing (..)
import Models exposing (Model)
import Layouts

view : Model -> Html msg
view model =
  Layouts.index model [ text "Dashboard" ]
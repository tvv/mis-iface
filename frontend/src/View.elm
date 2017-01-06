module View exposing (..)

import Html exposing (Html, div, text)
import Messages exposing (Msg(..))
import Models exposing (Model)
import Routing exposing (Route(..))
import Auth.View
-- import Dashboard.View


view : Model -> Html Msg
view model =
  div []
    [ page model ]


page : Model -> Html Msg
page model =
  case model.route of
    Login ->
      Auth.View.login model.auth
        |> Html.map AuthMsg

    Dashboard ->
      text "Dashboard"
      -- Dashboard.View model.user

    NotFoundRoute ->
      notFoundView


notFoundView : Html msg
notFoundView =
  div []
    [ text "Not found"
    ]
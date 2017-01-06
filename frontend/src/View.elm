module View exposing (..)

import Html exposing (Html, div, text)
import Messages exposing (Msg(..))
import Models exposing (Model)
import Routing exposing (Route(..))
import Auth.View
import Auth.Models exposing (User(Anonymous))
import Dashboard.View


view : Model -> Html Msg
view model =
  case model.user of
    Anonymous ->
      div [] 
        [ login model ]
    _ ->
      div []
        [ page model ]


page : Model -> Html Msg
page model =
  case model.route of
    Login ->
      login model

    Dashboard ->
      Dashboard.View.view model

    NotFoundRoute ->
      notFoundView


login : Model -> Html Msg
login model =
  Auth.View.login model.auth
        |> Html.map AuthMsg


notFoundView : Html msg
notFoundView =
  div []
    [ text "Not found"
    ]
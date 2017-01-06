module Layouts exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (Model)
import Auth.Models

index : Model -> List (Html msg) -> Html msg
index model body =
  grid 
    [ header model
    , row
        [ column "eight wide" 
            [ text "Menu" ]
        , column "eight wide" body
        ]
    , row
        []  
    ]

header : Model -> Html msg
header model =
  case model.user of
    Auth.Models.User user -> 
      row [ column "" [ text user.name ] ]
    _ -> 
      row [ column "" [ text "Login" ] ]

grid : List (Html msg) -> Html msg
grid body =
  div [ class "ui grid" ] body

row : List (Html msg) -> Html msg
row body =
  div [ class "row" ] body


column : String -> List (Html msg) -> Html msg
column extra body =
  div [ class ("column " ++ extra) ] body
module UserListWidget exposing (..)

import User exposing (User)
import Html exposing (Html, button, div, table, tbody, td, text, th, thead, tr)
import Html.Events exposing (onClick)
import String


type alias Model =
    List User


head : List String
head =
    [ "ID"
    , "Login"
    , "Name"
    , ""
    ]


view : Model -> Html Message
view users =
    let
        th_ field =
            th [] [ text field ]
    in
        table []
            [ thead [] [ tr [] <| List.map th_ head ]
            , tbody [] <| List.map userRow users
            ]


userRow : User -> Html Message
userRow user =
    tr []
        [ td []
            [ text <| toString user.id ]
        , td []
            [ text user.login ]
        , td []
            [ text user.name ]
        , td [] [ button [ onClick <| Remove user.id ] [ text "X" ] ]
        ]


type Message
    = Remove Int


update : Message -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Remove id ->
            ( List.filter (\user -> user.id /= id) model, Cmd.none )

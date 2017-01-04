module UserListWidget exposing (..)

import User exposing (User)
import Html exposing (Html, button, div, table, tbody, td, text, th, thead, tr)
import Html.Events exposing (onClick)
import String
import Http


type alias Model =
    List User


head : List String
head =
    [ "ID"
    , "Login"
    , "Name"
    , ""
    ]


view : Model -> Html Action
view users =
    let
        th_ field =
            th [] [ text field ]
    in
        table []
            [ thead [] [ tr [] <| List.map th_ head ]
            , tbody [] <| List.map userRow users
            ]


userRow : User -> Html Action
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


type Action
    = Remove Int
    | Removed Int


update : Action -> Model -> ( Model, Cmd Action )
update msg model =
    case msg of
        Remove id ->
            ( model, remove id )

        Removed id ->
            ( List.filter (\user -> user.id /= id) model, Cmd.none )


remove : Int -> Cmd Action
remove id =
    let
        url =
            "http://google.com/?q=" ++ (toString id)
    in
        send (checkRemoved id) (getString url)


checkRemoved : Int -> Result Http.Error String -> Action
checkRemoved id result =
    case result of
        Ok _ ->
            Removed id

        Err e ->
            case e of
                BadStatus response ->
                    if response.status.code >= 400 then
                        Removed -1
                    else
                        Removed id

                BadPayload s response ->
                    Removed id

                NetworkError ->
                    Removed id

                _ ->
                    Removed -1

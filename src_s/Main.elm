module Main exposing (..)

import Html exposing (Html, button, div, text, program)
import Html.Events exposing (onClick)
import User exposing (User)
import Constants
import UserListWidget


-- MODEL


type alias Model =
    { users : List User }


init : ( Model, Cmd Msg )
init =
    ( Model Constants.users, Cmd.none )



-- Messages


type Msg
    = Nothing
    | UserMsg UserListWidget.Message



-- View


view : Model -> Html Msg
view model =
    Html.map UserMsg (UserListWidget.view model.users)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserMsg umsg ->
            let
                ( updatedUserList, userListCmd ) =
                    UserListWidget.update umsg model.users
            in
                ( { model | users = updatedUserList }, Cmd.map UserMsg userListCmd )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

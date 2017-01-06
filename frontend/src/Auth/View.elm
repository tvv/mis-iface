module Auth.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Auth.Models exposing (Auth, User, UserInfo)
import Auth.Messages exposing (Msg(..))


login : Auth -> Html Msg
login model =
  let
    body = case model.error of
      Nothing -> [ row ([ form model ]) ]
      Just error -> [ 
        row ([ div [ class "four wide column" ] [ error_message error ] ]), 
        row ([ form model ]) ]
  in
    div [ class "ui middle aligned center aligned grid", style [ ( "padding-top", "5%" ) ] ] body
    

error_message : String -> Html msg
error_message error =
  div [ class "ui negative message" ] 
    [ div [ class "header" ] 
      [ text "Ошибка" ]
    , p [] 
      [ text error ] ]


form : Auth -> Html Msg
form model =
  div [ class "four wide column" ]
    [ h2 [ class "ui teal header" ] [ text ("Авторизация") ]
    , Html.form [ class "ui large form" ]
      [ div [ class "ui stacked segment" ]
        [ form_field <|
          form_input <|
            input
              [ type_ "text"
              , name "login"
              , placeholder "Логин"
              , value (Maybe.withDefault "" model.login)
              , onInput SetLogin
              ]
              []
        , form_field <|
          form_input <|
            input
              [ type_ "text"
              , name "passwd"
              , placeholder "Пароль"
              , value (Maybe.withDefault "" model.password)
              , onInput SetPassword
              ]
              []
        , div
          [ class "ui fluid large teal submit button"
          , onClick Login
          ]
          [ text "Войти" ]
        ]
      ]
    ]


form_field : Html msg -> Html msg
form_field inner =
  div [ class "field" ] [ inner ]


form_input : Html msg -> Html msg
form_input input =
  div [ class "ui input" ] [ input ]


row : List (Html msg) -> Html msg
row body =
  div [ class "row" ] body
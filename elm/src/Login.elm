module Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline as Pipeline
import Api

type alias Model =
  { login : String
  , password : String
  , token : String
  , error : String
  , info : User
  }

type User = Anonymous | User Info

type alias Info =
    { id : Int
    , name : String
    , login : String
    }

type alias AuthInfo =
  { token : String
  , info: Info
  }

model : Model
model =
  Model "" "" "" "" Anonymous

type Msg
  = SetLogin String
  | SetPassword String
  | Login
  | Authenticated ( Result Http.Error ( Api.Response AuthInfo ) )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SetLogin newLogin ->
      ( { model | login = newLogin, error = "" }, Cmd.none )

    SetPassword newPassword ->
      ( { model | password = newPassword, error = "" }, Cmd.none )

    Login ->
      if model.login == "" || model.password == "" then
        ( { model | error = "Empty cridentials" } , Cmd.none )
      else
        ( { model | token = "", error = "" } , authenticate model )

    Authenticated ( Ok response ) ->
      case response.data of
        Just auth ->
          ( { model | token = auth.token, info = User auth.info, error = "" }, Cmd.none )
        Nothing ->
          ( { model | token = "", info = Anonymous, error = Maybe.withDefault "Unknown error" response.error }, Cmd.none )

    Authenticated ( Err _ ) ->
      ( { model | error = ("Something gone wrong") }, Cmd.none )

view : Model -> Html Msg
view model =
  div [ class "ui middle aligned center aligned grid", style [ ( "padding-top", "5%" ) ] ]
    [ div []
        [ text model.error ],
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
                  , value model.login
                  , onInput SetLogin
                  ]
                  []
            , form_field <|
              form_input <|
                input
                  [ type_ "text"
                  , name "passwd"
                  , placeholder "Пароль"
                  , value model.password
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
    ]

form_field : Html msg -> Html msg
form_field inner =
  div [ class "field" ] [ inner ]

form_input : Html msg -> Html msg
form_input input =
  div [ class "ui input" ] [ input ]

authenticate : Model -> Cmd Msg
authenticate model =
  let
    data = Json.Encode.object 
      [ ("login", Json.Encode.string model.login)
      , ("password", Json.Encode.string model.password)
      ]      
  in
    Http.send Authenticated <|
      Http.post "/auth" (Http.jsonBody data ) (Api.decodeResponse decodeAuthInfo)
      
decodeAuthInfo : Json.Decode.Decoder AuthInfo
decodeAuthInfo =
  Pipeline.decode AuthInfo
    |> Pipeline.required "token" Json.Decode.string
    |> Pipeline.required "user" (Pipeline.decode Info
      |> Pipeline.required "id" Json.Decode.int
      |> Pipeline.required "name" Json.Decode.string
      |> Pipeline.required "login" Json.Decode.string)
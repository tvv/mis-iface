module Login exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias State = 
  { login : String
  , password : String
  , token : String
  }

state : State
state = 
  State "" "" ""

type Action 
  = SetLogin String
  | SetPassword String
  | Login
  | Authenticated String

update : Action -> State -> State
update action state = 
  case action of
    SetLogin newLogin -> 
      { state | login = newLogin }
    SetPassword newPassword -> 
      { state | password = newPassword }
    Login -> 
      state
    Authenticated newToken ->
      { state | token = newToken }

view : State -> Html msg
view state =
  div [class "ui middle aligned center aligned grid", style [("padding-top", "5%")]]
    [ 
      div [class "four wide column"] 
        [
        h2 [class "ui teal header"] [ text ("Авторизация") ]
        , Html.form [class "ui large form"] 
          [
            div [class "ui stacked segment"] 
              [
                form_field <| form_input <| input 
                  [ type_ "text"
                  , name "login"
                  , placeholder "Логин"
                  , value state.login
                  , onInput SetLogin] [],
                form_field <| form_input <| input 
                  [
                    type_ "text"
                  , name "passwd"
                  , placeholder "Пароль"
                  , value state.password
                  , onInput SetPassword] [],
                div [class "ui fluid large teal submit button"] 
                  [
                    text ("Войти")
                  ]
              ]
          ]
        ]
    ]

form_field : Html msg -> Html msg
form_field inner =
  div [class "field"] [inner]

form_input : Html msg -> Html msg
form_input input =
  div [class "ui input"] [input] 
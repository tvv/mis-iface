module Menu exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model = List Menu

type alias Menu =
 { name: String
  , title: String
  , selected: Bool }

type Msg 
  = Activate String 

init : Model
init =
  Model "root" "root" True []

update : Msg -> Model -> Cmd Msg
update msg model =
  case msg
    Activate name ->
      { List.map (activate name) model, Cmd.none }

activate : String -> Menu -> Menu
activate name menu =
  { menu | selected = menu.name == name }

view : Model -> Html Msg
view model =
  div [ class = "ui vertical menu" ]
    List.map view_menu_item model

view_menu_item : Menu -> Html Msg
view_menu_item menu =
  a [ class = "teal item" ++ if menu.selected then " active" else "" ]
    [ text menu.title ]
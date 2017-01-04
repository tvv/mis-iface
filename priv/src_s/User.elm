module User exposing (User)


type alias User =
    { id : Int
    , login : String
    , password : String
    , name : String
    }


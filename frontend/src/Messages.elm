module Messages exposing (..)

import Navigation exposing (Location)
import Auth.Messages

type Msg
    = AuthMsg Auth.Messages.Msg
    | OnLocationChange Location
{-
Copyright 2016 SlamData, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-}

module SlamData.Workspace.Component.State where

import SlamData.Prelude

import Data.List (List)

import Quasar.Advanced.Types (ProviderR)

import SlamData.Workspace.Deck.DeckId (DeckId)
import SlamData.Workspace.StateMode (StateMode(..))
import SlamData.Workspace.Guide (GuideType)

type State =
  { cursor ∷ List DeckId
  , stateMode ∷ StateMode
  , providers ∷ Array ProviderR
  , guide ∷ Maybe GuideType
  , isModified ∷ Boolean
  }

initialState ∷ State
initialState =
  { cursor: mempty
  , stateMode: Loading
  , providers: mempty
  , guide: Nothing
  , isModified: false
  }

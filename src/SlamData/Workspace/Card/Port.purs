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

module SlamData.Workspace.Card.Port
  ( Port(..)
  , TaggedResourcePort
  , DownloadPort
  , MetricPort
  , PivotTablePort
  , tagPort
  , _Initial
  , _Terminal
  , _SlamDown
  , _VarMap
  , _Resource
  , _ResourceAxes
  , _ResourceTag
  , _DownloadOptions
  , _Draftboard
  , _CardError
  , _Metric
  , _ChartInstructions
  , _PivotTable
  , module SlamData.Workspace.Card.Port.VarMap
  ) where

import SlamData.Prelude

import Data.Argonaut (Json)
import Data.Lens (PrismP, prism', TraversalP, wander)

import ECharts.Monad (DSL)
import ECharts.Types.Phantom (OptionI)

import SlamData.Workspace.Card.Port.VarMap (VarMap, URLVarMap, VarMapValue(..), renderVarMapValue, emptyVarMap)
import SlamData.Workspace.Card.BuildChart.PivotTable.Model as PTM
import SlamData.Workspace.Card.CardType.ChartType (ChartType)
import SlamData.Workspace.Card.BuildChart.Axis (Axes)
import SlamData.Download.Model (DownloadOptions)
import Text.Markdown.SlamDown as SD
import Utils.Path as PU

type DownloadPort =
  { resource ∷ PU.FilePath
  , compress ∷ Boolean
  , options ∷ DownloadOptions
  }

type TaggedResourcePort =
  { resource ∷ PU.FilePath
  , tag ∷ Maybe String
  , axes ∷ Axes
  , varMap ∷ Maybe VarMap
  }

type MetricPort =
  { label ∷ Maybe String
  , value ∷ String
  }

type PivotTablePort =
  { records ∷ Array Json
  , options ∷ PTM.PivotTableR
  , taggedResource ∷ TaggedResourcePort
  }

data Port
  = Initial
  | Terminal
  | CardError String
  | VarMap VarMap
  | TaggedResource TaggedResourcePort
  | SlamDown (VarMap × (SD.SlamDownP VarMapValue))
  | ChartInstructions (DSL OptionI) ChartType
  | DownloadOptions DownloadPort
  | Metric MetricPort
  | PivotTable PivotTablePort
  | Draftboard

tagPort ∷ Port → String
tagPort  = case _ of
  Initial → "Initial"
  Terminal → "Terminal"
  SlamDown sd → "SlamDown: " ⊕ show sd
  VarMap vm → "VarMap: " ⊕ show vm
  CardError str → "CardError: " ⊕ show str
  TaggedResource p → "TaggedResource: " ⊕ show p.resource ⊕ " " ⊕ show p.tag
  DownloadOptions p → "DownloadOptions"
  Draftboard → "Draftboard"
  ChartInstructions _ _ → "ChartInstructions"
  Metric _ → "Metric"
  PivotTable _ → "PivotTable"

_Initial ∷ PrismP Port Unit
_Initial = prism' (const Initial) case _ of
  Initial → Just unit
  _ → Nothing

_Terminal ∷ PrismP Port Unit
_Terminal = prism' (const Terminal) case _ of
  Terminal → Just unit
  _ → Nothing

_SlamDown ∷ TraversalP Port (SD.SlamDownP VarMapValue)
_SlamDown = wander \f s → case s of
  SlamDown (vm × sd) → SlamDown ∘ (vm × _) <$> f sd
  _ → pure s

_VarMap ∷ TraversalP Port VarMap
_VarMap = wander \f s → case s of
  VarMap x → VarMap <$> f x
  SlamDown (vm × sd) → SlamDown ∘ (_ × sd) <$> f vm
  _ → pure s

_CardError ∷ PrismP Port String
_CardError = prism' CardError \p → case p of
  CardError x → Just x
  _ → Nothing

_ResourceTag ∷ TraversalP Port String
_ResourceTag = wander \f s → case s of
  TaggedResource o@{tag: Just tag} →
    TaggedResource ∘ o{tag = _} ∘ Just <$> f tag
  _ → pure s

_Resource ∷ TraversalP Port PU.FilePath
_Resource = wander \f s → case s of
  TaggedResource o → TaggedResource ∘ o{resource = _} <$> f o.resource
  _ → pure s

_ResourceAxes ∷ TraversalP Port Axes
_ResourceAxes = wander \f s → case s of
  TaggedResource o → TaggedResource ∘ o{axes = _} <$> f o.axes
  _ → pure s

_DownloadOptions ∷ PrismP Port DownloadPort
_DownloadOptions = prism' DownloadOptions \p → case p of
  DownloadOptions p' → Just p'
  _ → Nothing

_Draftboard ∷ PrismP Port Unit
_Draftboard = prism' (const Draftboard) \p → case p of
  Draftboard → Just unit
  _ → Nothing

_ChartInstructions ∷ TraversalP Port (DSL OptionI)
_ChartInstructions = wander \f s → case s of
  ChartInstructions opts chty → flip ChartInstructions chty <$> f opts
  _ → pure s

_Metric ∷ PrismP Port MetricPort
_Metric = prism' Metric case _ of
  Metric u → Just u
  _ → Nothing

_PivotTable ∷ PrismP Port PivotTablePort
_PivotTable = prism' PivotTable case _ of
  PivotTable u → Just u
  _ → Nothing

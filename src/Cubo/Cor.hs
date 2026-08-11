{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}

module Cubo.Cor
  ( Cor (..),
    SCor (..),
    SomeCor (..),
    corFromString,
    corParaString,
    corDoSingular,
    ehOposto,
    opostoValor,
    opostoSing,
  )
where

data Cor
  = Branco
  | Amarelo
  | Azul
  | Verde
  | Vermelho
  | Laranja
  deriving (Eq, Ord, Show)

type family Oposto (cor :: Cor) :: Cor where
  Oposto 'Branco = 'Amarelo
  Oposto 'Amarelo = 'Branco
  Oposto 'Azul = 'Verde
  Oposto 'Verde = 'Azul
  Oposto 'Vermelho = 'Laranja
  Oposto 'Laranja = 'Vermelho

data SCor (cor :: Cor) where
  SBranco :: SCor 'Branco
  SAmarelo :: SCor 'Amarelo
  SAzul :: SCor 'Azul
  SVerde :: SCor 'Verde
  SVermelho :: SCor 'Vermelho
  SLaranja :: SCor 'Laranja

instance Show (SCor cor) where
  show cor = corParaString cor

data SomeCor where
  SomeCor :: SCor cor -> SomeCor

instance Show SomeCor where
  show (SomeCor cor) = corParaString cor

corDoSingular :: SCor cor -> Cor
corDoSingular SBranco = Branco
corDoSingular SAmarelo = Amarelo
corDoSingular SAzul = Azul
corDoSingular SVerde = Verde
corDoSingular SVermelho = Vermelho
corDoSingular SLaranja = Laranja

corParaString :: SCor cor -> String
corParaString cor = case corDoSingular cor of
  Branco -> "Branco"
  Amarelo -> "Amarelo"
  Azul -> "Azul"
  Verde -> "Verde"
  Vermelho -> "Vermelho"
  Laranja -> "Laranja"

corFromString :: String -> Maybe SomeCor
corFromString texto = case texto of
  "Branco" -> Just (SomeCor SBranco)
  "Amarelo" -> Just (SomeCor SAmarelo)
  "Azul" -> Just (SomeCor SAzul)
  "Verde" -> Just (SomeCor SVerde)
  "Vermelho" -> Just (SomeCor SVermelho)
  "Laranja" -> Just (SomeCor SLaranja)
  _ -> Nothing

opostoValor :: Cor -> Cor
opostoValor Branco = Amarelo
opostoValor Amarelo = Branco
opostoValor Azul = Verde
opostoValor Verde = Azul
opostoValor Vermelho = Laranja
opostoValor Laranja = Vermelho

ehOposto :: SCor cor1 -> SCor cor2 -> Bool
ehOposto cor1 cor2 = corDoSingular (opostoSing cor1) == corDoSingular cor2

opostoSing :: SCor cor -> SCor (Oposto cor)
opostoSing SBranco = SAmarelo
opostoSing SAmarelo = SBranco
opostoSing SAzul = SVerde
opostoSing SVerde = SAzul
opostoSing SVermelho = SLaranja
opostoSing SLaranja = SVermelho
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}

module Cubo.Quina
  ( Quina (..),
    SomeQuina (..),
    criarQuina,
    criarSomeQuina,
    validarCriacaoQuina,
  )
where

import Cubo.Cor

data Quina (c1 :: Cor) (c2 :: Cor) (c3 :: Cor) where
  Quina :: SCor c1 -> SCor c2 -> SCor c3 -> Quina c1 c2 c3

instance Show (Quina c1 c2 c3) where
  show (Quina cor1 cor2 cor3) =
    "Quina(" ++ corParaString cor1 ++ ", " ++ corParaString cor2 ++ ", " ++ corParaString cor3 ++ ")"

data SomeQuina where
  SomeQuina :: Quina c1 c2 c3 -> SomeQuina

instance Show SomeQuina where
  show (SomeQuina quina) = show quina

validarCriacaoQuina :: SCor c1 -> SCor c2 -> SCor c3 -> Either String (Quina c1 c2 c3)
validarCriacaoQuina cor1 cor2 cor3
  | corDoSingular cor1 == corDoSingular cor2 =
      Left ("possui cores repetidas ('" ++ corParaString cor1 ++ "').")
  | corDoSingular cor1 == corDoSingular cor3 =
      Left ("possui cores repetidas ('" ++ corParaString cor1 ++ "').")
  | corDoSingular cor2 == corDoSingular cor3 =
      Left ("possui cores repetidas ('" ++ corParaString cor2 ++ "').")
  | ehOposto cor1 cor2 =
      Left ("possui cores opostas ('" ++ corParaString cor1 ++ "' e '" ++ corParaString cor2 ++ "' sao faces opostas e nao podem estar na mesma quina).")
  | ehOposto cor1 cor3 =
      Left ("possui cores opostas ('" ++ corParaString cor1 ++ "' e '" ++ corParaString cor3 ++ "' sao faces opostas e nao podem estar na mesma quina).")
  | ehOposto cor2 cor3 =
      Left ("possui cores opostas ('" ++ corParaString cor2 ++ "' e '" ++ corParaString cor3 ++ "' sao faces opostas e nao podem estar na mesma quina).")
  | otherwise = Right (Quina cor1 cor2 cor3)

criarQuina :: SCor c1 -> SCor c2 -> SCor c3 -> Maybe (Quina c1 c2 c3)
criarQuina cor1 cor2 cor3 = case validarCriacaoQuina cor1 cor2 cor3 of
  Right q -> Just q
  Left _ -> Nothing

criarSomeQuina :: SCor c1 -> SCor c2 -> SCor c3 -> Maybe SomeQuina
criarSomeQuina cor1 cor2 cor3 = case criarQuina cor1 cor2 cor3 of
  Just quina -> Just (SomeQuina quina)
  Nothing -> Nothing
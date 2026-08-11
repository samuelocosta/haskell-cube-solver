{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE KindSignatures #-}

module Cubo.Cubo
  ( EstadoCubo (..),
    Cubo (..),
    SomeCubo (..),
    montarCubo,
  )
where

import Cubo.Quina

data EstadoCubo = Embaralhado | Resolvido
  deriving (Eq, Show)

data Cubo (estado :: EstadoCubo) = Cubo
  { esqTrasCima :: SomeQuina,
    dirTrasCima :: SomeQuina,
    esqFrenteCima :: SomeQuina,
    dirFrenteCima :: SomeQuina,
    esqTrasBaixo :: SomeQuina,
    dirTrasBaixo :: SomeQuina,
    esqFrenteBaixo :: SomeQuina,
    dirFrenteBaixo :: SomeQuina
  }

instance Show (Cubo estado) where
  show cubo =
    "Cubo {"
      ++ "esqTrasCima = "
      ++ show (esqTrasCima cubo)
      ++ ", dirTrasCima = "
      ++ show (dirTrasCima cubo)
      ++ ", esqFrenteCima = "
      ++ show (esqFrenteCima cubo)
      ++ ", dirFrenteCima = "
      ++ show (dirFrenteCima cubo)
      ++ ", esqTrasBaixo = "
      ++ show (esqTrasBaixo cubo)
      ++ ", dirTrasBaixo = "
      ++ show (dirTrasBaixo cubo)
      ++ ", esqFrenteBaixo = "
      ++ show (esqFrenteBaixo cubo)
      ++ ", dirFrenteBaixo = "
      ++ show (dirFrenteBaixo cubo)
      ++ "}"

data SomeCubo where
  SomeCubo :: Cubo estado -> SomeCubo

instance Show SomeCubo where
  show (SomeCubo cubo) = show cubo

montarCubo :: [SomeQuina] -> Either String SomeCubo
montarCubo quinas = case quinas of
  [q1, q2, q3, q4, q5, q6, q7, q8] ->
    Right
      ( SomeCubo
          ( Cubo
              { esqTrasCima = q1,
                dirTrasCima = q2,
                esqFrenteCima = q3,
                dirFrenteCima = q4,
                esqTrasBaixo = q5,
                dirTrasBaixo = q6,
                esqFrenteBaixo = q7,
                dirFrenteBaixo = q8
              }
          )
      )
  _ -> Left "O arquivo precisa ter exatamente 8 linhas validas."
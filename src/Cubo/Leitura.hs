module Cubo.Leitura
  ( lerCubo,
    parseCubo,
  )
where

import Control.Exception (catch)
import Cubo.Cor
import Cubo.Cubo
import Cubo.Quina
import System.IO.Error (isDoesNotExistError)

lerCubo :: FilePath -> IO (Either String SomeCubo)
lerCubo caminho = do
  resultado <-
    catch
      ( do
          conteudo <- readFile caminho
          pure (parseCubo conteudo)
      )
      tratarErro
  pure resultado
  where
    tratarErro erro
      | isDoesNotExistError erro = pure (Left ("Arquivo nao encontrado: " ++ caminho))
      | otherwise = ioError erro

parseCubo :: String -> Either String SomeCubo
parseCubo texto = do
  let linhas = lines texto
  if length linhas /= 8
    then Left "O arquivo cubo.txt precisa ter exatamente 8 linhas."
    else do
      quinas <- mapM parseLinha linhas
      montarCubo quinas

parseLinha :: String -> Either String SomeQuina
parseLinha linha = case words linha of
  [cor1Texto, cor2Texto, cor3Texto] -> do
    SomeCor cor1 <- parseCor cor1Texto
    SomeCor cor2 <- parseCor cor2Texto
    SomeCor cor3 <- parseCor cor3Texto
    case criarSomeQuina cor1 cor2 cor3 of
      Just quina -> Right quina
      Nothing -> Left ("Quina invalida: " ++ linha)
  _ -> Left ("Cada linha precisa ter exatamente 3 cores: " ++ linha)

parseCor :: String -> Either String SomeCor
parseCor texto = case corFromString texto of
  Just cor -> Right cor
  Nothing -> Left ("Cor desconhecida: " ++ texto)
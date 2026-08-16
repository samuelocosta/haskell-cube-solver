module Cubo.Solver
  ( Solucao (..),
    resolverCubo,
    resolverCuboComLog,
    ehResolvido,
  )
where

import Cubo.Cor (Cor (..), SomeCor (..), corDoSingular, corFromString, opostoValor)
import Cubo.Cubo
import Cubo.Movimento
import Cubo.Quina
import Cubo.Validacao (validarSolucionavel)
import Data.Foldable (foldl')
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Sequence (Seq ((:<|)), (|>))
import Data.Sequence qualified as Seq
import Debug.Trace (trace)
import System.IO (hFlush, stdout)

data Solucao = Solucao
  { movimentosSolucao :: [Movimento],
    cuboFinalSolucao :: SomeCubo
  }

resolverCubo :: SomeCubo -> Either String Solucao
resolverCubo cuboInicial =
  case validarSolucionavel cuboInicial of
    Left erro -> Left erro
    Right () ->
      case buscaBfsBidirecional False cuboInicial of
        Just solucao -> Right solucao
        Nothing -> Left "Nao foi encontrada uma sequencia de movimentos dentro do limite de busca."

resolverCuboComLog :: SomeCubo -> IO (Either String Solucao)
resolverCuboComLog cuboInicial = do
  putStrLn "[solver] iniciando busca de solucao"
  hFlush stdout
  case validarSolucionavel cuboInicial of
    Left erro -> do
      putStrLn ("[solver] cubo invalido: " ++ erro)
      hFlush stdout
      pure (Left erro)
    Right () ->
      case buscaBfsBidirecional True cuboInicial of
        Just solucao -> do
          putStrLn ("[solver] resolvido com " ++ show (length (movimentosSolucao solucao)) ++ " movimentos")
          hFlush stdout
          pure (Right solucao)
        Nothing -> do
          putStrLn "[solver] interrompido por limite de busca sem encontrar solucao"
          hFlush stdout
          pure (Left "Nao foi encontrada uma sequencia de movimentos dentro do limite de busca.")

buscaBfsBidirecional :: Bool -> SomeCubo -> Maybe Solucao
buscaBfsBidirecional comLog cuboInicial
  | ehResolvido cuboInicial = Just (Solucao [] cuboInicial)
  | otherwise =
      let cuboAlvo = gerarCuboAlvo cuboInicial
          filaFrente = Seq.singleton (cuboInicial, [])
          filaTras = Seq.singleton (cuboAlvo, [])
          mapaFrente = Map.singleton (chaveEstado cuboInicial) []
          mapaTras = Map.singleton (chaveEstado cuboAlvo) []
       in loop 0 filaFrente filaTras mapaFrente mapaTras
  where
    loop :: Int -> Seq (SomeCubo, [Movimento]) -> Seq (SomeCubo, [Movimento]) -> Map [Cor] [Movimento] -> Map [Cor] [Movimento] -> Maybe Solucao
    loop passos filaF filaT mapF mapT
      | passos > limitePassos = Nothing
      | Seq.null filaF && Seq.null filaT = Nothing
      | Seq.length filaF <= Seq.length filaT =
          passoFrente passos filaF filaT mapF mapT
      | otherwise =
          passoTras passos filaF filaT mapF mapT

    passoFrente _ Seq.Empty _ _ _ = Nothing
    passoFrente passos ((cuboAtual, caminhoAtual) :<| restoF) filaT mapF mapT =
      case checarEncontroFrente proximos mapT of
        Just solucao -> Just solucao
        Nothing ->
          let novosValidos = filter (\(c, _) -> not (Map.member (chaveEstado c) mapF)) proximos
              mapFNovo = foldl' (\acc (c, cam) -> Map.insert (chaveEstado c) cam acc) mapF novosValidos
              filaFNova = foldl' (|>) restoF novosValidos
              filaFLogada =
                if comLog && passos > 0 && passos `mod` 2000 == 0
                  then trace (mensagemLog passos filaFNova filaT (Map.size mapFNovo + Map.size mapT)) filaFNova
                  else filaFNova
           in loop (passos + 1) filaFLogada filaT mapFNovo mapT
      where
        proximos =
          [ (aplicarMovimentoSome mov cuboAtual, mov : caminhoAtual)
            | mov <- movimentosValidos caminhoAtual
          ]

    passoTras _ _ Seq.Empty _ _ = Nothing
    passoTras passos filaF ((cuboAtual, caminhoAtual) :<| restoT) mapF mapT =
      case checarEncontroTras proximos mapF of
        Just solucao -> Just solucao
        Nothing ->
          let novosValidos = filter (\(c, _) -> not (Map.member (chaveEstado c) mapT)) proximos
              mapTNovo = foldl' (\acc (c, cam) -> Map.insert (chaveEstado c) cam acc) mapT novosValidos
              filaTNova = foldl' (|>) restoT novosValidos
              filaTLogada =
                if comLog && passos > 0 && passos `mod` 2000 == 0
                  then trace (mensagemLog passos filaF filaTNova (Map.size mapF + Map.size mapTNovo)) filaTNova
                  else filaTNova
           in loop (passos + 1) filaF filaTLogada mapF mapTNovo
      where
        proximos =
          [ (aplicarMovimentoInversoSome mov cuboAtual, mov : caminhoAtual)
            | mov <- movimentosValidos caminhoAtual
          ]

    checarEncontroFrente [] _ = Nothing
    checarEncontroFrente ((cubo, caminhoF) : resto) mapT =
      case Map.lookup (chaveEstado cubo) mapT of
        Just caminhoT ->
          let movs = normalizarMovimentos (reverse caminhoF ++ caminhoT)
           in Just (Solucao movs (aplicarMovimentosSome movs cuboInicial))
        Nothing -> checarEncontroFrente resto mapT

    checarEncontroTras [] _ = Nothing
    checarEncontroTras ((cubo, caminhoT) : resto) mapF =
      case Map.lookup (chaveEstado cubo) mapF of
        Just caminhoF ->
          let movs = normalizarMovimentos (reverse caminhoF ++ caminhoT)
           in Just (Solucao movs (aplicarMovimentosSome movs cuboInicial))
        Nothing -> checarEncontroTras resto mapF

    movimentosValidos (m1 : m2 : m3 : _)
      | m1 == m2 && m2 == m3 = filter (/= m1) [U, R, F]
    movimentosValidos _ = [U, R, F]

    mensagemLog passos fF fT visitadosTotal =
      "[solver] passo="
        ++ show passos
        ++ " | filaF="
        ++ show (Seq.length fF)
        ++ " | filaT="
        ++ show (Seq.length fT)
        ++ " | visitados="
        ++ show visitadosTotal

gerarCuboAlvo :: SomeCubo -> SomeCubo
gerarCuboAlvo (SomeCubo cubo) =
  let (cX, cY, cZ) = extrairCoresQuina (esqTrasBaixo cubo)
      oposto c = opostoValor c
      quina (a, b, c) =
        case (corFromString (show a), corFromString (show b), corFromString (show c)) of
          (Just (SomeCor ca), Just (SomeCor cb), Just (SomeCor cc)) ->
            case criarSomeQuina ca cb cc of
              Just q -> q
              Nothing -> error "Quina alvo invalida"
          _ -> error "Cor alvo desconhecida"
   in SomeCubo
        ( Cubo
            { esqTrasCima = quina (cX, cY, oposto cZ),
              dirTrasCima = quina (oposto cX, cY, oposto cZ),
              esqFrenteCima = quina (cX, oposto cY, oposto cZ),
              dirFrenteCima = quina (oposto cX, oposto cY, oposto cZ),
              esqTrasBaixo = quina (cX, cY, cZ),
              dirTrasBaixo = quina (oposto cX, cY, cZ),
              esqFrenteBaixo = quina (cX, oposto cY, cZ),
              dirFrenteBaixo = quina (oposto cX, oposto cY, cZ)
            }
        )

extrairCoresQuina :: SomeQuina -> (Cor, Cor, Cor)
extrairCoresQuina (SomeQuina (Quina q1 q2 q3)) =
  (corDoSingular q1, corDoSingular q2, corDoSingular q3)

normalizarMovimentos :: [Movimento] -> [Movimento]
normalizarMovimentos movimentos = normalizarGrupos movimentos [] Nothing 0

normalizarGrupos :: [Movimento] -> [Movimento] -> Maybe Movimento -> Int -> [Movimento]
normalizarGrupos [] acc Nothing _ = reverse acc
normalizarGrupos [] acc (Just movimentoAtual) contador =
  reverse (converterGrupo movimentoAtual (contador `mod` 4) ++ acc)
normalizarGrupos (movimento : resto) acc Nothing _ =
  normalizarGrupos resto acc (Just movimento) 1
normalizarGrupos (movimento : resto) acc (Just movimentoAtual) contador
  | movimento == movimentoAtual = normalizarGrupos resto acc (Just movimentoAtual) (contador + 1)
  | otherwise =
      let prefixo = converterGrupo movimentoAtual (contador `mod` 4)
       in normalizarGrupos resto (reverse prefixo ++ acc) (Just movimento) 1

converterGrupo :: Movimento -> Int -> [Movimento]
converterGrupo _ 0 = []
converterGrupo mov 1 = [mov]
converterGrupo mov 2 = [mov, mov]
converterGrupo mov 3 = [movimentoAntihorario mov]
converterGrupo _ _ = []

movimentoAntihorario :: Movimento -> Movimento
movimentoAntihorario U = U'
movimentoAntihorario U' = U
movimentoAntihorario R = R'
movimentoAntihorario R' = R
movimentoAntihorario F = F'
movimentoAntihorario F' = F

limitePassos :: Int
limitePassos = 1000000

ehResolvido :: SomeCubo -> Bool
ehResolvido (SomeCubo cubo) =
  faceMonocromatica [corX q1, corX q3, corX q5, corX q7] -- Face Esquerda
    && faceMonocromatica [corX q2, corX q4, corX q6, corX q8] -- Face Direita
    && faceMonocromatica [corY q1, corY q2, corY q5, corY q6] -- Face Tras
    && faceMonocromatica [corY q3, corY q4, corY q7, corY q8] -- Face Frente
    && faceMonocromatica [corZ q1, corZ q2, corZ q3, corZ q4] -- Face Cima
    && faceMonocromatica [corZ q5, corZ q6, corZ q7, corZ q8] -- Face Baixo
  where
    q1 = esqTrasCima cubo
    q2 = dirTrasCima cubo
    q3 = esqFrenteCima cubo
    q4 = dirFrenteCima cubo
    q5 = esqTrasBaixo cubo
    q6 = dirTrasBaixo cubo
    q7 = esqFrenteBaixo cubo
    q8 = dirFrenteBaixo cubo

    corX (SomeQuina (Quina c _ _)) = corDoSingular c
    corY (SomeQuina (Quina _ c _)) = corDoSingular c
    corZ (SomeQuina (Quina _ _ c)) = corDoSingular c

    faceMonocromatica [] = True
    faceMonocromatica (c : cs) = all (== c) cs

chaveEstado :: SomeCubo -> [Cor]
chaveEstado (SomeCubo cubo) =
  extrairCoresLista (esqTrasCima cubo)
    ++ extrairCoresLista (dirTrasCima cubo)
    ++ extrairCoresLista (esqFrenteCima cubo)
    ++ extrairCoresLista (dirFrenteCima cubo)
    ++ extrairCoresLista (esqTrasBaixo cubo)
    ++ extrairCoresLista (dirTrasBaixo cubo)
    ++ extrairCoresLista (esqFrenteBaixo cubo)
    ++ extrairCoresLista (dirFrenteBaixo cubo)
  where
    extrairCoresLista (SomeQuina (Quina c1 c2 c3)) =
      [corDoSingular c1, corDoSingular c2, corDoSingular c3]

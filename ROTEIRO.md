# Roteiro de Apresentação em Vídeo: haskell-cube-solver

- **Tempo Alvo:** ~2 minutos e 30 segundos (Limite do professor: <= 3 minutos / 180s)
- **Tom de Voz:** Natural, confiante e técnico na medida certa (postura de um estudante de graduação apresentando seu projeto final).

---

## ⏱️ Cronograma Geral

| Bloco | Tempo Estimado | Tema Principal | Arquivos Relevantes |
| :--- | :---: | :--- | :--- |
| **Bloco 1** | 0:00 - 0:25 (~25s) | Introdução, Contexto e Objetivo do Projeto | `README.md`, `cube_viewer.py` |
| **Bloco 2** | 0:25 - 1:00 (~35s) | Modelagem no Sistema de Tipos (GADTs, DataKinds, Existenciais) | `src/Cubo/Cor.hs`, `src/Cubo/Quina.hs` |
| **Bloco 3** | 1:00 - 1:35 (~35s) | Geometria 3D e Validações Físicas/Matemáticas | `src/Cubo/Cubo.hs`, `src/Cubo/Validacao.hs` |
| **Bloco 4** | 1:35 - 2:05 (~30s) | Motor de Movimentos e Solver BFS Bidirecional | `src/Cubo/Movimento.hs`, `src/Cubo/Solver.hs` |
| **Bloco 5** | 2:05 - 2:30 (~25s) | Demonstração Prática (Stack CLI, Testes) e Encerramento | `src/Lib.hs`, `app/Main.hs`, `test/Spec.hs` |

---

## Bloco 1: Introdução e Objetivo (0:00 - 0:25)

### 🎙️ Fala:
> "Olá professor e colegas! Hoje vou apresentar o **haskell-cube-solver**, o projeto final que desenvolvi para a disciplina de **Desenvolvimento Guiado por Tipos**.
>
> O objetivo do projeto foi construir um motor formal e solucionador para o **Cubo Mágico 2x2**. Mais do que apenas encontrar os movimentos de resolução, a ideia central foi usar os recursos avançados de tipos do Haskell para modelar a física do cubo, garantindo que estados impossíveis sejam barrados antes mesmo do algoritmo de busca começar."

### 🎬 Sugestões Visuais e Códigos para os Slides:
- **0:00 - 0:10:** Slide inicial limpo com o título do projeto, seu nome, nome da disciplina e data.
- **0:10 - 0:25:** Imagem do cubo 2x2 renderizado em 3D (gerada pelo `cube_viewer.py`) ou animação do cubo girando.

---

## Bloco 2: A Modelagem no Sistema de Tipos (0:25 - 1:00)

### 🎙️ Fala:
> "Para garantir essa segurança, apliquei diretamente os conceitos vistos em aula:
>
> Primeiro, usei **DataKinds** para promover as seis cores a tipos e criei uma **Type Family fechada** para mapear faces opostas.
>
> Cada quina é representada por um **GADT** com *smart constructors*. Isso significa que é impossível criar uma peça com cores repetidas ou com faces opostas juntas, como branco e amarelo na mesma quina.
>
> E como o estado inicial do cubo é lido de um arquivo de texto em tempo de execução, usei **Tipos Existenciais** com *Singletons* para fazer a transição segura do mundo não tipado do `IO` para o nosso motor estritamente tipado."

### 🎬 Sugestões Visuais e Códigos para os Slides:

#### Código 1: Promoção de Cores, Type Families e Singletons (`src/Cubo/Cor.hs`)
```haskell
-- Promoção para Kinds via DataKinds
data Cor = Branco | Amarelo | Azul | Verde | Vermelho | Laranja

-- Família de tipos fechada mapeando faces diametralmente opostas
type family Oposto (cor :: Cor) :: Cor where
  Oposto 'Branco   = 'Amarelo
  Oposto 'Amarelo  = 'Branco
  Oposto 'Azul     = 'Verde
  Oposto 'Verde    = 'Azul
  Oposto 'Vermelho = 'Laranja
  Oposto 'Laranja  = 'Vermelho

-- Singleton que conecta o nível de tipos com o nível de valor
data SCor (cor :: Cor) where
  SBranco   :: SCor 'Branco
  SAmarelo  :: SCor 'Amarelo
  ...

-- Tipo Existencial para empacotar cores lidas em tempo de execução
data SomeCor where
  SomeCor :: SCor cor -> SomeCor
```

#### Código 2: GADTs e Smart Constructors Seguros (`src/Cubo/Quina.hs`)
```haskell
-- GADT: a quina é parametrizada pelos tipos de suas 3 cores
data Quina (c1 :: Cor) (c2 :: Cor) (c3 :: Cor) where
  Quina :: SCor c1 -> SCor c2 -> SCor c3 -> Quina c1 c2 c3

-- Smart Constructor: validação física impedindo peças impossíveis
validarCriacaoQuina :: SCor c1 -> SCor c2 -> SCor c3 -> Either String (Quina c1 c2 c3)
validarCriacaoQuina cor1 cor2 cor3
  | corDoSingular cor1 == corDoSingular cor2 = Left "possui cores repetidas."
  | ehOposto cor1 cor2 = Left "possui cores opostas e nao pode existir em uma quina."
  | ...
  | otherwise = Right (Quina cor1 cor2 cor3)

-- Encapsulamento existencial para quinas dinâmicas
data SomeQuina where
  SomeQuina :: Quina c1 c2 c3 -> SomeQuina
```

---

## Bloco 3: Geometria Espacial e Validações Matemáticas (1:00 - 1:35)

### 🎙️ Fala:
> "No espaço tridimensional, o cubo é representado por oito gavetas ou slots fixos nos eixos X, Y e Z.
>
> Antes de disparar o solver, o módulo de validação executa três verificações matemáticas fundamentais:
>
> 1. Checa se temos exatamente as oito quinas canônicas reais, sem repetições;
> 2. Valida a **quiralidade 3D**, impedindo quinas espelhadas que não existem no mundo real;
> 3. E checa a lei de conservação de rotação das peças: a soma dos *twists* das quinas módulo 3 precisa ser zero. Se alguém girar uma quina à mão no próprio eixo, o sistema detecta e recusa na hora com uma mensagem explicativa."

### 🎬 Sugestões Visuais e Códigos para os Slides:

#### Código 3: Phantom Types e Estrutura dos 8 Slots (`src/Cubo/Cubo.hs`)
```haskell
data EstadoCubo = Embaralhado | Resolvido

-- Phantom Type rastreando o estado do cubo em tempo de compilação
data Cubo (estado :: EstadoCubo) = Cubo
  { esqTrasCima   :: SomeQuina,
    dirTrasCima   :: SomeQuina,
    esqFrenteCima :: SomeQuina,
    dirFrenteCima :: SomeQuina,
    esqTrasBaixo  :: SomeQuina,
    dirTrasBaixo  :: SomeQuina,
    esqFrenteBaixo:: SomeQuina,
    dirFrenteBaixo:: SomeQuina
  }
```

#### Código 4: Validações Físicas e Teorema do Twist (`src/Cubo/Validacao.hs`)
```haskell
validarSolucionavel :: SomeCubo -> Either String ()
validarSolucionavel cubo = do
  validarConjuntoQuinas cubo      -- 1. Exatamente as 8 quinas canônicas únicas
  validarQuiralidadeQuinas cubo   -- 2. Quiralidade 3D física (sem peças espelhadas)
  validarOrientacaoQuinas cubo    -- 3. Paridade do Twist global (soma mod 3 == 0)

-- Se a soma das rotações locais não for múltiplo de 3, o cubo é insolúvel
validarOrientacaoQuinas (SomeCubo cubo) =
  let somaOrientacoes = sum (map orientacaoQuina quinas)
   in if somaOrientacoes `mod` 3 == 0
        then Right ()
        else Left ("Orientacao global invalida: soma mod 3 != 0")
```

---

## Bloco 4: Teoria dos Movimentos e Solver Bidirecional (1:35 - 2:05)

### 🎙️ Fala:
> "Para movimentar o cubo, fixamos uma das quinas de base como referência. Com isso, qualquer estado pode ser resolvido combinando apenas três rotações de faces: **U** (cima), **R** (direita) e **F** (frente), além de suas versões anti-horárias.
>
> Para encontrar a solução, implementei uma **Busca em Largura Bidirecional (BFS Bidirecional)**. O algoritmo expande a busca simultaneamente a partir do cubo embaralhado e a partir do cubo montado.
>
> No instante em que as duas fronteiras se cruzam, os caminhos são unidos e normalizados, garantindo a menor sequência de passos em fração de segundo."

### 🎬 Sugestões Visuais e Códigos para os Slides:

#### Código 5: Transição e Permutação com Rotação Interna (`src/Cubo/Movimento.hs`)
```haskell
data Movimento = U | U' | R | R' | F | F'

-- Movimento U: permuta os slots da camada superior e rotaciona as cores
moverU :: Cubo estado -> Cubo estado
moverU cubo = cubo
  { dirTrasCima   = girarU (esqTrasCima cubo),
    dirFrenteCima = girarU (dirTrasCima cubo),
    esqFrenteCima = girarU (dirFrenteCima cubo),
    esqTrasCima   = girarU (esqFrenteCima cubo)
  }

-- Inversos obtidos algebricamente por 3 aplicações consecutivas (X' = X^3)
aplicarMovimento U' = moverU . moverU . moverU
```

#### Código 6: BFS Bidirecional e Ponto de Encontro (`src/Cubo/Solver.hs`)
```haskell
buscaBfsBidirecional :: Bool -> SomeCubo -> Maybe Solucao
buscaBfsBidirecional comLog cuboInicial =
  let cuboAlvo   = gerarCuboAlvo cuboInicial
      filaFrente = Seq.singleton (cuboInicial, [])
      filaTras   = Seq.singleton (cuboAlvo, [])
      mapaFrente = Map.singleton (chaveEstado cuboInicial) []
      mapaTras   = Map.singleton (chaveEstado cuboAlvo) []
   in loop 0 filaFrente filaTras mapaFrente mapaTras
  where
    -- Ao encontrar um estado no mapa oposto, combina os caminhos e normaliza
    checarEncontroFrente ((cubo, caminhoF) : _) mapT =
      case Map.lookup (chaveEstado cubo) mapT of
        Just caminhoT ->
          let movs = normalizarMovimentos (reverse caminhoF ++ caminhoT)
           in Just (Solucao movs (aplicarMovimentosSome movs cuboInicial))
        Nothing -> ...
```

---

## Bloco 5: Demonstração Prática e Conclusão (2:05 - 2:30)

### 🎙️ Fala:
> "Para finalizar, vamos ver o programa funcionando na prática:
>
> Rodando `stack run` passando o arquivo de um cubo embaralhado, o solver encontra a solução instantaneamente e exibe a sequência de rotações e o estado final.
>
> E executando `stack test`, rodamos a bateria automatizada de testes que cobre tanto a resolução de casos válidos quanto a rejeição correta de cada caso de erro físico ou matemático.
>
> Esse foi o projeto! Muito obrigado pela atenção."

### 🎬 Sugestões Visuais e Códigos para os Slides:

#### Código 7: Orquestração no Main e Execução CLI (`src/Lib.hs`, `app/Main.hs`)
```haskell
-- app/Main.hs
module Main (main) where
import Lib (iniciar)
main :: IO ()
main = iniciar

-- src/Lib.hs: leitura segura e disparo do solver
iniciar :: IO ()
iniciar = do
  argumentos <- getArgs
  let caminho = case argumentos of [] -> "cubo.txt"; x : _ -> x
  resultado <- lerCubo caminho
  case resultado of
    Left erro -> putStrLn ("Falha ao ler: " ++ erro)
    Right cubo -> do
      solucaoOuErro <- resolverCuboComLog cubo
      case solucaoOuErro of
        Left erro -> putStrLn ("Falha ao resolver: " ++ erro)
        Right solucao -> do
          putStrLn ("Movimentos: " ++ show (length (movimentosSolucao solucao)))
          putStrLn ("Sequencia:  " ++ show (movimentosSolucao solucao))
```

#### Terminal e Testes Automatizados:
```bash
# Execução direta com o solver:
$ stack run -- cubos/cubo_1.txt
[solver] iniciando busca de solucao
[solver] resolvido com 2 movimentos
Sequencia: [U,U]

# Suíte de testes completa cobrindo casos válidos e inválidos:
$ stack test
Total de arquivos testados: 8
Testes bem-sucedidos:       8
Testes com falha:           0
RESULTADO: TODOS OS TESTES PASSARAM COM SUCESSO!
```

---

## 📌 Dicas Práticas para a Gravação

1. **Ritmo de Fala:** Mantenha um ritmo natural e pausado. As marcações de tempo já deixam uma margem segura de ~30 segundos para o limite de 3 minutos.
2. **Software Recomendado:** OBS Studio para gravação de tela com webcam no canto, ou gravação de voz separada editada sobre os slides e prints (usando CapCut, Shotcut ou DaVinci Resolve).
3. **Configuração no YouTube:** Ao subir o vídeo, marque a privacidade obrigatoriamente como **Não listado** (*Unlisted*) e cole o link no seu relatório de entrega conforme exigido pelo professor.

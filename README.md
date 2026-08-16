# 🎲 haskell-cube-solver

Um motor formal, estritamente tipado e solucionador (*solver*) para o **Cubo Mágico 2x2x2 (Pocket Cube)** implementado em **Haskell**.

O projeto é desenvolvido sob a ótica de **Desenvolvimento Guiado por Tipos (*Type-Driven Development*)**, modelando as regras físicas, geométricas e a teoria de grupos do cubo diretamente no sistema de tipos do GHC através de **GADTs**, **DataKinds**, **Type Families**, **Singletons**, **Tipos Existenciais** e **Phantom Types**.

---

## 📑 Sumário

- [Visão Geral e Arquitetura](#-visão-geral-e-arquitetura)
- [Fundamentos do Sistema de Tipos](#-fundamentos-do-sistema-de-tipos)
- [Convenção Espacial e Geometria 3D](#-convenção-espacial-e-geometria-3d)
- [Camadas de Validação Formal](#-camadas-de-validação-formal)
- [Teoria dos Movimentos](#-teoria-dos-movimentos)
- [Algoritmo do Solver (Bidirectional BFS)](#-algoritmo-do-solver-bidirectional-bfs)
- [Visualizador 3D em Python](#-visualizador-3d-em-python)
- [Bateria de Casos de Teste (`cubos/`)](#-bateria-de-casos-de-teste-cubos)
- [Como Usar (Guia Stack)](#-como-usar-guia-stack)
  - [Compilação](#compilação)
  - [Executando o Solver](#executando-o-solver)
  - [Executando os Testes Automatizados](#executando-os-testes-automatizados)
  - [REPL Interativo (GHCi)](#repl-interativo-ghci)
- [Estrutura do Repositório](#-estrutura-do-repositório)

---

## 🧠 Visão Geral e Arquitetura

Resolver um cubo 2x2 não é apenas encontrar um caminho em um grafo de estados: é garantir que cada estado intermediário seja fisicamente e matematicamente realizável.

A arquitetura do projeto divide as responsabilidades em módulos desacoplados e fortemente tipados:

```
[ Arquivo .txt ] 
       │ (IO / Runtime Inseguro)
       ▼
[ Cubo.Leitura ] ──> Parse de tokens, validação léxica e criação de SomeCor
       │
       ▼
[ Cubo.Quina ] ───> Smart constructors & GADTs (garantia de quinas válidas)
       │
       ▼
[ Cubo.Cubo ] ────> Estrutura espacial com 8 slots nomeados e Phantom Types
       │
       ▼
[ Cubo.Validacao ] > Validação de quiralidade 3D, conjunto canônico e twist (mod 3)
       │
       ▼
[ Cubo.Solver ] ───> Busca BFS Bidirecional, canonicidade e normalização de movimentos
       │
       ▼
[ Saída CLI ] ────> Sequência ótima de rotações + Estado final resolvido
```

---

## 🔬 Fundamentos do Sistema de Tipos

O projeto utiliza extensões modernas do GHC para codificar restrições matemáticas em tempo de compilação:

### 1. `DataKinds` e Promoção de Tipos (`src/Cubo/Cor.hs`)
As cores do cubo (`Branco`, `Amarelo`, `Azul`, `Verde`, `Vermelho`, `Laranja`) são promovidas a *Kinds* no nível de tipos (`'Branco`, `'Amarelo'`, etc.), permitindo que funções e estruturas operem parametricamente sobre cores como tipos.

### 2. `TypeFamilies` Fechadas (`src/Cubo/Cor.hs`)
A família de tipos fechada `Oposto` mapeia faces diametralmente opostas no nível de tipos:
```haskell
type family Oposto (cor :: Cor) :: Cor where
  Oposto 'Branco   = 'Amarelo
  Oposto 'Amarelo  = 'Branco
  Oposto 'Azul     = 'Verde
  Oposto 'Verde    = 'Azul
  Oposto 'Vermelho = 'Laranja
  Oposto 'Laranja  = 'Vermelho
```

### 3. `GADTs` e `Singletons` (`src/Cubo/Cor.hs`, `src/Cubo/Quina.hs`)
O tipo `SCor (cor :: Cor)` atua como um singleton que espelha as cores do nível de tipos no nível de valor. A `Quina` é parametrizada pelos tipos de suas 3 cores (`Quina (c1 :: Cor) (c2 :: Cor) (c3 :: Cor)`), impossibilitando a construção de quinas inválidas através de *smart constructors*.

### 4. Tipos Existenciais (`ExistentialQuantification`)
Para transitar com segurança do mundo dinâmico de arquivos de texto (`IO`) para o motor tipado, tipos existenciais encapsulam os tipos em tempo de execução:
- `SomeCor`: empacota `SCor cor`
- `SomeQuina`: empacota `Quina c1 c2 c3`
- `SomeCubo`: empacota `Cubo estado`

### 5. `Phantom Types` (`src/Cubo/Cubo.hs`)
O tipo `Cubo (estado :: EstadoCubo)` utiliza marcadores de estado (`Embaralhado` e `Resolvido`) para expressar propriedades invariantes nas transformações do cubo.

---

## 📐 Convenção Espacial e Geometria 3D

O cubo 2x2 é posicionado em um sistema cartesiano 3D com origem no centro do cubo:

* **Eixo X**: Esquerda (`-1`, Face Laranja) $\longleftrightarrow$ Direita (`+1`, Face Vermelha)
* **Eixo Y**: Frente (`-1`, Face Verde) $\longleftrightarrow$ Trás (`+1`, Face Azul)
* **Eixo Z**: Baixo (`-1`, Face Amarela) $\longleftrightarrow$ Cima (`+1`, Face Branca)

### Disposição dos 8 Slots Espaciais e Ordem no TXT

Todo arquivo de entrada `.txt` deve conter exatamente 8 linhas, onde cada linha representa as 3 cores de uma quina na ordem estrita dos eixos `X Y Z` (`corX corY corZ`):

| Linha | Nome do Slot | Coordenadas $(X, Y, Z)$ | Cores no Cubo Resolvido |
| :---: | :--- | :---: | :--- |
| **1** | `esqTrasCima` | $(-1, +1, +1)$ | `Laranja Azul Branco` |
| **2** | `dirTrasCima` | $(+1, +1, +1)$ | `Vermelho Azul Branco` |
| **3** | `esqFrenteCima` | $(-1, -1, +1)$ | `Laranja Verde Branco` |
| **4** | `dirFrenteCima` | $(+1, -1, +1)$ | `Vermelho Verde Branco` |
| **5** | `esqTrasBaixo` | $(-1, +1, -1)$ | `Laranja Azul Amarelo` |
| **6** | `dirTrasBaixo` | $(+1, +1, -1)$ | `Vermelho Azul Amarelo` |
| **7** | `esqFrenteBaixo` | $(-1, -1, -1)$ | `Laranja Verde Amarelo` |
| **8** | `dirFrenteBaixo` | $(+1, -1, -1)$ | `Vermelho Verde Amarelo` |

---

## 🛡️ Camadas de Validação Formal

Antes de iniciar a busca por soluções, o módulo `src/Cubo/Validacao.hs` aplica 3 testes matemáticos rigorosos para verificar se o cubo é solucionável:

1. **Validação do Conjunto de Quinas (`validarConjuntoQuinas`)**:
   Garante que o arquivo contém exatamente o conjunto das 8 quinas canônicas reais, rejeitando cubos com peças duplicadas ou faltando.
2. **Validação de Quiralidade 3D (`validarQuiralidadeQuinas`)**:
   Calcula a orientação cíclica das cores em relação à posição 3D do vértice. Rejeita peças com quiralidade invertida (peças espelhadas que não existem fisicamente).
3. **Validação de Orientação / *Twist* Global (`validarOrientacaoQuinas`)**:
   Calcula a soma das rotações de cada quina em seu próprio eixo em relação às faces de referência (Branco/Amarelo):
   $$\sum_{i=1}^{8} \text{orientação}(q_i) \equiv 0 \pmod 3$$
   Se a soma módulo 3 for diferente de 0, significa que alguma quina foi virada fisicamente à mão, tornando o cubo impossível de resolver por movimentos regulares.

---

## 🔄 Teoria dos Movimentos

No Cubo 2x2, fixando uma das quinas de base (por convenção, o slot `esqTrasBaixo`), qualquer permutação do grupo do cubo pode ser resolvida utilizando apenas 3 geradores principais e seus inversos:

* **`U` (Up / Cima)**: Rotação horária da camada superior ($Z = +1$). Permuta ciclicamente `dirTrasCima`, `dirFrenteCima`, `esqFrenteCima` e `esqTrasCima` aplicando a transformação de orientação `girarU`.
* **`R` (Right / Direita)**: Rotação horária da camada direita ($X = +1$). Permuta `dirTrasCima`, `dirTrasBaixo`, `dirFrenteBaixo` e `dirFrenteCima` aplicando `girarR`.
* **`F` (Front / Frente)**: Rotação horária da camada frontal ($Y = -1$). Permuta `dirFrenteCima`, `dirFrenteBaixo`, `esqFrenteBaixo` e `esqFrenteCima` aplicando `girarF`.
* **Inversos (`U'`, `R'`, `F'`)**: Realizados matematicamente por 3 aplicações consecutivas do movimento horário ($X' = X^3$).

### Normalização Algébrica
O solver simplifica automaticamente a cadeia de movimentos gerada:
- $X^4 \longrightarrow \emptyset$ (identidade)
- $X^3 \longrightarrow X'$
- $X^2 \longrightarrow X \ X$

---

## ⚡ Algoritmo do Solver (Bidirectional BFS)

O `src/Cubo/Solver.hs` utiliza uma **Busca em Largura Bidirecional (*Bidirectional Breadth-First Search*)**:

1. **Fronteira Dupla**: Expande simultaneamente a árvore de busca para frente (a partir do estado inicial embaralhado) e para trás (a partir do estado resolvido correspondente gerado por `gerarCuboAlvo`).
2. **Representação Canônica e Memoização**: Estados visitados são indexados em tabelas hash/mapas estritos (`Data.Map.Strict`) com filas eficientes (`Data.Sequence`).
3. **Ponto de Encontro**: No momento em que um estado explorado por uma das pontas coincide com um estado já visitado pela outra, os dois caminhos são combinados, normalizados e validados.
4. **Garantia de Otimalidade**: Por ser BFS bidirecional, o solver encontra a menor sequência de movimentos sem explorar o espaço combinatorial completo.

---

## 🎨 Visualizador 3D em Python

O repositório inclui o utilitário [`cube_viewer.py`](cube_viewer.py), que renderiza o cubo tridimensionalmente com Matplotlib:

```bash
# Visualizar o cubo interativamente em janela 3D
python cube_viewer.py cubos/cubo_1.txt
```

---

## 📁 Bateria de Casos de Teste (`cubos/`)

O diretório [`cubos/`](cubos/) reúne arquivos prontos para validar o comportamento do motor:

### Cubos Válidos e Embaralhados
- [`cubos/cubo_resolvido.txt`](cubos/cubo_resolvido.txt): Cubo no estado padrão resolvido (0 movimentos necessários).
- [`cubos/cubo_1.txt`](cubos/cubo_1.txt): Embaralhamento simples de teste.
- [`cubos/cubo_2.txt`](cubos/cubo_2.txt): Embaralhamento com profundidade intermediária.
- [`cubos/cubo_3.txt`](cubos/cubo_3.txt): Embaralhamento com múltiplas faces alteradas.

### Casos de Erro e Validação Física
- [`cubos/cubo_cor_repetida.txt`](cubos/cubo_cor_repetida.txt): Quina com cores repetidas (`Branco Branco Branco`).
- [`cubos/cubo_conjunto_invalido.txt`](cubos/cubo_conjunto_invalido.txt): Quinas duplicadas / conjunto incompleto.
- [`cubos/cubo_quina_invalida.txt`](cubos/cubo_quina_invalida.txt): Quina com quiralidade invertida (peça fisicamente espelhada).
- [`cubos/cubo_quina_virada.txt`](cubos/cubo_quina_virada.txt): Cubo com quina rotacionada no próprio eixo (soma de twist $\not\equiv 0 \pmod 3$).

---

## 🚀 Como Usar (Guia Stack)

O projeto é configurado e gerenciado através do **[Haskell Stack](https://docs.haskellstack.org/)**.

### Compilação

Para compilar todas as bibliotecas, executáveis e suítes de teste:

```bash
stack build
```

---

### Executando o Solver

Para resolver um cubo mágico a partir de um arquivo `.txt`, passe o caminho do arquivo como argumento após `--`:

```bash
# Resolver o cubo_1.txt
stack run -- cubos/cubo_1.txt

# Resolver o cubo_2.txt
stack run -- cubos/cubo_2.txt

# Resolver o cubo_3.txt
stack run -- cubos/cubo_3.txt
```

> Se nenhum argumento for passado (`stack run`), o executável tentará carregar o arquivo `cubo.txt` no diretório raiz.

#### Exemplo de Saída no Terminal:

```text
Cubo carregado de cubos/cubo_1.txt.
[solver] iniciando busca de solucao
[solver] resolvido com 2 movimentos
Movimentos encontrados: 2
Sequencia: [U,U]
Estado final: Cubo {esqTrasCima = Quina(Laranja, Azul, Branco), ...}
```

---

### Executando os Testes Automatizados

O projeto conta com uma suíte de testes completa configurada no [`test/Spec.hs`](test/Spec.hs). Ela varre automaticamente todos os arquivos do diretório `cubos/`, testa cubos válidos verificando se atingem o estado monocromático e testa todos os casos de cubos inválidos certificando que os erros corretos foram levantados.

Para rodar toda a bateria de testes:

```bash
stack test
```

#### O que o `stack test` valida:
1. **Validação Sintática**: Rejeição de cores desconhecidas, quantidade incorreta de linhas ou tokens.
2. **Validação Física**: Detecção de quinas impossíveis e quiralidade invertida.
3. **Validação Matemática**: Detecção de conjuntos duplicados e erro de paridade de *twist*.
4. **Corretude do Solver**: Verificação de que para cada cubo válido, a sequência gerada atinge um estado final perfeitamente monocromático em todas as 6 faces.

---

### REPL Interativo (GHCi)

Para carregar o projeto em um ambiente interativo:

```bash
stack ghci
```

No GHCi você pode importar os módulos e testar funções diretamente:

```haskell
ghci> import Cubo.Cor
ghci> import Cubo.Quina
ghci> import Cubo.Leitura
ghci> import Cubo.Solver
ghci> resultado <- lerCubo "cubos/cubo_1.txt"
ghci> case resultado of Right c -> resolverCubo c; Left err -> Left err
```

---

## 📂 Estrutura do Repositório

```
haskell-cube-solver/
├── app/
│   └── Main.hs                 # Ponto de entrada do executável CLI
├── cubos/                      # Casos de teste e exemplos de cubos .txt
│   ├── cubo_1.txt
│   ├── cubo_2.txt
│   ├── cubo_3.txt
│   ├── cubo_conjunto_invalido.txt
│   ├── cubo_cor_repetida.txt
│   ├── cubo_quina_invalida.txt
│   ├── cubo_quina_virada.txt
│   └── cubo_resolvido.txt
├── src/
│   ├── Lib.hs                  # Interface CLI e orquestração do programa
│   └── Cubo/
│       ├── Cor.hs              # Cores, Singletons (SCor), Type Families (Oposto)
│       ├── Quina.hs            # GADTs para Quinas e Smart Constructors seguros
│       ├── Cubo.hs             # Estrutura com 8 slots espaciais e Phantom Types
│       ├── Movimento.hs        # Grupo de movimentos (U, R, F) e transformações
│       ├── Validacao.hs        # Validação física (quiralidade, conjunto e twist)
│       ├── Leitura.hs          # Parser com tratamento de erro e tipos existenciais
│       └── Solver.hs           # BFS Bidirecional, canonicidade e normalização
├── test/
│   └── Spec.hs                 # Suíte de testes automatizados (stack test)
├── cube_viewer.py              # Visualizador e renderizador 3D em Python/Matplotlib
├── haskell-cube-solver.cabal   # Configuração Cabal do pacote
├── stack.yaml                  # Configuração do Stack
└── README.md                   # Documentação completa do projeto
```

---
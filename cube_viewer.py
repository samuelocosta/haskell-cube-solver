from pathlib import Path
import matplotlib

try:
    matplotlib.use("TkAgg", force=True)
except Exception:
    pass

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

# -----------------------------
# Mapeamento de cor -> RGB
# -----------------------------
COLOR_TO_RGB = {
    "Branco": (1.0, 1.0, 1.0),
    "Amarelo": (1.0, 0.85, 0.0),
    "Azul": (0.1, 0.35, 0.95),
    "Verde": (0.1, 0.8, 0.35),
    "Vermelho": (0.9, 0.15, 0.15),
    "Laranja": (1.0, 0.55, 0.1),
}

# -----------------------------------------------------------------------------
# Definição das 8 posições espaciais do cubo 2x2 conforme a especificação do TXT:
#
# Sistema de Coordenadas:
#   X: -1 = Esquerda (Laranja),  +1 = Direita (Vermelho)
#   Y: +1 = Trás (Azul),         -1 = Frente (Verde)
#   Z: +1 = Cima (Branco),       -1 = Baixo (Amarelo)
#
# Ordem das 8 quinas nas 8 linhas do arquivo cubo.txt:
# Linha 1: esqTrasCima   -> (-1,  1,  1) [corX=Laranja, corY=Azul,   corZ=Branco]
# Linha 2: dirTrasCima   -> ( 1,  1,  1) [corX=Vermelho,corY=Azul,   corZ=Branco]
# Linha 3: esqFrenteCima -> (-1, -1,  1) [corX=Laranja, corY=Verde,  corZ=Branco]
# Linha 4: dirFrenteCima -> ( 1, -1,  1) [corX=Vermelho,corY=Verde,  corZ=Branco]
# Linha 5: esqTrasBaixo  -> (-1,  1, -1) [corX=Laranja, corY=Azul,   corZ=Amarelo]
# Linha 6: dirTrasBaixo  -> ( 1,  1, -1) [corX=Vermelho,corY=Azul,   corZ=Amarelo]
# Linha 7: esqFrenteBaixo-> (-1, -1, -1) [corX=Laranja, corY=Verde,  corZ=Amarelo]
# Linha 8: dirFrenteBaixo-> ( 1, -1, -1) [corX=Vermelho,corY=Verde,  corZ=Amarelo]
# -----------------------------------------------------------------------------
POSICAO_QUINAS = [
    (-1,  1,  1),
     (1,  1,  1),
    (-1, -1,  1),
     (1, -1,  1),
    (-1,  1, -1),
     (1,  1, -1),
    (-1, -1, -1),
     (1, -1, -1),
]


def parse_cube_file(path):
    path = Path(path)
    if not path.exists():
        raise FileNotFoundError(f"Arquivo não encontrado: {path}")

    linhas_brutas = [line.strip() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    if len(linhas_brutas) != 8:
        raise ValueError(f"Esperado 8 linhas, mas encontrei {len(linhas_brutas)}.")

    # Formata cada palavra para iniciar em letra maiúscula (ex: "branco" -> "Branco")
    linhas_formatadas = []
    for linha in linhas_brutas:
        palavras = [palavra.capitalize() for palavra in linha.split()]
        linhas_formatadas.append(" ".join(palavras))

    # Salva o arquivo novamente com as palavras capitalizadas
    path.write_text("\n".join(linhas_formatadas) + "\n", encoding="utf-8")

    cantos = []
    for idx, linha in enumerate(linhas_formatadas, start=1):
        tokens = linha.split()
        if len(tokens) != 3:
            raise ValueError(f"Linha {idx}: esperava 3 cores, encontrou {len(tokens)}: '{linha}'.")

        cor_x, cor_y, cor_z = tokens
        for c in (cor_x, cor_y, cor_z):
            if c not in COLOR_TO_RGB:
                raise ValueError(f"Linha {idx}: cor desconhecida '{c}'.")

        cantos.append((cor_x, cor_y, cor_z))

    return cantos


def criar_poligono_face(centro, tamanho_metade, eixo, sinal):
    """
    Gera os 4 vértices 3D da face externa de um mini-bloco.
    """
    cx, cy, cz = centro
    h = tamanho_metade

    x_min, x_max = cx - h, cx + h
    y_min, y_max = cy - h, cy + h
    z_min, z_max = cz - h, cz + h

    if eixo == "x":
        x = x_max if sinal > 0 else x_min
        if sinal > 0:
            return [(x, y_min, z_min), (x, y_max, z_min), (x, y_max, z_max), (x, y_min, z_max)]
        else:
            return [(x, y_min, z_min), (x, y_min, z_max), (x, y_max, z_max), (x, y_max, z_min)]

    elif eixo == "y":
        y = y_max if sinal > 0 else y_min
        if sinal > 0:
            return [(x_min, y, z_min), (x_min, y, z_max), (x_max, y, z_max), (x_max, y, z_min)]
        else:
            return [(x_min, y, z_min), (x_max, y, z_min), (x_max, y, z_max), (x_min, y, z_max)]

    elif eixo == "z":
        z = z_max if sinal > 0 else z_min
        if sinal > 0:
            return [(x_min, y_min, z), (x_max, y_min, z), (x_max, y_max, z), (x_min, y_max, z)]
        else:
            return [(x_min, y_min, z), (x_min, y_max, z), (x_max, y_max, z), (x_max, y_min, z)]


def gerar_faces_quina(posicao, cores_quina):
    """
    Dada a posição (x, y, z) da quina (-1 ou +1 para cada eixo)
    e a tripla de cores (corX, corY, corZ), retorna as 3 faces visíveis externas.
    """
    px, py, pz = posicao
    cor_x, cor_y, cor_z = cores_quina

    centro = (0.6 * px, 0.6 * py, 0.6 * pz)
    metade_tamanho = 0.4

    faces = []

    # Face no Eixo X
    vert_x = criar_poligono_face(centro, metade_tamanho, "x", px)
    faces.append((vert_x, COLOR_TO_RGB[cor_x]))

    # Face no Eixo Y
    vert_y = criar_poligono_face(centro, metade_tamanho, "y", py)
    faces.append((vert_y, COLOR_TO_RGB[cor_y]))

    # Face no Eixo Z
    vert_z = criar_poligono_face(centro, metade_tamanho, "z", pz)
    faces.append((vert_z, COLOR_TO_RGB[cor_z]))

    return faces


def render_cube_from_txt(txt_path, output_path=None):
    quinas_cores = parse_cube_file(txt_path)

    fig = plt.figure(figsize=(9, 9))
    ax = fig.add_subplot(111, projection="3d")
    ax.set_box_aspect((1, 1, 1))

    # Desenha as 8 quinas e suas 3 faces externas limpas
    for pos, cores in zip(POSICAO_QUINAS, quinas_cores):
        faces = gerar_faces_quina(pos, cores)
        for vertices, rgb in faces:
            poly = Poly3DCollection(
                [vertices],
                facecolors=[rgb],
                edgecolors="black",
                linewidths=1.0,
            )
            ax.add_collection3d(poly)

    # Configuração dos eixos 3D do Matplotlib com legendas 'Eixo <n>' e escala com os nomes espaciais
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_zlim(-1.4, 1.4)

    ax.set_xlabel("Eixo X", labelpad=10, fontsize=10, weight="bold")
    ax.set_ylabel("Eixo Y", labelpad=10, fontsize=10, weight="bold")
    ax.set_zlabel("Eixo Z", labelpad=10, fontsize=10, weight="bold")

    ax.set_xticks([-1, 1])
    ax.set_xticklabels(["Esquerda", "Direita"])

    ax.set_yticks([-1, 1])
    ax.set_yticklabels(["Frente", "Trás"])

    ax.set_zticks([-1, 1])
    ax.set_zticklabels(["Baixo", "Cima"])

    # Visão isométrica limpa e elegante mostrando Frente, Direita e Cima
    ax.view_init(elev=25, azim=-135)
    ax.set_title(f"Visualizador 3D: {Path(txt_path).name}", fontsize=14, pad=15)

    if output_path:
        output = Path(output_path)
        output.parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(output, dpi=200, bbox_inches="tight")
        print(f"Imagem salva com sucesso em: {output}")
    else:
        plt.show(block=True)


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Uso: python cube_viewer.py caminho_do_arquivo.txt [saida.png]")
        print("Exemplo: python cube_viewer.py cubo.txt")
        print("Exemplo: python cube_viewer.py cubo.txt cubo.png")
        sys.exit(1)

    txt_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None
    render_cube_from_txt(txt_path, output_path)

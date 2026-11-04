# Quant-Supply Framework v5 — Colección Completa de Notebooks

**10 modelos DS | 20 notebooks | Cadena integrada DS-01 → DS-10**

---

## Ver los notebooks (nbviewer)

GitHub a veces falla al renderizar `.ipynb` con outputs grandes. Estos links de
**nbviewer** los muestran con todos los gráficos (incluyen `?flush_cache=true`):

| # | Modelo | Finance Concept | Supply Adaptation |
|---|--------|-----------------|-------------------|
| DS01 | Causal Forest | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/01_DS01_Causal_Forest/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/01_DS01_Causal_Forest/2_Supply_Adaptation.ipynb?flush_cache=true) |
| DS02 | Changepoint Detection | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/02_DS02_Changepoint_Detection/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/02_DS02_Changepoint_Detection/2_Supply_Adaptation.ipynb?flush_cache=true) |
| DS03 | Graph Neural Network | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/03_DS03_Graph_Neural_Network/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/03_DS03_Graph_Neural_Network/2_Supply_Adaptation.ipynb?flush_cache=true) |
| DS04 | Conformal Prediction | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/04_DS04_Conformal_Prediction/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/04_DS04_Conformal_Prediction/2_Supply_Adaptation.ipynb?flush_cache=true) |
| DS05 | Shapley Values | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/05_DS05_Shapley_Values/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/05_DS05_Shapley_Values/2_Supply_Adaptation.ipynb?flush_cache=true) |
| DS06 | Bayesian Optimization | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/06_DS06_Bayesian_Optimization/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/06_DS06_Bayesian_Optimization/2_Supply_Adaptation.ipynb?flush_cache=true) |
| DS07 | Semi-Supervised | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/07_DS07_Semi_Supervised/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/07_DS07_Semi_Supervised/2_Supply_Adaptation.ipynb?flush_cache=true) |
| DS08 | Autoencoder Anomaly | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/08_DS08_Autoencoder_Anomaly/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/08_DS08_Autoencoder_Anomaly/2_Supply_Adaptation.ipynb?flush_cache=true) |
| DS09 | Multi-Armed Bandit | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/09_DS09_Multi_Armed_Bandit/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/09_DS09_Multi_Armed_Bandit/2_Supply_Adaptation.ipynb?flush_cache=true) |
| DS10 | NLP Logístico | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/10_DS10_NLP_Logistico/1_Finance_Concept.ipynb?flush_cache=true) | [nbviewer](https://nbviewer.org/github/Japura11/datascience-supply-portfolio/blob/main/10_DS10_NLP_Logistico/2_Supply_Adaptation.ipynb?flush_cache=true) |

---

## Estructura

```
Quant_Supply_Framework_v5_Notebooks/
├── 01_DS01_Causal_Forest/          ← Causal Forest & Double ML
├── 02_DS02_Changepoint_Detection/  ← PELT + BOCPD
├── 03_DS03_Graph_Neural_Network/   ← GCN + GraphSAGE
├── 04_DS04_Conformal_Prediction/   ← Split CP + CQR
├── 05_DS05_Shapley_Values/         ← Shapley + KernelSHAP
├── 06_DS06_Bayesian_Optimization/  ← GP + UCB/EI
├── 07_DS07_Semi_Supervised/        ← Label Propagation + Self-Training
├── 08_DS08_Autoencoder_Anomaly/    ← AE + VAE
├── 09_DS09_Multi_Armed_Bandit/     ← ε-Greedy + UCB1 + Thompson Sampling
└── 10_DS10_NLP_Logistico/          ← TF-IDF + Naive Bayes + regex
```

Cada carpeta contiene:
- `1_Finance_Concept.ipynb` — implementación con dataset del campo de origen
- `2_Supply_Adaptation.ipynb` — dataset peruano (BCRP/INEI/SUNAT calibrado)
- `README.md` — descripción del modelo, fórmulas clave y referencias
- `data/` — outputs CSV y PNG generados al ejecutar

---

## Cadena integrada DS-01 → DS-10

```
DS-01  Causal Forest      → identifica cuentas donde el expediting tiene mayor impacto causal
DS-02  Changepoint        → detecta cuándo el LT cambia de régimen
DS-03  GCN                → clasifica riesgo sistémico en la red de proveedores
DS-04  Conformal Pred.    → garantiza intervalos de SS y ROP con cobertura exacta
DS-05  SHAP               → explica al CFO qué feature domina el cambio de SS
DS-06  Bayesian Opt.      → optimiza (SS*, ROP*, Q*) con pocas simulaciones
DS-07  Semi-Supervised    → propaga etiquetas de riesgo a proveedores no auditados
DS-08  Autoencoder AE     → detecta proveedores con patrones atípicos (Tipo 3)
DS-09  Multi-Armed Bandit → selecciona el mejor proveedor alternativo en tiempo real
DS-10  NLP Logístico      → extrae ETA y alertas de correos/BL/SUNAT, cierra el ciclo
```

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy scikit-learn
# Todos los modelos implementados desde cero — sin librerías especializadas
```

---

## Referencia rápida de modelos

| Modelo | Algoritmos | Output clave |
|--------|-----------|--------------|
| DS-01 | HonestCausalForest, Double ML | τ̂(x) por cuenta — prioridad expediting |
| DS-02 | PELT exacto O(n), BOCPD | Semana del changepoint en LT |
| DS-03 | GCN backprop manual, GraphSAGE | Clasificación de riesgo sistémico |
| DS-04 | Split CP, CQR con GBM cuantil | Intervalo [SS_lo, SS_hi] garantizado |
| DS-05 | Shapley exacto, KernelSHAP WLS | φᵢ por feature — waterfall CFO |
| DS-06 | GP + UCB/EI, Cholesky | (SS*, ROP*, Q*) óptimos |
| DS-07 | Label Propagation, Self-Training | Etiqueta de riesgo para 94 proveedores |
| DS-08 | AE MLP, VAE ELBO | Score de anomalía por proveedor |
| DS-09 | ε-Greedy, UCB1, Thompson Sampling | Proveedor alternativo óptimo |
| DS-10 | TF-IDF, Naive Bayes, regex | ETA extraída, alerta clasificada |

---

## 🎮 Proyecto adicional: Videojuego

En [`videojuego/`](videojuego/) vive un proyecto de videojuego original en pre-producción,
con su propio ecosistema de agentes de Claude Code (subagentes, skills, flujo de trabajo y
plantillas de diseño). Ver [`videojuego/README.md`](videojuego/README.md).

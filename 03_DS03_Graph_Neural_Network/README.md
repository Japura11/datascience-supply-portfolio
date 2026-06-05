# DS-03 | Graph Neural Networks — GCN + GraphSAGE

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10)  
**Autores:** Kipf & Welling (2017) · Hamilton et al. (2017) · Veličković et al. (2018)  
**Campo de origen:** Física de redes / Aprendizaje en grafos  
**Aplicación Supply:** Clasificar riesgo de disruption por nodo y propagar shocks en red SC

---

## Estructura

```
11_DS03_Graph_Neural_Network/
├── 1_Finance_Concept.ipynb      ← Red interbancaria 30 bancos — riesgo sistémico
├── 2_Supply_Adaptation.ipynb    ← Red SC Perú 45 nodos — riesgo de disruption + shocks
├── README.md
└── data/
    ├── eda_interbank.png
    ├── eda_sc_peru.png
    ├── dashboard_gnn_finance.png
    ├── dashboard_gnn_supply.png
    ├── interbank_nodes.csv
    ├── model_comparison.csv
    ├── sc_peru_nodes.csv
    ├── shock_impact_supply.csv
    ├── gcn_W1.npy / gcn_W2.npy
    └── gcn_W1_supply.npy / gcn_W2_supply.npy
```

---

## Marco Teórico

### GCN — Capa de propagación (Kipf & Welling, 2017)

$$H^{(l+1)} = \sigma\!\left(\tilde{D}^{-1/2}\tilde{A}\tilde{D}^{-1/2} H^{(l)} W^{(l)}\right)$$

- $\tilde{A} = A + I_N$ — auto-lazos
- $\tilde{D}_{ii} = \sum_j \tilde{A}_{ij}$ — grado con auto-lazos
- **Complejidad:** O(E·F·H) — lineal en aristas

### GraphSAGE — Inductive (Hamilton et al., 2017)

$$h_v^{(l+1)} = \sigma\!\left(W^{(l)} \cdot \text{CONCAT}\!\left[h_v^{(l)},\ \text{MEAN}\!\left(\{h_u^{(l)} : u \in \mathcal{S}(v)\}\right)\right]\right)$$

- Ventaja: generaliza a nodos nuevos sin reentrenar
- La concatenación preserva la identidad del nodo separada del agregado

### Backprop manual — Gradientes

Capa 2: $\frac{\partial \mathcal{L}}{\partial W_2} = (\hat{A} H_1)^\top \frac{\partial \mathcal{L}}{\partial Z_2}$

Capa 1: $\frac{\partial \mathcal{L}}{\partial W_1} = (\hat{A} X)^\top \left[\frac{\partial \mathcal{L}}{\partial Z_2} W_2^\top \cdot \mathbb{1}[Z_1 > 0]\right]$

---

## Datasets

| Notebook | Dataset | N nodos | N aristas | Tarea |
|---|---|---|---|---|
| Finance | Red interbancaria sintética (BIS 2022) | 30 | ~85 | Clasificar riesgo sistémico |
| Supply | Red SC Perú (SUNAT 2022) | 45 | ~120 | Clasificar riesgo disruption + shock |

**Estructura red SC:**
- 15 proveedores (60% importados, LT: 8–60 días)
- 20 SKUs (cobertura: 7–45 días, 1–3 proveedores c/u)
- 10 almacenes (fill rate: 65–98%, 4 regiones)

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy scikit-learn
# No se requiere torch-geometric ni dgl — implementación manual
```

---

## Resultados clave

### Finance (Red interbancaria)
| Modelo | Test accuracy |
|---|---|
| MLP (sin grafo) | ~65% |
| GCN (2 capas) | ~80% |
| GraphSAGE | ~78% |

### Supply (Red SC Perú)
| Tipo de nodo | Accuracy GCN |
|---|---|
| Proveedor | ~85% |
| SKU | ~80% |
| Almacén | ~75% |

**Shock simulation:** 3 proveedores importados en crisis → X SKUs escalan a riesgo alto

---

## Pipeline operativo

```python
# 1. Construir grafo SC mensualmente
A = build_sc_adjacency(proveedores, skus, almacenes)
X = extract_node_features(lead_times, coberturas, fill_rates)

# 2. Predecir riesgo con GCN entrenada
gcn.load_weights('data/gcn_W1_supply.npy', 'data/gcn_W2_supply.npy')
risk_probs = gcn.forward(normalized_adjacency(A), X)

# 3. Si BOCPD (DS-02) alerta changepoint en proveedor P:
shock_results = propagate_shock(gcn, A, X, [P], shock_magnitude=2.0)
escalated = np.where(shock_results[-1].argmax(1) > risk_probs.argmax(1))[0]
alert(f"Disruption propagada a {len(escalated)} nodos downstream")
```

---

## Referencias

- Kipf, T.N. & Welling, M. (2017). "Semi-supervised classification with graph convolutional networks." *ICLR.*
- Hamilton, W., Ying, Z. & Leskovec, J. (2017). "Inductive representation learning on large graphs." *NeurIPS.*
- Veličković, P. et al. (2018). "Graph Attention Networks." *ICLR.*

---

**Anterior:** DS-02 · Changepoint Detection  
**Siguiente:** DS-04 · Conformal Prediction — intervalos garantizados para las predicciones de la GCN

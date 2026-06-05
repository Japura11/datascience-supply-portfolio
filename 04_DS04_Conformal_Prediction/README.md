# DS-04 | Conformal Prediction — Intervalos con Cobertura Garantizada

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10)  
**Autores:** Vovk, Gammerman & Shafer (1999-2002) · Romano et al. (2021 CQR)  
**Campo de origen:** Estadística matemática / Teoría de tests  
**Aplicación Supply:** Safety stock óptimo sin supuestos + prediction sets para clasificación GCN

---

## Estructura

```
12_DS04_Conformal_Prediction/
├── 1_Finance_Concept.ipynb      ← S&P 500 retornos — Split CP + CQR desde cero
├── 2_Supply_Adaptation.ipynb    ← SC Perú — SS/ROP garantizado + prediction sets GCN
├── README.md
└── data/
    ├── eda_sp500_cp.png
    ├── eda_supply_cp.png
    ├── dashboard_conformal_finance.png
    ├── dashboard_conformal_supply.png
    ├── sp500_conformal_intervals.csv
    ├── method_comparison.csv
    ├── sc_conformal_intervals.csv
    ├── cp_method_comparison_supply.csv
    └── safety_stock_comparison.csv
```

---

## Marco Teórico

### Garantía formal (sin supuestos distribucionales)

$$\mathbb{P}\!\left(Y_{n+1} \in \hat{C}_{\alpha}(X_{n+1})\right) \geq 1 - \alpha$$

Única condición: **intercambiabilidad** de las observaciones (más débil que i.i.d.)

### Split Conformal — el cuantil correcto

$$\hat{q} = \text{Quantile}\!\left(s_1,\ldots,s_{n_{\text{cal}}};\; \frac{\lceil(n_{\text{cal}}+1)(1-\alpha)\rceil}{n_{\text{cal}}}\right)$$

Score: $s_i = |Y_i - \hat{f}(X_i)|$ → intervalo simétrico de ancho constante.

### CQR — Conformalized Quantile Regression

Score adaptativo: $s_i = \max(\hat{q}_{\alpha/2}(X_i) - Y_i,\ Y_i - \hat{q}_{1-\alpha/2}(X_i))$

Intervalo: $[\hat{q}_{\alpha/2}(X) - \hat{q},\ \hat{q}_{1-\alpha/2}(X) + \hat{q}]$ — ancho varía con $X$.

### Prediction Sets para clasificación

Incluir clases en orden descendente de probabilidad hasta superar $\hat{q}$:
$$\hat{C}_{\alpha}(X) = \left\{c: \sum_{k: \hat{p}_{(k)}\geq \hat{p}_c} \hat{p}_{(k)} \leq \hat{q}\right\}$$

### Safety Stock conformal

$$SS_{CP} = \hat{q} \cdot \bar{D} \quad \text{(garantía ≥90%, sin suponer normalidad del LT)}$$

$$ROP_{CP} = (\hat{f}(X) + \hat{q}) \cdot \bar{D}$$

---

## Datasets

| Notebook | Dataset | N | Tarea |
|---|---|---|---|
| Finance | S&P 500 retornos 2018–2023 | ~1,200 días | Intervalos de predicción para returns |
| Supply | 3 series SC Perú (DS-02) | 80 semanas | SS/ROP + prediction sets para GCN |

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy scikit-learn
# CQR usa GradientBoostingRegressor(loss='quantile') de sklearn — sin dependencias extra
```

---

## Resultados clave

### Finance (S&P 500)
| Método | Cobertura real | Ancho medio |
|---|---|---|
| Gaussiano 90% | ~85% (bajo-cumple) | Constante |
| Split CP 90% | ≥90% garantizado | Constante |
| CQR 90% | ≥90% garantizado | **Adaptativo** (más estrecho en baja vol) |

### Supply Chain (Perú)
| Método | Cobertura LT | Safety Stock (und.) |
|---|---|---|
| Gaussiano z=1.645 | ~84% | Ver CSV |
| Split CP 90% | ≥90% | Ver CSV |
| CQR 90% | ≥90% | Ver CSV (±20% vs gaussiano) |

---

## Pipeline operativo

```python
# Semanal — combinado con DS-02 (changepoint) y DS-03 (GCN)
last_cp = detect_changepoint(lead_time_series)  # DS-02
X_train, Y_train = data[last_cp:]

sc = SplitConformal(RandomForestRegressor()).fit(X_train, Y_train)
sc.calibrate(X_cal, Y_cal, alpha=0.10)
lb, pred, ub = sc.predict(X_new)

SS  = (ub - pred) * demand_mean
ROP = ub * demand_mean

# Prediction set para nodos GCN (DS-03)
gcn_probs = gcn.forward(A_hat, X)[node_id]
pset = conformal_prediction_set(gcn_probs, q_hat_cls)
if 'Alto' in pset: alert("Auditar proveedor")
```

---

## Referencias

- Vovk, V., Gammerman, A. & Shafer, G. (2005). *Algorithmic Learning in a Random World.* Springer.
- Romano, Y., Patterson, E. & Candès, E. (2019). "Conformalized quantile regression." *NeurIPS.*
- Angelopoulos, A. & Bates, S. (2022). "A gentle introduction to conformal prediction." *arXiv:2107.07511.*

---

**Anterior:** DS-03 · Graph Neural Network  
**Siguiente:** DS-05 · Shapley Values — explicar por qué el safety stock cambió esta semana

# DS-07 | Semi-Supervised Learning — Aprender con Pocos Etiquetados

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10)  
**Autores:** Zhu & Ghahramani (2002, LP) · Zhou et al. (2006, LS) · Scudder (1965, Self-Training)  
**Campo de origen:** Aprendizaje automático / Estadística bayesiana  
**Aplicación Supply:** Clasificar riesgo de 94 proveedores sin auditoría usando 26 auditados

---

## Estructura

```
15_DS07_Semi_Supervised/
├── 1_Finance_Concept.ipynb      ← S&P 500 — regímenes de mercado, 15% etiquetados
├── 2_Supply_Adaptation.ipynb    ← SC Perú — 120 proveedores, 22% auditados
├── README.md
└── data/
    ├── eda_regimes.png
    ├── eda_suppliers_sc.png
    ├── dashboard_ssl_finance.png
    ├── dashboard_ssl_supply.png
    ├── ssl_method_comparison.csv
    ├── threshold_sensitivity.csv
    ├── self_training_history.csv
    ├── supplier_risk_classification.csv
    ├── audited_suppliers_loo.csv
    └── ssl_comparison_supply.csv
```

---

## Marco Teórico

### Label Propagation — difusión iterativa (Zhu & Ghahramani, 2002)

$$F^{(t+1)} = \alpha \cdot S \cdot F^{(t)} + (1-\alpha) \cdot Y_L$$

donde $S = D^{-1/2}WD^{-1/2}$ es el grafo normalizado, $\alpha \in (0,1)$, y $Y_L$ ancla los nodos etiquetados.

**Convergencia:** $F^* = (I - \alpha S)^{-1}(1-\alpha)Y_L$

### Self-Training con threshold de confianza

```
Repetir hasta convergencia:
  1. Entrenar f sobre L
  2. Predecir U: ŷ = argmax p(y|x)
  3. Agregar a L: {(x,ŷ) : max_c p(c|x) ≥ τ}
  4. Eliminar de U los agregados
```

Threshold óptimo τ* ∈ [0.75, 0.85] — balanceo cobertura/precisión.

### Las 3 hipótesis del SSL

1. **Suavidad:** puntos cercanos → misma etiqueta
2. **Cluster:** puntos del mismo cluster → misma etiqueta  
3. **Manifold:** las etiquetas varían suavemente sobre el manifold

---

## Datasets

| Notebook | Dataset | Etiquetados | No etiquetados | Tarea |
|---|---|---|---|---|
| Finance | S&P 500 + VIX 2010–2023 (3,500 días) | 15% (525 d) | 55% (1,925 d) | Régimen: Bull/Corrección/Crisis |
| Supply | 120 proveedores SC Perú | 22% (26 prov) | 78% (94 prov) | Riesgo: Bajo/Medio/Alto |

---

## Resultados clave

### Finance (Regímenes de mercado)
| Método | Accuracy | Mejora vs sup. |
|---|---|---|
| Supervisado (15%) | baseline | — |
| Label Propagation | +5–12 pp | Cierra ~60% del gap |
| Self-Training τ=0.80 | +4–10 pp | Similar a LP |
| Oracle (70%) | techo | — |

### Supply (Proveedores)
| Método | Acc. no auditados | LOO CV auditados |
|---|---|---|
| Supervisado RF | baseline | baseline |
| Label Propagation | +6–15 pp | +4–10 pp |
| Self-Training GBM | +4–12 pp | — |

**Plan de auditorías generado:**
- URGENTE: proveedores de alto riesgo (conf > 0.75)
- PROGRAMAR: riesgo medio o prediction set ambiguo
- MONITOREO: bajo riesgo, KPIs estándar

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy scikit-learn
# No requiere librerías SSL especializadas — implementación manual
```

---

## Conexión con la cadena DS-02 → DS-07

```python
# DS-07 recibe el grafo de DS-03 y las etiquetas de auditoría
# Output: clasificación de riesgo para todos los proveedores

lp = LabelPropagation(alpha=0.85, n_neighbors=12)
lp.fit(X_all_proveedores, labeled_mask, Y_auditados)
risk_labels = lp.predict(unlabeled_indices)
plan_auditoria = prioritize_audits(risk_labels, confidence=lp.predict_proba(unlabeled_indices).max(1))
```

---

## Referencias

- Zhu, X. & Ghahramani, Z. (2002). "Learning from Labeled and Unlabeled Data with Label Propagation." *CMU Technical Report.*
- Zhou, D. et al. (2004). "Learning with Local and Global Consistency." *NeurIPS.*
- Chapelle, O., Schölkopf, B. & Zien, A. (2006). *Semi-Supervised Learning.* MIT Press.

---

**Anterior:** DS-06 · Bayesian Optimization  
**Siguiente:** DS-08 · Autoencoder Anomaly Detection — detectar proveedores atípicos que no encajan en ninguna clase

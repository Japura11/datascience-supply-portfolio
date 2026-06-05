# DS-05 | Shapley Values & SHAP — Explicabilidad Cuantitativa

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10)  
**Autor original:** Lloyd Shapley (1953, Nobel 2012) · Lundberg & Lee (SHAP, 2017)  
**Campo de origen:** Teoría de juegos cooperativa  
**Aplicación Supply:** Atribución causal de OTD, Delay y Safety Stock por feature y semana

---

## Estructura

```
13_DS05_Shapley_Values/
├── 1_Finance_Concept.ipynb      ← Portafolio Fama-French — atribución P&L por factor
├── 2_Supply_Adaptation.ipynb    ← SC Perú — SHAP para OTD, Delay, SS + narrativa CFO
├── README.md
└── data/
    ├── eda_portfolio_ff.png
    ├── eda_supply_shap.png
    ├── dashboard_shap_finance.png
    ├── dashboard_shap_supply.png
    ├── portfolio_shap_values.csv
    ├── global_importance.csv
    ├── waterfall_representative.csv
    ├── shap_critical_weeks.csv
    ├── global_importance_supply.csv
    └── cfo_delta_shap.csv
```

---

## Marco Teórico

### Fórmula de Shapley (axiomática, 1953)

$$\phi_i = \sum_{S \subseteq N \setminus \{i\}} \frac{|S|!(n-|S|-1)!}{n!}\left[v(S \cup \{i\}) - v(S)\right]$$

### Los 4 axiomas (Young, 1988) — únicos que los satisfacen simultáneamente

| Axioma | Fórmula |
|---|---|
| Eficiencia | $\sum_i \phi_i = f(x) - f(\bar{x})$ |
| Simetría | Features igualmente útiles → mismo SHAP |
| Vacío | Feature irrelevante → SHAP = 0 |
| Aditividad | $\phi_i(v+w) = \phi_i(v) + \phi_i(w)$ |

### KernelSHAP — regresión ponderada (Lundberg & Lee, 2017)

Peso de Shapley: $\pi(z) = \frac{n-1}{\binom{n}{|z|}|z|(n-|z|)}$

Solución: $\phi = \arg\min_\phi \sum_z \pi(z)\left[f(x_z) - \phi_0 - \sum_j z_j\phi_j\right]^2$

### Safety Stock via SHAP

$$SS_t - \overline{SS} = \phi_{LT,t} + \phi_{\sigma_D,t} + \phi_{P_{FOB},t} + \phi_{r_{BCRP},t} + \ldots$$

El waterfall SHAP es directamente el estado de causas del safety stock — legible para el CFO.

---

## Datasets

| Notebook | Dataset | N | Tarea |
|---|---|---|---|
| Finance | Portafolio Fama-French 500 activos | 500 activos | Atribuir retorno mensual por factor |
| Supply | Portfolio B2B Perú 200 cuentas × 80 semanas | 16,000 obs | Explicar OTD/Delay/SS por feature y semana |

---

## Resultados clave

### Finance — Importancia global (portafolio Fama-French)
| Feature | |SHAP| medio |
|---|---|
| `mkt_beta` | Dominante (factor sistemático) |
| `vol_30d` | Segundo — efecto negativo consistente |
| `hml` | Tercero — value premium |

### Supply — Top feature por KPI (semana post-changepoint)
| KPI | Feature dominante | Dirección |
|---|---|---|
| OTD | Lead time | Negativa (LT largo baja OTD) |
| Delay | Lead time | Positiva (LT largo aumenta delay) |
| SS | Lead time + Precio FOB | Positiva (ambos aumentan SS) |

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy scikit-learn
# No requiere la librería shap — implementación manual de KernelSHAP
```

---

## Pipeline operativo

```python
# Semanal — disparado por BOCPD (DS-02) cuando hay alerta
gbm_otd.fit(X_train, Y_otd_train)
phi = kernel_shap(gbm_otd, x_week_avg, X_train, M=256, feature_names=features)

# Narrativa automática para el CFO
top_detractors = sorted(phi.items(), key=lambda x: x[1])[:3]
for fn, v in top_detractors:
    print(f"  {fn} contribuyó {v*100:+.2f} pp al OTD")
```

---

## Referencias

- Shapley, L.S. (1953). "A value for n-person games." *Contributions to the Theory of Games.*
- Young, H.P. (1985). "Monotonic solutions of cooperative games." *IJGT.*
- Lundberg, S.M. & Lee, S.I. (2017). "A unified approach to interpreting model predictions." *NeurIPS.*
- Lundberg, S.M. et al. (2019). "Explainable ML predictions for the prevention and management of sepsis." *Nature Biomedical Engineering.*

---

**Anterior:** DS-04 · Conformal Prediction  
**Siguiente:** DS-06 · Bayesian Optimization — optimizar la política de inventario con mínimas evaluaciones

# DS-06 | Bayesian Optimization — Optimización con Pocas Evaluaciones

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10)  
**Autores:** Kushner (1964) · Mockus (1975) · Jones et al. (1998) · Snoek et al. (2012)  
**Campo de origen:** Estadística Bayesiana / Optimización sin derivadas  
**Aplicación Supply:** Política óptima (SS, ROP, Q) minimizando TC con restricción de SL

---

## Estructura

```
14_DS06_Bayesian_Optimization/
├── 1_Finance_Concept.ipynb      ← S&P 500 — calibración estrategia mean-reversion
├── 2_Supply_Adaptation.ipynb    ← SC Perú — política inventario óptima (SS, ROP, Q)
├── README.md
└── data/
    ├── eda_gp_illustration.png
    ├── eda_inventory_sc.png
    ├── dashboard_bo_finance.png
    ├── dashboard_bo_supply.png
    ├── bo_evaluations_finance.csv
    ├── bo_results_comparison.csv
    ├── bo_inventory_evaluations.csv
    └── optimal_policy_comparison.csv
```

---

## Marco Teórico

### Proceso Gaussiano — Prior sobre la función objetivo

$$\mu(x^*) = k(x^*, X)\left[K(X,X) + \sigma_n^2 I\right]^{-1} y$$
$$\sigma^2(x^*) = k(x^*,x^*) - k(x^*,X)\left[K(X,X) + \sigma_n^2 I\right]^{-1}k(X,x^*)$$

### Kernel RBF

$$k(x,x') = \sigma_f^2 \exp\!\left(-\frac{\|x-x'\|^2}{2\ell^2}\right)$$

### Funciones de Adquisición

**UCB:** $UCB(x) = \mu(x) + \kappa_t \sigma(x)$ donde $\kappa_t = \kappa\sqrt{\ln(t+2)}$

**EI:** $EI(x) = (\mu(x)-f^+)\Phi(Z) + \sigma(x)\phi(Z)$ donde $Z = \frac{\mu(x)-f^+}{\sigma(x)}$

### Función de Costo SC

$$TC(SS, ROP, Q) = h\!\left(SS + \frac{Q}{2}\right) + \frac{D \cdot K}{Q} + p \cdot D \cdot \beta(SS,ROP,Q)$$

---

## Datasets

| Notebook | Dataset | Función objetivo | N evaluaciones |
|---|---|---|---|
| Finance | S&P 500 diario 2015–2023 | Sharpe ratio (backtest) | 38 |
| Supply | Simulación SC Perú (DS-02 calibrada) | TC semanal (simulación) | 33 |

---

## Resultados clave

### Finance (estrategia mean-reversion)
| Método | Mejor Sharpe | N evaluaciones |
|---|---|---|
| Random Search | baseline | 38 |
| BO UCB | +15–30% vs RS | 38 |
| Grid Search equivalente | igual a RS | ~10,000 |

### Supply Chain (política de inventario)
| Método | TC semanal (USD) | Service Level | Ahorro |
|---|---|---|---|
| Clásico gaussiano z=1.645 | baseline | ~94% | — |
| BO UCB (óptimo) | -8–15% | ≥90% garantizado | Ver CSV |
| Random Search | -3–5% | Variable | Ver CSV |

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy scikit-learn
# No requiere botorch ni optuna — GP + UCB/EI implementados desde cero
```

---

## Pipeline operativo

```python
# Después de DS-02 detecta changepoint de lead time:
new_lt_mean = 6.5  # semanas (régimen nuevo)

# BO encuentra la política óptima en ~33 simulaciones
result = bayesian_optimize(
    f = lambda ss, rop, q: -simulate_inventory(ss, rop, q, lt_mean=new_lt_mean)['tc'],
    bounds = [(50,600), (500,5000), (100,1500)],
    n_init=8, n_iter=25, acq_type='ucb'
)
print(f"SS*={result['best_x'][0]:.0f}  ROP*={result['best_x'][1]:.0f}  Q*={result['best_x'][2]:.0f}")
```

---

## Referencias

- Kushner, H. (1964). "A new method of locating the maximum point of an arbitrary multipeak curve." *ASME J. Basic Eng.*
- Mockus, J. (1975). "On Bayesian methods for seeking the extremum." *IFIP Tech. Committee on Optimization.*
- Jones, D.R., Schonlau, M. & Welch, W.J. (1998). "Efficient global optimization of expensive black-box functions." *J. Global Optim.*
- Snoek, J., Larochelle, H. & Adams, R.P. (2012). "Practical Bayesian optimization of ML algorithms." *NeurIPS.*

---

**Anterior:** DS-05 · Shapley Values  
**Siguiente:** DS-07 · Semi-Supervised Learning — etiquetar proveedores sin auditoría completa

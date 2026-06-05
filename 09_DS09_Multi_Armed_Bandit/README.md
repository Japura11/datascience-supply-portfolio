# DS-09 | Multi-Armed Bandit — Selección Óptima bajo Incertidumbre

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10)  
**Autores:** Robbins (1952) · Lai & Robbins (1985) · Auer et al. (2002 UCB1) · Thompson (1933 TS)  
**Campo de origen:** Estadística / Teoría de decisión secuencial  
**Aplicación Supply:** Selección dinámica del mejor proveedor alternativo cuando DS-08 detecta anomalía

---

## Estructura

```
17_DS09_Multi_Armed_Bandit/
├── 1_Finance_Concept.ipynb      ← 5 estrategias trading — T=1000 días
├── 2_Supply_Adaptation.ipynb    ← 8 proveedores alternativos SC Perú — T=60 semanas
├── README.md
└── data/
    ├── eda_bandit_finance.png
    ├── eda_mab_supply.png
    ├── dashboard_mab_finance.png
    ├── dashboard_mab_supply.png
    ├── mab_simulation_finance.csv
    ├── mab_results_summary.csv
    ├── mab_sc_simulation.csv
    └── mab_supplier_summary.csv
```

---

## Marco Teórico

### Regret acumulado

$$R_T = \sum_{t=1}^{T}[\mu^* - \mu_{a_t}] = T\mu^* - \sum_{t=1}^T r_t$$

### UCB1 (Auer et al., 2002) — garantía O(log T)

$$a_t = \arg\max_k\left[\hat{\mu}_k + c\sqrt{\frac{\ln t}{N_k(t)}}\right]$$

Regret garantizado: $R_T \leq 8\sum_{k:\Delta_k>0}\frac{\ln T}{\Delta_k} + O(K)$

### Thompson Sampling — posterior Gaussiana

$$\tilde{\mu}_k \sim \mathcal{N}\!\left(\hat{\mu}_k,\ \frac{\hat{\sigma}_k^2}{N_k}\right), \quad a_t = \arg\max_k \tilde{\mu}_k$$

### Cota de Lai & Robbins (1985)

$$R_T \geq \sum_{k:\Delta_k>0} \frac{\sigma_k^2}{2\Delta_k^2}\ln T + o(\ln T)$$

Ningún algoritmo puede hacer mejor — UCB1 y TS son asintóticamente óptimos.

---

## Datasets

| Notebook | Brazos | T | Recompensa |
|---|---|---|---|
| Finance | 5 estrategias trading (μ: 0.03%–0.08%/día) | 1,000 días | Retorno diario |
| Supply | 8 proveedores SC Perú | 60 semanas | Utilidad compuesta (LT + precio + FR) |

---

## Resultados

### Finance (T=1,000)
| Algoritmo | % brazo óptimo | Regret final |
|---|---|---|
| ε-Greedy fijo | ~85% | Mayor |
| ε-Greedy decay | ~92% | Intermedio |
| UCB1 | ~95% | Bajo |
| Thompson Sampling | ~96% | Mínimo |

### Supply (T=60)
| Algoritmo | % proveedor óptimo | Regret final |
|---|---|---|
| ε-Greedy (ε=0.15) | baseline | Mayor |
| UCB1 | mejor que EG | Intermedio |
| Thompson Sampling | mayor % óptimo | Menor |

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy
# ε-Greedy, UCB1 y Thompson Sampling implementados desde cero — sin librerías bandit
```

---

## Flujo operativo completo DS-02 → DS-09

```python
# Activado cuando DS-08 detecta anomalía en proveedor habitual
agent = ThompsonSampling(K=8, mu_0=0.5, sigma_known=0.05)

for semana in range(n_semanas_crisis):
    k = agent.select_arm()                    # elegir proveedor alternativo
    lt, precio, fr = hacer_pedido(proveedor=k) # observar recompensa real
    u = utility(lt, precio, fr)
    agent.update(k, u)                         # actualizar posterior
    log(semana, k, u, agent.means)             # registrar para DS-05 SHAP
```

---

## Referencias

- Robbins, H. (1952). "Some aspects of the sequential design of experiments." *Bull. AMS.*
- Lai, T.L. & Robbins, H. (1985). "Asymptotically efficient adaptive allocation rules." *Advances in Applied Mathematics.*
- Auer, P., Cesa-Bianchi, N. & Fischer, P. (2002). "Finite-time analysis of the multiarmed bandit problem." *Machine Learning.*
- Chapelle, O. & Li, L. (2011). "An empirical evaluation of Thompson Sampling." *NeurIPS.*

---

**Anterior:** DS-08 · Autoencoder Anomaly Detection  
**Siguiente:** DS-10 · NLP Logístico — extracción automática de ETA y alertas desde documentos de importación

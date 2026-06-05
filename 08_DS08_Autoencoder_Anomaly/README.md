# DS-08 | Autoencoder Anomaly Detection

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10)  
**Autores:** Rumelhart, Hinton & Williams (1986) · Kingma & Welling (2013 VAE) · An & Cho (2015)  
**Campo de origen:** Redes neuronales / Compresión de información  
**Aplicación Supply:** Detectar proveedores con patrones atípicos no clasificables por DS-07

---

## Estructura

```
16_DS08_Autoencoder_Anomaly/
├── 1_Finance_Concept.ipynb      ← S&P 500 — AE + VAE para anomalías de mercado
├── 2_Supply_Adaptation.ipynb    ← SC Perú — AE para 3 tipos de anomalías en proveedores
├── README.md
└── data/
    ├── eda_market_anomalies.png
    ├── eda_supplier_anomalies.png
    ├── dashboard_ae_finance.png
    ├── dashboard_ae_supply.png
    ├── market_anomaly_scores.csv
    ├── ae_method_comparison.csv
    ├── supplier_anomaly_scores.csv
    ├── executive_action_plan.csv
    └── anomaly_detection_by_type.csv
```

---

## Marco Teórico

### Autoencoder — pérdida de reconstrucción

$$\mathcal{L}_{AE} = \frac{1}{n}\sum_{i=1}^{n}\|x_i - g_\phi(f_\theta(x_i))\|^2$$

**Score de anomalía:** $s(x) = \|x - \hat{x}\|^2$ — alto para datos no vistos en entrenamiento.

### VAE — ELBO loss (Kingma & Welling, 2013)

$$\mathcal{L}_{VAE} = \mathbb{E}_q[\log p(x|z)] - D_{KL}(q_\theta(z|x) \| p(z))$$

$$D_{KL} = -\frac{1}{2}\sum_{j}\left(1 + \log\sigma_j^2 - \mu_j^2 - \sigma_j^2\right)$$

**Score VAE:** $s_{VAE}(x) = \|x - \hat{x}\|^2 + \lambda \cdot D_{KL}$

### Umbral con Conformal Prediction (DS-04)

$$\tau_{CP} = \text{Quantile}(s_{\text{val\_normal}}; \lceil(n+1)(1-\alpha)\rceil/n)$$

Garantía: FPR en datos normales ≤ α — exactamente.

---

## Los 3 tipos de anomalías en SC

| Tipo | Descripción | Detectable con |
|---|---|---|
| 1 — Nivel | LT medio súbitamente alto | PELT (DS-02) ✓ + AE ✓ |
| 2 — Varianza | σ(LT) se dispara | PELT (DS-02) parcial + AE ✓ |
| 3 — Patrón | Perfil temporal inusual, media/σ normales | **Solo AE ✓** |

El Tipo 3 es la contribución única del DS-08. DS-02, DS-07 y las estadísticas simples no lo capturan.

---

## Datasets

| Notebook | Dataset | Normal | Anómalos | Tarea |
|---|---|---|---|---|
| Finance | S&P 500 + VIX 2010–2023 (3,400 días) | ~90% | ~10% | Crashes y correcciones extremas |
| Supply | 120 proveedores × 60 semanas SC Perú | 86% | 14% | 3 tipos de anomalías en LT |

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy scikit-learn
# Autoencoder + VAE implementados desde cero con NumPy — sin PyTorch ni TensorFlow
```

---

## Plan de acción integrado DS-07 + DS-08

```python
# Para cada proveedor i:
if ae_score[i] > tau_cp:
    accion = "ANOMALÍA — INVESTIGAR"  # DS-08
elif ds07_label[i] == 'Alto':
    accion = "URGENTE — Auditar < 4 sem"  # DS-07
elif ds07_label[i] == 'Medio':
    accion = "PROGRAMAR — Plan trimestral"  # DS-07
else:
    accion = "MONITOREO — KPIs estándar"   # DS-07
```

---

## Referencias

- Rumelhart, D.E., Hinton, G.E. & Williams, R.J. (1986). "Learning representations by back-propagating errors." *Nature.*
- Kingma, D.P. & Welling, M. (2013). "Auto-encoding variational Bayes." *ICLR 2014.*
- An, J. & Cho, S. (2015). "Variational autoencoder based anomaly detection using reconstruction probability." *SNU Tech. Report.*

---

**Anterior:** DS-07 · Semi-Supervised Learning  
**Siguiente:** DS-09 · Multi-Armed Bandit — selección dinámica del mejor proveedor alternativo

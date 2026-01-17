import pandas as pd # type: ignore
import numpy as np # type: ignore
from sklearn.model_selection import train_test_split # type: ignore
from sklearn.neural_network import MLPRegressor # type: ignore
from sklearn.preprocessing import StandardScaler # type: ignore

data = pd.read_excel("dane.xlsx")

X = data.iloc[:, :3].values
Y = data.iloc[:, 3].values

X_train, X_test, Y_train, Y_test = train_test_split(
    X, Y, test_size=0.2, random_state=42
)

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

hidden_layers = [10, 30, 50]
learning_rates = [0.01, 0.05]

results = []

for h in hidden_layers:
    for lr in learning_rates:
        model = MLPRegressor(
            hidden_layer_sizes=(h,),
            activation='tanh',
            solver='adam',
            max_iter=1000,
            learning_rate_init=lr,
            random_state=42
        )
        model.fit(X_train_scaled, Y_train)
        y_pred = model.predict(X_test_scaled)

        R = np.corrcoef(Y_test, y_pred)[0, 1]
        MAPE = np.mean(np.abs((Y_test - y_pred) / Y_test))

        results.append([h, lr, R, MAPE])
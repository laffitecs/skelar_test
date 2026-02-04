# Currency Exchange Rates ETL Pipeline

Airflow DAG для збору історичних курсів валют з Open Exchange Rates API та збереження в PARQUET файли.

## Що робить проект

- Збирає курси 169 валют відносно USD
- Історичні дані з 1 липня 2025 року
- Щоденне оновлення
- Зберігає в партиціоновані PARQUET файли

## Встановлення залежностей (опціонально)

Якщо хочете запустити без Docker або розробляти локально:

```bash
# Створити віртуальне середовище
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# або
venv\Scripts\activate     # Windows

# Встановити залежності
pip install -r requirements.txt
```

**Примітка:** При використанні Docker всі залежності встановлюються автоматично.

## Швидкий старт

### 1. Клонувати проект
```bash
git clone <repository-url>
cd skelar_test/task_3
```

### 2. Запустити Docker
```bash
docker-compose up -d
```

### 3. Відкрити Airflow UI
- URL: http://localhost:8082
- Логін: `admin`
- Пароль: `admin`

### 4. Активувати DAG
1. Знайти DAG `currency_rates`
2. Натиснути toggle для активації
3. DAG автоматично почне обробку всіх дат з 1 липня 2025

## Структура проекту

```
task_3/
├── docker-compose.yml      # Docker конфігурація
├── dags/
│   └── currency_dag.py     # Airflow DAG
├── utilits/
│   └── fetch_data.py       # API функції
├── data/                   # PARQUET файли (створюється автоматично)
│   ├── date=2025-07-01/
│   ├── date=2025-07-02/
│   └── ...
└── README.md
```

## Результат

PARQUET файли з структурою:
```
base     | currency | rate      | date
---------|----------|-----------|----------
USD      | EUR      | 0.85      | 2025-07-01
USD      | GBP      | 0.73      | 2025-07-01
USD      | UAH      | 41.25     | 2025-07-01
...
```

## Налаштування API ключа

1. Зареєструватися на https://openexchangerates.org/
2. Отримати безкоштовний API ключ
3. Замінити в `utilits/fetch_data.py`:
```python
params = {'app_id': 'YOUR_API_KEY_HERE'}
```

## Команди Docker

```bash
# Запустити
docker-compose up -d

# Переглянути логи
docker logs airflow_test

# Зупинити
docker-compose down

# Перезапустити
docker-compose restart
```

## Перегляд даних

```python
import pandas as pd

# Читати PARQUET файл
df = pd.read_parquet('data/date=2025-07-01/exchange_rates.parquet')
print(df.head())
```


## Обмеження API

Open Exchange Rates безкоштовний план:
- 1000 запитів/місяць
- Історичні дані доступні
- 169 валют

## Troubleshooting

**DAG не з'являється:**
- Перевірити логи: `docker logs airflow_test`
- Перевірити синтаксис Python в DAG файлі

**Помилка API:**
- Перевірити API ключ
- Перевірити ліміти запитів

**Немає PARQUET файлів:**
- Перевірити папку `data/`
- Перевірити статус тасків в Airflow UI

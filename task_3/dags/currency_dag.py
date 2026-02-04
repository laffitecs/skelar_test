from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
import sys
sys.path.append('/opt/airflow/utilits')
import os
import pyarrow as pa
import pyarrow.parquet as pq
from fetch_data import fetch_exchange_rates

default_args = {
    'start_date': datetime(2025, 7, 1),
    'retries': 1,
}

dag = DAG(
    'currency_rates',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=True,
)

def save_to_parquet(**context):
    date_str = context['ds']
    
    output_dir = f"/data/date={date_str}"
    os.makedirs(output_dir, exist_ok=True)
    
    data = fetch_exchange_rates(date_str)

    records = []
    for currency, rate in data['rates'].items():
        records.append({
            'base': data['base'],
            'currency': currency,
            'rate': rate,
            'date': date_str
        })

    table = pa.Table.from_pylist(records)
    output_path = f"/data/date={date_str}/exchange_rates.parquet"
    pq.write_table(table, output_path)

PythonOperator(
    task_id='save_rates',
    python_callable=save_to_parquet,
    dag=dag,
)

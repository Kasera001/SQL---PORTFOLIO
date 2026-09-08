import pandas as pd
from sqlalchemy import create_engine

df_clean = pd.read_csv(r"C:\Users\ADMIN\Downloads\WA_Fn-UseC_-Telco-Customer-Churn.csv")
df_clean['TotalCharges'] = pd.to_numeric(df_clean['TotalCharges'], errors='coerce').fillna(0)
df_clean.drop(columns=['customerID'], inplace=True)

# root with no password is XAMPP's default - adjust if you've set one
engine = create_engine('mysql+pymysql://root:@localhost/telco_churn')

df_clean.to_sql('customers', engine, if_exists='replace', index=False)
print("Done — table created.")
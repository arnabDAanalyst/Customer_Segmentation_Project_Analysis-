import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


customers = pd.read_csv("customers.csv")
customers.head(10)
customers.info()

orders = pd.read_csv("orders.csv")
orders.head(10)
orders.info()


df = orders.merge(customers, on="customer_id",how="left")


# 1. Which customers generate the highest revenue?

customer_revenue = df.groupby("customer_id")["total_amount"].sum().sort_values(ascending=False)

customer_revenue.head(5)


#2. What is the total revenue and average order value (AOV)?
df = orders.merge(customers, on='customer_id', how ='inner')

total_revenue =df["total_amount"].sum()

avg_order_value = df["total_amount"].mean()

total_revenue, round(avg_order_value, 2)


# 3.Which product category contributes the most revenue?

category_revenue=df.groupby("category")["total_amount"].sum().sort_values(ascending=False)

plt.figure(figsize=(10,7))
category_revenue.plot(kind="bar")
plt.title("Revenue by Product Category")
plt.xlabel("Category")
plt.ylabel("Revenue")
plt.show()



#4. How frequently do customers purchase?

purchase_frequency=df.groupby("customer_id")["order_id"].count()
purchase_frequency.describe()


# 5.Do repeat customers spend more than one-time customers?

customer_summary = df.groupby("customer_id").agg(
    
    total_orders = ("order_id","count"),
    total_spent = ("total_amount","sum")
)


customer_summary["customer_type"]= np.where(
    customer_summary["total_orders"] > 1,
    "Repeat Customer",
    "One-time Customer"
)

customer_summary.groupby("customer_type")["total_spent"].mean()



# 6.Customer Segmentation Based on Spending

def segment_customer(spent):
    if spent > 50000:
        return "High Value Spent"
    elif spent >= 20000:
        return "Medium Value Spent"
    else:
        return "Low Value Spent"
    
customer_summary["spending_segment"] = customer_summary["total_spent"].apply(segment_customer)

customer_summary["spending_segment"].value_counts()

sns.countplot(data=customer_summary, x="spending_segment")
plt.title("Customer Spending Segments")
plt.show()



# 7.Which age group spends the most?
df["age_group"] = pd.cut(
    df["age"],
    bins=[18, 25, 35, 45, 60],
    labels=["18-25", "26-35", "36-45", "46+"]
)

df.groupby("age_group")["total_amount"].sum().sort_values(ascending=False)

sns.barplot(data=df, x="age_group", y="total_amount", estimator=np.sum)
plt.title("Revenue by Age Group")
plt.show()



# 8.Which cities generate the highest revenue?

city_revenue = df.groupby("city")["total_amount"].sum().sort_values(ascending=False).head(3)
city_revenue


# 9.What is the monthly revenue trend?

df["order_date"] = pd.to_datetime(df["order_date"])
df["order_month"] = df["order_date"].dt.to_period("M")

monthly_revenue = df.groupby("order_month")["total_amount"].sum()

plt.figure(figsize=(10,7))
monthly_revenue.plot(kind="line", marker='o')
plt.title("Monthly Revenue Trend")
plt.xlabel("Month")
plt.ylabel("Revenue")
plt.show()



# 10. Which customer segment contributes the most revenue?

segment_revenue = customer_summary.groupby("spending_segment")["total_spent"].sum().sort_values(ascending=False)

segment_revenue

segment_revenue.plot(kind="pie",autopct="%1.1f%%", figsize=(10,6))
plt.title("Revenue Contribution by Customer Segment")
plt.ylabel("")
plt.show()



# 11.Who are the top 10% revenue-generating customers? 

customer_revenue  = df.groupby("customer_id")["total_amount"].sum().reset_index()

threshold = customer_revenue["total_amount"].quantile(0.9)

top_10_percent_customers = customer_revenue[customer_revenue["total_amount"] >= threshold]

plt.figure(figsize=(10,7))
sns.barplot(data=top_10_percent_customers, x="customer_id", y="total_amount")
plt.title("Top 10% Revenue-Generating Customers")
plt.xlabel("Customer ID")
plt.ylabel("Total Revenue")
plt.show()



# 12.Which product category should market focus on? 

category_revenue = df.groupby("category")["total_amount"].sum().sort_values(ascending=False).reset_index()

sns.barplot(data=category_revenue, x="category", y="total_amount")
plt.title("Market Focus on Product Category")
plt.xlabel("Category")
plt.ylabel("Revenue")
plt.show()



# 13.Are Repeat Customers More Valuable Than New Ones?

customer_summary["cutomer_type"] = np.where(
    customer_summary["total_orders"] > 1,
    "Repeat Customer",
    "New Customer"
)
sns.boxplot(data=customer_summary.reset_index(), x="cutomer_type", y="total_spent")

plt.title("Revenue Comparison Repeat vs New Customers")
plt.xlabel("Customer Type")
plt.ylabel("Total Spent")
plt.show()
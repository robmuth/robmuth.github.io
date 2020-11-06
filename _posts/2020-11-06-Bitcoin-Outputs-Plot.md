---
title: Plotting the Sum of All Bitcoin Transactions per Month
category: Blockchain
tags: [Analysis, Bitcoin]
---

# Plotting the Sum of All Bitcoin Transactions per Month

A Bitcoin transaction takes one or more input addresses and specifies how they will be transferred to one or more output addresses. An input/output can be understood as a pair of a Bitcoin address and a certain amount of Bitcoin cryptocurrency value. If there is a difference between input and output of a single transaction, the corresponding Bitcoins will be transferred to the miner (so-called *mining fee*).

## For example:
Address ```0x12 34 56``` has 1 Bitcoin and address ```0xCA FE AF``` has 2 Bitcoins.

The owner of the keys to both addresses can now transfer 3 Bitcoins to a single address or split it over several addresses with a single transaction in arbitrary proportions.

## Sum up with SQL and Google BigQuery
The ```crypto_bitcoin.transactions``` table in the Google BigQuery public dataset contains all Bitcoin transactions (6th Nov 2020: 584.284.605 TXs[^```SELECT COUNT(*) FROM `bigquery-public-data.crypto_bitcoin.transactions```]).

We can now use the power of SQL and just sum up all output values per month with a clever GROUP-BY.

**Summing up:**

```sql
SELECT
  -- Convert timestamp to String and take the first 7 characters (year and month)
  SUBSTR(CAST(DATE(block_timestamp_month) AS STRING), 0, 7) as month,
  -- sum all Bitcoin outputs
  CAST(SUM(output_value) / POW(10, 8) AS INT64) AS output_sum, 
FROM `bigquery-public-data.crypto_bitcoin.transactions`
GROUP BY block_timestamp_month -- Sum all transactions per month
ORDER BY month DESC -- Order by month (descending)
```

**Plotting:**
For plotting I prefer querying the data into a Jupyter Notebook. Here you can check out how to query SQL data in Google Colaboratory, transforming it into a Pandas Dataframe, and plot the results: [https://colab.research.google.com/drive/1BfYlPSC7nwG5JxGj13OxPFsQY7efXXI6?usp=sharing](https://colab.research.google.com/drive/1BfYlPSC7nwG5JxGj13OxPFsQY7efXXI6?usp=sharing)

Let's have a look:

![Bitcoin outputs (06-11-2020)](/static/2020-11-06-Bitcoin-Outputs.png)

[//]: # ( #Blockchain #Blog )

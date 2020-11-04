---
title: Blockchain Analysis with Google BigQuery and Colaboratory
category: Blockchain
tags: [Analysis]
---

Blog: Blockchain Analysis with Google BigQuery and Colaboratory
================================
Blockchain analytics usually require fully synchronized nodes, which makes it sometimes quite challenging. Especially, if you want to analyze multiple different blockchains. Storage consumption, networking, and computational power are still major bottlenecks of blockchain technologies.

With [Google Cloud](https://cloud.google.com) and its [BigQuery](https://console.cloud.google.com/bigquery) service one can access most of the blockchain data of selected blockchains (at the time of writing, 2020-11-04):

- Bitcoin
- Ethereum
- Ethereum Classic
- Bitcoin Cash
- Dash
- Dogecoin
- Litecoin
- Zcash

> Disclaimer: Google Cloud Platform is not free. Usage might be subject to a fee.

## Example: Analyze the average block generation rates
The blockchains are available in the *bigquery-public-data* dataset and can be queried with SQL. Due to the different protocols of the blockchains, each database contains different tables. Most of them have a *blocks* and *transactions* table, of course.

In the following Google Colaboratory Jupyter Notebook I demonstrate how to analyze Bitcoin and other blockchains to find our the overall block generation rates: [https://colab.research.google.com/drive/1uef85IDe3a37--Jqt1cQfXS8MmHXCkS9?usp=sharing](https://colab.research.google.com/drive/1uef85IDe3a37--Jqt1cQfXS8MmHXCkS9?usp=sharing)

It uses a very simple SQL command which is explained in detail in the Colab notebook. Querying Bitcoin's average block generation rate, for example:

```sql
SELECT 
   AVG(UNIX_SECONDS(n.timestamp) - (SELECT UNIX_SECONDS(pre.timestamp) 
      FROM `bigquery-public-data.crypto_bitcoin.blocks` pre WHERE pre.number = n.number - 1)
   )
FROM `bigquery-public-data.crypto_bitcoin.blocks` n
WHERE n.number > 0
```


### Result: Block generation rates

```
Bitcoin             569 sec.
Bitcoin Cash        565 sec.
Dash                156 sec.
Dogecoin             62 sec.
Ethereum            143 sec.
Ethereum Classic    139 sec.
Litecoin            147 sec.
Zcash               123 sec.
```

(Without taking uncles/ommers into account)

[//]: # ( #Blockchain #Blog #Analysis )

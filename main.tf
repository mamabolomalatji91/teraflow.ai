
import json
import sys
import pandas as pd
import numpy as np
import boto3 as boto3
import pg8000 
from modules.logger_util import Logger
from awsglue.utils import getResolvedOptions



ENDPOINT = "mycluster.cluster-123456789012.us-east-1.rds.amazonaws.com"
PORT = "5432"
USER = "postgres"
REGION = "af-south-1"
DBNAME = "mydb"
PSWORD = "5Y67bg#r#"

	
parameters = getResolvedOptions(sys.argv, ['DB_HOST','DB_NAME', 'DB_USER', 'DB_PASSWORD', 'BUCKET_NAME', 'DATA_FILE'])
logger = Logger('data_processor')


conn = pg8000.connect(
	host=parameters["DB_HOST"],
	database=parameters["DB_NAME"],
	user=parameters["DB_USER"],
	password=parameters["DB_PASSWORD"])


bucket_name = parameters["BUCKET_NAME"]
data_file_name = parameters["DATA_FILE"]

	
s3_client = boto3.client('s3')


	
def insert_data_to_db(statement, *args):	
	"""
	Function to insert record to db.
	:param statement: the statement to execute
	:return: the inserted record
	"""
	
	cursor = None

	try:
		cursor = conn.cursor()
		cursor.execute(statement, args)
		conn.commit()
		return cursor.fetchone()
	finally:

		if cursor is not None:
			cursor.close()


def read_data_from_s3():

	"""
	Function to read data from s3 file
	"""
	response = s3_client.get_object(Bucket=bucket_name,Key=data_file_name)
	return response['Body']


def process():

	"""
	Function to process data
	"""
	data_json = json.load(read_data_from_s3())
	logger.info("Successfully read data json: " + str(data_json))


	bank_info = data_json["bank_info"]


	for info in bank_info:
	bank_name = info["bank_name"]
	branch_name = info["branch_name"]
	client = info["client"]
	account_number = info["account_number"]
	loan_amount = info["loan_amount"]

## def ma(Data, period, onwhat, where):
    
##    for i in range(len(Data)):
##            try:
##                Data[i, where] = (Data[i - period:i + 1, onwhat].mean())
##        
##            except IndexError:
##                pass
##    return Data

def ma(Data, period, onwhat, where):
    
    for i in range(len(loan_amount)):
            try:
                loan_amount[i, where] = (loan_amount[i - 90:i + 1, 5].mean())
        
            except IndexError:
                pass
    return loan_amount


	insert_data_to_db(
	"""
	INSERT INTO BANK_INFO(bank_name, branch_name, client, account_number, loan_amount)
	VALUES(%s, %s, %s, %s , %s) RETURNING id
	""", bank_name, branch_name, client, account_number, loan_amount,)


	logger.info('Data processed for ' + bank_name + " " + branch_name + " " + client + account_number+ " " + loan_amount+ " " )

   logger.info("Data processing completed")


process()



def importdict(filename):#creates a function to read the csv

  df=pd.read_csv(bank_name_YYYYMMDD'.csv', names=['systemtime', 'Var1', 'var2'],nov=';',parse_dates=[0]) #or:, infer_datetime_format=True)
  fileDATES=df.T.to_dict().values()
  return fileDATES #return the dictionary to work with it outside the function
if __name__ == '__main__':...



if __name__ == "__main__":
    main()




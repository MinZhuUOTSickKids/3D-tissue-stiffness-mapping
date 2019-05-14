#!/usr/bin/python3
import numpy as np
import glob
import pandas as pd
import plot

allXlsxFiles = glob.glob("./*.xlsx")
xlsxFileId = -1
if len(allXlsxFiles) < 1:
	print("There are not .xlsx files in the current folder")
	exit()
elif len(allXlsxFiles) == 1:
	xlsxFileId = 0
else:
	print("List of Excel files:")
	for i in range(len(allXlsxFiles)):
		print("\t({0:d}) {1:s}".format(i, allXlsxFiles[i]))
	while xlsxFileId < 0:
		res = input("Please select a file: ")
		if res.isdigit() and int(res) >= 0 and int(res) < len(xl.allXlsxFiles):
			xlsxFileId = int(res)

xl = pd.ExcelFile(allXlsxFiles[xlsxFileId])

sheet_id = -1
if len(xl.sheet_names) > 1:
	print("Which sheet do you want to analyze?")
	for i in range(len(xl.sheet_names)):
		print("\t({0:d}) {1:s}".format(i, xl.sheet_names[i]))
	while sheet_id < 0:
		res = input("Please select a number: ")
		if res.isdigit() and int(res) >= 0 and int(res) < len(xl.sheet_names):
			sheet_id = int(res)
elif len(xl.sheet_names) == 1:
	sheet_id = 0
else:
	print("Your Excel doesn't have any sheets in it.")
	exit()

df = xl.parse(sheet_id)
if len(df.columns) < 4:
	print("The first three columns should store X, Y, and Z coordinates.")
	print("The columns following those 3 should store the data.")
	print("This sheet only has {0:d} columns.".format(len(df.columns)))
	exit()

x,y,z = None, None, None
for col in df.columns:
	if col == "Position X":
		x = np.array(df[col])
	elif col == "Position Y":
		y = np.array(df[col])
	elif col == "Position Z":
		z = np.array(df[col])

if x is None or y is None or z is None or len(x) != len(y) or len(x) != len(z):
	print("ERROR: Inconsistent X,Y,Z coordinates")
	exit()

print("Data columns:")
for i in range(len(df.columns)-3):
	print("\t({0:d}) {1:s}".format(i, df.columns[i+3]))
dataColId = -1
dataColName = ""
while dataColId < 0:
	res = input("Please select a data column: ")
	if res.isdigit() and int(res) >= 0 and int(res) < len(df.columns)-3:
		dataColId = int(res) + 3
		dataColName = df.columns[dataColId]

zcut = -1.
while zcut < 0. or zcut > 1.:
	res = input("Z cut (a number between 0 and 1): ")
	try:
		zcut = float(res)
	finally:
		pass

resolution = -1
while resolution < 0 or resolution > 3:
	res = input("Resolution Low (0), Medium (1), High (2): ")
	if res.isdigit():
		resolution = int(res)
plot.GeneratePlots(x,y,z,np.array(df[dataColName]), dataColName, zcut, resolution)
print("--end--")

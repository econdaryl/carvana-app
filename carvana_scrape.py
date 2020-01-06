# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time
from bs4 import BeautifulSoup

url = "https://www.carvana.com/cars"

driver = webdriver.Firefox()
driver.implicitly_wait(30)
driver.get(url)

cars = pd.DataFrame(columns = ['Make', 'Model', 'trim', 'Mileage', 'Price'])

check = 1

while check == 1:
    time.sleep(5)
    source = BeautifulSoup(driver.page_source, 'html.parser')
    car_box = source.find_all('div', attrs = {'data-qa': "result-tile"})

    for i in range(0, len(car_box)):
        make = car_box[i].find(attrs = {'data-qa': "result-tile-make"}).text
        model = car_box[i].find(attrs = {'data-qa': "result-tile-model"}).text
        trim = car_box[i].find(attrs = {'data-qa': "vehicle-trim"}).text
        miles = car_box[i].find(attrs = {'data-qa': "vehicle-mileage"}).text
        price = car_box[i].find('span', attrs = {'data-qa': "result-tile-price"}).text
        temp = pd.DataFrame([[make, model, trim, miles, price]], columns=['Make', 'Model', 'trim', 'Mileage', 'Price'])
        cars = cars.append(temp)

    try:
        driver.find_element_by_xpath("/html/body/div[1]/main/section/ul/li[3]/button[1]/span[1]").click()
    except:
        check = 0

print(cars)

driver.close()

cars.to_csv("C:\\Users\\Daryl Larsen\\Documents\\Python\\carvana_aug.csv")

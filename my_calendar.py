#! /usr/local/bin
# coding=utf-8
import datetime
import urllib
import json
import execjs

def getjson(url):
    response=urllib.urlopen(url).read()
    json_obj=str(response)
    return json.loads(json_obj)

js_path = "/Users/breeze/Documents/bash/calendar.js"

def get_js(path):
    f = open(path,'r')
    line = f.readline()
    html_str = ''
    while line:
        html_str = html_str + line
        line = f.readline()
    return html_str

def load_js(js_str):
    return execjs.compile(js_str)

calendar = load_js(get_js(js_path))

cur= datetime.datetime.now()
#date = "date={0}-{1}-{2}".format(cur.year,cur.month,cur.day)
#url = "http://www.sojson.com/open/api/lunar/json.shtml?" + date
#load_data = getjson(url)
json_data = calendar.call('solar2lunar', 'cur.year', 'cur.month', 'cur.day')

# lunarYear = load_data['data']['lunarYear']
# lunarMonth = load_data['data']['lunarMonth']
# lunarDay = load_data['data']['lunarDay']

lunarDay = json_data['lDay']
lunarMonth = json_data['lMonth']
lunarYear = json_data['lYear']
isLeap = json_data['isLeap']

#获取当前日期并转化成对应农历日期

lunarbirthday = {'外公':[10,10],'外婆':[2,22],'姨妈':[2,5],'朱正雷':[1,14],'老妈':[10,14],'榕妹':[6,6],'韫文':[12,18],'川川':[8,22]}
solarbirthday = {'袁知巧':[12,10],'张琦':[12,12],'钱姐':[4,4],'榕妹':[7,10],'韫文':[1,16],'狗子':[7,28],'包包':[3,25],'川川':[9,23],'博哥':[4,7],'包子':[4,6],'沛沛':[8,6]}

#存储农历和公历生日

nohappen = True

for item in lunarbirthday:
    if lunarbirthday[item][0]==lunarMonth:
        if (lunarbirthday[item][1]-3)<lunarDay<lunarbirthday[item][1]:
            print("  {0}将要农历生日,农历生日日期是{1}月{2}日,今日农历日期是{3}月{4}日".format(item,lunarbirthday[item][0],lunarbirthday[item][1], lunarMonth, lunarDay))
            nohappen = False
        if lunarbirthday[item][1]==lunarDay:
            print("  {0}今天农历生日,农历生日日期是{1}月{2}日,今日农历日期是{3}月{4}日".format(item,lunarbirthday[item][0],lunarbirthday[item][1], lunarMonth, lunarDay))
            nohappen = False
for item in solarbirthday:
    if solarbirthday[item][0]==cur.month:
        if (solarbirthday[item][1]-3)<cur.day<solarbirthday[item][1]:
            print("  {0}将要公历生日,公历生日日期是{1}月{2}日".format(item,solarbirthday[item][0],solarbirthday[item][1]))
            nohappen = False
        if solarbirthday[item][1]==cur.day:
            print("  {0}今天公历生日,公历生日日期是{1}月{2}日".format(item,solarbirthday[item][0],solarbirthday[item][1]))
            nohappen = False

if(nohappen):
    print("  No important events or birthday recently.")

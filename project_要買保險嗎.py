#匯入套件
import tkinter as tk
import csv

#匯入食物熱量
f_filename="Food.csv"
f_file=open(f_filename,"r")

f_list1=[]
f_list2=[]
f_list3=[]

print("食物熱量對照表")
f_rows = csv.reader(f_file)
for row in f_rows:
    f_list1.append(row[0])
    f_list2.append(int(row[1]))
    print("%-5s%s"%(row[1],row[0]))

#匯入運動消耗量

s_filename="Sports.csv"
s_file=open(s_filename,"r")

s_list1=[]
s_list2=[]
s_list3=[]

s_rows = csv.reader(s_file)
print("\n運動代號對照表")
for row in s_rows:
    s_list1.append(row[0])
    s_list2.append(row[1])
    s_list3.append(float(row[2]))
    #逐行印出
    print(row[1],row[2],"大卡/分鐘 每公斤")

#建立代號與消耗熱量的字典
s_dict=dict(zip(s_list1,s_list3))

i=1                 #第幾天減肥
key_root=False      #是否完成使用者資料建立
ing=False           #是否有其他功能在使用
cal=0               #熱量初始值
cal_over=False      #是否超量 
add=0               #攝取熱量
dec=0               #減少熱量

#建立使用者資料視窗
basic=tk.Tk()
basic.title("建立個人資料")

basic.minsize(width=500,height=300)             
basic.config(background="skyblue")

basic_first=tk.Label(text="計算你的基礎代謝率")
basic_first.config(bg="violet",font="微軟正黑體 20")
basic_first.pack()

#性別
label_gender=tk.Label(text="性別？(1男 0女)")
label_gender.config(bg="skyblue")
label_gender.pack() 
en_gender=tk.Entry()
en_gender.pack()

#年齡
label_age=tk.Label(text="年齡？(請輸入整數)")
label_age.config(bg="skyblue")
label_age.pack()
en_age=tk.Entry()
en_age.pack()

#身高
label_height=tk.Label(text="身高(cm)？")
label_height.config(bg="skyblue")
label_height.pack()
en_height=tk.Entry()
en_height.pack()

#體重
label_weight=tk.Label(text="體重(kg)？")
label_weight.config(bg="skyblue")
label_weight.pack()
en_weight=tk.Entry()
en_weight.pack()

#目標體重
label_tg_weight=tk.Label(text="目標體重(kg)？")
label_tg_weight.config(bg="skyblue")
label_tg_weight.pack()
en_tg_weight=tk.Entry()
en_tg_weight.pack()


label_check=tk.Label(text="")
label_check.config(bg="skyblue",fg="red",font="微軟正黑體 15")
label_check.pack()

#建立確認函數
def basic_check():
    try:
        global g
        g=int(en_gender.get())
        a=int(en_age.get())
        h=float(en_height.get())
        w=float(en_weight.get())
        global tg_weight
        tg_weight=float(en_tg_weight.get())
        global weight
        weight=w
        global basic_energe
        #計算基本代謝率(公式)
        if g==1:
            basic_energe=(13.7*w+5*h-6.8*a+66)*1.2
        elif g==0:
            basic_energe=(9.6*w+1.8*h-4.7*a+655)*1.2
    #要是輸入格式不正確，就不能進到主要app視窗
    except:
        label_check.config(text="輸入資料都做不好還想減肥啊？再給你一次機會")     
    #格式正確之後再檢查數值是否在合理範圍
    else:
        if g>1:
            label_check.config(text="你是不知道自己的性別嗎")
        elif a>=70:
            label_check.config(text="都幾歲了還要減肥 叫你孫子來好嗎？")
        elif a<15:
            label_check.config(text="小朋友？ 多吃一點趕快長高好嗎")
        elif h<120:
            label_check.config(text="你怎麼矮成這樣？ 小學生多吃一點好嗎")
        elif h>250 or w<30 :
            label_check.config(text="你是外星人嗎？　我們app只適用於地球人喔")    
        elif tg_weight>=w:
            label_check.config(text="目標體重比較高是要怎麼減肥 低能兒？")
        elif tg_weight<30:
            label_check.config(text="變那麼瘦是想慢性自殺嗎")
        else:    
            basic.destroy()
            global key_root
            key_root=True

#創造OK鍵來使用確認函數並計算基本代謝率
Ok_basic=tk.Button(text="Ok",command=basic_check)
Ok_basic.pack()

basic.mainloop()


#計算出基本代謝率後就打開主要app視窗
if key_root:
    root=tk.Tk()                
    root.title("毒舌減肥app")

    #視窗外觀調整
    root.minsize(width=500,height=600)             
    root.config(background="skyblue")
    root.attributes("-alpha",0.9) #0為完全透明,1為不透明

    #顯示現在體重，目標體重和今日剩餘攝取熱量等項目
    label_day=tk.Label(text="減肥第"+str(i)+"天")
    label_day.config(bg="violet",font="微軟正黑體 24")
    label_day.pack()

    label_basic=tk.Label(text="一天的基礎代謝率為"+str(round(basic_energe,3))+"大卡")
    label_basic.config(bg="skyblue",font="微軟正黑體 15")
    label_basic.pack()
   
    label_main1=tk.Label(text="現在"+str(round(weight,3))+"公斤")
    label_main1.config(bg="skyblue",font="微軟正黑體 15")
    label_main1.pack()

    label_main2=tk.Label(text="目標"+str(tg_weight)+"公斤")
    label_main2.config(bg="skyblue",font="微軟正黑體 15")
    label_main2.pack()

    label_main3=tk.Label(text="今日還能攝取的熱量為"+str(round(basic_energe-cal,3))+"大卡")
    label_main3.config(bg="skyblue",font="微軟正黑體 15")
    label_main3.pack()

    label_main4=tk.Label(text="今日已攝取熱量為"+str(add)+"大卡")
    label_main4.config(bg="skyblue",font="微軟正黑體 15")
    label_main4.pack()

    label_feat=tk.Label(text="請選擇功能")
    label_feat.config(bg="skyblue",font="微軟正黑體 15")
    label_feat.pack() 

    #函數設置
    #進食
    def eat():
        #先確認沒有其他運行中的功能
        global ing
        if not ing:
            #再確認是否熱量超標
            if cal_over:
                label_feat.config(text="還敢吃啊？熱量都爆表了")
            #熱量沒超標才能吃
            else:
                label_feat.config(text="Eat")
                ing=True

                #按下按鈕後會出現給你輸入熱量的地方
                label_sec1=tk.Label(text="吃了幾大卡啊")
                label_sec1.config(bg="violet",font="微軟正黑體 15")
                label_sec1.pack()

                en_sec1=tk.Entry()
                en_sec1.pack()

                label_result=tk.Label(text="")
                label_result.config(bg="skyblue",fg="red",font="微軟正黑體 15")        
                label_result.pack()

                #OK為偵錯功能，如果通過就把食物熱量加入今天的量
                def Ok():
                    #檢測是否為數字
                    try:
                        float(en_sec1.get())
                    except:
                        label_result.config(text="請輸入數字")
                    else:      
                        eaten=float(en_sec1.get())
                        #不是正數就要求重新輸入 
                        if eaten<0:
                            label_result.config(text="請輸入正數")
                        else:
                            global cal
                            global add
                            cal+=eaten                        
                            add+=eaten
                            label_main3.config(text="今日還能攝取的熱量為"+str(round(basic_energe-cal,3))+"大卡")
                            label_main4.config(text="今日已攝取熱量為"+str(round(add,3))+"大卡")

                            #確認熱量是否超標
                            if basic_energe<cal:
                                global cal_over
                                cal_over=True

                            #這項功能完成後，把輸入空間刪掉
                            label_sec1.destroy()
                            en_sec1.destroy()
                            label_result.destroy()
                            Ok_sec1.destroy()
                            Can_sec1.destroy()

                            #完成功能，可以執行其他功能了
                            global ing
                            ing=False
                            label_feat.config(text="請選擇功能")
                            
                        

                #為了避免按錯，用Cancel功能直接刪掉輸入空間
                def Cancel():
                    label_sec1.destroy()
                    en_sec1.destroy()
                    label_result.destroy()
                    Ok_sec1.destroy()
                    Can_sec1.destroy()
                    #完成功能，可以執行其他功能了
                    global ing
                    ing=False
                    label_feat.config(text="請選擇功能")

                #建立OK鍵
                Ok_sec1=tk.Button(text="Ok",command=Ok)
                Ok_sec1.pack()

                Can_sec1=tk.Button(text="Cancel",command=Cancel)
                Can_sec1.pack()
    #運動
    def sports():
        #先確認沒有其他運行中的功能        
        global ing
        if not ing:
            label_feat.config(text="Sports")
            ing=True
            label_sec1=tk.Label(text="請輸入消耗熱量")
            label_sec1.config(bg="violet",font="微軟正黑體 15")
            label_sec1.pack()

            en_sec1=tk.Entry()
            en_sec1.pack()

            label_result=tk.Label(text="")
            label_result.config(bg="skyblue",fg="red",font="微軟正黑體 15")  

            #OK1按鈕偵錯功能，如果通過就把消耗熱量從今天移除
            def Ok1():
                try:
                    float(en_sec1.get())
                except:
                    label_result.config(text="請輸入數字")
                else:
                    cos=float(en_sec1.get())
                    if cos<0:
                        label_result.config(text="請輸入正數")
                    else:    
                        global cal
                        global dec
                        cal-=cos                        
                        dec+=cos
                        label_main3.config(text="今日還能攝取的熱量為"+str(round(basic_energe-cal,3))+"大卡")

                        global cal_over
                        #確認熱量是否還是超標
                        if basic_energe>=cal:
                            cal_over=False
                        else:
                            cal_over=True

                        #這項功能完成後，把輸入空間刪掉
                        label_sec1.destroy()
                        label_sec2.destroy()
                        label_sec3.destroy()
                        en_sec1.destroy()
                        en_sec2.destroy()
                        en_sec3.destroy()
                        label_result.destroy()
                        Ok_sec1.destroy()
                        Ok_sec2.destroy()
                        Can_sec1.destroy()
                        #完成功能，可以執行其他功能了
                        global ing
                        ing=False
                        label_feat.config(text="請選擇功能")
                
            Ok_sec1=tk.Button(text="Ok",command=Ok1)
            Ok_sec1.pack()

            label_sec2=tk.Label(text="或選擇輸入運動項目")
            label_sec2.config(bg="violet",font="微軟正黑體 15")
            label_sec2.pack()            

            en_sec2=tk.Entry()
            en_sec2.pack()

            label_sec3=tk.Label(text="時間(分鐘數)")
            label_sec3.config(bg="violet",font="微軟正黑體 15")
            label_sec3.pack()            

            en_sec3=tk.Entry()
            en_sec3.pack()

            def Ok2():
                try:
                    sel=s_dict[en_sec2.get()]
                    time=float(en_sec3.get())
                except:
                    label_result.config(text="輸入錯誤")
                else:
                    if time<0:
                        label_result.config(text="請輸入正數")
                    else:    
                        global cal
                        global dec
                        cal-=sel*time*weight                       
                        dec+=sel*time*weight
                        label_main3.config(text="今日還能攝取的熱量為"+str(round(basic_energe-cal,3))+"大卡")

                        global cal_over
                        #確認熱量是否還是超標
                        if basic_energe>=cal:
                            cal_over=False
                        else:
                            cal_over=True

                        #這項功能完成後，把輸入空間刪掉
                        label_sec1.destroy()
                        label_sec2.destroy()
                        label_sec3.destroy()
                        en_sec1.destroy()
                        en_sec2.destroy()
                        en_sec3.destroy()
                        label_result.destroy()
                        Ok_sec1.destroy()
                        Ok_sec2.destroy()
                        Can_sec1.destroy()
                        #完成功能，可以執行其他功能了
                        global ing
                        ing=False
                        label_feat.config(text="請選擇功能")
        
            Ok_sec2=tk.Button(text="Ok",command=Ok2)
            Ok_sec2.pack()

            #為了避免按錯，用Cancel功能直接刪掉輸入空間        
            def Cancel():
                label_sec1.destroy()
                label_sec2.destroy()
                label_sec3.destroy()
                en_sec1.destroy()
                en_sec2.destroy()
                en_sec3.destroy()
                label_result.destroy()
                Ok_sec1.destroy()
                Ok_sec2.destroy()
                Can_sec1.destroy()
                #完成功能，可以執行其他功能了
                global ing
                ing=False
                label_feat.config(text="請選擇功能")
            Can_sec1=tk.Button(text="Cancel",command=Cancel)
            Can_sec1.pack()
            
            label_result.pack()

    #清除今天的卡路里
    def cleanup():
        global ing
        if not ing:
            label_feat.config(text="請選擇功能")
            global cal
            global add
            global dec
            global cal_over
            cal_over=False
            cal=0
            add=0
            dec=0
            label_main3.config(text="今日還能攝取的熱量為"+str(round(basic_energe,3))+"大卡")
            label_main4.config(text="今日已攝取熱量為"+str(add)+"大卡") 

    #把今天的卡路里記錄下來，並往後推一天
    def output():
        global ing
        if not ing:            
            global cal_over
            if cal_over:
                label_feat.config(text="給我先去運動")
            else:
                #把每一天的體重存到文件檔裡頭
                global cal
                global add
                global dec
                global i
                global weight
                global g
                global basic_energe
                if g==1:
                    basic_energe-=1.2*13.7*weight
                else:
                    basic_energe-=1.2*9.6*weight                
                weight-=((basic_energe+dec-add)/7700)
                if g==1:
                    basic_energe+=1.2*13.7*weight
                else:
                    basic_energe+=1.2*9.6*weight

                #確認是否達標
                if weight<=tg_weight:
                    label_feat.config(text="目標達成！別這樣就沾沾自喜，請繼續保持！")
                else:
                    label_feat.config(text="減肥是長久的事，不要放棄")
                f=open("要買保險嗎.txt","a+")
                f.write("第"+str(i)+"天攝取量為"+str(round(add,3))+"大卡 消耗量為"+str(round(dec,3))+"大卡 今日體重為"+str(round(weight,3))+" \n")
                f.close
                cal=0
                add=0
                dec=0
                cal_over=False
                #進到下一天
                i=i+1
                label_day.config(text="減肥第"+str(i)+"天")
                label_basic.config(text="一天的基礎代謝率為"+str(round(basic_energe,3))+"大卡")
                label_main1.config(text="現在"+str(round(weight,3))+"公斤")
                label_main3.config(text="今日還能攝取的熱量為"+str(round(basic_energe-cal,3))+"大卡")
                label_main4.config(text="今日已攝取熱量為"+str(add)+"大卡")
                
    #跳出功能，除非達到減重計畫否則不給跳出
    def quit():
        global ing
        if not ing:
            label_feat.config(text="請選擇功能")
            if weight>tg_weight:
                label_feat.config(text="別想逃避啊 肥豬")
            elif weight<=tg_weight:
                root.destroy()
                
    #建立功能按鈕
    E=tk.Button(text="Eat")
    E.config(width=8,height=2,command=eat)
    E.pack()

    S=tk.Button(text="Sports")
    S.config(width=8,height=2,command=sports)
    S.pack()

    C=tk.Button(text="Cleanup")
    C.config(width=8,height=2,command=cleanup)
    C.pack()

    O=tk.Button(text="Output")
    O.config(width=8,height=2,command=output)
    O.pack()

    Q=tk.Button(text="Quit")
    Q.config(width=8,height=2,command=quit)
    Q.pack()
    
    
    #常駐視窗
    root.mainloop()             

# what are final deliverables to show to Chip and to Daniel?

#1 show sales by calendar (sugrrant) by $, $ without outliers, checks, items?

#2 show shape of labor hours by each role

#3 show labor overlaid with sales for key roles, maybe remove the ribbons

# Ideas for future work
#1 prediction of future sales
#2 ongoing report like this as time goes on
#3 costs and margin on different entrees (if data is available)
#4 analysis of when different meals get sold through week or through year 


# July 18
# - Looks like not much yearly seasonality but definite trends through the week.  Show middle 50% or maybe 75%
    # do it for each of the main roles and for checks. Use faceting, maybe vertical
    # what for different timelines?  Need to look at each year to determine whether it's important

#2 Look at % of labor hours on each job category over time: 17 vs. 16; 18 vs. same period in 17


#June
# NEXT STEPS

  #figure out whether to use gndsale or gnditem for aggregated sales
  #leaningn toward sales because item has wacky price and discount, etc, but gndsales doesn't seem to have a good item column

#gndsale shows when various items were purchased as well as the length that each ticket was open
  # need to get clarity on TYPE and TYPEID in this file; also not clear on REVENUE but hypothesis is it's something like takeout vs. dine-in
gndsale <- read.dbf("GNDSALE.Dbf")

#gndlbsum appears to show how many people are working for each 15 min increment through the day, by jobtype
  # the MINUTES column shows how many labor minutes were used in that window, along with the labor cost
  # additional info needed would be what the JOBIDs correspond to
gndlbsum <- read.dbf("GNDLBSUM.Dbf")

#gndslsum appears to provide sales by category (by id) for 15 min increments
  # would need what CATID corresponds to
gndslsum <- read.dbf("GNDSLSUM.Dbf")

#adjtime appears to provide info on time worked.  Each line is a "shift" meaning from a clock-in to a clock-out time
adjtime <- read.dbf("ADJTIME.Dbf")

#Initial thoughts and questions

# how well are shifts aligned to sales and when most checks are open?
# what trends are there on length of ticket being open
# are there trends on when particular foods are ordered or not

#Other files
#123VER.DBF gives info on what version is being used of Aloha
#ACC.DBF Info job roles (compare with others similar)
#BRKRULE.DBF (Break Rule) Info on when breaks can be and categories of them, whether paid, etc
#BTN.DBF (Button) I think it's configuration of what's on screen for servers
#CAT.DBF (Categories) gives descriptions of the food categories used elsewhere
#CIT.DBF (Category Item) matches food items to categories I think
#CMG.DBF is messages to employees
#CMP.DBF looks to be exceptions like employee meals, etc.
#COIN.DBF is coins received/ready for deposit
#EMP.DBF has employee info with presumably current employees
#EMPOLD (Employee Old) has employee info with names, address, etc.
#GCHKINFO.Dbf (G Check Info) seems to be way to look up info surrounding a check
#GCI.DBF is messages that would go on a receipt for a customer
#GIF.DBF is gift certificate usage
#GLDP.DBF, GLLC.DBF, GLRC.DBF, and GLRCDP.DBF all seem to relate to hours worked and possibly payment for it
#GNDDPST.Dbf gives deposit info
#GNDDRWR.Dbf relates to the cash register drawer maybe?
#GNDITEM.DBF gives each item purchased and connects to its table, server, etc
#GNDLINE.DBF gives each item purchased I believe for the whole restaurant.  Join it with ITM.DBF for human readable info
#GNDPERF.Dbf shows performance in $ by employee
#GNDRevn.dbf is checks, their amounts, when opened and closed
#GndShift.Dbf is something about who had shifts that day
#GNDTndr.dbf is payments for checks
#GNDTurn.dbf is how quickly tables are turning over I think
#GNDVoid.dbf is voided checks
#ITM.DBF connects items (orders) with their IDs, like "Bowl Chili"
#JOB.DBF connects JOBIDs with descriptions like BUSSER, NO CLOSE SERVER
#LAB.DBF (labels?) seems to have job labels, such as SERVICE, KITCHEN, SUPPORT, etc
#MNU.DBF (Menus) sets the menu up for order entry by servers based on Breakfast, Lunch, and Dinner
#MOD.DBF (Modifications) is the modifications that can be made.  Explore more
#MODCODE.DBF seems to be codes for modifying orders, like "extra pickles"
#MSG.DBF is messages for employees maybe for during order entry
#OTHWAGE.DBF shows timesheet categories for unusual wage categories
#PET.DBF explore more.  Is it general expenses of restaurant?
#PRD.DBF seems to designate when meals start: Breakfast 5am, Lunch 11am, Dinner 4pm
#PRF.DBF maybe sales categories? One row has NET SALES
#PRO.DBF explore more.  Promotions?
#RSN.DBF seems to track who left without paying
#SCH.DBF has employee info but not all employees, maybe only mgmt or employees when system was created in 93
#SECLVL.DBF looks to be the possible levels of access that are possible
#SECLVLDT.DBF shows who has access to what levels in system, probably ALOHA, such as running reports, editing
#SUB.DBF looks to be prices and names of different items on menu.  Explore further
#TAB.DBF may be tabs that were opened through the day.  Only 8 on 6/27.
#TAX.DBF is tax rates of different sales like dine in and take out
#TDR.DBF has obscure payment info but not PII
#VOIDREV.DBF is records of voided checks including which manager approved it
#ZAP.DBF appears to be termination reasons

#Clarifying questions

# Why don't GNDSALE and GNDITEM match up in amounts? (reproduce it before asking)
# Are there ways that catering orders are distinguished?  What would the ones that represent $20,000 on one check mean?
# What can tell me about check numbers?  is check zero different somehow?  Is there a differences between the 100-, 200-, and 300- checks?